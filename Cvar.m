function  x = Cvar(mu, returns, alpha)
        % Compute the returns
        %rets = ( prices(2:end,:) ./ prices(1:end-1,:) ) - 1;
        %rets = ( prices(2:end,:) - prices(1:end-1,:) ) ./ prices(1:end-1,:);
    rets = returns;
        % Compute the returns
    %rets = ( prices(2:end,:) ./ prices(1:end-1,:) ) - 1;
    %rets2 = ( prices(2:end,:) - prices(1:end-1,:) ) ./ prices(1:end-1,:);

    % Define the confidence level
    %alpha = 0.90;

    % Estimate the geometric mean (for our target return)
    mu = ( geomean(rets + 1) - 1 )';

    % Set our target return (as an example, set it as 10% higher than the
    % average asset return)
    R = -1.1 * mean( mu );

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
    %x = y

    % Calculate the historical loss distribution for the optimal portfolio
    %optLoss = -rets * x;

    % Calculate the historical loss distribution for the equally-weighted 
    % portfolio (for comparison)
    %EWLoss = -rets * ones(n,1) / n;


end