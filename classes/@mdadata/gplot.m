function varargout = gplot(obj, varargin)
% 'gplot' makes a group plot for line series
%
%   gplot(data)
%   gplot(data, factors)
%   gplot(data, factors, 'ParamName', ParamValue, ...)
%   gplot(data, x, factors)
%   gplot(data, x, factors, 'ParamName', ParamValue, ...)
%
%
% The method makes a line series plot for two or more group of data rows,
% defined by a combination of provided factors. By default, each group 
% has its own color. If dataset with factors is not provided every row 
% of the dataset will be considered as a separate group.
%
% Another optional second argument ('x') is a vector of values for the x
% axis. If it is not provided, a sequence 1:N, where N is number of
% columns in the dataset, will be used. The ticks for x axis in this case
% will be generated based on column names. The method assumes that every
% column of the data is a variable and every row is an observation.
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

   x = [];
   groups = [];
   
   % check if factors are provided
   if numel(varargin) > 0 
      if isnumeric(varargin{1})
      % x values are provided
         x = varargin{1};
         varargin(1) = [];
      end
      
      if numel(varargin) > 0 && isa(varargin{1}, 'mdadata')
      % dataset with factors is provided
         groups = varargin{1};
         varargin(1) = [];
         groups = groups.getgroups();
         nGroups = groups.nCols;         
      end       
   end

   % if no groups - use every row as separate group
   if isempty(groups)
      groups = mdadata(eye(obj.nRows), obj.rowFullNames, obj.rowFullNames);
      nGroups = obj.nRows;            
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
      ms = repmat(8, nGroups, 1);
      ms(strcmp(mr, '.')) = 16;
   else
      if numel(ms) == 1
         ms = repmat(ms, nGroups, 1);
      elseif numel(ms) ~= nGroups
         error('Argument "MarkerSize" should have one value or values for each groups!');
      end   
   end         
   
   h = cell(nGroups, 1);
   hl = [];
   for i = 1:nGroups
      ind = groups.values(:, i) == 1;    
      hk = plot(subset(obj, ind, ':'), ...
               'Color', lc(i, :), 'LineWidth', lw(i), 'LineStyle', ls{i},...
               'Marker', mr{i}, 'MarkerSize', ms(i));               
      h{i} = hk;
      hl = [hl, hk.plot(1)];
      hold on
   end   
   hold off
      
   if showLegend
      legend(hl, groups.colFullNames, 'Location', lp, 'EdgeColor', obj.LEGEND_EDGE_COLOR);
   end

   if nargout > 0
      varargout{1} = h;
   end   
end
