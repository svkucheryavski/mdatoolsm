classdef Gline < Plot
      
   properties(Dependent)
      plotOptions
   end
   
   methods
      function obj = Gline(parent, varargin)
         obj = obj@Plot(parent, varargin);
         obj.plotType = 'gbar';
         obj.listeners{end + 1} = addlistener(obj.parent.data, findprop(obj.parent.data, 'excludedCols'), 'PostSet', @obj.redraw);
      end
      
      function options = get.plotOptions(obj)
         options = {...
            'LineStyle', obj.parent.options.LineStyle.Value, ...
            'LineWidth', obj.parent.options.LineWidth.Value, ...
            'Marker', obj.parent.options.Marker.Value,...
         };
      end
      
      function redraw(obj, ~, ~)
         redraw@Plot(obj);
         cla reset
         if any(obj.parent.data.selectedRows)
            obj.plotHandle = gplot(obj.parent.data(obj.parent.data.selectedRows, :), obj.plotOptions{:});
         else
            obj.plotHandle = [];
         end   
      end   
                              
      function setSettings(obj)
         
         if ~isfield(obj.parent.gui, 'settingsPanel') 
            return
         end
         
         settings = {'SelectedRows'};
         if strcmp(obj.parent.settingsType, 'full')
            settings = [settings 'LineStyle', 'LineWidth', 'Marker'];
         end         
         obj.parent.setSettingsPanel(settings);
      end     
      
   end   
end

