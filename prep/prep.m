classdef prep < handle
   
   properties (Access = 'private')
      HEIGHT = 20
      BTN_STYLE 
      LNK_STYLE
   end
   
   properties (SetAccess = 'protected', SetObservable = true)
      items
   end
   
   properties (SetAccess = 'protected')
      methodList = {'center', 'scale', 'savgol', 'snv', 'alsbasecorr'};
      gui
      Height = 50;
   end
   
   methods
      function obj = prep()
      end
      
      function p = copy(obj)
         p = prep();
         for i = 1:numel(obj.items)            
            p.add(obj.items{i}.name, obj.items{i}.options{:})
         end
      end
      
      function setGUI(obj, parent, parentLayout)
         obj.gui.parent = parent;
         obj.gui.panel = uipanel(parent);
         obj.gui.parentLayout = parentLayout;
         parentLayout.add(obj.gui.panel, 2, 1, 'Fill', 'Horizontal', 'MinimumHeight', obj.Height,...
          'MaximumHeight', obj.Height, 'Anchor', 'North')      
      end
      
      function showPanel(obj)
         
         if ~isfield(obj.gui, 'panel') || isempty(obj.gui.panel)
            return
         end
         
         h = obj.gui.panel;
         
         % clear the panel
         delete(allchild(h))
         obj.gui.layout = GridBagLayout(h, 'HorizontalGap', 5, 'VerticalGap', 5);
         obj.gui.layout.HorizontalWeights = [1 1 10 1];
         obj.gui.items = [];

         mpath = mfilename('fullpath');
         upIcon = javax.swing.ImageIcon([mpath(1:end-4) 'arrowUp.png']);
         downIcon = javax.swing.ImageIcon([mpath(1:end-4) 'arrowDown.png']);
            
         % show the items
         for i = 1:numel(obj.items);
            item = obj.items{i};
            if item.nOptions > 0
               txt = ['<html><div style="'...
                     'font:bold 11pt Arial, sans-serif;' ...
                     'color: #4433f0;'...
                     'text-decoration: underline;'...
                     '">' item.name '</div></html>'];
               callback = @item.showOptions;   
            else
               txt = ['<html><div style="'...
                     'font:bold 11pt Arial, sans-serif;' ...
                     'color: #111111;'...
                     'text-decoration: none;'...
                     '">' item.name '</div></html>'];
               callback = [];   
            end  
            if i == 1
               obj.gui.items(i).arrowUp = obj.addButton(h, '', 'Move up', {@obj.up, i}, upIcon, true);
            else   
               obj.gui.items(i).arrowUp = obj.addButton(h, '', 'Move up', {@obj.up, i}, upIcon);
            end
               
            if i == numel(obj.items)
               obj.gui.items(i).arrowDn = obj.addButton(h, '', 'Move down', {@obj.down, i}, downIcon, true);
            else   
               obj.gui.items(i).arrowDn = obj.addButton(h, '', 'Move down', {@obj.down, i}, downIcon);
            end

            obj.gui.items(i).name = obj.addButton(h, txt, 'Change parameters', callback);
            obj.gui.items(i).cross = obj.addButton(h, 'x', 'Remove method', {@obj.remove, i});
                              
               obj.gui.layout.add(obj.gui.items(i).arrowUp, i, 1, 'Fill', 'Both', ...
                  'MaximumHeight', obj.HEIGHT, 'MinimumHeight', obj.HEIGHT, ...
                  'MaximumWidth', 10)
               obj.gui.layout.add(obj.gui.items(i).arrowDn, i, 2, 'Fill', 'Both', ...
                  'MaximumHeight', obj.HEIGHT, 'MinimumHeight', obj.HEIGHT, ...
                  'MaximumWidth', 10)
               obj.gui.layout.add(obj.gui.items(i).name, i, 3, 'Fill', 'Both', ...
                  'MaximumHeight', obj.HEIGHT, 'MinimumHeight', obj.HEIGHT)
            
               obj.gui.layout.add(obj.gui.items(i).cross, i, 4, 'Fill', 'Both', ...
                  'MaximumHeight', obj.HEIGHT, 'MinimumHeight', obj.HEIGHT, ...
                  'MaximumWidth', 10)   
          end   
            
          if isempty(i)
            i = 0;
          end
            
          obj.gui.addList = uicontrol(h, 'Style', 'popup', 'String', obj.methodList);
          obj.gui.addBtn = uicontrol(h, 'Style', 'pushbutton', 'String', 'Add', 'Callback', @obj.guiAdd);
            
          obj.gui.layout.add(obj.gui.addList, i + 1, 3, ...
            'Fill', 'Horizontal', ...
            'MinimumHeight', obj.HEIGHT, ...
            'MaximumHeight', obj.HEIGHT, ...
            'TopInset', 10,...
            'BottomInset', 5)   
         
          obj.gui.layout.add(obj.gui.addBtn, i + 1, 4, ...
            'Fill', 'Horizontal', ...
            'MinimumHeight', obj.HEIGHT, ...
            'MaximumHeight', obj.HEIGHT, ...
            'TopInset', 10,...
            'BottomInset', 5) 
         
         set(obj.gui.panel, 'Position', [0 0 250 obj.Height]);
                  
         obj.gui.parentLayout.setConstraints(2, 1,...
            'MinimumHeight', obj.Height,...
            'MaximumHeight', obj.Height)         
      end
      
      function up(obj, ~, ~, n)
         if n > 1
            i = obj.items{n - 1};
            obj.items{n - 1} = obj.items{n};
            obj.items{n} = i;
            obj.showPanel()
         end   
      end
      
      function down(obj, ~, ~, n)
         if n < numel(obj.items)
            i = obj.items{n + 1};
            obj.items{n + 1} = obj.items{n};
            obj.items{n} = i;
            obj.showPanel()
         end   
      end
      
      function add(obj, method, varargin)
         n = numel(obj.items) + 1;
         obj.items{n} = eval(['prep' upper(method(1)) method(2:end) '(varargin{:})']);
      end
      
      function guiAdd(obj, ~, ~)
         name =  obj.methodList{get(obj.gui.addList, 'Value')};
         obj.add(name);
         obj.Height = obj.Height + obj.HEIGHT;
         obj.showPanel();
      end
      
      function bt = addButton(obj, parent, string, tooltip, callback, icon, disable)
         try
            bt = com.mathworks.mwswing.MJButton(string);
            bt.setBorder([]);
            %bt.setBackground(java.awt.Color.white);

            bt.setCursor(java.awt.Cursor(java.awt.Cursor.HAND_CURSOR));
            bt.setFlyOverAppearance(true);
            bt.setToolTipText(tooltip);

            if nargin > 6
               bt.setEnabled(~disable)
            end

            if nargin > 5 && ~isempty(icon)
                  bt.setIcon(icon);
            end

            if nargin > 4 && ~isempty(callback)
               set(bt, 'ActionPerformedCallback', callback);
            end
         catch e
            error('Can not add a Java button to GUI!')
         end   
         [~, bt] = javacomponent(bt, [0 0 1 1], parent);         
      end
      
      function remove(obj, ~, ~, n)
         if n < 1 || n > numel(obj.items)
            return
         end
         
         obj.Height = obj.Height - obj.HEIGHT;
         obj.items(n) = [];    
         obj.showPanel();
      end
      
      function varargout = apply(obj, data)
         if isa(data, 'mdadata')
            isDataset = true;
            values = data.valuesAll(:, ~data.factorCols);
            excludedRows = data.excludedRows;
            excludedCols = data.excludedCols(~data.factorCols);
         else
            isDataset = false;
            values = data;
            excludedRows = false(size(values, 1), 1);
            excludedCols = false(1, size(values, 2));
         end
         
         for i = 1:numel(obj.items)
            values = obj.items{i}.apply(values, excludedRows, excludedCols);            
         end   
         
         if isDataset
            data.valuesAll(:, ~data.factorCols) = values;
         else
            data = values;
         end   
         
         if nargout > 0
            varargout = {data};
         end   
      end   
      
      function varargout = sweep(obj, data)
      % 'sweep' removes preprocessing effects from the data
      %
         if isa(data, 'mdadata')
            isDataset = true;
            values = data.valuesAll(:, ~data.factorCols);
            excludedRows = data.excludedRows;
            excludedCols = data.excludedCols(~data.factorCols);
         else
            isDataset = false;
            values = data;
            excludedRows = false(size(values, 1), 1);
            excludedCols = false(1, size(values, 2));
         end
         
         for i = numel(obj.items):-1:1
            values = obj.items{i}.sweep(values, excludedRows, excludedCols);            
         end   
         
         if isDataset
            data.valuesAll(:, ~data.factorCols) = values;
         else
            data = values;
         end   
         
         if nargout > 0
            varargout = {data};
         end            
      end
      
   end
end