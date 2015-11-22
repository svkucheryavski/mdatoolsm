function varargout = plotweights(obj, varargin)
   h = mdapca.plotloadingsstat(obj.weights, varargin{:});
   title('PLS weigths')
   if nargout > 0
      varargout{1} = h;
   end   
end