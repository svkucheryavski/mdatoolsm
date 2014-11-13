function varargout = plotloadings(obj, varargin)
   if nargin > 1 && isnumeric(varargin{1})
      comp = varargin{1};
      varargin(1) = [];
   else   
      comp = [1, 2];
   end
   
   ncomp = numel(comp);
      
   i = find(strcmp(varargin, 'Type'), 1);
   if ~isempty(i)
      type = varargin{i + 1};
      varargin(i:i+1) = [];
   else
      if ncomp == 2
         type = 'scatter';
      else
         type = 'line';
      end   
   end   
   
   if strcmp(type, 'scatter')
      scatter(obj.loadings(:, comp), varargin{:});
   elseif strcmp(type, 'bar')   
      gbar(obj.loadings(:, comp)', varargin{:});
   elseif strcmp(type, 'line')   
      gplot(obj.loadings(:, comp)', varargin{:});
   else
      error('Wrong plot type!');
   end
   title('Loadings')
   
   if strcmp(type, 'scatter')
      lim = axis();
      line([0 0], [lim(3) lim(4)], 'LineStyle', '--', 'Color', [0.5 0.5 0.5]);
      line([lim(1)  lim(2)], [0 0], 'LineStyle', '--', 'Color', [0.5 0.5 0.5]);
   end
   
   if nargout > 0
      varargout{1} = h;
   end   
end