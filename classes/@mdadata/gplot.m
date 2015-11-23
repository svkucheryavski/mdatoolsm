function varargout = gplot(obj, varargin)
% 'gplot' makes a group plot for line series
%
%   gplot(data)
%   gplot(data, factors)
%   gplot(data, factors, 'ParamName', ParamValue, ...)
%
%
% The method makes a line series plot for two or more group of data rows,
% defined by a combination of provided factors. By default, each group 
% has its own color. If dataset with factors is not provided every row 
% of the dataset will be considered as a separate group.
%
% Parameters:
% -----------
%  "Legend" - shor or nor legend for the groups. Possible values are
%  "on" (default) and "off".
%
%  "LegendLocation" - if legend is on, defines location for the legend. 
%  The values are similar to what are used in 'legend()' function.
%
%  "Color" - one value or a vector with values (one for each group) 
%  for the line color. If color is specified using RGB values, the
%  parameter should be a matrix with as many rows as many groups
%  exist.
%
%  "LineWidth" - one value or a vector with values (one for each group) 
%  for the the line width.
%
%  "LineStyle" - one value or a cell vector with values (one for each group) 
%  for the the line style.
%
%  "Marker" - one value or a vector with values (one for each group) 
%  for the marker symbol (default "none").
%
%  "MarkerSize" - one value or a vector with values (one for each group) 
%  for the marker size.
%
%
% Examples:
% ---------
%     
%   % prepare a dataset
%   v = [75 40 32; 68 35 31];
%   data = mdadata(v, {'Cal', 'Val'}, {'PC1', 'PC2', 'PC3'},...
%     {'Explained variance', 'Components'}, 'Explained variance');
%   
%   % group plot without factors
%   figure
%   subplot(1, 2, 1)
%   gplot(data)
%   
%   subplot(1, 2, 2)
%   gplot(data, 'Marker', '.', 'Color', 'rg', 'LineStyle', {'--', ':'})
%
%   % group plot with factors
%   load simdata
%   datasplit = mdadata([zeros(100, 1); ones(50, 1)]);
%   datasplit.factor(1, {'Cal', 'Val'})
%
%   gplot(spectra, datasplit)
%
%

   if ~ishold
      cla;
   end

   % check if factors are provided
   if numel(varargin) > 0 
      if isa(varargin{1}, 'mdadata')
      % dataset with factors is provided
         groups = varargin{1};
         varargin(1) = [];
         groups = groups.getgroups();
         nGroups = groups.nCols;
      else
      % consider every row as a separate group
         groups = [];
         nGroups = obj.nRows;
      end   
   else
      groups = [];
      nGroups = obj.nRows;            
   end

   if isempty(groups)
      groups = mdadata(eye(nGroups), obj.rowNames, obj.rowNames);
   end

   % check if excluded variables will be shown
   [v, varargin] = getarg(varargin, 'ShowExcluded');

   if isempty(v) || ~strcmp(v, 'on')
      showExcluded = false;
   else
      showExcluded = true;
   end   

   % get values and various parameters
   % the serIncl/serExcl is a matrix with start
   % and end indices of series in variables         
   if showExcluded
      values = obj.valuesAll(~obj.excludedRows, ~obj.factorCols);
      nCols = size(values, 2);
      indExcl = find(obj.excludedCols(~obj.factorCols));
      indIncl = find(~obj.excludedCols(~obj.factorCols));
      serExcl = getserind(indExcl);
      serIncl = getserind(indIncl);
      colNames = obj.colFullNamesAll(~obj.factorCols);
   else
      values = obj.numValues;
      nCols = size(values, 2);
      indIncl = 1:nCols;
      serIncl = getserind(indIncl);
      colNames = obj.colFullNamesWithoutFactors;
   end

   % check if x values are provided and set up x and xtick values
   if numel(varargin) > 0 && isnumeric(varargin{1})
      x = varargin{1};
      varargin(1) = [];

      if numel(x) ~= nCols
         error('Number of x values should be the same as number of columns in dataset!');
      end
      xticklabel = [];
   else   
      x = 1:nCols;
      xticklabel = colNames;
   end

   % check legend and labels
   [v, varargin] = getarg(varargin, 'Legend');
   if isempty(v)
      if groups.nCols < 2
         showLegend = false;
      else
         showLegend = true;
      end   
   elseif ~isempty(v)  
      if strcmp(v, 'on')
         showLegend = true;
      else
         showLegend = false;
      end
   end

   [lp, varargin] = getarg(varargin, 'LegendLocation');
   if isempty(lp)
      lp = 'NorthEast';
   end

   % check color settings
   [lc, varargin] = getarg(varargin, 'Color');
   if isempty(lc)
      lc = mdadata.getmycolors(nGroups);
   else            
      if isnumeric(lc)
         nlc = size(lc, 1);
      else
         nlc = numel(lc);
         if size(lc, 2) > size(lc, 1)
            lc = lc';
         end   
      end

      if nlc == 1
         lc = repmat(lc, nGroups, 1);
      elseif nlc ~= nGroups
         error('Number of colors in "Color" should be the same as number of groups!');
      end   
   end   

   % check line and marker parameters
   [lw, varargin] = getarg(varargin, 'LineWidth');
   if isempty(lw) 
      lw = ones(nGroups, 1);
   else
      if numel(lw) == 1
         lw = repmat(lw, nGroups, 1);
      elseif numel(lw) ~= nGroups
         error('Argument "LineWidth" should have one value or values for each groups!');
      end   
   end

   [ls, varargin] = getarg(varargin, 'LineStyle');
   if isempty(ls) 
      ls = repmat({'-'}, nGroups, 1);
   else
      if ischar(ls)
         ls = {ls};
      end   
      if numel(ls) == 1 
         ls = repmat(ls, nGroups, 1);
      elseif numel(ls) ~= nGroups
         error('Argument "LineStyle" should have one value or values for each groups!');
      end   
   end

   [mr, varargin] = getarg(varargin, 'Marker');
   if isempty(mr) 
      mr = repmat({'none'}, nGroups, 1);
   else
      if ischar(mr)
         mr = {mr};
      end   
      if numel(mr) == 1 
         mr = repmat(mr, nGroups, 1);
      elseif numel(mr) ~= nGroups
         error('Argument "Marker" should have one value or values for each groups!');
      end   
   end

   [ms, ~] = getarg(varargin, 'MarkerSize');
   if isempty(ms) 
      ms = repmat(15, nGroups, 1);
   else
      if numel(ms) == 1
         ms = repmat(ms, nGroups, 1);
      elseif numel(ms) ~= nGroups
         error('Argument "MarkerSize" should have one value or values for each groups!');
      end   
   end         

   % set X ticks
   if numel(x) < 12
      xtick = x;
   else
      tickind = unique(round(linspace(1, numel(x), 12)));
      xtick = x(tickind);
      xticklabel = xticklabel(tickind);
   end

   hold on
   h = cell(nGroups, 1);
   hl = zeros(nGroups, 1);
   for iGroup = 1:nGroups
      indR = groups.values(:, iGroup) == 1;
      hk = [];
      if any(indR)
         for i = 1:size(serIncl, 1);
            indC = indIncl(serIncl(i, 1):serIncl(i, 2));
            if indC(1) > 1
               indC = [indC(1) - 1; indC];
            end
            if indC(end) < nCols
               indC = [indC; indC(end) + 1];
            end   
            hk = [hk; plot(x(indC), values(indR, indC)',...
               'Color', lc(iGroup, :), 'LineWidth', lw(iGroup), 'LineStyle', ls{iGroup},...
               'Marker', mr{iGroup}, 'MarkerSize', ms(iGroup, :))];               
         end          
         h{iGroup} = hk;
         hl(iGroup) = hk(1);
      end   
   end
   hold off
   indl = ~(hl == 0);         

   if showExcluded && any(obj.excludedCols)
      lc = obj.EXCLUDED_COLOR;
      [~, varargin] = getarg(varargin, 'Color');
      [~, varargin] = getarg(varargin, 'Marker');
      [~, varargin] = getarg(varargin, 'MarkerSize');
      hold on
      for i = 1:size(serExcl, 1);
         indC = indExcl(serExcl(i, 1):serExcl(i, 2));
         hp = plot(x(indC), values(:, indC)', 'Color', lc, 'Marker', '.', ...
            'MarkerSize', 8, varargin{:});
      end   
      hold off         
   end

   xlabel(obj.dimNames{2});
   title(obj.name);
   set(gca, 'XTick', xtick, 'XTickLabel', xticklabel);
   box on

   if showLegend
      legend(hl(indl), groups.colFullNames(indl), 'Location', lp, 'EdgeColor', obj.LEGEND_EDGE_COLOR);
   end

   if strcmp(get(gca, 'NextPlot'), 'replace')
      correctaxislim(5);
   end

   if nargout > 0
      varargout{1} = h(indl);
   end   
end
