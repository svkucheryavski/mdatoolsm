classdef PrepSettingsPanel < handle
   
   properties (SetAccess = 'protected')
      HEIGHT = 35;
   end   
   
   properties
      panel
      parentLayout
      layout
      prep
   end   
   
   methods
      function obj = PrepSettingsPanel(parent, prep)
         obj.panel = uipanel(parent);
         obj.layout = GridBagLayout(obj.panel, 'HorizontalGap', 5, 'VerticalGap', 10);
         obj.layout.HorizontalWeights = [3 1];
      end   
      
      function setParentLayout(obj, parentLayout)
         obj.parentLayout = parentLayout;
      end
      
      function adjustSize(obj)
         if obj.nItems > 0
            setConstraints(obj.parentLayout, 1, 2, 'MinimumHeight', obj.minHeight)
         end   
      end
            
      function addItem(obj, item)
         obj.nItems = obj.nItems + 1;                  
         obj.items(obj.nItems) = item;         
         obj.show
      end
            
      
      function removeItem(obj, n)
      end  
      
   end   
end