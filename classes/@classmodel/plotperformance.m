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

   plotData = eval(['obj.calres.stat.' restype '(:, nclass)']);
   plotData.colNames = {'cal'};

   if ~isempty(obj.cvres)
      plotData = [plotData eval(['obj.cvres.stat.' restype '(:, nclass)'])];
      plotData(:, end).colNames = {'cv'};
   else
      c(2, :) = [];
   end   
   
   if ~isempty(obj.testres) 
      plotData = [plotData eval(['obj.testres.stat.' restype '(:, nclass)'])];
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
      varargout{1} = h;
   end   
   title([upper(restype(1)) restype(2:end) ' (' obj.calres.classNames{nclass} ')'])
end
