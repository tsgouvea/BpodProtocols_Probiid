function Matching
% Reproduction on Bpod of protocol used in the PatonLab, MATCHINGvFix

global BpodSystem
global TaskParameters

%% Task parameters
TaskParameters = BpodSystem.ProtocolSettings;
if isempty(fieldnames(TaskParameters))
    %% General
    TaskParameters.GUI.Ports_LMR = '123';
    TaskParameters.GUI.ITI = 1; % (s)
    TaskParameters.GUI.VI = false; % random ITI
    TaskParameters.GUIMeta.VI.Style = 'checkbox';
    TaskParameters.GUI.ChoiceDeadline = 10;
    TaskParameters.GUI.MinCutoff = 50; % New waiting time as percentile of empirical distribution
    TaskParameters.GUI.nTrialsBack = 10;
    TaskParameters.GUIPanels.General = {'Ports_LMR','ITI','VI','ChoiceDeadline','MinCutoff','nTrialsBack'};

    %% Center Port ("stimulus sampling")
    TaskParameters.GUI.EarlyCoutPenalty = 0;
    TaskParameters.GUI.CenterDelaySelection = 4;
    TaskParameters.GUIMeta.CenterDelaySelection.Style = 'popupmenu';
    TaskParameters.GUIMeta.CenterDelaySelection.String = {'Fix','AutoIncr','TruncExp','Uniform'};
    TaskParameters.GUI.CenterDelayMin = 0.2;
    TaskParameters.GUI.CenterDelayMax = 0.5;
    TaskParameters.GUI.CenterDelayTau = 0.2;
    TaskParameters.GUI.CenterDelay = TaskParameters.GUI.CenterDelayMin;
    TaskParameters.GUIMeta.CenterDelay.Style = 'text';
    TaskParameters.GUIPanels.CenterDelay = {'EarlyCoutPenalty','CenterDelaySelection','CenterDelayMin','CenterDelayMax','CenterDelayTau','CenterDelay'};

    % Clicks
    TaskParameters.GUI.FictBNCout = 2;
    TaskParameters.GUI.FictDelaySelection = 2;
    TaskParameters.GUIMeta.FictDelaySelection.Style = 'popupmenu';
    TaskParameters.GUIMeta.FictDelaySelection.String = {'Fix','AutoIncr','TruncExp','Uniform'};
    TaskParameters.GUI.FictDelayMin = 0;
    TaskParameters.GUI.FictDelayMax = 1;
    TaskParameters.GUI.FictDelayTau = 0.4;
    TaskParameters.GUI.FictDelay = TaskParameters.GUI.FictDelayMin;
    TaskParameters.GUIMeta.FictDelay.Style = 'text';
    TaskParameters.GUI.FictClickTrainDur = 1;
    TaskParameters.GUI.FictClickRate = 100;
    TaskParameters.GUIPanels.WouldHaveReward = {'FictBNCout','FictDelaySelection','FictDelayMin','FictDelayMax','FictDelayTau','FictDelay','FictClickTrainDur','FictClickRate'};

    % Side Ports ("waiting for feedback")
    TaskParameters.GUI.EarlySoutPenalty = 0;
    TaskParameters.GUI.RewardDelay = .25; % From click train onset
    TaskParameters.GUI.Grace = 0.1;
    TaskParameters.GUIPanels.SidePorts = {'EarlySoutPenalty','RewardDelay','Grace'};

    % Reward
    TaskParameters.GUI.ProbRwdMean = 0.4;
    TaskParameters.GUI.ProbBetaA = 3;
    TaskParameters.GUI.ProbRwdL = TaskParameters.GUI.ProbRwdMean;
    TaskParameters.GUIMeta.ProbRwdL.Style = 'text';
    TaskParameters.GUI.ProbRwdR = TaskParameters.GUI.ProbRwdMean;
    TaskParameters.GUIMeta.ProbRwdR.Style = 'text';

    TaskParameters.GUI.Unbias = true;
    TaskParameters.GUIMeta.Unbias.Style = 'checkbox';
    TaskParameters.GUI.ProbRwdBias = 0.5;
    TaskParameters.GUIMeta.ProbRwdBias.Style = 'text';

    TaskParameters.GUI.blockLenMin = 80;
    TaskParameters.GUI.blockLenMax = 120;
    TaskParameters.GUI.rewardAmount = 30;
    TaskParameters.GUIPanels.Reward = {'rewardAmount','blockLenMin','blockLenMax', 'ProbRwdMean','ProbBetaA','ProbRwdL','ProbRwdR','Unbias','ProbRwdBias'};

    TaskParameters.GUI = orderfields(TaskParameters.GUI);
end
TaskParameters.GUI.CenterDelay = TaskParameters.GUI.CenterDelayMin;
TaskParameters.GUI.FictDelay = TaskParameters.GUI.FictDelayMin;
BpodParameterGUI('init', TaskParameters);

%% Initializing data (trial type) vectors

BpodSystem.Data.Custom.Baited.Left = true;
BpodSystem.Data.Custom.Baited.Right = true;

BpodSystem.Data.Custom.LeftClickTrain{1} = GeneratePoissonClickTrain(TaskParameters.GUI.FictClickRate,TaskParameters.GUI.FictClickTrainDur);
BpodSystem.Data.Custom.RightClickTrain{1} = GeneratePoissonClickTrain(TaskParameters.GUI.FictClickRate,TaskParameters.GUI.FictClickTrainDur);
if ~BpodSystem.Data.Custom.Baited.Left
    BpodSystem.Data.Custom.LeftClickTrain{1} = min([ BpodSystem.Data.Custom.LeftClickTrain{1}, BpodSystem.Data.Custom.RightClickTrain{1}]);
end
if ~BpodSystem.Data.Custom.Baited.Right
    BpodSystem.Data.Custom.RightClickTrain{1} = min([ BpodSystem.Data.Custom.LeftClickTrain{1}, BpodSystem.Data.Custom.RightClickTrain{1}]);
end

BpodSystem.Data.Custom.BlockNumber = 1;
% BpodSystem.Data.Custom.BetaBL = TaskParameters.GUI.ProbBetaA*((1-TaskParameters.GUI.ProbRwdMean)/TaskParameters.GUI.ProbRwdMean);
% BpodSystem.Data.Custom.BetaBR = TaskParameters.GUI.ProbBetaA*((1-TaskParameters.GUI.ProbRwdMean)/TaskParameters.GUI.ProbRwdMean);
BpodSystem.Data.Custom.BlockProbRwdL = TaskParameters.GUI.ProbRwdL;
BpodSystem.Data.Custom.BlockProbRwdR = TaskParameters.GUI.ProbRwdR;
BpodSystem.Data.Custom.BlockLen = drawBlockLen(TaskParameters);

BpodSystem.Data.Custom.ChoiceLeft = NaN;
BpodSystem.Data.Custom.EarlyCout(1) = false;
BpodSystem.Data.Custom.EarlySout(1) = false;
BpodSystem.Data.Custom.Rewarded = false;
BpodSystem.Data.Custom.RewardMagnitude = TaskParameters.GUI.rewardAmount;
BpodSystem.Data.Custom.CenterDelay(1) = NaN;
% BpodSystem.Data.Custom.FeedbackTime(1) = NaN;

%server data
BpodSystem.Data.Custom.Rig = getenv('computername');
[~,BpodSystem.Data.Custom.Subject] = fileparts(fileparts(fileparts(fileparts(BpodSystem.DataPath))));

BpodSystem.Data.Custom = orderfields(BpodSystem.Data.Custom);

%% Set up PulsePal
load PulsePalParamStimulus.mat
load PulsePalParamFeedback.mat
BpodSystem.Data.Custom.PulsePalParamStimulus=PulsePalParamStimulus;
BpodSystem.Data.Custom.PulsePalParamFeedback=PulsePalParamFeedback;
clear PulsePalParamFeedback PulsePalParamStimulus
BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler';
if ~BpodSystem.EmulatorMode
    ProgramPulsePal(BpodSystem.Data.Custom.PulsePalParamStimulus);
    SendCustomPulseTrain(1, BpodSystem.Data.Custom.RightClickTrain{1}, ones(1,length(BpodSystem.Data.Custom.RightClickTrain{1}))*5);
    SendCustomPulseTrain(2, BpodSystem.Data.Custom.LeftClickTrain{1}, ones(1,length(BpodSystem.Data.Custom.LeftClickTrain{1}))*5);
end

%% Initialize plots
temp = SessionSummary();
for i = fieldnames(temp)'
    BpodSystem.GUIHandles.(i{1}) = temp.(i{1});
end
clear temp
BpodNotebook('init');

%% Main loop
RunSession = true;
iTrial = 1;

while RunSession
    TaskParameters = BpodParameterGUI('sync', TaskParameters);

    sma = stateMatrix();
    SendStateMatrix(sma);
    RawEvents = RunStateMatrix;
    if ~isempty(fieldnames(RawEvents))
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents);
        SaveBpodSessionData;
    end
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    if BpodSystem.BeingUsed == 0
        return
    end

    updateCustomDataFields(iTrial)
    iTrial = iTrial + 1;
    BpodSystem.GUIHandles = SessionSummary(BpodSystem.Data, BpodSystem.GUIHandles, iTrial);
end
end
