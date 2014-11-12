classdef plsres < regres
    properties(SetAccess = 'protected')
      xdecomp
      ydecomp
    end
    
    properties (Dependent = true, Hidden = true, Access = 'private')
      nComp
      nPred
    end
    
    methods
      function obj = plsres(xdecomp, ydecomp, varargin)
         obj = obj@regres(varargin{:});
         obj.xdecomp = xdecomp;
         obj.ydecomp = ydecomp;
      end
               
      function out = get.nPred(obj)
         out = size(obj.ypred_, 1);
      end
      
      
      function out = get.nComp(obj)
         out = size(obj.ypred_, 3);
      end
      
      function plot(obj, varargin)
         [nresp, ncomp, varargin] = regres.getRegPlotParams(obj.nResp, obj.nComp, obj.respNames, varargin{:});
         if ~isempty(obj.stat)
            subplot(2, 2, 1)
            obj.plotxresiduals(ncomp, varargin{:});
            subplot(2, 2, 2)
            obj.plotyexpvar(varargin{:});
            subplot(2, 2, 3)
            obj.plotrmse(nresp, varargin{:});
            subplot(2, 2, 4)
            obj.plotpredictions(nresp, ncomp, varargin{:});
         else
            subplot(1, 2, 1)
            obj.xresiduals(ncomp, varargin{:});
            subplot(1, 2, 2)
            obj.plotpredictions(nresp, ncomp, varargin{:});
         end   
      end
                
      function summary(obj, nresp)
         if nargin < 2
             nresp = 1:obj.nResp;
         end
         
         if ~isempty(obj.stat)
         
            for iResp = nresp
               xexpvar = obj.xdecomp.variance(:, 1);
               xexpvar.colNames = {'X expvar'};
               
               yexpvar = obj.ydecomp.variance(:, 1);
               yexpvar.colNames = {'Y expvar'};
               
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
               
               out = [xexpvar yexpvar rmse bias slope r2 rpd];
               out.dimNames = {'', ''};
               out.name = ['Prediction performance for ' obj.ypred_.wayFullNames{2}{iResp}];
               
               if ~isempty(obj.info)
                  fprintf('\n%s', obj.info);
               end   
               show(out);
            end   
         end
      end
        
      function show(obj, varargin)
         [nresp, ncomp, ~] = regres.getPlotParams(obj.nResp, obj.nComp, varargin{:});
         show@regres(obj, nresp, ncomp);
      end        
    end 
end

