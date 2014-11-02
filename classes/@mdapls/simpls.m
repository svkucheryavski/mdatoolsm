function m = simpls(X, y, nComp, cv)
   
   if nargin < 4
      cv = false;
   end   
   
   nPred = size(X, 2);
   nResp = size(y, 2);
   
   % initial estimation
   A = X' * y;
   M = X' * X;
   C = diag(ones(nPred, 1));
   
   % prepare space for results
   B = zeros(nPred, nResp, nComp);
   W = zeros(nPred, nComp);
   P = zeros(nPred, nComp);
   Q = zeros(nResp, nComp);
   
   % loop for each components
   for iComp = 1:nComp
      % get the dominate eigenvector of A'A
      [evec, eval] = eigs(A' * A);
      q = evec(1:nResp, 1);
      
      % calculate and store weights
      w = A * q;
      c = w' * M * w;
      w = w/sqrt(c);
      W(:, iComp) = w;
      
      % calculate and store x loadings
      p = M * w;
      P(:, iComp) = p;
      
      % calculate and store y loadings
      q = A' * w;
      Q(:, iComp) = q;
      
      v = C * p;
      v = v/sqrt(v' * v);
      
      % calculate and store regression coefficients
      B(:, :, iComp) = W(:, 1:iComp) * Q(:, 1:iComp)';
      
      % recalculate matrices for the next compnonent
      C = C - v * v';
      M = M - p * p';
      A = C * A;      
      
      if ~cv && eval < 10^-12 
         % stop cycle is egienvalue is almost zero
         break
      end
   end
   
   % truncate results if iComp is smaller than nComp
   B = B(:, :, 1:iComp);
   W = W(:, 1:iComp);
   P = P(:, 1:iComp);
   Q = Q(:, 1:iComp);
   
   m.coeffs = B;
   m.weights = W;
   m.xloadings = P;
   m.yloadings = Q;
end
