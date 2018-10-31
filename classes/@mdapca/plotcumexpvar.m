function varargout = plotcumexpvar(obj, varargin)

   i = find(strcmp(varargin, 'Type'), 1);
   if ~isempty(i)
      type = varargin{i + 1};
      varargin(i:i+1) = [];
   else
      type = 'line';
   end
   
   [mr, varargin] = getarg(varargin, 'Marker');
   if isempty(mr)
      mr = '.';
   end   
   
   c = mdadata.getmycolors(3);
   plotData = [0 obj.calres.variance.values(:, 2)'];
   rowNames = {'cal'};
   
   if ~isempty(obj.cvres) && isa(obj.cvres, 'pcares')
      plotData = [plotData; [0 obj.cvres.variance.values(:, 2)']];
      rowNames = [rowNames, 'cv'];
   else
      c(2, :) = [];
   end   
   
   if ~isempty(obj.testres) && isa(obj.testres, 'pcares')
      plotData = [plotData; [0 obj.testres.variance.values(:, 2)']];
      rowNames = [rowNames, 'test'];
   else
      c(end, :) = [];
   end   
   
   plotData = mdadata(plotData, rowNames, 0:size(plotData, 2));
   plotData.name = 'Explained variance (cumulative)';
   plotData.colValuesAll = 0:plotData.nCols-1;
   
   if strcmp(type, 'line')   
      h = gplot(plotData, varargin{:}, 'Marker', mr, 'Color', c);
      xlim([-0.25 plotData.nCols - 0.75])
   elseif strcmp(type, 'bar')   
      h = gbar(plotData, varargin{:}, 'FaceColor', c);
      xlim([-0.75 plotData.nCols - 0.25])      
   else
      error('Wrong plot type!');
   end
   
   set(gca, 'XTick', 0:plotData.nCols-1);
   
   title('Cumulative explained varaince')
   ylabel('Variance, %');
   xlabel('Components');
   
   if nargout > 0
      varargout{1} = h;
   end   
end