function out = mdacorr(values)
%MDACORR calculates a correlation matrix for all pairwise columns of VALUES
%
   sd = std(values);
   out = cov(values)./(sd' * sd);      
end

