classdef prepMath < prepItem
   
   properties (SetAccess = private)
      name = 'math';
      fullName = 'Mathematical function';      
   end
   
   methods
      function obj = prepMath(varargin)
         obj = obj@prepItem(varargin{:});
         
         if nargin == 0
            error('Specify the function and (optionally) its parameters!');
         else
            obj.options = varargin;
         end   
         
         obj.fullName = [obj.fullName ': ' func2str(obj.options{1})];         
      end 
      
      function out = apply(obj, values, ~, ~)         
         n = numel(obj.options);
         if n == 1
            out = obj.options{1}(values);
         else
            out = obj.options{1}(values, obj.options{2:end});
         end   
      end   
       
   end
   
   methods (Static = true)      
   end   
end   

