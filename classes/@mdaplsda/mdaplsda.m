classdef mdaplsda < mdapls & classmodel
% 'mdaplsda' creates and manipulates
%
%
   properties (SetAccess = 'protected')
      className
   end
   
   methods
      function obj = mdaplsda(X, c, className, ncomp, varargin)
         
         if X.nRows ~= c.nRows
            error('Number of rows in "X" ad "c" variables must be the same!')
         end
                  
         if c.nCols ~= 1 || ~isfactor(c, 1)
            error('Class variable should be a dataset with one factor column!')
         end   
         
         c = classmodel.getClassFromFactor(c, className);
         y = splitfactor(c, 1);         
         y = y(:, className);
         
         % check if test set is provided and apply model to the test set
         [test, varargin] = getarg(varargin, 'TestSet');
         if ~isempty(test) 
            if ~iscell(test) || numel(test) ~= 2
               error('Test set should be a cell with two datasets (X and Y)!')
            end   
            Xtest = test{1};
            ctest = test{2};
            ytest = splitfactor(ctest, 1);
            ytest = ytest(:, className);
            varargin = {varargin{:}, 'TestSet', {Xtest, ytest}};
         end
         
         obj = obj@mdapls(X, y, ncomp, varargin{:});   
         obj.className = className;
         obj.calres = predict(obj, X, c);
         obj.calres.info = 'Results for calibration set';
         
         if ~isempty(obj.cvres)
            cvres.xdecomp = obj.cvres.xdecomp;
            cvres.ydecomp = obj.cvres.ydecomp;
            cvres.ypred = obj.cvres.ypred_;
            cvres.yref = obj.cvres.yref;
            
            cpred = mdaplsda.classify(cvres.ypred);
            obj.cvres = plsdares(cvres, cpred, c);
            obj.cvres.info = 'Results for cross-validation';
         end   
                  
         if ~isempty(obj.testres)
            cpred = mdaplsda.classify(obj.testres.ypred);
            ctest = classmodel.getClassFromFactor(ctest, obj.className);
            obj.testres = plsdares(obj.testres, cpred, ctest);
            obj.testres.info = 'Results for test set';
         end
      end   
            
      function res = predict(obj, X, cref, makeres)
         
         if nargin < 3
            cref = [];
         end   
         
         if nargin < 4
            makeres = false;
         end
               
         st = dbstack(1);
         if strcmp(st(1).name, 'regmodel.regmodel')
            res = predict@mdapls(obj, X, cref, makeres);
            return;                        
         end
         
         if ~isempty(cref) && cref.nCols ~= 1
            error('Class reference should be a dataset with one column!');
         elseif ~isfactor(cref, 1)
            error('Class reference should be a factor!');
         end
                  
         if isempty(cref)
            yref = [];
         else
            cref = classmodel.getClassFromFactor(cref, obj.className);
            yref = splitfactor(cref, 1);
            yref = yref(:, obj.className);
         end 
         
         res = predict@mdapls(obj, X, yref, makeres);
         cpred = mdaplsda.classify(res.ypred);
         res = plsdares(res, cpred, cref);
      end 
            
      
      function plot(obj, varargin)
         [nresp, ncomp, varargin] = regres.getRegPlotParams(obj.nResp, obj.nComp, varargin{:});
         subplot(2, 2, 1)
         plotxresiduals(obj, ncomp, varargin{:});
         subplot(2, 2, 2)
         plotregcoeffs(obj, nresp, ncomp, varargin{:});
         subplot(2, 2, 3)
         plotmisclassified(obj, nresp, varargin{:});
         subplot(2, 2, 4)
         if ~isempty(obj.cvres)
            plotclassification(obj.cvres, ncomp, varargin{:});
            title('Classification for cross-validation')
         elseif ~isempty(obj.testres)
            plotclassification(obj.testres, ncomp, varargin{:});
            title('Classification for test set')
         else
            plotclassification(obj.calres, ncomp, varargin{:});
            title('Classification for calibration set')
         end   
      end   
   end
   
   methods (Static = true)
      function cpred = classify(y)
         values = y.values_;
         cpred = -ones(size(values));         
         cpred(values >= 0) = 1;         
         cpred = mdadata3(cpred, y.wayNamesAll, y.wayFullNamesAll, y.dimNames);
         cpred.excluderows(y.excludedRows);
      end
   end   
end   