classdef regmodel < handle
   
   properties 
      info
   end
   
   properties (SetAccess = 'protected')
      prep
      cv
      regcoeffs
      calres
      cvres
      testres
      nComp
   end
   
   properties (Dependent = true, Hidden = true)
      nResp
      nPred
   end
   
   methods
      
      function obj = regmodel(X, y, ncomp, varargin)
         
         if nargin < 3
            obj.nComp = min([X.nRows - 1, X.nCols]);
         else
            obj.nComp = min([X.nRows - 1, X.nCols, ncomp]);
         end
         
         if nargin < 2 
            error('Specify vector of response (y) values!');
         elseif ~(isnumeric(y) || isa(y, 'mdadata'))
            error('Response values should be a vector with numbers of an object of "mdadata" class"');
         elseif ~isa(y, 'mdadata')
            y = mdadata(y);
         end   
         
         if nargin < 1 
            error('Specify matrix with predictor (X) values!');
         elseif ~(isnumeric(X) || isa(X, 'mdadata'))
            error('Predictors should be a matrix with numbers of an object of "mdadata" class"');
         elseif ~isa(X, 'mdadata')
            X = mdadata(X);
         end   
         
         if X.nRows ~= y.nRows
            error('Number of rows in predictors and response matrices should be the same!')
         end
         
         obj.setOptions(varargin{:});
         obj.fit(X, y);
         obj.calres = obj.predict(X, y);
         obj.calres.info = 'Results for calibration set';
         
         % check if test set is provided and apply model to the test set
         v = getarg(varargin, 'TestSet');
         if ~isempty(v) 
            if ~iscell(v) || numel(v) ~= 2
               error('Test set should be a cell with two datasets (X and Y)!')
            end   
            obj.testres = obj.predict(v{1}, v{2});
            obj.testres.info = 'Results for test set';
         end
         
         % check if cross-validation is needed and run the cv
         if ~isempty(obj.cv) 
            obj.cvres = obj.crossval(X, y, varargin{:});
            obj.cvres.info = 'Results for cross-validation';
         end         
         
      end
      
      function set.info(obj, value)
         if ~ischar(value)
            error('Parameter "info" should have a text value!');
         end
         obj.info = value;
      end
      
      function setOptions(obj, varargin)
         
         % set up number cross-validation
         [v, varargin] = getarg(varargin, 'CV');
         if ~isempty(v)
            if ~iscell(v)
               error('Cross-validation parameters should be passed as a cell array!');
            end   
            obj.cv = v;
         else
            obj.cv = [];
         end
         
         % set up preprocessing
         v = getarg(varargin, 'Prep');
         if ~isempty(v)
            if ~isa(v{1}, 'prep') || ~isa(v{2}, 'prep')
               error('Parameter PREP should be an object of preprocessing class!'); 
            else
               obj.prep = {v{1}.copy() v{2}.copy()};
            end   
         else
            obj.prep{1} = prep();
            obj.prep{2} = prep();
         end   
         
         % add centering if it is not disable by user
         v = getarg(varargin, 'Center');
         if isempty(v) || strcmp(v, 'on')
            obj.prep{1}.add('center');
            obj.prep{2}.add('center');
         end   
         
         % add scaling if it was asked for
         v = getarg(varargin, 'Scale');
         if ~isempty(v) && strcmp(v, 'on')
            obj.prep{1}.add('scale');
            obj.prep{2}.add('scale');
         end   
         
      end   
      
%       function out = get.nComp(obj)
%          if isempty(obj.regcoeffs)
%             out = 0;
%          else
%             out = obj.regcoeffs.nComp;
%          end
%       end
      
      function out = get.nPred(obj)
         if isempty(obj.regcoeffs)
            out = 0;
         else
            out = obj.regcoeffs.nPred;
         end
      end
      
      function out = get.nResp(obj)
         if isempty(obj.regcoeffs)
            out = 0;
         else
            out = obj.regcoeffs.nResp;
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
end

