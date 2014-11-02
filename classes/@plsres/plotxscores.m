function varargout = plotxscores(obj, varargin)         
   if numel(varargin) > 0 && isnumeric(varargin{1})
      comp = varargin{1};
      varargin(1) = [];
      if min(comp) < 1 || max(comp) > obj.nComp
         error('Wrong value for components!');
      end   
   else
      comp = [1 2];
   end
   
   if isempty(obj.xdecomp.scores)
      warning('Scores are not available for cross-validation results!')
      return
   end

   h = obj.xdecomp.plotscores(comp, varargin{:});
   
   if ~ishold
      box on
      title('X scores');
   end
   
   if nargout > 0
      varargout{1} = h;
   end      
end
