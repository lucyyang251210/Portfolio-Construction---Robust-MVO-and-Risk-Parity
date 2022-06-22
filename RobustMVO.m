function  x = robustMVO(mu, Q, lambda, alpha, T, x0)

    % This function presents an implementation of the following robust MVO 
    % model:
    %
    % min   lambda * (x' * Q * x) - mu' x + epsilon * norm (sqrtTh * x)
    % s.t.  sum(x) == 1
    %       x >= 0

    % Find the number of assets
    n = size(Q,1);
    
    % Define the radius of our uncertainty set
    ep = sqrt( chi2inv(alpha, n) );
    
    % Find the value of Theta (i.e., the squared standard error of our
    % expected returns)
    Theta = diag( diag(Q) ) ./ T;

    % Square root of Theta
    sqrtTh = sqrt(Theta);
    
    %----------------------------------------------------------------------
    % Define input parameters for the 'fmincon' solver
    %----------------------------------------------------------------------
    % Define initial portfolio ("equally weighted" or "1/n portfolio")
    %x0 = repmat( 1.0/n, n, 1 );
    
    % Linear equality Constraint bounds
    beq = 1;
    Aeq = ones(1, n); 
    
    % Set the target as the average expected return of all assets
    targetRet = mean(mu);
    
    % Add the expected return constraint
    %A = -1 .* mu';
    %b = -1 * targetRet;
    A = [];
    b = [];
    
    % Lower and upper bounds on variables
    lb = zeros(n,1);
    %lb = [];
    ub = [];
    
    % It might be useful to increase the tolerance of 'fmincon'
    options = optimoptions('fmincon', 'TolFun', 1e-9);
    
    %----------------------------------------------------------------------
    % Start the 'fmincon' solver
    %----------------------------------------------------------------------
    % Solve using fmincon
    x = fmincon(@(x)objFun(x, mu, Q, lambda, sqrtTh, ep),x0,A,b,Aeq,beq,lb,ub,...
            @(x)nonlcon(x), options);

end

%-------------------------------------------------------------------------- 
% Define the objective function:
% We must specify our nonlinear objective as a separate function. fmincon
% accepts the "norm( )" function.
%--------------------------------------------------------------------------
function f = objFun(x, mu, Q, lambda, sqrtTh, ep)

    f = (lambda * x' * Q * x) - mu' * x + ep * norm( sqrtTh * x ); 

end

%-------------------------------------------------------------------------- 
% Define the equality and inequality nonlinear constraints:
% fmincon accepts nonlinear constraints, but these must be defined as
% separate functions. In our case, we do not have nonlinear constraints. 
%--------------------------------------------------------------------------
function [c, ceq] = nonlcon(x)

    c = [];
    ceq = [];

end

