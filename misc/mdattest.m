function out = mdattest(values, mu)
%% One-sample t-test
%

   if nargin < 2
      mu = 0;
   end
   
   if numel(mu) == 1
      mu = mu * ones(1, size(values, 2));
   end
   
   df = size(values, 1) - 1;
   se = mdase(values);
   m = mean(values);
   t = (m - mu) ./ se;
   tm = min([t; -t]);
   
   out = [mdatcdf(t, df); 2 * mdatcdf(tm, df); 1 - mdatcdf(t, df)];
end