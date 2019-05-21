% This script pulls onsets and durations from the subject output files for
% ROC to create FX multicond files
%
% D.Cos 10/2018

%% Load data and intialize variables
inputDir = '~/Documents/code/sanlab/PCSR_scripts/task';
runNames = {'R1', 'R2'}; % add runs names here
writeDir = '~/Documents/code/sanlab/PCSR_scripts/fMRI/fx/multiconds/ROC/condition';
studyName = 'PC';
filePattern = 'PIC_Picture';
nConds = 4;
condNames = {'lookNeutral', 'lookNoCrave', 'lookCrave', 'reappraiseCrave', 'instructions', 'ratings'};

% list files in input directory
runFiles = dir(sprintf('%s/*PIC*.mat',inputDir));
filesCell = struct2cell(runFiles);

% extract subject IDs
subjectID = unique(extractBetween(filesCell(1,:), 1,3));

% exclude test responses
subjectID = subjectID(~cellfun(@isempty,regexp(subjectID, '[0-2]{1}[0-9]{2}')));

%% Loop through subjects and runs and save names, onsets, and durations as .mat files
for i = 1:numel(subjectID)
    sub = subjectID{i};
    files = dir(fullfile(inputDir, sprintf('%s_%s*.mat', sub, filePattern)));
    
    % warn if there are not 2 files
    if numel(files) ~= length(runNames)
        warning('Incorrect number of files. Subject %s has %d files.', sub, numel(files))
    end
    
    % log missing trial info
    missing{i,1} = sprintf('%s%s', studyName, sub);
    
    for j = 1:numel(runNames)
        %% Load text file
        run = runNames{j};
        runFile = dir(fullfile(inputDir, sprintf('%s_%s%s*.mat', sub, filePattern, run)));
        subFileName = {runFile.name};
        
        if ~isempty(subFileName)
            subFile = sprintf('%s/%s', inputDir, subFileName{end}); %select the last file

            if exist(subFile)
                load(subFile);
                
                %% Initialize names 
                names = condNames;

                %% Pull onsets
                for a = 1:nConds
                    idxs = find(strcmp(run_info.tag(:), num2str(a)));
                    idxs_image = idxs(2:3:length(idxs));
                    idxs_ratings_cond = idxs(3:3:length(idxs));
                    ratings_cond = run_info.responses(idxs_ratings_cond)';
                    onsets{a} = run_info.onsets(idxs_image)';
                    onsets{a}(find(cellfun(@isempty,ratings_cond))) = []; % remove missing trials
                end

                % Instructions
                idxs_all = find(~cellfun(@isempty,run_info.tag(:,1)));
                idxs_instructions = idxs_all(1:3:length(idxs_all));
                onsets{nConds+1} = run_info.onsets(idxs_instructions)';
                onsets{nConds+1}(onsets{nConds+1} == 0) = []; % remove incomplete trials

                % Ratings
                idxs_ratings = idxs_all(3:3:length(idxs_all));
                ratings = run_info.responses(idxs_ratings)';
                onsets{nConds+2} = run_info.onsets(idxs_ratings)';
                onsets{nConds+2}(find(cellfun(@isempty,ratings))) = []; % remove missing trials

                %% Create durations
                durations = onsets;

                % image conditions
                for b = 1:nConds
                    durations{b} = repelem(5, length(durations{b}))';
                end

                % instructions
                durations{nConds+1} = repelem(2, length(durations{nConds+1}))';

                % ratings (duration = rt)
                durations{nConds+2} = run_info.rt(idxs_ratings)';
                durations{nConds+2}(find(cellfun(@isempty,ratings))) = []; % remove missing trials
                
                %% Pull onsets and durations for missed responses (if any)
                % Missing responses are coded from image onset to rating
                % offset (9 seconds). Exclude incomplete trials.
                if sum(cellfun(@isempty,ratings) > 0)
                    idxs_missing = idxs_ratings(find(cellfun(@isempty,ratings)))-1;
                    if sum(run_info.onsets(idxs_missing)) > 0
                        names(nConds+3) = {'noResponse'};
                        onsets(nConds+3) = {run_info.onsets(idxs_missing)'};
                        onsets{nConds+3}(onsets{nConds+3} == 0) = []; % remove incomplete trials
                        durations(nConds+3) = {repelem(9, length(onsets{nConds+3}))'};
                    end
                end 

                %% Define output file name
                outputName = sprintf('%s%s_ROC%d.mat', studyName, sub, j);

                %% Save as .mat file and clear
                if ~exist(writeDir); mkdir(writeDir); end
                
                if ~(isempty(onsets{1}) && isempty(onsets{2}))
                    save(fullfile(writeDir,outputName),'names','onsets','durations');
                else
                    warning('File is empty. Did not save %s.', outputName);
                end

                %% Log missing trial info
                missing{i,j+1} = sum(cellfun(@isempty,ratings));
                
                clear names onsets durations;
            end
        else
            warning('Unable to load subject %s run %s.', sub, run);
        end
    end
end
  
% save missing trial info
missing(cellfun('isempty', missing)) = {NaN};
table = cell2table(missing,'VariableNames',[{'subjectID'}, runNames{:}]);
writetable(table,fullfile(writeDir, 'missing.csv'),'Delimiter',',')
fprintf('\nMissing trial info saved in %s\n', fullfile(writeDir, 'missing.csv'))