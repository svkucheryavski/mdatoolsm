classdef Explorer < handle

   properties
      data
      prep
      model
      gui
   end
   
   methods
      function obj = Explorer(data)
         obj.data = {data};         
         obj.createGUI();
      end   
      
      function createGUI(obj)
         obj.gui.f = figure('Position', [100 500 1000 600]);  
%          set(obj.gui.f,'Toolbar','figure'); 
%          tbh = findall(obj.gui.f,'Type','uitoolbar');
%          hb = findall(tbh);
%          get(hb(end - 1), 'Tag')
%          get(hb(end - 1), 'ClickedCallback')
%          delete(hb(2:end-1))
         set(obj.gui.f, 'KeyPressFcn', @obj.onKeyPress);
         obj.gui.panels = {};
         obj.gui.currentPanel = 1;
         obj.addDataPrepPanel();         
      end
      
      function addDataPrepPanel(obj)
         obj.gui.panels{end + 1} = DataPrepPanel(obj.gui.f, obj.data{end});
      end   
      
      function onKeyPress(obj, src, event)
         obj.gui.panels{obj.gui.currentPanel}.onKeyPress(src, event);
      end
      
   end
end
