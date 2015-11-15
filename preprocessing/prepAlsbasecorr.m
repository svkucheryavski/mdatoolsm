classdef prepAlsbasecorr < prepItem

   properties (SetAccess = private)
      name = 'alsbasecorr';
      fullName = 'ALS baseline correction';      
   end
   
   methods
      function obj = prepAlsbasecorr(varargin)
         obj = obj@prepItem(varargin{:});
         
         obj.optionList = {...
            'Smoothness', [1 10^12], 10^5;...
            'Penalty', [0 1], 0.1 ...
            };
         
         if nargin == 0
            obj.options = obj.optionList(:, 3);
         elseif nargin ~= 2
            error('"alsbasecorr" has two parameters: smoothness and penalty!')
         else
            obj.options = varargin;
         end   
      end 
      
      function out = apply(obj, values, excludedRows, excludedCols)
         
         % for calculation parameters of preprocessing 
         % we do not take into account excluded rows (objects)
         % but do it for excluded columns


         out = zeros(size(values));
         for i = 1:size(values, 1)
            b = obj.alsbasecorr(values(i, ~excludedCols), obj.options{:}); 
            out(i, ~excludedCols) = values(i, ~excludedCols) - b';
         end   
      end   
       
   end
   
   methods (Static = true)
      
      function baseline = alsbasecorr(s, smoothness, penalty)
         [nr, nc] = size(s);
         
         if nc > nr
            s = s';
         end   
      
         if nargin < 3
            penalty = 0.1;
         end
   
         if nargin < 2
            smoothness = 10^5;
         end
   
         m = length(s);
         D = diff(speye(m), 2);
         w = ones(m, 1);
   
         for it = 1:20
            W = spdiags(w, 0, m, m);
            C = chol(W + smoothness * D' * D);
            baseline = C \ (C' \ (w .* s));
            w = penalty * (s > baseline) + (1 - penalty) * (s < baseline);
         end
      end   
      
   end   
end   

