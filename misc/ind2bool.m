function out = ind2bool(ind, n)
   out = false(n, 1);
   if numel(ind) > 0
      out(ind) = true;
   end   
end