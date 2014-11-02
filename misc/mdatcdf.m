function out = mdatcdf(t, df)
% Cumulative distribution function for Student's t-distribution
%
   x = df ./ (t.^2 + df);
   out = 1 - 0.5 * betainc(x, df/2, 0.5);
   
   out(t < 0) = 1 - out(t < 0);
end