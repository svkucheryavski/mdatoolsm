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
        
        function summary(obj)
            summary@regres(obj, 1);
        end
        
        function show(obj, varargin)
            show@regres(obj, 1, 1);
        end        
    end    
end

