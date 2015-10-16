classdef prepRef2abs < prepItem
   
   properties (SetAccess = private)
      name = 'ref2abs';
      fullName = 'Reflectance to absorbance';      
   end
   
   methods
      function obj = prepRef2abs(varargin)
         obj = obj@prepItem(varargin{:});
      end 
      
      function out = apply(obj, values, excludedRows, excludedCols)
         % TODO: check if there are any zero or negative values
            out = log(1./values);
       end   
   end   
end   