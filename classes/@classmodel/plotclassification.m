function plotclassification(obj, varargin)
   [classes, ncomp, varargin] = classres.getClassPlotParams(obj.calres.nClasses, ...
      obj.calres.nComp, obj.calres.classNames, varargin{:});
      
   if ncomp ~= obj.nComp
      titleStr = sprintf(' (ncomp = %d)', ncomp);
   else
      titleStr = '';
   end    
   
   if ~isempty(obj.testres)
      obj.testres.plotclassification(classes, ncomp, varargin{:});
      title(['Classification for test set' titleStr]);
   elseif ~isempty(obj.cvres)
      obj.cvres.plotclassification(classes, ncomp, varargin{:});
      title(['Classification for cross-validation' titleStr]);
   else
      obj.calres.plotclassification(classes, ncomp, varargin{:});
      title(['Classification for calibration set' titleStr]);
   end   
   
   box on
end
