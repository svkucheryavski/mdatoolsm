function out = mdase(values)
%% Standard error for columns
%
   out = std(values)/sqrt(size(values, 1));
end