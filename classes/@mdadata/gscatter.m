function varargout = gscatter(obj, varargin)
% 'gscatter' makes a group scatter plot
%
%   gscatter(data, factors)
%   gscatter(data, factors, 'ParamName', ParamValue, ...)
%
%
% The method makes a scatter plot for two or more group of points,
% defined by a combination of provided factors. By default, each group 
% has its own color. If more columns exist, the method will generate
% a figure with several subplots for all pairwise combinations of the
% columns. The maximal number of combinations is limited by 10, so if
% more than five columns are available, the method will show plots
% only for the first five.
%
% Parameters:
% -----------
%  "Labels" - show or not labels for the data points. Possible
%  values are "none" (default), "names" for name of objects and "numbers"
%  for their numbers. 
%
%  "Marker" - one value or a vector with values (one for each group) 
%  for the marker symbol.
%
%  "MarkerEdgeColor" - one value or a vector with values (one for each group) 
%  for the marker edge color. If color is specified using RGB values, the
%  parameter should be a matrix with as many rows as many groups
%  exist.
%
%  "MarkerFaceColor" - one value or a vector with values (one for each group) 
%  for the marker edge color. If color is specified using RGB values, the
%  parameter should be a matrix with as many rows as many groups
%  exist.
%
%  "MarkerSize" - one value or a vector with values (one for each group) 
%  for the marker size.
%
%  "ShowContour" - show or not a contour around the data points belonging to each group. 
%  It uses convex hull to find the outer points. 
%
%
% Examples:
% ---------
%
%   load people
%   people.factor('Sex', {'Male', 'Female'})
%   
%   figure
%   subplot(1, 2, 1)
%   gscatter(people(:, 'Height:Weight'), people(:, 'Sex'))
%   
%   subplot(1, 2, 2)
%   gscatter(people(:, 'Height:Weight'), people(:, 'Sex'), 'Labels', 'on',...
%     'MarkerSize', [7 10], 'Marker', 'so', 'MarkerFaceColor', 'rb')
%   
%   figure
%   gscatter(people, people(:, 'Sex'), 'LegendLocation', 'best')
%
%
   if ~ishold
      cla;
   end

   % check if factors are provided
   if numel(varargin) > 0 && isa(varargin{1}, 'mdadata')
      groups = varargin{1};
      varargin(1) = [];
   else
      h = scatter(obj, varargin{:});
      if nargout > 0
         varargout{1} = h;
      end
      return
   end

   objs = mdasplit(obj, groups);
   nGroups = numel(objs);

   [args, varargin] = mdadata.getgscatteroptions(nGroups, varargin{:});

   % show hidden rows or not?
   [v, varargin] = getarg(varargin, 'ShowExcluded');         
   if isempty(v) || strcmp(v, 'off')
      showExcluded = false;
   else
      showExcluded = true;
   end

   % show labels or not?
   labelsHidden = [];
   showLabels = getarg(varargin, 'Labels');   
   if ~isempty(showLabels) && strcmp(showLabels, 'names')
      labelsHidden = obj.rowFullNamesAll(obj.excludedRows);
   end   

   hp = cell(nGroups, 1);
   legendStr = cell(nGroups, 1);
   lh = [];
   hold on               
   for iGroup = 1:nGroups
      hp{iGroup} = objs{iGroup}.scatter(args{iGroup}{:});                
      legendStr{iGroup} = objs{iGroup}.name;
      lh = [lh; hp{iGroup}.plot];
   end
   hold off
   h.plots = hp;
   
   if showExcluded
      values = obj.valuesHidden;
      if obj.nCols == 1
         xh = 1:size(values, 1);
         yh = values(:, 1);
      else   
         xh = values(:, 1);
         yh = values(:, 2);
      end

      mr = get(h.plots{1}.plot, 'Marker');
      ms = get(h.plots{1}.plot, 'MarkerSize');
      
      hold on
      hh.plotHidden = plot(xh, yh, 'Color', obj.EXCLUDED_COLOR, 'Marker', mr, ...
         'MarkerFaceColor', obj.EXCLUDED_COLOR, ...
         'MarkerEdgeColor', obj.EXCLUDED_COLOR, 'MarkerSize', ms,...
         'LineStyle', 'none');                           
      hold off
   end

   if strcmp(get(gca, 'NextPlot'), 'replace')
      if numel(legendStr) > 1
         legend(lh, legendStr)
         mdadata.legend(lh, legendStr);
      end

      title(obj.name)
      box on
      correctaxislim(10);                  
   end

   if ~isempty(labelsHidden) && showExcluded
      h.labelsHidden = mdadata.showlabels(xh, yh, labelsHidden);
   end

   if nargout > 0
      varargout{1} = h;
   end   
end
