function varargout = plotxresiduals(obj, varargin)         
   if numel(varargin) > 0 && isnumeric(varargin{1})
      ncomp = varargin{1};
      varargin(1) = [];
      if ncomp < 1 || ncomp > obj.nComp
         error('Wrong value for "ncomp" parameter!');
      end   
      titleStr = sprintf('X residuals (ncomp = %d)', ncomp);
   else
      ncomp = obj.nComp;
      titleStr = 'X residuals';
   end
   
   args = mdadata.getgscatteroptions(3, varargin{:});
   
   hold on
   h(1) = obj.calres.xdecomp.plotresiduals(ncomp, args{1}{:});
   legendStr{1} = 'cal';
      
   if ~isempty(obj.cvres)
      h(end + 1) = obj.cvres.xdecomp.plotresiduals(ncomp, args{2}{:});
      legendStr{end + 1} = 'cv';
   end
   
   if ~isempty(obj.testres)
      h(end + 1) = obj.testres.xdecomp.plotresiduals(ncomp, args{3}{:});
      legendStr{end + 1} = 'test';
   end
   
   hold off
   box on
   if numel(legendStr) > 1
      mdadata.legend(h, legendStr)
   end   
   title(titleStr);
         
   
   if nargout > 0
      varargout{1} = h;
   end      
end
