function varargout = plotxexpvar(obj, varargin)            
   h = obj.xdecomp.plotexpvar(varargin{:});
   
   if ~ishold
      box on
      title('X explained variance');
   end
   
   if nargout > 0
      varargout{1} = h;
   end      
end
