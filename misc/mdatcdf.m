function out = mdatcdf(t, df)
% Cumulative distribution function for Student's t-distribution
%
   x = df ./ (t.^2 + df);
   out = zeros(size(t));
   out(~isnan(x)) = 1 - 0.5 * betainc(x(~isnan(x)), df/2, 0.5);
   out(isnan(x)) = NaN;
   out(t < 0) = 1 - out(t < 0);
end