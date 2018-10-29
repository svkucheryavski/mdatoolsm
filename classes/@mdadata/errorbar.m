      
      function varargout = errorbar(obj, varargin)
      % 'errorbar' makes an error bar plot for dataset columns
      %
      %   errobar(data);
      %   errorbar(data, 'ParamName', ParamValue, ...);
      %   
      %   errobar(data, factors);
      %   errorbar(data, factors, 'ParamName', ParamValue, ...);
      %
      %
      % The method is similar to standard 'errorbar()' function, however 
      % all statistic are caclulated automatically, only dataset with original
      % values should be provided.
      %
      % Optional argument "factors" is a dataset with qualitative variables
      % (factors) used to split data values into groups and show error bars
      % separately for each group on the same axis. In this case one plot
      % will be made only for the first column of data.
      %
      % Parameters:
      % ------------
      % All parameters for Matlab's 'plot()' function (e.g. "Color", etc.)
      % can be used. Additional parameters are:
      %
      %  "Type" - how to calculate size of the error bars. By default ("ci") 
      %  error bars shows confidence interval for mean values. This can be
      %  changed to: "se" to show standard error, or to "sd" to show standard
      %  deviation. Both can be combined with 'Alpha' parameter, see
      %  examples below.
      %
      %  "Alpha" - significance level, a value between 0 and 1.
      %
      %
      % Examples:
      % ---------
      %   
      %   load people
      %   people.removecols('Income');
      %
      %   % show average and 95% confidence intervals
      %   figure
      %   errorbar(people)
      %
      %   % show average and 90% confidence intervals
      %   figure
      %   errorbar(people, 'Alpha', 0.1)
      %
      %   % show average +/- standard error
      %   figure
      %   errorbar(people, 'Type', 'se')
      %
      %   % show average +/- standard deviation
      %   figure
      %   errorbar(people, 'Type', 'sd')
      %
      %   % show average and 95% of most common values (+/- 1.96 sd)
      %   figure
      %   errorbar(people, 'Type', 'sd', 'Alpha', 0.05)
      %
      %   % confidence intervals for groups
      %   people.factor('Sex', {'Male', 'Female'});
      %   figure
      %   errorbar(people(:, {'Height', 'Weight'}), people(:, 'Sex'))
      %
         
         if ~ishold
            cla;
         end

         % check if factors are provided and generate groups
         if nargin > 1 && isa(varargin{1}, 'mdadata')
            groups = varargin{1};
            varargin(1) = [];
            groups = groups.getgroups();
            nGroups = groups.nCols;
         else
            groups = [];
            nGroups = 1;
            m = mean(obj);
         end
         
         [type, varargin] = getarg(varargin, 'Type');
         if isempty(type)
            type = 'ci';            
         end
         
         [alpha, varargin] = getarg(varargin, 'Alpha');
         if isempty(alpha)
            if strcmp(type, 'ci') 
               type = 'se';
               alpha = 0.05;
               t = [];
            else
               t = 1;
            end   
         else
            if strcmp(type, 'ci') 
               type = 'se';
            end   
            t = [];
         end

         if isempty(find(strcmp(varargin, 'LineStyle'), 1))
            varargin = [{'LineStyle', 'none'} varargin];
         end   
         
         if isempty(find(strcmp(varargin, 'Marker'), 1))
            varargin = [{'Marker', '.'} varargin];
            if isempty(find(strcmp(varargin, 'MarkerSize'), 1))
               varargin = [{'MarkerSize', 18} varargin];
            end   
         end   
         
         if isempty(find(strcmp(varargin, 'Color'), 1))
            varargin = [{'Color', mdadata.getmycolors(1)} varargin];
         end   
         
         plotValues = obj.numValues(:, 1);
         
         % calculate error margin and mean values         
         if strcmp(type, 'se')
            if t == 1
               titlestr = '(std. error)';
            else
               titlestr = sprintf('(%.0f%% conf. int)', (1 - alpha) * 100);
            end   
            
            if nGroups == 1
               if isempty(t)
                  t = mdatinv(1 - alpha/2, obj.nRows - 1);
               end   
               err = se(obj) * t;
            else
               err = zeros(1, nGroups);
               m = zeros(1, nGroups);
               for nGroup = 1:nGroups
                  ind = groups.values(:, nGroup) == 1;
                  if isempty(t)
                     t = mdatinv(1 - alpha/2, sum(ind) - 1);
                  end   
                  m(nGroup) = mean(plotValues(ind, 1));
                  err(nGroup) = mdase(plotValues(ind, 1)) * t;
               end   
               m = mdadata(m, obj.getColLabels(1), groups.colNames);
               err = mdadata(err, obj.getColLabels(1), groups.colNames);               
            end   
         else
            if t == 1
               titlestr = '(std)';
            else
               titlestr = sprintf('(%.0f%% interval)', (1 - alpha) * 100);
            end   
            
            if nGroups == 1
               if isempty(t)
                  t = mdatinv(1 - alpha/2, obj.nRows - 1);
               end   
               err = std(obj) * t;
            else
               err = zeros(1, nGroups);
               m = zeros(1, nGroups);
               for nGroup = 1:nGroups
                  ind = groups.values(:, nGroup) == 1;
                  if isempty(t)
                     t = mdatinv(1 - alpha/2, sum(ind) - 1);
                  end   
                  m(nGroup) = mean(plotValues(ind, 1));                     
                  err(nGroup) = std(plotValues(ind, 1)) * t;
               end   
               m = mdadata(m, obj.colNamesWithoutFactors(1), groups.colNames);
               err = mdadata(err, obj.colNamesWithoutFactors(1), groups.colNames);               
               err.colFullNamesAll = groups.colFullNames;
               err.rowFullNamesAll = obj.colFullNamesWithoutFactors(1);
            end   
         end   

         xticklabel = {};
         if nGroups == 1
            if ~isempty(obj.colValuesAll)
               x = obj.colValuesWithoutFactors;
            else
               x = 1:obj.nCols;
               if ~isempty(obj.colNamesAll)
                  xticklabel = obj.colNamesWithoutFactors;
               end
            end
         else            
            x = 1:nGroups;
            xticklabel = groups.colFullNames;
         end
         
         if numel(x) < 12
            xtick = x;
         else
            xtick = unique(round(linspace(1, numel(x), 12)));
         end
            
         h = errorbar(x, m.values, err.values, varargin{:});
                    
         if ~isempty(xticklabel)
            set(gca, 'XTick', xtick, 'XTickLabel', xticklabel(xtick));
         end
         
         % correct axis limits
         if strcmp(get(gca, 'NextPlot'), 'replace')
            correctaxislim(5, [min(x) max(x)]);
         end
            
         if nGroups == 1
            xlabel(obj.dimNames{2})         
            ylabel('')    
            title([obj.name ' ' titlestr])
         else
            xlabel(groups.dimNames{2})
            ylabel(err.rowFullNames{1})    
            title([err.rowFullNames{1} ' ' titlestr])
         end
         
         box on
         
         if nargout > 0
            varargout{1} = h;
         end            
      end
