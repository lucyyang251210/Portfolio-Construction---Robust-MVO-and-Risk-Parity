function  [mu, Q, adjR2, alpha, V] = BSS(returns, factRet, lambda, K)
    
    % Use this function for the BSS model. Note that you will not use 
    % lambda in this model (lambda is for LASSO).
    %ß
    % You should use an optimizer to solve this problem. Be sure to comment 
    % on your code to (briefly) explain your procedure.
    
 
    % *************** WRITE YOUR CODE HERE ***************
    %----------------------------------------------------------------------

    n = size(returns,2);
    p = size(factRet,2);
    t = size(returns, 1);
    
    % Returns
    r = returns;
    f = factRet;
    
    % add alpha place holders
    alphaplace = ones(t,1);
    X = [ alphaplace f ];
    
    I = eye(n*(p+1));
    %Z = zeros( n*(p+1), n*(p+1) );
    
    % upper and lower bound of betas
    upper = 4;
    lower = -4;
    
    % upper bounds
    %UB = [ I -upper*I ];
    
    % lower bounds
    %LB = [-I lower*I ];
    
    % prepare a matrix for C
    row = ones(1, p+1);
    Ar = repmat(row, 1, n);
    Ac = mat2cell(Ar, size(row,1), repmat(size(row,2),1,n));
    ACdiagZero = blkdiag(Ac{:});
    
    % create C
    C = [ zeros(size(ACdiagZero,1), n*(p+1)) ACdiagZero ];

    % quadratic objective
    Xr = repmat(X, 1, n);
    Xc = mat2cell(Xr, size(X,1), repmat(size(X,2),1,n));
    X_hat = blkdiag(Xc{:});
    
    % populate return vector
    r_hat = reshape(r, n*t, 1);

    %% Setup inputs
    % all inequality constraints in one matrix
    A = [ I -upper*I ; 
        -I lower*I; 
        C ];
    
    % rhs b
    b = [ zeros( 2*n*(p+1), 1 ); K*ones( n, 1) ];

    %% Setup the Gurobi model
    clear model;

    % variable types
    varTypes = [repmat('C', n*(p+1), 1); repmat('B', n*(p+1), 1)];

    % Gurobi accepts an objective function of the following form:
    % f(x) = x' Q x + c' x 

    % Define the Q matrix in the objective 
    model.Q = sparse( [ X_hat'*X_hat zeros(n*(p+1)); ...
                        zeros(n*(p+1)) zeros( n*(p+1)) ]);

    % define the c vector in the objective
    model.obj = [ -2* X_hat'*r_hat; zeros( n*(p+1), 1 ) ];

    % Constraint matrix
    model.A = sparse(A);

    % Define the right-hand side vector b
    model.rhs = b;

    % Indicate whether the constraints are ">=", "<=", or "="
    model.sense = repmat('<', size(b, 1), 1);

    % Define the variable type (continuous, integer, or binary)
    model.vtype = varTypes;

    % Set some Gurobi parameters to limit the runtime and to avoid printing the
    % output to the console. 
    clear params;
    params.TimeLimit = 100;
    params.OutputFlag = 0;

    results = gurobi(model,params);
    
    % Compute residuals
    %f_mean = geomean(factRet +1) -1;
    
    F = cov(factRet);

    B = reshape( results.x(1:n*(p+1)), p+1, n );
    
    alpha = B(1,:)';
    V = B(2:end,:);
    
 
    residual = r - X*B;
    residual_var = zeros(size(r,2), 1);

    
    for i = 1: size(residual, 2)
        residual_var(i,1) = sum(residual(:,i).^2) / (t - p -1);
    end
    
    D = diag(residual_var);
    
    total_var = zeros(size(r,2),1);
    
    for i = 1: size(r,2)
        total_var(i,1) = sum((r(:,i)-mean(r(:,i))).^2) / (t-1);
    end
    

    
    mu = alpha + V.' * ((geomean(f+1)-1).');
    Q = V.' * F * V + D;
    
    adjR2 = mean(1 - residual_var ./ total_var);
    
end