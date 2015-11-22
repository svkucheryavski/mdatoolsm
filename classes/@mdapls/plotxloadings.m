function varargout = plotxloadings(obj, varargin)
   h = mdapca.plotloadingsstat(obj.xloadings, varargin{:});
   title('X-loadings')
   if nargout > 0
      varargout{1} = h;
   end   
end