% MMF1921H - CVaR Optimization Example
% 
% Course Instructor: Prof. Roy H. Kwon
%
% Prepared by:  David Islip
% Email:        ryan.islip@mail.utoronto.ca
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Clear the memory and console
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
clc
format short

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. DEFINE PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% Load the historical weekly price data for 50 assets (210 observations)
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
%returns = array2table(returns);
%returns.Properties.VariableNames = tickers;
%returns.Properties.RowNames = cellstr(datetime(factorRet.Properties.RowNames));

% Align the price table to the asset and factor returns tables by
% discarding the first observation.
adjClose = adjClose(2:end,:);


% Compute the returns
rets = returns;
%rets = ( prices(2:end,:) ./ prices(1:end-1,:) ) - 1;
% rets2 = ( prices(2:end,:) - prices(1:end-1,:) ) ./ prices(1:end-1,:);
%rets2 = ( prices(2:end,:) - prices(1:end-1,:) ) ./ prices(1:end-1,:);
%rets2 = rets2 - ( diag( table2array(riskFree) ) * ones( size(rets2) ) );
%rets2 = array2table(rets2);
%size(rets2)
size(rets)

% Define the confidence level
alpha = 0.90;

% Estimate the geometric mean (for our target return)
mu = ( geomean(rets + 1) - 1 )';

% Set our target return (as an example, set it as 10% higher than the
% average asset return)
R = 1.1 * mean( mu );

% Determine the number of assets and scenarios
[S, n] = size( rets );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2. Construct the appropriate matrices for optimization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% We can model CVaR Optimization as a Linear Program. 
% 
%   min     gamma + (1 / [(1 - alpha) * S]) * sum( z_s )
%   s.t.    z_s   >= 0,                 for s = 1, ..., S
%           z_s   >= -r_s' x - gamma,   for s = 1, ..., S  
%           1' x  =  1,
%           mu' x >= R
% 
% We will use MATLAB's 'linprog' in this example. In this section of the
% code we will construct our inequality constraint matrix 'A' and 'b' for
% 
% A x <= b
% 
% This means we need to rearrange our constraint to have all the variables 
% on the LHS of the inequality.
% 
% This problem has N = n + S + 1 variables, as well as 2*S + 1 inequality
% constraints (the first S inequality constraints can be included as part 
% of 'lb' within 'linprog'). We have only one equality constraint. 
% 
% We have 209 weekly scenarios, and 50 assets. Therefore, N = 260

% Define the lower and upper bounds to our portfolio
lb = [-inf(n,1); zeros(S,1); -inf ];
ub = [];

% Define the inequality constraint matrices A and b
A = [ -rets -eye(S) -ones(S,1); -mu' zeros(1,S) 0 ];
b = [ zeros(S, 1); -R ];

% Define the equality constraint matrices A_eq and b_eq
Aeq = [ ones(1,n) zeros(1,S) 0 ];
beq = 1;

% Define our objective linear cost function c
k = (1 / ( (1 - alpha) * S) );
c = [ zeros(n,1); k * ones(S,1); 1 ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3. Find the optimal portfolio
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set the linprog options to increase the solver tolerance
options = optimoptions('linprog','TolFun',1e-9);

% Use 'linprog' to find the optimal portfolio
y = linprog( c, A, b, Aeq, beq, lb, ub, [], options );

% Retrieve the optimal portfolio weights
x = y(1:n);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 4. Plot the results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calculate the historical loss distribution for the optimal portfolio
optLoss = -rets * x;

% Calculate the historical loss distribution for the equally-weighted 
% portfolio (for comparison)
EWLoss = -rets * ones(n,1) / n;

fig1 = figure(1);
ax1  = subplot(2,1,1);
histogram(optLoss, 50);
xlabel('Portfolio losses ($\%$)','interpreter', 'latex','FontSize',14);
ylabel('Frequency','interpreter','latex','FontSize',14); 
title('Optimal portfolio','interpreter', 'latex','FontSize',16);

ax2  = subplot(2,1,2);
histogram(EWLoss, 50);
xlabel('Portfolio losses ($\%$)','interpreter', 'latex','FontSize',14);
ylabel('Frequency','interpreter','latex','FontSize',14); 
title('Equally-weighted portfolio','interpreter', 'latex','FontSize',16);

set(fig1,'Units','Inches', 'Position', [0 0 10, 8]);
pos2 = get(fig1,'Position');
set(fig1,'PaperPositionMode','Auto','PaperUnits','Inches',...
'PaperSize',[pos2(3), pos2(4)])


