function res = cvpred(X, y, m)
   
   if ~isempty(m.prep) 
      X = m.prep{1}.apply(X);
      y = m.prep{2}.apply(y);
   end
   
   xscores = X * (m.weights * pinv(m.xloadings' * m.weights));     
   yscores = y * m.yloadings;
         
   ypred = zeros(size(y, 1), size(y, 2), m.nComp);
   for i = 1:m.nComp
      b = squeeze(m.coeffs(:, :, i));
      ypred(:, :, i) = X * b;
      if ~isempty(prep)
         ypred(:, :, i) = m.prep{2}.sweep(squeeze(ypred(:, :, i)));
      end
   end

   res.X = X;
   res.y = y;
   res.ycv = ypred;
   
   res.xscores = xscores;
   res.yscores = yscores;
end