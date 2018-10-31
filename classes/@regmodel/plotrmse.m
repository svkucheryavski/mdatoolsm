function varargout = plotrmse(obj, varargin)
   
   % which response to make the plot for
   nResp = 1;
   if numel(varargin) > 0 && isnumeric(varargin{1})
      nResp = varargin{1};
      varargin(1) = [];
   end
   
   % type of the plot
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
   
   plotData = obj.calres.stat.rmse(:, nResp)';
   plotData.rowNamesAll = {'cal'};
   plotData.rowFullNamesAll = {'cal'};

   if ~isempty(obj.cvres)
      cvPlotData = obj.cvres.stat.rmse(:, nResp)';
      cvPlotData.rowNamesAll = {'cv'};
      cvPlotData.rowFullNamesAll = {'cv'};
      plotData = [plotData; cvPlotData];
   else
      c(2, :) = [];
   end   
   
   if ~isempty(obj.testres) 
      testPlotData = obj.testres.stat.rmse(:, nResp)';
      testPlotData.rowNamesAll = {'test'};
      testPlotData.rowFullNamesAll = {'test'};
      plotData = [plotData; testPlotData];
   else
      c(end, :) = [];
   end   

   plotData.colValuesAll = 1:plotData.nCols;
   
   if strcmp(type, 'line')
      h = gplot(plotData, 'Color', c, 'Marker', mr, varargin{:});
      xlim([0.75 plotData.nCols + 0.25])
   elseif strcmp(type, 'bar')
      h = gbar(plotData, 'FaceColor', c, varargin{:});
      xlim([0.25 plotData.nCols + 0.75])      
   else
      error('Wrong plot type!');
   end
   
   set(gca, 'XTick', 1:plotData.nCols);
   box on
   title('RMSE')

   if nargout > 0
      varargout{1} = h;
   end   
end
