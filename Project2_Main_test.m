%% MMF1921 (Winter 2022) - Project 2
% 
% The purpose of this program is to provide a template with which to
% develop Project 2. The project requires you to test different models 
% (and/or different model combinations) to create an asset management
% algorithm. 

% This template will be used by the instructor and TA to assess your  
% trading algorithm using different datasets.

% PLEASE DO NOT MODIFY THIS TEMPLATE

clc
clear all
format short

% Program Start
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. Read input files 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Input file names
assetData  = 'MMF1921_AssetPrices_1.csv';
factorData = 'MMF1921_FactorReturns_1.csv';

% Initial budget to invest ($100,000)
initialVal = 100000;

% Length of investment period (in months)
investPeriod = 6;

% Load the stock weekly prices
adjClose = readtable(assetData);
adjClose.Properties.RowNames = cellstr(datetime(adjClose.Date));
adjClose.Properties.RowNames = cellstr(datetime(adjClose.Properties.RowNames));
adjClose.Date = [];

% Load the factors weekly returns
factorRet = readtable(factorData);
factorRet.Properties.RowNames = cellstr(datetime(factorRet.Date));
factorRet.Properties.RowNames = cellstr(datetime(factorRet.Properties.RowNames));
factorRet.Date = [];

riskFree = factorRet(:,9);
factorRet = factorRet(:,1:8);

% Identify the tickers and the dates 
tickers = adjClose.Properties.VariableNames';
dates   = datetime(factorRet.Properties.RowNames);

% Calculate the stocks' weekly EXCESS returns
prices  = table2array(adjClose);
returns = ( prices(2:end,:) - prices(1:end-1,:) ) ./ prices(1:end-1,:);
returns = returns - ( diag( table2array(riskFree) ) * ones( size(returns) ) );
returns = array2table(returns);
returns.Properties.VariableNames = tickers;
returns.Properties.RowNames = cellstr(datetime(factorRet.Properties.RowNames));

% Align the price table to the asset and factor returns tables by
% discarding the first observation.
adjClose = adjClose(2:end,:);

% Start of out-of-sample test period 
testStart = datetime(returns.Properties.RowNames{1}) + calyears(5);

% End of the first investment period
testEnd = testStart + calmonths(investPeriod) - days(1);

% End of calibration period (note that the start date is the first
% observation in the dataset)
calEnd = testStart - days(1);

% Total number of investment periods
NoPeriods = ceil( days(datetime(returns.Properties.RowNames{end}) - testStart) / (30.44*investPeriod) );

% Number of assets      
n = size(adjClose,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2. Run your program
% 
% This section will run your Project1_Function in a loop. The data will be
% loaded progressively as a growing window of historical observations.
% Rebalancing will take place after every loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Preallocate space for the portfolio weights (x0 will be used to calculate
% the turnover rate)
count = 0;
% setting metrics key space
%metricsArray = linspace(0,0.1,11);
metricsArray = linspace(0.9,0.99,10);
%metricsArray = linspace(1,10,10);
% calling which function
%Project2_Function = @Project2_FunctionRobustMVO;
%Project2_Function = @Project2_FunctionRP;
Project2_Function = @Project2_FunctionCvar;
%Project2_Function = @Project2_FunctionOriginMVO;

for metricsKey = metricsArray
    [portfValue,turnover,elapsetime] = Project2_Run(n, NoPeriods,returns,dates,calEnd,factorRet,...
adjClose,testStart,testEnd,initialVal,investPeriod, metricsKey,Project2_Function);
    count = count + 1;
    portfValueArray(:,count) = portfValue;
    %turnoverArray(:,count) = turnover;
    timeArray(:,count) = elapsetime;
    % Calculate the observed portfolio returns
    portfRets = portfValue(2:end) ./ portfValue(1:end-1) - 1;

    % Calculate the portfolio excess returns
    portfExRets = portfRets - table2array(riskFree(dates >= datetime(returns.Properties.RowNames{1}) + calyears(5) + calmonths(1),: ));

    % Calculate the portfolio Sharpe ratio 
    SR = (geomean(portfExRets + 1) - 1) / std(portfExRets);
    SRArray(:,count) = SR;
    % Calculate the average turnover rate
    avgTurnover = mean(turnover(2:end));
    avgTurnoverArray(:,count) = avgTurnover;
    % Print Sharpe ratio and Avg. turnover to the console
    disp(['Elapsed time is: ',num2str(elapsetime)]);
    disp(['Sharpe ratio: ', num2str(SR)]);
    disp(['Avg. turnover: ', num2str(avgTurnover)]);
    
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3. Results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------------
% 3.1 Calculate the portfolio average return, standard deviation, Sharpe
% ratio and average turnover.
%--------------------------------------------------------------------------
% ii = 1;
% while ii <= count
%     portfValue = portfValueArray(:,ii);
%     turnover = turnoverArray(:,ii);
%     elapsetime = timeArray(:,ii);
%     [SR,avgTurnover] = Project2_result(portfValue,turnover,...
%     elapsetime,riskFree,dates,returns);
%     ii = ii + 1;
% end

%% plot SR
% Calculate the dates of the out-of-sample period
plotDates = dates(dates >= datetime(returns.Properties.RowNames{1}) + calyears(5) );
%metricsArray = linspace(0,0.1,11);
fig3 = figure(3);

plot(metricsArray, SRArray)

%datetick('x','dd-mmm-yyyy','keepticks','keeplimits');
%set(gca,'XTickLabelRotation',30);

title('SR Vs alpha', 'FontSize', 14)
xlabel('alpha','interpreter','latex','FontSize',12 )
ylabel('Sharpe Ratio','interpreter','latex','FontSize',12);

% Define the plot size in inches
%set(fig3,'Units','Inches', 'Position', [0 0 8, 5]);
%pos1 = get(fig3,'Position');
%set(fig3,'PaperPositionMode','Auto','PaperUnits','Inches',...
%    'PaperSize',[pos1(3), pos1(4)]);

% If you want to save the figure as .pdf for use in LaTeX
% print(fig1,'fileName','-dpdf','-r0');

% If you want to save the figure as .png for use in MS Word
print(fig3,'SR','-dpng','-r0');


%% plot avgTurnOver

% Calculate the dates of the out-of-sample period
%plotDates = dates(dates >= datetime(returns.Properties.RowNames{1}) + calyears(5) );
%metricsArray = linspace(0,0.1,11);
fig4 = figure(4);

plot(metricsArray,avgTurnoverArray)

%datetick('x','dd-mmm-yyyy','keepticks','keeplimits');
%set(gca,'XTickLabelRotation',30);
title('Avg Turnover Vs alpha', 'FontSize', 14)
xlabel('alpha','interpreter','latex','FontSize',12 )
ylabel('Avg Turnover','interpreter','latex','FontSize',12);

% Define the plot size in inches
set(fig4,'Units','Inches', 'Position', [0 0 8, 5]);
pos1 = get(fig4,'Position');
set(fig4,'PaperPositionMode','Auto','PaperUnits','Inches',...
    'PaperSize',[pos1(3), pos1(4)]);

% If you want to save the figure as .pdf for use in LaTeX
% print(fig1,'fileName','-dpdf','-r0');

% If you want to save the figure as .png for use in MS Word
print(fig4,'Avg Turnover','-dpng','-r0');

%% plot Score

% Calculate the dates of the out-of-sample period
%plotDates = dates(dates >= datetime(returns.Properties.RowNames{1}) + calyears(5) );
%metricsArray = linspace(0,0.1,11);
fig5 = figure(5);

score = (0.8 * SRArray + 0.2 * avgTurnoverArray)*100;
plot(metricsArray, score)

%datetick('x','dd-mmm-yyyy','keepticks','keeplimits');
%set(gca,'XTickLabelRotation',30);
title('Score Vs alpha', 'FontSize', 14)
xlabel('alpha','interpreter','latex','FontSize',12 )
ylabel('Score','interpreter','latex','FontSize',12);

% Define the plot size in inches
set(fig5,'Units','Inches', 'Position', [0 0 8, 5]);
pos1 = get(fig5,'Position');
set(fig5,'PaperPositionMode','Auto','PaperUnits','Inches',...
    'PaperSize',[pos1(3), pos1(4)]);

% If you want to save the figure as .pdf for use in LaTeX
% print(fig1,'fileName','-dpdf','-r0');

% If you want to save the figure as .png for use in MS Word
print(fig5,'Score','-dpng','-r0');

%--------------------------------------------------------------------------
% 3.2 Portfolio wealth evolution plot
%--------------------------------------------------------------------------
%%
% Calculate the dates of the out-of-sample period
plotDates = dates(dates >= datetime(returns.Properties.RowNames{1}) + calyears(5) );

fig1 = figure(1);
ii = 1;
while ii <= count
    portfValue = portfValueArray(:,ii);
    plot(plotDates, portfValue)
    ii = ii + 1;
    hold on
end

datetick('x','dd-mmm-yyyy','keepticks','keeplimits');
set(gca,'XTickLabelRotation',30);
title('Portfolio wealth evolution', 'FontSize', 14)
ylabel('Total wealth','interpreter','latex','FontSize',12);

% Define the plot size in inches
set(fig1,'Units','Inches', 'Position', [0 0 8, 5]);
pos1 = get(fig1,'Position');
set(fig1,'PaperPositionMode','Auto','PaperUnits','Inches',...
    'PaperSize',[pos1(3), pos1(4)]);

% If you want to save the figure as .pdf for use in LaTeX
% print(fig1,'fileName','-dpdf','-r0');

% If you want to save the figure as .png for use in MS Word
print(fig1,'fileName','-dpng','-r0');
%%
%--------------------------------------------------------------------------
% 3.3 Portfolio weights plot
%--------------------------------------------------------------------------

% Portfolio weights
fig2 = figure(2);
area(x')
legend(tickers, 'Location', 'eastoutside','FontSize',12);
title('Portfolio weights', 'FontSize', 14)
ylabel('Weights','interpreter','latex','FontSize',12);
xlabel('Rebalance period','interpreter','latex','FontSize',12);

% Define the plot size in inches
set(fig2,'Units','Inches', 'Position', [0 0 8, 5]);
pos1 = get(fig2,'Position');
set(fig2,'PaperPositionMode','Auto','PaperUnits','Inches',...
    'PaperSize',[pos1(3), pos1(4)]);

% If you want to save the figure as .pdf for use in LaTeX
% print(fig2,'fileName2','-dpdf','-r0');

% If you want to save the figure as .png for use in MS Word
print(fig2,'fileName2','-dpng','-r0');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Program End