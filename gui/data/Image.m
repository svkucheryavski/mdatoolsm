classdef Image < ScatterBasic

   properties(Dependent)
      plotOptions
   end
   
   methods
      function obj = Image(parent, varargin)
         obj = obj@ScatterBasic(parent, varargin);
         obj.plotType = 'image';
      end
      
      function options = get.plotOptions(obj)
         options = {'Colormap', obj.parent.colormap};
      end
      
      function showSelection(obj, ~, ~)
         showSelection@Plot(obj);
         
         if any(obj.parent.data.selectedRows)
            ind = obj.parent.data.selectedRows;
            alpha = zeros(obj.parent.data.width * obj.parent.data.height, 1);
            alpha(ind) = 1;
            alpha = reshape(alpha, obj.parent.data.height, obj.parent.data.width);         
            grays = ones(obj.parent.data.height, obj.parent.data.width, 3) * 0.7;
      
            axes(obj.parent.gui.plotAxes);
            hold on
            obj.selectionHandle = imagesc(grays, 'AlphaData', alpha);
            hold off
            obj.parent.statusbarText(sprintf('%d pixels selected (use "esc" to clean selection).',...
               numel(ind)));
            obj.parent.showObjSelectionContextMenu()
         end   
      end
      
      function invertSelection(obj, ~, ~)
         obj.parent.invertSelectedRows();
      end
      
      function select(obj)
         if ~isempty(obj.selectionHandle) 
            delete(obj.selectionHandle);
            obj.selectionHandle = [];
         end
         
         obj.parent.statusbarText('Selecting data, make a polygon and double click inside it finish selection.');
         h = impoly(obj.parent.gui.plotAxes);
         position = wait(h);
         if size(position, 1) > 2 
            rows = repmat((1:obj.parent.data.height)', 1, obj.parent.data.width);
            cols = repmat((1:obj.parent.data.width), obj.parent.data.height, 1);
            points_in = inpolygon(cols(:), rows(:), position(:, 1), position (:, 2));

            if ~isempty(h) && isobject(h)
               delete(h);
            end   
            
            obj.parent.data.selectedRows = points_in;
         else
            obj.unselect();
         end
         obj.parent.statusbarText('');         
      end
            
      
      function setSettings(obj)
         
         if ~isfield(obj.parent.gui, 'settingsPanel') 
            return
         end
         
         settings = {'XAxis', 'Colormap'};
         obj.parent.setSettingsPanel(settings);
      end     
                  
      function redraw(obj, ~, ~)
         redraw@Plot(obj);
         cols = obj.parent.data.colNamesWithoutFactors(obj.parent.data.currentCols);                
         obj.gui.plotHandle = imagesc(obj.parent.data(:, :, cols{1}), obj.plotOptions{:});
         title(cols{1});
         if ~isempty(obj.parent.data.selectedRows)
            obj.showSelection();
         end                  
      end   
      
      function onKeyPress(obj, ~, event)         
         if strcmp(event.Key, 'leftarrow')
            obj.parent.changeCurrentColumn(-1, 1);
         elseif strcmp(event.Key, 'rightarrow')   
            obj.parent.changeCurrentColumn(1, 1);
         end
      end
      
      
   end
end
