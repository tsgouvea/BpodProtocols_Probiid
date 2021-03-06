function GUIHandles = SessionSummary(Data, GUIHandles, iTrial, nTrialsToShow)

%global nTrialsToShow %this is for convenience
%global BpodSystem
global TaskParameters
if nargin < 4 %custom number of trials to display
    nTrialsToShow = 90; %default
end

if nargin < 2 % plot initialized (either beginning of session or post-hoc analysis)
    if nargin > 0 % post-hoc analysis
        TaskParameters.GUI = Data.Settings.GUI;
    end

    GUIHandles = struct();
    GUIHandles.Figs.MainFig = figure('Position', [200, 200, 1000, 400],'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
    GUIHandles.Axes.OutcomePlot.MainHandle = axes('Position', [.06 .15 .91 .3]);
    GUIHandles.Axes.TrialRate.MainHandle = axes('Position', [[1 0]*[.06;.12] .6 .12 .3]);
    GUIHandles.Axes.CenterDelay.MainHandle = axes('Position', [[2 1]*[.06;.12] .6 .12 .3]);
    GUIHandles.Axes.FictDelay.MainHandle = axes('Position', [[3 2]*[.06;.12] .6 .12 .3]);
    GUIHandles.Axes.ChoiceKernel.MainHandle = axes('Position', [[4 3]*[.06;.12] .6 .12 .3]);
    GUIHandles.Axes.Wager.MainHandle = axes('Position', [[5 4]*[.06;.12] .6 .12 .3]);

    %% Outcome
    axes(GUIHandles.Axes.OutcomePlot.MainHandle)
    GUIHandles.Axes.OutcomePlot.Bait = line(-1,1, 'LineStyle','none','Marker','o','MarkerEdge','g','MarkerFace','none', 'MarkerSize',8);
    GUIHandles.Axes.OutcomePlot.CurrentTrialCircle = line(-1,0.5, 'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace',[1 1 1], 'MarkerSize',6);
    GUIHandles.Axes.OutcomePlot.CurrentTrialCross = line(-1,0.5, 'LineStyle','none','Marker','+','MarkerEdge','k','MarkerFace',[1 1 1], 'MarkerSize',6);
    GUIHandles.Axes.OutcomePlot.Rewarded = line(-1,1, 'LineStyle','none','Marker','o','MarkerEdge','g','MarkerFace','g', 'MarkerSize',6);
    GUIHandles.Axes.OutcomePlot.Unrewarded = line(-1,1, 'LineStyle','none','Marker','o','MarkerEdge','r','MarkerFace','r', 'MarkerSize',6);
    GUIHandles.Axes.OutcomePlot.NoResponse = line(-1,1, 'LineStyle','none','Marker','o','MarkerEdge','b','MarkerFace','none', 'MarkerSize',6);
    GUIHandles.Axes.OutcomePlot.EarlyCout = line(-1,0, 'LineStyle','none','Marker','d','MarkerEdge','none','MarkerFace','b', 'MarkerSize',6);
    GUIHandles.Axes.OutcomePlot.EarlySout = line(-1,0, 'LineStyle','none','Marker','d','MarkerEdge','none','MarkerFace','b', 'MarkerSize',6);
    GUIHandles.Axes.OutcomePlot.CumRwd = text(1,1,'0mL','verticalalignment','bottom','horizontalalignment','center');
    set(GUIHandles.Axes.OutcomePlot.MainHandle,'TickDir', 'out','YLim', [-1, 2],'XLim',[0,nTrialsToShow], 'YTick', [0 1],'YTickLabel', {'Right','Left'}, 'FontSize', 16);
    xlabel(GUIHandles.Axes.OutcomePlot.MainHandle, 'Trial#', 'FontSize', 18);
    hold(GUIHandles.Axes.OutcomePlot.MainHandle, 'on');
    %% Trial rate
    hold(GUIHandles.Axes.TrialRate.MainHandle,'on')
    GUIHandles.Axes.TrialRate.TrialRate = line(GUIHandles.Axes.TrialRate.MainHandle,[0 1],[0 1], 'LineStyle','-','Color','k','Visible','on','linewidth',3);
    GUIHandles.Axes.TrialRate.TrialRateL = line(GUIHandles.Axes.TrialRate.MainHandle,[0 1],[0 1], 'LineStyle','-','Color',[254,178,76]/255,'Visible','on','linewidth',3);
    GUIHandles.Axes.TrialRate.TrialRateR = line(GUIHandles.Axes.TrialRate.MainHandle,[0 1],[0 1], 'LineStyle','-','Color',[49,163,84]/255,'Visible','on','linewidth',3);
    GUIHandles.Axes.TrialRate.MainHandle.XLabel.String = 'Time (min)';
    GUIHandles.Axes.TrialRate.MainHandle.YLabel.String = 'nTrials';
    GUIHandles.Axes.TrialRate.MainHandle.Title.String = 'Trial rate';
    %% ST histogram
    hold(GUIHandles.Axes.CenterDelay.MainHandle,'on')
    GUIHandles.Axes.CenterDelay.MainHandle.XLabel.String = 'Time (s)';
    GUIHandles.Axes.CenterDelay.MainHandle.YLabel.String = 'trial counts';
    GUIHandles.Axes.CenterDelay.MainHandle.Title.String = 'Center port WT';
    %% FT histogram
    hold(GUIHandles.Axes.FictDelay.MainHandle,'on')
    GUIHandles.Axes.FictDelay.MainHandle.XLabel.String = 'Time (s)';
    GUIHandles.Axes.FictDelay.MainHandle.YLabel.String = 'trial counts';
    GUIHandles.Axes.FictDelay.MainHandle.Title.String = 'Side port WT';
    %% Choice Kernel
    colors = lines(5);
    hold(GUIHandles.Axes.ChoiceKernel.MainHandle,'on')
    GUIHandles.Axes.ChoiceKernel.Fic = line(GUIHandles.Axes.ChoiceKernel.MainHandle,[1:TaskParameters.GUI.nTrialsBack],zeros(TaskParameters.GUI.nTrialsBack,1),'marker','s','linestyle','none','MarkerEdgeColor',colors(5,:),'Visible','on');
    GUIHandles.Axes.ChoiceKernel.Rwd = line(GUIHandles.Axes.ChoiceKernel.MainHandle,[1:TaskParameters.GUI.nTrialsBack],zeros(TaskParameters.GUI.nTrialsBack,1),'marker','p','linestyle','none','MarkerEdgeColor',colors(1,:),'Visible','on');
    GUIHandles.Axes.ChoiceKernel.Cho = line(GUIHandles.Axes.ChoiceKernel.MainHandle,[1:TaskParameters.GUI.nTrialsBack],zeros(TaskParameters.GUI.nTrialsBack,1),'marker','o','linestyle','none','MarkerEdgeColor',colors(3,:),'Visible','on');
    GUIHandles.Axes.ChoiceKernel.Bias = line(GUIHandles.Axes.ChoiceKernel.MainHandle,[1,TaskParameters.GUI.nTrialsBack],[0,0],'Color',ones(1,3)*.7,'Visible','on');
    GUIHandles.Axes.ChoiceKernel.MainHandle.XLabel.String = 'Trials back';
    GUIHandles.Axes.ChoiceKernel.MainHandle.YLabel.String = 'GLM coefficient';
    GUIHandles.Axes.ChoiceKernel.MainHandle.Title.String = 'Choice kernel';
    %% Time Wagering
    hold(GUIHandles.Axes.Wager.MainHandle,'on')
    %colors from [http://paletton.com/#uid=3000u0kllllaFw0g0qFqFg0w0aF]
    GUIHandles.Axes.Wager.ExploitScatter = line(GUIHandles.Axes.Wager.MainHandle,[1,5],[0,0],'marker','o','linestyle','none','MarkerEdgeColor',[40, 60, 60]/100,'Visible','on');
    GUIHandles.Axes.Wager.ExploreScatter = line(GUIHandles.Axes.Wager.MainHandle,[1,5],[0,0],'marker','o','linestyle','none','MarkerEdgeColor',[83.1, 41.6, 41.6]/100,'Visible','on');
    GUIHandles.Axes.Wager.ExploitLine = line(GUIHandles.Axes.Wager.MainHandle,[1,5],[0,0],'Color',[13.3, 40, 40]/100,'Visible','on','linewidth',2);
    GUIHandles.Axes.Wager.ExploreLine = line(GUIHandles.Axes.Wager.MainHandle,[1,5],[0,0],'Color',[50.2, 8.2, 8.2]/100,'Visible','on','linewidth',2);
    GUIHandles.Axes.Wager.MainHandle.XLabel.String = 'log(pL/pR)';
    GUIHandles.Axes.Wager.MainHandle.YLabel.String = 'Waiting time (s)';
    GUIHandles.Axes.Wager.MainHandle.Title.String = 'Vevaiometric?';
else
    global TaskParameters
end

if nargin > 0
    if nargin < 3
        iTrial = Data.nTrials;
    end
    % Outcome
    [mn, ~] = rescaleX(GUIHandles.Axes.OutcomePlot.MainHandle,iTrial,nTrialsToShow); % recompute xlim

    set(GUIHandles.Axes.OutcomePlot.CurrentTrialCircle, 'xdata', iTrial, 'ydata', 0.5);
    set(GUIHandles.Axes.OutcomePlot.CurrentTrialCross, 'xdata', iTrial, 'ydata', 0.5);

    %Plot past trials
    ChoiceLeft = Data.Custom.ChoiceLeft;
    Rewarded = Data.Custom.Rewarded;
    if ~isempty(Rewarded)
        indxToPlot = mn:iTrial-1;

        ndxRwd = Rewarded(indxToPlot) == 1;
        Xdata = indxToPlot(ndxRwd);
        Ydata = ChoiceLeft(indxToPlot); Ydata = Ydata(ndxRwd);
        set(GUIHandles.Axes.OutcomePlot.Rewarded, 'xdata', Xdata, 'ydata', Ydata);

        ndxUrwd = Rewarded(indxToPlot) == 0 & not(Data.Custom.EarlyCout(indxToPlot)|Data.Custom.EarlySout(indxToPlot));
        Xdata = indxToPlot(ndxUrwd);
        Ydata = ChoiceLeft(indxToPlot); Ydata = Ydata(ndxUrwd);
        set(GUIHandles.Axes.OutcomePlot.Unrewarded, 'xdata', Xdata, 'ydata', Ydata);

        ndxNocho = isnan(ChoiceLeft(indxToPlot)) & ~Data.Custom.EarlyCout(indxToPlot);
        Xdata = indxToPlot(ndxNocho);
        Ydata = ones(size(Xdata))*.5;
        set(GUIHandles.Axes.OutcomePlot.NoResponse, 'xdata', Xdata, 'ydata', Ydata);

        Ydata = [ones(sum(Data.Custom.Baited.Left(indxToPlot)),1)', zeros(sum(Data.Custom.Baited.Right(indxToPlot)),1)'];
        Xdata = [indxToPlot(Data.Custom.Baited.Left(indxToPlot)), indxToPlot(Data.Custom.Baited.Right(indxToPlot))];
        set(GUIHandles.Axes.OutcomePlot.Bait, 'xdata', Xdata, 'ydata', Ydata);
    end
    if ~isempty(Data.Custom.EarlyCout)
        indxToPlot = mn:iTrial-1;
        ndxEarly = Data.Custom.EarlyCout(indxToPlot);
        XData = indxToPlot(ndxEarly);
        YData = 0.5*ones(1,sum(ndxEarly));
        set(GUIHandles.Axes.OutcomePlot.EarlyCout, 'xdata', XData, 'ydata', YData);
    end
    if ~isempty(Data.Custom.EarlySout)
        indxToPlot = mn:iTrial-1;
        ndxEarly = Data.Custom.EarlySout(indxToPlot);
        XData = indxToPlot(ndxEarly);
        YData = ChoiceLeft(indxToPlot); YData = YData(ndxEarly);
        set(GUIHandles.Axes.OutcomePlot.EarlySout, 'xdata', XData, 'ydata', YData);
    end
    %Cumulative Reward Amount
    R = Data.Custom.RewardMagnitude;
    ndxRwd = Data.Custom.Rewarded;
    C = zeros(size(R)); C(Data.Custom.ChoiceLeft==1&ndxRwd,1) = 1; C(Data.Custom.ChoiceLeft==0&ndxRwd,2) = 1;
    R = R.*C;
    set(GUIHandles.Axes.OutcomePlot.CumRwd, 'position', [iTrial+1 1], 'string', ...
        [num2str(sum(R(:))/1000) ' mL']);
    clear R C

    %% Trial rate
    GUIHandles.Axes.TrialRate.TrialRate.XData = (Data.TrialStartTimestamp-min(Data.TrialStartTimestamp))/60;
    GUIHandles.Axes.TrialRate.TrialRate.YData = 1:numel(GUIHandles.Axes.TrialRate.TrialRate.XData);
    ndxCho = Data.Custom.ChoiceLeft(:)==1;
    GUIHandles.Axes.TrialRate.TrialRateL.XData = (Data.TrialStartTimestamp(ndxCho)-min(Data.TrialStartTimestamp))/60;
    GUIHandles.Axes.TrialRate.TrialRateL.YData = 1:numel(GUIHandles.Axes.TrialRate.TrialRateL.XData);
    ndxCho = Data.Custom.ChoiceLeft(:)==0;
    GUIHandles.Axes.TrialRate.TrialRateR.XData = (Data.TrialStartTimestamp(ndxCho)-min(Data.TrialStartTimestamp))/60;
    GUIHandles.Axes.TrialRate.TrialRateR.YData = 1:numel(GUIHandles.Axes.TrialRate.TrialRateR.XData);
    %% Stimulus delay
    cla(GUIHandles.Axes.CenterDelay.MainHandle)
    GUIHandles.Axes.CenterDelay.Hist = histogram(GUIHandles.Axes.CenterDelay.MainHandle,...
        Data.Custom.CenterDelay(~Data.Custom.EarlyCout)*1000);
    GUIHandles.Axes.CenterDelay.Hist.BinWidth = 50;
    GUIHandles.Axes.CenterDelay.Hist.EdgeColor = 'none';
    GUIHandles.Axes.CenterDelay.HistEarly = histogram(GUIHandles.Axes.CenterDelay.MainHandle,...
        Data.Custom.CenterDelay(Data.Custom.EarlyCout)*1000);
    GUIHandles.Axes.CenterDelay.HistEarly.BinWidth = 50;
    GUIHandles.Axes.CenterDelay.HistEarly.EdgeColor = 'none';
    GUIHandles.Axes.CenterDelay.CutOff = plot(GUIHandles.Axes.CenterDelay.MainHandle,TaskParameters.GUI.CenterDelay*1000,0,'^k');

    %% Feedback delay
    cla(GUIHandles.Axes.FictDelay.MainHandle)
    if isfield(TaskParameters,'GUIMeta') && strcmp(TaskParameters.GUIMeta.FictDelaySelection.String{TaskParameters.GUI.FictDelaySelection},'TruncExp')
        GUIHandles.Axes.FictDelay.Hist = histogram(GUIHandles.Axes.FictDelay.MainHandle,Data.Custom.FictDelay(Data.Custom.Rewarded)*1000);
        %GUIHandles.Axes.FictDelay.Hist.BinWidth = 50;
        GUIHandles.Axes.FictDelay.Hist.EdgeColor = 'none';
        GUIHandles.Axes.FictDelay.HistEarly = histogram(GUIHandles.Axes.FictDelay.MainHandle,Data.Custom.FictDelay(~Data.Custom.Rewarded)*1000);
        %GUIHandles.Axes.FictDelay.HistEarly.BinWidth = 50;
        GUIHandles.Axes.FictDelay.HistEarly.EdgeColor = 'none';
        GUIHandles.Axes.FictDelay.CutOff = plot(GUIHandles.Axes.FictDelay.MainHandle,TaskParameters.GUI.FictDelay*1000,0,'^k');
        GUIHandles.Axes.FictDelay.Expected = plot(GUIHandles.Axes.FictDelay.MainHandle,...
            min(Data.Custom.FictDelay)*1000:max(Data.Custom.FictDelay)*1000,...
            (GUIHandles.Axes.FictDelay.Hist.BinWidth * iTrial) * exppdf(min(Data.Custom.FictDelay)*1000:max(Data.Custom.FictDelay)*1000,TaskParameters.GUI.FictDelayTau*1000),'c');
    else
        GUIHandles.Axes.FictDelay.Hist = histogram(GUIHandles.Axes.FictDelay.MainHandle,Data.Custom.FictDelay(~Data.Custom.EarlySout)*1000);
        GUIHandles.Axes.FictDelay.Hist.BinWidth = 50;
        GUIHandles.Axes.FictDelay.Hist.EdgeColor = 'none';
        GUIHandles.Axes.FictDelay.HistEarly = histogram(GUIHandles.Axes.FictDelay.MainHandle,...
            Data.Custom.FictDelay(Data.Custom.EarlySout)*1000);
        GUIHandles.Axes.FictDelay.HistEarly.BinWidth = 50;
        GUIHandles.Axes.FictDelay.HistEarly.EdgeColor = 'none';
        GUIHandles.Axes.FictDelay.CutOff = plot(GUIHandles.Axes.FictDelay.MainHandle,TaskParameters.GUI.FictDelay*1000,0,'^k');
    end

    %% Choice Kernel
    % log(\frac{P(L|t)}{P(R|t)}) = Sum((R[t-k]*exp(-k*Beta_r))(k,0,n))+Sum((C[t-l]*exp(-l*Beta_c))(l,0,n))
    if sum(~isnan(Data.Custom.ChoiceLeft)) < 20
        GUIHandles.Axes.ChoiceKernel.MainHandle.Visible = 'off';
    elseif rem(sum(~isnan(Data.Custom.ChoiceLeft)),20)==0 || nargin == 1 % every 20 trials OR when called offline
        try
            GUIHandles.Axes.ChoiceKernel.MainHandle.Visible = 'on';
            [GUIHandles.Axes.ChoiceKernel.Mdl, logodds, ~]  = LauGlim( Data, TaskParameters.GUI.nTrialsBack );
            GUIHandles.Axes.ChoiceKernel.Bias.XData = [1,TaskParameters.GUI.nTrialsBack];
            GUIHandles.Axes.ChoiceKernel.Bias.YData = GUIHandles.Axes.ChoiceKernel.Mdl.Coefficients.Estimate(1)*[1,1];
            GUIHandles.Axes.ChoiceKernel.Cho.XData = 1:TaskParameters.GUI.nTrialsBack;
            GUIHandles.Axes.ChoiceKernel.Cho.YData  = GUIHandles.Axes.ChoiceKernel.Mdl.Coefficients.Estimate(2:TaskParameters.GUI.nTrialsBack+1);
            GUIHandles.Axes.ChoiceKernel.Rwd.XData = 1:TaskParameters.GUI.nTrialsBack;
            GUIHandles.Axes.ChoiceKernel.Rwd.YData  = GUIHandles.Axes.ChoiceKernel.Mdl.Coefficients.Estimate(TaskParameters.GUI.nTrialsBack+2:2*TaskParameters.GUI.nTrialsBack+1);
            GUIHandles.Axes.ChoiceKernel.Fic.XData = 1:TaskParameters.GUI.nTrialsBack;
            GUIHandles.Axes.ChoiceKernel.Fic.YData  = GUIHandles.Axes.ChoiceKernel.Mdl.Coefficients.Estimate(2*TaskParameters.GUI.nTrialsBack+2:3*TaskParameters.GUI.nTrialsBack+1);

            %% Time Wagering
            hold(GUIHandles.Axes.Wager.MainHandle,'on')
            GUIHandles.Axes.Wager.ExploreScatter.Visible = 'on';
            GUIHandles.Axes.Wager.ExploreLine.Visible = 'on';
            ndxBaited = (Data.Custom.Baited.Left & Data.Custom.ChoiceLeft==1) | (Data.Custom.Baited.Right & Data.Custom.ChoiceLeft==0);
            ndxBaited = ndxBaited(:);
            ndxValid = Data.Custom.EarlyCout==0 & ~isnan(Data.Custom.ChoiceLeft); ndxValid = ndxValid(:);
            ndxExploit = Data.Custom.ChoiceLeft(:) == (logodds>0);
            GUIHandles.Axes.Wager.ExploreScatter.XData = logodds(ndxValid & ~ndxBaited & ~ndxExploit);
            GUIHandles.Axes.Wager.ExploreScatter.YData = Data.Custom.FictDelay(ndxValid & ~ndxBaited & ~ndxExploit);
            GUIHandles.Axes.Wager.ExploitScatter.XData = logodds(ndxValid & ~ndxBaited & ndxExploit);
            GUIHandles.Axes.Wager.ExploitScatter.YData = Data.Custom.FictDelay(ndxValid & ~ndxBaited & ndxExploit);
            [GUIHandles.Axes.Wager.ExploreLine.XData, GUIHandles.Axes.Wager.ExploreLine.YData] = binvevaio(GUIHandles.Axes.Wager.ExploreScatter.XData,GUIHandles.Axes.Wager.ExploreScatter.YData);
            [GUIHandles.Axes.Wager.ExploitLine.XData, GUIHandles.Axes.Wager.ExploitLine.YData] = binvevaio(GUIHandles.Axes.Wager.ExploitScatter.XData,GUIHandles.Axes.Wager.ExploitScatter.YData);
            GUIHandles.Axes.Wager.MainHandle.XLim = 1.1*[min(GUIHandles.Axes.Wager.ExploitScatter.XData) max(GUIHandles.Axes.Wager.ExploitScatter.XData)];
        end
    end
end
end

function [mn,mx] = rescaleX(AxesHandle,CurrentTrial,nTrialsToShow)
FractionWindowStickpoint = .75; % After this fraction of visible trials, the trial position in the window "sticks" and the window begins to slide through trials.
mn = max(round(CurrentTrial - FractionWindowStickpoint*nTrialsToShow),1);
mx = mn + nTrialsToShow - 1;
set(AxesHandle,'XLim',[mn-1 mx+1]);
end
