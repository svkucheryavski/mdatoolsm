classdef Scatter < ScatterBasic
   
   properties(Dependent)
      plotOptions
   end
   
   methods
      function obj = Scatter(parent, varargin)
         obj = obj@ScatterBasic(parent, varargin);
         obj.plotType = 'scatter';
         obj.parent.options.Marker.Value = 'o';
      end
      
      function options = get.plotOptions(obj)
         options = {...
            'Marker', obj.parent.options.Marker.Value, ...
            'MarkerSize', obj.parent.options.MarkerSize.Value,...
            'Labels', obj.parent.options.ShowLabels.Value,...
         };
                     
         if ~isempty(obj.parent.colorby) && isempty(obj.parent.options.GroupBy.Value)
            options = [options, ...
               {'Colorby', obj.parent.colorby, 'Colorbar', 'on'}];            
         end
      end
      
      function redraw(obj, src, ~)
         if nargin > 1 && isa(src, 'meta.property') && strcmp(src.Name, 'excludedRows')            
            % redraw is called after changed excluded rows
            % redefinde colorby values            
            obj.parent.setColorByValues()
         end      
         
         redraw@Plot(obj);         
         cla reset         

         cols = obj.parent.data.colNamesWithoutFactors(obj.parent.data.currentCols);       
         obj.parent.statusbarText('Showing the plot...');         
         if diff(obj.parent.data.currentCols(1:2)) == 0
            % if columns 1 and 2 are the same
            d = [obj.parent.data(:, cols{1}) obj.parent.data(:, cols{2})];
         else   
            d = obj.parent.data(:, cols);
         end
         
         if ~isempty(obj.parent.options.GroupBy.Value)            
            factors = obj.parent.data.getfactors(obj.parent.options.GroupBy.Value);
            obj.plotHandle = gscatter(d, factors, obj.plotOptions{:});
         else   
            obj.plotHandle = scatter(d, obj.plotOptions{:});
         end
         
         obj.parent.statusbarText('');

         if ~isempty(obj.parent.data.selectedRows)
            obj.showSelection();
         end         
      end   
      
      function setSettings(obj)         
         if ~isfield(obj.parent.gui, 'settingsPanel') 
            return
         end
         settings = {'XAxis', 'YAxis', 'ShowExcludedRows'};
         
         if obj.parent.data.nRows <= obj.parent.TOO_MANY_ROWS
            settings = [settings, 'ShowLabels'];
         end
         
         if obj.parent.data.nFactors > 0 && isempty(obj.parent.options.GroupBy.Value)
            settings  = [settings 'ColorBy'];
         end
         
         if obj.parent.data.nFactors > 0 
            settings = [settings 'GroupBy'];
         end
                  
         if strcmp(obj.parent.settingsType, 'full')
            settings = [settings, 'Marker', 'MarkerSize'];
         end
         
          obj.parent.setSettingsPanel(settings);         
      end              
   end
   
end

