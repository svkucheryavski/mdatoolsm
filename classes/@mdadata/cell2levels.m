function [values, names] = cell2levels(v)
   levels = unique(v);
   values = zeros(numel(v));
   for l = 1:numel(levels)
      values(ismember(v, levels{l})) = l;
   end            
   names = levels;
end
