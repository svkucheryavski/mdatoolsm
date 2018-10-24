function varargout = boxplot(obj, varargin)
% 'boxplot' makes a box and whiskers plot for dataset columns
%
%   boxplot(data);
%   boxplot(data, 'ParamName', ParamValue, ...);
%
%   boxplot(data, factors);
%   boxplot(data, factors, 'ParamName', ParamValue, ...);
%
%
% Optional argument "factors" is a dataset with qualitative variables
% (factors) used to split data values into groups and show box and
% whiskers separately for each group on the same axis. In this case the 
% plot will be made only for the first column of data.
%
% Parameters:
% ------------
%
%  "Whisker" - a factor 'w' that influences length of the whiskers. 
%  The whiskers correspond to max and min values, after removing 
%  outliers. The default value for w is 1.5, which corresponds 
%  to 2.7 std interval (99.3% of most common values) if values are 
%  normally distributed. 
%
%  "Labels" - show or not labels for outliers. Possible values are 
%  "none" (default), "names" for name of objects and "numbers"
%  for their numbers. 
%
%
% Examples:
% ---------
%   
%   load people
%   
%   % normal box plot for columns
%   figure
%   boxplot(people(:, {'Height', 'Weight', 'Swim'}));
%
%   % box plot for groups
%   people.factor('Sex', {'Male', 'Female'})
%   figure
%   boxplot(people(:, {'Height', 'Weight'}), people(:, 'Sex'), 'Labels', 'on')
%

   if ~ishold
      cla;
   end

   plotValues = obj.numValues;

   % check if factors are provided and generate groups
   if nargin > 1 && isa(varargin{1}, 'mdadata')
      groups = varargin{1};
      varargin(1) = [];
      groups = groups.getgroups();
      nGroups = groups.nCols;
   else
      groups = [];
      nGroups = 1;
   end

   % set up length of whiskers
   [w, varargin] = getarg(varargin, 'Whisker');
   if isempty(w)
      w = 1.5;
   end

   % set up colors
   c = mdadata.getmycolors(2);
   [bc, varargin] = getarg(varargin, 'EdgeColor');
   if isempty(bc)
      bc = c(1, :);
   end

   [mc, varargin] = getarg(varargin, 'Color');
   if isempty(mc)
      mc = c(2, :);
   end


   % check if labels to show
   [showLabels, ~] = getarg(varargin, 'Labels');
   if strcmp(showLabels, 'names')
      labels = obj.getRowLabels();
   elseif strcmp(showLabels, 'numbers')
      labels = textgen('', 1:numel(obj.nRows));
   else
      labels = [];            
   end

   % calculate number of boxes (n) and generate x, xticklabels
   if nGroups == 1
      n = obj.nNumCols;
      if ~isempty(obj.colValuesAll)
         x = obj.colValues;
      else
         x = 1:n;
      end      
      if ~isempty(obj.colNamesAll) && isempty(obj.colValuesAll)
         xticklabel = obj.colFullNamesWithoutFactors;
      else
         xticklabel = {};
      end      
      m = mean(plotValues);
   else
      n = groups.nCols;
      if ~isempty(groups.colValuesAll)
         x = groups.colValues;
      else
         x = 1:n;
      end
      if ~isempty(groups.colNamesAll)
         xticklabel = groups.colFullNames;
      else
         xticklabel = {};
      end      
   end

   % correct number of ticks
   if numel(x) < 12
      xtick = x;
   else
      xtick = x(unique(round(linspace(1, numel(x), 12))));
   end

   % calculate width of boxes and limits
   if n > 1
      boxWidth = (max(x) - min(x)) / n * 0.75;
      lims = [1 20];
   else
      boxWidth = 1;
      lims = [50 10];
   end   

   outX = [];
   outY = [];
   outLabels = [];

   % loop for plotting boxes and whiskers
   hold on
   for i = 1:n
      if nGroups == 1
         v = plotValues(:, i);
      else
         ind = groups.values(:, i) == 1;
         v = plotValues(ind, 1);
         if ~isempty(obj.rowNamesAll)
            plotRowNames = obj.rowFullNames(ind);
         else
            plotRowNames = {};
         end

         m (i) = mean(v);
      end   

      % calculate quartiles and limits
      q1 = mdapercentile(v, 25);
      q2 = mdapercentile(v, 50);
      q3 = mdapercentile(v, 75);
      h = q3 - q1;
      up = q3 + h * w;
      low = q1 - h * w;

      % show box
      if abs(h) > 0
         rectangle('Position', [x(i) - boxWidth/2, q1, boxWidth, h], 'EdgeColor', bc)
      end   
      line([x(i) - boxWidth/2, x(i) + boxWidth/2], [q2 q2], 'Color', mc);

      % detect outliers
      outind = v < low | v > up;
      outY = [outY; v(outind)];
      outX = [outX; x(i) * ones(sum(outind), 1)];

      if ~isempty(labels)
         outLabels = [outLabels; labels(outind)];            
      end

      % show whiskers
      mn = min(v(~outind));            
      line([x(i), x(i)], [mn, q1], 'Color', bc);
      line([x(i) - boxWidth/2, x(i) + boxWidth/2], [mn mn], 'Color', bc);

      mx = max(v(~outind));
      line([x(i), x(i)], [q3 mx], 'Color', bc);
      line([x(i) - boxWidth/2, x(i) + boxWidth/2], [mx mx], 'Color', bc);            
   end

   % plot outliers and average values
   if ~isempty(outX)
      scatter(double(outX), double(outY), 'x', 'MarkerEdgeColor', bc)            
   end   
   plot(x, m, '.', 'Color', mc, 'LineStyle', 'none');
   hold off

   if ~isempty(labels)
      mdadata.showlabels(outX, outY, outLabels, 'right');
   end   

   if ~isempty(xticklabel)
      set(gca, 'XTick', xtick, 'XTickLabel', xticklabel(xtick));
   end

   if nGroups == 1
      xlabel(obj.dimNames{2})         
      ylabel('')    
      title(obj.name)
   else
      xlabel(groups.dimNames{2})
      ylabel(obj.getColLabels(1))
      title(obj.name)
   end

   box on
   if strcmp(get(gca, 'NextPlot'), 'replace')
      correctaxislim([5 5 0.01 5], [min(x) - boxWidth/1.8 max(x) + boxWidth / 1.8]);
   end

   if nargout > 0
      varargout{1} = h;
   end            
end
