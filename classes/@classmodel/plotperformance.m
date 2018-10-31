function varargout = plotperformance(obj, varargin)
   
   [nclass, varargin] = classres.getClassNum(obj.calres.nClasses, obj.calres.classNames, varargin{:});
   
   [restype, varargin] = getarg(varargin, 'Restype');
   if isempty(restype)
      restype = 'missclassified';
   end   
   
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
   
   plotData = obj.calres.stat.(restype)(:, nclass)';   
   plotData.rowNames = {'cal'};
   
   if ~isempty(obj.cvres) && isa(obj.cvres, 'classres')
      cvPlotData = obj.cvres.stat.(restype)(:, nclass)';
      cvPlotData.rowNames = {'cv'};
      plotData = [plotData; cvPlotData];
   else
      c(2, :) = [];
   end   
   
   if ~isempty(obj.testres) && isa(obj.testres, 'classres')
      testPlotData = obj.testres.stat.(restype)(:, nclass)';
      testPlotData.rowNames = {'test'};
      plotData = [plotData; testPlotData];
   else
      c(end, :) = [];
   end   
   
   plotData.name = restype;
   plotData.colValuesAll = 1:plotData.nCols;
   
   if strcmp(type, 'line')   
      h = gplot(plotData, varargin{:}, 'Marker', mr, 'Color', c);
      xlim([0.75 plotData.nCols + 0.25])
   elseif strcmp(type, 'bar')   
      h = gbar(plotData, varargin{:}, 'FaceColor', c);
      xlim([0.25 plotData.nCols + 0.75])      
   else
      error('Wrong plot type!');
   end
   
   set(gca, 'XTick', 1:plotData.nCols);
   ylim([0 1.1])
   
   title([upper(restype(1)) restype(2:end)])
   ylabel('Variance, %');
   xlabel('Components');
   
   if nargout > 0
      varargout{1} = h;
   end   
      
end
