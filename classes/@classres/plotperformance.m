function varargout = plotperformance(obj, varargin)    
   [nclass, varargin] = classres.getClassNum(obj.nClasses, obj.classNames, varargin{:});
   
   [restype, varargin] = getarg(varargin, 'Restype');
   if isempty(restype)
      restype = 'missclassified';
   end   
   
   if isempty(obj.stat)
      warning('Classification statistics are not available for this object.')
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
   
   switch restype
      case 'misclassified'
         plotData = obj.stat.misclassified(:, nclass);
      case 'sensitivity'
         plotData = obj.stat.sensitivity(:, nclass);
      case 'specificity'
         plotData = obj.stat.specificity(:, nclass);
      otherwise
         error('Wrone type of classification results!')
   end
      
   if strcmp(type, 'bar')   
      h = bar(plotData', varargin{:});
   elseif strcmp(type, 'line')   
      h = plot(plotData', varargin{:}, 'Marker', mr);
   else
      error('Wrong plot type!');
   end
   
   if ~ishold
      box on
      title([upper(restype(1)) restype(2:end) ' (' obj.classNames{nclass} ')'])
      correctaxislim()
   end
   
   if nargout > 0
      varargout{1} = h;
   end      
end
