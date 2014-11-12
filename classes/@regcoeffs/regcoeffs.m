classdef regcoeffs < handle

   properties (SetAccess = 'protected', Hidden = true)
      values_
      pvalues_
      ci_
   end
   
   properties (Dependent = true)
      pvalues
      ci
   end
   
   properties (Dependent = true, Hidden = true)
      nResp
      nPred
      nComp
   end
      
	methods
      
		function obj = regcoeffs(values)         
         obj.values_ = values;
      end
      
      function out = get.pvalues(obj)
         out = obj.values_.values;
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
      
      function out = valuesAll(obj, varargin)
         out = obj.values_(varargin{:}).values_;
      end
      
      function computejkstat(obj, values, alpha)
         [nPred, nComp, nResp, nRep] = size(values);

         t = mdatinv(1 - alpha/2, nRep - 1);

         ciLo = zeros(nPred, nComp, nResp);
         ciUp = zeros(nPred, nComp, nResp);
         pvalues = zeros(nPred, nComp, nResp);
      
         for iResp = 1:nResp
            for iComp = 1:nComp
               v = values(:, iComp, iResp, :);
               m = mean(v);
               ssq = sum(bsxfun(@minus, v, m).^2);
               se = sqrt((nRep - 1)/nRep * ssq);
               
               ciLo(:, iResp, iComp) = [m - t * se, m + t * se];
               ciUp(:, iResp, iComp) = [m - t * se, m + t * se];
               tvals = m/se;
               tmin = min([tvals, -tvals]);
               pvalues(:, iComp, iResp) = 2 * pt(tmin, nobj - 1);
            end
         end
         
         pvalues = mdadata3(pvalues, obj.values.wayNames, obj.values.wayFullNames, obj.values.dimNames);
         pvalues.name = 'P-values for regression coefficients';
         obj.pvalues = pvalues;
         
         ciLo = mdadata3(ciLo, obj.values.wayNames, obj.values.wayFullNames, obj.values.dimNames);
         ciLo.name = 'Confidence intervals (lower) for regression coefficients';
         ciUp = mdadata3(ciUp, obj.values.wayNames, obj.values.wayFullNames, obj.values.dimNames);
         ciUp.name = 'Confidence intervals (upper) for regression coefficients';
         obj.ci = {ciLo, ciUp};
      end
      
      function summary(obj, resp, comp)
         if nargin < 3
            comp = obj.nComp;
         end
         
         if nargin < 2
            resp = 1;
         end
         
         if numel(comp) > 1 || numel(resp) > 1
            error('Specify response and number of components to show the coefficients for!')
         end
         
         v = obj.values_(:, resp, comp).values; 
                  
         if ~isempty(obj.pvalues_)
            p = obj.pvalues_(:, resp, comp).values;
            cil = obj.ci_{1}(:, resp, comp).values;
            ciu = obj.ci_{2}(:, resp, comp).values;
         
            out = [v p cil ciu];
            out.name = 'Summary statistics for regression coefficients';
            show(out);
         else
            disp('Summary statistics is not available.')
         end
         
      end
      
      function varargout = plot(obj, resp, comp, varargin)
         
         if nargin < 3
            comp = obj.nComp;
         end
         
         if nargin < 2
            resp = 1;
         end
         
         if numel(comp) > 1 && numel(resp) > 1
            error('Specify response and number of components to show the coefficients for!')
         end
         
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
         end                  
         
         [showLines, varargin] = getarg(varargin, 'AxisLines');
         if ~isempty(showLines) && strcmp(showLines, 'off')
            showLines = false;
         else
            showLines = true;
         end   
         
         [showCI, varargin] = getarg(varargin, 'CI');
         if (~isempty(showLines) && strcmp(showLines, 'off')) || isempty(obj.ci_)
            showCI = false;
         else
            showCI = true;
         end   
         
         if ~showCI
            if strcmp(type, 'line')
               h = gplot(obj.values(:, resp, comp)', varargin{:}, 'Marker', mr);
            elseif strcmp(type, 'bar')   
               h = gbar(obj.values(:, resp, comp)', varargin{:});
            else
               error('Wrong plot type!');
            end
         else
         end
         
         if numel(comp) == 1 && comp ~= obj.nComp
            title(sprintf('Regression coefficients (ncomp = %d)', comp));
         else
            title('Regression coefficients');
         end   
   
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
