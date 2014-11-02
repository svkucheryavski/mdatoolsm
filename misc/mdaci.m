function out = mdaci(values, alpha)
%% Standard error for columns
%
   if nargin < 2
      alpha = 0.05;
   end
   
   df = size(values, 1) - 1;
   t = mdatinv(1 - alpha/2, df);
   se = mdase(values);
   m = mean(values);
   
   out = [m - t * se; m + t * se];
end