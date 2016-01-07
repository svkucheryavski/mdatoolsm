function out = mdase(values, varargin)
%% Standard error for columns
%
   out = std(values, 0, 1)/sqrt(size(values, 1));
end