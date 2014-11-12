classdef DataPrepPanel < DataPanel
   properties (SetAccess = 'protected')
      prep
      odata
   end
   
   methods
      function obj = DataPrepPanel(parent, data, layout)
         if nargin < 3
            layout = {};
         end
         
         obj = obj@DataPanel(parent, data, layout);
         
         obj.odata = copy(data);
         obj.prep = prep();
         obj.prep.setGUI(obj.gui.settingsPanel, obj.gui.settingsLayout);
         obj.prep.showPanel();
         obj.createCommandPanel();
         obj.listeners{end + 1} = addlistener(obj.prep, findprop(obj.prep, 'items'), 'PostSet', ...
            @obj.changePreprocessingListCallback);
         
      end   

      function createCommandPanel(obj)
         obj.gui.commandPanel = uipanel(obj.gui.settingsPanel);
         
         obj.gui.btnApply = uicontrol(obj.gui.commandPanel, ...
            'Style', 'pushbutton', ...
            'String', 'Apply preprocessing',...
            'Enable', 'off', ...
            'Callback', @obj.Preprocess);
         
         obj.gui.btnReset = uicontrol(obj.gui.commandPanel, ...
            'Style', 'pushbutton', ...
            'String', 'Reset data',...
            'Enable', 'off', ...
            'Callback', @obj.Reset);
         
         layout = GridBagLayout(obj.gui.commandPanel, 'HorizontalGap', 5, 'VerticalGap', 10);
         layout.add(obj.gui.btnApply, 1, 1, 'Fill', 'Horizontal');
         layout.add(obj.gui.btnReset, 1, 2, 'Fill', 'Horizontal');
         obj.gui.settingsLayout.add(obj.gui.commandPanel, 3, 1, 'Fill', 'Horizontal', ...
            'MinimumHeight', 50,...
            'MaximumHeight', 50)
      end
      
      function changePreprocessingListCallback(obj, ~, ~)
         set(obj.gui.btnApply, 'Enable', 'on')
      end
      
      function Preprocess(obj, ~, ~)
         obj.data.valuesAll = obj.odata.valuesAll;
         obj.prep.apply(obj.data);
         obj.redraw()
         set(obj.gui.btnApply, 'Enable', 'off')
         set(obj.gui.btnReset, 'Enable', 'on')
      end   
      
      function Reset(obj, ~, ~)
         obj.data.valuesAll = obj.odata.valuesAll;
         obj.redraw()
         set(obj.gui.btnApply, 'Enable', 'on')
         set(obj.gui.btnReset, 'Enable', 'off')         
      end   
   end   
end
