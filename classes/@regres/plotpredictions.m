function varargout = plotpredictions(obj, varargin)
   [nresp, ncomp, varargin] = regres.getPlotParams(obj.nResp, obj.nComp, varargin{:});
   
   [type, varargin] = getarg(varargin, 'Type');
   if isempty(type)
      type = 'scatter';
   end
   
   [showLine, varargin] = getarg(varargin, 'TargetLine');
   if ~isempty(showLine) && strcmp(showLine, 'off')
      showLine = false;
   else
      showLine = true;
   end   

   if ~isempty(obj.yref)
      s = obj.yref(:, nresp).colNames{1};
      plotData = [obj.yref.valuesAll(:, nresp) obj.ypred_.values_(:, nresp, ncomp)];
      plotData = mdadata(plotData, obj.yref.rowNamesAll, {[s 'ref'], [s 'pred']});
      plotData.colFullNamesAll = {[s ', reference'], [s, ', predictions']};
      plotData.rowFullNamesAll = obj.yref.rowFullNamesAll;
      plotData.excluderows(obj.yref.excludedRows);
   else
      plotData = obj.ypred_(:, nresp, ncomp).values;
   end
   
   if strcmp(type, 'scatter')
      h = scatter(plotData, varargin{:});
   else
      error('Wrong plot type!');
   end

   if showLine && ~isempty(obj.stat)
      b = polyfit(plotData.values(:, 1), plotData.values(:, 2), 1);
      x = xlim();
      y = b(2) + b(1) * x;

      if numel(h.plot) == 1
          c = get(h.plot, 'Color');
      else
          c = mdadata.getmycolors(1);
      end
      
      line(x, y, 'Color', mdalight(c));          
   end
   
   if ~ishold
      box on
      title('Predictions');
   end
   
   if nargout > 0
      varargout{1} = h.plot;
   end   
end
