classdef regres < handle
   
   properties 
      info
   end
   
   properties (SetAccess = 'protected')
      yref      
      stat
   end
      
   properties (SetAccess = 'protected', Hidden = true)
      ypred_
   end
   
	properties (Dependent = true, Hidden = true)
      nResp
      nComp
      nPred
	end
   
   methods
      function obj = regres(ypred, yref, stat)
         if nargin < 2
            yref = [];
         end
         
         if nargin < 3
            stat = [];
         end
         
         obj.yref = yref;
         obj.ypred_ = ypred;
         
         if isempty(stat) && ~isempty(yref)
            obj.getStat();
         end   
      end
      
      function out = ypred(obj, varargin)
        out = obj.ypred_(varargin{:}).values;
      end
      
      function out = get.nPred(obj)
         out = size(obj.ypred_, 1);
      end
      
      function out = get.nResp(obj)
         out = size(obj.ypred_, 2);
      end
      
      function out = get.nComp(obj)
         out = size(obj.ypred_, 3);
      end
      
      function getStat(obj)
         if isempty(obj.yref) || size(obj.yref, 1) < 2
            return;
         end   
         
         nComp = obj.nComp;
         nResp = obj.nResp;
         
         
         ypred = obj.ypred_.values_(~obj.ypred_.excludedRows, :, :);
         yref = obj.yref.values;
         rmse = zeros(nComp, nResp);
         bias = zeros(nComp, nResp);
         slope = zeros(nComp, nResp);
         r2 = zeros(nComp, nResp);
         
         for i = 1:nResp
            y = squeeze(ypred(:, i, :));
            rmse(:, i) = regres.rmse(y, yref);
            bias(:, i) = regres.bias(y, yref);
            slope(:, i) = regres.slope(y, yref);
            r2(:, i) = regres.r2(y, yref);
         end
         
         sep = sqrt(rmse.^2 - bias.^2);
         rpd = std(yref)./sep;
         
         dimNames = {'', ''};
         rowNames = obj.ypred_.wayNames{3};
         colNames = obj.ypred_.wayNames{2};
         if nResp > 1
            dimNames{2} = 'Responses';
         end
         
         if nComp > 1
            dimNames{2} = 'Components';
         else
            rowNames = {};
         end
         
         obj.stat.rmse = mdadata(rmse, rowNames, colNames, dimNames, 'RMSE');
         obj.stat.bias = mdadata(bias, rowNames, colNames, dimNames, 'Bias');         
         obj.stat.slope = mdadata(slope, rowNames, colNames, dimNames, 'Slope');
         obj.stat.r2 = mdadata(r2, rowNames, colNames, dimNames, 'R2');         
         obj.stat.rpd = mdadata(rpd, rowNames, colNames, dimNames, 'RPD');
      end   
      
      function varargout = size(obj, varargin)
         if nargout == 1
            varargout{1} = size(obj.ypred, varargin{:});
         elseif nargout == 3
            [nr, nc, ns] = size(obj.ypred, varargin{:});   
            varargout{1} = nr;
            varargout{2} = nc;
            varargout{3} = ns;
         else
            error('Wrong number of output arguments!');
         end   
      end         
      
      function plot(obj, nresp, ncomp, varargin)
        if nargin < 2
            nresp = 1;
        end
        
        if nargin < 3
            ncomp = obj.nComp;
        end
        
        if numel(ncomp) ~= 1 || numel(nresp) ~= 1
            error('Specify response variable and number of components to show the plot for!')
        end
        
        if obj.nComp > 1 && ~isempty(obj.stat)
            subplot(1, 2, 1)
            plotpredictions(obj, nresp, ncomp, varargin{:});
            subplot(1, 2, 2)
            plotrmse(obj, nresp, varargin{:});
        else 
            plotpredictions(obj, nresp, ncomp, varargin{:});
        end
      end
      
      function summary(obj, nresp)
         if nargin < 2
             nresp = 1:obj.nResp;
         end
         
         if ~isempty(obj.stat)
         
            for iResp = nresp
               rmse = obj.stat.rmse(:, iResp);
               rmse.colNames = {'RMSE'};
               
               bias = obj.stat.bias(:, iResp);
               bias.colNames = {'Bias'};
               
               slope = obj.stat.slope(:, iResp);
               slope.colNames = {'Slope'};
               
               r2 = obj.stat.r2(:, iResp);
               r2.colNames = {'R2'};
               
               rpd = obj.stat.rpd(:, iResp);
               rpd.colNames = {'RPD'};
               
               out = [rmse bias slope r2 rpd];
               out.dimNames = {'', ''};
               out.name = ['Prediction performance for ' obj.ypred_.wayFullNames{2}{iResp}];
               
               if ~isempty(obj.info)
                  fprintf('\n%s', obj.info);
               end   
               show(out);
            end   
         end
      end   
      
   end
   
   methods (Static = true)
      function out = rmse(y, yref)
         out = bsxfun(@minus, y, yref);
         out = squeeze(sum(out.^2));
         out = sqrt(out / (size(y, 1) - 1));
      end
      
      function out = bias(y, yref)
         out = mean(bsxfun(@minus, y, yref))';
      end
      
      function out = slope(y, yref)
         out = zeros(size(y, 2), 1);
         for i = size(y, 2)
            p = polyfit(yref, y(:, i), 1);
            out(i, :) = p(1);
         end   
      end
      
      function out = r2(y, yref)
         out = mdacorr([yref, y]).^2;
         out = out(1, 2:end);
      end      
      
      function[nresp, ncomp, varargin] = getPlotParams(nResp, nComp, varargin)
         if (numel(varargin) == 1 && isnumeric(varargin{1})) || ... 
               (numel(varargin) > 1 && isnumeric(varargin{1}) && ~isnumeric(varargin{2}))
         % only one value is specified, assuming the other is single   
            n = varargin{1};
            varargin(1) = [];
            if nResp == 1
               nresp = 1;
               ncomp = n;
            elseif nComp == 1
               nresp = n;
               ncomp = 1;
            else
               error('Specify response variable and number of components to show the plot for');
            end   
         elseif numel(varargin) > 1 && isnumeric(varargin{1}) && isnumeric(varargin{2})
         % both values are provided   
            nresp = varargin{1};
            ncomp = varargin{2};
            varargin(1:2) = [];
            if nresp < 1 || nresp > nResp
               error('Wrong value for response variable number!');
            end
            if ncomp <1 || ncomp > nComp
               error('Wrong value for number of components!');
            end   
         else
         % no values are provided, using defaults
            nresp = 1;
            ncomp = nComp;
         end   
       end
   end   
end

