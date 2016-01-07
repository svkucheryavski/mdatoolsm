function p = mdapercentile(v, i)
   if i < 1
      i = i * 100;
   end
   
   v = sort(v);   
   m = size(v, 1);

   n = i/100.0 * (m + 1);
   
   n1 = floor(n);
   n2 = ceil(n);
   
   n1(n1 == 0) = 1;   
   n2(n2 > size(v, 1)) = size(v, 1);

   p = (v(n1, :) + v(n2, :))/2;
end