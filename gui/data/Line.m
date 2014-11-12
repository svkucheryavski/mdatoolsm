classdef Line < Plot
   
   properties (SetAccess = 'protected')
      isShown = false
      linesHandle = [];
   end
   
   properties(Dependent)
      plotOptions
   end
   
   methods
      function obj = Line(parent, varargin)
         obj = obj@Plot(parent, varargin);
         obj.plotType = 'line';
         obj.listeners{end + 1} = addlistener(obj.parent.data, findprop(obj.parent.data, 'currentCols'), 'PostSet', @obj.showCurrentCols);
         obj.listeners{end + 1} = addlistener(obj.parent.data, findprop(obj.parent.data, 'selectedCols'), 'PostSet', @obj.showSelection);
         obj.listeners{end + 1} = addlistener(obj.parent.data, findprop(obj.parent.data, 'excludedCols'), 'PostSet', @obj.redraw);
         obj.listeners{end + 1} = addlistener(obj.parent.data, findprop(obj.parent.data, 'showExcludedCols'), 'PostSet', @obj.redraw);
         obj.listeners{end + 1} = addlistener(obj.parent.data, findprop(obj.parent.data, 'selectedRows'), 'PostSet', @obj.redraw);
         obj.parent.options.Marker.Value = 'none';
      end
      
      %%% getters and setters
      
      function options = get.plotOptions(obj)
         options = {...
            'LineStyle', obj.parent.options.LineStyle.Value, ...
            'LineWidth', obj.parent.options.LineWidth.Value, ...
            'Marker', obj.parent.options.Marker.Value,...
         };
                  
         if ~isempty(obj.parent.colorby) && isempty(obj.parent.options.GroupBy.Value)
            
            if any(obj.parent.data.selectedRows)
               rowInd = obj.parent.data.selectedRows;
            else
               rowInd = 1:numel(obj.parent.colorby);
            end   
            options = [options, ...
               {'Colorby', obj.parent.colorby(rowInd), 'Colorbar', 'on'}];            
         end   
      end
      
      %%% main methods
      
      function redraw(obj, ~, ~)
         redraw@Plot(obj);         
         cla reset
         
         if any(obj.parent.data.selectedRows)
            rowInd = find(obj.parent.data.selectedRows(~obj.parent.data.excludedRows));
            finalMsg = sprintf('Line plot for selected objects (%d).', numel(rowInd));
         else
            rowInd = 1:obj.parent.data.nRows;            
            finalMsg = '';
         end
         
         obj.parent.statusbarText('Showing the plot...');
         if obj.parent.data.nRows > obj.parent.TOO_MANY_ROWS && ~any(obj.parent.data.selectedRows)
            finalMsg = 'Only mean values are shown. Select objects you want to make the plot for.';
            obj.plotHandle = plot(mean(obj.parent.data(rowInd, :)), obj.plotOptions{:});                  
         else   
            if ~isempty(obj.parent.options.GroupBy.Value)
               factors = obj.parent.data.getfactors(obj.parent.options.GroupBy.Value);
               obj.plotHandle = gplot(obj.parent.data(rowInd, :), factors(rowInd, :), obj.plotOptions{:});                  
            else   
               obj.plotHandle = plot(obj.parent.data(rowInd, :), obj.plotOptions{:});                  
            end   
         end   
         obj.isShown = true;
         obj.showCurrentCols();         
         obj.parent.statusbarText(finalMsg);
         
         if ~isempty(obj.parent.data.selectedCols)
            obj.showSelection();
         end
      end   
      
      function showCurrentCols(obj, ~, ~)

         if ~obj.isShown
            return
         end
         
         axes(obj.parent.gui.plotAxes);
         if ~isempty(obj.linesHandle)
            try 
               delete(obj.linesHandle);
               obj.linesHandle = [];
            catch
            end
         end
         
         yl = ylim();
         xl = [obj.parent.data.currentCols(1) obj.parent.data.currentCols(2)];
         
         if obj.parent.data.showExcludedCols
            xl = obj.parent.data.getfullcolind(xl, false, false);
         end
         obj.linesHandle(1) = line([xl(1) xl(1)], yl, 'LineWidth', 2,...
            'LineStyle', '--', 'Color', obj.parent.CURCOL_LINE_COLORS(1, :));
         obj.linesHandle(2) = line([xl(2) xl(2)], yl, 'LineWidth', 2,...
            'LineStyle', '--', 'Color', obj.parent.CURCOL_LINE_COLORS(2, :));
      end
      
      function unselect(obj)
         if any(obj.parent.data.selectedCols)
            obj.parent.data.selectedCols = [];
         end   
      end
      
      function showSelection(obj, ~, ~)
         if ~obj.isShown
            return
         end
         
         showSelection@Plot(obj);
                  
         if any(obj.parent.data.selectedCols)         

            ind = obj.parent.data.selectedCols;
            if obj.parent.data.showExcludedCols
               ind = ind(~obj.parent.data.factorCols);
            else   
               ind = ind(~(obj.parent.data.excludedCols | obj.parent.data.factorCols));
            end
            
            values = obj.parent.data.valuesCSelected;

            ind = find(ind);
            serind = getserind(ind);
            % show selected points
            axes(obj.parent.gui.plotAxes);
            hs = [];
            hold on
            for i = 1:size(serind, 1)
               ix = serind(i, 1):serind(i, 2);
               h = plot(ind(ix), values(:, ix)', ...                     
                  'Color', obj.parent.SELECTION_EDGE_COLOR,...
                  'LineStyle', obj.parent.options.LineStyle.Value, ...
                  'LineWidth', obj.parent.options.LineWidth.Value, ...
                  'MarkerSize', 8, ...
                  'Marker', '.');
               hs = [hs; h];
            end   
            hold off
            obj.selectionHandle = hs;
            obj.parent.statusbarText(sprintf('%d columns selected (use "esc" to clean selection).', numel(ind)));
         end
      end
            
      function select(obj)
         if ~obj.isShown
            return
         end
         
         obj.parent.statusbarText('Selecting data, double click inside rectangle when finish.');            
         % show a rectangle for selection
         h = imrect(obj.parent.gui.plotAxes);
         position = wait(h);
         if numel(position) == 4
            points_in = obj.parent.data.inrect(position);
            if ~isempty(h) && isobject(h)
               delete(h);
            end   
            obj.parent.data.selectedCols = points_in;
         else
            obj.unselect();
         end            
         obj.parent.statusbarText('');            
      end
      
      function invertSelection(obj)
         obj.parent.invertSelectedCols();
      end
                 
      function exclude(obj)
         if ~isempty(obj.parent.data.selectedCols)
            ind = obj.parent.data.selectedCols;
            obj.parent.data.excludecols(ind, true);
         end   
      end
      
      function include(obj)
         if ~isempty(obj.parent.data.selectedCols)
            ind = obj.parent.data.selectedCols;
            obj.parent.data.includecols(ind, true);
         end   
      end
      
      %%% callbacks
      
      function changeCurrentColumn(obj, inc, n)
         obj.parent.changeCurrentColumn(inc, n);
      end        

      %%% settings and other methods
      function setSettings(obj)
         
         if ~isfield(obj.parent.gui, 'settingsPanel') 
            return
         end

         settings = {'ShowExcludedCols'};
         
         if obj.parent.data.nFactors > 0 && isempty(obj.parent.options.GroupBy.Value)
            settings  = [settings 'ColorBy'];
         end
         
         if obj.parent.data.nFactors > 0 
            settings = [settings 'GroupBy'];
         end
         
         if strcmp(obj.parent.settingsType, 'full')
            settings = [settings 'LineStyle', 'LineWidth', 'Marker'];
         end
         
          obj.parent.setSettingsPanel(settings);         
      end     
      
      function onKeyPress(obj, ~, event)         
         
         if ~isempty(event.Modifier) && strcmp(event.Modifier{1}, 'alt')
            inc = 10;
         else
            inc = 1;
         end   
         
         if strcmp(event.Key, 'leftarrow')
            obj.changeCurrentColumn(-inc, 1);
         elseif strcmp(event.Key, 'rightarrow')   
            obj.changeCurrentColumn(inc, 1);
         elseif strcmp(event.Key, 'uparrow')   
            obj.changeCurrentColumn(inc, 2);
         elseif strcmp(event.Key, 'downarrow')   
            obj.changeCurrentColumn(-inc, 2);
         end
      end
   
   end
   
end

