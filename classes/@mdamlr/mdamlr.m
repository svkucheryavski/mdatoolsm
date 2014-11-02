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
         wayNames = {X.colNamesAll(~X.factorCols), y.colNamesAll(~y.factorCols), {'x'}};
         wayFullNames = {X.colFullNamesAll(~X.factorCols), y.colFullNamesAll(~y.factorCols), {'x'}};
         dimNames = {X.dimNames{2}, 'Responses', ''};
         name = 'Regression coefficients';
         
         b = mdadata3(b, wayNames, wayFullNames, dimNames, name);
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
            wayNames = {X.rowNamesAll, yref.colNames, {'x'}};
            wayFullNames = {X.rowFullNamesAll, yref.colFullNamesAll, {'x'}};
            dimNames = {X.dimNames{1}, 'Responses', ''};
            name = 'Predicted values';
            
            ypred = mdadata3(ypred, wayNames, wayFullNames, dimNames, name);
            ypred.excluderows(X.excludedRows);
            res = mlrres(ypred, yref);
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
         nPred = X.nCols;
         
         % get matrix with indices for cv segments
         idx = mdacrossval(nObj, obj.cv);
         [nSeg, seglen, nRep] = size(idx);
      
         ycv = zeros(nObj, 1, 1);  
         
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
                  
                  prep = {copy(obj.prep{1}) copy(obj.prep{1})};
                  m = mdamlr(Xcal, ycal, 'Prep', prep, 'Scale', 'off', 'Center', 'off');
                  res = m.predict(Xval, yval, true);
                  
                  ycv(vind, :, :) = ycv(vind, :, :) + res;
               end
            end
         end
         
         ycv = ycv ./ nRep;
         
         wayNames = {X.rowNames, y.colNames, {'x'}};
         wayFullNames = {X.rowFullNames, y.colFullNames, {'x'}};
         dimNames = {X.dimNames{1}, 'Responses', ''};
         name = 'Predicted values';
         ycv = mdadata3(ycv, wayNames, wayFullNames, dimNames, name);
         cvres = mlrres(ycv, y);
      end
      
      function plot(obj)
         subplot(1, 2, 1)
         plotpredictions(obj);
         subplot(1, 2, 2)
         plotregcoeffs(obj);
      end   
   end
end   