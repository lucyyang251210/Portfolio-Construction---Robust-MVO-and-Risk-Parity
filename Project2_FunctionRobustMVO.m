function x = Project2_FunctionRobustMVO(periodReturns, periodFactRet, x0, metricsKey)

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
    
    % Example: Use an OLS regression to estimate mu and Q
    [mu, Q] = OLS(returns, factRet);
    
    
    %alpha = 0.90;
    alpha = metricsKey;
    lambda = 0.02;
    %lambda = metricsKey;
    T = size(returns,1);

    x = robustMVO(mu, Q, lambda, alpha, T,x0);
    


    %----------------------------------------------------------------------
end
