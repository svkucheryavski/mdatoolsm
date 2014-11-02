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
   
   h = obj.xdecomp.plotresiduals(ncomp, varargin{:});

   if ~ishold
      box on
      title(titleStr);
   end
   
   if nargout > 0
      varargout{1} = h;
   end      
end
