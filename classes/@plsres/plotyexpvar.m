function varargout = plotyexpvar(obj, varargin)            
   if isempty(obj.ydecomp)
      warning('Y decomposition is not available for this PLS results.')
      return
   end
   
   h = obj.ydecomp.plotexpvar(varargin{:});
   
   if ~ishold
      box on
      title('Y explained variance');
   end
   
   if nargout > 0
      varargout{1} = h;
   end      
end
