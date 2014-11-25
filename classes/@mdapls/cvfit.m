function m = cvfit(X, y, nComp, prep)
   
   if ~isempty(prep)
      X = prep{1}.apply(X);
      y = prep{2}.apply(y);
   end
   
   m = mdapls.simpls(X, y, nComp);

   m.nComp = size(m.weights, 2);
   m.prep = prep;
   
   xscores = X * (m.weights * pinv(m.xloadings' * m.weights));     
   yscores = y * m.yloadings;

   m.xtnorm = sqrt(sum(xscores.^2)/(size(xscores, 1) - 1));
   m.ytnorm = sqrt(sum(yscores.^2)/(size(yscores, 1) - 1));
end
      
