classdef ScatterBasic < Plot
            
   methods
                  
      %%% main methods
      function obj = ScatterBasic(parent, varargin)
         obj = obj@Plot(parent, varargin);
         obj.listeners{end + 1} = addlistener(obj.parent.data, findprop(obj.parent.data, 'currentCols'), 'PostSet', @obj.redraw);
         obj.listeners{end + 1} = addlistener(obj.parent.data, findprop(obj.parent.data, 'selectedRows'), 'PostSet', @obj.showSelection);
         obj.listeners{end + 1} = addlistener(obj.parent.data, findprop(obj.parent.data, 'excludedRows'), 'PostSet', @obj.redraw);
         obj.listeners{end + 1} = addlistener(obj.parent.data, findprop(obj.parent.data, 'excludedCols'), 'PostSet', @obj.redraw);
         obj.listeners{end + 1} = addlistener(obj.parent.data, findprop(obj.parent.data, 'showExcludedRows'), 'PostSet', @obj.redraw);
      end
      
      function unselect(obj, ~, ~)
         if any(obj.parent.data.selectedRows)
            obj.parent.data.selectedRows = [];
         end   
      end

      function showSelection(obj, ~, ~)
         showSelection@Plot(obj);
         
         if any(obj.parent.data.selectedRows)
            % show selected points
            cols = obj.parent.data.currentCols;
            values = obj.parent.data.valuesRSelected;
            x = values(:, cols(1));
            y = values(:, cols(2));
            if numel(x) > mdadata.REDUCE_ROWS_LIMIT
               dens = mdadata.getsampledensity(x, y, 100, 'Quantize', 'on');
               ind = mdadata.reducerows(dens, 1);
               x = x(ind);
               y = y(ind);
            end
               
            axes(obj.parent.gui.plotAxes);
            hold on
            h = plot(x, y, ...
               'LineStyle', 'none', ...
               'Marker', obj.parent.options.Marker.Value,...
               'MarkerSize', obj.parent.options.MarkerSize.Value, ...
               'MarkerFaceColor', obj.parent.SELECTION_FACE_COLOR, ...                   
               'MarkerEdgeColor', obj.parent.SELECTION_EDGE_COLOR);
            hold off
            obj.parent.statusbarText(sprintf('%d objects selected (use "esc" to clean selection).', size(values, 1)));
            obj.selectionHandle = h;   
            obj.parent.showObjSelectionContextMenu()
         end    
      end
      
      function select(obj, ~, ~)
         cols = obj.parent.data.colNamesWithoutFactors(obj.parent.data.currentCols);       
         
         if ~isempty(obj.selectionHandle) 
            delete(obj.selectionHandle);
            obj.selectionHandle = [];
         end
         
         obj.parent.statusbarText('Selecting data, make a polygon and double click inside it finish selection.');
         
         % show a polygon for selection
         h = impoly(obj.parent.gui.plotAxes);
         position = wait(h);
         if size(position, 1) > 2
            if diff(obj.parent.data.currentCols(1:2)) == 0
               % if columns 1 and 2 are the same
               d = [obj.parent.data(:, cols{1}) obj.parent.data(:, cols{2})];
            else   
               d = obj.parent.data(:, cols);
            end
            
            points_in = d.inpolygon(position);
            if ~isempty(h) && isobject(h)
               delete(h);
            end   
            
            obj.parent.data.selectedRows = points_in;
         else
            obj.unselect();
         end
         obj.parent.statusbarText('');         
      end
                
      function invertSelection(obj, ~, ~)
         obj.parent.invertSelectedRows();
      end
      
      function exclude(obj, ~, ~)
         if ~isempty(obj.parent.data.selectedRows)
            ind = obj.parent.data.selectedRows;
            obj.parent.data.excluderows(ind, 'full');
         end   
      end
      
      function redraw(~, ~, ~)
      end
      
      function include(obj, ~, ~)
         if ~isempty(obj.parent.data.selectedRows)
            ind = obj.parent.data.selectedRows;
            obj.parent.data.includerows(ind, 'full');
         end   
      end            
                       
      %%% other methods 
      
      function onKeyPress(obj, ~, event)
         
         if strcmp(event.Key, 'leftarrow')
            obj.parent.changeCurrentColumn(-1, 1);
         elseif strcmp(event.Key, 'rightarrow')   
            obj.parent.changeCurrentColumn(1, 1);
         elseif strcmp(event.Key, 'uparrow')   
            obj.parent.changeCurrentColumn(1, 2);
         elseif strcmp(event.Key, 'downarrow')   
            obj.parent.changeCurrentColumn(-1, 2);
         end
      end
   
   end
   
end

