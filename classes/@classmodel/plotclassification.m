function plotclassification(obj, varargin)
   [classes, ncomp, varargin] = classres.getClassPlotParams(obj.calres.nClasses, obj.calres.nComp, obj.calres.classNames, varargin{:});
   nrows = 1;
   
   if ~isempty(obj.cvres)
      nrows = nrows + 1;
   end
   
   if ~isempty(obj.testres)
      nrows = nrows + 1;
   end
   
   if ncomp ~= obj.nComp
      titleStr = sprintf(' (ncomp = %d)', ncomp);
   else
      titleStr = '';
   end    
   
   subplot(nrows, 1, 1)
   obj.calres.plotclassification(classes, ncomp, varargin{:});
   box on
   title(['Classification for calibration set' titleStr]);
   n = 2;
   
   if ~isempty(obj.cvres)
      subplot(nrows, 1, n)
      obj.cvres.plotclassification(classes, ncomp, varargin{:});
      title(['Classification for cross-validation' titleStr]);
      n = n + 1;
      box on
   end
   
   if ~isempty(obj.testres)
      subplot(nrows, 1, n)
      obj.testres.plotclassification(classes, ncomp, varargin{:});
      title(['Classification for test set' titleStr]);
      box on
   end   
end
