function varargout = plotsensitivity(obj, varargin)         
   h = plotperformance(obj, varargin{:}, 'Restype', 'sensitivity');
   if nargout > 0
      varargout{1} = h;
   end      
end
