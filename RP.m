function  x = RP(mu, Q, kappa, y0)

    % This function implements the risk parity problem:
    %
    % min   (1/2) * (x' * Q * x) - kappa * sum_{i=1}^n ln(x_i)
    % s.t.  x >= 0

    % Find number of assets
    n = size(Q,1);
    
    % Assign an arbitrary value for kappa
    %kappa = 5;
    
    %----------------------------------------------------------------------
    % Define input parameters for 'fmincon' solver
    %----------------------------------------------------------------------
    % Define initial portfolio ("equally weighted" or "1/n portfolio")
    %y0 = repmat(1.0 / n, n, 1);
    
    % Linear equality Constraint bounds
    Aeq = ones(1,n);
    beq = 1;
    
    % Set the target as the average expected return of all assets
    targetRet = mean(mu);
    
    % Linear inequality Constraint bounds
    A = -1 .* mu';
    b = -1 * targetRet;
    %A = [];
    %b = [];
    
    % Lower and upper bounds on variables
    lb = zeros(n,1);
    ub = [];
    
    %----------------------------------------------------------------------
    % Start 'fmincon' solver
    %----------------------------------------------------------------------
    % Solve using fmincon
    y = fmincon(@(y)objFun(y, Q, kappa),y0,A,b,Aeq,beq,lb,ub);
    
    % Recover the weights
    x = y ./ sum(y);
    
    % Calculate the individual risk contribution per asset
    %RC = (x .* (Q * x)) / sqrt(x' * Q * x);

end

% Define the objective function
function f = objFun(x, Q, kappa)

    n = size(Q,1) ;
    
    f = 0.5 .* (x' * (Q * x));
    
    for i = 1:n
      
        f = f - kappa * log( x(i) );
      
    end
  
end