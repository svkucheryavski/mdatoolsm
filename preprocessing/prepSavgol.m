classdef prepSavgol < prepItem
   
   properties (SetAccess = private)
      name = 'savgol';
      fullName = 'Savitzky-Goley transformation';      
   end
   
   methods
      function obj = prepSavgol(varargin)
         obj = obj@prepItem(varargin{:});
         
         obj.optionList = {...
            'Derivative', {0 1 2}, 0; ...
            'Width', [1 100], 3; ...
            'Polynomial', {0 1 2 3 4}, 1 ...
            };
         
         if nargin == 0
            obj.options = obj.optionList(:, 3);
         elseif nargin ~= 3
            error('"savgol" has three parameters: derivative, width and polynomial order!')
         else
            obj.options = varargin;
            if mod(obj.options{2}, 2) == 0
               error('Width of filter must be an odd number!')
            end
         end   
      end 
      
      function out = apply(obj, values, excludedRows, excludedCols)
         
         % for calculation parameters of preprocessing 
         % we do not take into account excluded rows (objects)
         % but do it for excluded columns

         out = zeros(size(values));
         out(:, ~excludedCols) = obj.savgol(values(:, ~excludedCols), obj.options{:}); 
      end   
       
   end
   
   methods (Static = true)
      
      function out = savgol(data, dorder, width, porder)
         out = zeros(size(data));
   
         for i = 1:size(data, 1)
            v = data(i, :);
            w = (width - 1)/2;
            f  = pinv(pt(-w:w, 0:porder))';  

            x = v;
            y = f(dorder + 1, end:-1:1);
            v = conv(x, y);
            out(i, :) = v((w + 1) : (numel(v) - w)); 
         end
         
         function t = pt(x, y)
            [xx, yy] = meshgrid(x, y');
            t = xx .^ yy;
         end   

      end   
      
   end   
end   

