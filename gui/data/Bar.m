classdef Bar < Plot
         
   properties(Dependent)
      plotOptions
   end
   
   methods
      function obj = Bar(parent, varargin)
         obj = obj@Plot(parent, varargin);
         obj.plotType = 'bar';         
         obj.listeners{end + 1} = addlistener(obj.parent.data, findprop(obj.parent.data, 'currentRows'), 'PostSet', @obj.redraw);
         obj.listeners{end + 1} = addlistener(obj.parent.data, findprop(obj.parent.data, 'showExcludedCols'), 'PostSet', @obj.redraw);
      end
      
      %%% getters and setters
      
      function options = get.plotOptions(obj)
         options = {'Labels', obj.parent.options.ShowLabels.Value};
         
         if obj.parent.options.ShowExcludedCols.Value == 1
            options = [options, {'ShowExcluded', 'on'}];                     
         end
         
      end
      
      %%% main methods
      
      function redraw(obj, ~, ~)
         redraw@Plot(obj)
         cla reset        
         obj.plotHandle = bar(obj.parent.data(obj.parent.data.currentRows(1), :), obj.plotOptions{:});
      end   
                                       
      function setSettings(obj)
         
         if ~isfield(obj.parent.gui, 'settingsPanel') 
            return
         end

         settings = {'SelectedRows', 'ShowExcludedCols', 'ShowLabels'};
         obj.parent.setSettingsPanel(settings);                  
      end     
      
      function onKeyPress(obj, ~, event)         
         if strcmp(event.Key, 'leftarrow')
            obj.parent.changeCurrentRow(-1);
         elseif strcmp(event.Key, 'rightarrow')   
            obj.parent.changeCurrentRow(1);
         end
      end
   
   end   
end

