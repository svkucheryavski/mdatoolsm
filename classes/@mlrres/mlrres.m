classdef mlrres < regres
    
    methods
        function obj = mlrres(varargin)
            obj = obj@regres(varargin{:});
        end
        
        function plot(obj, varargin)
            plot@regres(obj, 1, 1, varargin{:});
        end
        
        function varargout = plotpredictions(obj, varargin)
            h = plotpredictions@regres(obj, 1, 1, varargin{:});
            
            if nargout > 0
               varargout{1} = h;
            end   
        end
        
        function varargout = plotyresiduals(obj, varargin)
            h = plotyresiduals@regres(obj, 1, 1, varargin{:});
            
            if nargout > 0
               varargout{1} = h;
            end   
        end
        
        function varargout = plotrmse(obj, varargin)
            h = plotrmse@regres(obj, 1, varargin{:});
            if nargout > 0
               varargout{1} = h;
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
        
        function show(obj, varargin)
            show@regres(obj, 1, 1);
        end        
    end    
end

