function varargout = scatter(obj, varargin)
% 'scatter' makes a scatter plot for 'mdadata' class object
%
%   scatter(data);
%   scatter(data(:, [1 5]));
%   scatter(data, 'ParamName', ParamValue, ...);
%
%
% The method uses the standard 'plot()' function (instead of 'scatter()' which is 
% slow with large datasets) and give some extra functionality, such 
% as automatic labels for data points, grouping data with color, etc. If output 
% variable is specified it returns a structure with plot elements (plot handle, 
% labels handle, etc).
% 
% The mandatory argument is a dataset (object of class 'mdadata') with at 
% least one column. If more than two columns exist, the method will make a plot 
% only for the first two. 
%
%
% Parameters:
% ------------
% All parameters for Matlab's 'plot()' function (e.g. "Marker", "MarkerSize", etc.)
% can be used. Additional parameters are:
%
%  "Colorby" - make color grouping of points by a vector of values. The
%  parameter can be a numeric vector with the same number of values as
%  number of rows in the data object. 
%  
%  "Colormap" - a function for generating colormap for the color grouping.
%  By default uses a built in colormap based on colorbrewer2.org. Possible
%  values are: '@jet', '@gray', and so on.
%  
%  "Colorbar" - show or not a colorbar (legend for color groups). Possible
%  values are 'on' and 'off'. By default colorbar is shown if "Colorby" 
%  parameter is specified.
%  
%  "ColorbarTitle" - a text string with title to be shown on top of
%  colorbar.
%  
%  "Labels" - show or not labels for the data points. Possible
%  values are "none" (default), "names" for name of objects and "numbers"
%  for their numbers. 
% 
%  "Groupby" - allows to make a scatter plot with color groups, by 
%  providing one or several factors as values for this parameter. In fact
%  it uses the function "gscatter()" so all parameters for this function
%  can be used when "Groupby" is specified.
%
%  "ShowContour" - show or not a contour around the data points. It uses
%  convex hull to find the outer points. Can be combined with "Groupby"
%  parameter
%
% Examples:
% ---------
%   
%   load people
%
%   % make plot and change standard properties, add labels
%   
%   figure
%   subplot(1, 3, 1)
%   scatter(people(:, 1:2));
%   subplot(1, 3, 2)
%   scatter(people(:, 1:2), 'MarkerFaceColor', 'b', 'Marker', 's');
%   subplot(1, 3, 3)
%   scatter(people(:, 1:2), 'Labels', 'on');
%   
%   % using color grouping
%   
%   cg = people(:, 'Beer');
%   
%   figure
%   scatter(people(:, 1:2), 'Colorby', cg);
%   scatter(people(:, 1:2), 'Colorby', cg, 'Colormap', @gray);
%   scatter(people(:, 1:2), 'Colorby', cg, 'Colorbar', 'on');
%   scatter(people(:, 1:2), 'Colorby', cg, 'Colorbar', 'on', 'ColorbarTitle', 'Beer');
%
%   % make plot for dataset with more than two columns
%
%   figure
%   scatter(people, 'Labels', 'names');
%
%
   
   
   % check if this is a group plot
   [gb, varargin] = getarg(varargin, 'Groupby');   
   if ~isempty(gb)
      h = gscatter(obj, gb, varargin{:});
      if nargout > 0
         varargout{1} = h;
      end
      return      
   end   
   
   % check if necessary to show contour for a data cloud
   [sc, varargin] = getarg(varargin, 'ShowContour');
   if ~isempty(sc) && strcmp(sc, 'on')
      sc = true;
   else
      sc = false;
   end   

   % check if values for color grouping are provided
   [cmap, cgroup, varargin, isColorbar, colorbarTitle] = mdadata.getplotcolorsettings(varargin{:});
   if ~isempty(cgroup) && numel(cgroup) ~= obj.nRows
      error('Number of elements in color grouping variable should be the same as number of objects!');
   end   
   
   % check if reducing is turned off
   [v, varargin] = getarg(varargin, 'Reduce');         
   if ~isempty(v) || strcmp(v, 'off')
      doReduce = false;
   else
      doReduce = true;
   end   

   % show hidden rows or not?
   [v, varargin] = getarg(varargin, 'ShowExcluded');

   if ~isempty(v) 
      if strcmp(v, 'on') 
         showExcluded = true;
      else
         showExcluded = false;
      end            
   else
      showExcluded = obj.showExcludedRows;
   end

   % show labels or not?
   rowNames = [];
   [showLabels, varargin] = getarg(varargin, 'Labels');   
   if ~isempty(showLabels) && ~strcmp(showLabels, 'none')
      if isempty(obj.rowFullNames) || strcmp(showLabels, 'numbers')
         if showExcluded
            names = textgen('', 1:obj.nRowsAll);
            rowNames = names(~obj.excludedRows);
            rowNamesHidden = names(obj.excludedRows);
         else   
            rowNames = textgen('', 1:obj.nRows);
            rowNamesHidden = [];
         end   
      elseif strcmp(showLabels, 'names')
         rowNames = obj.rowFullNames;
         if showExcluded
            rowNamesHidden = obj.rowFullNamesAll(obj.excludedRows);
         else
            rowNamesHidden = [];
         end   
      end   
   end   

   % marker symbol
   mr = getarg(varargin, 'Marker');
   if isempty(mr)
      mr = 'o';
   end

   % marker colors
   mc = getarg(varargin, 'Color');
   if isempty(mc)
      mc = mdadata.getmycolors(1);
   end   

   mfc = getarg(varargin, 'MarkerFaceColor');
   if isempty(mfc)
      mfc = mc;
   end   

   mec = getarg(varargin, 'MarkerEdgeColor');
   if isempty(mec)
      mec = mc;
   end   
   
   % set default marker size
   ms = getarg(varargin, 'MarkerSize');
   if isempty(ms)
      if strcmp(mr, '.')
         ms = 12;
      else   
         ms = 5;
      end   
   end

   [v, varargin] = getarg(varargin, 'Density');
   if ~isempty(v) && strcmp(v, 'on') 
      hasDensity = true;
   else
      hasDensity = false;
   end   

   if obj.nNumCols == 1
      x = (1:obj.nRows)';
      y = obj.numValues(:, 1);
      colNames = [obj.dimNames{1} obj.colFullNamesWithoutFactors(1)];
   else   
      values = obj.numValues(:, 1:2);
      x = values(:, 1);
      y = values(:, 2);
      colNames = obj.colFullNamesWithoutFactors(1:2);
   end

   nanind = isnan(x) | isnan(y);
   x(nanind) = [];
   y(nanind) = [];

   if doReduce && numel(x) > obj.REDUCE_ROWS_LIMIT
      if hasDensity && ~isempty(cgroup)
         % it is call from densscatter, density already provided
         dens = mdadata.quantizedens(cgroup);
      else   
         % calculate and rescale density of scores
         dens = mdadata.getsampledensity(x, y, 100, 'Quantize', 'on');
      end

      % reduce number of rows according to the density
      ind = mdadata.reducerows(dens, 4);

      x = x(ind);
      y = y(ind);
      if ~isempty(cgroup)
         cgroup = cgroup(ind);
      end   
   end   

   if ~ishold
      cla;
   end

   % show plot - we use PLOT() instead of SCATTER() for speed      
   if isempty(cgroup) || numel(unique(cgroup)) == 1
      hp = plot(double(x), double(y), 'Color', mc, 'Marker', mr, 'MarkerFaceColor', mfc, ...
         'MarkerEdgeColor', mec, 'MarkerSize', ms, 'LineStyle', 'none');   
      if sc
         % show contour of data cloud (convex hull)
         idx = convhull(x, y);
         dooff = false;
         if ~ishold
            dooff = true;
            hold on
         end
         plot(x(idx), y(idx), 'Color', mc)
         if dooff
            hold off
         end   
      end   
   else
      [ucgroup, ~, ind] = unique(cgroup);
      if numel(ucgroup) > size(cmap, 1)
         % number of values in color group larger than number of colors
         ind = fix((cgroup - min(cgroup)) / (max(cgroup) - min(cgroup)) * ...
            (size(cmap, 1) - 1)) + 1; 
      end

      hp = zeros(size(cmap, 1), 1);
      hold on
      for k = 1:size(cmap, 1)
         if any(ind == k)
            hp(k) = plot(x(ind == k),y(ind == k), ...
               'Marker', mr, ...
               'MarkerSize', ms,...
               'Color', cmap(k,:), ...
               'MarkerEdgeColor', mec,...
               'MarkerFaceColor', cmap(k,:), ...
               'LineStyle', 'none',...
               varargin{:});
          end
      end
      hold off
   end

   h.plot = hp;
   if showExcluded
      values = obj.valuesHidden;
      if size(values, 1) > 0            
         if obj.nCols == 1
            xh = 1:size(values, 1);
            yh = values(:, 1);
         else   
            xh = values(:, 1);
            yh = values(:, 2);
         end

         if doReduce && numel(xh) > obj.REDUCE_ROWS_LIMIT
            % calculate and rescale density of scores
            dens = mdadata.getsampledensity(xh, yh, 100, 'Quantize', 'on');

            % reduce number of rows according to the density
            ind = mdadata.reducerows(dens, 4);
            xh = xh(ind);
            yh = yh(ind);               
         end   

         flag = true;
         if ishold
            flag = false;
         end

         if flag
            hold on
         end   

         mc = obj.EXCLUDED_COLOR;
         hh = plot(xh, yh, 'Color', mc, 'Marker', mr, ...
            'MarkerFaceColor', mc, ...
            'MarkerEdgeColor', mec, 'MarkerSize', ms,...
            'LineStyle', 'none');         

         set(hh, 'Color', [1 1 0])
         h.plotHidden = hh;

         if flag
            hold off
         end   
      else
         showExcluded = false;
      end   
   end

   % show axis labels, title and box
   xlabel(colNames{1})         
   ylabel(colNames{2})         
   title(obj.name)
   box on

   % correct axis limits
   if ~ishold
      axis tight
      correctaxislim(10)
   end

   % show colorbar
   if isColorbar
      xc = xlim(); dx = (xc(2) - xc(1));
      yc = ylim(); dy = (yc(2) - yc(1))/2;
      h.colorbar = mdadata.showcolorbar(cmap, cgroup, colorbarTitle, dx, dy);
   end   

   % show labels
   if numel(rowNames) == numel(x)
      h.labels = mdadata.showlabels(x, y, rowNames);

      if showExcluded && numel(rowNamesHidden) == numel(xh)
         h.labelsHidden = mdadata.showlabels(xh, yh, rowNamesHidden);
      end
   end


   if nargout > 0
      varargout{1} = h;
   end   

end
