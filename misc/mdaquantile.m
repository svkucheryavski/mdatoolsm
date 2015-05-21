function out = mdaquantile(x, n, m)
   if nargin < 3
      m = 100;
   end
   
   x = sort(x);
   out = i / n * (m + 1);
end