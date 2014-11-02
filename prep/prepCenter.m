classdef prepCenter < prepItem
   methods
      function obj = prepCenter(varargin)
         obj = obj@prepItem(varargin{:});
         obj.name = 'center';
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
         
         out = bsxfun(@minus, values, means);
      end   
       
      function out = sweep(obj, values, excludedRows, excludedCols)
         if isempty(obj.values)
            out = values;
            return
         end
         
         means = obj.values{1};
         
         out = bsxfun(@plus, values, means);
      end
      
   end   
end   