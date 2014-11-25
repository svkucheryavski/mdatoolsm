function m = cvfit(X, y, prep)
   
   if ~isempty(prep)
      X = prep{1}.apply(X);
      y = prep{2}.apply(y);
   end
   
   b = X \ y;

   m.prep = prep;
   m.coeffs = b;
end
      
