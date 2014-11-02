function p = mdapercentile(v, i)
   if i < 1
      i = i * 100;
   end
   
   if size(v, 1) == 1 && size(v, 2) > 1
      v = v';
   end   
   
   v = sort(v);   
   m = size(v, 1);

   n = i/100.0 * (m + 1);
   
   n1 = floor(n);
   n2 = ceil(n);
   
   if (n1 == 0)
      n1 = 1;
   end
   
   if (n2 > size(v, 1))
      n2 = size(v, 1);
   end   
   
   p = (v(n1, :) + v(n2, :))/2;
end