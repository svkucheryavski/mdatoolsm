classdef Boxplot < Plot
   
   properties (SetAccess = 'protected')
      isShown = false
   end
   
   properties(Dependent)
      plotOptions
   end
   
   methods
      function obj = Boxplot(parent, varargin)
         obj = obj@Plot(parent, varargin);
         obj.plotType = 'boxplot';
         obj.listeners{end + 1} = addlistener(obj.parent.data, findprop(obj.parent.data, 'currentCols'), 'PostSet', @obj.redraw);
         obj.listeners{end + 1} = addlistener(obj.parent.data, findprop(obj.parent.data, 'selectedRows'), 'PostSet', @obj.redraw);
         obj.listeners{end + 1} = addlistener(obj.parent.data, findprop(obj.parent.data, 'excludedRows'), 'PostSet', @obj.redraw);
      end
      
      %%% getters and setters
      
      function options = get.plotOptions(obj)
         options = {'Labels', obj.parent.options.ShowLabels.Value};         
      end
      
      %%% main methods
      
      function redraw(obj, ~, ~)
         redraw@Plot(obj);
         cla reset
         if obj.parent.data.nRows > obj.parent.TOO_MANY_ROWS && ~any(obj.parent.data.selectedRows)
            obj.parent.statusbarText('Data has too many rows/objects. Select objects you want to make the plot for.', 'warning');
            obj.isShown = false;
            return
         end
         
         if any(obj.parent.data.selectedRows)
            rowInd = find(obj.parent.data.selectedRows);
            finalMsg = sprintf('Box plot for selected (%d) objects.', numel(rowInd));
         else
            rowInd = 1:obj.parent.data.nRows;
            finalMsg = '';
         end
         
         obj.parent.statusbarText('Showing the plot...');
         if isempty(obj.parent.options.GroupBy.Value)
            obj.plotHandle = boxplot(obj.parent.data(rowInd, :), obj.plotOptions{:});
         else
            cols = obj.parent.data.colNamesWithoutFactors(obj.parent.data.currentCols);       
            factors = obj.parent.data.getfactors(obj.parent.options.GroupBy.Value);
            obj.plotHandle = boxplot(obj.parent.data(rowInd, cols{1}), factors, obj.plotOptions{:});
         end
         obj.parent.statusbarText(finalMsg)         
      end   
                     
      %%% settings and other methods
      
      function setSettings(obj)
         
          if ~isfield(obj.parent.gui, 'settingsPanel') 
            return
         end
        
         settings = {'XAxis', 'Labels'};

         if any(obj.parent.data.factorCols)
            settings = [settings 'GroupBy'];
         end
         
         obj.parent.setSettingsPanel(settings)
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

