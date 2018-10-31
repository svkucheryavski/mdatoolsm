function varargout = plotxexpvar(obj, varargin)
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
   
   plotData = obj.calres.xdecomp.variance(:, 1);
   plotData.colNames = {'cal'};

   if ~isempty(obj.cvres)
      plotData = [plotData obj.cvres.xdecomp.variance(:, 1)];
      plotData(:, end).colNames = {'cv'};
   else
      c(2, :) = [];
   end   
   
   if ~isempty(obj.testres) 
      plotData = [plotData obj.testres.xdecomp.variance(:, 1)];
      plotData(:, end).colNames = {'test'};
   else
      c(end, :) = [];
   end   
      
   plotData.rowValuesAll = 1:plotData.nRows;
   if strcmp(type, 'bar')   
      h = gbar(plotData', varargin{:}, 'FaceColor', c);
      xlim([0.25 plotData.nRows + 0.75])
   elseif strcmp(type, 'line')   
      h = gplot(plotData', varargin{:}, 'Marker', mr, 'Color', c);
      xlim([0.75 plotData.nRows + 0.25])
   else
      error('Wrong plot type!');
   end
   
   set(gca, 'XTick', 1:plotData.nRows);

   if nargout > 0
      varargout{1} = h.plot;
   end   
   title('X explained variance')
end
