function varargout = plotmisclassified(obj, varargin)         
   h = plotperformance(obj, varargin{:}, 'Restype', 'misclassified');
   if nargout > 0
      varargout{1} = h;
   end      
end
