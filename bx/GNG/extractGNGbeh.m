%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% GNG behavioral analysis for PCSR
% written by Krista DeStasio
% adapted for PCSR by Nicole Giuliani
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% extract # and RT of correct and incorrect Go and NoGo trials

outputDir = '/Users/giuliani/OneDrive - University Of Oregon/PCSR/BehavioralData/GNG/output';
% create a vector of the trial numbers for each condition
% cd('/Users/giuliani/OneDrive - University Of Oregon/PCSR/scripts/behavioral/GNG');
% 
if ~exist(outputDir, 'dir')
  mkdir(outputDir);
end

% rename data files if they're in the original format. If not, comment out.
% orig_files = dir('*.mat');
% 
% for id = 1:length(orig_files)
%     [~, f, ext] = fileparts(orig_files(id).name);    % split file name into parts
%     ix = strfind(f,'_');                        % get the underscore locations
%     t = f(1:ix(3)-5);                           % return the substring up to 3rd underscore, remove .txt
%     rename = strcat(t,ext) ; 
%     movefile(orig_files(id).name, rename); 
% end

% Define columns in the task template file (needs 3 columns, stim type,
% event number, and event type; no headers or blank lines)
stimTypeCol=1;
indexCol=2;
eventTypeCol=3;
numRuns=2;
numSubs=79;
numTrials=256;
% Set up 8 blank matrices
GNG_CorrGo_RT = nan(numSubs,numRuns);
GNG_IncorrNoGo_RT = nan(numSubs,numRuns);

GNG_CorrGo_Count = nan(numSubs,numRuns);
GNG_CorrNoGo_Count = nan(numSubs,numRuns);
GNG_IncorrNoGo_Count = nan(numSubs,numRuns);
GNG_IncorrGo_Count = nan(numSubs,numRuns);
GNG_Corr_Count = nan(numSubs,numRuns);

GNG_IncorrGo_CountByBlock_run1 = nan(numSubs, numRuns);
GNG_IncorrGo_CountByBlock_run2 = nan(numSubs, numRuns);
% GNG_IncorrGo_CountByBlock_run3 = nan(numSubs, numRuns);
% GNG_IncorrGo_CountByBlock_run4 = nan(numSubs, numRuns);

for runNum=1:numRuns
    
    % make sure you have copies of the run text files in your directory
    taskfile=dir(['GNG' num2str(runNum) '.txt']);
    
    for k=1:length(taskfile)
        data=dlmread(taskfile(k).name,'\t');
        GoIndices = data(:,eventTypeCol)==1; % Create a binary vector to indicate whether a row is a go event
        GoEvents = data(GoIndices,indexCol); % Provide the even number corresponding to the go events
        NoGoIndices = data(:,eventTypeCol)==2; % Create a binary vector to indicate whehter a row is a no-go event
        NoGoEvents = data(NoGoIndices,indexCol); % Provide the even number corresponding to the no-go events
        AnimalCue = data(:,stimTypeCol)==1;
        NeutralCue = data(:,stimTypeCol)==2;
        InstructionIndices = data(:,eventTypeCol)==0;
        InstructEvents = data(InstructionIndices,indexCol);
    end

%     cd('/Users/giuliani/OneDrive - University Of Oregon/PCSR/BehavioralData/GNG')
    files = dir(['*' num2str(runNum) '.mat']); %loads all the .mats in that directory into matlab's workspace.
    numFiles = length(files);
    
    % corrGo
    % corrNoGo
    % IncorrNoGo
    % Instructions
    % Trash
    
    % Create a bunch of empty arrays
    CorrGo = nan(numFiles,numTrials);
    CorrGoRT = nan(numFiles,numTrials);
    CorrNoGo = nan(numFiles,numTrials);
    IncorrNoGo = nan(numFiles,numTrials);
    IncorrNoGoRT = nan(numFiles,numTrials);
    IncorrGo = nan(numFiles,numTrials);
    
    % Not sure this part is needed. Can probably split IncorrGo vector at
    % these indices 
    IncorrGo_block1 = nan(numFiles, range(InstructEvents(2), InstructEvents(3)));
    IncorrGo_block2 = nan(numFiles, range(InstructEvents(3), InstructEvents(4)));
    IncorrGo_block3 = nan(numFiles, range(InstructEvents(4), InstructEvents(5)));
    IncorrGo_block4 = nan(numFiles, range(InstructEvents(5), InstructEvents(6)));
    IncorrGo_block5 = nan(numFiles, range(InstructEvents(6), numTrials));

    IncorrGo_indices_block1 = InstructEvents(2):InstructEvents(3);
    IncorrGo_indices_block2 = InstructEvents(3):InstructEvents(4);
    IncorrGo_indices_block3 = InstructEvents(4):InstructEvents(5);
    IncorrGo_indices_block4 = InstructEvents(5):InstructEvents(6);
    IncorrGo_indices_block5 = InstructEvents(6):numTrials;
    
    for i = 1:numFiles
        inputFilename = files(i).name;
        load(inputFilename);
        responsesRaw=run_info.responses; %pull out the cell array of button presses
        rtsRaw=run_info.rt; %pull out the cell array of RTs
        subNum = str2num(inputFilename(1:3));
        
        for t=1:numTrials % go through each trial
            % assign it to CorrGo column if it's CorrGo (any button press
            % counts as a go)
            if ismember(t,GoEvents) && ~isempty(responsesRaw{t})
                CorrGo(i,t) = 1;
                CorrGoRT(i,t) = rtsRaw(t);
                
                % assign it to CorrNoGo column if it's CorrNoGo
            elseif ismember(t,NoGoEvents) && isempty(responsesRaw{t})
                CorrNoGo(i,t) = 1;
                
                % assign it to IncorrNoGo column if it's IncorrNoGo
            elseif ismember(t,NoGoEvents) && ~isempty(responsesRaw{t})
                IncorrNoGo(i,t) = 1;
                IncorrNoGoRT(i,t) = rtsRaw(t);
                
                % assign it to IncorrGo column if it's IncorrGo
            elseif ismember(t,GoEvents) && isempty(responsesRaw{t})
                IncorrGo(i,t) = 1;
                if ismember(t, IncorrGo_indices_block1)
                    IncorrGo_block1(i,t) = 1;
                elseif ismember(t, IncorrGo_indices_block2)
                    IncorrGo_block2(i,t) = 1;
                elseif ismember(t, IncorrGo_indices_block3)
                    IncorrGo_block3(i,t) = 1;
                elseif ismember(t, IncorrGo_indices_block4)
                    IncorrGo_block4(i,t) = 1;
                elseif ismember(t, IncorrGo_indices_block5)
                    IncorrGo_block5(i,t) = 1;
                end
            end
        end

        
        
        GNG_CorrGo_RT(subNum,runNum) = nanmean(CorrGoRT(i,:));
        GNG_CorrGo_RT_Animal(subNum,runNum) = nanmean(CorrGoRT(i,AnimalCue));
        GNG_CorrGo_RT_Neutral(subNum,runNum) = nanmean(CorrGoRT(i,NeutralCue));
        GNG_IncorrNoGo_RT(subNum,runNum) = nanmean(IncorrNoGoRT(i,:));
        
        GNG_CorrGo_Count(subNum,runNum) = nansum(CorrGo(i,:));
        GNG_CorrGo_Count_Animal(subNum,runNum) = nansum(CorrGo(i,AnimalCue));
        GNG_CorrGo_Count_Neutral(subNum,runNum) = nansum(CorrGo(i,NeutralCue));
        
        GNG_CorrNoGo_Count(subNum,runNum) = nansum(CorrNoGo(i,:));
        GNG_CorrNoGo_Count_Animal(subNum,runNum) = nansum(CorrNoGo(i,AnimalCue));
        GNG_CorrNoGo_Count_Neutral(subNum,runNum) = nansum(CorrNoGo(i,NeutralCue));
        
        GNG_IncorrNoGo_Count(subNum,runNum) = nansum(IncorrNoGo(i,:));
        GNG_IncorrNoGo_Count_Animal(subNum,runNum) = nansum(IncorrNoGo(i,AnimalCue));
        GNG_IncorrNoGo_Count_Neutral(subNum,runNum) = nansum(IncorrNoGo(i,NeutralCue));
        
        GNG_IncorrGo_Count(subNum,runNum) = nansum(IncorrGo(i,:));
        GNG_IncorrGo_Count_Animal(subNum,runNum) = nansum(IncorrGo(i,AnimalCue));
        GNG_IncorrGo_Count_Neutral(subNum,runNum) = nansum(IncorrGo(i,NeutralCue));
        
        GNG_Corr_Count(subNum,runNum) = nansum(CorrGo(i,:))+nansum(CorrNoGo(i,:));
        
        GNG_IncorrGo_CountByBlock_block1(subNum, runNum) = nansum(IncorrGo_block1(i,:));
        GNG_IncorrGo_CountByBlock_block2(subNum, runNum) = nansum(IncorrGo_block2(i,:));
        GNG_IncorrGo_CountByBlock_block3(subNum, runNum) = nansum(IncorrGo_block3(i,:));
        GNG_IncorrGo_CountByBlock_block4(subNum, runNum) = nansum(IncorrGo_block4(i,:));
        GNG_IncorrGo_CountByBlock_block5(subNum, runNum) = nansum(IncorrGo_block5(i,:));
        
    end %end numFiles loop
end

save([outputDir '/rtMean_GNG']);
% dlmwrite('~/Desktop/REV/GNG/output/accuracyGNG4.txt', acc_GNG4, 'delimiter','\t');
dlmwrite([outputDir '/GNG_CorrGo_RT.txt'], GNG_CorrGo_RT, 'delimiter','\t');
dlmwrite([outputDir '/GNG_IncorrNoGo_RT.txt'], GNG_IncorrNoGo_RT, 'delimiter','\t');
dlmwrite([outputDir '/GNG_CorrGo_RT_Animal.txt'], GNG_CorrGo_RT_Animal, 'delimiter','\t');
dlmwrite([outputDir '/GNG_CorrGo_RT_Neutral.txt'], GNG_CorrGo_RT_Neutral, 'delimiter','\t');
dlmwrite([outputDir '/GNG_CorrGo_Count.txt'], GNG_CorrGo_Count, 'delimiter','\t');
dlmwrite([outputDir '/GNG_CorrGo_Count_Animal.txt'], GNG_CorrGo_Count_Animal, 'delimiter','\t');
dlmwrite([outputDir '/GNG_CorrGo_Count_Neutral.txt'], GNG_CorrGo_Count_Neutral, 'delimiter','\t');
dlmwrite([outputDir '/GNG_CorrNoGo_Count.txt'], GNG_CorrNoGo_Count, 'delimiter','\t');
dlmwrite([outputDir '/GNG_CorrNoGo_Count_Animal.txt'], GNG_CorrNoGo_Count_Animal, 'delimiter','\t');
dlmwrite([outputDir '/GNG_CorrNoGo_Count_Neutral.txt'], GNG_CorrNoGo_Count_Neutral, 'delimiter','\t');
dlmwrite([outputDir '/GNG_IncorrNoGo_Count.txt'], GNG_IncorrNoGo_Count, 'delimiter','\t');
dlmwrite([outputDir '/GNG_IncorrNoGo_Count_Animal.txt'], GNG_IncorrNoGo_Count_Animal, 'delimiter','\t');
dlmwrite([outputDir '/GNG_IncorrNoGo_Count_Neutral.txt'], GNG_IncorrNoGo_Count_Neutral, 'delimiter','\t');
dlmwrite([outputDir '/GNG_IncorrGo_Count.txt'], GNG_IncorrGo_Count, 'delimiter','\t');
dlmwrite([outputDir '/GNG_IncorrGo_Count_Animal.txt'], GNG_IncorrGo_Count_Animal, 'delimiter','\t');
dlmwrite([outputDir '/GNG_IncorrGo_Count_Neutral.txt'], GNG_IncorrGo_Count_Neutral, 'delimiter','\t');
dlmwrite([outputDir '/GNG_Corr_Count.txt'], GNG_Corr_Count, 'delimiter','\t');
dlmwrite([outputDir '/GNG_IncorrGo_CountByBlock_block1.txt'], GNG_IncorrGo_CountByBlock_block1, 'delimiter','\t');
dlmwrite([outputDir '/GNG_IncorrGo_CountByBlock_block2.txt'], GNG_IncorrGo_CountByBlock_block2, 'delimiter','\t');
dlmwrite([outputDir '/GNG_IncorrGo_CountByBlock_block3.txt'], GNG_IncorrGo_CountByBlock_block3, 'delimiter','\t');
dlmwrite([outputDir '/GNG_IncorrGo_CountByBlock_block4.txt'], GNG_IncorrGo_CountByBlock_block4, 'delimiter','\t');
dlmwrite([outputDir '/GNG_IncorrGo_CountByBlock_block5.txt'], GNG_IncorrGo_CountByBlock_block5, 'delimiter','\t');
