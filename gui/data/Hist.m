classdef Hist < Plot

   properties(Dependent)
      plotOptions
   end
   
   methods
      function obj = Hist(parent, varargin)
         obj = obj@Plot(parent, varargin);
         obj.plotType = 'hist';
         obj.listeners{end + 1} = addlistener(obj.parent.data, findprop(obj.parent.data, 'currentCols'), 'PostSet', @obj.redraw);
         obj.listeners{end + 1} = addlistener(obj.parent.data, findprop(obj.parent.data, 'excludedCols'), 'PostSet', @obj.redraw);
         obj.listeners{end + 1} = addlistener(obj.parent.data, findprop(obj.parent.data, 'selectedRows'), 'PostSet', @obj.redraw);
      end
            
      function options = get.plotOptions(obj)
         options = {};
         
         if obj.parent.options.ShowNormal.Value == 1
            options = [options, {'ShowNormal', 'on'}];                     
         end         
      end
            
      function redraw(obj, ~, ~)
         redraw@Plot(obj);         
         
         if any(obj.parent.data.selectedRows)
            rowInd = find(obj.parent.data.selectedRows);
            finalMsg = sprintf('Histogram for selected (%d) objects.', sum(rowInd));
         else
            rowInd = 1:obj.parent.data.nRows;
            finalMsg = '';
         end
         
         if rowInd < 3
            obj.parent.statusbarText('Number of selected objects is too small for histogram, clean selection.')
            return
         end
         
         cla reset
         cols = obj.parent.data.colNamesWithoutFactors(obj.parent.data.currentCols);       
         if isempty(obj.parent.options.GroupBy.Value)
            obj.plotHandle = hist(obj.parent.data(rowInd, cols{1}), obj.plotOptions{:});
         else
            factors = obj.parent.data.getfactors(obj.parent.options.GroupBy.Value);
            obj.plotHandle = hist(obj.parent.data(rowInd, cols{1}), factors, obj.plotOptions{:});
         end  
         obj.parent.statusbarText(finalMsg)
      end   
                             
      function setSettings(obj)
         
         if ~isfield(obj.parent.gui, 'settingsPanel') 
            return
         end
         
         settings = {'ShowNormal', 'XAxis'};

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

