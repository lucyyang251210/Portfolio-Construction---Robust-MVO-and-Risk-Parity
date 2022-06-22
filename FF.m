function  [mu, Q, adjR2, alpha, B] = FF(returns, factRet, lambda, K)
    
    % Use this function to calibrate the Fama-French 3-factor model. Note 
    % that you will not use lambda or K in this model (lambda is for LASSO, 
    % and K is for BSS).ß
 
    % *************** WRITE YOUR CODE HERE ***************
    %----------------------------------------------------------------------
    
    % 3 factors market size and value 
    %factReturn  = factRet{:,1:3};
    factReturn = factRet(:,1:3);
    % y is the returns that need to estimate it's a m by 20 matrix
    %y = returns{:,:};
    y = returns;
    % m is rowNum i.e. # of observation; 20 is assetNum
    [rowNum, assetNum] = size(returns);
    
    % m is rowNum; 8 is facNum
    [rowNum, facNum] = size(factReturn);
    % y = alpha + X beta + epsilon need to incorporate alpha
    
    alphaPlace = ones(rowNum,1);
    % add a column to X so X is a m by 8+1=9 matrix 
    
    X = [alphaPlace factReturn];
    betaArray = (X' * X) \ X' * y;
    
    alpha = betaArray(1,:);
    B = betaArray(2:facNum+1,:);
    
    % m by 9 * 9 by 20 = m by 20
    E = X * betaArray - y;
    % Take a square of each element in residuals
    sqrE = E.^2 ;
    % Compute residuel variance
    covE = 1/(rowNum-facNum-1)* sum(sqrE(1:end,:));

      
    % mu =          % n x 1 vector of asset exp. returns
    meanFac = mean(factReturn); % 1 by 8 for 8 factors 
    mu = alpha +  meanFac * B;
    mu = mu';
    
    % Q  =          % n x n asset covariance matrix
    % asset cov = beta * factor cov * beta' + D
    covFac = cov(factReturn);
    % D is diagonal . it is the residual variances's diagonal elements
    D = diag(covE);
    Q = B' * covFac * B + D;
    %cal R^2
    t = size(returns,1);
    n = size(factReturn,2);
    p = size(factReturn,2);
    f = factReturn;
    r = returns;
    F = cov(factReturn);
    
    residual = X * betaArray - y;
    residual_var = zeros(size(r,2), 1);
    %residual_var = eps.^2;
    
    for i = 1: size(residual, 2)
        residual_var(i,1) = sum(residual(:,i).^2) / (t - p -1);
    end
    
    D = diag(residual_var);
    
    total_var = zeros(size(r,2),1);
    
    for i = 1: size(r,2)
        total_var(i,1) = sum((r(:,i)-mean(r(:,i))).^2) / (t-1);
    end
    
    V = B;
    mu = alpha' + V.' * ((geomean(f+1)-1).');
    Q = V.' * F * V + D;
    
    adjR2 = mean(1 - residual_var ./ total_var);
end