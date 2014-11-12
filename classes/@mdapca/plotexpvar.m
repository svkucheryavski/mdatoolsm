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

   plotData = obj.calres.variance(:, 1)';
   plotData.rowNames = {'cal'};
   c = mdadata.getmycolors(3);
   
   if ~isempty(obj.cvres) && isa(obj.cvres, 'pcares')
      plotData = [plotData; obj.cvres.variance(:, 1)'];
      plotData(end, :).rowNames = {'cv'};
   else
      c(2, :) = [];
   end   
   
   if ~isempty(obj.testres) && isa(obj.testres, 'pcares')
      plotData = [plotData; obj.testres.variance(:, 1)'];
      plotData(end, :).rowNames = {'test'};
   else
      c(end, :) = [];
   end
   
   plotData.colNames = 1:plotData.nCols;
   plotData.name = 'Explained variance';
   
   if strcmp(type, 'bar')   
      h = gbar(plotData, varargin{:}, 'FaceColor', c);
   elseif strcmp(type, 'line')   
      h = gplot(plotData, varargin{:}, 'Marker', mr, 'Color', c);
   else
      error('Wrong plot type!');
   end
   
   ylabel('Variance, %');
   xlabel('Components');
   
   if nargout > 0
      varargout{1} = h;
   end   
end