classdef prepWhitening< prepItem

   properties (SetAccess = private)
      name = 'whitening';
      fullName = 'Whitening of variables';      
   end
   
   methods
      function obj = prepWhitening(varargin)
         obj = obj@prepItem(varargin{:});
         
         obj.optionList = {};
         
         if nargin ~= 0
            error('"whitening" has no parameters!')
         end   
      end 
      
      function out = apply(obj, values, excludedRows, excludedCols)
         
         % for calculation parameters of preprocessing 
         % we do not take into account excluded rows (objects)
         % but do it for excluded columns


         out = zeros(size(values));
         out(~excludedRows, ~excludedCols) = obj.whitening(values(~excludedRows, ~excludedCols));
      end   
       
   end
   
   methods (Static = true)
      
      function W = whitening(X)
         [V, D] = eig(cov(X));
         P = V * diag(sqrt(1./(diag(D) + 0.1))) * V';
         W = bsxfun(@minus, X, mean(X)) * P;      
      end   
      
   end   
end   

