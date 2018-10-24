      function varargout = hist(obj, varargin)
      % 'hist' makes a histogram plot for selected columns of dataset.
      %
      %   hist(data);
      %   hist(data, nbins);
      %   hist(data, 'ParamName', ParamValue, ...);
      %   
      %   hist(data, factors);
      %   hist(data, factors, nbins);
      %   hist(data, factors, 'ParamName', ParamValue, ...);
      %
      %
      % The function returns a structure with plot elements (plot handle,
      % labels handle, etc). If dataset has more than one column, the method 
      % will make a plot for the first column only.
      % 
      % Optional argument "factors" is a dataset with qualitative variables
      % (factors) used to split values to groups and show distribution
      % histogram separately for each group on the same axis.
      %
      % Parameters:
      % -----------
      % All parameters for Matlab's 'bar()' function will work. Optinally the second 
      % parameter (after dataset) is either number of bins or a vector with bin
      % intervals like in original 'hist()' function. Extra parameters are shown below.
      %
      %  "Density" - calculate density instead of frequency. Possible
      %  values are "on" and "off" (default).
      %
      %  "ShowNormal" - shows a curve with normal theoretical normal distribution.
      %  Possible values are "on" and "off" (default). 
      % 
      %  "Labels" - show or not labels for the histogram bars. Possible
      %  values are "on" and "off" (default). If "on", the values will be shown on 
      %  top of each bar.
      %
      %  "FaceColor" - the parameter is similar to the one for bar plot, however if 
      %  factors are used it should have a value for each group, made by combination 
      %  of the factors.
      %
      %  "EdgeColor" - the parameter is similar to the one for bar plot, however if 
      %  factors are used it should have a value for each group, made by combination 
      %  of the factors.
      %
      %  "Color" - color of normal probability curve (if used), if factors are used it 
      %  should have a value for each group, made by combination of the factors.
      %
      %  "FaceAlpha" - transparency of the bars, a value between 0 (fully transparent) 
      %  and 1 (not transparent). Default value is 0.5.
      %
      %  "LineWidth" - line thickness of normal probability curve (if used), default is 2.
      %
      %  "LineStyle" - line style of normal probability curve (if used), default is "-".
      %
      %
      % Examples:
      % ---------
      %
      %   load people
      %
      %   % show historgram for particular column
      %   figure
      %   hist(people(:, 'IQ'), 'EdgeColor', 'c')
      %   
      %   % show histogram for first column
      %   hist(people, 'Density', 'on', 'ShowNormal', 'on')
      %
      %   % make a factor and show histogram for groups
      %   people.factor('Sex', {'M', 'F'});
      %   figure
      %   hist(people(:, 'Height'), people(:, 'Sex'), 'ShowNormal', 'on');
      %
      %

         if ~ishold
            cla;
         end
      
         % check arguments for groups and nbins
         if nargin == 1
            groups = [];
            nbins = 0;
         elseif nargin >= 2 
            if isa(varargin{1}, 'mdadata') 
               groups = varargin{1};
               if nargin > 2 && isnumeric(varargin{2}) 
                  nbins = varargin{2};
                  varargin(2) = []; 
               else   
                  nbins = 0;
               end
               varargin(1) = []; 
            else
               groups = [];
               if isnumeric(varargin{1}) 
                  nbins = varargin{1};
                  varargin(1) = []; 
               else
                  nbins = 0;
               end
            end               
         end

         if ~isempty(groups)
            groups = groups.getgroups();
            nGroups = groups.nCols;
         else
            nGroups = 1;            
         end
         
         plotValues = obj.numValues(:, 1);
                  
         % check color settings
         [fa, varargin] = getarg(varargin, 'FaceAlpha');
         if isempty(fa)
            fa = 0.4;
         end
            
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
            
            if nec ~= nGroups || nec ~= 1
               error('Number of colors in "EdgeColor" should be one or the same as number of groups!');
            end               
         end   
         
         [lc, varargin] = getarg(varargin, 'Color');
         if isempty(lc)
            lc = fc;
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
               error('Number of colors in "Color" should be the same as number of groups!');
            end               
         end   

         % check line parameters
         [lw, varargin] = getarg(varargin, 'LineWidth');
         if isempty(lw) 
            lw = 2;
         end
         
         [ls, varargin] = getarg(varargin, 'LineStyle');
         if isempty(ls) 
            ls = '-';
         end
         
         % check if showing normal distribution is needed
         [v, varargin] = getarg(varargin, 'ShowNormal');
         if ~isempty(v) && strcmp(v, 'on')
            showNormal = true;
         else
            showNormal = false;
         end
         
         % check what to show - frequency or density
         [v, varargin] = getarg(varargin, 'Density');
         if ~isempty(v) && strcmp(v, 'on')
            showDensity = true;
            ylabelStr = 'Density';
         else
            showDensity = false;
            ylabelStr = 'Frequencies';
         end
         
         % check if labels to show
         [v, varargin] = getarg(varargin, 'Labels');
         if ~isempty(v) && strcmp(v, 'on')
            showLabels = true;
         else
            showLabels = false;
         end
         
         % in 2014b bar has no children, transparency will not work
         showTransparent = true;
         hg2 = false;
         if ~verLessThan('matlab', '8.4')
            hg2 = true;
         end   
            
         isShowNormal = false;
         
            
         hb = cell(nGroups, 1);
         xlim = [];
         hold on
         for nGroup = 1:nGroups
            if nGroups > 1
               v = plotValues(groups.values(:, nGroup) == 1, 1);
            else
               v = plotValues(:, 1);
            end

            if nbins > 0
               [y, x] = hist(v, nbins);
            else   
               [y, x] = hist(v);
            end

            if isempty(xlim)
               xlim = [min(x) max(x)];
            else   
               if xlim(1) > min(x)
                  xlim(1) = min(x);
               end

               if xlim(2) < max(x)
                  xlim(2) = max(x);
               end   
            end

            % calculate x and y values for normal curve
            if showNormal == true
               m = mean(v);
               s2 = var(v);
               mnx = min(v);
               mxx = max(v);
               dx = (mxx - mnx)/20;
               if mnx < mxx
                  nx = linspace(mnx - dx, mxx + dx, 100);
                  ny = 1/sqrt(2 * pi * s2) * exp( - (nx - m).^2 / (2 * s2) );      
                  isShowNormal = true;
               else
                  isShowNormal = false;
               end                  
            end

            % amend y values for density/frequency case
            if showDensity
               y = y/sum(y)/(x(2) - x(1));
            else
               if isShowNormal
                  ny = ny * sum(y) * (x(2) - x(1));
               end     
            end

            % set up values for labels

            % show plot and set transparency
            hb{nGroup} = bar(double(x), double(y), 0.98, 'FaceColor', fc(nGroup, :), ...
               'EdgeColor', ec(nGroup, :), varargin{:});   
            if showTransparent
               if hg2
                  % TODO: fix HG2 transparancy
                  % hb{nGroup}.Face.ColorType = 'truecoloralpha';
                  % hb{nGroup}.Face.ColorData = uint8(255 * [fc(nGroup, :) fa]');
               else   
                  hp = arrayfun(@(x) allchild(x), double(hb{nGroup}));
                  set(hp, 'FaceAlpha', fa);               
               end   
            end

            if isShowNormal
              plot(nx, ny, 'Color', lc(nGroup, :), 'LineWidth', lw, 'LineStyle', ls); 
            end   

            if showLabels
               labels = strsplit(num2str(y, 3), ' ');
               mdadata.showlabels(x, y, labels, 'top');
            end
         end
         
         hold off   
         if ~isempty(obj.colNamesAll)
            xlabel(obj.colFullNamesWithoutFactors{1})
         else
            xlabel('Variable #1');
         end
         
         ylabel(ylabelStr)         
         title(obj.name)
         box on               

         % correct limits
         if strcmp(get(gca, 'NextPlot'), 'replace')
            correctaxislim([5 5 0.01 5], xlim);
         end
         
         if nGroups > 1
            % show legend and set transparancy for legend items
            hl = legend([hb{:}], groups.colFullNamesWithoutFactors, 'EdgeColor', obj.LEGEND_EDGE_COLOR);
            c = get(hl, 'Children');
            hp = arrayfun(@(x) allchild(x), c(1:2:end));
            set(hp, 'FaceAlpha', fa);                              
         end
         
         if nargout > 0
            varargout{1} = [];
         end   

      end
