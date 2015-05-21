classdef regres < res
      
   properties (SetAccess = 'protected')
      yref      
   end
      
   properties (SetAccess = 'protected', Hidden = true)
      ypred_
   end
   
	properties (Dependent = true, Hidden = true)
      nResp
      respNames
   end
   
	properties (Dependent = true, Hidden = true, Access = 'private')
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
      
      function out = get.respNames(obj)
         out = obj.ypred_.wayNames{2};
      end
      
   end

   methods 
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
   end
   methods (Access = 'protected')
      
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
            rmse(:, i) = regres.getRMSE(y, yref(:, i));
            bias(:, i) = regres.getBias(y, yref(:, i));
            slope(:, i) = regres.getSlope(y, yref(:, i));
            r2(:, i) = regres.getR2(y, yref(:, i));
            rpd(:, i) = std(yref(:, i))./sqrt(rmse(:, i).^2 - bias(:, i).^2);
         end

         dimNames = {'', ''};
         rowNames = obj.ypred_.wayNames{3};
         colNames = obj.ypred_.wayNames{2};
         if nResp > 1
            dimNames{2} = 'Responses';
         end
         
         if nComp > 1
            dimNames{1} = 'Components';
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
   end
   
   methods (Static = true)
      function out = getRMSE(y, yref)
         out = bsxfun(@minus, y, yref);
         out = squeeze(sum(out.^2));
         out = sqrt(out / (size(y, 1) - 1));
      end
      
      function out = getBias(y, yref)
         out = mean(bsxfun(@minus, y, yref))';
      end
      
      function out = getSlope(y, yref)
         out = zeros(size(y, 2), 1);
         for i = 1:size(y, 2)
            p = polyfit(yref, y(:, i), 1);
            out(i, :) = p(1);
         end 
      end
      
      function out = getR2(y, yref)
         out = mdacorr([yref, y]).^2;
         out = out(1, 2:end);
      end      
   end
   
   methods (Static = true)
      function [nresp, ncomp, varargin] = getRegPlotParams(nResp, nComp, respNames, varargin)
      % detect response and components if specified by user
      % algorithm:
      %
      % 1. If first value is text, check if the name is among response
      % names. If not, no components and no response are specified. If yes,
      % check second value, if it is numeric, it is number of components.
      %
      % 2. If first value is numeric, check if second value is numeric as
      % well. If not, consider the value as number of components. If yes, 
      % first value is response and second is number of components
      %
      
         nresp = 1;
         ncomp = nComp;
         
         if numel(varargin) == 1
            if iscell(varargin{1}) || ischar(varargin{1})
               % response name is specified
               nresp = ismember(respNames, varargin{1});
               if ~any(nresp)
                  error('Wrong response name!');
               else
                  nresp = find(nresp, 1);
               end   
               varargin(1) = [];
            elseif isnumeric(varargin{1})               
               % numeric value, consider as number of components or (if
               % only one component is used, number of class.
               if nResp == 1
                  ncomp = varargin{1};
               else
                  nresp = varargin{1};
               end   
               varargin(1) = [];
            end   
         elseif numel(varargin) > 1
            if iscell(varargin{1}) || ischar(varargin{1}) 
               ind = ismember(respNames, varargin{1});
               if any(ind)
                  nresp = find(ind, 1);
                  if isnumeric(varargin{2})
                     ncomp = varargin{2};
                     varargin(1:2) = [];
                  else
                     varargin(1) = [];
                  end
               end
            elseif isnumeric(varargin{1}) 
               if ~isnumeric(varargin{2})
                  if nComp == 1
                     nresp = varargin{1};
                  else
                     ncomp = varargin{1};
                  end   
                  varargin(1) = [];
               else   
                  nresp = varargin{1};
                  ncomp = varargin{2};
                  varargin(1:2) = [];
               end   
            end   
         end
         
         if numel(ncomp) ~= 1 || ncomp < 1 || ncomp > nComp
            error('Wrong value for number of components!')
         end
         
         if numel(nresp) ~= 1 || nresp < 1 || nresp > nResp
            error('Wrong value for response indices!');
         end   
      end
   end   
end

