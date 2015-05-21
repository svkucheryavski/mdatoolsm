classdef mdapca < handle
% 'mdapca' is a class for Principal Component Analysis (PCA) model.
%
%  m = mdapca(data);
%  m = mdapca(data, 10);
%  m = mdapca(data, 10, {'random', 4, 4});
%  
%  m = mdapca(..., 'ParamName', ParamValue);
%
%
% The 'mdapca' class allows to calibrate a PCA model and validate it with 
% test set or cross-validation, and apply the model to a new data easily.
%
% By default number of components is calculated automatically is
% maximum possible, but you can specify the exact number as the
% second argument when create an 'mdapca' object.
%
% The optional third argument is a cell array with cross-validation
% parameters. It can be '{"full"}' for full cross-validation,
% '{"rand", nseg, nrep}' cross-validation with random splits to
% 'nseg' segments and 'nrep' repetitions and {'ven', nseg} systematic
% cross-validation with "venetian blinds split.
%
% Additional parameters include:
%
%  "Center" - center or not the data before calibrating model or
%  apply the calibrated model to a new data. Possible values are "on"
%  (default) and "off".
%
%  "Scale" - standardize or not data before calibrating model or
%  apply the calibrated model to a new data. Possible values are "on"
%  and "off" (default).
%
%  "Prep" - a preprocessing object, set of preprocessing methods and
%  their parameters which will be used every time the model is
%  applied for a new data.
%
%  "TestSet" - an 'mdadata' object for test set validation.
%
%  "Alpha" - significance level for calculation of statistical limits
%  for T2 and Q2 residuals (default 0.05).
%
%  "Method" - which method to use for calculation of principal
%  components. Default value is "svd" (Singular Value Decomposition),
%  later more methods will be available.
%
%
% Properties (general):
% ---------------------
% Most of the properties are represented by 'mdadata' objects.
%
%  'info' - information about the model
%  'nComp' - number of calculated components
%  'loadings' - dataset with loadings values
%  'eigenvalues' - vector with eigenvalues for the calculated components
%  'prep' - object with preprocessing methods
%  'cv' - cell array with cross-validation parameters
%  'limits' - dataset with statistical limits for residuals
%  'alpha' - significance level for statistical limits
%
% Properties (results):
% ---------------------
% Any 'mdapca' object has three types of results: for calibration
% set, cross-validation and test set validation. The validation
% results are set up only if a proper validation method was used. The
% PCA results are represented as a specific object of class 'pcares'
% and contain all information, including scores, residuals, variance
% and so on.
%
%  'calres' - object with calibration results
%  'cvres' - object with cross-validation results
%  'testres' - object with test set validation results
%
%
% Examples:
% ---------
%
%   load people
%   m = mdapca(people, 10, {'rand', 8, 2}, 'Scale', 'on');
%   sumamry(m)
%   plot(m)
%
%   plotscores(m, [1 3], 'Labels', 'names')
%   plotloadings(m, [1 3], 'Type', 'line')
%
%
% Methods:
% --------
%  'predict' - applies a PCA model to a new data.
%  'summary' - prints summary about the model.
%  'plot' - shows four plots for the model and main results.
%  'plotscores' - shows the scores plot.
%  'plotloadings' - shows the loadings plot.
%  'plotresiduals' - shows residuals plot.
%  'plotexpvar' - shows explained variance plot.
%  'plotcumexpvar' - shows cumulative explained variance plot.
%


   properties 
      info
   end  
   
   properties (Access = 'private')
      MAX_NCOMP = 20;
      METHODS = {'svd', 'nipals', 'ica'};
   end
      
   properties (SetAccess = 'protected')
      nComp
      loadings     
      eigenvalues
      prep
      alpha = 0.05
      cv
      calres
      cvres
      testres      
      limits
      method
   end
   
   properties (SetAccess = 'protected', Hidden = true)
      tnorm
   end
   
   methods
      
      function obj = mdapca(data, varargin)
      
         % set options, calibrate model and get results for calibration set
         obj.setOptions(data, varargin{:});         
         obj.fit(data); 
         
         % check if test set is provided and apply model to the test set
         v = getarg(varargin, 'TestSet');
         if ~isempty(v) 
            if ~isa(v, 'mdadata')
               error('Test set should be an object of class "mdadata"!')
            end   
            obj.testres = obj.predict(v);
            obj.testres.info = 'Results for test set';
         end
         
         % check if cross-validation is needed and run the cv
         if ~isempty(obj.cv) 
            obj.cvres = obj.crossval(data, varargin{:});
            obj.cvres.info = 'Results for cross-validation';
         end         
      end
      
      function set.info(obj, value)
         if ~ischar(value)
            error('Parameter "info" should have a text value!');
         end
         obj.info = value;
      end
      
      function setOptions(obj, data, varargin)
         % set up number of components
         if numel(varargin) > 0 && isnumeric(varargin{1})
            nc = varargin{1};
            varargin(1) = [];
         else
            nc = 999;
         end
         obj.nComp = min([nc, obj.MAX_NCOMP, data.nRows - 1, data.nNumCols]);
         
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
            if ~isa(v, 'prep')
               error('Parameter PREP should be an object of preprocessing class!'); 
            else
               obj.prep = v.copy();
            end   
         else
            obj.prep = prep();
         end   

         % add centering if it is not disable by user
         v = getarg(varargin, 'Center');
         if isempty(v) || strcmp(v, 'on')
            obj.prep.add('center');
         end   
         
         % add scaling if it was asked for
         v = getarg(varargin, 'Scale');
         if ~isempty(v) && strcmp(v, 'on')
            obj.prep.add('scale');
         end   
         
         % which PCA algorithm to use?
         v = getarg(varargin, 'Method');
         if isempty(v)
            obj.method = 'svd';
         else
            if ~find(strcmp(obj.METHODS, v), 1)
               error('Invalid value for parameter "Method"!');
            else
               obj.method = v;
            end   
         end   
         
         % alpha for statistical limits
         v = getarg(varargin, 'Alpha');
         if isempty(v)
            obj.alpha = 0.05;
         else
            if v <= 0 || v >= 1
               error('Invalid value for parameter "Alpha" (must be between 0 and 1)!');
            else
               obj.alpha = v;
            end   
         end            
      end   
            
      function fit(obj, odata)         
      % calibrate PCA model
         data = copy(odata);
         excludedCols = data.excludedCols(~data.factorCols);
         
         obj.prep.apply(data);
      
         loads = zeros(data.nNumColsAll, obj.nComp);
         
         switch obj.method
            case 'svd'
               [loads(~excludedCols, :), eigenvals] = mdapca.pcasvd(data.numValues, obj.nComp);
            case 'ica'
               [loads(~excludedCols, :), eigenvals] = mdapca.pcaica(data.numValues, obj.nComp);               
            otherwise
               error('Unknown name for PCA algorithm: %s', obj.method);
         end
         
         compnames = textgen('Comp ', 1:obj.nComp);         
         
         obj.loadings = mdadata(loads, data.colNamesAll(~data.factorCols), compnames);
         obj.loadings.dimNames = {data.dimNames{2}, 'Components'};
         obj.loadings.rowFullNames = data.colFullNamesAll(~data.factorCols);
         obj.loadings.colFullNames = compnames;
         obj.loadings.name = 'Loadings';
         obj.loadings.excluderows(excludedCols);
         
         obj.eigenvalues = mdadata(eigenvals, compnames, {'Eigenvalues'}, {'Components', ''});
         obj.eigenvalues.name = 'Eugenvalues';
         
         % we do not need calibration results and limits for CV
         obj.calres = predict(obj, data, false);
         obj.calres.info = 'Results for calibration set';
         obj.limits = ldecomp.getResLimits(data, obj);
         obj.tnorm = obj.calres.tnorm;
      end   
      
      function out = predict(obj, odata, doPrep)
      % 'predict'   
         data = copy(odata);
         if nargin < 3
            doPrep = true;
         end
         
         if isa(data, 'mdaimage')
            isImage = true;
            width = data.width;
            height = data.height;
         else
            isImage = false;
         end
                  
         if doPrep == true
            obj.prep.apply(data);
         end   
         
         scores = data.numValuesAll * obj.loadings.values;
         
         if isImage            
            scores = reshape(scores, height, width, obj.loadings.nCols);
            scores = mdaimage(scores, obj.loadings.colNames);
         else   
            scores = mdadata(scores, data.rowNamesAll, obj.loadings.colNames);
            scores.rowFullNames = data.rowFullNamesAll;
         end
         
         scores.dimNames = {data.dimNames{1}, obj.loadings.dimNames{2}};
         scores.colFullNames = obj.loadings.colFullNames;
         scores.name = 'Scores';
         scores.excluderows(data.excludedRows);
         
         out = pcares(scores, obj.loadings, data, obj.tnorm);            
      end 
      
      function cvres = crossval(obj, data, varargin)
      % 'crossval' cross-validation of PCA model
         nObj = data.nRows;
         nVar = data.nCols;
         
         % get matrix with indices for cv segments
         idx = mdacrossval(nObj, obj.cv);
         [nSeg, seglen, nRep] = size(idx);
      
         Q2 = zeros(nObj, obj.nComp);  
         T2 = zeros(nObj, obj.nComp);   
         
         nComp = min([obj.nComp, nObj - seglen - 1, nVar]);
         % loop over repetitions and segments
         for iRep = 1:nRep
            for iSeg = 1:nSeg
               % get logical indices for validation subset
               ind = idx(iSeg, :, iRep);
               ind(isnan(ind)) = [];
               
               if numel(ind) > 0
                  vind = false(nObj, 1);
                  vind(ind) = true;   
            
                  cal = data(~vind, :);
                  val = data(vind, :);
                  m = mdapca(cal, nComp, 'Prep', obj.prep, 'Scale', 'off', 'Center', 'off');
                  res = m.predict(val);
                  
                  Q2(vind, :) = Q2(vind, :) + res.Q2.values;
                  T2(vind, :) = T2(vind, :) + res.T2.values;
               end
            end
         end
         
         Q2 = Q2 ./ nRep;
         T2 = T2 ./ nRep;
         
         T2 = mdadata(T2, data.rowNames, obj.loadings.colNames, obj.calres.scores.dimNames);
         T2.name = 'T2 residuals';
         T2.rowFullNames = obj.calres.scores.rowFullNames;
         T2.colFullNames = obj.calres.scores.colFullNames;

         Q2 = mdadata(Q2, T2.rowNames, T2.colNames, T2.dimNames, 'Q2 residuals');
         Q2.rowFullNames = T2.rowFullNamesAll;
         Q2.colFullNames = T2.colFullNamesAll;
         
         % in CV results there are no scores only residuals and variances
         cvres = pcares([], [], [], obj.calres.tnorm, obj.calres.totvar, Q2, T2, []);
      end
      
      function summary(obj)
      % 'summary' shows summery of PCA model   
         
         out = [obj.eigenvalues obj.calres.variance];
         
         if ~isempty(obj.cvres) && isa(obj.cvres, 'pcares')
            var = obj.cvres.variance(:, :);
            var.colNames = {'ExpvarCV', 'CumexpvarCV'};
            var.colFullNames = {'Expvar (CV)', 'Cumexpvar (CV)'};
            out = [out var];
         end
         
         if ~isempty(obj.testres) && isa(obj.testres, 'pcares')
            var = obj.testres.variance(:, :);
            var.colNames = {'ExpvarTest', 'CumexpvarTest'};
            var.colFullNames = {'Expvar (Test)', 'Cumexpvar (Test)'};
            out = [out var];
         end
         
         if ~isempty(obj.info)
            fprintf('\n\n%s', obj.info);
         end
         
         show(out);
      end
            
      function plot(obj, comp, varargin)
         
         if nargin < 2
            comp = [1 2];
         end
         
         v = getarg(varargin, 'Labels');
         
         sargs = {};
         largs = {};
         if isempty(v) 
            if obj.calres.scores.nRows < 150
               sargs = {'Labels', 'names'};
            end
            
            if obj.loadings.nRows < 150
               largs = {'Labels', 'names'};
            end
         else
            sargs = {'Labels', v};
            largs = {'Labels', v};
         end   
         
         subplot(2, 2, 1)
         plotscores(obj, comp, sargs{:});
         subplot(2, 2, 2)
         plotloadings(obj, comp, largs{:});
         subplot(2, 2, 3)
         plotresiduals(obj, sargs{:});
         subplot(2, 2, 4)
         plotcumexpvar(obj);
      end   
   end
   
   methods (Static = true)
      function [loadings, eigenvals] = pcaica(x, nComp)
         eps = 1e-4; 
         maxIters = 100; 

         [m, ~] = size(x);

         % generate random weights 
         w = rand(nComp, m);
         for i = 1:nComp
            w(i, :) = w(i, :) / norm(w(i, :));
         end

         err = ones(nComp, 1);
         its = 0;

         while ((max(err) > eps) && (its < maxIters))
            its = its + 1;
            w_old = w;
    
            for i = 1:nComp
               si = w_old(i, :) * x;
        
               g = si .* exp(-0.5 * (si.^2));
               gp = -1.0 * ((si.^2) .* exp(-0.5 * (si.^2)));
        
               w(i, :) = mean(x .* repmat(g, m, 1), 2)' - mean(gp) * w_old(i, :);       
               w(i,:) = w(i,:) / norm(w(i,:));
            end
    
            [u, s, ~] = svd(w, 'econ');
            sinv = diag(1./diag(s));
            w = u * sinv * u' * w;
    
            for i = 1:nComp
               err(i) = 1 - w(i,:) * w_old(i,:)';
            end
         end   
         loadings = (w * x)';      
         eigenvals = zeros(nComp, 1);
      end
      
      function [loadings, eigenvals] = pcasvd(x, nComp)
         if nargin < 2 
            nComp = min([size(x, 1) - 1, size(x, 2), pca.MAX_NCOMP]);
         else   
            nComp = min([size(x, 1) - 1, size(x, 2), nComp]);
         end

         if nComp < 1
            error('Number of components should be above zero!')
         end   

         [~, s, v] = svd(x, 0);

         loadings = v(:, 1:nComp);      
         eigenvals = (diag(s).^2)/(size(x, 1) - 1);
         eigenvals = eigenvals(1:nComp);
      end
   end   
end

