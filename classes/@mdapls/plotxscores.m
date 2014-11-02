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
   
   args = mdadata.getgscatteroptions(3, varargin{:});
   
   hold on
   h(1) = obj.calres.plotxscores(comp, args{1}{:});
   legendStr{1} = 'cal';
      
   if ~isempty(obj.testres)
      h(end + 1) = obj.testres.plotxscores(comp, args{3}{:});
      legendStr{end + 1} = 'test';
   end
   
   hold off
   box on
   if numel(legendStr) > 1
      mdadata.legend(h, legendStr)
   end   
   title('X scores');
            
   if nargout > 0
      varargout{1} = h;
   end      
end
   
