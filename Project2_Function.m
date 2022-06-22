function x = Project2_Function(periodReturns, periodFactRet, x0)

    % Use this function to implement your algorithmic asset management
    % strategy. You can modify this function, but you must keep the inputs
    % and outputs consistent.
    %
    % INPUTS: periodReturns, periodFactRet, x0 (current portfolio weights)
    % OUTPUTS: x (optimal portfolio)
    %
    % An example of an MVO implementation with OLS regression is given
    % below. Please be sure to include comments in your code.
    %
    % *************** WRITE YOUR CODE HERE ***************
    %----------------------------------------------------------------------

    % Example: subset the data to consistently use the most recent 3 years
    % for parameter estimation
    returns = periodReturns(end-35:end,:);
    factRet = periodFactRet(end-35:end,:);
    
    % second set of returns all period
    %returns = periodReturns;
    %factRet = periodFactRet;
    
    % Example: Use an OLS regression to estimate mu and Q
    %[mu, Q] = OLS(returns, factRet);
    lambda = 0.01;
    K = 5;
    
    % FF
    %[mu, Q] = FF(returns, factRet, lambda, K);

    %[mu,Q] = LASSO(returns, factRet, lambda, K);  
    
    [mu,Q] = BSS(returns, factRet, lambda, K);
    
    % Example: Use MVO to optimize our portfolio
    x = MVO(mu, Q);

    % Risk aversion coefficient
    %lambda = 0.02;

    % Confidence level
    %alpha = 0.9;

    % Number of return observations 
    T = size(returns,1);

    %robust Risk aversion
    robustlambda = 0.01; %best
    %robust confidence level
    robustalpha = 0.90; %best
 
    %x = robustMVO(mu, Q, robustlambda, robustalpha, T,x0);
    
    CVaRalpha = 0.96; %optimal
    %x = Cvar(mu, returns, CVaRalpha);
    
    %Risk Parity
    RPkappa = 8;% best
    %x = RP(mu, Q, RPkappa,x0);

    %----------------------------------------------------------------------
end
