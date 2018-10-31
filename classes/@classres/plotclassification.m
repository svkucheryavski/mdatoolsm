function varargout = plotclassification(obj, varargin)
   [classes, ncomp, varargin] = classres.getClassPlotParams(obj.nClasses, obj.nComp, ...
      obj.classNames, varargin{:});

   cpred = copy(obj.cpred_);

   excludedRows = cpred.excludedRows;   
   classNames = obj.classNames(classes);
   cpred.includerows(excludedRows);
   
   if ~isempty(obj.cref)
      cref = copy(obj.cref);
      cref.includerows(excludedRows);
   else
      cref = [];
   end
   
   
   if isempty(cpred.wayFullNames{1})
      objNames = textgen('', 1:size(cpred, 1))';
   else   
      objNames = cpred.wayFullNames{1};
   end
   objNames = objNames(:);

   if isempty(cpred.wayValues{1})
      objValues = 1:size(cpred, 1);
   else
      objValues = cpred.wayValues{1};
   end
   objValues = objValues(:);
      
   values = squeeze(obj.cpred_.values_(:, :, ncomp));   
   
   x = (1:size(values, 1))';
   ind_none = true(size(x, 1), 1);
   
   plotData = [];
   refData = [];
   plotObjNames = {};
   plotObjValues = [];
   plotExcludedRows = [];
   refData = [];
   
   for i = classes
      ind = values(:, i) == 1;
      if any(ind)
         plotData = [plotData; [x(ind), i * ones(sum(ind), 1)]];
         plotObjNames = [plotObjNames; objNames(ind)];
         plotObjValues = [plotObjValues; objValues(ind)];
         
         if ~isempty(cref)
            if isempty(refData) 
               refData = cref(ind, :);
            else   
               refData = [refData; cref(ind, :)];
            end
         end
         
         per = excludedRows & ind;
         plotExcludedRows = [plotExcludedRows; per(ind)];
      end
      
      ind_none = ind_none & ~ind;      
   end
      
   if any(ind_none)
      plotData = [plotData; [x(ind_none), zeros(sum(ind_none), 1)]];
      plotObjNames = [plotObjNames(:); objNames(ind_none)];
      plotObjValues = [plotObjValues(:); objValues(ind_none)];
      per = excludedRows & ind_none;
      plotExcludedRows = [plotExcludedRows; per(ind_none)];
      
      if ~isempty(cref) && ~isempty(refData)
         refData = [refData; cref(ind_none, :)];
      end
   end
   
   plotData = mdadata(plotData);
   plotData.dimNames = {'Objects', 'Classes'};
   plotData.rowFullNamesAll = plotObjNames;
   plotData.rowValuesAll = plotObjValues;
   
   plotExcludedRows = logical(plotExcludedRows);
   if any(plotExcludedRows)
      plotData.excluderows(plotExcludedRows);
      if ~isempty(cref)
         refData.excluderows(plotExcludedRows);
      end   
   end
   
   if ~isempty(cref)
      h = gscatter(plotData, refData, varargin{:});
   else
      h = scatter(plotData, varargin{:});
   end   
   
   set(gca, 'YTick', [0 classes], 'YTickLabel', ['None', classNames]);
   ylabel('Classes')
   xlabel('Objects')
   
   if ncomp < size(cpred, 3)
      title_str = sprintf('Classification (ncomp = %d)', ncomp);
   else
      title_str = 'Classification';
   end
   
   if ~ishold
      box on
      title(title_str);
   end
   
   if nargout > 0
      varargout{1} = h.plot;
   end   
end
