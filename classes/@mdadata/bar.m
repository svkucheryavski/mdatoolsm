function varargout = bar(obj, varargin)
% 'bar' makes a bar plot for 'mdadata' object.
%
%   bar(data);
%   bar(data, 'ParamName', ParamValue, ...);
%   bar(data, x);
%   bar(data, x, 'ParamName', ParamValue, ...);
%
%
% The method makes a bar plot for a particular row of a dataset. If
% dataset provided as an argument has more than one row the plot will 
% be shown for the first row.
%
% The optional second argument ('x') is a vector of values for the x
% axis. If it is not provided, a sequence 1:N, where N is number of
% columns in the dataset, will be used. The ticks for x axis in this case
% will be generated based on column names. The method assumes that every
% column of the data is a variable and every row is an observation.
%
% Parameters:
% -----------
% All parameters for Matlab's 'bar()' function will work. Extra parameters are shown below.
%
%  "Labels" - show or not labels for the data points. Possible
%  values are "none" (default), "names" for name of objects, "numbers"
%  for their numbers and "values" for the data values (height of bars). 
%
%  "LabelsSigfig" - how many significant figures to use for the label values.
%
%
% Examples:
% ---------
% 
%   expvar = mdadata([40.1 20 5 4; 35.2 18 4 3], {'Cal', 'Test'}, 1:4);
%   expvar.dimNames = {'Results', 'Components'};
%   expvar.name = 'Explained variance';
%   
%   % show bar plot for second row and change bar colors
%   figure
%   bar(expvar('Test', :), 'FaceColor', 'r');
%
%   % show labels on top of the bars
%   figure
%   bar(expvar, 'Labels', 'on');
%
%

   [v, varargin] = getarg(varargin, 'ShowExcluded');
   if isempty(v) || ~strcmp(v, 'on')
      showExcluded = false;
   else
      showExcluded = true;
   end

   % check if x values are provided and set up x and xtick values
   x = [];
   if numel(varargin) > 0 && isnumeric(varargin{1})
      if showExcluded
         error('You can not use manual x values with "ShowExcluded" parameter!');
      end   
      x = varargin{1};
      varargin(1) = [];
   else
      x = obj.colValuesAll;      
   end

   if isempty(find(strcmp(varargin, 'FaceColor'), 1))
      c = mdadata.getmycolors(1);
      varargin = [varargin, 'FaceColor', c(1, :)];
   end   

   if isempty(find(strcmp(varargin, 'EdgeColor'), 1))
      varargin = [varargin 'EdgeColor', 'n'];
   end

   bw = getarg(varargin, 'BarWidth');
   if isempty(bw)
      varargin = [varargin 'BarWidth', 0.75];
   else
      varargin = [varargin 'BarWidth', bw];            
   end   

   [showLabels, varargin] = getarg(varargin, 'Labels');
   if isempty(showLabels)
      showLabels = 'none';
   end

   [sigfig, varargin] = getarg(varargin, 'LabelsSigfig');
   if isempty(sigfig) || ~isnumeric(sigfig) || sigfig < 1 || sigfig > 10
      sigfig = 3;
   end

   
   xticklabels = {};
   if showExcluded
      values = obj.valuesAll(:, ~obj.factorCols);
      nCols = size(values, 2);
      if ~isempty(obj.colNamesAll)
         xticklabels = obj.colNamesAll(~obj.factorCols);
      end
   else
      values = obj.numValues;
      nCols = size(values, 2);
      if ~isempty(obj.colNamesAll)
         xticklabels = obj.colNamesWithoutFactors;
      end
   end

   if isempty(x)            
      x = 1:nCols;
      showTicks = true;
   else
      showTicks = false;
   end   

   if strcmp(showLabels, 'names') 
      if ~isempty(xticklabels)
         labels = xticklabels;               
      else
         labels = 1:nCols;
      end
   elseif strcmp(showLabels, 'numbers')
      labels = num2str(x');               
   else
      labels = [];
   end   

   if numel(x) < 12
      xtick = 1:numel(x);
   else
      xtick = unique(round(linspace(1, numel(x), 12)));
   end

   if ~ishold
      cla;
   end

   y = values(1, :);     
   h = bar(double(x), double(y), 0.95, varargin{:}); 

   if showExcluded
      ind = obj.excludedCols(~obj.factorCols);
      [~, varargin] = getarg(varargin, 'FaceColor');
      hold on
      h(2) = bar(x(ind), y(ind), 0.95, 'FaceColor', obj.EXCLUDED_COLOR, varargin{:});                
      hold off
   end

   xlabel(obj.dimNames{2})            
   ylabel('')         

   if ~isempty(obj.rowNamesAll)
      if ~isempty(obj.name) 
         title([obj.name ' (' obj.rowNames{1} ')'])
      else
         title(obj.rowNames{1})
      end
   else
      title('Object #1');
   end

   box on
   if showTicks && ~isempty(xticklabels)
       set(gca, 'XTick', x(xtick), 'XTickLabel', xticklabels(xtick));
   end   

   if numel(x) > 1
      dx = x(2) - x(1);
      xlim = [min(x) - dx/2 max(x) + dx/2];
   else
      xlim = [0 2];
   end

   if ~strcmp(showLabels, 'none')
      if isempty(labels)
         labels = cellstr(num2str(y', sigfig));
      end

      indtop = y >= 0;
      mdadata.showlabels(x(indtop), y(indtop), labels(indtop), 'top');
      mdadata.showlabels(x(~indtop), y(~indtop), labels(~indtop), 'bottom');

      if strcmp(get(gca, 'NextPlot'), 'replace')
         correctaxislim([3 3 0 10], xlim);
      end
   else   
      if strcmp(get(gca, 'NextPlot'), 'replace')
         correctaxislim([3 3 0 5], xlim);
      end
   end            

   if nargout > 0
      varargout{1} = h;
   end   

end   
