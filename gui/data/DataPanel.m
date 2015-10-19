classdef DataPanel < handle
   properties (SetAccess = 'protected')
      parent
      gui
      listeners
      data
   end
   
   methods
      function obj = DataPanel(parent, data, layout)
         
         if nargin < 3 || isempty(layout)
            if isa(data, 'mdaimage')
               layout = {...
                  1, 1, 'densscatter';...
                  1, 2, 'image'; ...
                  2, [1 2], 'line'};
            else   
               layout = {...
                  1, 1, 'scatter';...
                  1, 2, 'hist'; ...
                  2, [1 2], 'line'};
            end
         end
         
         obj.parent = parent;
         obj.data = data;
         obj.createGUI(layout);
         obj.redraw();                  
         obj.selectPanel([], [], 1);         
      end   
      
      function createGUI(obj, layout)
         nRows = max([layout{:, 1}]);        
         nCols = max([layout{:, 2}]);
         
         obj.gui.panel = uipanel('Parent', obj.parent, 'BorderType', 'none');         
         obj.gui.layout = GridBagLayout(obj.gui.panel, 'HorizontalGap', 5, 'VerticalGap', 5);

         obj.gui.settingsPanel = uipanel(obj.gui.panel, 'BorderType', 'none');
         obj.gui.layout.add(obj.gui.settingsPanel, [1 2], nCols + 1, 'MinimumWidth', 250, 'Anchor', 'North', 'Fill', 'Both');   
         obj.gui.settingsLayout = GridBagLayout(obj.gui.settingsPanel, 'HorizontalGap', 5, 'VerticalGap', 10);
         obj.gui.settingsLayout.VerticalWeights = [0 0 1];
         
         for i = 1:size(layout, 1)
            obj.gui.plotPanel(i) = PlotPanel(obj, obj.data, obj.gui.settingsPanel, i, 'PlotType', layout{i, 3});
            obj.gui.layout.add(obj.gui.plotPanel(i).gui.plotPanel, layout{i, 1}, layout{i, 2}, 'Fill', 'Both');
         end
         
         obj.gui.layout.HorizontalWeights = [ones(1, nCols) 0];
         obj.gui.layout.VerticalWeights = ones(1, nRows);
         obj.gui.currentPanel = [];
      end
      
      function redraw(obj)
         for i = 1:numel(obj.gui.plotPanel)
            obj.gui.plotPanel(i).redraw();
         end   
      end
            
      function selectPanel(obj, ~, ~, id)
         if ~isempty(obj.gui.currentPanel)
            obj.gui.plotPanel(obj.gui.currentPanel).unselectPanel();
         end   
         obj.gui.plotPanel(id).selectPanel();
         obj.gui.currentPanel = id;
      end
      
      function onKeyPress(obj, src, event)
         obj.gui.plotPanel(obj.gui.currentPanel).onKeyPress(src, event);
      end         
   end   
end
