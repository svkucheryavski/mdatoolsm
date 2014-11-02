function ind = reducerows(dens, factor)
   if nargin < 2
      factor = 1;
   end   
   d = unique(dens);
   dn = ceil(d / factor);

   ind = [];
   for k = 1:numel(d)
      i = dens == d(k);
      ind = [ind; find(i(1:dn(k):end))];
   end         
end   
