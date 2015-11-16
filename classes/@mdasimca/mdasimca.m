classdef mdasimca < mdapca & classmodel
% 'mdaplsda' creates and manipulates
%
%
   properties (SetAccess = 'protected')
      className
   end
   
   methods
      function obj = mdasimca(X, className, ncomp, varargin)

         if ~ischar(className)
            error('Parameter "className" should have a text value!')
         end
         
         % prepare reference values for calibration set
         cref = ones(X.nRowsAll, 1);
         cref = mdadata(cref, X.rowNamesAll, {className}, {'Objects', 'Class'});
         cref.excluderows(X.excludedRows);
         cref.factor(1, {className});

         % check if test set is provided and process it properly
         [test, varargin] = getarg(varargin, 'TestSet');
         if ~isempty(test) 
            if ~iscell(test) || numel(test) ~= 2
               error('Test set should be a cell with two datasets (X and c)!')
            end   
            Xtest = test{1};
            ctest = test{2};
            varargin = {varargin{:}, 'TestSet', Xtest};
         end
         
         obj = obj@mdapca(X, ncomp, varargin{:});   
         obj.className = className;
         lim = obj.limits.valuesAll;
         
         cpred = mdasimca.classify(obj.calres, lim, obj.className);
         obj.calres = simcares(obj.calres, cpred, cref);
         obj.calres.info = 'Results for calibration set';
                           
         if ~isempty(obj.cvres)
            cpred = mdasimca.classify(obj.cvres, lim, obj.className);
            obj.cvres = simcares(obj.cvres, cpred, cref);
            obj.cvres.info = 'Results for cross-validation';
         end   
                  
         if ~isempty(obj.testres)
            cpred = mdasimca.classify(obj.testres, lim, obj.className);
            ctest = classmodel.getClassFromFactor(ctest, obj.className);
            obj.testres = simcares(obj.testres, cpred, ctest);
            obj.testres.info = 'Results for test set';
         end
      end   
            
      function res = predict(obj, X, cref)
                                          
         st = dbstack(1);
         if numel(st) > 0 && strcmp(st(1).name, 'mdapca.fit')
            % in this case cref is doPrep for PCA
            res = predict@mdapca(obj, X, cref);
            return;                        
         end
         
         if nargin < 3
            cref = [];
         else
            cref = classmodel.convertClasses(cref, obj.className);
         end   

         if ~isempty(cref) 
            if cref.nCols ~= 1
               error('Class reference should be a dataset with one column!');
            elseif ~isfactor(cref, 1)
               error('Class reference should be a factor!');
            else
               cref = classmodel.getClassFromFactor(cref, obj.className);
            end   
         end 
         
         res = predict@mdapca(obj, X);
         cpred = mdasimca.classify(res, obj.limits.valuesAll, obj.className);
         res = simcares(res, cpred, cref);
      end 
            
      function plot(obj, comp, varargin)
         
         if nargin < 2
            if obj.nComp > 1
               comp = [1 2];
            else
               comp = 1;
            end   
         end
         
         v = getarg(varargin, 'Labels');
         
         sargs = {};
         if isempty(v) 
            if obj.calres.scores.nRows < 150
               sargs = {'Labels', 'names'};
            end            
         else
            sargs = {'Labels', v};
         end   
         
         subplot(2, 2, 1)
         plotscores(obj, comp, sargs{:});
         subplot(2, 2, 2)
         plotresiduals(obj, sargs{:});
         subplot(2, 2, 3)
         plotcumexpvar(obj);
         subplot(2, 2, 4)
         if ~isempty(obj.cvres)
            plotclassification(obj.cvres, obj.nComp, varargin{:});
            title('Classification for cross-validation')
         elseif ~isempty(obj.testres)
            plotclassification(obj.testres, obj.nComp, varargin{:});
            title('Classification for test set')
         else
            plotclassification(obj.calres, obj.nComp, varargin{:});
            title('Classification for calibration set')
         end   
      end   
      
      function summary(obj, varargin)
         summary(obj.calres)
         
         if ~isempty(obj.cvres)
            summary(obj.cvres);
         end
         
         if ~isempty(obj.testres)
            summary(obj.testres);
         end
         
      end   
      
   end
   
   methods (Static = true)
      function cpred = classify(res, lim, className)
         nComp = res.Q.nCols;
         cpred = zeros(res.Q.nRowsAll, 1, nComp);
   
         for i = 1:nComp
            cpred(:, 1, i) = res.T2.valuesAll(:, i) <= lim(1, i) & res.Q.valuesAll(:, i) <= lim(2, i);
         end   
         cpred = cpred * 2 - 1;
         
         wayNamesAll = {res.Q.rowNamesAll, {className}, res.Q.colNamesAll};
         wayFullNamesAll = {res.Q.rowFullNamesAll, {className}, res.Q.colFullNamesAll};
         dimNames = {res.Q.dimNames{1}, {className}, res.Q.dimNames{2}};
         
         cpred = mdadata3(cpred, wayNamesAll, wayFullNamesAll, dimNames);
         cpred.excluderows(res.Q.excludedRows);
      end
   end   
end   