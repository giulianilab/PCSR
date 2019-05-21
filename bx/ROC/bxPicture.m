%% MRI Picture
TaskDir='/Users/giuliani/OneDrive - University Of Oregon/PCSR/BehavioralData/Food';
AnaDir='/Users/giuliani/OneDrive - University Of Oregon/PCSR/analyses/task_bx';
Mats = dir('/Users/giuliani/OneDrive - University Of Oregon/PCSR/BehavioralData/Food/*.mat');
PictureStruct = struct;

sNum = [zeros(length(Mats),1) ones(length(Mats),1)];
for w = 1:length(Mats)
   
    Subs{w,1} = Mats(w).name(1:3);
    sNum(w,1) = str2num(Subs{w,1}(1:3));
    if w > 1 && (sNum(w,1) == sNum(w-1,1))
        sNum(w,2) = 2;
    end
end
clear w;
sSubs = Subs(sNum(:,2)==1,1);
PictureSum1 = cell(length(sSubs),9);
PictureData = zeros(length(sSubs),8);
load('/Users/giuliani/OneDrive - University Of Oregon/PCSR/analyses/task_bx/PicRunStimOrder.mat');
%load('/media/Crunch/CHIVES/code/picture/Conditions.mat');
% PictureGroups=zeros(length(sSubs),1);
for v = 1:length(sSubs)
    sMats = dir(fullfile(TaskDir,strcat(sSubs{v,1},'*.mat')));
    PictureSum1(v,1) =  {sSubs{v,1}};
    SubNum = strcat('PC',sMats(1).name(1:3));
    PictureStruct(v).Sub = SubNum;
    PictureStruct(v).AllOut = [];
    if length(sMats)==1
        Xx = [1];
    elseif length(sMats)==2
        Xx = [1 2];
    end
    ResponseIndex = zeros(0);
    for x = Xx     %1:length(sMats)
        load(fullfile(TaskDir,sMats(x).name));
        Run = sMats(x).name(16:17);
        Responses = zeros(161,1); Tags = zeros(161,1);
        for Rs = 1:length(run_info.responses);
            if ~isempty(run_info.responses{1,Rs});
                Responses(Rs,1) = str2num(run_info.responses{1,Rs});
            end
            if ~isempty(run_info.tag{Rs,1});
                Tags(Rs,1) = str2num(run_info.tag{Rs,1});
            end
        end
        ResponseIn1 = Responses > 0;
        ResponseIndex = [ResponseIndex; ResponseIn1];
        Out = [run_info.onsets' run_info.durations' Responses run_info.rt' Tags];
        
        if str2num(Run(2))==1
            StimOrder = PicR1StimOrder;
        elseif str2num(Run(2))==2
            StimOrder = PicR2StimOrder;
        end

        PictureStruct(v).Run(x).Num = Run; PictureStruct(v).Run(x).Data = run_info;
        PictureStruct(v).Run(x).OutPut = Out;
        PictureStruct(v).AllOut = [PictureStruct(v).AllOut; Out];
    end
%     load('/Users/giuliani/OneDrive - University Of Oregon/PCSR/analyses/task_bx/GroupxID_100s.mat');
%     WhichGroup=strcmpi(ID,SubNum); PictureStruct(v).Group=Group(WhichGroup);
%     PictureGroups(v,1)=Group(WhichGroup);
    ResponseIndex = ResponseIndex > 0;
    AllOut = PictureStruct(v).AllOut;
    LNeut = ResponseIndex&(AllOut(:,5)==1); LNoCr = ResponseIndex&(AllOut(:,5)==2);
    LCrav = ResponseIndex&(AllOut(:,5)==3); RCrav = ResponseIndex&(AllOut(:,5)==4); 
    meanCrave = [mean(AllOut(LNeut,3)) mean(AllOut(LNoCr,3)) mean(AllOut(LCrav,3)) mean(AllOut(RCrav,3))];
    medRTs = [median(AllOut(LNeut,4)) median(AllOut(LNoCr,4)) median(AllOut(LCrav,4)) median(AllOut(RCrav,4))];
    PictureData(v,:) = [meanCrave medRTs];
    PictureData1 = PictureData(:,[1:4]) - 4;
    PictureData2 = PictureData(:,[5:8]);
    PictureDataAll = [PictureData1 PictureData2];
    %PictureSum1(v,2:9) = {PictureData(v,:)};
end

%PictureData = cell2mat(PictureSum1(:,2:9));
Ttest=struct('Test',{},'Tstat',{},'P',{},'RejNull',{},'ConfInt',{});

Ttest(1).Test='LookCraveRate>LookNeutralRate';
[h,p,ci,stats] = ttest(PictureDataAll(:,3),PictureDataAll(:,1));
Ttest(1).Tstat=stats; Ttest(1).P=p; Ttest(1).RejNull=h; Ttest(1).ConfInt=ci;

Ttest(2).Test='LookCraveRate>LookNoCraveRate';
[h,p,ci,stats] = ttest(PictureDataAll(:,3),PictureDataAll(:,2));
Ttest(2).Tstat=stats; Ttest(2).P=p; Ttest(2).RejNull=h; Ttest(2).ConfInt=ci;

Ttest(3).Test='LookCraveRate>RegulateCraveRate';
[h,p,ci,stats] = ttest(PictureDataAll(:,3),PictureDataAll(:,4));
Ttest(3).Tstat=stats; Ttest(3).P=p; Ttest(3).RejNull=h; Ttest(3).ConfInt=ci;

%[h,p,ci,stats] = ttest(PictureData(:,7),PictureData(:,5))
% [h,p,ci,stats] = ttest(PictureData(:,7),PictureData(:,6))

Ttest(4).Test='LookCraveRT>RegulateCraveRT';
[h,p,ci,stats] = ttest(PictureDataAll(:,7),PictureDataAll(:,8));
Ttest(4).Tstat=stats; Ttest(4).P=p; Ttest(4).RejNull=h; Ttest(4).ConfInt=ci;

LookRegCraveRateDiff = PictureDataAll(:,3) - PictureDataAll(:,4);
LookRegCraveRTDiff = PictureDataAll(:,7) - PictureDataAll(:,8);
% Group28s = [1 0 1 0 0 1 0 1 0 0 0 0 1 1 1 1 1 0 1 1 0 1 1 1 1 0 0 0]';
% GroupIndex = PictureGroups > 0;

% Ttest(5).Test='LookCraveRate>RegulateCraveRate for Exp>Control';
% [h,p,ci,stats] = ttest2(LookRegCraveRateDiff(GroupIndex,1),LookRegCraveRateDiff(~GroupIndex,1),[],[],'unequal');
% Ttest(5).Tstat=stats; Ttest(5).P=p; Ttest(5).RejNull=h; Ttest(5).ConfInt=ci;
% 
% Ttest(6).Test='LookCraveRT>RegulateCraveRT for Exp>Control';
% [h,p,ci,stats] = ttest2(LookRegCraveRTDiff(GroupIndex,1),LookRegCraveRTDiff(~GroupIndex,1),[],[],'unequal');
% Ttest(6).Tstat=stats; Ttest(6).P=p; Ttest(6).RejNull=h; Ttest(6).ConfInt=ci;

save(fullfile(AnaDir,'PicturesMRI.mat'), 'PictureSum1', 'PictureStruct', 'PictureDataAll', 'Ttest');
clear
%%


%% 
Summaries=findfiles(fullfile('/Users/giuliani/OneDrive - University Of Oregon/PCSR/analyses/task_bx/Pictures*.mat'));
MStruct=struct('Session',{},'Subs',{},'Data',{}); load('/Users/giuliani/OneDrive - University Of Oregon/PCSR/analyses/task_bx/GroupxID_100s.mat');
MSum=cell(92,(8*3)+1); MSum(:,1)=ID; Ranges=[2:9; 10:17; 18:25];
for y=1:length(Summaries)
    load(Summaries{y,1}); session=Summaries{y,1}((length(Summaries{y,1})-8):(length(Summaries{y,1})-4));
%     MStruct(y).Session=session; MStruct(y).Subs=PictureSum1(:,1); MStruct(y).Data=PictureData;
    Subs=PictureSum1(:,1);
    for s =1:length(Subs)
        subid=strcat('PC',Subs(s,1));
        Sindex=strcmpi(ID,subid); 
        MSum(Sindex,Ranges(y,:))=num2cell(PictureDataAll(s,1:8));
    end
end
Conditions={'LkNeutRate' 'LkNoCrRate' 'LkCravRate' 'RgCravRate' 'LkNeutMdRT' 'LkNoCrMdRT' 'LkCravMdRT' 'RgCravMdRT'};
Sessions={'MRI'}; AllConds=cell(length(Sessions),length(Conditions));
for Sess=1:length(Sessions)
    for Cond=1:length(Conditions)
        AllConds(Sess,Cond)=strcat(Sessions(1,Sess),'_',Conditions(1,Cond));
    end
end
% FirstRow=['SubID' 'Group' AllConds(1,:) AllConds(2,:) AllConds(3,:)];
FirstRow=['SubID' 'Group' AllConds(1,:)];
RemainingRows=[ID num2cell(Group) MSum(:,2:9)];
FinalSpreadSheet=[FirstRow; RemainingRows];
ds=cell2dataset(FinalSpreadSheet); export(ds,'file','PictureSummary.csv','delimiter',',');



%% Uncomment if you want to see t-test results
% for y=1:length(Summaries)
%     load(Summaries{y,1})
%     for z=1:length(Ttest)
%         Ttest(1,z)
%         pause
%     end
% end
clear