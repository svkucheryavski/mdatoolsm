function varargout = plotloadings(obj, varargin)
   h = mdapca.plotloadingsstat(obj.loadings, varargin{:});
   
   if nargout > 0
      varargout{1} = h;
   end   
end