classdef Plot < handle
   
   properties (SetAccess = 'protected')
      plotType
      selectionHandle = []
      plotHandle = []
      parent
      listeners = {}
      gui
   end
         
   methods
      function obj = Plot(parent, varargin)
         obj.parent = parent;   
         obj.setSettings();
      end
                  
      %%% abstract methods
            
      function unselect(obj, ~, ~)
      end
      
      function showSelection(obj, ~, ~)
         if ~isempty(obj.selectionHandle)
            if ishghandle(obj.selectionHandle)
               delete(obj.selectionHandle);
            end   
            obj.selectionHandle = [];
         end
      end
      
      function select(obj, ~, ~)
      end
      
      function invertSelection(obj, ~, ~)
      end
      
      function include(obj, ~, ~)
      end
      
      function exclude(obj, ~, ~)
      end
      
      function redraw(obj, ~, ~)
         axes(obj.parent.gui.plotAxes);
      end
         
      function setSettings(obj)
      end   
      
      function onKeyPress(obj, ~, event)
      end
   
      function delete(obj)
         delete([obj.listeners{:}]);
      end   
   end
   
end

