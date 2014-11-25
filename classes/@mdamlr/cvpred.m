function res = cvpred(X, y, m)
   
   if ~isempty(m.prep) 
      X = m.prep{1}.apply(X);
      y = m.prep{2}.apply(y);
   end
   
   ypred = X * m.coeffs;
   
   if ~isempty(prep)
      ypred = m.prep{2}.sweep(squeeze(ypred));
   end

   res.X = X;
   res.y = y;
   res.ycv = ypred;   
end