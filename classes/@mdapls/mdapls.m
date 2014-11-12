classdef mdapls < regmodel
% 'mdapls' creates and manipulates
%
%
   properties (SetAccess = 'protected')
      xloadings
      yloadings
      weights
   end
   
   methods
      function obj = mdapls(X, y, ncomp, varargin)
         obj = obj@regmodel(X, y, ncomp, varargin{:});
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
         respNames = y.colNamesAll(~y.factorCols);
         respFullNames = y.colFullNamesAll(~y.factorCols);
         
         predNames = X.colNamesAll(~X.factorCols);
         predFullNames = X.colFullNamesAll(~X.factorCols);
         
         compNames = textgen('Comp', 1:obj.nComp);
         compFullNames = textgen('Comp ', 1:obj.nComp);
         
         wayNames = {predNames, respNames, compNames};
         wayFullNames = {predFullNames, respFullNames, compFullNames};
   
         % regression coefficients
         name = 'Regression coefficients';         
         dimNames = {X.dimNames{2}, 'Responses', 'Components'};
         b = zeros(X.nNumColsAll, y.nNumCols, obj.nComp);
         b(~excludedCols, :, :) = m.coeffs; 
         b = mdadata3(b, wayNames, wayFullNames, dimNames, name);
         b.excluderows(excludedCols);
         obj.regcoeffs = regcoeffs(b);
         
         % weights
         name = 'Weights';         
         dimNames = {X.dimNames{2}, 'Components'};
         w = zeros(X.nNumColsAll, obj.nComp);
         w(~excludedCols, :) = m.weights; 
         w = mdadata(w, predNames, compNames, dimNames, name);
         w.rowFullNames = predFullNames;
         w.colFullNames = compFullNames;
         w.excluderows(excludedCols);
         obj.weights = w;
         
         % X loadings
         name = 'X loadings';         
         dimNames = {X.dimNames{2}, 'Components'};
         xl = zeros(X.nNumColsAll, obj.nComp);
         xl(~excludedCols, :) = m.xloadings; 
         xl = mdadata(xl, predNames, compNames, dimNames, name);
         xl.rowFullNames = predFullNames;
         xl.colFullNames = compFullNames;
         xl.excluderows(excludedCols);
         obj.xloadings = xl;
         
         % Y loadings
         name = 'Y loadings';         
         dimNames = {y.dimNames{2}, 'Components'};
         yl = mdadata(m.yloadings, respNames, compNames, dimNames, name);
         yl.rowFullNames = respFullNames;
         yl.colFullNames = compFullNames;
         obj.yloadings = yl;
         
      end
      
      function res = predict(obj, oX, oyref, cv, makeres)
         
         if nargin < 5
            makeres = true;
         end
         
         if nargin < 4
            cv = false;
         end
         
         if nargin < 3
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
            
         if cv 
         % just return the predicted values   
            res.ycv = ypred;
            res.y = yrefc;
            res.X = X;
            res.xscores = xscores;
         else   
            
            % set up 3-way dataset for predictions (nPred x nResp x nComp)
            % we use empty name for components here         
            wayNames = {X.rowNamesAll, yref.colNames, obj.weights.colNames};
            wayFullNames = {X.rowFullNamesAll, yref.colFullNamesAll, obj.weights.colFullNames};
            dimNames = {X.dimNames{1}, 'Responses', 'Components'};
            name = 'Predicted values';
            ypred = mdadata3(ypred, wayNames, wayFullNames, dimNames, name);
            ypred.excluderows(X.excludedRows);
            
            xdecomp = ldecomp(xscores, obj.xloadings, X);

            if ~isempty(yref)
               [yT2, yQ2, ~, ytnorm] = ldecomp.getDistances(xscores, obj.yloadings, yrefc);
               % mdadata for Y scores
               yscores = mdadata(yscores, X.rowNamesAll, obj.weights.colFullNames);
               yscores.dimNames = {X.dimNames{1}, obj.weights.dimNames{2}};
               yscores.name = 'Y scores';
               yscores.excluderows(X.excludedRows);
            
               ydecomp = ldecomp(yscores, obj.yloadings, yrefc, ytnorm, sum(yrefc.values(:).^2), yQ2, yT2);
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
      end
      
      function cvres = crossval(obj, oX, oy, varargin)
      % 'crossval' cross-validation of MLR model
      
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
         xQ2 = zeros(nObj, nComp);  
         xT2 = zeros(nObj, nComp);  
         yQ2 = zeros(nObj, nComp);  
         yT2 = zeros(nObj, nComp);  
         
         % loop over repetitions and segments
         for iRep = 1:nRep
            for iSeg = 1:nSeg
               % get logical indices for validation subset
               ind = idx(iSeg, :, iRep);
               ind(isnan(ind)) = [];
               
               if numel(ind) > 0
                  vind = false(nObj, 1);
                  vind(ind) = true;   
            
                  Xcal = X(~vind, :);
                  ycal = y(~vind, :);
                  Xval = X(vind, :);
                  yval = y(vind, :);

                  prep = {copy(obj.prep{1}) copy(obj.prep{2})};
                  m = mdapls(Xcal, ycal, nComp, 'Prep', prep, 'Scale', 'off', 'Center', 'off');
                  res = m.predict(Xval, yval, true);
                  
                  tnormX = m.calres.xdecomp.tnorm;
                  tnormY = m.calres.ydecomp.tnorm;

                  [T2, Q2, ~, ~] = ldecomp.getDistances(res.xscores, m.xloadings, res.X, tnormX);
                  xQ2(vind, :) = xQ2(vind, :) + Q2.valuesAll;
                  xT2(vind, :) = xT2(vind, :) + T2.valuesAll;

                  [T2, Q2, ~, ~] = ldecomp.getDistances(res.xscores, m.yloadings, res.y, tnormY);
                  yQ2(vind, :) = yQ2(vind, :) + Q2.valuesAll;
                  yT2(vind, :) = yT2(vind, :) + T2.valuesAll;
            
                  ycv(vind, :, :) = ycv(vind, :, :) + res.ycv;
               end
            end
         end
         
         ycv = ycv ./ nRep;
         yQ2 = yQ2 ./ nRep;
         yT2 = yT2 ./ nRep;
         xQ2 = xQ2 ./ nRep;
         xT2 = xT2 ./ nRep;
         
         wayNames = {X.rowNames, y.colNames, obj.xloadings.colNames};
         wayFullNames = {X.rowFullNames, y.colFullNames, obj.xloadings.colFullNames};
         dimNames = {X.dimNames{1}, 'Responses', 'Components'};
         name = 'Predicted values';
         ycv = mdadata3(ycv, wayNames, wayFullNames, dimNames, name);

         xT2 = mdadata(xT2, X.rowNames, obj.xloadings.colNames, obj.calres.xdecomp.scores.dimNames);
         xT2.name = 'T2 residuals';
         xT2.rowFullNames = X.rowFullNames;
         xT2.colFullNames = obj.xloadings.colFullNames;

         xQ2 = mdadata(xQ2, xT2.rowNames, xT2.colNames, xT2.dimNames, 'Q2 residuals');
         xQ2.rowFullNames = xT2.rowFullNamesAll;
         xQ2.colFullNames = xT2.colFullNamesAll;

         xdecomp = ldecomp([], [], [], obj.calres.xdecomp.tnorm, obj.calres.xdecomp.totvar, xQ2, xT2, []);

         yT2 = mdadata(yT2, X.rowNames, obj.yloadings.colNames, obj.calres.xdecomp.scores.dimNames);
         yT2.name = 'T2 residuals';
         yT2.rowFullNames = X.rowFullNames;
         yT2.colFullNames = obj.yloadings.colFullNames;

         yQ2 = mdadata(yQ2, yT2.rowNames, yT2.colNames, yT2.dimNames, 'Q2 residuals');
         yQ2.rowFullNames = yT2.rowFullNamesAll;
         yQ2.colFullNames = yT2.colFullNamesAll;
         ydecomp = ldecomp([], [], [], obj.calres.xdecomp.tnorm, obj.calres.xdecomp.totvar, xQ2, xT2, []);

         cvres = plsres(xdecomp, ydecomp, ycv, y);
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
   end   
end   