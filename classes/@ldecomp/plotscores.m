function varargout = plotscores(obj, varargin)

   if isempty(obj.scores)
      warning('Scores plot is not available for cross-validation results!')
      return
   end   
   
   if nargin < 2 || ~isnumeric(varargin{1})
      comp = [1 2];
   else
      comp = varargin{1};
      varargin(1) = [];
      if min(comp) < 1 || max(comp) > obj.scores.nCols
         error('Wrong value for "comp" parameter!');
      end   
   end
   
   [showLines, varargin] = getarg(varargin, 'AxisLines');
   if ~isempty(showLines) && strcmp(showLines, 'off')
      showLines = false;
   else
      showLines = true;
   end   
   
   [type, varargin] = getarg(varargin, 'Type');
   if isempty(type) 
      if numel(comp) < 3
         type = 'scatter';
      else
         type = 'line';
      end   
   end
         
   if strcmp(type, 'scatter')
      h = scatter(obj.scores(:, comp), varargin{:});
      if numel(comp) == 2
         xlabel(sprintf('Comp %d (%.1f%%)', comp(1), obj.variance(comp(1), 1).values));
         ylabel(sprintf('Comp %d (%.1f%%)', comp(2), obj.variance(comp(2), 1).values));
      else
         xlabel(obj.scores.dimNames{1});
         ylabel(sprintf('Comp %d (%.1f%%)', comp, obj.variance(comp, 1).values));
      end
   elseif strcmp(type, 'density') ||   strcmp(type, 'densscatter')
      h = densscatter(obj.scores(:, comp), varargin{:});
      xlabel(sprintf('Comp %d (%.1f%%)', comp(1), obj.variance(comp(1), 1).values));
      ylabel(sprintf('Comp %d (%.1f%%)', comp(2), obj.variance(comp(2), 1).values));
   elseif strcmp(type, 'line')   
      h = gplot(obj.scores(:, comp)', varargin{:});
   elseif strcmp(type, 'bar')   
      h = gbar(obj.scores(:, comp)', varargin{:});
   else
      error('Wrong plot type!');
   end
   
   title('Scores');
   if showLines && ~strcmp(type, 'density')
      lim = axis();
      line([lim(1) lim(2)], [0 0], 'LineStyle', '--', 'Color', [0.5 0.5 0.5], ...
         'HandleVisibility','off');
      if strcmp(type, 'scatter') && numel(comp) > 1
         line([0 0], [lim(3) lim(4)], 'LineStyle', '--', 'Color', [0.5 0.5 0.5],...
            'HandleVisibility','off');
      end   
   end
   
   if nargout > 0
      varargout{1} = h;
   end   
end