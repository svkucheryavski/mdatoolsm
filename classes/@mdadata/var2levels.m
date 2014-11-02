function [values, names] = var2levels(v, varname)         
   if nargin < 2
      varname = '';
   end

   levels = unique(v);
   values = zeros(numel(v));
   for l = 1:numel(levels)
      values(v == levels(l)) = l;
   end

   if ischar(v)
      names = strsplit(sprintf('%c:', levels));
      names(end) = [];
   else   
      names = textgen(varname, levels);
   end   
end      
