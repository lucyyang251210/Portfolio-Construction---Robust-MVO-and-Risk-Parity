function  [mu, Q, rSqr] = LASSO2(returns, factRet, lambda, K)
    
    % Use this function for the LASSO model. Note that you will not use K 
    % in this model (K is for BSS).
    %
    % You should use an optimizer to solve this problem. Be sure to comment 
    % on your code to (briefly) explain your procedure.
    
    % *************** WRITE YOUR CODE HERE ***************
    %----------------------------------------------------------------------
    
    f = factRet;
    [T p]= size(f);
    X = [ones(T,1) f];
    R = returns;
    n = size(R,2);
    
    abs_p = [diag(ones(p+1,1)) diag(ones(p+1,1))];
    abs_m = [diag(ones(p+1,1)) diag(-ones(p+1,1))];
    
    B = zeros(p+1,n);
    factorNum = zeros(n, 1);
    tolerance = 1e-6;
    for i=1:n
        r_i = R(:,i);
        H = abs_m.' * X.' * X * abs_m;
        g = - abs_m.' * X.' * r_i + (lambda/2) * abs_p.' * ones(p+1,1);
        lb = zeros(2*(p+1),1);
        B_i = quadprog(H, g, [], [], [], [], lb, []);
        B(:,i) = abs_m * B_i;
        factorNum(i,1) = sum(abs(B(2:end,i))>=tolerance);
    end
    
    alpha = B(1,:).';
    V = B(2:end,:);
    
    F = cov(f); % Factor covariance matrix
    residual = R - (X * B);
    residual_var = zeros(size(R,2),1);
    for i = 1:size(residual,2)
        residual_var(i,1) = sum(residual(:,i).^2) / (T-factorNum(i,1)-1);
    end
    D = diag(residual_var);
    
    total_var = zeros(size(R,2),1);
    for i = 1:size(R,2)
        total_var(i,1) = sum((R(:,i) - mean(R(:,i))).^2) / (T-1);
    end
    
    mu = alpha + V.' * ((geomean(f+1)-1).');           % n x 1 vector of asset exp. returns
    Q  = V.' * F * V + D;                     % n x n asset covariance matrix
    rSqr = 1 - residual_var ./ total_var;
    %----------------------------------------------------------------------
    
end