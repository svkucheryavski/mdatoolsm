classdef Densscatter < ScatterBasic
   
   properties(Dependent)
      plotOptions
   end
   
   methods
      
      function obj = Densscatter(parent, varargin)
         obj = obj@ScatterBasic(parent, varargin);
         obj.plotType = 'densscatter';
         obj.parent.options.Marker.Value = 'o';         
      end
      
      %%% getters and setters
      
      function options = get.plotOptions(obj)
         options = {...
            'Marker', obj.parent.options.Marker.Value, ...
            'MarkerSize', obj.parent.options.MarkerSize.Value,...
            'Labels', obj.parent.options.ShowLabels.Value,...
            'Colormap', obj.parent.colormap
         };
      end
      
      %%% main methods
      
      function redraw(obj, ~, ~)
         redraw@Plot(obj);         
         cols = obj.parent.data.colNamesWithoutFactors(obj.parent.data.currentCols);       

         cla reset         
         obj.parent.statusbarText('Showing the plot...');                  
         if diff(obj.parent.data.currentCols(1:2)) == 0
            % if columns 1 and 2 are the same
            d = [obj.parent.data(:, cols{1}) obj.parent.data(:, cols{2})];
         else   
            d = obj.parent.data(:, cols);
         end
         
         obj.plotHandle = densscatter(d, obj.plotOptions{:});
         obj.parent.statusbarText('');

         if ~isempty(obj.parent.data.selectedRows)
            obj.showSelection();
         end         
      end   
                       
      %%% settings and other methods
      function setSettings(obj)
         if ~isfield(obj.parent.gui, 'settingsPanel') 
            return
         end
         
         settings = {'XAxis', 'YAxis', 'ShowExcludedRows', 'Colormap'};
         
         if obj.parent.data.nRows <= obj.parent.TOO_MANY_ROWS
            settings = [settings, 'ShowLabels'];
         end
                  
         if strcmp(obj.parent.settingsType, 'full')
            settings = [settings, 'Marker', 'MarkerSize'];
         end         
         
          obj.parent.setSettingsPanel(settings);         
      end     
            
   end
   
end

