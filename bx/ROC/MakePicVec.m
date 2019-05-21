function MakePicVec(Out,CIndx,SubNum,Run)
VecDir = '/Users/giuliani/OneDrive - University Of Oregon/PCSR/analyses/task_bx/PicVecs/';
Stim = zeros(40,5);

Fours = [1:4:160];
for St = 1:40
    Stim(St,1) = Out(Fours(1,St)+1,5);
    Stim(St,2) = Out(Fours(1,St)+1,1);
    Stim(St,3) = Stim(St,2) + Out(Fours(1,St)+1,2) + Out(Fours(1,St)+2,2);
    Stim(St,4) = Out(Fours(1,St)+3,3);
    Stim(St,5) = Out(Fours(1,St)+3,4);
end
LNe=Stim(:,1)==1; LNo=Stim(:,1)==2; LCr=Stim(:,1)==3; RCr=Stim(:,1)==4;

names = {'LookNeutral' 'LookNoCrave' 'LookCrave' 'RegulateCrave' 'Rate'};
onsets = cell(1,5);
durations = cell(1,5);
pmod = struct('name',{''},'param',{},'poly',{});

for in =1:4
    onsets{in} = Stim((Stim(:,1)==in),2);
    durations{in} = Stim((Stim(:,1)==in),3);
    pmod(in).name{1} = 'Crave'; pmod(in).name{2}  = 'RT';
    pmod(in).poly{1} = 1; pmod(in).poly{2}  = 1;
    param1 = Stim((Stim(:,1)==in),4);
    pmod(in).param{1} = param1 - mean(param1);
    param2 = Stim((Stim(:,1)==in),5);
    pmod(in).param{2} = param2 - mean(param2);
end
onsets{5} = Out(CIndx(:,2),1);
durations{5} =4;
save(strcat(VecDir,SubNum,'_',Run,'.mat'),'names','onsets','durations','pmod');