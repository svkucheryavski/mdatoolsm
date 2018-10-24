function varargout = plot(obj, varargin)
% 'plot' makes a scatter plot for 'mdadata' class object
%
%   plot(data);
%   plot(data, 'ParamName', ParamValue, ...);
%   plot(data, x);
%   plot(data, x, 'ParamName', ParamValue, ...);
%
%
% The method is based on the standard 'plot()' function and give some extra 
% functionality, such as automatic labels for axis, grouping plot lines 
% with color, etc. If output variable is specified the method returns a structure or 
% a cell array with plot elements handles (plot handle, labels handle, etc).
% 
% The only mandatory argument is a dataset (object of class 'mdadata').
% The optional second argument ('x') is a vector of values for the x
% axis. If it is not provided, a sequence 1:N, where N is number of
% columns in the dataset, will be used. The ticks for x axis in this case
% will be generated based on column names. The method assumes that every
% column of the data is a variable and every row is an observation.
%
% Parameters:
% ------------
% All parameters for Matlab's 'plot()' function (e.g. "Color", "LineStyle", etc.)
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
%  values are "on" and "off". By default colorbar is not shown.
%
%  "ColorbarTitle" - a text string with title to be shown on top of
%  colorbar.
%
%  "Groupby" - allows to make a line plot with color groups, by 
%  providing one or several factors as values for this parameter.
%
%  "Reduce" - if data has many rows (more than 2000) this number will
%  be reduced to speed up the plot by removing rows which are similar. 
%  The reducing algorithm is based on PCA (Principal Component
%  Analysis) and density of the rows on scores plot for first two 
%  components. Set this parameter to "off" to avoid reducing. 
%  
%
% Examples:
% ---------
%   
%   load simdata
%   
%   % make plot of UV/Vis spectra and change standard properties
%   figure
%   plot(spectra, 'Color', 'b', 'LineStyle', '--');
%   
%   % use manual x values
%   x = 1:spectra.nCols;
%   figure
%   plot(spectra, x);
%   xlabel('Wavenumbers');
%
%   % using color grouping (concentration values)
%   figure
%   subplot(3, 1, 1)
%   plot(spectra, 'Colorby', conc(:, 1));
%   subplot(3, 1, 2)
%   plot(spectra, 'Colorby', conc(:, 1), 'Colormap', @summer);
%   subplot(3, 1, 3)
%   plot(spectra, 'Colorby', conc(:, 1), 'Colorbar', 'on');
%
%

   % check if x values are provided and set up x and xtick values
   xticklabel = {};
   x = [];
   if numel(varargin) > 0 && isnumeric(varargin{1})
      x = varargin{1};
      varargin(1) = [];
   end

   % check if this is a group plot
   [gb, varargin] = getarg(varargin, 'Groupby');   
   if ~isempty(gb)
      h = gplot(obj, gb, varargin{:});
      if nargout > 0
         varargout{1} = h;
      end
      return      
   end   

   % check if reducing is turned off
   [v, varargin] = getarg(varargin, 'Reduce');         
   if ~isempty(v) || strcmp(v, 'off')
      doReduce = false;
   else
      doReduce = true;
   end   

   % set default marker size
   mr = getarg(varargin, 'Marker');
   if ~isempty(mr)
      [ms, varargin] = getarg(varargin, 'MarkerSize');
      if isempty(ms)
         if strcmp(mr, '.')
            ms = 16;
         else   
            ms = 8;
         end
         varargin = [varargin, 'MarkerSize', ms];
      end   
   end

   % check if excluded variables will be shown
   [v, varargin] = getarg(varargin, 'ShowExcluded');         
   if ~isempty(v) 
      if strcmp(v, 'on') 
         showExcluded = true;
      else
         showExcluded = false;
      end            
   else
      showExcluded = obj.showExcludedCols;
   end

   % get values and various parameters
   % the serIncl/serExcl is a matrix with start
   % and end indices of series in variables         
   if showExcluded
      % show excluded columns but keep excluded rows hidden
      values = obj.valuesAll(~obj.excludedRows, ~obj.factorCols);
      nCols = size(values, 2);
      indExcl = find(obj.excludedCols(~obj.factorCols));
      indIncl = find(~obj.excludedCols(~obj.factorCols));
      serExcl = getserind(indExcl);
      serIncl = getserind(indIncl);
   else
      values = obj.numValues;
      nCols = size(values, 2);
      indIncl = 1:nCols;
      serIncl = getserind(indIncl);
   end
   
   % continue with defining x-values if they were not provided as argument
   if isempty(x)
      % colValues is a new property, for old object we need a workaround
      if isprop(obj, 'colValuesAll') && ~isempty(obj.colValuesAll)
         if showExcluded
            x = obj.colValuesAllWithoutFactors;
         else   
            x = obj.colValuesWithoutFactors;
         end   
      else
         x = 1:nCols;
         if ~isempty(obj.colNamesAll)
            if showExcluded
               xticklabel = obj.colFullNamesAllWithoutFactors;
            else   
               xticklabel = obj.colFullNamesWithoutFactors;
            end   
         end
      end
   end
   
   % check if number of x-values is correct
   if numel(x) ~= nCols
      error('Number of x values should be the same as number of columns in dataset!');
   end 

   % define values for xticks if needed
   if numel(x) < 12 && ~isempty(xticklabel)
      xtick = x;
   else
      xtick = unique(round(linspace(1, numel(x), 12)));
   end

   % check if values for color grouping are provided
   [cmap, cgroup, varargin, isColorbar, colorbarTitle, cgroupLevels] = mdadata.getplotcolorsettings(varargin{:});
   if ~isempty(cgroup) && numel(cgroup) ~= obj.nRows
      error('Number of elements in color grouping variable should be the same as number of objects!');
   end   

   if doReduce && size(values, 1) > obj.REDUCE_ROWS_LIMIT
      % make pca of the values and get scores for two components
      dd = bsxfun(@minus, values, mean(values));
      [~, ~, v] = svd(dd, 0);
      s = dd * v(:, 1:2);

      % calculate and rescale density of scores
      dens = mdadata.getsampledensity(s(:, 1), s(:, 2), 100, 'Quantize', 'on');

      % reduce number of rows according to the density
      ind = mdadata.reducerows(dens);
      values = values(ind, :);
      if ~isempty(cgroup)
         cgroup = cgroup(ind);
      end   
      clear('v', 's', 'ind');
   end   

   % check if "hold on" was activated before 
   turnHoldOn = false;
   if ~ishold
      cla;
   else
      turnHoldOn = true;
   end

   
   if isempty(cgroup)
      % normal plot
      hold on
      for i = 1:size(serIncl, 1)
         indC = indIncl(serIncl(i, 1):serIncl(i, 2));
         if indC(1) > 1
            indC = [indC(1) - 1; indC];
         end
         if indC(end) < nCols
            indC = [indC; indC(end) + 1];
         end   
         hp = plot(x(indC), values(:, indC)', varargin{:});
      end   
      hold off
   else
      % plot with color groups
      indR = fix((cgroup - min(cgroup)) / (max(cgroup) - min(cgroup)) * (size(cmap, 1) - 1)) + 1;
      hp = cell(size(cmap, 1), 1);
      hold on
      for k = 1:size(cmap, 1)
         if any(indR == k)
            hh = [];
            for i = 1:size(serIncl, 1)
               indC = indIncl(serIncl(i, 1):serIncl(i, 2));
               if indC(1) > 1
                  indC = [indC(1) - 1; indC];
               end
               if indC(end) < nCols
                  indC = [indC; indC(end) + 1];
               end   
               hl = plot(x(indC), values(indR == k, indC)', 'Color', cmap(k,:), varargin{:});
               hh = [hh; hl];
            end   
            hp{k} = hh;
         end
      end
      hold off
   end
   h.plot = hp;

   if showExcluded && any(obj.excludedCols)
      % show plot for excluded variables
      lc = obj.EXCLUDED_COLOR;
      [~, varargin] = getarg(varargin, 'Color');
      [~, varargin] = getarg(varargin, 'Marker');
      [~, varargin] = getarg(varargin, 'MarkerSize');

      hold on
      for i = 1:size(serExcl, 1)
         indC = indExcl(serExcl(i, 1):serExcl(i, 2));
         if numel(indC) == 1
            hp = plot(x(indC), values(:, indC)', 'Color', lc, 'Marker', '.', ...
               'MarkerSize', 8, varargin{:});
         else
            hp = plot(x(indC), values(:, indC)', 'Color', lc, varargin{:});
         end
      end
      hold off
   end
   h.plotHidden = hp;

   % correct axis limits
   %if strcmp(get(gca, 'NextPlot'), 'replace') && abs(min(x) - max(x)) > 0.001
   %   correctaxislim([5, 5, 0, 5], [min(x) max(x)]);
   %end

   % show colorbar
   if isColorbar
      l = axis();
      dx = (l(2) - l(1));
      dy = (l(4) - l(3))/2;
      h.colorbar = mdadata.showcolorbar(cmap, cgroup, colorbarTitle, dx, dy, cgroupLevels);
   end

   % show xticklabel if they are not empty
   if ~isempty(xticklabel)
      set(gca, 'XTick', xtick, 'XTickLabel', xticklabel(xtick));
   end

   if ~isempty(obj.dimNames) && numel(obj.dimNames) == 2
      xlabel(obj.dimNames{2})         
   end

   ylabel('')    
   title(obj.name)
   box on

   % if "hold on" was activated before the plot do it again 
   if turnHoldOn 
      hold on;
   end
   
   if nargout > 0
      varargout{1} = h;
   end            
end

