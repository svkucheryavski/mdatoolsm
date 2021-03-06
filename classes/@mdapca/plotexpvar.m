function varargout = plotexpvar(obj, varargin)

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
   plotData = obj.calres.variance.values(:, 1)';
   rowNames = {'cal'};
   
   if ~isempty(obj.cvres) && isa(obj.cvres, 'pcares')
      plotData = [plotData; obj.cvres.variance.values(:, 1)'];
      rowNames = [rowNames, 'cv'];
   else
      c(2, :) = [];
   end   
   
   if ~isempty(obj.testres) && isa(obj.testres, 'pcares')
      plotData = [plotData; obj.testres.variance.values(:, 1)'];
      rowNames = [rowNames, 'test'];
   else
      c(end, :) = [];
   end   
   
   plotData = mdadata(plotData, rowNames, 1:size(plotData, 1));
   plotData.name = 'Explained variance';
   plotData.colValuesAll = 1:plotData.nCols;
   
   if strcmp(type, 'bar')   
      h = gbar(plotData, varargin{:}, 'FaceColor', c);
      xlim([0.25 plotData.nCols + 0.75])      
   elseif strcmp(type, 'line')   
      h = gplot(plotData, varargin{:}, 'Marker', mr, 'Color', c);
      xlim([0.75 plotData.nCols + 0.25])
   else
      error('Wrong plot type!');
   end
   
   set(gca, 'XTick', 1:plotData.nCols);
   
   title('Explained varaince')
   ylabel('Variance, %');
   xlabel('Components');
   
   if nargout > 0
      varargout{1} = h;
   end   
end