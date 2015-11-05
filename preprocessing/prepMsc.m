classdef prepMsc < prepItem
   properties (SetAccess = private)
      name = 'msc';
      fullName = 'Multiplicative Scatter Correction';      
   end
   
   methods
      function obj = prepMsc(varargin)
         obj = obj@prepItem(varargin{:});
      end 
      
      function out = apply(obj, values, excludedRows, excludedCols)
         
         % for calculation parameters of preprocessing 
         % we do not take into account excluded rows (objects)
         % but do it for excluded columns
         
         if isempty(obj.values)
            means = mean(values(~excludedRows, :));            
            obj.values = {means};
         else
            means = obj.values{1};
         end
         
         out = obj.msc(values, means);
      end                
   end   
   
   methods (Static = true)
      function out = msc(values, means)
         X = [ones(numel(means), 1) means'];
         out = zeros(size(values));
         for i = 1:size(values, 1);
               
            y = values(i, :)';
            b = X \ y;
            out(i, :) = (values(i, :) - b(1))/b(2);
         end         
      end      
   end   
end   