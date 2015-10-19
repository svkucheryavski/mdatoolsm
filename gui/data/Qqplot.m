classdef Qqplot < Plot
      
   properties(Dependent)
      plotOptions
   end
   
   methods
      function obj = Qqplot(parent, varargin)
         obj = obj@Plot(parent, varargin);
         obj.plotType = 'qqplot';
         obj.listeners{end + 1} = addlistener(obj.parent.data, findprop(obj.parent.data, 'currentCols'), 'PostSet', @obj.redraw);
         obj.listeners{end + 1} = addlistener(obj.parent.data, findprop(obj.parent.data, 'selectedRows'), 'PostSet', @obj.redraw);
         obj.listeners{end + 1} = addlistener(obj.parent.data, findprop(obj.parent.data, 'excludedRows'), 'PostSet', @obj.redraw);
         obj.listeners{end + 1} = addlistener(obj.parent.data, findprop(obj.parent.data, 'showExcludedRows'), 'PostSet', @obj.redraw);
      end
      
      function options = get.plotOptions(obj)
         options = {'Labels', obj.parent.options.ShowLabels.Value};
         
         if obj.parent.options.ShowNormal.Value == 0
            options = [options, {'ShowNormal', 'off'}];                     
         end         
      end
      
      function redraw(obj, ~, ~)
         if any(obj.parent.data.selectedRows)
            rowInd = find(obj.parent.data.selectedRows);
            finalMsg = sprintf('QQ plot for selected (%d) objects.', numel(rowInd));
         else
            rowInd = 1:obj.parent.data.nRows;
            finalMsg = '';
         end

         redraw@Plot(obj);
         cla reset
         obj.parent.statusbarText('Showing the plot...')         
         cols = obj.parent.data.colNamesWithoutFactors(obj.parent.data.currentCols);       
         if isempty(obj.parent.options.GroupBy.Value)
            obj.plotHandle = qqplot(obj.parent.data(rowInd, cols{1}), obj.plotOptions{:});
         else
            factors = obj.parent.data.getfactors(obj.parent.options.GroupBy.Value);
            obj.plotHandle = qqplot(obj.parent.data(rowInd, cols{1}), factors, obj.plotOptions{:});
         end
         obj.parent.statusbarText(finalMsg)         
      end   
        
      function setSettings(obj)
         
         if ~isfield(obj.parent.gui, 'settingsPanel') 
            return
         end
         settings = {'XAxis', 'ShowNormal', 'Labels'};

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

