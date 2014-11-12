function varargout = plotyresiduals(obj, varargin)

   [nresp, ncomp, varargin] = regres.getRegPlotParams(obj.nResp, obj.nComp, obj.respNames, varargin{:});

   [type, varargin] = getarg(varargin, 'Type');
   if isempty(type)
      type = 'scatter';
   end
   if ~isempty(obj.yref)
      s = obj.yref(:, nresp).colNames{1};
      plotData = [obj.yref(:, nresp).valuesAll, obj.yref(:, nresp).valuesAll - obj.ypred_(:, nresp, ncomp).valuesAll.valuesAll];
      plotData = mdadata(plotData, obj.yref.rowNamesAll, {[s 'ref'], [s 'res']});
      plotData.colFullNamesAll = {[s ', reference'], [s ', residuals']};
      plotData.rowFullNamesAll = obj.yref.rowFullNamesAll;
      plotData.excluderows(obj.yref.excludedRows);
   else
      error('Reference values are not available!');
   end
   
   if strcmp(type, 'scatter')
      h = scatter(plotData, varargin{:});
   else
      error('Wrong plot type!');
   end

   if ~ishold
      box on
      title('Y residuals');
      lim = axis();
      line([lim(1) lim(2)], [0 0], 'LineStyle', '--', 'Color', [0.5 0.5 0.5]);
   end
   
   if nargout > 0
      varargout{1} = h.plot;
   end   
end
