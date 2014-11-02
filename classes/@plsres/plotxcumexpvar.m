function varargout = plotxcumexpvar(obj, varargin)            
   h = obj.xdecomp.plotcumexpvar(varargin{:});

   if ~ishold
      box on
      title('X explained variance (cumulative)');
   end
   
   if nargout > 0
      varargout{1} = h;
   end      
end
