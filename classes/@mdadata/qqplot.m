function varargout = qqplot(obj, varargin)
% 'qqplot' makes a quantile-quantile plot for selected columns of dataset.
%
%   qqplot(data)
%   qqplot(data, 'ParamName', ParamValue, ...)
%   
%   qqplot(data, factors)
%   qqplot(data, factors, 'ParamName', ParamValue, ...)
%
%
% Quantile-quantile plot for normal distribution calculates real and theoretical 
% quantiles of each data value as if the values are distributed normally.
% The calculated values are shown as a scatter plot and can be used to
% evaluate if data is distributed normally or deviates from normal
% distribution.      
%
% If dataset has more than one column, the method  will make the plot 
% for the first column only.
%
% Optional argument "factors" is a dataset with qualitative variables
% (factors) used to split values to groups and show points separately 
% for each group on the same axis.
%
%
% Parameters:
% -----------
% All parameters for Matlab's 'plot()' function will work. Extra parameters 
% are shown below. If factors are used the color parameters should have 
% a value for each group, made by combination of the factors.
%
%  "ShowNormal" - show or not a line for ideal normal distribution.
%  Possible values are "off" and "on" (default). 
% 
%  "Labels" - show or not labels for the data points. Possible
%  values are "none" (default), "names" for name of objects and "numbers"
%  for their numbers. 
%
%  "LineColor" - a color of fitted line (the color of points can be
%  changed using parameter "Color")
%
%
% Examples:
% ---------
%
%   load people
%
%   figure
%   qqplot(people(:, 'Height'), 'Labels', 'on')   
%   
%   people.factor('Sex', {'Male', 'Female'})
%   figure
%   qqplot(people(:, 'IQ'), people(:, 'Sex'))
%
%

   if ~ishold
      cla;
   end

   % check arguments for groups and nbins
   if nargin > 1 && isa(varargin{1}, 'mdadata') 
      groups = varargin{1};
      varargin(1) = [];
      groups = groups.getgroups();
      nGroups = groups.nCols;            
   else
      groups = [];
      nGroups = 1;            
   end

   % limit number of variables by 12
   values = obj.numValues(:, 1);

   % check color settings
   [fa, varargin] = getarg(varargin, 'FaceAlpha');
   if isempty(fa)
      fa = 0.5;
   end

   [mc, varargin] = getarg(varargin, 'Color');
   if isempty(mc)
      mc = mdadata.getmycolors(nGroups);
   else
      if isnumeric(mc)
         nmc = size(mc, 1);
      else
         nmc = numel(mc);
         if size(mc, 2) > size(mc, 1)
            mc = mc';
         end   
      end

      if nmc ~= nGroups
         error('Number of colors in "Color" should be the same as number of groups!');
      end   
   end   

   [lc, varargin] = getarg(varargin, 'LineColor');
   if isempty(lc)
      lc = mc;
   else
      if isnumeric(lc)
         nlc = size(lc, 1);
      else
         nlc = numel(lc);
         if size(lc, 2) > size(lc, 1)
            lc = lc';
         end                                 
      end

      if nlc ~= nGroups
         error('Number of colors in "LineColor" should be the same as number of groups!');
      end               
   end   

   [v, varargin] = getarg(varargin, 'ShowNormal');
   if ~isempty(v) && strcmp(v, 'off')
      showLine = false;
   else 
      showLine = true;
   end   

   % check line and marker parameters
   [lw, varargin] = getarg(varargin, 'LineWidth');
   if isempty(lw) 
      lw = 1;
   end

   [ls, varargin] = getarg(varargin, 'LineStyle');
   if isempty(ls) 
      ls = '--';
   end

   if isempty(find(strcmp(varargin, 'Marker'), 1))
      varargin = [{'Marker', 'o'} varargin];
   end   

   if isempty(find(strcmp(varargin, 'MarkerSize'), 1))
      varargin = [{'MarkerSize', 8} varargin];
   end   

   rowNames = obj.rowNames;

   % check if labels to show
   [showLabels, varargin] = getarg(varargin, 'Labels');
   if strcmp(showLabels, 'names') && ~isempty(obj.rowNames)
      labels = rowNames;
   elseif strcmp(showLabels, 'numbers')
      labels = textgen('', 1:obj.nRows);
   else
      labels = [];            
   end         

   hold on
   hp = zeros(nGroups, 1);
   hl = zeros(nGroups, 1);
   for nGroup = 1:nGroups
      if nGroups > 1
         ind = groups.values(:, nGroup) == 1;
         v = values(ind, 1);
      else
         ind = 1:size(values, 1);
         v = values(:, 1);
      end

      [v, sortind] = sort(v);

      n = numel(v);
      k = 1:n;
      x = (k - 0.5)/n;            
      x = mdatinv(x, 100000)';

      hp(nGroup) = plot(x, v, 'MarkerEdgeColor', 'none', 'MarkerFaceColor', mc(nGroup, :),...
         'LineStyle', 'none', varargin{:});

      if showLine && numel(x) > 1
         qx = mdapercentile(x, [25 75]);
         qy = mdapercentile(v, [25 75]);
                  
         b1 = diff(qy)/diff(qx);
         b0 = (qy(1) + qy(2))/2 - b1 * (qx(1) + qx(2))/2;               

         xp = [min(x), max(x)];
         yp = b0 + b1 * xp;

         h.normalLine = line(xp, yp, 'Color', lc(nGroup, :), 'LineStyle', ls, 'LineWidth', lw);
      end

      if ~isempty(labels)
         l = labels(ind);
         h.labels = mdadata.showlabels(x, v, l(sortind), 'top');      
      end            
   end     
   hold off

   axis auto
   title(obj.colFullNamesWithoutFactors{1})         
   ylabel('Data quantiles');         
   xlabel('Normal theoretical quantiles');
   box on
   correctaxislim([10 10])

   if nGroups > 1
         % show legend and set transparancy for legend items
      h.legend = legend(hp, groups.colFullNames, 'EdgeColor', obj.LEGEND_EDGE_COLOR);
%                c = get(hl, 'Children');
%                hp = arrayfun(@(x) allchild(x), c(1:2:end));
%                set(hp, 'FaceAlpha', fa);                              
   end
   h.plot = hp;         
   if nargout > 0
      varargout{1} = h;
   end   
end
