function out = mdaci(values, alpha, varargin)
%% Standard error for columns
%
   if nargin < 2
      alpha = 0.05;
   end
   
   df = size(values, 1) - 1;
   t = mdatinv(1 - alpha/2, df);
   se = mdase(values);
   m = mean(values, 1);
   
   out = [m - t * se; m + t * se];
end