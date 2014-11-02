function p = mdachi2cdf(x, df)
% 'mdachi2cdf' cumulative distribution function for Chi square distribution.
   p = gammainc(df/2, x/2)/gamma(df/2);
end

