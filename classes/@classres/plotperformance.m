function varargout = plotperformance(obj, varargin)    
   [nclass, varargin] = classres.getClassNum(obj.nClasses, obj.classNames, varargin{:});
   [restype, varargin] = getarg(varargin, 'Restype');
   if isempty(restype)
      restype = 'missclassified';
   end   
   
   if isempty(obj.stat)
      warning('Classification statistics are not available for this object.')
      if nargout > 0
         varargout{1} = [];
      end      
      return
   end
   
   i = find(strcmp(varargin, 'Type'), 1);
   if ~isempty(i)
      type = varargin{i + 1};
      varargin(i:i+1) = [];
   else
      type = 'line';
   end
   
   i = find(strcmp(varargin, 'Color'), 1);
   if ~isempty(i)
      color = varargin{i + 1};
      varargin(i:i+1) = [];
   else
      color = mdadata.getmycolors(1);
   end
   
   [mr, varargin] = getarg(varargin, 'Marker');
   if isempty(mr)
      mr = '.';
   end   
   
   plotData = obj.stat.(restype)(:, nclass);   
   plotData.rowValuesAll = 1:plotData.nRows;
   
   if strcmp(type, 'bar')   
      h = bar(plotData', varargin{:}, 'FaceColor', color);
      xlim([0.25 plotData.nRows + 0.75])      
   elseif strcmp(type, 'line')   
      h = plot(plotData', varargin{:}, 'Marker', mr, 'Color', color);
      xlim([0.75 plotData.nRows + 0.25])
   else
      error('Wrong plot type!');
   end
   
   set(gca, 'XTick', 1:plotData.nRows);
   ylim([0 1.1])
   
   if ~ishold
      box on
      title([upper(restype(1)) restype(2:end) ' (' obj.classNames{nclass} ')'])
   end
   
   if nargout > 0
      varargout{1} = h;
   end      
end
