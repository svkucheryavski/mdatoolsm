classdef Errorbar < Plot
   
   properties(Dependent)
      plotOptions
   end
   
   methods
      function obj = Errorbar(parent, varargin)
         obj = obj@Plot(parent, varargin);
         obj.plotType = 'errorbar';
         obj.listeners{end + 1} = addlistener(obj.parent.data, findprop(obj.parent.data, 'currentCols'), 'PostSet', @obj.redraw);
         obj.listeners{end + 1} = addlistener(obj.parent.data, findprop(obj.parent.data, 'selectedRows'), 'PostSet', @obj.redraw);
         obj.listeners{end + 1} = addlistener(obj.parent.data, findprop(obj.parent.data, 'excludedRows'), 'PostSet', @obj.redraw);         
      end
            
      function options = get.plotOptions(obj)
         options = {'Type', obj.parent.options.ErrorType.Value, 'Alpha', obj.parent.options.Alpha.Value};         
      end
            
      function redraw(obj, ~, ~)
         
         if obj.parent.data.nRows > obj.parent.TOO_MANY_ROWS && ~any(obj.parent.selectedRows)
            obj.parent.statusbarText('Data has too many rows/objects. Select objects you want to make the plot for.', 'warning');
            return
         end
         
         if any(obj.parent.data.selectedRows)
            rowInd = find(obj.parent.data.selectedRows);
            finalMsg = sprintf('Box plot for selected (%d) objects.', numel(rowInd));
         else
            rowInd = 1:obj.parent.data.nRows;
            finalMsg = '';
         end
         
         redraw@Plot(obj);
         cla reset
         obj.parent.statusbarText('Showing the plot...');
         if isempty(obj.parent.options.GroupBy.Value)
            obj.plotHandle = errorbar(obj.parent.data(rowInd, :), obj.plotOptions{:});
         else
            cols = obj.parent.data.colNamesWithoutFactors(obj.parent.data.currentCols);       
            factors = obj.parent.data.getfactors(obj.parent.options.GroupBy.Value);
            obj.plotHandle = errorbar(obj.parent.data(rowInd, cols{1}), factors, obj.plotOptions{:});
         end
         
         obj.parent.statusbarText(finalMsg);
      end   
                                 
      function setSettings(obj)
         
         if ~isfield(obj.parent.gui, 'settingsPanel') 
            return
         end
         
         settings = {'ErrorType', 'Alpha', 'XAxis'};

         if any(obj.parent.data.factorCols)
            settings = [settings 'GroupBy'];
         end
         
         obj.parent.setSettingsPanel(settings);
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

