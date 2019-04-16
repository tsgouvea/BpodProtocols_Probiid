function updateCustomDataFields(iTrial)
global BpodSystem
global TaskParameters

statesThisTrial = BpodSystem.Data.RawData.OriginalStateNamesByNumber{iTrial}(BpodSystem.Data.RawData.OriginalStateData{iTrial});

%% Center port
if any(strcmp('Cin',statesThisTrial))
    if any(strcmp('stillSampling',statesThisTrial))
        BpodSystem.Data.Custom.CenterDelay(iTrial) = BpodSystem.Data.RawEvents.Trial{iTrial}.States.stillSampling(1,2) - BpodSystem.Data.RawEvents.Trial{iTrial}.States.Cin(1,1);
    else
        BpodSystem.Data.Custom.CenterDelay(iTrial) = diff(BpodSystem.Data.RawEvents.Trial{iTrial}.States.Cin);
    end
end
%% Side ports
if any(strcmp('Lin',statesThisTrial)) || any(strcmp('Rin',statesThisTrial))
    Sin = statesThisTrial{strcmp('Lin',statesThisTrial)|strcmp('Rin',statesThisTrial)};
    if any(strcmp('EarlySout',statesThisTrial))
        BpodSystem.Data.Custom.FictDelay(iTrial) = BpodSystem.Data.RawEvents.Trial{iTrial}.States.('EarlySout')(1,1) -  BpodSystem.Data.RawEvents.Trial{iTrial}.States.(Sin)(1,1);
    else
        BpodSystem.Data.Custom.FictDelay(iTrial) = BpodSystem.Data.RawEvents.Trial{iTrial}.States.ITI(end) -  BpodSystem.Data.RawEvents.Trial{iTrial}.States.(Sin)(1,1);
        temp = num2str(TaskParameters.GUI.Ports_LMR);
        if isfield(BpodSystem.Data.RawEvents.Trial{iTrial}.Events,['Port' temp('LMR'==Sin(1)) 'Out'])
            t_sout = BpodSystem.Data.RawEvents.Trial{iTrial}.Events.(['Port' temp('LMR'==Sin(1)) 'Out'])(:);
            t_sout = t_sout(t_sout > max(BpodSystem.Data.RawEvents.Trial{iTrial}.States.(Sin)(:)));
            if ~isempty(t_sout)
                BpodSystem.Data.Custom.FictDelay(iTrial) = t_sout(1) -  BpodSystem.Data.RawEvents.Trial{iTrial}.States.(Sin)(1,1);
            end
        else
            %diff(BpodSystem.Data.RawEvents.Trial{iTrial}.States.(Sin)(:));
        end
    end
else
    BpodSystem.Data.Custom.FictDelay(iTrial) = nan;
end
%%
if any(strcmp('Lin',statesThisTrial))
    BpodSystem.Data.Custom.ChoiceLeft(iTrial) = 1;
elseif any(strcmp('Rin',statesThisTrial))
    BpodSystem.Data.Custom.ChoiceLeft(iTrial) = 0;
end
BpodSystem.Data.Custom.EarlyCout(iTrial) = any(strcmp('EarlyCout',statesThisTrial));
BpodSystem.Data.Custom.EarlySout(iTrial) = any(strcmp('EarlySout',statesThisTrial));
BpodSystem.Data.Custom.Rewarded(iTrial) = any(strncmp('water_',statesThisTrial,6));
BpodSystem.Data.Custom.RewardMagnitude(iTrial) = TaskParameters.GUI.rewardAmount;

%% initialize next trial values
BpodSystem.Data.Custom.ChoiceLeft(iTrial+1) = NaN;
BpodSystem.Data.Custom.EarlyCout(iTrial+1) = false;
BpodSystem.Data.Custom.EarlySout(iTrial+1) = false;
BpodSystem.Data.Custom.Rewarded(iTrial+1) = false;
BpodSystem.Data.Custom.CenterDelay(iTrial+1) = NaN;
BpodSystem.Data.Custom.FictDelay(iTrial+1) = NaN;

%% Block count
nTrialsThisBlock = sum(BpodSystem.Data.Custom.BlockNumber == BpodSystem.Data.Custom.BlockNumber(iTrial));
if nTrialsThisBlock >= TaskParameters.GUI.blockLenMax
    % If current block len exceeds new max block size, will transition
    BpodSystem.Data.Custom.BlockLen(end) = nTrialsThisBlock;
end
if nTrialsThisBlock >= BpodSystem.Data.Custom.BlockLen(end)
    BpodSystem.Data.Custom.BlockNumber(iTrial+1) = BpodSystem.Data.Custom.BlockNumber(iTrial)+1;
    BpodSystem.Data.Custom.BlockLen(end+1) = drawBlockLen(TaskParameters);
    TaskParameters.GUI.ProbRwdL = betarnd(TaskParameters.GUI.ProbRwdAlphaL,TaskParameters.GUI.ProbRwdBetaL);
    TaskParameters.GUI.ProbRwdR = betarnd(TaskParameters.GUI.ProbRwdAlphaR,TaskParameters.GUI.ProbRwdBetaR);
else
    BpodSystem.Data.Custom.BlockNumber(iTrial+1) = BpodSystem.Data.Custom.BlockNumber(iTrial);
end
BpodSystem.Data.Custom.BlockProbRwdL(iTrial+1) = TaskParameters.GUI.ProbRwdL;
BpodSystem.Data.Custom.BlockProbRwdR(iTrial+1) = TaskParameters.GUI.ProbRwdR;

%% Baiting
BpodSystem.Data.Custom.Baited.Left(iTrial+1) = rand < BpodSystem.Data.Custom.BlockProbRwdL(iTrial);
BpodSystem.Data.Custom.Baited.Right(iTrial+1) = rand < BpodSystem.Data.Custom.BlockProbRwdR(iTrial);

%% Fictive Reward (Click Trains)
BpodSystem.Data.Custom.LeftClickTrain{iTrial+1} = GeneratePoissonClickTrain(TaskParameters.GUI.FictClickRate,TaskParameters.GUI.FictClickTrainDur);
BpodSystem.Data.Custom.RightClickTrain{iTrial+1} = GeneratePoissonClickTrain(TaskParameters.GUI.FictClickRate,TaskParameters.GUI.FictClickTrainDur);
if ~BpodSystem.Data.Custom.Baited.Left(iTrial+1)
    BpodSystem.Data.Custom.LeftClickTrain{iTrial+1} = min([ BpodSystem.Data.Custom.LeftClickTrain{iTrial+1}, BpodSystem.Data.Custom.RightClickTrain{iTrial+1}]);
end
if ~BpodSystem.Data.Custom.Baited.Right(iTrial+1)
    BpodSystem.Data.Custom.RightClickTrain{iTrial+1} = min([ BpodSystem.Data.Custom.LeftClickTrain{iTrial+1}, BpodSystem.Data.Custom.RightClickTrain{iTrial+1}]);
end
if ~BpodSystem.EmulatorMode
    SendCustomPulseTrain(1, BpodSystem.Data.Custom.RightClickTrain{iTrial+1}, ones(1,length(BpodSystem.Data.Custom.RightClickTrain{iTrial+1}))*5);
    SendCustomPulseTrain(2, BpodSystem.Data.Custom.LeftClickTrain{iTrial+1}, ones(1,length(BpodSystem.Data.Custom.LeftClickTrain{iTrial+1}))*5);
end
%increase sample time
%% Center port
switch TaskParameters.GUIMeta.CenterDelaySelection.String{TaskParameters.GUI.CenterDelaySelection}
    case 'Fix'
        TaskParameters.GUI.CenterDelay = TaskParameters.GUI.CenterDelayMax;
    case 'AutoIncr'
        if sum(~isnan(BpodSystem.Data.Custom.CenterDelay)) >= 10
            TaskParameters.GUI.CenterDelay = prctile(BpodSystem.Data.Custom.CenterDelay,TaskParameters.GUI.MinCutoff);
        else
            TaskParameters.GUI.CenterDelay = TaskParameters.GUI.CenterDelayMin;
        end
    case 'TruncExp'
        TaskParameters.GUI.CenterDelay = TruncatedExponential(TaskParameters.GUI.CenterDelayMin,...
            TaskParameters.GUI.CenterDelayMax,TaskParameters.GUI.CenterDelayTau);
    case 'Uniform'
        TaskParameters.GUI.CenterDelay = TaskParameters.GUI.CenterDelayMin + (TaskParameters.GUI.CenterDelayMax-TaskParameters.GUI.CenterDelayMin)*rand(1);
end
TaskParameters.GUI.CenterDelay = max(TaskParameters.GUI.CenterDelayMin,min(TaskParameters.GUI.CenterDelay,TaskParameters.GUI.CenterDelayMax));

%% Side ports
switch TaskParameters.GUIMeta.FictDelaySelection.String{TaskParameters.GUI.FictDelaySelection}
    case 'Fix'
        TaskParameters.GUI.FictDelay = TaskParameters.GUI.FictDelayMax;
    case 'AutoIncr'
        if sum(~isnan(BpodSystem.Data.Custom.FictDelay)) >= 10
            TaskParameters.GUI.FictDelay = prctile(BpodSystem.Data.Custom.FictDelay,TaskParameters.GUI.MinCutoff);
        else
            TaskParameters.GUI.FictDelay = TaskParameters.GUI.FictDelayMin;
        end
    case 'TruncExp'
        TaskParameters.GUI.FictDelay = TruncatedExponential(TaskParameters.GUI.FictDelayMin,...
            TaskParameters.GUI.FictDelayMax,TaskParameters.GUI.FictDelayTau);
    case 'Uniform'
        TaskParameters.GUI.FictDelay = TaskParameters.GUI.FictDelayMin + (TaskParameters.GUI.FictDelayMax-TaskParameters.GUI.FictDelayMin)*rand(1);

TaskParameters.GUI.FictDelay = max(TaskParameters.GUI.FictDelayMin,min(TaskParameters.GUI.FictDelay,TaskParameters.GUI.FictDelayMax));

% %% send bpod status to server
% try
%     BpodSystem.Data.Custom.Script = 'receivebpodstatus.php';
%     %create a common "outcome" vector
%     outcome = BpodSystem.Data.Custom.ChoiceLeft(1:iTrial); %1=left, 0=right
%     outcome(BpodSystem.Data.Custom.EarlyCout(1:iTrial))=3; %early C withdrawal=3
%     outcome(BpodSystem.Data.Custom.Jackpot(1:iTrial))=4; %jackpot=4
%     outcome(BpodSystem.Data.Custom.EarlySout(1:iTrial))=5; %early S withdrawal=5
%     SendTrialStatusToServer(BpodSystem.Data.Custom.Script,BpodSystem.Data.Custom.Rig,outcome,BpodSystem.Data.Custom.Subject,BpodSystem.CurrentProtocolName);
% catch
% end
end
