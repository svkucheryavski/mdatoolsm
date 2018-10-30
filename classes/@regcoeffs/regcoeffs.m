classdef regcoeffs < handle
% 'regcoeffs' is a class for storing and manipulation of regression coefficients. 
%
% The object is a universal way to deal with regression coefficients for any linear 
% regression model (e.g. PLS1, PLS2, MLR, etc). Any model has an object 'regcoeffs',
% which is the object of this class and all properties and methods described below can 
% be used with this object. 
%
%
% Properties:
% -----------
%  values - regression coefficient values for given response and number of
%  components.
%
%  pvalues - p-values for t-test if regression coefficient is equal to
%  zero. Available only if cross-validation is used when building a model.
%
%  ci - confidence intervals for regression coefficients. Available only 
%  if cross-validation is used when building a model.
%
%
% Methods:
% --------
%  plot - makes like or bar plot for regression coefficients
%  summary - shows regression coefficient values with statistics
%
%
% Examples:
% ---------
%
%   % make PLS model to predict Height for People data
%   load people
%   X = people(:, 2:12);
%   y = people(:, 1);
%   m = mdapls(X, y, 2, 'Scale', 'on', 'CV', {'full'});
%
%   % show values and statistics with default settings
%   show(m.regcoeffs.values);
%   show(m.regcoeffs.pvalues);
%   show(m.regcoeffs.ci);
%
%   % show the same but for model with one component
%   show(m.regcoeffs.values, 1);
%   show(m.regcoeffs.pvalues, 1);
%   show(m.regcoeffs.ci, 1);
%   
%   % if several responses available, one shall specify response 
%   % by its name or number
%   show(m.regcoeffs.values, 1, 1);
%   show(m.regcoeffs.pvalues, 'Height', 1);
%   show(m.regcoeffs.ci, 'Height', 1);
%
%   % summary works similar way
%   summary(m.regcoeffs);
%   summary(m.regcoeffs, 1);
%   summary(m.regcoeffs, 'Height', 1);
%
%   % regcoeffs plot
%   plot(m.regcoeffs);
%   plot(m.regcoeffs, 1);
%   plot(m.regcoeffs, 1, 'Type', 'bar');
%
%

   properties (SetAccess = 'protected', Hidden = true)
      values_
      pvalues_
      ci_
   end
      
   properties (Dependent = true, Hidden = true)
      nResp
      nPred
      nComp
      respNames
   end
      
	methods
      
		function obj = regcoeffs(values)         
         obj.values_ = values;
      end
      
      function out = get.respNames(obj)
         out = obj.values_.wayNames{2};
      end
      
      function out = get.nPred(obj)
         out = size(obj.values_, 1);
      end
      
      function out = get.nResp(obj)
         out = size(obj.values_, 2);
      end
      
      function out = get.nComp(obj)
         out = size(obj.values_, 3);
      end

      function out = values(obj, varargin)
         if isempty(varargin)
            varargin = {':', obj.nComp};
         end   
         out = obj.values_(varargin{:}).values;
      end
      
      function out = ci(obj, varargin)
         if isempty(obj.ci_)
            disp('Confidence intervals are not available.');
            out = [];
            return
         end   
         
         if isempty(varargin)
            varargin = {':', obj.nComp};
         end
         
         out1 = obj.ci_{1}(varargin{:}).values;
         fnames = out1.colFullNames;
         out1.colNamesAll = strcat(out1.colNames, 'lo');
         out1.colFullNamesAll = strcat(fnames, ' (lo)');
         
         out2 = obj.ci_{2}(varargin{:}).values;
         fnames = out2.colFullNames;
         out2.colNamesAll = strcat(out2.colNames, 'up');
         out2.colFullNamesAll = strcat(fnames, ' (up)');
         
         out = [out1 out2];
         out.name = 'Confidence intervals';
      end
      
      function out = pvalues(obj, varargin)
         if isempty(obj.pvalues_)
            disp('p-values are not available.');
            out = [];
            return
         end   
         
         if isempty(varargin)
            varargin = {':', obj.nComp};
         end   
         out = obj.pvalues_(varargin{:}).values;
      end
      
      function out = valuesAll(obj, varargin)
         out = obj.values_(varargin{:}).values_;
      end
      
      function computejkstat(obj, values, alpha)
         nRep = size(values, 4);

         t = mdatinv(1 - alpha/2, nRep - 1);

         m = mean(values, 4);
         ssq = sum(bsxfun(@minus, values, m).^2, 4);
         se = sqrt((nRep - 1)/nRep * ssq);
         
         ciLo = m - t * se;
         ciUp = m + t * se;

         tvals = m./se;        
         tmin = min(cat(4, tvals, -tvals), [], 4);
         
         pvalues = 2 * mdatcdf(tmin, nRep - 1);
         
         pvalues = mdadata3(pvalues, obj.values_.wayNames, obj.values_.wayFullNames, obj.values_.dimNames);
         pvalues.name = 'P-values for regression coefficients';
         obj.pvalues_ = pvalues;
                  
         ciLo = mdadata3(ciLo, obj.values_.wayNames, obj.values_.wayFullNames, obj.values_.dimNames);
         ciLo.name = 'Confidence intervals (lower) for regression coefficients';
         
         ciUp = mdadata3(ciUp, obj.values_.wayNames, obj.values_.wayFullNames, obj.values_.dimNames);
         ciUp.name = 'Confidence intervals (upper) for regression coefficients';
         obj.ci_ = {ciLo, ciUp};
      end
      
      function summary(obj, varargin)
      % 'summary' shows summary statistics for regression coefficients.   
      %
      %   summary(m.regcoeffs);
      %   summary(m.regcoeffs, ncomp);
      %   summary(m.regcoeffs, resp, ncomp);
      %
      %
      %  Here 'resp' is a number or name of response variable to show the
      %  statistics for (if more than one is used) and 'ncomp' - number of
      %  components.
      %
      
         [resp, comp, varargin] = regres.getRegPlotParams(obj.nResp, obj.nComp, obj.respNames, varargin{:});
         
         v = obj.values_(:, resp, comp).values; 
                  
         if ~isempty(obj.pvalues_)
            p = obj.pvalues(1:end, resp, comp);
            ci = obj.ci(1:end, resp, comp);
         
            out = [ci(:, 1) v  ci(:, 2) p];
            out.name = 'Summary statistics for regression coefficients';
            out.colNames = {'Lo', 'Value', 'Up', 'p-value'};
            out.dimNames = {'', ''};
            show(out);
         else
            disp('Summary statistics is not available.')
         end
         
      end
      
      function varargout = plot(obj, varargin)
         
         [resp, comp, varargin] = regres.getRegPlotParams(obj.nResp, obj.nComp, obj.respNames, varargin{:});
         
         [type, varargin] = getarg(varargin, 'Type');
         if isempty(type)
            if obj.nPred > 12
               type = 'line';
            else
               type = 'bar';
            end   
         end
         
         [mr, varargin] = getarg(varargin, 'Marker');
         if isempty(mr) && obj.nPred < 20
            mr = '.';
         else
            mr = 'none';
         end                  
         
         [showLines, varargin] = getarg(varargin, 'AxisLines');
         if ~isempty(showLines) && strcmp(showLines, 'off')
            showLines = false;
         else
            showLines = true;
         end   
         
         [showCI, varargin] = getarg(varargin, 'CI');
         if isempty(showCI)
            if obj.nPred < 20 && ~isempty(obj.ci_)
               showCI = true;
            else
               showCI = false;
            end
         elseif strcmp(showCI, 'off')
            showCI = false;
         else
            showCI = true;
         end 
         
         values = obj.values(1:end, resp, comp)';
         if strcmp(type, 'line')
            h = plot(values, varargin{:}, 'Marker', mr);
         elseif strcmp(type, 'bar')   
            h = bar(values, varargin{:});
         else
            error('Wrong plot type!');
         end
         
         if showCI && ~isempty(obj.ci_)
            hold on            
            ci = obj.ci(1:end, resp, comp); 
            v = values.values;
            l = v - ci(:, 1).values';
            u = ci(:, 2).values' - v;
            if strcmp(type, 'bar')
               errorbar(1:size(v, 2), v, l, u, '.', 'Color', mdalight(mdadata.getmycolors(1)))
            elseif strcmp(type, 'line')
               plot(1:size(v, 2), v - l, '-', 'Color', mdalight(mdadata.getmycolors(1)))
               plot(1:size(v, 2), v + u, '-', 'Color', mdalight(mdadata.getmycolors(1)))               
            end
            
            hold off
         end
         
         if numel(comp) == 1 && comp ~= obj.nComp
            title(sprintf('Regression coefficients (ncomp = %d)', comp));
         else
            title('Regression coefficients');
         end   
   
         axis auto
                           
         if showLines && strcmp(type, 'line')
            lim = axis();
            line([lim(1) lim(2)], [0 0], 'LineStyle', '--', 'Color', [0.8 0.8 0.8]);
         end
         
         if nargout > 0
            varargout{:} = h;
         end   
      end
      
	end
end
