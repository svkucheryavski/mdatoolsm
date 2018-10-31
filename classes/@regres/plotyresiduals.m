function varargout = plotyresiduals(obj, varargin)

   [nresp, ncomp, varargin] = regres.getRegPlotParams(obj.nResp, obj.nComp, obj.respNames, varargin{:});

   [type, varargin] = getarg(varargin, 'Type');
   if isempty(type)
      type = 'scatter';
   end
   
   if ~isempty(obj.yref)
      s = obj.yref.getColLabels(nresp);
      plotData = [obj.yref(:, nresp).valuesAll, obj.yref(:, nresp).valuesAll - obj.ypred_(:, nresp, ncomp).valuesAll.valuesAll];
      plotData = mdadata(plotData, obj.ypred.rowNamesAll, {[s{1} 'ref'], [s{1} 'res']});
      plotData.colFullNamesAll = {[s{1} ', reference'], [s{1} ', residuals']};
      plotData.rowFullNamesAll = obj.ypred.rowFullNamesAll;
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
      line(xlim(), [0 0], 'LineStyle', '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility','off');
   end
   
   box on
   title('Prediction residuals');
   
   if nargout > 0
      varargout{1} = h.plot;
   end   
end
