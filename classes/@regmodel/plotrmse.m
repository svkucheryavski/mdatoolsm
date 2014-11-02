function varargout = plotrmse(obj, varargin)
   if numel(varargin) > 0 && isnumeric(varargin{1})
      nresp = varargin{1};
      varargin(1) = [];
   else
      nresp = 1;
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

   plotData = obj.calres.stat.rmse(:, nresp);
   plotData.colNames = {'cal'};

   if ~isempty(obj.cvres)
      plotData = [plotData obj.cvres.stat.rmse(:, nresp)];
      plotData(:, end).colNames = {'cv'};
   else
      c(2, :) = [];
   end   
   
   if ~isempty(obj.testres) 
      plotData = [plotData obj.testres.stat.rmse(:, nresp)];
      plotData(:, end).colNames = {'test'};
   else
      c(end, :) = [];
   end   
      
   if strcmp(type, 'bar')   
      h = gbar(plotData', varargin{:}, 'FaceColor', c);
   elseif strcmp(type, 'line')   
      h = gplot(plotData', varargin{:}, 'Marker', mr, 'Color', c);
   else
      error('Wrong plot type!');
   end
   
   if nargout > 0
      varargout{1} = h.plot;
   end   
   title('RMSE')
end
