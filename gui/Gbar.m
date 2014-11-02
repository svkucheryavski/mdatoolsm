classdef Gbar < Plot
   
   properties(Dependent)
      plotOptions
   end
   
   methods
      function obj = Gbar(parent, varargin)
         obj = obj@Plot(parent, varargin);
         obj.plotType = 'gbar';
         obj.listeners{end + 1} = addlistener(obj.parent.data, findprop(obj.parent.data, 'excludedCols'), 'PostSet', @obj.redraw);
      end
      
      function options = get.plotOptions(obj)
         options = {'Labels', obj.parent.options.ShowLabels.Value};
      end
      
      function redraw(obj, ~, ~)
         redraw@Plot(obj)
         cla reset
         rows = obj.parent.options.Rows.Value;
         if ~isempty(rows)
            obj.plotHandle = gbar(obj.parent.data(rows, :), obj.plotOptions{:});
         else
            obj.plotHandle = [];
         end   
      end   
                                
      function setSettings(obj)
         
         if ~isfield(obj.parent.gui, 'settingsPanel') 
            return
         end
         
         settings = {'Rows'};
         obj.parent.setSettingsPanel(settings);                           
      end     
      
      function onKeyPress(~, ~, ~)         
      end
   
   end   
end

