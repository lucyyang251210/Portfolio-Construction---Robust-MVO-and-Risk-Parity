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
x  = zeros(n, NoPeriods);
x0 = zeros(n, NoPeriods);

% Preallocate space for the portfolio per period value and turnover
currentVal = zeros(NoPeriods, 1);
turnover   = zeros(NoPeriods, 1);

% Initiate counter for the number of observations per investment period
toDay = 0;

% Meaure runtime: start the clock
tic

for t = 1 : NoPeriods
  
    % Subset the returns and factor returns corresponding to the current
    % calibration period.
    periodReturns = table2array( returns( dates <= calEnd, :) );
    periodFactRet = table2array( factorRet( dates <= calEnd, :) );
    currentPrices = table2array( adjClose( ( calEnd - calmonths(1) - days(5) ) <= dates & dates <= calEnd, :) )';
    
    % Subset the prices corresponding to the current out-of-sample test 
    % period.
    periodPrices = table2array( adjClose( testStart <= dates & dates <= testEnd,:) );
    
    % Set the initial value of the portfolio or update the portfolio value
    if t == 1
        currentVal(t) = initialVal;
    else    
        currentVal(t) = currentPrices' * NoShares;
        
        % Store the current asset weights (before optimization takes place)
        x0(:,t) = (currentPrices .* NoShares) ./ currentVal(t);
    end
    
    %----------------------------------------------------------------------
    % Portfolio optimization
    % You must write code your own algorithmic trading function 
    %----------------------------------------------------------------------
    x(:,t) = Project2_Function(periodReturns, periodFactRet, x0(:,t));

    % Calculate the turnover rate 
    if t > 1
        turnover(t) = sum( abs( x(:,t) - x0(:,t) ) );
    end
        
    % Number of shares your portfolio holds per stock
    NoShares = x(:,t) .* currentVal(t) ./ currentPrices;
    
    % Update counter for the number of observations per investment period
    fromDay = toDay + 1;
    toDay   = toDay + size(periodPrices,1);

    % Weekly portfolio value during the out-of-sample window
    portfValue(fromDay:toDay) = periodPrices * NoShares;

    % Update your calibration and out-of-sample test periods
    testStart = testStart + calmonths(investPeriod);
    testEnd   = testStart + calmonths(investPeriod) - days(1);
    calEnd    = testStart - days(1);

end

% Transpose the portfValue into a column vector
portfValue = portfValue';

% Measure runtime: stop the clock
toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3. Results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------------
% 3.1 Calculate the portfolio average return, standard deviation, Sharpe
% ratio and average turnover.
%--------------------------------------------------------------------------

% Calculate the observed portfolio returns
portfRets = portfValue(2:end) ./ portfValue(1:end-1) - 1;

% Calculate the portfolio excess returns
portfExRets = portfRets - table2array(riskFree(dates >= datetime(returns.Properties.RowNames{1}) + calyears(5) + calmonths(1),: ));

% Calculate the portfolio Sharpe ratio 
SR = (geomean(portfExRets + 1) - 1) / std(portfExRets);

% Calculate the average turnover rate
avgTurnover = mean(turnover(2:end));

% Print Sharpe ratio and Avg. turnover to the console
disp(['Sharpe ratio: ', num2str(SR)]);
disp(['Avg. turnover: ', num2str(avgTurnover)]);

modelName = "BSS";
optName = "MVO";
save(modelName+optName+"portfValue", "portfValue")
save(modelName+optName+"weights", "x")
%%
%--------------------------------------------------------------------------
% 3.2 Portfolio wealth evolution plot
%--------------------------------------------------------------------------

% Calculate the dates of the out-of-sample period
plotDates = dates(dates >= datetime(returns.Properties.RowNames{1}) + calyears(5) );
%save("samplePeriod", 'plotDates');
%save("sampleticker", 'tickers');

fig1 = figure(1);
plot(plotDates, portfValue)

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
fileName1 = modelName + optName + "wealth";
print(fig1,fileName1,'-dpng','-r0');

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
fileName2 = modelName + optName + "weights";
% If you want to save the figure as .png for use in MS Word
print(fig2,fileName2,'-dpng','-r0');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Program End