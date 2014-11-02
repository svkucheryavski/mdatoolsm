function varargout = plotxyscores(obj, varargin)         
   if numel(varargin) > 0 && isnumeric(varargin{1})
      ncomp = varargin{1};
      varargin(1) = [];
      if ncomp < 1 || ncomp > obj.nComp
         error('Wrong value for "ncomp" parameter!');
      end   
   else
      ncomp = obj.nComp;
   end
   
   args = mdadata.getgscatteroptions(3, varargin{:});
   
   hold on
   h(1) = obj.calres.plotxyscores(ncomp, args{1}{:});
   legendStr{1} = 'cal';
      
   if ~isempty(obj.testres)
      h(end + 1) = obj.testres.plotxyscores(ncomp, args{3}{:});
      legendStr{end + 1} = 'test';
   end
   
   hold off
   box on
   if numel(legendStr) > 1
      mdadata.legend(h, legendStr)
   end   
   title('XY scores');
   xlabel(sprintf('X scores (Comp %d)', ncomp));
   ylabel(sprintf('Y scores (Comp %d)', ncomp));
            
   if nargout > 0
      varargout{1} = h;
   end      
end
