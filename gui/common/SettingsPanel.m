classdef SettingsPanel < handle
      
   properties
      Parent
      Panel
      Layout
      Names
      Items
      Height
   end   
   
   methods
      
      function obj = SettingsPanel(parent, panel, items)
         obj.Parent = parent;
         obj.Panel = uipanel(panel, 'Visible', 'on');
         set(obj.Panel, 'Units', 'Pixels', 'Position', [0 0 250 300])
         set(obj.Panel, 'Visible', 'off')
         obj.Items = [];
         
         if isstruct(items)
         % if setting objects are fields of structure   
            fields = fieldnames(items);
            for i = 1:numel(fields)
               obj.Names{i} = fields{i};
               obj.Items{i} = items.(fields{i});
               obj.Items{i}.Parent = obj.Panel;
            end   
         else
         % if setting objects are cell array   
            for i = 1:numel(items)
               obj.Names{i} = items{i}.Name;
               obj.Items{i} = items{i};
               obj.Items{i}.Parent = obj.Panel;            
            end
         end   
      end   

      function redraw(obj, names)
         if nargin < 2
         % show all settings   
            names = obj.Names;
         end   
         
         ind = ismember(obj.Names, names);
         
         if ~isempty(obj.Layout)
            delete(obj.Layout);
            obj.Layout = [];
         end
         
         set(obj.Panel, 'Visible', 'on')
         obj.Layout = GridBagLayout(obj.Panel, 'HorizontalGap', 5, 'VerticalGap', 10);
         obj.Layout.HorizontalWeights = [1 2];

         obj.Height = 0;
         cellfun(@hide, obj.Items(~ind));
         cellfun(@unhide, obj.Items(ind), num2cell(1:sum(ind)));

         function hide(i)
            i.Visible = 'off';
         end   
         
         function unhide(i, n) 
            i.Visible = 'on';
            obj.Height = obj.Height + i.Height;
            
            if ~isempty(i.gui)
               obj.Layout.add(i.gui.text, n, 1, 'Fill', 'Horizontal', 'Anchor', 'NorthWest', 'TopInset', 3,...
                  'MinimumHeight', i.Height, 'MaximumHeight', i.Height);
               obj.Layout.add(i.gui.control, n, 2, 'Fill', 'Horizontal', 'Anchor', 'NorthWest',...
                  'MinimumHeight', i.Height, 'MaximumHeight', i.Height);            
               
               if strcmp(i.Style, 'pushbutton')
               % hide text field for a button   
                  set(i.gui.text, 'Visible', 'off')
               end   
            end   
         end             
         
         set(obj.Panel, 'Units', 'Pixels', 'Position', [0 0 250 obj.Height])
         set(obj.Panel, 'Visible', 'off')
      end
      
      function show(obj)
         set(obj.Panel, 'Visible', 'on');
         if ~isempty(obj.Parent)
            if size(obj.Parent.parent.gui.settingsLayout.Grid, 1) > 0
               obj.Parent.parent.gui.settingsLayout.remove(1, 1);
            end   
            obj.Parent.parent.gui.settingsLayout.add(obj.Panel, 1, 1, ...
               'Fill', 'Horizontal', ...
               'MinimumHeight', obj.Height, ...
               'MaximumHeight', obj.Height, ...
               'Anchor', 'North');
         end   
      end   
      
      function hide(obj)
         set(obj.Panel, 'Visible', 'off');
      end   
                  
   end   
end