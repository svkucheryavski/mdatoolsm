function varargout = plotycumexpvar(obj, varargin)            
   if isempty(obj.ydecomp)
      warning('Y decomposition is not available for this PLS results.')
      return
   end
   
   h = obj.ydecomp.plotcumexpvar(varargin{:});
   
   if ~ishold
      box on
      title('Y explained variance (cumulative)');
   end
   
   if nargout > 0
      varargout{1} = h;
   end      
end
