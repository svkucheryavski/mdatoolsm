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
      type = 'scatter';
   end
         
   if strcmp(type, 'scatter')
      h = scatter(obj.scores(:, comp), varargin{:});
   elseif strcmp(type, 'density') ||   strcmp(type, 'densscatter')
      h = densscatter(obj.scores(:, comp), varargin{:});
%    elseif strcmp(type, 'line')   
%       h = gplot(obj.scores(:, comp)', varargin{:});
   else
      error('Wrong plot type!');
   end
   title('Scores');
   
   if showLines && ~strcmp(type, 'density')
      lim = axis();
      line([lim(1) lim(2)], [0 0], 'LineStyle', '--', 'Color', [0.5 0.5 0.5]);
      if strcmp(type, 'scatter') && numel(comp) > 1
         line([0 0], [lim(3) lim(4)], 'LineStyle', '--', 'Color', [0.5 0.5 0.5]);
      end   
   end
   
   if nargout > 0
      varargout{1} = h.plot;
   end   
end