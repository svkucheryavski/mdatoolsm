classdef mdapls < regmodel
% 'mdapls' creates and manipulates
%
%
   properties (SetAccess = 'protected')
      xloadings
      yloadings
      weights
      vipscores
      selratio
   end
   
   methods
      function obj = mdapls(X, y, ncomp, varargin)
         obj = obj@regmodel(X, y, ncomp, varargin{:});
         obj.setVIPScores();         
      end   
      
      function fit(obj, oX, oy)
         
         X = copy(oX);
         y = copy(oy);
         
         if ~isempty(obj.prep)
            obj.prep{1}.apply(X);
            obj.prep{2}.apply(y);
         end   

         excludedCols = X.excludedCols(~X.factorCols);                  

         % calibrate model using SIMPLS and re-set nComp
         m = mdapls.simpls(X.numValues, y.numValues, obj.nComp);
         obj.nComp = size(m.weights, 2);
         
         % assign names and values to model object
         respNames = y.colNamesAllWithoutFactors;
         respFullNames = y.colFullNamesAllWithoutFactors;
         respRowValues = y.rowValuesAll;
         respColValues = y.colValuesAllWithoutFactors;
         
         predNames = X.colNamesAllWithoutFactors;         
         predFullNames = X.colFullNamesAllWithoutFactors;
         predRowValues = X.rowValuesAll;
         predColValues = X.colValuesAllWithoutFactors;
         
         compNames = textgen('Comp', 1:obj.nComp);
         compFullNames = textgen('Comp ', 1:obj.nComp);
         
         wayNames = {predNames, respNames, compNames};
         wayFullNames = {predFullNames, respFullNames, compFullNames};
         wayValues = {predColValues, respRowValues, 1:obj.nComp};
         
         % regression coefficients
         name = 'Regression coefficients';         
         dimNames = {X.dimNames{2}, 'Responses', 'Components'};
         b = zeros(X.nNumColsAll, y.nNumCols, obj.nComp);
         b(~excludedCols, :, :) = m.coeffs; 
         b = mdadata3(b, wayNames, wayFullNames, dimNames, name);
         b.wayValuesAll = wayValues;
         b.excluderows(excludedCols);
         obj.regcoeffs = regcoeffs(b);
         
         % weights
         name = 'Weights';         
         dimNames = {X.dimNames{2}, 'Components'};
         w = zeros(X.nNumColsAll, obj.nComp);
         w(~excludedCols, :) = m.weights; 
         w = mdadata(w, predNames, compNames, dimNames, name);
         w.rowFullNamesAll = predFullNames;
         w.colFullNamesAll = compFullNames;
         w.rowValuesAll = predColValues;
         w.excluderows(excludedCols);
         obj.weights = w;
         
         % X loadings
         name = 'X loadings';         
         dimNames = {X.dimNames{2}, 'Components'};
         xl = zeros(X.nNumColsAll, obj.nComp);
         xl(~excludedCols, :) = m.xloadings; 
         xl = mdadata(xl, predNames, compNames, dimNames, name);
         xl.rowFullNamesAll = predFullNames;
         xl.colFullNamesAll = compFullNames;
         xl.rowValuesAll = predColValues;
         xl.excluderows(excludedCols);
         obj.xloadings = xl;
         
         % Y loadings
         name = 'Y loadings';         
         dimNames = {y.dimNames{2}, 'Components'};
         yl = mdadata(m.yloadings, respNames, compNames, dimNames, name);
         yl.rowFullNamesAll = respFullNames;
         yl.colFullNamesAll = compFullNames;
         yl.rowValuesAll = predRowValues;
         obj.yloadings = yl;

         obj.setSelratio(X);
      end
      
      function res = predict(obj, oX, oyref, makeres)
         
         if nargin < 4
            makeres = true;
         end
         
         if nargin < 3 || isempty(oyref)
            yref = [];
         else   
            yref = copy(oyref);
         end
         
         X = copy(oX);
                  
         if ~isempty(obj.prep) 
            obj.prep{1}.apply(X);
         end            
         xscores = X.valuesAll(:, ~X.factorCols) * ...
            (obj.weights.valuesAll * pinv(obj.xloadings.valuesAll' * obj.weights.valuesAll));     

         % mdadata for X scores
         xscores = mdadata(xscores, X.rowNamesAll, obj.weights.colFullNames);
         xscores.dimNames = {X.dimNames{1}, obj.weights.dimNames{2}};
         xscores.rowValuesAll = X.rowValuesAll;
         xscores.name = 'X scores';
         xscores.excluderows(X.excludedRows);
         
         ypred = zeros(X.nRowsAll, obj.regcoeffs.nResp, obj.nComp);
         for i = 1:obj.regcoeffs.nComp
            b = squeeze(obj.regcoeffs.values_.values_(:, :, i));
            ypred(:, :, i) = X.valuesAll(:, ~X.factorCols) * b;
            if ~isempty(obj.prep)
               ypred(:, :, i) = obj.prep{2}.sweep(squeeze(ypred(:, :, i)));
            end
         end

         if ~isempty(yref)
            if ~isempty(obj.prep) 
               yrefc = copy(yref);
               obj.prep{2}.apply(yrefc);
            end   
            
            yscores = yrefc.valuesAll * obj.yloadings.valuesAll;
         end
            
         % set up 3-way dataset for predictions (nPred x nResp x nComp)
         % we use empty name for components here         
         if isempty(yref) || (isempty(yref.colNames) && ~isempty(obj.calres))
            colNamesAll = obj.calres.yref.colNamesAll;
            colFullNamesAll = obj.calres.yref.colFullNamesAll;
         else
            colNamesAll = yref.colNamesAll;
            colFullNamesAll = yref.colFullNamesAll;
         end
         
         wayNames = {X.rowNamesAll, colNamesAll, obj.weights.colNames};
         wayFullNames = {X.rowFullNamesAll, colFullNamesAll, obj.weights.colFullNames};
         dimNames = {X.dimNames{1}, 'Responses', 'Components'};
         name = 'Predicted values';
         ypred = mdadata3(ypred, wayNames, wayFullNames, dimNames, name);
         ypred.wayValuesAll{1} = X.rowValuesAll;
         ypred.excluderows(X.excludedRows);

         xdecomp = ldecomp(xscores, obj.xloadings, X);

         if ~isempty(yref)
            [yT2, yQ, ~, ytnorm] = ldecomp.getDistances(xscores, obj.yloadings, yrefc);
            % mdadata for Y scores
            yscores = mdadata(yscores, X.rowNamesAll, obj.weights.colFullNames);
            yscores.dimNames = {X.dimNames{1}, obj.weights.dimNames{2}};
            yscores.rowValuesAll = X.rowValuesAll;
            yscores.name = 'Y scores';
            yscores.excluderows(X.excludedRows);

            ydecomp = ldecomp(yscores, obj.yloadings, yrefc, ytnorm, sum(yrefc.values(:).^2), yQ, yT2);
         else
            ydecomp = [];
         end   

         if makeres
            res = plsres(xdecomp, ydecomp, ypred, yref);
         else
            res.xdecomp = xdecomp;
            res.ydecomp = ydecomp;
            res.ypred = ypred;
            res.yref = yref;
         end   
      end
      
      function res = crossval(obj, oX, oy, varargin)
      % 'crossval' cross-validation of PLS model
      
         X = copy(oX);
         y = copy(oy);

         % remove excluded rows from datast
         excludedRows = find(X.excludedRows);
         X.includerows(excludedRows);
         X.removerows(excludedRows);
         y.includerows(excludedRows);
         y.removerows(excludedRows);
         
         nObj = X.nRows;
         nPred = X.nNumCols;
         nResp = y.nNumCols;
         nComp = obj.nComp;
         
         % get matrix with indices for cv segments
         idx = mdacrossval(nObj, obj.cv);
         [nSeg, seglen, nRep] = size(idx);
      
         ycv = zeros(nObj, nResp, nComp);  
         xQ = zeros(nObj, nComp);  
         xT2 = zeros(nObj, nComp);  
         yQ = zeros(nObj, nComp);  
         yT2 = zeros(nObj, nComp);  
         jkcoeffs = zeros(X.nNumCols, nResp, nComp, nSeg);
         
         % loop over repetitions and segments
         for iRep = 1:nRep
            for iSeg = 1:nSeg
               % get logical indices for validation subset
               ind = idx(iSeg, :, iRep);
               ind(isnan(ind)) = [];
               
               if numel(ind) > 0
                  vind = false(nObj, 1);
                  vind(ind) = true;   
            
                  Xcal = X(~vind, :).numValues;
                  ycal = y(~vind, :).numValues;
                  Xval = X(vind, :).numValues;
                  yval = y(vind, :).numValues;

                  prep = {copy(obj.prep{1}) copy(obj.prep{2})};
                  
                  m = mdapls.cvfit(Xcal, ycal, nComp, prep);
                  res = mdapls.cvpred(Xval, yval, m);
                  
                  [T2x, Qx, ~, ~] = ldecomp.getDistances(mdadata(res.xscores), mdadata(m.xloadings), mdadata(res.X), mdadata(m.xtnorm));
                  xQ(vind, :) = xQ(vind, :) + Qx.valuesAll;
                  xT2(vind, :) = xT2(vind, :) + T2x.valuesAll;

                  [T2y, Qy, ~, ~] = ldecomp.getDistances(mdadata(res.xscores), mdadata(m.yloadings), mdadata(res.y), mdadata(m.ytnorm));
                  yQ(vind, :) = yQ(vind, :) + Qy.valuesAll;
                  yT2(vind, :) = yT2(vind, :) + T2y.valuesAll;
                  
                  jkcoeffs(:, :, :, iSeg) = jkcoeffs(:, :, :, iSeg) + m.coeffs;
                  ycv(vind, :, :) = ycv(vind, :, :) + res.ycv;
               end
            end
         end
         
         jkcoeffs = jkcoeffs ./ nRep;
         ycv = ycv ./ nRep;
         yQ = yQ ./ nRep;
         yT2 = yT2 ./ nRep;
         xQ = xQ ./ nRep;
         xT2 = xT2 ./ nRep;
         
         wayValues = {X.rowValues, [], []};
         wayNames = {X.rowNames, y.colNames, obj.xloadings.colNames};
         wayFullNames = {X.rowFullNames, y.colFullNames, obj.xloadings.colFullNames};
         dimNames = {X.dimNames{1}, 'Responses', 'Components'};
         name = 'Predicted values';
         ycv = mdadata3(ycv, wayNames, wayFullNames, dimNames, name);
         ycv.wayValuesAll = wayValues;
         
         xT2 = mdadata(xT2, X.rowNames, obj.xloadings.colNames, obj.calres.xdecomp.scores.dimNames);
         xT2.name = 'T2 residuals';
         xT2.rowFullNamesAll = X.rowFullNames;
         xT2.colFullNamesAll = obj.xloadings.colFullNames;
         xT2.rowValuesAll = X.rowValues;
         
         xQ = mdadata(xQ, xT2.rowNames, xT2.colNames, xT2.dimNames, 'Q residuals');
         xQ.rowFullNamesAll = xT2.rowFullNamesAll;
         xQ.colFullNamesAll = xT2.colFullNamesAll;
         xQ.rowValuesAll = xT2.rowValuesAll;

         xdecomp = ldecomp([], [], [], obj.calres.xdecomp.tnorm, obj.calres.xdecomp.totvar, xQ, xT2, []);

         yT2 = mdadata(yT2, X.rowNames, obj.yloadings.colNames, obj.calres.xdecomp.scores.dimNames);
         yT2.name = 'T2 residuals';
         yT2.rowFullNamesAll = X.rowFullNames;
         yT2.colFullNamesAll = obj.yloadings.colFullNames;
         yT2.rowValuesAll = X.rowValues;
         
         yQ = mdadata(yQ, yT2.rowNames, yT2.colNames, yT2.dimNames, 'Q residuals');
         yQ.rowFullNamesAll = yT2.rowFullNamesAll;
         yQ.colFullNamesAll = yT2.colFullNamesAll;
         yQ.rowValuesAll = yT2.rowValuesAll;
         ydecomp = ldecomp([], [], [], obj.calres.ydecomp.tnorm, obj.calres.ydecomp.totvar, yQ, yT2, []);

         res.res = plsres(xdecomp, ydecomp, ycv, y);
         res.jkcoeffs = jkcoeffs;
      end
      
      function setVIPScores(obj)
         nPred = obj.regcoeffs.nPred;
         nResp = obj.regcoeffs.nResp;
         nComp = obj.nComp;

         vipscores = zeros(nPred, nResp);

         w = obj.weights(:, 1:nComp).values;
         xloads = obj.xloadings(:, 1:nComp).values;
         xscores = obj.calres.xdecomp.scores(:, 1:nComp).values;

         % regression coefficients for working with scores instead of x
         % T = X * WPW 
         % T * WPW' = X * WPW * WPW'
         % T * WPW' * (WPW * WPW')^-1 = X
         % YP = X * b 
         % YP = T * WPW' * (WPW * WPW')^-1 * b
         % YP = T * bT, where bT = WPW' * (WPW * WPW)^-1 * b
         wpw = w * pinv(xloads' * w);
         
         % normalise weights
         n = 1./sqrt(sum(w.^2));
         if nComp > 1
            n = diag(n);                     
         end   
         wnorm = w * n;
   
         for iResp = 1:nResp
            b = obj.regcoeffs.values(1:end, iResp, nComp).values;
            bscores = (wpw' * pinv(wpw * wpw')) * b;         
            ss = (bscores.^2) .* sum(xscores.^2)';
            vipscores(:, iResp) = nPred * wnorm.^2 * ss / sum(ss);
         end
         
         vipscores = mdadata(vipscores, obj.regcoeffs.values_.wayNames{1}, obj.regcoeffs.values_.wayNames{2});
         vipscores.dimNames = {obj.regcoeffs.values_.dimNames{1}, obj.regcoeffs.values_.dimNames{2}};
         vipscores.rowValuesAll = obj.regcoeffs.values_.wayValues{1};
         vipscores.name = 'VIP scores';
         obj.vipscores = vipscores;
      end
      
      function setSelratio(obj, X)
         nPred = obj.regcoeffs.nPred;
         nResp = obj.regcoeffs.nResp;
         nComp = obj.nComp;
         X = X.numValues;
         selratio = zeros(nPred, nResp);
         
         for iResp = 1:nResp
            b = obj.regcoeffs.values(1:end, iResp, nComp).values;
            bnorm = sqrt(sum(b.^2));
            w = b/bnorm;
            
            ttp = X * w;
            ptp = (ttp' * X) / (ttp' * ttp);
   
            expvar = ttp * ptp;
            resvar = var(X - expvar);
            expvar = var(expvar);
            selratio(:, iResp) = expvar ./ resvar;
         end
         
         selratio = mdadata(selratio, obj.regcoeffs.values_.wayNames{1}, obj.regcoeffs.values_.wayNames{2});
         selratio.dimNames = {obj.regcoeffs.values_.dimNames{1}, obj.regcoeffs.values_.dimNames{2}};
         selratio.rowValuesAll = obj.regcoeffs.values_.wayValues{1};
         selratio.name = 'Selectivity ratio';
         obj.selratio = selratio;         
      end
      
      function plot(obj, varargin)
         [nresp, ncomp, varargin] = regres.getRegPlotParams(obj.nResp, obj.nComp, varargin{:});
         subplot(2, 2, 1)
         plotxresiduals(obj, ncomp, varargin{:});
         subplot(2, 2, 2)
         plotregcoeffs(obj, nresp, ncomp, varargin{:});
         subplot(2, 2, 3)
         plotrmse(obj, nresp, varargin{:});
         subplot(2, 2, 4)
         plotpredictions(obj, nresp, ncomp, varargin{:});
      end   
   end
   
   methods (Static = true)
      m = simpls(X, y, ncomp)
      res = cvfit(X, y, ncomp, prep)
      res = cvpred(X, y, m)
   end   
end   