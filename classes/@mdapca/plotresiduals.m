function varargout = plotresiduals(obj, varargin)         

   if nargin > 1 && isnumeric(varargin{1})
      ncomp = varargin{1};
      varargin(1) = [];
      if ncomp < 1 || ncomp > obj.nComp
         error('Wrong value for "ncomp" parameter!');
      end   
      titleStr = sprintf('Residuals (ncomp = %d)', ncomp);
   else   
      ncomp = obj.nComp;
      titleStr = 'Residuals';
   end
   
   args = mdadata.getgscatteroptions(3, varargin{:});
   
   hold on
   h(1) = obj.calres.plotresiduals(ncomp, args{1}{:});
   legendStr{1} = 'cal';
      
   if ~isempty(obj.cvres)
      h(end + 1) = obj.cvres.plotresiduals(ncomp, args{2}{:});
      legendStr{end + 1} = 'cv';
   end
   
   if ~isempty(obj.testres)
      h(end + 1) = obj.testres.plotresiduals(ncomp, args{3}{:});
      legendStr{end + 1} = 'test';
   end
   
   hold off
   box on
   if numel(legendStr) > 1
      mdadata.legend(h, legendStr)
   end   
   title(titleStr);
         
   % show statistical limits
   slim = obj.limits.values(:, ncomp);
   lim = axis();
   dx = (lim(2) - lim(1)) / 10;
   dy = (lim(4) - lim(3)) / 10;
   lim(2) = max(lim(2), slim(1) + dx);
   lim(4) = max(lim(4), slim(2) + dy);
   line([slim(1) slim(1)], [lim(3) lim(4)], 'LineStyle', '--', 'Color', [0.5 0.5 0.5],...
      'HandleVisibility','off');
   line([lim(1) lim(2)], [slim(2) slim(2)], 'LineStyle', '--', 'Color', [0.5 0.5 0.5],...
      'HandleVisibility','off');   
   axis(lim);
   
   if nargout > 0
      varargout{1} = h;
   end      
end
