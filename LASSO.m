function  [mu, Q, adjR2, alpha, V] = LASSO(returns, factRet, lambda, K)   
    % Use this function for the LASSO model. Note that you will not use K 
    % in this model (K is for BSS).
    %
    % You should use anß optimizer to solve this problem. Be sure to comment 
    % on your code to (briefly) explain your procedure.
    % Input  
    % returns : is a t x n matrix with excess return for each tickers in t
    % dates
    % factRet : is a t x p matrix with factor returns in t dates
    % *************** WRITE YOUR CODE HERE ***************
    %----------------------------------------------------------------------
    t = size(returns,1);
    n = size(returns,2);
    p = size(factRet,2);
    f = factRet;
    r = returns;

    % Quadratic Program
    % min b' H b + c' b
    % s.t.   A b <= 0
    alphaplace = ones(t,1);
    X = [alphaplace f];
   
    % fill the rest of H with zeros
    H = 2*[X'*X zeros(p+1);
        zeros(p+1,2*p+2)];
    
    I = eye(p+1);
    
    A = [I -I;
        -I -I];
    
    
    
    alpha = zeros(n,1);
    V = zeros(p,n);
    l = zeros(2*p + 2,1);

    % loop for each asset to get the optimal mu and variance
    for i = 1:n
        ri = returns(:,i);
        c = [-2 * ri'*X lambda*ones(1,1+p)]'; 
        b = quadprog(H,c,A,l,[],[],[],[],[]);
        % alpha for interceptions
        alpha(i) = b(1);
        % beta name as V
        V(:,i) = b(2:p+1,:);
    end
    % Compute residuals
    B = [alpha'; V];

    % compute covatiance of fac returns
    F = cov(f);
    
    %r = returns;
    % as for lasso, alpha potentially needed in calculating residual
    residual = r - X*B;
    residual_var = zeros(size(r,2), 1);

    % prepare for adj R2
    for i = 1: size(residual, 2)
        residual_var(i,1) = sum(residual(:,i).^2) / (t - p -1);
    end
    
    D = diag(residual_var);
    
    total_var = zeros(size(r,2),1);
    
    for i = 1: size(r,2)
        total_var(i,1) = sum((r(:,i)-mean(r(:,i))).^2) / (t-1);
    end
    
    
    % note we need geomean
    mu = alpha + V.' * ((geomean(f+1)-1).');
    % Q would need cov of fac return
    Q = V.' * F * V + D;
    
    adjR2 = mean(1 - residual_var ./ total_var);
end