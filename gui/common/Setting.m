classdef Setting < handle
   
   properties (Constant)
      HEIGHT = 35;
      LIST_HEIGHT = 25;
      LIST_BACKGROUND = [0.96 0.96 0.96];      
   end   
   
   properties
      gui
      Height = 35
      Parent
      Name
      Values
      Value
      Visible = 'off'
      Callback
      Style
   end   
   
   methods
      
      function obj = Setting(name, values, value, style, callback)
         obj.Name = name;
         obj.Values = values;
         obj.Style = style;
         obj.Callback = callback;
         
         if ~isempty(style) > 0 && ~strcmp(style, 'none')
            obj.createWidget()
         else
            obj.gui = [];
         end   
         obj.Value = value;
      end
      
      function createWidget(obj)
         obj.gui.text = uicontrol('Style', 'Text', 'String', obj.Name, 'Visible', 'off');
         
         switch obj.Style
            case 'popup'
               obj.createPopup()
            case 'checkbox'   
               obj.createCheckbox()
            case 'checkboxlist'
               obj.createCheckboxlist()
            case 'editnum'
               obj.createEditnum()
            case 'pushbutton'
               obj.createPushbutton()
            otherwise
               error('Invalid style for setting object!')
         end
      end
      
      function createPopup(obj)
         obj.Height = obj.HEIGHT;
         obj.gui.control = uicontrol('Style', 'popup',... 
            'String', obj.Values, 'Callback', obj.Callback,...
            'Visible', 'off');
      end
      
      function createPushbutton(obj)
         obj.Height = obj.HEIGHT;
         obj.gui.control = uicontrol('Style', 'pushbutton',... 
            'String', obj.Name, 'Callback', obj.Callback,...
            'Visible', 'off');
      end
      
      function createEditnum(obj)
         obj.Height = obj.HEIGHT;
         obj.gui.control = uicontrol('Style', 'edit',... 
            'Callback', @obj.checkEditnumValue,...
            'BackgroundColor', 'w',...
            'Visible', 'off');
      end
      
      function createCheckbox(obj)
         obj.Height = obj.HEIGHT;
         obj.gui.control = uicontrol('Style', 'checkbox',... 
            'Min', obj.Values(1), 'Max', obj.Values(2), ...
            'Callback', obj.Callback, 'Visible', 'off');            
      end
      
      function createCheckboxlist(obj)
         if isfield(obj.gui, 'layout') && ~isempty(obj.gui.layout)
            delete(obj.gui.layout);
            obj.gui.layout = [];
         end
         
         if isfield(obj.gui, 'list') && ~isempty(obj.gui.list)
            delete(obj.gui.list(:));
            obj.gui.list = [];
         end
         
         if isfield(obj.gui, 'control') && ~isempty(obj.gui.control)
            delete(obj.gui.control);
            obj.gui.control = [];
         end
         
         obj.Height = numel(obj.Values) * obj.LIST_HEIGHT + 10;
         obj.gui.control = uipanel('Units', 'pixels', 'Position', [1 obj.Height 150 obj.Height],...
            'BorderType', 'line', 'BackgroundColor', obj.LIST_BACKGROUND, 'Visible', 'off');
         obj.gui.layout = GridBagLayout(obj.gui.control, 'HorizontalGap', 5, 'VerticalGap', 2);
         obj.gui.layout.HorizontalWeights = [2 1];

         for i = 1:numel(obj.Values)  
            obj.gui.labels(i) = uicontrol('Parent', obj.gui.control, 'Style', 'text', ...
               'String', obj.Values{i}, 'BackgroundColor', obj.LIST_BACKGROUND,...
               'HorizontalAlignment', 'left');
            obj.gui.list(i) = uicontrol('Parent', obj.gui.control, ...
               'Style', 'checkbox', 'Min', 0, 'Max', 1, 'Value', 0,... 
               'Callback', obj.Callback, 'BackgroundColor', obj.LIST_BACKGROUND,...
               'HorizontalAlignment', 'left');                   
            obj.gui.layout.add(obj.gui.labels(i), i + 1, 1, 'Fill', 'both', 'TopInset', 3)
            obj.gui.layout.add(obj.gui.list(i), i + 1, 2, 'Fill', 'both', 'TopInset', 2)                  
         end
      end
      
      function set.Parent(obj, parent)
         obj.Parent = parent;
         obj.setGUIParent();
      end
      
      function setGUIParent(obj)
         if ~isempty(obj.gui)
            set(obj.gui.text, 'Parent', obj.Parent);
            set(obj.gui.control, 'Parent', obj.Parent);
         end   
      end
      
      function out = get.Value(obj)
         if ~isempty(obj.gui)
            if strcmp(obj.Style, 'checkboxlist')
               if isfield(obj.gui, 'list')
                  v = get(obj.gui.list(:), 'Value');
                  if ~iscell(v); v = {v}; end
                  out = find([v{:}]);
               else
                  out = [];
               end   
            elseif strcmp(obj.Style, 'popup')   
               if iscell(obj.Values)
                  out = obj.Values{get(obj.gui.control, 'Value')};
               else
                  out = obj.Values(get(obj.gui.control, 'Value'));
               end               
            elseif strcmp(obj.Style, 'editnum')   
               out = str2double(get(obj.gui.control, 'String'));
            else   
               out = get(obj.gui.control, 'Value');
            end
         else
            out = obj.Value;
         end   
      end
      
      function set.Values(obj, values)
         obj.Values = values;
         if ~isempty(obj.gui)
            if strcmp(obj.Style, 'checkboxlist')
               createCheckboxlist(obj)            
            elseif strcmp(obj.Style, 'popup')
               set(obj.gui.control, 'String', values);
            end   
         end   
      end
      
      function set.Value(obj, value)
         if ~isempty(obj.gui)
            if strcmp(obj.Style, 'checkboxlist') 
               ind = find(ismember(obj.Values, value));
               obj.Value = ind;
               if isfield(obj.gui, 'list')
                  set(obj.gui.list(ind), 'Value', 1);
               end   
            elseif strcmp(obj.Style, 'popup')
               ind = find(ismember(obj.Values, value));
               obj.Value = ind;
               set(obj.gui.control, 'Value', ind);
            elseif strcmp(obj.Style, 'editnum')
               if ~isempty(obj.Values) && (~isnumeric(value) || value < obj.Values(1) ...
                     || value > obj.Values(2))
                  error('Parameter "%s" should be a number between %f and %f!', ...
                     obj.Name, obj.Values(1), obj.Values(2))
               else
                  set(obj.gui.control, 'String', num2str(value));
               end
            elseif ~strcmp(obj.Style, 'pushbutton')
               set(obj.gui.control, 'Value', value);            
            end   
         else
            obj.Value = value;
         end   
      end   
      
      function set.Visible(obj, value)
         obj.Visible = value;
         
         if ~isempty(obj.gui)
            set(obj.gui.text, 'Visible', value);
            set(obj.gui.control, 'Visible', value);
         end   
      end   
            
      function set.Name(obj, name)
         obj.Name = name;
      end   
      
      function checkEditnumValue(obj, src, event)
         value = obj.Value;
         if ~isempty(obj.Values) && (~isnumeric(value) || value < obj.Values(1) || ...
               value > obj.Values(2))
           errordlg(sprintf('Parameter "%s" should be a number between %.2f and %.2f!', ...
                      obj.Name, obj.Values(1), obj.Values(2)))
             return;
         elseif ~isempty(obj.Callback)
            obj.Callback(src, event);
         end      
      end
      
   end
end   