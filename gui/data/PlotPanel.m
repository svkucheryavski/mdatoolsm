classdef PlotPanel < handle
   
   properties (Access = 'private')
      plotTypes = {...
         'scatter', 'line', 'bar', 'densscatter', ...
         'hist', 'qqplot', 'boxplot', 'errorbar',... 
         'gbar', 'gline'};         
   end
   
   % plot constants
   properties (Constant = true, Hidden = true)
      COLORMAPS = {'default', 'gray', 'jet'}; 
      MARKERS = {'none', 'o', 's', 'x', 'd', '*', '.'}
      MARKER_SIZE = [4 6 8 10 12 14 16 18]
      LINE_STYLE = {'none', '-', '--', ':', '-.'};
      LINE_WIDTH = [1 2 3 4 5 6];
      LABELS = {'none', 'names', 'numbers', 'values'}
      SELECTION_EDGE_COLOR = [0.8 0.5 0.3]
      SELECTION_FACE_COLOR = [0.8 0.8 0.8]
      CURCOL_LINE_COLORS = [0.6 0.6 0.6; 0.8 0.8 0.8];
      CURCOL_LINE_WIDTH = 1;
      TOO_MANY_ROWS = 2000;
      ERROR_TYPES = {'se', 'std'};
   end

   % panel constants
   properties (Constant = true, Hidden = true)
      PANEL_BACKGROUND_COLOR = [0.89 0.89 0.89];
      PANEL_BACKGROUND_COLOR_SELECTED = [0.99 0.99 0.97];
      PANEL_TITLE_COLOR = [0.85 0.85 0.85];
      PANEL_TITLE_COLOR_SELECTED = [0.95 0.95 0.88];
   end
   
   properties (SetAccess = 'public')
      options
   end
   
%   properties (SetAccess = 'protected')
   properties
      id
      isCurrentPanel = false
      gui
      parent
      data
      settingsType
      listeners = {}
      plot
      colormap
      colorby
      colorByVariables
      lastMessage
   end
   
   methods
      function obj = PlotPanel(parent, data, settingsPanel, id, varargin)
         
         if ~isa(data, 'mdadata')
            error('Parameter "data" should be an object of "mdadata" class!')
         end
         
         if isa(data, 'mdaimage')
            obj.plotTypes = ['image', obj.plotTypes];
         end
         
         obj.id = id;                 
         obj.parent = parent;                  
         obj.data = data;
         obj.setDefaults(varargin{:});
                                             
         % set defaults and create GUI
         obj.createGUI(settingsPanel);
         obj.listeners{end + 1} = addlistener(obj.data, findprop(obj.data, 'excludedRows'), 'PostSet', @obj.changeExcludedRowsCallback);
         obj.listeners{end + 1} = addlistener(obj.data, findprop(obj.data, 'excludedCols'), 'PostSet', @obj.changeExcludedColsCallback);
         obj.listeners{end + 1} = addlistener(obj.data, findprop(obj.data, 'currentCols'), 'PostSet', @obj.changeCurrentColsCallback);         
         obj.listeners{end + 1} = addlistener(obj.data, findprop(obj.data, 'currentRows'), 'PostSet', @obj.changeCurrentRowsCallback);         
      end
         
      function createGUI(obj, settingsPanel)
         p = obj.parent;
         
         obj.gui.plotPanel = uipanel( 'Parent', obj.parent.gui.panel);
         set(obj.gui.plotPanel, 'BackgroundColor', obj.PANEL_BACKGROUND_COLOR);
         set(obj.gui.plotPanel, 'FontSize', 12);
         set(obj.gui.plotPanel, 'ButtonDownFcn', {@p.selectPanel obj.id});

         if ~isempty(settingsPanel) && ishandle(settingsPanel)
            obj.gui.settingsPanel = SettingsPanel(obj, settingsPanel, obj.options);
         end
         
         obj.gui.plotAxes = axes('Parent', obj.gui.plotPanel, 'Units', 'Normalized');
         set(obj.gui.plotAxes, 'ButtonDownFcn', {@p.selectPanel obj.id});
         set(obj.gui.plotAxes, 'Box', 'on');    
         
         t = obj.options.PlotType.Value;
         eval(['obj.plot = ' upper(t(1)) t(2:end) '(obj);']);
      end
      
      function setDefaults(obj, varargin)

         if obj.data.nRows == 1
            obj.plotTypes = {'line', 'bar'};
         end
         
         if obj.data.nRows > 6   
            i = ismember(obj.plotTypes, {'gline', 'gbar'});
            obj.plotTypes(i) = [];
         end
         
         if obj.data.nRows > 100   
            i = ismember(obj.plotTypes, {'bar'});
            obj.plotTypes(i) = [];
         end
         
         % set up plot type
         [pt, ~] = getarg(varargin, 'PlotType');
         if isempty(pt) || ~ischar(pt)
            pt = obj.plotTypes{1};
         else
            pt = find(ismember(obj.plotTypes, pt), 1);
            if isempty(pt)
               pt = obj.plotTypes{1};               
            else
               pt = obj.plotTypes{pt};                              
            end
         end
         
         % set up settings list type
         [slt, ~] = getarg(varargin, 'settingsType');
         if ~isempty(slt) && ischar(slt) && strcmp(slt, 'full')
            obj.settingsType = 'full';
         else
            obj.settingsType = 'short';            
         end
         
         obj.setColorByVariables();
         obj.options.PlotType = Setting('Plot type', obj.plotTypes, pt, 'popup', @obj.selectPlot);  
         obj.options.Marker = Setting('Marker', obj.MARKERS, 'o', 'popup', @obj.redraw);         
         obj.options.MarkerSize = Setting('Marker size', obj.MARKER_SIZE, 8, 'popup', @obj.redraw);
         obj.options.LineStyle = Setting('Line style', obj.LINE_STYLE, '-', 'popup', @obj.redraw);
         obj.options.LineWidth = Setting('Line width', obj.LINE_WIDTH, 1, 'popup', @obj.redraw);
         obj.options.XAxis = Setting('X axis', obj.data.colNamesWithoutFactors, obj.data.colNamesWithoutFactors{obj.data.currentCols(1)}, 'popup', @obj.changeXAxisCallback);
         obj.options.YAxis = Setting('Y axis', obj.data.colNamesWithoutFactors, obj.data.colNamesWithoutFactors{obj.data.currentCols(2)}, 'popup', @obj.changeYAxisCallback);
         obj.options.ShowLabels = Setting('Show labels', {'none', 'names', 'numbers', 'values'}, 'none', 'popup', @obj.redraw);         
         obj.options.ShowExcludedRows = Setting('Excluded rows', [0 1], 0, 'checkbox', @obj.changeShowExcludedRowsCallback);
         obj.options.ShowExcludedCols = Setting('Excluded cols', [0 1], 0, 'checkbox', @obj.changeShowExcludedColsCallback);
         obj.options.ShowNormal = Setting('Show normal', [0 1], 0, 'checkbox', @obj.redraw);  
         obj.options.ColorBy = Setting('Color by', obj.colorByVariables, 'none', 'popup', @obj.changeColorByCallback);
         obj.options.Colormap = Setting('Colormap', obj.COLORMAPS, 'default', 'popup', @obj.changeColormapCallback);
         obj.options.ErrorType = Setting('Error type', obj.ERROR_TYPES, 'se', 'popup', @obj.redraw);
         obj.options.Alpha = Setting('Alpha', [0.01 0.99], 0.05, 'editnum', @obj.redraw);      
         obj.options.GroupBy = Setting('Group by', obj.data.factorNames, {}, 'checkboxlist', @obj.redraw);         
         
         if ~isempty(obj.data.rowNames)
            obj.options.CurrentRows = Setting('Rows', obj.data.rowNames, obj.data.rowNames{obj.data.currentRows(1)}, 'popup', @obj.changeCurrentRowCallback);
            if obj.data.nRows <= 6  
               obj.options.Rows = Setting('Rows', obj.data.rowNames, obj.data.rowNames, 'checkboxlist', @obj.redraw);
            end   
         else
            obj.options.CurrentRows = Setting('Rows', {}, {}, 'none', []);
         end   
                  
      end   
      
      function redraw(obj, ~, ~)
         if ~isempty(obj.plot)
            obj.plot.redraw();
         end   
      end
      
      function setTitle(obj, title)
         set(obj.gui.panel, 'Title', title);
      end   
                                    
      function selectPanel(obj, ~, ~)
         set(obj.gui.plotPanel, 'BackgroundColor', obj.PANEL_BACKGROUND_COLOR_SELECTED);
         set(obj.gui.plotPanel, 'FontWeight', 'bold');    
         obj.isCurrentPanel = true;
         if isempty(obj.plot)
            obj.selectPlot()
         end   
         obj.gui.settingsPanel.show();
         obj.statusbarText(obj.lastMessage);
      end
      
      function unselectPanel(obj, ~, ~)
         set(obj.gui.plotPanel, 'BackgroundColor', obj.PANEL_BACKGROUND_COLOR);
         set(obj.gui.plotPanel, 'FontWeight', 'normal');         
         obj.isCurrentPanel = false;
         obj.gui.settingsPanel.hide();
      end
      
      %%% data selection
            
      function invertSelectedRows(obj, ~, ~)
         obj.data.selectedRows = ~obj.data.selectedRows;
      end
      
      function invertSelectedCols(obj, ~, ~)
         obj.data.selectedCols = ~obj.data.selectedCols;
      end
      
      %%% settings
            
      function selectPlot(obj, ~, ~)
         obj.statusbarText('');
         
         if ~isempty(obj.plot)
            delete(obj.plot);
            obj.plot = [];
         end         
         
         t = obj.options.PlotType.Value;
         eval(['obj.plot = ' upper(t(1)) t(2:end) '(obj);']);
         obj.plot.redraw();
         obj.plot.setSettings();
         obj.showSettings;
      end   
            
      function showSettings(obj)
         obj.gui.settingsPanel.show();
      end
      
      function setSettingsPanel(obj, settings)
         obj.gui.settingsPanel.redraw(['PlotType' settings]);         
      end
      
      function setColorByVariables(obj)
         c = evalin('base', 'who');
         list = {'none'};
         for i = 1:numel(c)
            v = evalin('base', c{i});
            if isnumeric(v) && numel(v) == obj.data.nRows
               list = [list c{i}];
            end   
         end         
         
         obj.colorByVariables = [list obj.data.colNames];
         
         if isfield(obj.options, 'ColorBy')
            v = obj.options.ColorBy.Value;
            obj.options.ColorBy.Values = obj.colorByVariables;
            if isempty(find(strcmp(obj.colorByVariables, v), 1))
               obj.options.ColorBy.Value = 'none'; 
            end
         end   
      end
            
      function setColorByValues(obj)
         v = obj.options.ColorBy.Value;
         if ~strcmp(v, 'none')
            dataInd = find(strcmp(obj.data.colNames, v), 1);
            if dataInd
               obj.colorby = obj.data(:, dataInd).values;
            else
               obj.colorby = evalin('base', v);
            end
         else
            obj.colorby = [];
         end   
      end
      
      function save(obj, width, height, filename)
         try
            if nargin < 4
               filename = obj.data.name;         
            end
         
            if nargin < 3
               height = 600;
            end
         
            if nargin < 2
               width = 800;
            end
         
            fig = findobj('Type', 'figure');
            pos = get(fig(1), 'Position');
            pos = [pos(1) + pos(3)/2, pos(2) + pos(4)/2];
         
            savePlotDialog(pos, filename, width, height, @obj.savePlot);
         catch 
            errordlg('Error occured while saving the current plot!')
         end
         
      end
      
      function savePlot(obj, src, ~, data)
         set(src, 'Enable', 'off');
         
         height = str2double(get(data.heightField, 'String'));
         width = str2double(get(data.widthField, 'String'));
         filename = get(data.filenameField, 'String');
         typeid = get(data.typeField, 'Value');
         type = get(data.typeField, 'String');
         type = strtrim(lower(type(typeid, :)));
         filename = [filename '.' type];
         fig = figure('visible','off');
         copyobj(obj.plotAxes, fig); 
         printplot(fig, filename, [width height], type);         
         delete(fig)
      end
      
      %%% misc
      
      function showObjSelectionContextMenu(obj)
         src = obj.plot;
         
         if ~isempty(src)
            hcmenu = uicontextmenu;
         
            uimenu(hcmenu, 'Label', 'Clear selection', 'Callback', @src.unselect);
            uimenu(hcmenu, 'Label', 'Invert selection', 'Callback', @src.invertSelection);
            uimenu(hcmenu, 'Label', 'Exclude selected objects','Callback', @src.exclude);
            uimenu(hcmenu, 'Label', 'Include selected objects','Callback', @src.include);
         
            % Attach the context menu to each line
            set(src.selectionHandle, 'uicontextmenu', hcmenu)
         end   
      end
      
      function statusbarText(obj, text, type)
         if ~obj.isCurrentPanel
            obj.lastMessage = text;
            return;
         end
         
         if nargin < 3
            type = 'normal';
         end
         
         if strcmp(type, 'warning')
            text = sprintf('<html><div style="font-size:0.95em;background:#fff0f0;padding:2px5px;color:#a04411">%s</div></html>', text);
         elseif strcmp(type, 'warning')   
            text = sprintf('<html><div style="font-size:0.95em;background:#fff0f0;color:#a01111">%s</div></html>', text);
         else
            text = sprintf('<html><div style="font-size:0.95em;color: 505050;">%s</div></html>', text);
         end   
         
         statusbar(gcf, text);
      end   
     
      %%% callbacks
      
      function changeCurrentColumn(obj, inc, n)
         nCol = obj.data.currentCols(n);
         nCol = nCol + inc;
         
         if nCol < 1
            nCol = obj.data.nNumCols;
         elseif nCol > obj.data.nNumCols
            nCol = 1;
         end
         
         obj.data.currentCols(n) = nCol;
      end
      
      function changeCurrentRow(obj, inc)
         nRow = obj.data.currentRows(1);
         nRow = nRow + inc;
         
         if nRow < 1
            nRow = obj.data.nRows;
         elseif nRow > obj.data.nRows
            nRow = 1;
         end
         
         obj.data.currentRows(1) = nRow;
      end
                  
      function changeShowExcludedRowsCallback(obj, ~, ~)
         obj.data.showExcludedRows = obj.options.ShowExcludedRows.Value == 1;
      end
      
      function changeShowExcludedColsCallback(obj, ~, ~)
         obj.data.showExcludedCols = obj.options.ShowExcludedCols.Value == 1;
      end
      
      function changeExcludedColsCallback(obj, ~, ~)
         obj.options.XAxis.Values = obj.data.colNamesWithoutFactors;
         obj.options.YAxis.Values = obj.data.colNamesWithoutFactors;
         obj.options.XAxis.Value = obj.data.colNamesWithoutFactors{obj.data.currentCols(1)};
         obj.options.YAxis.Value = obj.data.colNamesWithoutFactors{obj.data.currentCols(2)};
         obj.setColorByVariables();
         obj.setColorByValues();
      end
      
      function changeExcludedRowsCallback(obj, ~, ~)
         if ~isempty(obj.data.rowNames)         
            obj.options.Rows.Values = obj.data.rowNames;
            obj.options.Rows.Value = obj.data.rowNames{obj.data.currentRows(1)};
         end   
         obj.setColorByValues();
      end
            
      function changeColorByCallback(obj, ~, ~)                  
         obj.setColorByValues();
         obj.plot.redraw();
      end
      
      function changeColormapCallback(obj, ~, ~)
         v = obj.options.Colormap.Value;
         
         if strcmp(v, 'default')
            v = 'mdadata.getmycolors';
         end
         
         obj.colormap = eval(['@' v]);
         obj.redraw();
      end
            
      function changeCurrentRowsCallback(obj, ~, ~)
         obj.options.Rows.Value = obj.data.rowNames{obj.data.currentRows(1)};
      end
      
      function changeCurrentColsCallback(obj, ~, ~)
         obj.options.XAxis.Value = obj.data.colNamesWithoutFactors{obj.data.currentCols(1)};
         obj.options.YAxis.Value = obj.data.colNamesWithoutFactors{obj.data.currentCols(2)};
      end
            
      function changeXAxisCallback(obj, ~, ~)
         obj.data.currentCols(1) = obj.data.parsecolind(obj.options.XAxis.Value);
      end
      
      function changeYAxisCallback(obj, ~, ~)
         obj.data.currentCols(2) = obj.data.parsecolind(obj.options.YAxis.Value);
      end                       
      
      function onKeyPress(obj, src, event)
         if strcmp(event.Key, 's')
            if ischar(event.Modifier) && (strcmp(event.Modifier, 'command') || strcmp(event.Modifier, 'control'))
               obj.save();
            elseif ismethod(obj.plot, 'select')   
               obj.plot.select();
            end   
         elseif strcmp(event.Key, 'escape') && ismethod(obj.plot, 'unselect')   
            obj.plot.unselect();
         elseif strcmp(event.Key, 'e')&& ismethod(obj.plot, 'exclude')
            obj.plot.exclude();
         elseif strcmp(event.Key, 'i')&& ismethod(obj.plot, 'invertSelection')
            obj.plot.invertSelection();
         elseif strcmp(event.Key, 'a') && ismethod(obj.plot, 'include')
            obj.plot.include();
         else   
            obj.plot.onKeyPress(src, event);
         end   
      end
            
   end
end