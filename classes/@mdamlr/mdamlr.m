classdef mdamlr < regmodel
% 'mdamlr' creates and manipulates
%
%
   methods
      function obj = mdamlr(X, y, varargin)
         obj = obj@regmodel(X, y, 1, varargin{:});
      end   
      
      function fit(obj, oX, oy)
                  
         X = copy(oX);
         y = copy(oy);
         
         if ~isempty(obj.prep)
            obj.prep{1}.apply(X);
            obj.prep{2}.apply(y);
         end   

         excludedCols = X.excludedCols(~X.factorCols);                  
         b = zeros(X.nNumColsAll, 1);
         b(~excludedCols, 1) = X.numValues \ y.numValues;
         
         % set up 3-way dataset for coefficients (nPred x nResp x nComp)
         % we use empty name for components here
         
         wayNames = cell(3, 1);
         wayNames{3} = {'x'};
         if ~isempty(X.colNamesAll)
            wayNames{1} = X.colNamesAll(~X.factorCols);
         end         
         if ~isempty(y.colNamesAll)
            wayNames{2} = y.colNamesAll(~y.factorCols);
         end

         wayFullNames = cell(3, 1);
         wayFullNames{3} = {'x'};
         if ~isempty(X.colFullNamesAll)
            wayFullNames{1} = X.colFullNamesAll(~X.factorCols);
         end         
         if ~isempty(y.colFullNamesAll)
            wayFullNames{2} = y.colFullNamesAll(~y.factorCols);
         end
         
         dimNames = {X.dimNames{2}, 'Responses', ''};
         name = 'Regression coefficients';
         
         b = mdadata3(b, wayNames, wayFullNames, dimNames, name);
         b.wayValuesAll{1} = X.colValuesAll;
         b.excluderows(excludedCols);

         obj.regcoeffs = regcoeffs(b);
      end
      
      function res = predict(obj, oX, oyref, cv)
         
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
         
         b = squeeze(obj.regcoeffs.values_.values_);
         ypred = X.valuesAll(:, ~X.factorCols) * b;

         if ~isempty(obj.prep)
            ypred = obj.prep{2}.sweep(ypred);
         end

         if cv 
         % just return the predicted values   
            res = ypred;
         else   
         % set up 3-way dataset for coefficients (nPred x nResp x nComp)
         % we use empty name for components here         
            if isempty(yref) || (isempty(yref.colNames) && ~isempty(obj.calres))
               colNames = obj.calres.yref.colNames;
               colFullNamesAll = obj.calres.yref.colFullNamesAll;
            else
               colNames = yref.colNames;
               colFullNamesAll = yref.colFullNamesAll;
            end
            
            wayNames = {X.rowNamesAll, colNames, {'x'}};
            wayFullNames = {X.rowFullNamesAll, colFullNamesAll, {'x'}};
            dimNames = {X.dimNames{1}, 'Responses', ''};
            name = 'Predicted values';
            
            ypred = mdadata3(ypred, wayNames, wayFullNames, dimNames, name);
            ypred.wayValuesAll{1} = X.rowValuesAll;
            ypred.excluderows(X.excludedRows);
            res = mlrres(ypred, yref);
         end   
      end
      
      function res = crossval(obj, oX, oy, varargin)
      % 'crossval' cross-validation of MLR model
      
         X = copy(oX);
         y = copy(oy);
         
         nResp = 1;
         nComp = 1;

         % remove excluded rows from datast
         excludedRows = find(X.excludedRows);
         X.includerows(excludedRows);
         X.removerows(excludedRows);
         y.includerows(excludedRows);
         y.removerows(excludedRows);
         
         nObj = X.nRows;
         nPred = X.nCols;
         
         % get matrix with indices for cv segments
         idx = mdacrossval(nObj, obj.cv);
         [nSeg, seglen, nRep] = size(idx);
      
         ycv = zeros(nObj, 1, 1);  
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
                  
                  prep = {copy(obj.prep{1}) copy(obj.prep{1})};
                  m = mdamlr.cvfit(Xcal, ycal, prep);
                  res = mdamlr.cvpred(Xval, yval, m);
                  
                  jkcoeffs(:, :, :, iSeg) = jkcoeffs(:, :, :, iSeg) + m.coeffs;
                  ycv(vind, :, :) = ycv(vind, :, :) + res.ycv;
               end
            end
         end
         
         ycv = ycv / nRep;
         jkcoeffs = jkcoeffs / nRep;
         
         wayNames = {X.rowNames, y.colNames, {'x'}};
         wayFullNames = {X.rowFullNames, y.colFullNames, {'x'}};
         dimNames = {X.dimNames{1}, 'Responses', ''};
         name = 'Predicted values';
         ycv = mdadata3(ycv, wayNames, wayFullNames, dimNames, name);
         ycv.wayValuesAll{1} = X.rowValues;
         
         res.res = mlrres(ycv, y);
         res.jkcoeffs = jkcoeffs;
      end
      
      function plot(obj)
         subplot(1, 2, 1)
         plotpredictions(obj);
         subplot(1, 2, 2)
         plotregcoeffs(obj);
      end   
   end
   
   methods (Static = true)
      m = cvfit(X, y, prep);
      res = cvpred(X, y, m);
   end   
end   