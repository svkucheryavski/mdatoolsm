function out = mdatinv(p, df)
% Inverse cumulative distribution function for Student's t-distribution
%
   out = zeros(size(p));
   
   % cases
   ind1 = p == 0;
   ind2 = p == 1;
   ind3 = p == 0.5;   
   ind4 = p > 0.25 & p < 0.75;
   ind5 = ~ind4;
   
   ind4 = ind4 & ~ind1 & ~ind2 & ~ind3;
   ind5 = ind5 & ~ind1 & ~ind2 & ~ind3;
   
   out(ind1) = -Inf;
   out(ind2) = Inf;
   out(ind3) = 0;
   
   
   if any(ind4)
      z = betaincinv(abs(1 - 2 * p(ind4)), 0.5, 0.5 * df);
      out(ind4) = sqrt(df * z ./ (1 - z));
      out(ind4 & p < 0.5) = -out(ind4 & p < 0.5); 
   end
   
   if any(ind5) 
      f = ones(size(p));
      f(ind5 & p < 0.5) = -1;
      p(ind5 & p >= 0.5) = 1 - p(ind5 & p >= 0.5);
      
      z = betaincinv(2 * p(ind5), 0.5 * df, 0.5);
      out(ind5) = f(ind5) .* sqrt(df ./z - df);
   end

%%%% Old code
%    if p == 0
%       out = -Inf;
%    elseif p == 1
%       out = Inf;
%    elseif p == 0.5;
%       out = 0;
%    elseif p > 0.25 && p < 0.75      
%       z = betaincinv(abs(1 - 2 * p), 0.5, 0.5 * df);
%       out = sqrt(df * z / (1 - z));
%       if p < 0.5
%          out = -out;
%       end   
%    else
%       if p >= 0.5
%          p = 1 - p;
%          f = 1;
%       else
%          f = -1;
%       end
%       z = betaincinv(2 * p, 0.5 * df, 0.5);
%       out = f * sqrt(df /z - df);
%    end
end