classdef prepNorm < prepItem
   
   properties (SetAccess = private)
      name = 'norm';
      fullName = 'Normalization';      
   end
   
   methods
      function obj = prepNorm(varargin)
         obj = obj@prepItem(varargin{:});

         obj.optionList = {...
            'Type', {'area', 'length'}, 'area', 'popup'...
            };
         
         if nargin == 0
            obj.options = obj.optionList(:, 3);
         elseif nargin ~= 1
            error('"norm" has one parameter: type!')
         else
            obj.options = varargin;
         end   
         
      end 
      
      function out = apply(obj, values, excludedRows, excludedCols)
         
         % for calculation parameters of preprocessing 
         % we do not take into account excluded rows (objects)
         % but do it for excluded columns

         type = obj.options{:};
         
         out = zeros(size(values));
         values = values(~excludedRows, ~excludedCols);
         if strcmp(type, 'area')
            w = sum(abs(values), 2);
         elseif strcmp(type, 'length')
            w = sqrt(sum(values.^2, 2));
         end
         
         out(~excludedRows, ~excludedCols) = bsxfun(@rdivide, values, w);
         
       end   
   end   
end   