classdef prepItem < handle
   
   properties (SetAccess = 'protected', Hidden = true)
      name
      fullName
      options = {}
      values
      optionList = {}
      gui
   end
   
   properties (Dependent = true)
      nOptions
   end
   
   methods
      function obj = prepItem(varargin)
      end   
      
      function out = get.nOptions(obj)
         out = size(obj.optionList, 1);
      end
      
      function set.options(obj, values)
      % option list has four columns:
      % 1. Name of the option
      % 2. Possible values: either numerical limits (matrix) or list (cell array)
      % 3. Default value
      % 4. Widget style
      %
         try 
            obj.checkValues(values)
            obj.options = values;
         catch e
            error(e.message)
         end
      end
      
      function checkValues(obj, values)
         nOptions = size(obj.optionList, 1);
         if nOptions > 0
            if numel(values) ~= nOptions
               error('Specify all values for the method (%d)!', nOptions);
            else
               for i = 1:nOptions
                  limits = obj.optionList{i, 2};
                  if ~isempty(limits)
                     if iscell(limits)
                        if isnumeric(values{i})
                           res = ismember(values{i}, [limits{:}]);
                        else
                           res = ~ismember(values{i}, limits);
                        end
                        
                        if ~res
                           throw(MException('prepItem:WrongValue', ...
                              sprintf('Wrong value for parameter "%s"!', obj.optionList{i, 1})));
                        end                        
                     else
                        if values{i} < limits(1) || values{i} > limits(2)
                           throw(MException('prepItem:WrongValue', ...
                              sprintf('Wrong value for parameter "%s"!', obj.optionList{i, 1})));
                        end
                     end   
                  end   
               end   
            end
         end   
      end
      
      function reset(obj)
         if ~isempty(obj.optionList)
            obj.options = obj.optionList(:, 3);
         end   
      end   
   
      function showOptions(obj, ~, ~)
         obj.gui.optionDialog = dialog('Name', ['Preprocessing options (' obj.name ')'],...
            'Position', [0 0 300 (obj.nOptions + 1) * Setting.HEIGHT]);
         l = obj.optionList;
         for i = 1:size(l, 1)
            if strcmp(l{i, 4}, 'popup') && isnumeric(l{i, 3})
               limits = l{i, 2};
               limits = [limits{:}];
            else
               limits = l{i, 2};
            end   
            if strcmp(l{i, 4}, 'editnum')
            % skip checking values in the setting object   
               obj.gui.opt{i} = Setting(l{i, 1}, [], l{i, 3}, l{i, 4}, []);
            else
               obj.gui.opt{i} = Setting(l{i, 1}, limits, l{i, 3}, l{i, 4}, []);
            end
         end
         obj.gui.opt{i + 1} = Setting('Save', [], 0, 'pushbutton', @obj.changeOptionsCallback);
         obj.gui.settingsPanel = SettingsPanel([], obj.gui.optionDialog, obj.gui.opt);
         obj.gui.settingsPanel.redraw(); 
         obj.gui.settingsPanel.show(); 
      end   
      
      function changeOptionsCallback(obj, src, event)
         l = obj.optionList;
         values = cell(1, size(l, 1));
         for i = 1:size(l, 1)
            values{i} = obj.gui.opt{i}.Value;
         end
         
         try 
            obj.checkValues(values)
            obj.options = values;
            delete(obj.gui.optionDialog)
            delete([obj.gui.opt{:}]);
            obj.gui.settingsPanel = [];
         catch e
            errordlg(e.message)
         end   
      end   
   end
   
   methods (Static = true)
   end
end   