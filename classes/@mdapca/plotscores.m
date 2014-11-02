function varargout = plotscores(obj, comp, varargin)         
   if nargin < 2
      comp = [1 2];
   end
   
   if numel(comp) < 1 || numel(comp) > 2
      error('Wrong value for "comp", specify one or two components for the plot!');
   end   
   
   args = mdadata.getgscatteroptions(3, varargin{:});
   
   hold on
   h{1} = obj.calres.plotscores(comp, args{1}{:});
   legendStr{1} = 'cal';
      
   if ~isempty(obj.testres)
      h(end + 1) = obj.testres.plotscores(comp, args{3}{:});
      legendStr{end + 1} = 'test';
   end
   
   hold off
   box on
   if numel(legendStr) > 1
      mdadata.legend(h, legendStr)
   end   
   title('Scores');

   
   lim = axis();
   line([lim(1) lim(2)], [0 0], 'LineStyle', '--', 'Color', [0.5 0.5 0.5]);
   
   if numel(comp) > 1
      line([0 0], [lim(3) lim(4)], 'LineStyle', '--', 'Color', [0.5 0.5 0.5]);
   end
   
   if nargout > 0
      varargout{1} = h;
   end      
end
