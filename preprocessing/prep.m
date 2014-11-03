classdef prep < handle
% 'prep' is a class for data preprocessing.
%
%   p = prep();
%
%
% The main purpose of the 'prep' class is to give a possibility for 
% building a list of preprocessing methods, changing their options and 
% applying the methods to a dataset. Actually 'prep' object can be applied both 
% to datasets (including 'mdaimage' images) as well as to matrices.
% When it is applied to dataset the data values will be changed in the
% existent object, there is now need to create a new variable. If it is
% applied to a conventional Matlab matrix one has to reassign the values.
%
% It "remembers" all parameters, including those, calculated at first run.
% For example if mean centering is used, when a preprocessing object
% applied to a dataset a vector of mean values will be calculated and
% stored in the object. So when we use it next time, the mean values will
% not be calculated again. This is essential, e.g. when we calibrate model
% and the apply it to a new data. If one want to clear all calculations and
% apply the list of methods to a new data from the scratch, just take a
% copy of the object.
%
% Examples:
% ---------
%
%   load simdata;
%
%   % set up list with preprocessing methods and apply
%   p = prep();
%   p.add('savgol', 0, 5, 1);
%   p.add('snv');
%   p.apply(spectra);
%
%   figure
%   plot(spectra)
%
%   % displaying the preprocessing object 
%   show(p)
%
%
% Methods:
% --------
%  add - adds a method to the object
%  remove - removes a method from the object
%  show - shows information about the object
%  apply - apply list of methods from the object to a data
%
%
% Preprocessing methods:
% --------------------------
% "p.add('center')" - mean centering of data.
%
% "p.add('scale')" - standardization (scaling to standard deviation).
%
% "p.add('snv')" - standard normal variate preprocessing to correct scatter effects.
%
% "p.add('savgol', d, w, p)" - Savitzky-Golay transformation, d is derivative (default 0), w is
% width of filter window (default 3, only odd numbers), p is polynomial order (default 1).
%
%


   properties (Access = 'private', Hidden = true)
      HEIGHT = 20
      BTN_STYLE 
      LNK_STYLE
   end
   
   properties (SetAccess = 'protected', SetObservable = true)
      items
   end
   
   properties (SetAccess = 'protected', Hidden = true)
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
      % 'add' add a method to preprocessing object
      %
      %   p = prep();
      %   p.add('savgol', 1, 3, 1);
      %   p.add('center');
      %   show(p);
      %
      
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
      
      function guiRemove(obj, ~, ~, n)
         obj.remove(n);
         obj.Height = obj.Height - obj.HEIGHT;
         obj.showPanel();
      end
      
      function remove(obj, n)
      % 'remove' removes a method to preprocessing object
      %
      %   p = prep();
      %   p.add('savgol', 1, 3, 1);
      %   p.add('center');
      %   show(p);
      %
      %   p.remove(1);
      %   show(p);
      %
      %
         
         if n < 1 || n > numel(obj.items)
            return
         end         
         obj.items(n) = [];    
      end
      
      function varargout = apply(obj, data)
      % 'apply' apply list of methods from the object to a data.
      %
      %   p = prep();
      %   p.add('center');
      %   p.apply(data);
      %
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
      % 'sweep' removes preprocessing effects from the data (undo for preprocessing).
      %
      %  load people
      %  p = prep();
      %  p.add('center');
      %  p.apply(people);
      %  show(people(1:5, 1:5);
      %
      %  p.sweep(people);
      %  show(people(1:5, 1:5);
      %
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
      
      function show(obj)
      % 'show' show information about preprocessing object
      %
      %   p = prep();
      %   p.add('center');
      %   p.add('snv');
      %
      %   show(p);
      %
      %
      
         nItems = numel(obj.items);
         
         fprintf('Preprocessing ("prep") object\n')
         if nItems > 0
            fprintf('methods included: %d\n', nItems)
            for i = 1:nItems
               fprintf('%d. %s (%s)\n', i, obj.items{i}.name, obj.items{i}.fullName);
            end
         else
            fprintf('No methods included yet.\n')            
         end
         fprintf('\n');
         fprintf('Use "obj.add(name, properties)" to add a new method.\n')
         fprintf('Use "obj.remove(n)" to remove a method from the list.\n\n')
         fprintf('See "help prep" for list of available methods.\n')
      end   
   end
end