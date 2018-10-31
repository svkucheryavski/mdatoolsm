function varargout = plotrmse(obj, varargin)     
   if numel(varargin) > 0 && isnumeric(varargin{1})
      nresp = varargin{1};
      varargin(1) = [];
      if nresp < 1 || nresp > obj.nResp
         error('Wrong value for "nresp" parameter!');
      end   
   else
      nresp = 1;
   end
   
   if isempty(obj.stat)
      warning('Prediction statistics are not available for this object.')
      return
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
   
   plotData = obj.stat.rmse(:, nresp);
   plotData.rowValuesAll = 1:plotData.nRows;
   
   if strcmp(type, 'bar')   
      h = bar(plotData', varargin{:});
      xlim([0.25 plotData.nRows + 0.75])
   elseif strcmp(type, 'line')   
      h = plot(plotData', varargin{:}, 'Marker', mr);
      xlim([0.75 plotData.nRows + 0.25])
   else
      error('Wrong plot type!');
   end
   
   set(gca, 'XTick', 1:plotData.nRows);
   
   if ~ishold
      box on
      title('RMSE')
   end
   
   if nargout > 0
      varargout{1} = h;
   end      
end
