function varargout = gbar(obj, varargin)
% 'gbar' makes a group bar plot 
%
%   gbar(data)
%   gbar(data, 'ParamName', ParamValue, ...)
%
%
% The method makes a bar plot for two or more data rows considered as 
% groups. By default, each group has its own color. 
%
% Parameters:
% -----------
%  "Labels" - show or not labels for the bars. Possible
%  values are "none" (default), "names" for name of objects, "numbers"
%  for their numbers and "values" for the bar values (height). This 
%  option does not work with HG2 graphics engine (Matlab 2014b), the 
%  solution is coming in next release.
%  
%  "LabelsSigfig" - how many significant figures to use for the label values.
%
%  "Legend" - shor or nor legend for the groups. Possible values are
%  "on" (default) and "off".
%
%  "LegendLocation" - if legend is on, defines location for the legend. 
%  The values are similar to what are used in 'legend()' function.
%
%  "EdgeColor" - one value or a vector with values (one for each group) 
%  for the bar edge color. If color is specified using RGB values, the
%  parameter should be a matrix with as many rows as many groups
%  exist.
%
%  "FaceColor" - one value or a vector with values (one for each group) 
%  for the bar face color. If color is specified using RGB values, the
%  parameter should be a matrix with as many rows as many groups
%  exist.
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
%   gbar(data)
%   
%   subplot(1, 2, 2)
%   gbar(data, 'FaceColor', 'rb', 'Labels', 'on', 'LegendLocation', 'best')
%

   % check if x values are provided and set up x and xtick values
   xticklabel = {};
   x = [];
   if numel(varargin) > 0 && isnumeric(varargin{1})
      x = varargin{1};
      varargin(1) = [];
   end
   
   % get groups
   nGroups = obj.nRows;
   bw = getarg(varargin, 'BarWidth');
   if isempty(bw)
      varargin = [varargin 'BarWidth', 0.75];
   else
      varargin = [varargin 'BarWidth', bw];            
   end   

   % check color settings            
   [fc, varargin] = getarg(varargin, 'FaceColor');
   if isempty(fc)
      fc = mdadata.getmycolors(nGroups);
   else
      if isnumeric(fc)
         nfc = size(fc, 1);
      else
         nfc = numel(fc);
         if size(fc, 2) > size(fc, 1)
            fc = fc';
         end   
      end

      if nfc ~= nGroups
         error('Number of colors in "FaceColor" should be the same as number of groups!');
      end   
   end   

   [ec, varargin] = getarg(varargin, 'EdgeColor');
   if isempty(ec)
      ec = repmat('none', nGroups, 1);
   else
      if isnumeric(ec)
      % color is an array with numbers
         nec = size(ec, 1);
      else
      % color is a vector with symbols   
         nec = numel(ec);
         if size(ec, 2) > size(ec, 1)
            ec = ec';
         end                  
      end

      if nec ~= nGroups || nec == 1
         error('Number of colors in "EdgeColor" should be one or the same as number of groups!');
      end               
   end   

   % get values
   plotValues = obj.numValues;
   
   if isempty(x)
      % colValues is a new property, for old object we need a workaround
      if isprop(obj, 'colValuesAll') && ~isempty(obj.colValuesAll)
         x = obj.colValuesWithoutFactors;
      else
         x = 1:size(plotValues, 2);
         if ~isempty(obj.colNamesAll)
            xticklabel = obj.colFullNamesWithoutFactors;
         end
      end
   end
   
   if numel(x) < 12
      xtick = x;
   else
      xtick = unique(round(linspace(1, numel(x), 12)));
   end

   % check other parameters
   [sigfig, varargin] = getarg(varargin, 'LabelsSigfig');
   if isempty(sigfig) || ~isnumeric(sigfig) || sigfig < 1 || sigfig > 10
      sigfig = 3;
   end

   [showLabels, varargin] = getarg(varargin, 'Labels');
   if strcmp(showLabels, 'names') && ~isempty(obj.colNamesAll)
      labels = repmat(obj.colNamesWithoutFactors, obj.nRows, 1);
   elseif strcmp(showLabels, 'numbers')
      labels = repmat(textgen('', 1:numel(obj.nNumCols)), obj.nRows, 1);
   elseif strcmp(showLabels, 'values')
      labels = cell(obj.nRows, obj.nNumCols);
      for i = 1:obj.nRows               
         labels(i, :) = cellstr(num2str(plotValues(i, :)', sigfig))';
      end   
   else   
      labels = [];            
   end

   isNaN = false;
   if size(plotValues, 2) == 1
      plotValues = [plotValues, nan(size(plotValues))];
      isNaN = true;
   end
   h = bar(x, plotValues', 0.98, 'grouped', varargin{:}); 

   for i = 1:numel(h)            
      set(h(i), 'FaceColor', fc(i, :), 'EdgeColor', ec(i, :));
      xl = get(get(h(i), 'Children'), 'XData');
      if ~isempty(labels) && ~isempty(xl) 
         % 2014a or older
         % TODO: find solution for HG2 (2014b) 
            mdadata.showlabels((xl(3, :) + xl(1, :)) / 2, plotValues(i, :), ...
               labels(i, :), 'top');
      end            
   end   

   if ~isempty(xticklabel)
      set(gca, 'XTick', xtick, 'XTickLabel', xticklabel);
   end

   xlabel(obj.dimNames{2})            
   ylabel('')                     
   title(obj.name);            
   box on
   axis auto


   if obj.nRows > 1
      legend(obj.rowNames, 'EdgeColor', obj.LEGEND_EDGE_COLOR);
   end

%    if isNaN
%       xlim([0 2]);
%    end

   if nargout > 0
      varargout{1} = h;
   end   
end   
