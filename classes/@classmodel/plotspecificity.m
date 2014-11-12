function varargout = plotspecificity(obj, varargin)         
   h = plotperformance(obj, varargin{:}, 'Restype', 'specificity');
   if nargout > 0
      varargout{1} = h;
   end      
end
