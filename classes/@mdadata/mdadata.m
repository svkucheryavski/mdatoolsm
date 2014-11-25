classdef mdadata < handle & matlab.mixin.Copyable
% 'mdadata' is a class for storing, manipulation and visualisation of two-way datasets.
%
%   data = mdadata(values);
%   data = mdadata(values, rowNames, colNames);
%   data = mdadata(values, rowNames, colNames, dimNames, name);
%
%
%
% The 'mdadata' class extends possibilities given by matrices with
% ability to use row and column names, exlude columns and rows without
% removing them physically, work with qualitative data, make interactive 
% plots and many others.
%
% The 'mdadata' objects can be manipulated in a similar way as matrices,
% including subsetting, arithmetic and logical operations as well as some 
% mathematical functions can be applied directly to the objects. The result of
% any operation is also an mdadata object. Look at the 
% <a href="mdadata_gs.html">Getting started</a> guide 
% for more details, with a lot of examples.
%
%
% Properties (main):
% ------------------
%  'values' - numeric matrix with data values
%  'rowNames' - cell array with unique row names 
%  'colNames' - cell array with unique column names
%  'dimNames' - cell array with dimension names (columns and rows)
%  'name' - name of the dataset (short text string)
%  'info' - information about the dataset (text string)
%
%
% Properties (extra):
% -------------------
%  'numValues' - numeric matrix with data values without factors
%  'rowFullNames ' - cell array with full text row names 
%  'colFullNames' - cell array with full text column names 
%
%
% Examples:
% ---------
%
%   a = [175 80; 181 78; 165 55];
%   d = mdadata(a);
%   show(d);
%
%   % make a dataset with names for rows, columns and dimensions
%   d = mdadata(a, {'Bob', 'Eva', 'Ron'}, {'Height', 'Weight'}, {'People', 'Parameters'});
%   show(d);
%
%   % add a name and information for the dataset 
%   d.name = 'People';
%   d.info = 'People dataset from 2014';
%   show(d);
%
%
% Methods for displaying and manipulating values:
% -----------------------------------------------
%  'sort' - sort rows of dataset
%  'disp' - displays data values as a table
%  'print' - prints information about the data and the data values 
%  'excludecols' - exclude columns (make them hidden)
%  'excluderows' - exclude rows (make them hidden)
%  'includecols' - include (unhide) columns
%  'includerows' - include (unhide) rows
%  'showexcludedcols' - shows names and numbers of excluded columns
%  'showexcludedrows' - shows names and numbers of excluded rows
%  'removecols' - remove columns from dataset
%  'removerows' - remove rows from dataset
%
%
% Methods for quantitative statistics:
% ------------------------------------
% All methods return result as an 'mdadata' object as well, with proper
% names for rows and columns.
%
%  'mean' - average
%  'var' - variance
%  'std' - standard deviation
%  'median' - median
%  'corr' - correlation matrix
%  'cov' - covariance matrix
%  'percentile' - percentiles
%  'ci' - confidence intervals
%  'se' - standard error
%  'ttest' - one sample t-test
%  'summary' - calculates all statistics for every column
%
%
% Methods for making simple plots:
% --------------------------------
% The plot methods are similar to conventilnal Matlab methods, but give
% some extra possibilities, e.g. automatic labels, color grouping,
% calculation of standard erros, etc.
%
%  'scatter' - scatter plot 
%  'densscatter' - scatter density plot
%  'plot' - line plot
%  'bar' - bar plot
%  'levelplot' - level plot
%  'matrixplot' - 3D representation of the data values 
%  'hist' - distribution histogram plot
%  'boxplot' - box plot
%  'errorbar' - error bar plot
%  'qqplot' - quantile-quantile normal plot
%
%
% Methods for qualitative data:
% -----------------------------
% methods for manipuation and analysis of qualitative data.
%
%  'factor' - mark a column as a factor
%  'notfactor' - mark a factor column as a non-factor
%  'getgroups' - calculate a logical table for combination of factors
%  'freq' - observed frequencies and proportions for a factor
%  'crosstable' - contingency table for two factors
%  'chi2test' - chi-square test for association for two factors
%  'crossresid' - standardized residuals for contingency table
%
%
% Methods for making grouped plots:
% ----------------------------------
% some of the standard plots can also be made for groups of objects or
% observations. In this case the groups will be shown using different
% colors or plot properties (marker, line style) and legend can added.
%
%  'gscatter' - GUI version of scatter plot 
%  'gplot' - GUI version of line plot
%  'gbar' - GUI version for bar plot
%
%
% Methods for interactive graphics:
% ---------------------------------
% most of the plotting methods have also GUI version, which allows to analyse
% data interactively, e.g. switch columns, look at statistics, exclude
% objects and variables, etc. 
%
%  'guiplot' - GUI tool for most of the plots 
%
%

   properties (Constant = true, Hidden = true)
      LEGEND_EDGE_COLOR = [0.8 0.8 0.8]
      EXCLUDED_COLOR = [0.9 0.9 0.9];
      AXIS_LINE_COLOR = [0.8 0.8 0.8];
      LABELS_COLOR = [0.6 0.6 0.6];
      REDUCE_ROWS_LIMIT = 2000; 
   end
   
   properties
      name              % name of the dataset
      info              % information (short text) about the data
      dimNames          % cell array with dimension names 
   end
   
   properties (SetAccess = 'protected', Hidden = true)
      valuesAll         % matrix with all values, including hidden
      factorCols        % vector of columns which are factors
      factorLevelNames  % a cell array with level names for the factors
   end
   
   properties (SetAccess = 'protected', Hidden = true)
      colNamesAll       % cell array with names for all columns
      rowNamesAll       % cell array with names for all rows
      colFullNamesAll   % cell array with full names for all columns
      rowFullNamesAll   % cell array with full names for all rows
   end
   
   properties (SetAccess = 'protected', Hidden = true, SetObservable = true)
      excludedRows      % vector with hidden (excluded) rows
      excludedCols      % vector with hidden (excluded) columns
      selectedRows      % indices of selected rows for GUI
      selectedCols      % indices of selected columns for GUI
      currentRows       % indices of current rows for GUI
      currentCols       % indices of selected columns for GUI
      showExcludedRows = false
      showExcludedCols = false     
   end
   
   properties (Dependent = true)
      values            % data values 
      nCols             % number of unhidden columns
      nRows             % number of unhidden rows 
      nFactors          % number of factors
      rowNames          % row names (only letters and numbers, unique)
      colNames          % column names (only letters and numbers, unique)      
      rowFullNames      % row names with extra symbols, using for printing and plotting
      colFullNames      % column names with extra symbols, using for printing and plotting
   end
   
   properties (Dependent = true, Hidden = true)
      factors           % factor values
      numValues         % get data values without factors
   end
   
   properties (Dependent = true, Hidden = true)
      valuesHidden      % values for excluded rows
      valuesRSelected   % values for selected rows
      valuesCSelected   % values for selected columns
      numValuesAll      % get all data values without factors
      nColsAll          % number of all columns (including hidden)
      nRowsAll          % number of all rows (including hidden)
      nNumCols          % number of columns without factors
      nNumColsAll       % number of all columns (including hidden) without factors
      factorNames       % column names for factors
      factorFullNames   % column full names for factors 
      colNamesWithoutFactors % column names only for quantitative data
      colFullNamesWithoutFactors % column names only for qualitative data
      colNamesAllWithoutFactors % all column names (including hidden) only for quantitative data
      colFullNamesAllWithoutFactors % all column full names (including hidden) only for quantitative data
   end
      
   methods
      
      function obj = mdadata(values, rowNames, colNames, dimNames, name)
         % 'mdadata' creates an object of class 'mdadata'
         %

         if size(values, 1) == 0 || size(values, 2) == 0
            error('Argument "values" is an empty matrix!')
         end   
            
         if nargin < 5
            name = '';
         end
         
         if nargin < 4 || isempty(dimNames)
            dimNames = {'Objects', 'Variables'};
         end
         
         if nargin < 3 
            colNames = {};
         end
         
         if nargin < 2 
            rowNames = {};
         end   
         
         obj.valuesAll = values;
         obj.colNamesAll = colNames;
         obj.rowNamesAll = rowNames;
         obj.dimNames = dimNames; 
         obj.excludedRows = false(obj.nRowsAll, 1);
         obj.selectedRows = false(obj.nRowsAll, 1);
         obj.excludedCols = false(obj.nColsAll, 1);
         obj.selectedCols = false(obj.nColsAll, 1);
         obj.factorCols = false(obj.nColsAll, 1);
         obj.factorLevelNames = cell(obj.nColsAll, 1);
         obj.name = name;
      end
      
      %%% getters and setters
      
      function out = get.values(obj)  
         row_ind = ~obj.excludedRows;
         col_ind = ~obj.excludedCols;
         out = obj.valuesAll(row_ind, col_ind);
      end
      
      function out = get.factors(obj)         
         row_ind = ~obj.excludedRows;
         col_ind = ~(obj.excludedCols) & obj.factorCols;
         out = obj.valuesAll(row_ind, col_ind);
      end
      
      function out = get.numValues(obj)         
         row_ind = ~obj.excludedRows;
         col_ind = ~(obj.excludedCols | obj.factorCols);
         out = obj.valuesAll(row_ind, col_ind);
      end
      
      function out = get.numValuesAll(obj)
         col_ind = ~(obj.excludedCols | obj.factorCols);
         out = obj.valuesAll(:, col_ind);
      end
                        
      function out = get.nRows(obj)
         out = obj.nRowsAll - sum(obj.excludedRows);
      end   
      
      function out = get.nCols(obj)
         out = obj.nColsAll - sum(obj.excludedCols);
      end
      
      function out = get.nNumCols(obj)
         out = obj.nColsAll - sum(obj.excludedCols) - sum(obj.factorCols);
      end   
      
      function out = get.nColsAll(obj)
         out = size(obj.valuesAll, 2);
      end
      
      function out = get.nNumColsAll(obj)
         out = size(obj.valuesAll, 2) - sum(obj.factorCols);
      end   
      
      function out = get.nRowsAll(obj)
         out = size(obj.valuesAll, 1);
      end   
            
      function out = get.nFactors(obj)
         out = sum(obj.factorCols(~obj.excludedCols));
      end      
      
      function out = get.valuesHidden(obj)
         row_ind = obj.excludedRows;
         col_ind = ~obj.excludedCols;
         out = obj.valuesAll(row_ind, col_ind);      
      end
      
      function out = get.valuesRSelected(obj)
         if obj.showExcludedRows
            out = obj.valuesAll(obj.selectedRows, ~obj.excludedCols & ~obj.factorCols);
         else
            out = obj.valuesAll(obj.selectedRows & ~obj.excludedRows, ~obj.excludedCols & ~obj.factorCols);
         end
      end
      
      function out = get.valuesCSelected(obj)
      % returns matrix with values for selected columns and either all rows
      % or selected rows
         if any(obj.selectedRows)
            rowInd = obj.selectedRows & ~obj.excludedRows;
         else
            rowInd = ~obj.excludedRows;
         end
         
         if obj.showExcludedCols
            out = obj.valuesAll(rowInd, obj.selectedCols & ~obj.factorCols);
         else
            out = obj.valuesAll(rowInd, obj.selectedCols & ~(obj.excludedCols | obj.factorCols));
         end
      end
                     
      function out = get.colNames(obj)         
         out = obj.colNamesAll;
         
         if ~isempty(out)
            out(obj.excludedCols) = [];
         end   
      end
      
      function out = get.colFullNames(obj)
         out = obj.colFullNamesAll;
         
         if ~isempty(out)
            out(obj.excludedCols) = [];
         end   
      end
      
      function out = get.factorNames(obj)
         out = obj.colNamesAll;
         
         if ~isempty(out)
            out(~obj.factorCols | obj.excludedCols) = [];
         end         
      end
      
      function out = get.factorFullNames(obj)
         out = obj.colFullNamesAll;
         
         if ~isempty(out)
            out(~obj.factorCols | obj.excludedCols) = [];
         end         
      end
      
      function out = get.colNamesWithoutFactors(obj)
         out = obj.colNamesAll;
         
         if ~isempty(out) 
            out(obj.factorCols | obj.excludedCols) = [];
         end   
      end
      
      function out = get.colNamesAllWithoutFactors(obj)
         out = obj.colNamesAll;
         
         if ~isempty(out) 
            out(obj.factorCols) = [];
         end   
      end
      
      function out = get.colFullNamesWithoutFactors(obj)
         out = obj.colFullNamesAll;
         
         if ~isempty(out) 
            out(obj.factorCols | obj.excludedCols) = [];
         end   
      end
      
      function out = get.colFullNamesAllWithoutFactors(obj)
         out = obj.colFullNamesAll;
         
         if ~isempty(out) 
            out(obj.factorCols) = [];
         end   
      end
      
      %%% setters
      function set.colNamesAll(obj, colNames)         
                  
         nCols = size(obj.valuesAll, 2);

         colFullNames = {};
         
         %%%% check if colNames are provided and generate the names if needed
         
         if isempty(colNames)
         % no colnames - generate them as '1', '2', ...   
            obj.colNamesAll = textgen('', 1:nCols);
         else   
            if ischar(colNames) && nCols == 1
               colNames = {colNames};
            end
            
            if iscell(colNames) && ischar(colNames{1})
            % names are provided as a text cell array    
            
               % keep full names
               colFullNames = colNames;
               
               % remove all symbols which are non letter nor numbers
               % merge words and capitalise them
               for i = 1:numel(colNames)
                  a = regexp(colNames{i}, '[^A-Za-z0-9\.\-\s]', 'split');
                  a = regexp(strtrim(a{1}), '\s', 'split');
                  %a = cellfun(@(x)([upper(x(1)) x(2:end)]), a, 'UniformOutput', false);
                  colNames{i} = sprintf('%s', a{:});
               end
            end
            
            if numel(unique(colNames)) ~= numel(colNames)
               error('Column names must be unique!')
            elseif numel(unique(colFullNames)) ~= numel(colFullNames)
               error('Column names must be unique!')
            elseif (numel(colNames) ~= nCols)
               error('Number of names should be the same as number of columns!');
            elseif isnumeric(colNames)
               obj.colNamesAll = textgen('', colNames);
            elseif iscell(colNames) && ischar([colNames{:}])
               obj.colNamesAll = colNames;
            else
               error('Values for "colNames" argument must be either numeric or cell array with text!');
            end   
            
         end
         
         if isempty(colFullNames)
            obj.colFullNamesAll = obj.colNamesAll;
         else
            obj.colFullNamesAll = colFullNames;
         end   
      end
      
      function set.colNames(obj, colNames)
         obj.colNamesAll = colNames;
      end
      
      function set.colFullNames(obj, colNames)
         obj.colFullNamesAll = colNames;
      end
            
      function set.rowNamesAll(obj, rowNames)         
         
         nRows = size(obj.valuesAll, 1);
         
         rowFullNames = {};
         
         %%% check if rowNames are provided and generate the names if needed
         if ~isempty(rowNames)
            
            if iscell(rowNames) && ischar(rowNames{1})
            % row names are provided as text cell array
            
               % keep full names
               rowFullNames = rowNames;
               
               % remove all symbols which are non letter nor numbers
               % merge words and capitalise them
               for i = 1:numel(rowNames)
                  a = regexp(rowNames{i}, '[^A-Za-z0-9\-\.\s]', 'split');
                  a = regexp(strtrim(strtrim(a{1})), '\s', 'split');
                  %a = cellfun(@(x)([upper(x(1)) x(2:end)]), a, 'UniformOutput', false);
                  rowNames{i} = sprintf('%s', a{:});
               end
            end
            
            if numel(unique(rowNames)) ~= numel(rowNames)
               error('Row names must be unique!')
            elseif (numel(rowNames) ~= nRows)
               error('Number of names should be the same as number of objects!');
            elseif isnumeric(rowNames)
               rowNames = textgen('', rowNames);
               if size(rowNames, 1) < size(rowNames, 2)
                  rowNames = rowNames';
               end   
               obj.rowNamesAll = rowNames;
            elseif iscell(rowNames) && ischar([rowNames{:}])
               obj.rowNamesAll = rowNames;
            else
               error('Row names must be either numeric or cell array with text values!');
            end    
%          elseif nRows < 2000
%          % if number of rows is large no names will be used, otherwise generate then from numbers   
%             obj.rowNamesAll = textgen('', 1:nRows)';
         else   
            obj.rowNamesAll = {};
         end   
         
         if isempty(rowFullNames)
            obj.rowFullNamesAll = obj.rowNamesAll;
         else
            obj.rowFullNamesAll = rowFullNames ;
         end            
      end

      function set.rowNames(obj, rowNames)
         obj.rowNamesAll = rowNames;
      end
      
      function set.rowFullNames(obj, rowNames)
         obj.rowFullNamesAll = rowNames;
      end
      
      function out = get.rowNames(obj)
         out = obj.rowNamesAll;
         
         if ~isempty(out)
            out(obj.excludedRows) = [];
         end   
      end
      
      function out = get.rowFullNames (obj)
         out = obj.rowFullNamesAll;
         
         if ~isempty(out)
            out(obj.excludedRows) = [];
         end   
      end

      function set.dimNames(obj, dimNames)
         if ~isempty(dimNames)
            if sum(cellfun(@ischar, dimNames)) ~=2 || numel(dimNames) ~= 2
               error('Parameter dimNames should be a cell with two text values!')
            else   
               obj.dimNames = dimNames;
            end   
         end   
      end
      
      function out = getfullrowind(obj, ind)
      % 'getfullrowind' returns numeric indices for rows, taking into 
      % account hidden rows   
      
      
         ind = parserowind(obj, ind);
         
         fullRowInd = 1:obj.nRowsAll;
         fullRowInd(obj.excludedRows) = [];
         
         out = fullRowInd(ind);
      end
      
      function out = getfullcolind(obj, ind, full, withFactors)
      % 'getfullcolind' returns numeric indices for columns, taking into 
      % account hidden columns

         if nargin < 3
            full = false;
         end
         
         if nargin < 4
            withFactors = true;
         end   
         ind = parsecolind(obj, ind, full, withFactors);
         fullColInd = 1:obj.nColsAll;
         fullColInd((~full & obj.excludedCols) | (~withFactors & obj.factorCols)) = [];
         out = fullColInd(ind);
      end
      
      function set.selectedRows(obj, ind)
         if isempty(ind)
            obj.selectedRows = false(obj.nRowsAll, 1);
         elseif isnumeric(ind)
            obj.selectedRows(ind) = true;
         elseif islogical(ind)   
            obj.selectedRows = ind;
         else
            error('Wrong indices for selected rows!')
         end
      end   
      
      function set.selectedCols(obj, ind)
         if isempty(ind)
            obj.selectedCols = false(obj.nColsAll, 1);
         elseif isnumeric(ind)
            obj.selectedCols(ind) = true;
         elseif islogical(ind)   
            obj.selectedCols = ind;
         else
            error('Wrong indices for selected rows!')
         end
      end
      
      function set.currentRows(obj, ind)
         obj.currentRows = ind;
      end   
      
      function set.currentCols(obj, ind)
         if all(ind > 0) && all(ind <= obj.nCols) 
            obj.currentCols = ind;
         end   
      end   
      
      function ind = get.selectedRows(obj)
         ind = obj.selectedRows;
      end   
      
      function ind = get.selectedCols(obj)
         ind = obj.selectedCols;
      end   
            
      function ind = get.currentRows(obj)
         if isempty(obj.currentRows)
            obj.currentRows = [1 1];
         end   
         
         ind = obj.currentRows;
      end   
      
      function ind = get.currentCols(obj)
         if isempty(obj.currentCols)
            if obj.nCols > 1
               obj.currentCols = [1 2];
            else
               obj.currentCols = [1 1];
            end   
         end   
         
         ind = obj.currentCols;
      end   
            
      %%% methods for including/excluding/removing values and variables
      
      function excluderows(obj, ind, type)
      % 'exlcluderows' exclude (hide) rows from the dataset
      %
      % The method allows to hide rows without removing them from
      % the dataset. The hidden rows will not be used in calculations,
      % plots, etc. 
      %
      % Examples:
      % ---------
      %   load people
      %   d = people(1:8, 1:4);
      %   
      %   disp(d)
      %
      %   d.excluderows(2);
      %   disp(d)
      %
      %   d.excluderows({'Lars', 'Lene'})
      %   disp(d)
      %
      %
      
         if islogical(ind)
            ind = find(ind);
         end
         
         if isempty(ind) 
            return
         end   
            
         if nargin < 3 || ~strcmp(type, 'full')
            ind = getfullrowind(obj, ind);         
         end
         
         obj.selectedRows = [];
         obj.excludedRows(ind) = true;        
      end
      
      function includerows(obj, ind, type)     
      % 'includerows' include (unhide) hidden rows 
      %
      % The method unhides the excluded rows. Be aware, that 
      % the hidden rows have specific numeration, use 'showexcludedrows(data)' 
      % to see the names and numbers of the hidden rows.
      %
      % Examples:
      % ---------
      %   load people
      %   d = people(1:8, 1:4);
      %   
      %   disp(d)
      %
      %   d.excluderows(1:3);
      %   disp(d)
      %
      %   d.includerows('Lars');
      %   disp(d)
      %
      %      
         if nargin < 2 || (isnumeric(ind) && isempty(ind)) || (islogical(ind) && ~any(ind)) 
            return;
         end   
         
         if nargin < 3 || ~strcmp(type, 'full')
            ind = parserowind(obj, ind, true);
         end
         
         obj.selectedRows = [];
         obj.excludedRows(ind) = false;
      end
      
      function showexcludedrows(obj)
      % 'showexcludedrows' shows numbers and names (if available) of the 
      % exluded (hidden) rows as a table
      %
      %   load people
      %   
      %   people.excluderows(1:4);
      %   people.showexcludedrows
      %
      
         ind = find(obj.excludedRows);
         
         if isempty(ind)
            disp('No excluded rows found.')
         else   
            fprintf('Excluded rows: \n')
            mdadata.showexcluded(ind, obj.rowNamesAll);
         end         
      end         
      
      function excludecols(obj, ind, full, withFactors)
      % 'exlcludecols' exclude (hide) columns from the dataset
      %
      % The method allows to hide columns without removing them from
      % dataset. The hidden columns will not be counted in any operations,
      % calculations, etc. 
      %
      % Examples:
      % ---------
      %   load people
      %   d = people(1:5, 1:8);
      %   
      %   disp(d)
      %
      %   d.excludecols(2);
      %   disp(d)
      %
      %   d.excludecols({'Height', 'Shoesize'})
      %   disp(d)
      %
      %

         if islogical(ind)
            ind = find(ind);
         end
         
         if isempty(ind)
            return
         end   
         
         if nargin < 3
            full = false;
         end
         
         if nargin < 4
            withFactors = true;
         end
                  

         ind = getfullcolind(obj, ind, full, withFactors);                  
         
         indCurrent = getfullcolind(obj, obj.currentCols, full, withFactors);
         
         cols = obj.currentCols;
         
         if any(ismember(ind, indCurrent(1)))
            cols(1) = 1;
         else            
            cols(1) = cols(1) - sum(ind < indCurrent(1));
         end
         
         if any(ismember(ind, indCurrent(2)))
            cols(2) = 2;         
         else   
            cols(2) = cols(2) - sum(ind < indCurrent(2));
         end   
         
         obj.selectedCols = [];
         obj.currentCols = cols;
         obj.excludedCols(ind) = true;         
      end
      
      function includecols(obj, ind, full, withFactors)
      % 'includecols' include (unhide) hidden columns
      %
      % The method allows to unhide the excluded rows. Be aware, that 
      % the hidden rows have specific numeration, use 'showexcludedcols(data)' 
      % to see the names and numbers of the hidden rows.
      %
      % Examples:
      % ---------
      %   load people
      %   d = people(1:5, 1:8);
      %   
      %   disp(d)
      %
      %   d.excludecols(1:3);
      %   disp(d)
      %
      %   d.includecols('Weight');
      %   disp(d)
      %
         if nargin < 2 || isempty(ind)
            return
         end
         
         if nargin < 3
            full = true;
         end
         
         if nargin < 4
            withFactors = true;
         end

         ind = getfullcolind(obj, ind, full, withFactors);                           
         obj.excludedCols(ind) = false;
      end
            
      function showexcludedcols(obj)
      % 'showexcludedcols' shows numbers and names of the 
      % exluded (hidden) columns as a table
      %
      %   load people
      %   
      %   people.excludecols([1 3 5 7]);
      %   people.showexcludedcols
      %
         
         ind = find(obj.excludedCols);
         
         if isempty(ind)
            disp('No excluded columns found.')
         else   
            fprintf('Excluded columns: \n')
            mdadata.showexcluded(ind, obj.colNamesAll);
         end
      end   
      
      function removecols(obj, rind)
      % 'removecols' remove columns from a dataset
      %
      %   data.removecols(ind);
      %
      %
      % The index of column can be numeric or text, one can also
      % specify a sequence of columns have to be removed.
      %
         if isempty(rind)
            return
         end
         
         ind = false(obj.nColsAll, 1);
         ind(getfullcolind(obj, rind)) = true;

         fullNames = obj.colFullNamesAll;
         obj.valuesAll(:, ind) = [];
         obj.colNamesAll = obj.colNamesAll(~ind);
         obj.colFullNamesAll = fullNames(~ind);      
         obj.factorCols(ind) = [];        
         obj.factorLevelNames(ind) = [];        
         obj.excludedCols(ind) = [];
      end   
      
      function removerows(obj, ind)
      % 'removerows' remove rows from a dataset
      %
      %   data.removerows(ind);
      %
      %
      % The index of rows can be numeric or text, one can also
      % specify a sequence of rows have to be removed.
      %
         if isempty(ind)
            return
         end
         
         ind = getfullrowind(obj, ind);
         
         obj.valuesAll(ind, :) = [];
         obj.excludedRows(ind) = [];
         if ~isempty(obj.rowFullNamesAll)
            obj.rowFullNamesAll(ind) = [];      
         end   
         if ~isempty(obj.rowNamesAll)
            obj.rowNamesAll(ind) = [];
         end
      end   
      
      %%% methods for factors
      
      function varargout = factor(obj, column, levelNames)
      % 'factor' mark a column of a dataset as a factor
      %
      %   factor(data, column);
      %   factor(data, column, levelNames);
      %
      %
      % Factor is a categorical variable with discrete values (levels). If
      % a column marked as a factor it will be shown not among the dataset
      % value ('data.values') but among factors ('data.factors'). It means 
      % the factors will be excluded from all arithmetic and statistic 
      % calculations and/or modelling.
      %
      % Factors are used to split data into groups in some statistic
      % methods and plots, calculation qualitative statistics, making 
      % classification and discrimination models for the data and so on.
      %
      % The argument 'column' is a column name or number to be marked as a
      % factor and optional argument 'levelNames' is a cell array with
      % names for each level of the factor.
      %
      % Examples:
      % ---------
      %
      %   load people
      %   
      %   data = people(1:8, {'Height', 'Weight', 'Beer', 'Sex'});
      %
      %   % show original data
      %   disp(data)
      %   disp(min(data))
      %
      %   % mark column "Sex" as a factor
      %   factor(data, 'Sex')
      %   disp(data)
      %   disp(min(data))
      %
      %   % add text levels for factor "Sex"
      %   factor(data, 'Sex', {'Male', 'Female'})
      %   disp(data)
      %   
      %   % show how values are influenced by factors
      %   disp('All values:')
      %   disp(data.values)
      %   
      %   disp('Only factors:')
      %   disp(data.factors)
      %
      %   disp('Only quantitative data:')
      %   disp(data.numValues)
      %
      %
      
         ind = getfullcolind(obj, column);                  
         
         if numel(ind) ~= 1
            error('Only one column at time can be marked as a factor!');
         end
         
         levels = unique(obj.valuesAll(:, ind));
         if nargin < 3
            levelNames = textgen('', levels);
         elseif numel(levelNames) ~= numel(levels)   
            error('Number of level names should correspond to the number of levels!')
         else
            % resort level names according to order of level values
            [~, ind1] = sort(levels);
            [~, ind2] = sort(ind1);            
            levelNames = levelNames(ind2);            
         end   
         
         obj.factorCols(ind) = true;
         obj.factorLevelNames{ind} = levelNames;
         
         if nargout > 0
            varargout{1} = 1;
         end           
      end
      
      function varargout = notfactor(obj, ind)
      % 'notfactor' marks a column of a dataset as a non-factor
      %
      %   notfactor(data, column);
      %
      %
      % The operation is inverse to what 'factor()' does, the column become 
      % a normal (quantitative) variable.
      %
      
         ind = getfullcolind(obj, ind);
         obj.factorCols(ind) = false;
         obj.factorLevelNames{ind} = {};
         
         if nargout > 0
            varargout{1} = 1;
         end   
      end
      
      function out = isfactor(obj, ind)
      % 'isfactor' check if a column is a factor or not
      %
         ind = getfullcolind(obj, ind);
         out = obj.factorCols(ind);      
      end
      
      function out = getfactors(obj, ind)
      % 'getfactors' return a subset of the data with factor columns only
         f = find(obj.factorCols(~obj.excludedCols));
         
         if nargin > 1 && isnumeric(ind)
            if any(ind > numel(f)) || any(ind < 1)
               error('Wrong indices for factor columns!');
            end   
            f = f(ind);
         end
         
         out = subset(obj, ':', f);
      
      end
      
      function out = splitfactor(obj, ind)
         
         ind = getfullcolind(obj, ind);
         
         if numel(ind) ~= 1
            error('You can split only one factor at time!');
         end 
         
         values = obj.valuesAll(:, ind);
         levels = unique(values);
         levelNames = obj.factorLevelNames{ind};
         nlevels = numel(levels);
         
         newvalues = zeros(size(values, 1), nlevels);
         
         for i = 1:nlevels
            newvalues(:, i) = (values == levels(i)) * 2 - 1;
         end
         
         out = mdadata(newvalues, obj.rowNamesAll, levelNames, {obj.dimNames{1} obj.colNamesAll{ind}});
         out.name = obj.name;
         out.info = obj.info;
         out.rowFullNamesAll = obj.rowFullNamesAll;
         out.excluderows(obj.excludedRows);              
      end
      
      function out = getfactorlevels(obj, ind)
      % 'getfactorlevels' return a cell array with factor levels
      %
         ind = getfullcolind(obj, ind);
         
         if numel(ind) > 1
            error('It is possible to get levels only for one factor at time!');
         end
         
         n = obj.factorLevelNames;
         out = n{ind};
      end
      
      function groups = getgroups(obj, ind)
      % 'groups' returns a dataset with binary values for all possible
      % combinations of specified factors
      %
      %   g = getgroups(data, columns);
      %
      %
      % The method gives an idea how grouping works. It is used
      % in other methods for calculations and plotting of groupped data.
      %
      % Examples:
      % ---------
      %
      %   load people
      %   data = people(1:10, :)
      %
      %   people.factor('Sex', {'Male', 'Female'});
      %   people.factor('Region', {'A', 'B'});
      %
      %   g = getgroups(people, {'Sex', 'Region'});
      %   show(g)
      %
      
      
         if nargin < 2
            ind = 1:obj.nCols;
         end
         
         ind = getfullcolind(obj, ind);
         
         if numel(obj.factorCols(ind)) ~= sum(obj.factorCols(ind))
            error('Only factors can be used to make groups!')
         end   
         
         values = obj.values(:, ind);
         colNames = obj.colNames(ind);
         [nRows, nFactors] = size(values);
         
         % get factor values as level indices (1, 2, 3)
         [~, ~, values] = unique(values);
         values = reshape(values, nRows, nFactors);
         
         % get factor values as names
         levelNames = obj.factorLevelNames(ind);
         levels = cellfun(@(x)(numel(unique(x))), num2cell(values, 1));
         
         % set up a vector with level sequences for each factor
         arg = cell(nFactors, 1);
         for i = 1:nFactors
            arg{i} = 1:levels(i);
         end   
         
         % get all possible combinations of levels
         comb = allcomb(arg{:});

         % for each combination get vector of logical values for rows
         nComb = size(comb, 1);
         groups = zeros(obj.nRows, nComb);
         fullNames = cell(nComb, 1);
         shortNames = cell(nComb, 1);
         for i = 1:nComb
            levels = unique(values(:, 1));
            v = values(:, 1) == levels(comb(i, 1));
            fullName = [levelNames{1}{comb(i, 1)}];
            shortName = [levelNames{1}{comb(i, 1)}];
            for j = 2:nFactors
               levelsj = unique(values(:, j));
               v = v & values(:, j) == levelsj(comb(i, j));
               fullName = [fullName ', ' levelNames{j}{comb(i, j)}];
               shortName = [shortName levelNames{j}{comb(i, j)}];
            end   
            fullNames{i} = fullName;
            shortNames{i} = shortName;
            groups(:, i) = v;
         end   
         
         dimName = sprintf('%s, ', colNames{:});
         dimName = ['Groups (' dimName(1:end-2) ')'];
         groups = mdadata(groups, obj.rowNames, {}, {obj.dimNames{1}, dimName});
         groups.colFullNames = fullNames;
         
         % remove columns with all false values
         nulind = find(~any(logical(groups.values)));    
         if ~isempty(nulind)
            groups.removecols(nulind);
         end   
      end
            
      %%% overrides for standard math methods
      
      function out = plus(a, b)
         out = op(a, b, @plus);
      end
      
      function out = minus(a, b)
         out = op(a, b, @minus);
      end
      
      function out = uminus(a)
         out = op(a, [], @uminus);
      end
      
      function out = times(a, b)
         out = op(a, b, @times);
      end
      
      function out = mtimes(a, b)
         if isscalar(b)
            colNames = a.colNamesWithoutFactors;
            colFullNames = a.colFullNamesWithoutFactors;
         else
            if ~isa(b, 'mdadata')
               b = mdadata(b);
            end
            colNames = b.colNamesWithoutFactors;
            colFullNames = b.colFullNamesWithoutFactors;
         end   
         out = op(a, b, @mtimes, a.rowNames, a.rowFullNames , colNames, colFullNames);         
      end
      
      function out = rdivide(a, b)
         out = op(a, b, @rdivide);
      end
      
      function out = mrdivide(a, b)
         if isscalar(a)
            colNames = b.colNamesWithoutFactors;
            rowNames = b.rowNames;
            colFullNames = b.colFullNamesWithoutFactors;
            rowFullNames = b.rowFullNames ;
         elseif isscalar(b)
            colNames = a.colNamesWithoutFactors;
            rowNames = a.rowNames;
            colFullNames = a.colFullNamesWithoutFactors;
            rowFullNames = a.rowFullNames ;
         else
            rowNames = a.colNamesWithoutFactors;
            colNames = {};
            rowFullNames = a.colFullNamesWithoutFactors;
            colFullNames = {};
         end   
         out = op(a, b, @mrdivide, rowNames, rowFullNames , colNames, colFullNames);
      end
      
      function out = ldivide(a, b)
         out = op(a, b, @ldivide);
      end
      
      function out = bsxfun(a, b, fun)
         out = mdadata(bsxfun(fun, a.numValues, b.numValues), a.rowNames, a.colNamesWithoutFactors,...
            a.dimNames, a.name);
         out.colFullNames = a.colFullNamesAll(~a.factorCols & ~a.excludedCols);
         out.rowFullNames = a.rowFullNames;
      end
       
      function out = mldivide(a, b)
         out = op(a, b, @mldivide, a.colNames, a.colFullNames, b.colNamesWithoutFactors, ...
            b.colFullNamesWithoutFactors);
         out.dimNames = {'Coefficients', 'Variables'};
      end
                 
      function out = ctranspose(a)
         out = mdadata(ctranspose(a.numValues), a.colNamesWithoutFactors, a.rowNames, a.dimNames(end:-1:1));
         out.name = a.name;
         out.info = a.info;
         out.colFullNames = a.rowFullNames ;
         out.rowFullNames = a.colFullNamesWithoutFactors;
      end
      
      function out = horzcat(a, b, varargin)
         if any(ismember(a.colNames, b.colNames)) 
            colNames = strcat('V', b.colNames);
            colFullNames = strcat('V', b.colFullNames);
         else
            colNames = b.colNames;
            colFullNames = b.colFullNames;
         end   
         out = op(a, b, @horzcat, a.rowNames, a.rowFullNames , ...
            [a.colNames, colNames], [a.colFullNames, colFullNames], a.dimNames, true);
         
         factorCols = [a.factorCols; b.factorCols];
         factorLevelNames = [a.factorLevelNames; b.factorLevelNames];
         
         for i = 1:numel(varargin)
            b = varargin{i};
            if any(ismember(out.colFullNames, b.colFullNames))
               colNames = strcat('V', b.colNames);
               colFullNames = strcat('V', b.colFullNames);
            else
               colNames = b.colNames;
               colFullNames = b.colFullNames;
            end   
            
            out = op(out, b, @horzcat, out.rowNames, out.rowFullNames , [out.colNames, colNames],...
               [out.colFullNames, colFullNames], out.dimNames, true);
            factorCols = [factorCols; b.factorCols];
            factorLevelNames = [factorLevelNames; b.factorLevelNames];    
         end   
         out.factorCols = factorCols;
         out.factorLevelNames = factorLevelNames;
      end
      
      function out = vertcat(a, b, varargin)
         if isempty(a)
            out = b;
            f = find(b.factorCols);
            factorCols = b.factorCols;
            fln = [b.factorLevelNames];            
         else   
            f = find(a.factorCols);
            factorCols = a.factorCols;
            
            aExcludedRows = a.excludedRows;
            bExcludedRows = b.excludedRows;

            a.includerows(aExcludedRows);
            b.includerows(bExcludedRows);

            if sum(ismember(a.rowNames, b.rowNames)) > 0
               rowNames = strcat('O', b.rowNames);
               rowFullNames = strcat('O', b.rowFullNames );
            else
               rowNames = b.rowNames;
               rowFullNames = b.rowFullNames ;
            end   

            af = a.factorCols;         
            bf = b.factorCols;
            fln = [a.factorLevelNames b.factorLevelNames];

            if ~all(af == bf)
               error('Factor columns in data "a" should correspond to factor columns in data "b"!')
            end

            out = op(a, b, @vertcat, [a.rowNames; rowNames], [a.rowFullNames ; rowFullNames ],...
               a.colNames, a.colFullNames, a.dimNames, true);
            out.excluderows([aExcludedRows; bExcludedRows]);
         end
         
         for i = 1:numel(varargin)
            outExcludedRows = out.excludedRows;
            bExcludedRows = b.excludedRows;
         
            out.includerows(outExcludedRows);
            b.includerows(bExcludedRows);
            
            b = varargin{i};
            bf = b.factorCols;
            fln = [fln b.factorLevelNames];
            
            if ~all(af == bf)
               error('Factor columns in data "a" should correspond to factor columns in data "b"!')
            end
            
            if sum(ismember(out.rowFullNames , b.rowFullNames )) > 0
               rowNames = strcat('O', b.rowFullNames );
            else
               rowNames = b.rowFullNames ;
            end   
            
            out = op(out, b, @vertcat, [out.rowNames; rowNames], [out.rowFullNames ; rowFullNames ],...
               out.colNames, out.colFullNames, out.dimNames, true);
            out.excluderows([outExcludedRows; bExcludedRows]);
         end   

         out.factorCols = factorCols;
         for i = 1:numel(f)
            % concatenate level names and keep only unique in the same
            % order as they were added in
            ln = vertcat(fln{f(i), :});
            ln = unique(ln(:), 'stable'); 
            
            % get unique level values in the same order they were added in
            lv = unique(out.valuesAll(:, f(i)), 'stable');
            
            % sort level values and resort names accordingly
            [~, ind] = sort(lv);
            out.factorLevelNames{f(i)} = ln(ind);
         end         
      end
      
      function out = power(a, b)
         out = op(a, b, @power);         
         out.valuesAll = double(out.valuesAll);
      end
      
      function out = log(a)
         out = op(a, [], @log);         
         out.valuesAll = double(out.valuesAll);
      end
      
      function out = sqrt(a)
         out = op(a, [], @sqrt);         
         out.valuesAll = double(out.valuesAll);
      end
      
      function out = abs(a)
         out = op(a, [], @abs);         
      end
      
      function out = exp(a)
         out = op(a, [], @exp);         
      end
      
      function out = round(a)
         out = op(a, [], @round);         
      end

      function out = op(a, b, fun, rowNames, rowFullNames , colNames, colFullNames, dimNames, useAllValues)
      % 'op' a general function for arithmetic operations with mdadata
      %
         if ~isa(a, 'mdadata')
            error('Frst argument should be an object of "mdadata" class!');
         end

         if ~isempty(b) && ~isa(b, 'mdadata') 
            b = mdadata(b);
         end

         if nargin < 9
            useAllValues = false;
         end
         
         if nargin < 8
            dimNames = a.dimNames; 
         end

         if nargin < 7
            colFullNames = a.colFullNamesWithoutFactors; 
         end
         
         if nargin < 6
            colNames = a.colNamesWithoutFactors; 
         end

         if nargin < 5
            rowFullNames = a.rowFullNames ;
         end
         
         if nargin < 4
            rowNames = a.rowNames;
         end
         
         if ~isempty(b)
            if useAllValues
               out = mdadata(fun(a.values, b.values), rowNames, colNames, dimNames);
            else   
               out = mdadata(fun(a.numValues, b.numValues), rowNames, colNames, dimNames);
            end   
         else
           if useAllValues
               out = mdadata(fun(a.values), rowNames, colNames, dimNames);
           else
               out = mdadata(fun(a.numValues), rowNames, colNames, dimNames);
           end   
         end
         
         if ~isempty(colFullNames)
            out.colFullNames = colFullNames;
         end   
         
         if ~isempty(rowFullNames)
            out.rowFullNames = rowFullNames;
         end   
         
         if ~isreal(out.valuesAll)
            out.valuesAll = real(out.valuesAll);
            warning('Complex values were obtained, converted to real.')
         end   
      end
      
      %%% overrides for logical methods
      
      function out = le(obj, val)
         out = le(obj.values, val);
      end
      
      function out = ge(obj, val)
         out = ge(obj.values, val);
      end
      
      function out = lt(obj, val)
         out = lt(obj.values, val);
      end
      
      function out = gt(obj, val)
         out = gt(obj.values, val);
      end
      
      function out = eq(obj, val)
         if obj.nCols == 1 && isfactor(obj, 1) && ischar(val)
            vals = unique(obj.values);
            val = find(ismember(obj.factorLevelNames{1}, val), 1);
            out = eq(obj.values, vals(val));
         else   
            out = eq(obj.values, val);
         end   
      end
      
      function out = ne(obj, val)
         out = ne(obj.values, val);
      end
      
      function out = find(obj, exp)
      %FIND returns dataset's row numbers that meet a logical
      %condition given by parameter 'exp'.
      %
      % i = FIND(data, exp);
      %
      % Parameter exp is a text string with logical expression for columns
      % of the dataset. Either column names or numbers can be used, in
      % the latter case the numbers should have a leading dollar sign ($).
      % Here are some examples:
      %
      % i = FIND(data, 'Sex == 1 & Height > 170');
      % i = FIND(data, '$1 > 10 |�($2 == 1 & $3 > 0.1)');
      %
         out = parserowind(obj, exp);
      end
      
      %%% statistical methods
      
      function out = var(obj, varargin)
      % 'var' calculates variance for each column of dataset, or for one 
      % column, which values are split into groups.
      %
      %   s2 = var(data);
      %   s2 = var(data, factors);
      %
      %
      % By default, method calculates variance for each column of the
      % 'data' object. However if a dataset with factors is provided the
      % method will calculate the variance only for the first column of
      % 'data' by splitting its values into groups, corresponded to all
      % possible combination of the factors.
      %
      % Examples:
      % ---------
      %
      %   load people
      %
      %   % calculate variance for all columns
      %   s2 = var(people);
      %   show(s2)
      %   
      %   % mark columns "Sex" and "Region" as a factors
      %   people.factor('Sex', {'Male', 'Female'})
      %   people.factor('Region', {'A', 'B'})
      %
      %   % calculate variance for "Height" separately for each sex and region.
      %   s2 = var(people(:, 'Height'), people(:, {'Sex', 'Region'}));
      %   show(s2)
      %
      
         if nargin == 1
            groups = [];
         else
            groups = varargin{1};
         end
         
         out = stat(obj, groups, @var, 'Variance');
      end
      
      function out = cov(obj)
      % 'cov' calculates covariance matrix for all pairwise combinations of columns.
      %
      %   c = cov(data);
      %
         
         out = op(obj, [], @cov, obj.colNamesWithoutFactors, obj.colFullNamesWithoutFactors,...
            obj.colNamesWithoutFactors, obj.colFullNamesWithoutFactors);         
         out.dimNames = {'Variables', 'Variables'};
         out.name = 'Covariance';
      end
      
      function out = corr(obj)
      % 'corr' calculates correlation matrix for all pairwise combinations of columns.
      %
      %   r = corr(data);
      %
      
         %TODO: add calculation of confidence intervals and p-values
         out = op(obj, [], @mdacorr, obj.colNamesWithoutFactors, obj.colFullNamesWithoutFactors,...
            obj.colNamesWithoutFactors, obj.colFullNamesWithoutFactors);         
         out.dimNames = {'Variables', 'Variables'};
         out.name = 'Correlation';
      end
                  
      function out = mean(obj, varargin)
      % 'mean' calculates average value for each column of dataset or for one 
      % column, which values are split into groups.
      %
      %    m = mean(data);
      %    m = mean(data, factors);
      %
      %
      % By default, method calculates mean value for each column of the
      % 'data' object. However if a dataset with factors is also provided the
      % method will calculate the mean value only for the first column of
      % 'data' by splitting its values into groups, corresponded to all
      % possible combination of the factors.
      %
      % Examples:
      % ---------
      %
      %   load people
      %
      %   % calculate mean value for each column
      %   m = mean(people);
      %   show(m)
      %   
      %   % mark columns "Sex" and "Region" as a factors
      %   people.factor('Sex', {'Male', 'Female'})
      %   people.factor('Region', {'A', 'B'})
      %
      %   % calculate mean value for "Height" separately for each sex and region.
      %   m = mean(people(:, 'Height'), people(:, {'Sex', 'Region'}));
      %   show(m)
      %
      
         if nargin == 1
            groups = [];
         else
            groups = varargin{1};
         end
      
         out = stat(obj, groups, @mean, 'Mean');
      end
      
      function out = std(obj, varargin)
      % 'std' calculates standard deviation for each column of dataset or for one
      % column, which values are split into groups.
      %
      %    s = std(data);
      %    s = std(data, factors);
      %
      %
      % By default, method calculates standard deviation for each column of the
      % 'data' object. However if a dataset with factors is also provided the
      % method will calculate the value only for the first column of
      % 'data' by splitting its values into groups, corresponded to all
      % possible combination of the factors.
      %
      % Examples:
      % ---------
      %
      %   load people
      %
      %   % calculate standard deviation for each column
      %   s = std(people);
      %   show(s)
      %   
      %   % mark columns "Sex" and "Region" as a factors
      %   people.factor('Sex', {'Male', 'Female'})
      %   people.factor('Region', {'A', 'B'})
      %
      %   % calculate standard deviation for "Height" separately for each sex and region.
      %   s = std(people(:, 'Height'), people(:, {'Sex', 'Region'}));
      %   show(s)
      %
      
         if nargin == 1
            groups = [];
         else
            groups = varargin{1};
         end
      

         out = stat(obj, groups, @std, 'Stdev');
      end
      
      function out = se(obj, varargin)
      % 'se' calculates standard error of mean for each column of dataset or for 
      % the first column, which values are split into groups.
      %
      %   s = se(data);
      %   s = se(data, factors);
      %
      %
      % By default, method calculates standard error for each column of the
      % 'data' object. However if a dataset with factors is also provided the
      % method will calculate the value only for the first column of
      % 'data' by splitting its values into groups, corresponded to all
      % possible combination of the factors.
      %
      % Examples:
      % ---------
      %
      %   load people
      %
      %   % calculate standard error for each column
      %   s = se(people);
      %   show(s)
      %   
      %   % mark columns "Sex" and "Region" as a factors
      %   people.factor('Sex', {'Male', 'Female'})
      %   people.factor('Region', {'A', 'B'})
      %
      %   % calculate standard error for "Height" separately for each sex and region.
      %   s = se(people(:, 'Height'), people(:, {'Sex', 'Region'}));
      %   show(s)
      %
      
         if nargin == 1
            groups = [];
         else
            groups = varargin{1};
         end
         
         out = stat(obj, groups, @mdase, 'Std. error');
      end
      
      function out = ci(obj, varargin)
      % 'ci' calculates confidence interval using Student's t-distribution either 
      % for each column of dataset or for the first column, which values are split
      % into groups.
      %
      %   s = ci(data);
      %   s = ci(data, alpha);
      %   s = ci(data, factors);
      %   s = ci(data, factors, alpha);
      %
      %
      % By default, method calculates confidence interval for each column of the
      % 'data' object. However if a dataset with factors is also provided the
      % method will calculate the interval only for the first column of
      % 'data' by splitting its values into groups, corresponded to all
      % possible combination of the factors.
      %
      % Argument 'alpha' is a signigicance level (between 0 and 1, default is 0.05).
      %
      % Examples:
      % ---------
      %
      %   load people
      %
      %   % calculate confidence interval for each column
      %   s = ci(people);
      %   show(s)
      %   
      %   % mark columns "Sex" and "Region" as a factors
      %   people.factor('Sex', {'Male', 'Female'})
      %   people.factor('Region', {'A', 'B'})
      %
      %   % calculate confidence interval for "Height" separately for each sex and region.
      %   s = ci(people(:, 'Height'), people(:, {'Sex', 'Region'}));
      %   show(s)
      %
      %   s = ci(people(:, 'Height'), people(:, {'Sex', 'Region'}), 0.10);
      %   show(s)
      %
      
         if nargin == 1
            groups = [];
            alpha = 0.05;
         elseif nargin == 2 
            if isa(varargin{1}, 'mdadata') 
               groups = varargin{1};
               alpha = 0.05;
            elseif isnumeric(varargin{1})   
               alpha = varargin{1};
               groups = [];
            else
               alpha = 0.05;
               groups = [];
            end   
         elseif nargin == 3
            groups = varargin{1};
            alpha = varargin{2};
         end
         out = stat(obj, groups, @mdaci, {'Lower', 'Upper'}, ...
            sprintf('Confidence intervals (%.0f%%)', 100 * (1 - alpha)), alpha);
      end
      
      function out = ttest(obj, varargin)
      % 'ttest' calculates one-sample t-test p-value for each column of dataset or 
      % for the first column, which values are split into groups.
      %
      %   p = ttest(data);
      %   p = ttest(data, mu);
      %   p = ttest(data, factors);
      %   p = ttest(data, factors, mu);
      %
      %
      % By default, method calculates p-value for each column of the
      % 'data' object. However if a dataset with factors is also provided the
      % method will calculate the value only for the first column of
      % 'data' by splitting its values into groups, corresponded to all
      % possible combination of the factors.
      %
      % Argument 'mu' is the tested average. By default it is 0. 
      % The p-values are calculated for each tail and both.
      %
      % Examples:
      % ---------
      %
      %   load people
      %
      %   % calculate p-values for each column
      %   p = ttest(people);
      %   show(p)
      %
      %   % mark columns "Sex" and "Region" as a factors
      %   people.factor('Sex', {'Male', 'Female'})
      %   people.factor('Region', {'A', 'B'})
      %
      %   % calculate p-values for "Height" separately for each sex and region.
      %   s = ttest(people(:, 'Height'), people(:, {'Sex', 'Region'}));
      %   show(s)
      %   
      %   s = ttest(people(:, 'Height'), people(:, {'Sex', 'Region'}), 170);
      %   show(s)
      %
      
      
         if nargin == 1
            groups = [];
            mu = 0;
         elseif nargin == 2 
            if isa(varargin{1}, 'mdadata') 
               groups = varargin{1};
               mu = 0;
            elseif isnumeric(varargin{1})   
               mu = varargin{1};
               groups = [];
            else
               mu = 0;
               groups = [];
            end   
         elseif nargin == 3
            groups = varargin{1};
            mu = varargin{2};
         end
         
         if numel(mu) > 1
            error('Argument "mu" should have one value!')
         end
         out = stat(obj, groups, @mdattest, {'Left tail', 'Both tails', 'Right tail'},...
            sprintf('P-values for t-test (mu = %s)', num2str(mu, 3)), mu);
      end
      
      function out = min(obj, varargin)
      % 'min' calculates minimal value for each column of dataset or for the 
      % first column, which values are split into groups.
      %
      %   mn = min(data);
      %   mn = min(data, factors);
      %
      %
      % By default, method calculates min value for each column of the
      % 'data' object. However if a dataset with factors is also provided the
      % method will calculate the value only for the first column of
      % 'data' by splitting its values into groups, corresponded to all
      % possible combination of the factors.
      %
      % Examples:
      % ---------
      %
      %   load people
      %
      %   % calculate minimum for each column
      %   mn = min(people);
      %   show(mn)
      %   
      %   % mark columns "Sex" and "Region" as a factors
      %   people.factor('Sex', {'Male', 'Female'})
      %   people.factor('Region', {'A', 'B'})
      %
      %   % calculate minimum for "Height" separately for each sex and region.
      %   mn = min(people(:, 'Height'), people(:, {'Sex', 'Region'}));
      %   show(mn)
      %
      
         if nargin == 1
            groups = [];
         else
            groups = varargin{1};
         end
      
         out = stat(obj, groups, @min, 'Min');
      end
      
      function out = max(obj, varargin)
      % 'max' calculates maximal value for each column of dataset or for the 
      % first colum, which values are split into groups.
      %
      %   mx = max(data);
      %   mx = max(data, factors);
      %
      %
      % By default, method calculates max value for each column of the
      % 'data' object. However if a dataset with factors is also provided the
      % method will calculate the value only for the first column of
      % 'data' by splitting its values into groups, corresponded to all
      % possible combination of the factors.
      %
      % Examples:
      % ---------
      %
      %   load people
      %
      %   % calculate maximum for each column
      %   mx = max(people);
      %   show(mx)
      %   
      %   % mark columns "Sex" and "Region" as a factors
      %   people.factor('Sex', {'Male', 'Female'})
      %   people.factor('Region', {'A', 'B'})
      %
      %   % calculate minimum for "Height" separately for each sex and region.
      %   mx = max(people(:, 'Height'), people(:, {'Sex', 'Region'}));
      %   show(mx)
      %
      
         if nargin == 1
            groups = [];
         else
            groups = varargin{1};
         end
      
         out = stat(obj, groups, @max, 'Max');
      end
                  
      function out = median(obj, varargin)
      % 'median' calculates median value for each column of dataset, or for the 
      % first column, which values are split into groups.
      %
      %   md = median(data);
      %   md = median(data, factors);
      %
      %
      % By default, method calculates median for each column of the
      % 'data' object. However if a dataset with factors is also provided the
      % method will calculate the value only for the first column of
      % 'data' by splitting its values into groups, corresponded to all
      % possible combination of the factors.
      %
      % Examples:
      % ---------
      %
      %   load people
      %
      %   % calculate median for each column
      %   md = median(people);
      %   show(md)
      %   
      %   % mark columns "Sex" and "Region" as a factors
      %   people.factor('Sex', {'Male', 'Female'})
      %   people.factor('Region', {'A', 'B'})
      %
      %   % calculate median for "Height" separately for each sex and region.
      %   md = median(people(:, 'Height'), people(:, {'Sex', 'Region'}));
      %   show(md)
      %
      
         if nargin == 1
            groups = [];
         else
            groups = varargin{1};
         end
      
         out = stat(obj, groups, @median, 'Median', 'Statistics');
      end
      
      function out = sum(obj, varargin)
      % 'sum' calculates the sum of values in each column of dataset or for the
      % first column, which values are split into groups.
      %
      %   s = sum(data);
      %   s = sum(data, factors);
      %
      %
      % By default, method calculates sum for each column of the
      % 'data' object. However if a dataset with factors is also provided the
      % method will calculate the value only for the first column of
      % 'data' by splitting its values into groups, corresponded to all
      % possible combination of the factors.
      %
      % Examples:
      % ---------
      %
      %   load people
      %
      %   % calculate sum for each column
      %   s = sum(people);
      %   show(s)
      %   
      %   % mark columns "Sex" and "Region" as a factors
      %   people.factor('Sex', {'Male', 'Female'})
      %   people.factor('Region', {'A', 'B'})
      %
      %   % calculate sum for "Height" separately for each sex and region.
      %   s = sum(people(:, 'Height'), people(:, {'Sex', 'Region'}));
      %   show(s)
      %
      
         if nargin == 1
            groups = [];
         else
            groups = varargin{1};
         end
      
         out = stat(obj, groups, @sum, 'Sum', 'Statistics');
      end
      
      function out = percentile(obj, varargin)
      % 'percentile' calculates n-th percentile for each column of dataset
      % or for the first column, which values are split into groups.
      % 
      %   p = percentile(data, n); 
      %   p = percentile(data, factors, n);
      %
      %
      % By default, method calculates percentile for each column of the
      % 'data' object. However if a dataset with factors is also provided the
      % method will calculate the interval only for the first column of
      % 'data' by splitting its values into groups, corresponded to all
      % possible combination of the factors.
      %
      % Examples:
      % ---------
      %
      %   load people
      %
      %   % calculate 25th percentile for each column
      %   p = percentile(people, 25);
      %   show(p)
      %   
      %   % mark columns "Sex" and "Region" as a factors
      %   people.factor('Sex', {'Male', 'Female'})
      %   people.factor('Region', {'A', 'B'})
      %
      %   % calculate 25th percentile for "Height" separately for each sex and region.
      %   p = percentile(people(:, 'Height'), people(:, {'Sex', 'Region'}), 25);
      %   show(p)
      %
      
         if nargin == 1
            error('Specify which percentile should be calculated!')
         elseif nargin == 2 
            if ~isnumeric(varargin{1}) 
               error('Specify which percentile should be calculated!')
            else   
               n = varargin{1};
               groups = [];
            end   
         elseif nargin == 3
            groups = varargin{1};
            n = varargin{2};
         end
         
         out = stat(obj, groups, @mdapercentile, sprintf('%d%%', n), 'Percentiles', n);
      end
      
      function out = summary(obj, varargin)
      % 'summary' calculates summary statistics for each column of dataset, or
      % for the first column, which values a split into groups.
      %
      %   s = summary(data);
      %   s = sum(data, factors);
      %
      %
      % The statistics include min, max, mean, median, first and third
      % quartiles.
      %
      % By default, method calculates statistics for each column of the
      % 'data' object. However if a dataset with factors is also provided the
      % method will calculate the values only for the first column of
      % 'data' by splitting its values into groups, corresponded to all
      % possible combination of the factors.
      %
      % Examples:
      % ---------
      %
      %   load people
      %
      %   % calculate summary for each column
      %   s = summary(people);
      %   show(s)
      %   
      %   % mark columns "Sex" and "Region" as a factors
      %   people.factor('Sex', {'Male', 'Female'})
      %   people.factor('Region', {'A', 'B'})
      %
      %   % calculate summary for "Height" separately for each sex and region.
      %   s = summary(people(:, 'Height'), people(:, {'Sex', 'Region'}));
      %   show(s)
      %
      
         if nargin == 1
            groups = [];
         else
            groups = varargin{1};
         end
               
         out = [min(obj, groups); percentile(obj, groups, 25); median(obj, groups);...
            mean(obj, groups); percentile(obj, groups, 75); max(obj, groups)];
         out.rowNames = {'Min', 'Q1', 'Median', 'Mean', 'Q3', 'Max'};
         
         if isempty(groups)
            out.name = 'Summary statistics' ;
         else   
            out.name = ['Summary statistics for ' obj.colNames{1}];
         end   
      end
            
      function out = stat(obj, groups, fun, rowNames, name, varargin)         
         if nargin < 5
            name = '';
         end

         if ~iscell(rowNames)
            rowNames = {rowNames};
         end   

         if isempty(groups)
            out = mdadata(fun(obj.numValues, varargin{:}), rowNames, obj.colFullNamesWithoutFactors, ...
               {'Statistics', obj.dimNames{2}}, name); 
         else
            groups = groups.getgroups();
            values = obj.numValues;
            out = [];
            for i = 1:groups.nCols
               out = [out fun(values(groups.values(:, i) == 1, 1), varargin{:})];
            end
            
            if isempty(name)
               name = [obj.colNamesWithoutFactors{1}];
            else
               name = [name ' for ' obj.colNamesWithoutFactors{1}];
            end
            
            out = mdadata(out, rowNames, groups.colNames, {'Statistics', groups.dimNames{2}}, name); 
            out.colFullNames = groups.colFullNames;
         end   
      end   
      
      function out = freq(obj, alpha)
      % 'freq' calculates observed frequency table for a factor
      %
      %   f = freq(data);
      %   f = freq(data, alpha);
      %
      %
      % The table includes observed frequency value for each level of the
      % factor, relative frequencies and confidence interval for the
      % relative frequencies (proportions). Argument 'alpha' is a
      % significance level for the confidence interval (default 0.05). If
      % data object has more than one column the calculations will be made
      % only for the first column.
      %
      % Examples:
      % ---------
      %
      %   load people
      %   people.factor('Sex', {'Male', 'Female'});
      %
      %   f = freq(people(1:20, 'Sex'));
      %   show(f)
      %
     
         if obj.nCols ~= 1
            error('The frequency table can be calculated for one factor at time!')
         end   
            
         if ~isfactor(obj, 1)
            error('The frequencies can be calculated only for factors!')
         end
         
         if nargin < 2
            alpha = 0.05;
         end
         
         levels = unique(obj(:, 1).values);
         n = obj.nRows;
         
         f = hist(obj(:, 1).values, levels);
         fr = f/n;
         mu = fr;
         sigma = sqrt((fr .* (1 - fr))/n);
         merr = mdatinv(1 - alpha/2, 10000) * sigma;
         
         out = mdadata([f; fr; mu - merr; mu + merr], {'Freq', 'RelFreq', 'Lower', 'Upper'}, ...
            obj.getfactorlevels(1), ['Statistics', obj(:, 1).colNames], 'Observed frequencies');
         out.rowFullNames = {'Freq', 'Rel. Freq', sprintf('Lower (%d%%)', round((1 - alpha)*100)),...
            sprintf('Upper (%d%%)', round((1 - alpha)*100))};
      end
      
      function out = crosstable(obj)
      % 'crosstable' calculates contingency table for combination of
      % two factors
      %
      %   t = crosstable(data);
      %
      %
      % Contingency table shows observed frequencies of every possible 
      % combination of two factor levels. If 'data' has more than two
      % columns, only first two will be taken.
      %
      % Examples:
      % ---------
      %
      %   load people
      %   people.factor('Sex', {'Male', 'Female'});
      %   people.factor('Region', {'A', 'B'});
      %
      %   t = crosstable(people(1:25, {'Sex', 'Region'}));
      %   show(t)
      %
      
         if (~isfactor(obj, 1) && isfactor(obj, 2))
            error('Contingency table can be calculated only for factors!')
         end
         
         [u1, ~, values1] = unique(obj.values(:, 1));
         [u2, ~, values2] = unique(obj.values(:, 2));
         
         if numel(u1) < 2 || numel(u2) < 2
            error('Factors should have at least two levels each!')
         end
         
         levels1 = obj.getfactorlevels(1);
         levels2 = obj.getfactorlevels(2);
         
         comb = allcomb(1:max(values1), 1:max(values2));
         nComb = size(comb, 1);
         f = zeros(nComb, 1);
         
         for i = 1:nComb
            f(i) = sum(values1 == comb(i, 1) & values2 == comb(i, 2));
         end
         
         f = reshape(f, max(values2), max(values1));
         f = [f sum(f, 2)];
         f = [f; sum(f, 1)];
         if size(levels2, 2) > size(levels2, 1)
            levels2 = levels2';
         end
         
         if size(levels1, 2) > size(levels1, 1)
            levels1 = levels1';
         end
         
         out = mdadata(f, [levels2; {'Sum'}], [levels1; {'Sum'}], {obj.colNames{2}, obj.colNames{1}}, ...
            sprintf('Contingency table (%s, %s)', obj.colNames{2}, obj.colNames{1}));
      end
      
      function out = obsfreq(obj)
      % 'obsfreq' calculates observed frequencies for two factors   
         [~, ~, values1] = unique(obj.values(:, 1));
         [~, ~, values2] = unique(obj.values(:, 2));
         
         comb = allcomb(1:max(values1), 1:max(values2));
         nComb = size(comb, 1);
         
         f = zeros(nComb, 1);
         
         for i = 1:nComb
            f(i) = sum(values1 == comb(i, 1) & values2 == comb(i, 2));
         end
         
         out = reshape(f, max(values2), max(values1));
      end
            
      function out = crossresid(obj)
      % 'crossresid' calculates standardized residuals for association of
      % two factors.
      %
      %   t = crossresid(data);
      %
      %
      % Standardized residuals shows an influence of one factor to distribution 
      % of proportions of the second factor.
      %
      % Examples:
      % ---------
      %
      %   load people
      %   people.factor('Sex', {'Male', 'Female'});
      %   people.factor('Region', {'A', 'B'});
      %
      %   r = crossresid(people(1:25, {'Sex', 'Region'}));
      %   show(r)
      %
      
         if (~isfactor(obj, 1) && isfactor(obj, 2))
            error('Residuals table can be calculated only for factors!')
         end
         
         levels1 = obj.getfactorlevels(1);
         levels2 = obj.getfactorlevels(2);
         
         of = obsfreq(obj);
         n = sum(of(:));

         ef = sum(of, 2) * (sum(of, 1) / n);
         
         nr = repmat(sum(of, 1), size(of, 1), 1);
         nc = repmat(sum(of, 2), 1, size(of, 2));
         d = (of - ef)./ sqrt(ef .* (1 - nr/n) .* (1 - nc/n));         
         
         out = mdadata(d, levels2, levels1, {obj.colNames{2}, obj.colNames{1}}, ...
            sprintf('Standardized residuals (%s, %s)', obj.colNames{2}, obj.colNames{1}));
      end
      
      function out = chi2test(obj)
      % 'chi2test' makes chi-square test for association 
      %
      %   res = chi2test(data);
      %
      %
      % The method makes the chi-square test for association between two 
      % qualitative variables (factors). It returns a table with chi-square 
      % statistic and the p-value for the test.
      %
      % Examples:
      % ---------
      %
      %   load people
      %   people.factor('Sex', {'Male', 'Female'});
      %   people.factor('Region', {'A', 'B'});
      %
      %   res = chi2test(people(1:25, {'Sex', 'Region'}));
      %   show(res)
      %
      
         if (~isfactor(obj, 1) && isfactor(obj, 2))
            error('Residuals table can be calculated only for factors!')
         end
         
         levels1 = obj.getfactorlevels(1);
         levels2 = obj.getfactorlevels(2);
         
         of = obsfreq(obj);
         n = sum(of(:));

         ef = sum(of, 2) * (sum(of, 1) / n);
         d2 = (of - ef).^2 ./ ef;
         chi2 = sum(d2(:));
         
         p = mdachi2cdf(chi2, (size(of, 1) - 1) * (size(of, 2) - 1));
         
         out = mdadata([p; chi2], {'p', 'chi2'}, {'Statistics'}, {}, ...
            sprintf('Chi2 test (%s, %s)', obj.colNames{1}, obj.colNames{2}));
      end
      
      %%% overrides for standard methods
      function ind = parserowind(obj, ind, full)
      % 'parseind' parses indices for rows and return parsed values
      %
      % It may work with a name, array of names or sequence of names, logical 
      % expressions as well as with numeric values.
      %
      % Inputs:
      % -------
      % 'obj' - object of mdadata class
      % 'ind' - indices specified by user, e.g. 1:5, [1, 3], 'Height:Weight', etc
      % 'full' - if true hidden columns and rows will be included
      %
         if nargin < 3
            full = false;
         end

         if full
            names = obj.rowNamesAll;
            n = obj.nRowsAll;
            values = obj.valuesAll;
         else   
            names = obj.rowNames;
            n = obj.nRows;
            values = obj.values;
         end
         
         colnames = obj.colNamesAll;
         ind = mdadata.parseind(ind, n, names, colnames, values);
         if isempty(ind)
            error('Wrong values for row indices!')
         end

      end
      
      function ind = parsecolind(obj, ind, full, withFactors)
      % 'parserowind' parses indices for columns return parsed values
      %
      % It may work with a name, array of names or sequence of names, logical 
      % expressions as well as with numeric values.
      %
      % Inputs:
      % -------
      % 'obj' - object of 'mdadata' class
      % 'ind' - indices specified by user, e.g. 1:5, [1, 3], 'Height:Weight', etc
      % 'full' - if true hidden columns and rows will be included
      % 'withFactors' - take or not factors into account
      %

         if nargin < 3
            full = false;
         end

         if nargin < 4
            withFactors = true;
         end

         if full
            if withFactors
               names = obj.colNamesAll;
               n = obj.nColsAll;
            else   
               names = obj.colNamesAllWithoutFactors;
               n = obj.nNumColsAll;
            end   
         else
            if withFactors
               names = obj.colNames;
               n = obj.nCols;
            else
               names = obj.colNamesWithoutFactors;
               n = obj.nNumCols;
            end   
         end

         ind = mdadata.parseind(ind, n, names);
         
         if isempty(ind)
            error('Wrong values for column indices!')
         end
         
      end 

      function out = end(obj, k, s)                  
         out = size(obj.values, k);
      end
      
      function out = length(obj)         
         out = length(obj.values);
      end         
            
      function varargout = size(obj, varargin)
         if nargout == 1
            varargout{1} = size(obj.values, varargin{:});
         elseif nargout == 2
            [nr, nc] = size(obj.values, varargin{:});   
            varargout{1} = nr;
            varargout{2} = nc;
         else
            error('Wrong number of output arguments!');
         end   
      end         
      
      function varargout = subsref(obj, s)
         switch s(1).type
            case '.'
               if nargout == 0
                  builtin('subsref', obj, s);
               else   
                  subsref = builtin('subsref', obj, s);
               end
            case '()'
               data = obj.subset(s(1).subs{:});
               
               if length(s) < 2
                  varargout{:} = data;
                  return
               else
                  subsref = builtin('subsref', data, s(2:end));
               end               
            case '{}'
               error('Not a supported subscripted reference')
         end
         
         if nargout > 0
            varargout{:} = subsref;
         end   
      end

      function obj = subsasgn(obj, s, b)
         if strcmp(s(1).type, '()')            
            row_ind = getfullrowind(obj, s(1).subs{1});
            col_ind = getfullcolind(obj, s(1).subs{2});            
         end
         
         if numel(s) > 1 && strcmp(s(2).type, '.')
            if strcmp(s(2).subs, 'values')
               % change data values   
               if size(b) ~= size(obj.valuesAll(row_ind, col_ind))
                  error('Subscripted assignment dimension mismatch!')
               elseif ~isnumeric(b)
                  error('Assigned values must be numeric!')
               else
                  obj.valuesAll(row_ind, col_ind) = b;
               end   
            elseif strcmp(s(2).subs, 'colNames')
               if ~iscell(b) && ischar(b)
                  b = {b};
               end   
               
               if numel(b) ~= numel(col_ind)
                  error('Subscripted assignment dimension mismatch!');
               elseif ~iscell(b) || ~ischar(b{1})    
                  error('Cell array with text values must be used as names!')
               end
               
               colNames = obj.colNamesAll;
               colFullNames = obj.colFullNamesAll;
               colNames(col_ind) = b;
               colFullNames(col_ind) = b;
               obj.colNamesAll = colNames;
               obj.colFullNamesAll = colFullNames;
            elseif strcmp(s(2).subs, 'colFullNames')
               if ~iscell(b) && ischar(b)
                  b = {b};
               end   
               
               if numel(b) ~= numel(col_ind)
                  error('Subscripted assignment dimension mismatch!');
               elseif ~iscell(b) || ~ischar(b{1})    
                  error('Cell array with text values must be used as names!')
               end
               
               colFullNames = obj.colFullNamesAll;
               colFullNames(col_ind) = b;
               obj.colFullNamesAll = colFullNames;
            elseif strcmp(s(2).subs, 'rowNames')
               if ~iscell(b) && ischar(b)
                  b = {b};
               end   
               
               if numel(b) ~= numel(row_ind)
                  error('Subscripted assignment dimension mismatch!');
               elseif ~iscell(b) || ~ischar(b{1})    
                  error('Cell array with text values must be used as names!')
               end
               
               rowNames = obj.rowNamesAll;
               rowFullNames = obj.rowFullNamesAll ;
               rowNames(row_ind) = b;
               rowFullNames(row_ind) = b;
               obj.rowNamesAll = rowNames;
               obj.rowFullNamesAll = rowFullNames;
            elseif strcmp(s(2).subs, 'rowFullNames')
               if ~iscell(b) && ischar(b)
                  b = {b};
               end   
               
               if numel(b) ~= numel(row_ind)
                  error('Subscripted assignment dimension mismatch!');
               elseif ~iscell(b) || ~ischar(b{1})    
                  error('Cell array with text values must be used as names!')
               end
               
               rowFullNames = obj.rowFullNamesAll;
               rowFullNames(row_ind) = b;
               obj.rowFullNamesAll = rowFullNames;               
            else
               error('You can not change this property directly!')
            end
         else
            if strcmp(s(1).subs, 'valuesAll') 
               if numel(s) > 1
                  % change part of the matrix
                  if numel(s(2).subs) ~= 2
                     error('Specify indices for rows and columns of the data object!')            
                  end
                  rowInd = s(2).subs{1};
                  colInd = s(2).subs{2};
                  if ~all(size(obj.valuesAll(rowInd, colInd)) == size(b))
                     error('Subscripted assignment dimension mismatch!')
                  else
                     obj.valuesAll(rowInd, colInd) = b;
                  end   
               else   
                  % change the whole matrix
                  if ~all(size(obj.valuesAll) == size(b))
                     error('Subscripted assignment dimension mismatch!')
                  else
                     obj.valuesAll = b;
                  end   
               end   
            else   
               obj = builtin('subsasgn', obj, s, b);
            end   
         end
      end

      function varargout = subset(obj, varargin)
      % 'subset' returns a subset of the data set
      %

         % set default settings
         if nargin == 1
         % no indices   
            col_ind = ':';
            row_ind = ':';
         elseif nargin == 2
         % only one index   
            if obj.nRows == 1
               row_ind = 1;
               col_ind = varargin{1};
            elseif obj.nCols == 1
               col_ind = 1;
               row_ind = varargin{1};
            else
               error('Wrong indices for rows and columns!')
            end   
         else
            row_ind = varargin{1};
            col_ind = varargin{2};
         end
         
         if ischar(row_ind) && strcmp(row_ind, ':')
            % subset with all rows - with excluded rows   
            col_ind = getfullcolind(obj, col_ind);            
            row_ind = 1:obj.nRowsAll;            
            values = obj.valuesAll;
            
            svalues = values(:, col_ind);
            scolNames = obj.colNamesAll(col_ind);
            scolFullNames = obj.colFullNamesAll(col_ind);
            srowNames = obj.rowNamesAll;
            srowFullNames = obj.rowFullNamesAll;
            sexcludedRows = find(obj.excludedRows);
            sexcludedCols = [];
            sselectedRows = obj.selectedRows;
            sselectedCols = [];
            
         elseif ischar(col_ind) && strcmp(col_ind, ':')
            % subset with all cols - with excluded cols  
            col_ind = 1:obj.nColsAll;            
            row_ind = getfullrowind(obj, row_ind);            
            values = obj.valuesAll;
            
            svalues = values(row_ind, :);
            scolNames = obj.colNamesAll;
            scolFullNames = obj.colFullNamesAll;
            sexcludedCols = find(obj.excludedCols);
            sexcludedRows = [];
            
            sselectedRows = [];
            sselectedCols = obj.selectedCols;
            
            if ~isempty(obj.rowNamesAll)
               srowNames = obj.rowNamesAll(row_ind);
            else
               srowNames = {};
            end
            
            if ~isempty(obj.rowFullNamesAll)
               srowFullNames = obj.rowFullNamesAll(row_ind);
            else
               srowFullNames = {};
            end               
         else
            % partial subset for both rows and cols - no excluded data    
            values = obj.valuesAll;
            col_ind = getfullcolind(obj, col_ind);   
            row_ind = getfullrowind(obj, row_ind);            
            
            svalues = values(row_ind, col_ind);
            scolNames = obj.colNamesAll(col_ind);
            scolFullNames = obj.colFullNamesAll(col_ind);
            sexcludedRows = [];
            sexcludedCols = [];
            sselectedRows = [];
            sselectedCols = [];
            
            if ~isempty(obj.rowNamesAll)
               srowNames = obj.rowNamesAll(row_ind);
            else
               srowNames = {};
            end
            
            if ~isempty(obj.rowFullNamesAll)
               srowFullNames = obj.rowFullNamesAll(row_ind);
            else
               srowFullNames = {};
            end                           
         end
         
         data = mdadata(svalues, srowNames, scolNames, obj.dimNames, obj.name);
         data.info = obj.info;
         data.colFullNames = scolFullNames;
         data.rowFullNames = srowFullNames;
         objFactorCols = col_ind(ismember(col_ind, find(obj.factorCols)));
         dataFactorCols = find(obj.factorCols(col_ind));
                  
         for i = 1:numel(dataFactorCols)
            objLevels = unique(values(:, objFactorCols(i)));
            dataLevels = unique(svalues(:, dataFactorCols(i)));
            
            levels = obj.factorLevelNames{objFactorCols(i)}(ismember(objLevels, dataLevels));
            
            data.factorCols(dataFactorCols(i)) = true;            
            data.factorLevelNames{dataFactorCols(i)} = levels';
         end
         
         data.excludecols(sexcludedCols);
         data.excluderows(sexcludedRows);

         data.showExcludedRows = obj.showExcludedRows;
         data.showExcludedCols = obj.showExcludedCols;
         data.selectedRows = sselectedRows;
         data.selectedCols = sselectedCols;
         
         varargout{1} = data;
      end   
      
      %%% conventional plots
      
      function varargout = scatter(obj, varargin)
      % 'scatter' makes a scatter plot for 'mdadata' class object
      %
      %   scatter(data);
      %   scatter(data(:, [1 5]));
      %   scatter(data, 'ParamName', ParamValue, ...);
      %
      %
      % The method uses the standard 'plot()' function (instead of 'scatter()' which is 
      % slow with large datasets) and give some extra functionality, such 
      % as automatic labels for data points, grouping data with color, etc. If output 
      % variable is specified it returns a structure with plot elements (plot handle, 
      % labels handle, etc).
      % 
      % The mandatory argument is a dataset (object of class 'mdadata') with at 
      % least one column. If more than two columns exist, the method will make a plot 
      % only for the first two. 
      %
      %
      % Parameters:
      % ------------
      % All parameters for Matlab's 'plot()' function (e.g. "Marker", "MarkerSize", etc.)
      % can be used. Additional parameters are:
      %
      %  "Colorby" - make color grouping of points by a vector of values. The
      %  parameter can be a numeric vector with the same number of values as
      %  number of rows in the data object. 
      %  
      %  "Colormap" - a function for generating colormap for the color grouping.
      %  By default uses a built in colormap based on colorbrewer2.org. Possible
      %  values are: '@jet', '@gray', and so on.
      %  
      %  "Colorbar" - show or not a colorbar (legend for color groups). Possible
      %  values are 'on' and 'off'. By default colorbar is shown if "Colorby" 
      %  parameter is specified.
      %  
      %  "ColorbarTitle" - a text string with title to be shown on top of
      %  colorbar.
      %  
      %  "Labels" - show or not labels for the data points. Possible
      %  values are "none" (default), "names" for name of objects and "numbers"
      %  for their numbers. 
      %  
      %
      % Examples:
      % ---------
      %   
      %   load people
      %
      %   % make plot and change standard properties, add labels
      %   
      %   figure
      %   subplot(1, 3, 1)
      %   scatter(people(:, 1:2));
      %   subplot(1, 3, 2)
      %   scatter(people(:, 1:2), 'MarkerFaceColor', 'b', 'Marker', 's');
      %   subplot(1, 3, 3)
      %   scatter(people(:, 1:2), 'Labels', 'on');
      %   
      %   % using color grouping
      %   
      %   cg = people(:, 'Beer');
      %   
      %   figure
      %   scatter(people(:, 1:2), 'Colorby', cg);
      %   scatter(people(:, 1:2), 'Colorby', cg, 'Colormap', @gray);
      %   scatter(people(:, 1:2), 'Colorby', cg, 'Colorbar', 'on');
      %   scatter(people(:, 1:2), 'Colorby', cg, 'Colorbar', 'on', 'ColorbarTitle', 'Beer');
      %
      %   % make plot for dataset with more than two columns
      %
      %   figure
      %   scatter(people, 'Labels', 'names');
      %
      %
         % check if values for color grouping are provided
         [cmap, cgroup, varargin, isColorbar, colorbarTitle] = mdadata.getplotcolorsettings(varargin{:});
         if ~isempty(cgroup) && numel(cgroup) ~= obj.nRows
            error('Number of elements in color grouping variable should be the same as number of objects!');
         end   
         % check if reducing is turned off
         [v, varargin] = getarg(varargin, 'Reduce');         
         if ~isempty(v) || strcmp(v, 'off')
            doReduce = false;
         else
            doReduce = true;
         end   

         % show hidden rows or not?
         [v, varargin] = getarg(varargin, 'ShowExcluded');
         
         if ~isempty(v) 
            if strcmp(v, 'on') 
               showExcluded = true;
            else
               showExcluded = false;
            end            
         else
            showExcluded = obj.showExcludedRows;
         end
         
         % show labels or not?
         rowNames = [];
         [showLabels, varargin] = getarg(varargin, 'Labels');   
         if ~isempty(showLabels) && ~strcmp(showLabels, 'none')
            if isempty(obj.rowFullNames) || strcmp(showLabels, 'numbers')
               if showExcluded
                  names = textgen('', 1:obj.nRowsAll);
                  rowNames = names(~obj.excludedRows);
                  rowNamesHidden = names(obj.excludedRows);
               else   
                  rowNames = textgen('', 1:obj.nRows);
                  rowNamesHidden = [];
               end   
            elseif strcmp(showLabels, 'names')
               rowNames = obj.rowFullNames;
               if showExcluded
                  rowNamesHidden = obj.rowFullNamesAll(obj.excludedRows);
               else
                  rowNamesHidden = [];
               end   
            end   
         end   
         
         % marker symbol
         mr = getarg(varargin, 'Marker');
         if isempty(mr)
            mr = 'o';
         end
         
         % marker colors
         mc = getarg(varargin, 'Color');
         if isempty(mc)
            mc = mdadata.getmycolors(1);
         end   
         
         mfc = getarg(varargin, 'MarkerFaceColor');
         if isempty(mfc)
            mfc = mc;
         end   
         
         mec = getarg(varargin, 'MarkerEdgeColor');
         if isempty(mec)
            mec = 'none';
         end   

         % set default marker size
         ms = getarg(varargin, 'MarkerSize');
         if isempty(ms)
            if strcmp(mr, '.')
               ms = 16;
            else   
               ms = 8;
            end   
         end
         
         [v, varargin] = getarg(varargin, 'Density');
         if ~isempty(v) && strcmp(v, 'on') 
            hasDensity = true;
         else
            hasDensity = false;
         end   
         
         if obj.nNumCols == 1
            x = (1:obj.nRows)';
            y = obj.numValues(:, 1);
            colNames = [obj.dimNames{1} obj.colFullNamesWithoutFactors(1)];
         else   
            values = obj.numValues(:, 1:2);
            x = values(:, 1);
            y = values(:, 2);
            colNames = obj.colFullNamesWithoutFactors(1:2);
         end
         
         if doReduce && numel(x) > obj.REDUCE_ROWS_LIMIT
            if hasDensity && ~isempty(cgroup)
               % it is call from densscatter, density already provided
               dens = mdadata.quantizedens(cgroup);
            else   
               % calculate and rescale density of scores
               dens = mdadata.getsampledensity(x, y, 100, 'Quantize', 'on');
            end
               
            % reduce number of rows according to the density
            ind = mdadata.reducerows(dens, 4);
               
            x = x(ind);
            y = y(ind);
            if ~isempty(cgroup)
               cgroup = cgroup(ind);
            end   
         end   
         
         if ~ishold
            cla;
         end
                  
         % show plot - we use PLOT() instead of SCATTER() for speed      
         if isempty(cgroup) || numel(unique(cgroup)) == 1
            hp = plot(double(x), double(y), 'Color', mc, 'Marker', mr, 'MarkerFaceColor', mfc, ...
               'MarkerEdgeColor', mec, 'MarkerSize', ms, 'LineStyle', 'none');              
         else
            ind = fix((cgroup - min(cgroup)) / (max(cgroup) - min(cgroup)) * (size(cmap, 1) - 1)) + 1;                  
            hp = zeros(size(cmap, 1), 1);
            hold on
            for k = 1:size(cmap, 1)
               if any(ind == k)
                  hp(k) = plot(x(ind == k),y(ind == k), ...
                     'Marker', mr, ...
                     'MarkerSize', ms,...
                     'Color', cmap(k,:), ...
                     'MarkerEdgeColor', mec,...
                     'MarkerFaceColor', cmap(k,:), ...
                     'LineStyle', 'none',...
                     varargin{:});
                end
            end
            hold off
         end
         
         h.plot = hp;
         if showExcluded
            values = obj.valuesHidden;
            if size(values, 1) > 0            
               if obj.nCols == 1
                  xh = 1:size(values, 1);
                  yh = values(:, 1);
               else   
                  xh = values(:, 1);
                  yh = values(:, 2);
               end

               if doReduce && numel(xh) > obj.REDUCE_ROWS_LIMIT
                  % calculate and rescale density of scores
                  dens = mdadata.getsampledensity(xh, yh, 100, 'Quantize', 'on');

                  % reduce number of rows according to the density
                  ind = mdadata.reducerows(dens, 4);
                  xh = xh(ind);
                  yh = yh(ind);               
               end   
               
               flag = true;
               if ishold
                  flag = false;
               end
               
               if flag
                  hold on
               end   
               
               mc = obj.EXCLUDED_COLOR;
               hh = plot(xh, yh, 'Color', mc, 'Marker', mr, ...
                  'MarkerFaceColor', mc, ...
                  'MarkerEdgeColor', mec, 'MarkerSize', ms,...
                  'LineStyle', 'none');         

               set(hh, 'Color', [1 1 0])
               h.plotHidden = hh;
               
               if flag
                  hold off
               end   
            else
               showExcluded = false;
            end   
         end
               
         % show axis labels, title and box
         xlabel(colNames{1})         
         ylabel(colNames{2})         
         title(obj.name)
         box on

         % correct axis limits
         if ~ishold
            axis tight
            correctaxislim(10)
         end
               
         % show colorbar
         if isColorbar
            xc = xlim(); dx = (xc(2) - xc(1));
            yc = ylim(); dy = (yc(2) - yc(1))/2;
            h.colorbar = mdadata.showcolorbar(cmap, cgroup, colorbarTitle, dx, dy);
         end   

         % show labels
         if numel(rowNames) == numel(x)
            h.labels = mdadata.showlabels(x, y, rowNames);
                  
            if showExcluded && numel(rowNamesHidden) == numel(xh)
               h.labelsHidden = mdadata.showlabels(xh, yh, rowNamesHidden);
            end
         end
               
         
         if nargout > 0
            varargout{1} = h;
         end   

      end
      
      function varargout = densscatter(obj, varargin)
      % 'densscatter' makes a density scatter plot for 'mdadata' object.
      %
      % Density scatter plot looks like a normal scatter plot where data points
      % are colored by their density - how many other data points are around.
      %
      % Parameters:
      % -----------
      % The syntax and parameters are similar to 'mdadata.scatter' The
      % additional parameters are:
      %  
      %  "NBins" - number of sections to split every axis of the plotting 
      %  area into. E.g. if it is 100, the XY plane will be split to 100x100
      %  sections and density of each section will be calculated.
      %  
      %  "Colormap" - which colormap to use for color separation. By default
      %  a built in palette based on colorbrewer 2 colors is used. Any
      %  Matlab colormap can be used ('@jet', '@spring', etc).
      %
      %
      % Examples:
      % ---------
      % 
      %   d = mdadata(randn(10000, 2));
      %
      %   figure
      %   subplot(1, 2, 1)
      %   densscatter(d)
      %   subplot(1, 2, 2)
      %   densscatter(d, 'NBins', 20, 'Colormap', @parula)
      %
      %
      
         % check if values for colorbar are provided
         [isColorbar, varargin] = getarg(varargin, 'Colorbar');
         if ~(isempty(isColorbar) && strcmp(isColorbar, 'on'))
            varargin = [varargin, {'Colorbar', 'off'}];
         end
         
         [nbins, varargin] = getarg(varargin, 'NBins');
         if isempty(nbins)
            nbins = 80;
         end   
         
         [mec, varargin] = getarg(varargin, 'MarkerEdgeColor');
         if isempty(mec)
            mec = 'none';
         end
         
         if size(obj.numValues, 2) ~= 2
            error('Specify for which two columns you want to make the plot for!')
         end

         values = obj.numValues;
         x = values(:, 1);
         y = values(:, 2);

         d = mdadata.getsampledensity(x, y, nbins);
        
         % remove Color argument if provided
         [~, varargin] = getarg(varargin, 'Color');

         varargin = [varargin {'Colorby', d, 'MarkerEdgeColor', mec, 'Density', 'on'}];
         h = obj.scatter(varargin{:});

         if nargout
            varargout{1} = h;
         end
      end

      function varargout = plot(obj, varargin)
      % 'plot' makes a scatter plot for 'mdadata' class object
      %
      %   plot(data);
      %   plot(data, 'ParamName', ParamValue, ...);
      %   plot(data, x);
      %   plot(data, x, 'ParamName', ParamValue, ...);
      %
      %
      % The method is based on the standard 'plot()' function and give some extra 
      % functionality, such as automatic labels for axis, grouping plot lines 
      % with color, etc. If output variable is specified the method returns a structure or 
      % a cell array with plot elements handles (plot handle, labels handle, etc).
      % 
      % The only mandatory argument is a dataset (object of class 'mdadata').
      % The optional second argument ('x') is a vector of values for the x
      % axis. If it is not provided, a sequence 1:N, where N is number of
      % columns in the dataset, will be used. The ticks for x axis in this case
      % will be generated based on column names. The method assumes that every
      % column of the data is a variable and every row is an observation.
      %
      % Parameters:
      % ------------
      % All parameters for Matlab's 'plot()' function (e.g. "Color", "LineStyle", etc.)
      % can be used. Additional parameters are:
      %
      %  "Colorby" - make color grouping of points by a vector of values. The
      %  parameter can be a numeric vector with the same number of values as
      %  number of rows in the data object. 
      %
      %  "Colormap" - a function for generating colormap for the color grouping.
      %  By default uses a built in colormap based on colorbrewer2.org. Possible
      %  values are: '@jet', '@gray', and so on.
      %
      %  "Colorbar" - show or not a colorbar (legend for color groups). Possible
      %  values are "on" and "off". By default colorbar is not shown.
      %
      %  "ColorbarTitle" - a text string with title to be shown on top of
      %  colorbar.
      %
      %  "Reduce" - if data has many rows (more than 2000) this number will
      %  be reduced to speed up the plot by removing rows which are similar. 
      %  The reducing algorithm is based on PCA (Principal Component
      %  Analysis) and density of the rows on scores plot for first two 
      %  components. Set this parameter to "off" to avoid reducing. 
      %  
      %
      % Examples:
      % ---------
      %   
      %   load simdata
      %   
      %   % make plot of UV/Vis spectra and change standard properties
      %   figure
      %   plot(spectra, 'Color', 'b', 'LineStyle', '--');
      %   
      %   % use manual x values
      %   x = 1:spectra.nCols;
      %   figure
      %   plot(spectra, x);
      %   xlabel('Wavenumbers');
      %
      %   % using color grouping (concentration values)
      %   figure
      %   subplot(3, 1, 1)
      %   plot(spectra, 'Colorby', conc(:, 1));
      %   subplot(3, 1, 2)
      %   plot(spectra, 'Colorby', conc(:, 1), 'Colormap', @summer);
      %   subplot(3, 1, 3)
      %   plot(spectra, 'Colorby', conc(:, 1), 'Colorbar', 'on');
      %
      %

         % check if reducing is turned off
         [v, varargin] = getarg(varargin, 'Reduce');         
         if ~isempty(v) || strcmp(v, 'off')
            doReduce = false;
         else
            doReduce = true;
         end   
         
         % set default marker size
         mr = getarg(varargin, 'Marker');
         if ~isempty(mr)
            [ms, varargin] = getarg(varargin, 'MarkerSize');
            if isempty(ms)
               if strcmp(mr, '.')
                  ms = 16;
               else   
                  ms = 8;
               end
               varargin = [varargin, 'MarkerSize', ms];
            end   
         end
         
         % check if excluded variables will be shown
         [v, varargin] = getarg(varargin, 'ShowExcluded');         
         if ~isempty(v) 
            if strcmp(v, 'on') 
               showExcluded = true;
            else
               showExcluded = false;
            end            
         else
            showExcluded = obj.showExcludedCols;
         end
         
         % get values and various parameters
         % the serIncl/serExcl is a matrix with start
         % and end indices of series in variables         
         if showExcluded
            % show excluded columns but keep excluded rows hidden
            values = obj.valuesAll(~obj.excludedRows, ~obj.factorCols);
            nCols = size(values, 2);
            indExcl = find(obj.excludedCols(~obj.factorCols));
            indIncl = find(~obj.excludedCols(~obj.factorCols));
            serExcl = getserind(indExcl);
            serIncl = getserind(indIncl);
         else
            values = obj.numValues;
            nCols = size(values, 2);
            indIncl = 1:nCols;
            serIncl = getserind(indIncl);
         end
         
         % check if x values are provided and set up x and xtick values
         if numel(varargin) > 0 && isnumeric(varargin{1})
            x = varargin{1};
            varargin(1) = [];
            
            if numel(x) ~= nCols
               error('Number of x values should be the same as number of columns in dataset!');
            end
            xticklabel = [];
         else   
            x = 1:nCols;
            
            if showExcluded
               xticklabel = obj.colFullNamesAllWithoutFactors;
            else   
               xticklabel = obj.colFullNamesWithoutFactors;
            end   
         end
         
         if numel(x) < 12
            xtick = x;
         else
            xtick = unique(round(linspace(1, numel(x), 12)));
         end
         
         % check if values for color grouping are provided
         [cmap, cgroup, varargin, isColorbar, colorbarTitle] = mdadata.getplotcolorsettings(varargin{:});
         if ~isempty(cgroup) && numel(cgroup) ~= obj.nRows
            error('Number of elements in color grouping variable should be the same as number of objects!');
         end   
          
         if doReduce && size(values, 1) > obj.REDUCE_ROWS_LIMIT
            % make pca of the values and get scores for two components
            dd = bsxfun(@minus, values, mean(values));
            [~, ~, v] = svd(dd, 0);
            s = dd * v(:, 1:2);

            % calculate and rescale density of scores
            dens = mdadata.getsampledensity(s(:, 1), s(:, 2), 100, 'Quantize', 'on');

            % reduce number of rows according to the density
            ind = mdadata.reducerows(dens);
            values = values(ind, :);
            if ~isempty(cgroup)
               cgroup = cgroup(ind);
            end   
            clear('v', 's', 'ind');
         end   
         
         if ~ishold
            cla;
         end
         if isempty(cgroup)
            hold on
            for i = 1:size(serIncl, 1);
               indC = indIncl(serIncl(i, 1):serIncl(i, 2));
               if indC(1) > 1
                  indC = [indC(1) - 1; indC];
               end
               if indC(end) < nCols
                  indC = [indC; indC(end) + 1];
               end   
               hp = plot(x(indC), values(:, indC)', varargin{:});
            end   
            hold off
         else
            indR = fix((cgroup - min(cgroup)) / (max(cgroup) - min(cgroup)) * (size(cmap, 1) - 1)) + 1;
            hp = cell(size(cmap, 1), 1);
            hold on
            for k = 1:size(cmap, 1)
               if any(indR == k)
                  hh = [];
                  for i = 1:size(serIncl, 1);
                     indC = indIncl(serIncl(i, 1):serIncl(i, 2));
                     if indC(1) > 1
                        indC = [indC(1) - 1; indC];
                     end
                     if indC(end) < nCols
                        indC = [indC; indC(end) + 1];
                     end   
                     hl = plot(x(indC), values(indR == k, indC)', 'Color', cmap(k,:), varargin{:});
                     hh = [hh; hl];
                  end   
                  hp{k} = hh;
               end
            end
            hold off
         end
         h.plot = hp;
         
         if showExcluded && any(obj.excludedCols)
            lc = obj.EXCLUDED_COLOR;
            [~, varargin] = getarg(varargin, 'Color');
            [~, varargin] = getarg(varargin, 'Marker');
            [~, varargin] = getarg(varargin, 'MarkerSize');
            
            flag = true;
            if ishold
               flag = false;
            end
            
            if flag
               hold on
            end
            
            for i = 1:size(serExcl, 1);
               indC = indExcl(serExcl(i, 1):serExcl(i, 2));
               hp = plot(x(indC), values(:, indC)', 'Color', lc, 'Marker', '.', ...
                  'MarkerSize', 8, varargin{:});
            end
            
            if flag
               hold off
            end   
         end
         h.plotHidden = hp;
         
         % correct axis limits
         if strcmp(get(gca, 'NextPlot'), 'replace')
            correctaxislim([5, 5, 0, 5], [min(x) max(x)]);
         end
         
         % show colorbar
         if isColorbar
            l = axis();
            dx = (l(2) - l(1));
            dy = (l(4) - l(3))/2;
            h.colorbar = mdadata.showcolorbar(cmap, cgroup, colorbarTitle, dx, dy);
         end

         if ~isempty(xticklabel)
            set(gca, 'XTick', xtick, 'XTickLabel', xticklabel(xtick));
         end
         
         if ~isempty(obj.dimNames) && numel(obj.dimNames) == 2
            xlabel(obj.dimNames{2})         
         end
         
         ylabel('')    
         title(obj.name)
         box on

         if nargout > 0
            varargout{1} = h;
         end            
      end

      function varargout = bar(obj, varargin)
      % 'bar' makes a bar plot for 'mdadata' object.
      %
      %   bar(data);
      %   bar(data, 'ParamName', ParamValue, ...);
      %   bar(data, x);
      %   bar(data, x, 'ParamName', ParamValue, ...);
      %
      %
      % The method makes a bar plot for a particular row of a dataset. If
      % dataset provided as an argument has more than one row the plot will 
      % be shown for the first row.
      %
      % The optional second argument ('x') is a vector of values for the x
      % axis. If it is not provided, a sequence 1:N, where N is number of
      % columns in the dataset, will be used. The ticks for x axis in this case
      % will be generated based on column names. The method assumes that every
      % column of the data is a variable and every row is an observation.
      %
      % Parameters:
      % -----------
      % All parameters for Matlab's 'bar()' function will work. Extra parameters are shown below.
      %
      %  "Labels" - show or not labels for the data points. Possible
      %  values are "none" (default), "names" for name of objects, "numbers"
      %  for their numbers and "values" for the data values (height of bars). 
      %
      %  "LabelsSigfig" - how many significant figures to use for the label values.
      %
      %
      % Examples:
      % ---------
      % 
      %   expvar = mdadata([40.1 20 5 4; 35.2 18 4 3], {'Cal', 'Test'}, 1:4);
      %   expvar.dimNames = {'Results', 'Components'};
      %   expvar.name = 'Explained variance';
      %   
      %   % show bar plot for second row and change bar colors
      %   figure
      %   bar(expvar('Test', :), 'FaceColor', 'r');
      %
      %   % show labels on top of the bars
      %   figure
      %   bar(expvar, 'Labels', 'on');
      %
      %
      
         [v, varargin] = getarg(varargin, 'ShowExcluded');
         if isempty(v) || ~strcmp(v, 'on')
            showExcluded = false;
         else
            showExcluded = true;
         end
               
         % check if x values are provided and set up x and xtick values
         if numel(varargin) > 0 && isnumeric(varargin{1})
            if showExcluded
               error('You can not use manual x values with "ShowExcluded" parameter!');
            end   
            x = varargin{1};
            varargin(1) = [];
         else
            x = [];
         end
         
         if isempty(find(strcmp(varargin, 'FaceColor'), 1))
            c = mdadata.getmycolors(1);
            varargin = [varargin, 'FaceColor', c(1, :)];
         end   

         if isempty(find(strcmp(varargin, 'EdgeColor'), 1))
            varargin = [varargin 'EdgeColor', 'n'];
         end
         
         bw = getarg(varargin, 'BarWidth');
         if isempty(bw)
            varargin = [varargin 'BarWidth', 0.75];
         else
            varargin = [varargin 'BarWidth', bw];            
         end   

         [showLabels, varargin] = getarg(varargin, 'Labels');
         if isempty(showLabels)
            showLabels = 'none';
         end
         
         [sigfig, varargin] = getarg(varargin, 'LabelsSigfig');
         if isempty(sigfig) || ~isnumeric(sigfig) || sigfig < 1 || sigfig > 10
            sigfig = 3;
         end
                
         
         if showExcluded
            values = obj.valuesAll(:, ~obj.factorCols);
            nCols = size(values, 2);
            xticklabels = obj.colNamesAll(~obj.factorCols);
         else
            values = obj.numValues;
            xticklabels = obj.colNamesWithoutFactors;
            nCols = size(values, 2);
         end


         if isempty(x)            
            x = 1:nCols;
         end   

         if strcmp(showLabels, 'names')
            labels = xticklabels;               
         elseif strcmp(showLabels, 'numbers')
            labels = num2str(x');               
         else
            labels = [];
         end   
         
         if numel(x) < 12
            xtick = 1:numel(x);
         else
            xtick = unique(round(linspace(1, numel(x), 12)));
         end
         
         if ~ishold
            cla;
         end

         y = values(1, :);     
         h = bar(double(x), double(y), 0.95, varargin{:}); 
            
         if showExcluded
            ind = obj.excludedCols(~obj.factorCols);
            [~, varargin] = getarg(varargin, 'FaceColor');
            hold on
            h(2) = bar(x(ind), y(ind), 0.95, 'FaceColor', obj.EXCLUDED_COLOR, varargin{:});                
            hold off
         end
            
         xlabel(obj.dimNames{2})            
         ylabel('')         
            
         if ~isempty(obj.rowNames)
            if ~isempty(obj.name) 
               title([obj.name ' (' obj.rowNames{1} ')'])
            else
               title(obj.rowNames{1})
            end
         end
            
         box on
         set(gca, 'XTick', x(xtick), 'XTickLabel', xticklabels(xtick));

         dx = x(2) - x(1);
         xlim = [min(x) - dx/2 max(x) + dx/2];
         
         if ~strcmp(showLabels, 'none')
            if isempty(labels)
               labels = cellstr(num2str(y', sigfig));
            end
            
            indtop = y >= 0;
            mdadata.showlabels(x(indtop), y(indtop), labels(indtop), 'top');
            mdadata.showlabels(x(~indtop), y(~indtop), labels(~indtop), 'bottom');
            
            if strcmp(get(gca, 'NextPlot'), 'replace')
               correctaxislim([3 3 0 10], xlim);
            end
         else   
            if strcmp(get(gca, 'NextPlot'), 'replace')
               correctaxislim([3 3 0 5], xlim);
            end
         end            

         if nargout > 0
            varargout{1} = h;
         end   

      end   
      
      function varargout = levelplot(obj, varargin)
      % 'levelplot' makes a level plot for dataset values.
      %
      %   levelplot(data);
      %
      %
      % The method visualises a matrix of values from the dataset as a set of
      % rectangles (levels), oriented the same way as values in the matrix. 
      % Color of each rectangle corresponds to the value. This can be particularly
      % useful for comparison of the same factors obtained at different
      % conditions or for different groups (e.g. average values for males and
      % females) or pairwise comparison (e.g. covariance or correlation
      % matrices).
      %
      % Examples:
      % ---------
      %
      %   load people
      %   
      %   figure
      %   levelplot(corr(people(:, 1:6)))
      %
      %   figure
      %   levelplot(corr(people(:, 1:6)))
      %   colormap('winter')
      %   colorbar
      %
      
         if ~ishold
            cla;
         end
      
         h = imagesc(obj.numValues);
         set(gca, 'XTick', 1:obj.nNumCols, 'XTickLabel', obj.colNamesWithoutFactors);
         
         if ~isempty(obj.rowNames)
            set(gca, 'YTick', 1:obj.nRows, 'YTickLabel', obj.rowNames);
         end
         
         [cmap, ~] = getarg(varargin, 'Colormap');
         if ~isempty(cmap)
            colormap(cmap(64))
         else   
            colormap(mdadata.getmycolors())
         end
         
         title(obj.name);
         
         if ~isempty(obj.dimNames) && numel(obj.dimNames) == 2
            xlabel(obj.dimNames{2})
            ylabel(obj.dimNames{1})
         end
         
         if nargout > 0
            varargout{1} = h;
         end   
         
      end

      function varargout = matrixplot(obj, varargin)
      % 'matrixplot' makes a 3D plot for dataset values.
      %
      %   matrixplot(data);
      %
      %
      % The method shows a matrix of values from the dataset as a 3D surface 
      % with color identication of the surfacce levels.
      %
      % Examples:
      % ---------
      %
      %   load people
      %   
      %   figure
      %   matrixplot(people(1:8, {'Height', 'Weight', 'Beer', 'Wine'}))
      %
      %

         if ~ishold
            cla;
         end
            
         h = mesh(obj.numValues);
         set(gca, 'XTick', 1:obj.nNumCols, 'XTickLabel', obj.colNamesWithoutFactors);
         if ~isempty(obj.rowNames)
            set(gca, 'YTick', 1:obj.nRows, 'YTickLabel', obj.rowNames);
         end
         [cmap, ~] = getarg(varargin, 'Colormap');
         if ~isempty(cmap)
            colormap(cmap(64))
         else   
            colormap(mdadata.getmycolors())
         end
         
         view(45, 45)
         title(obj.name);
         
         if ~isempty(obj.dimNames) && numel(obj.dimNames) == 2
            xlabel(obj.dimNames{2})
            ylabel(obj.dimNames{1})
         end
         
         if nargout > 0
            varargout{1} = h;
         end   
         
      end
      
      %%% group plots
      
      function varargout = gbar(obj, varargin)
      % 'gbar' makes a group bar plot 
      %
      %   gbar(data)
      %   gbar(data, 'ParamName', ParamValue, ...)
      %
      %
      % The method makes a bar plot for two or more data rows considered as 
      % groups. By default, each group has its own color. 
      %
      % Parameters:
      % -----------
      %  "Labels" - show or not labels for the bars. Possible
      %  values are "none" (default), "names" for name of objects, "numbers"
      %  for their numbers and "values" for the bar values (height). This 
      %  option does not work with HG2 graphics engine (Matlab 2014b), the 
      %  solution is coming in next release.
      %  
      %  "LabelsSigfig" - how many significant figures to use for the label values.
      %
      %  "Legend" - shor or nor legend for the groups. Possible values are
      %  "on" (default) and "off".
      %
      %  "LegendLocation" - if legend is on, defines location for the legend. 
      %  The values are similar to what are used in 'legend()' function.
      %
      %  "EdgeColor" - one value or a vector with values (one for each group) 
      %  for the bar edge color. If color is specified using RGB values, the
      %  parameter should be a matrix with as many rows as many groups
      %  exist.
      %
      %  "FaceColor" - one value or a vector with values (one for each group) 
      %  for the bar face color. If color is specified using RGB values, the
      %  parameter should be a matrix with as many rows as many groups
      %  exist.
      %
      %
      % Examples:
      % ---------
      %     
      %   % prepare a dataset
      %   v = [75 40 32; 68 35 31];
      %   data = mdadata(v, {'Cal', 'Val'}, {'PC1', 'PC2', 'PC3'},...
      %     {'Explained variance', 'Components'}, 'Explained variance');
      %   
      %   % group plot without factors
      %   figure
      %   subplot(1, 2, 1)
      %   gbar(data)
      %   
      %   subplot(1, 2, 2)
      %   gbar(data, 'FaceColor', 'rb', 'Labels', 'on', 'LegendLocation', 'best')
      %
      
         if ~ishold
            cla;
         end
         
         nGroups = obj.nRows;
         
         bw = getarg(varargin, 'BarWidth');
         if isempty(bw)
            varargin = [varargin 'BarWidth', 0.75];
         else
            varargin = [varargin 'BarWidth', bw];            
         end   

         % check color settings            
         [fc, varargin] = getarg(varargin, 'FaceColor');
         if isempty(fc)
            fc = mdadata.getmycolors(nGroups);
         else
            if isnumeric(fc)
               nfc = size(fc, 1);
            else
               nfc = numel(fc);
               if size(fc, 2) > size(fc, 1)
                  fc = fc';
               end   
            end
            
            if nfc ~= nGroups
               error('Number of colors in "FaceColor" should be the same as number of groups!');
            end   
         end   

         [ec, varargin] = getarg(varargin, 'EdgeColor');
         if isempty(ec)
            ec = repmat('none', nGroups, 1);
         else
            if isnumeric(ec)
            % color is an array with numbers
               nec = size(ec, 1);
            else
            % color is a vector with symbols   
               nec = numel(ec);
               if size(ec, 2) > size(ec, 1)
                  ec = ec';
               end                  
            end
            
            if nec ~= nGroups || nec == 1
               error('Number of colors in "EdgeColor" should be one or the same as number of groups!');
            end               
         end   
         
         % get values
         values = obj.numValues;
         x = 1:obj.nNumCols;
         if numel(x) < 12
            xtick = x;
         else
            xtick = unique(round(linspace(1, numel(x), 12)));
         end
         
         % check other parameters
         [sigfig, varargin] = getarg(varargin, 'LabelsSigfig');
         if isempty(sigfig) || ~isnumeric(sigfig) || sigfig < 1 || sigfig > 10
            sigfig = 3;
         end
         
         [showLabels, varargin] = getarg(varargin, 'Labels');
         if strcmp(showLabels, 'names')
            labels = repmat(obj.colNamesWithoutFactors, obj.nRows, 1);
         elseif strcmp(showLabels, 'numbers')
            labels = repmat(textgen('', 1:numel(obj.colNamesWithoutFactors)), obj.nRows, 1);
         elseif strcmp(showLabels, 'values')
            labels = cell(obj.nRows, obj.nNumCols);
            for i = 1:obj.nRows               
               labels(i, :) = cellstr(num2str(values(i, :)', sigfig))';
            end   
         else   
            labels = [];            
         end
                           
         h = bar(values', 0.98, varargin{:}); 
         
         for i = 1:numel(h)
            set(h(i), 'FaceColor', fc(i, :), 'EdgeColor', ec(i, :));
            xl = get(get(h(i), 'Children'), 'XData');
            if ~isempty(labels) && ~isempty(xl) 
               % 2014a or older
               % TODO: find solution for HG2 (2014b) 
                  mdadata.showlabels((xl(3, :) + xl(1, :)) / 2, values(i, :), ...
                     labels(i, :), 'top');
            end            
          end   
         
         set(gca, 'XTick', xtick, 'XTickLabel', obj.colNamesWithoutFactors(xtick));
         xlabel(obj.dimNames{2})            
         ylabel('')                     
         title(obj.name);            
         box on
         axis auto
         
         
         if obj.nRows > 1
            legend(obj.rowNames, 'EdgeColor', obj.LEGEND_EDGE_COLOR);
         end
         
         if strcmp(get(gca, 'NextPlot'), 'replace')
            if showLabels
               correctaxislim([3 3 0 10]);
            else
               correctaxislim([3 3 0 5]);
            end
         end
         
         if nargout > 0
            varargout{1} = h;
         end   

      end   
      
      function varargout = gplot(obj, varargin)
      % 'gplot' makes a group plot for line series
      %
      %   gplot(data)
      %   gplot(data, factors)
      %   gplot(data, factors, 'ParamName', ParamValue, ...)
      %
      %
      % The method makes a line series plot for two or more group of data rows,
      % defined by a combination of provided factors. By default, each group 
      % has its own color. If dataset with factors is not provided every row 
      % of the dataset will be considered as a separate group.
      %
      % Parameters:
      % -----------
      %  "Legend" - shor or nor legend for the groups. Possible values are
      %  "on" (default) and "off".
      %
      %  "LegendLocation" - if legend is on, defines location for the legend. 
      %  The values are similar to what are used in 'legend()' function.
      %
      %  "Color" - one value or a vector with values (one for each group) 
      %  for the line color. If color is specified using RGB values, the
      %  parameter should be a matrix with as many rows as many groups
      %  exist.
      %
      %  "LineWidth" - one value or a vector with values (one for each group) 
      %  for the the line width.
      %
      %  "LineStyle" - one value or a cell vector with values (one for each group) 
      %  for the the line style.
      %
      %  "Marker" - one value or a vector with values (one for each group) 
      %  for the marker symbol (default "none").
      %
      %  "MarkerSize" - one value or a vector with values (one for each group) 
      %  for the marker size.
      %
      %
      % Examples:
      % ---------
      %     
      %   % prepare a dataset
      %   v = [75 40 32; 68 35 31];
      %   data = mdadata(v, {'Cal', 'Val'}, {'PC1', 'PC2', 'PC3'},...
      %     {'Explained variance', 'Components'}, 'Explained variance');
      %   
      %   % group plot without factors
      %   figure
      %   subplot(1, 2, 1)
      %   gplot(data)
      %   
      %   subplot(1, 2, 2)
      %   gplot(data, 'Marker', '.', 'Color', 'rg', 'LineStyle', {'--', ':'})
      %
      %   % group plot with factors
      %   load simdata
      %   datasplit = mdadata([zeros(100, 1); ones(50, 1)]);
      %   datasplit.factor(1, {'Cal', 'Val'})
      %
      %   gplot(spectra, datasplit)
      %
      %
      
         if ~ishold
            cla;
         end
         
         % check if factors are provided
         if numel(varargin) > 0 
            if isa(varargin{1}, 'mdadata')
            % dataset with factors is provided
               groups = varargin{1};
               varargin(1) = [];
               groups = groups.getgroups();
               nGroups = groups.nCols;
            else
            % consider every row as a separate group
               groups = [];
               nGroups = obj.nRows;
            end   
         else
            groups = [];
            nGroups = obj.nRows;            
         end
         
         if isempty(groups)
            groups = mdadata(eye(nGroups), obj.rowNames, obj.rowNames);
         end
                  
         % check if excluded variables will be shown
         [v, varargin] = getarg(varargin, 'ShowExcluded');
         
         if isempty(v) || ~strcmp(v, 'on')
            showExcluded = false;
         else
            showExcluded = true;
         end   
         
         % get values and various parameters
         % the serIncl/serExcl is a matrix with start
         % and end indices of series in variables         
         if showExcluded
            values = obj.valuesAll(~obj.excludedRows, ~obj.factorCols);
            nCols = size(values, 2);
            indExcl = find(obj.excludedCols(~obj.factorCols));
            indIncl = find(~obj.excludedCols(~obj.factorCols));
            serExcl = getserind(indExcl);
            serIncl = getserind(indIncl);
            colNames = obj.colFullNamesAll(~obj.factorCols);
         else
            values = obj.numValues;
            nCols = size(values, 2);
            indIncl = 1:nCols;
            serIncl = getserind(indIncl);
            colNames = obj.colFullNamesWithoutFactors;
         end
         
         % check if x values are provided and set up x and xtick values
         if numel(varargin) > 0 && isnumeric(varargin{1})
            x = varargin{1};
            varargin(1) = [];
            
            if numel(x) ~= nCols
               error('Number of x values should be the same as number of columns in dataset!');
            end
            xticklabel = [];
         else   
            x = 1:nCols;
            xticklabel = colNames;
         end
         
         % check legend and labels
         [v, varargin] = getarg(varargin, 'Legend');
         if isempty(v)
            if groups.nCols < 2
               showLegend = false;
            else
               showLegend = true;
            end   
         elseif ~isempty(v)  
            if strcmp(v, 'on')
               showLegend = true;
            else
               showLegend = false;
            end
         end
            
         [lp, varargin] = getarg(varargin, 'LegendLocation');
         if isempty(lp)
            lp = 'NorthEast';
         end
         
         % check color settings
         [lc, varargin] = getarg(varargin, 'Color');
         if isempty(lc)
            lc = mdadata.getmycolors(nGroups);
         else            
            if isnumeric(lc)
               nlc = size(lc, 1);
            else
               nlc = numel(lc);
               if size(lc, 2) > size(lc, 1)
                  lc = lc';
               end   
            end
            
            if nlc == 1
               lc = repmat(lc, nGroups, 1);
            elseif nlc ~= nGroups
               error('Number of colors in "Color" should be the same as number of groups!');
            end   
         end   
                  
         % check line and marker parameters
         [lw, varargin] = getarg(varargin, 'LineWidth');
         if isempty(lw) 
            lw = ones(nGroups, 1);
         else
            if numel(lw) == 1
               lw = repmat(lw, nGroups, 1);
            elseif numel(lw) ~= nGroups
               error('Argument "LineWidth" should have one value or values for each groups!');
            end   
         end
         
         [ls, varargin] = getarg(varargin, 'LineStyle');
         if isempty(ls) 
            ls = repmat({'-'}, nGroups, 1);
         else
            if ischar(ls)
               ls = {ls};
            end   
            if numel(ls) == 1 
               ls = repmat(ls, nGroups, 1);
            elseif numel(ls) ~= nGroups
               error('Argument "LineStyle" should have one value or values for each groups!');
            end   
         end

         [mr, varargin] = getarg(varargin, 'Marker');
         if isempty(mr) 
            mr = repmat({'none'}, nGroups, 1);
         else
            if ischar(mr)
               mr = {mr};
            end   
            if numel(mr) == 1 
               mr = repmat(mr, nGroups, 1);
            elseif numel(mr) ~= nGroups
               error('Argument "Marker" should have one value or values for each groups!');
            end   
         end
         
         [ms, ~] = getarg(varargin, 'MarkerSize');
         if isempty(ms) 
            ms = repmat(15, nGroups, 1);
         else
            if numel(ms) == 1
               ms = repmat(ms, nGroups, 1);
            elseif numel(ms) ~= nGroups
               error('Argument "MarkerSize" should have one value or values for each groups!');
            end   
         end         
         
         % set X ticks
         if numel(x) < 12
            xtick = x;
         else
            tickind = unique(round(linspace(1, numel(x), 12)));
            xtick = x(tickind);
            xticklabel = xticklabel(tickind);
         end
         
         hold on
         h = cell(nGroups, 1);
         hl = zeros(nGroups, 1);
         for iGroup = 1:nGroups
            indR = groups.values(:, iGroup) == 1;
            hk = [];
            if any(indR)
               for i = 1:size(serIncl, 1);
                  indC = indIncl(serIncl(i, 1):serIncl(i, 2));
                  if indC(1) > 1
                     indC = [indC(1) - 1; indC];
                  end
                  if indC(end) < nCols
                     indC = [indC; indC(end) + 1];
                  end   
                  hk = [hk; plot(x(indC), values(indR, indC)',...
                     'Color', lc(iGroup, :), 'LineWidth', lw(iGroup), 'LineStyle', ls{iGroup},...
                     'Marker', mr{iGroup}, 'MarkerSize', ms(iGroup, :))];               
               end          
               h{iGroup} = hk;
               hl(iGroup) = hk(1);
            end   
         end
         hold off
         indl = ~(hl == 0);         
         
         if showExcluded && any(obj.excludedCols)
            lc = obj.EXCLUDED_COLOR;
            [~, varargin] = getarg(varargin, 'Color');
            [~, varargin] = getarg(varargin, 'Marker');
            [~, varargin] = getarg(varargin, 'MarkerSize');
            hold on
            for i = 1:size(serExcl, 1);
               indC = indExcl(serExcl(i, 1):serExcl(i, 2));
               hp = plot(x(indC), values(:, indC)', 'Color', lc, 'Marker', '.', ...
                  'MarkerSize', 8, varargin{:});
            end   
            hold off         
         end
         
         xlabel(obj.dimNames{2});
         title(obj.name);
         set(gca, 'XTick', xtick, 'XTickLabel', xticklabel);
         box on
                  
         if showLegend
            legend(hl(indl), groups.colFullNames(indl), 'Location', lp, 'EdgeColor', obj.LEGEND_EDGE_COLOR);
         end
         
         if strcmp(get(gca, 'NextPlot'), 'replace')
            correctaxislim(5);
         end
         
         if nargout > 0
            varargout{1} = h(indl);
         end   
      end
      
      function varargout = gscatter(obj, varargin)
      % 'gscatter' makes a group scatter plot
      %
      %   gscatter(data, factors)
      %   gscatter(data, factors, 'ParamName', ParamValue, ...)
      %
      %
      % The method makes a scatter plot for two or more group of points,
      % defined by a combination of provided factors. By default, each group 
      % has its own color. If more columns exist, the method will generate
      % a figure with several subplots for all pairwise combinations of the
      % columns. The maximal number of combinations is limited by 10, so if
      % more than five columns are available, the method will show plots
      % only for the first five.
      %
      % Parameters:
      % -----------
      %  "Labels" - show or not labels for the data points. Possible
      %  values are "none" (default), "names" for name of objects and "numbers"
      %  for their numbers. 
      %
      %  "Marker" - one value or a vector with values (one for each group) 
      %  for the marker symbol.
      %
      %  "MarkerEdgeColor" - one value or a vector with values (one for each group) 
      %  for the marker edge color. If color is specified using RGB values, the
      %  parameter should be a matrix with as many rows as many groups
      %  exist.
      %
      %  "MarkerFaceColor" - one value or a vector with values (one for each group) 
      %  for the marker edge color. If color is specified using RGB values, the
      %  parameter should be a matrix with as many rows as many groups
      %  exist.
      %
      %  "MarkerSize" - one value or a vector with values (one for each group) 
      %  for the marker size.
      %
      %
      % Examples:
      % ---------
      %
      %   load people
      %   people.factor('Sex', {'Male', 'Female'})
      %   
      %   figure
      %   subplot(1, 2, 1)
      %   gscatter(people(:, 'Height:Weight'), people(:, 'Sex'))
      %   
      %   subplot(1, 2, 2)
      %   gscatter(people(:, 'Height:Weight'), people(:, 'Sex'), 'Labels', 'on',...
      %     'MarkerSize', [7 10], 'Marker', 'so', 'MarkerFaceColor', 'rb')
      %   
      %   figure
      %   gscatter(people, people(:, 'Sex'), 'LegendLocation', 'best')
      %
      %
         if ~ishold
            cla;
         end
      
         % check if factors are provided
         if numel(varargin) > 0 && isa(varargin{1}, 'mdadata')
            groups = varargin{1};
            varargin(1) = [];
         else
            h = scatter(obj, varargin{:});
            if nargout > 0
               varargout{1} = h;
            end
            return
         end
         
         objs = mdasplit(obj, groups);
         nGroups = numel(objs);
         
         [args, varargin] = mdadata.getgscatteroptions(nGroups, varargin{:});
         
         % show hidden rows or not?
         [v, varargin] = getarg(varargin, 'ShowExcluded');         
         if isempty(v) || strcmp(v, 'off')
            showExcluded = false;
         else
            showExcluded = true;
         end
         
         % show labels or not?
         labelsHidden = [];
         showLabels = getarg(varargin, 'Labels');   
         if ~isempty(showLabels) && strcmp(showLabels, 'names')
            labelsHidden = obj.rowFullNamesAll(obj.excludedRows);
         end   

         hp = cell(nGroups, 1);
         legendStr = cell(nGroups, 1);
         lh = [];
         hold on               
         for iGroup = 1:nGroups
            hp{iGroup} = objs{iGroup}.scatter(args{iGroup}{:});                
            legendStr{iGroup} = objs{iGroup}.name;
            lh = [lh; hp{iGroup}.plot];
         end
         hold off
         h.plots = hp;
         
         if showExcluded
            values = obj.valuesHidden;
            if obj.nCols == 1
               xh = 1:size(values, 1);
               yh = values(:, 1);
            else   
               xh = values(:, 1);
               yh = values(:, 2);
            end
            
            mr = get(h.plots{1}.plot, 'Marker');
            ms = get(h.plots{1}.plot, 'MarkerSize');
            hold on
            hh.plotHidden = plot(xh, yh, 'Color', obj.EXCLUDED_COLOR, 'Marker', mr, ...
               'MarkerFaceColor', obj.EXCLUDED_COLOR, ...
               'MarkerEdgeColor', 'none', 'MarkerSize', ms,...
               'LineStyle', 'none');                           
            hold off
         end
         
         if strcmp(get(gca, 'NextPlot'), 'replace')
            if numel(legendStr) > 1
               mdadata.legend(lh, legendStr);
            end
            
            title(objs{1}.name)
            box on
            correctaxislim(10);                  
         end
               
         if ~isempty(labelsHidden) && showExcluded
            h.labelsHidden = mdadata.showlabels(xh, yh, labelsHidden);
         end
                             
         if nargout > 0
            varargout{1} = h;
         end   
      end
      
      %%% statistic plots
      
      function varargout = hist(obj, varargin)
      % 'hist' makes a histogram plot for selected columns of dataset.
      %
      %   hist(data);
      %   hist(data, nbins);
      %   hist(data, 'ParamName', ParamValue, ...);
      %   
      %   hist(data, factors);
      %   hist(data, factors, nbins);
      %   hist(data, factors, 'ParamName', ParamValue, ...);
      %
      %
      % The function returns a structure with plot elements (plot handle,
      % labels handle, etc). If dataset has more than one column, the method 
      % will make a plot for the first column only.
      % 
      % Optional argument "factors" is a dataset with qualitative variables
      % (factors) used to split values to groups and show distribution
      % histogram separately for each group on the same axis.
      %
      % Parameters:
      % -----------
      % All parameters for Matlab's 'bar()' function will work. Optinally the second 
      % parameter (after dataset) is either number of bins or a vector with bin
      % intervals like in original 'hist()' function. Extra parameters are shown below.
      %
      %  "Density" - calculate density instead of frequency. Possible
      %  values are "on" and "off" (default).
      %
      %  "ShowNormal" - shows a curve with normal theoretical normal distribution.
      %  Possible values are "on" and "off" (default). 
      % 
      %  "Labels" - show or not labels for the histogram bars. Possible
      %  values are "on" and "off" (default). If "on", the values will be shown on 
      %  top of each bar.
      %
      %  "FaceColor" - the parameter is similar to the one for bar plot, however if 
      %  factors are used it should have a value for each group, made by combination 
      %  of the factors.
      %
      %  "EdgeColor" - the parameter is similar to the one for bar plot, however if 
      %  factors are used it should have a value for each group, made by combination 
      %  of the factors.
      %
      %  "Color" - color of normal probability curve (if used), if factors are used it 
      %  should have a value for each group, made by combination of the factors.
      %
      %  "FaceAlpha" - transparency of the bars, a value between 0 (fully transparent) 
      %  and 1 (not transparent). Default value is 0.5.
      %
      %  "LineWidth" - line thickness of normal probability curve (if used), default is 2.
      %
      %  "LineStyle" - line style of normal probability curve (if used), default is "-".
      %
      %
      % Examples:
      % ---------
      %
      %   load people
      %
      %   % show historgram for particular column
      %   figure
      %   hist(people(:, 'IQ'), 'EdgeColor', 'c')
      %   
      %   % show histogram for first column
      %   hist(people, 'Density', 'on', 'ShowNormal', 'on')
      %
      %   % make a factor and show histogram for groups
      %   people.factor('Sex', {'M', 'F'});
      %   figure
      %   hist(people(:, 'Height'), people(:, 'Sex'), 'ShowNormal', 'on');
      %
      %

         if ~ishold
            cla;
         end
      
         % check arguments for groups and nbins
         if nargin == 1
            groups = [];
            nbins = 0;
         elseif nargin >= 2 
            if isa(varargin{1}, 'mdadata') 
               groups = varargin{1};
               if nargin > 2 && isnumeric(varargin{2}) 
                  nbins = varargin{2};
                  varargin(2) = []; 
               else   
                  nbins = 0;
               end
               varargin(1) = []; 
            else
               groups = [];
               if isnumeric(varargin{1}) 
                  nbins = varargin{1};
                  varargin(1) = []; 
               else
                  nbins = 0;
               end
            end               
         end

         if ~isempty(groups)
            groups = groups.getgroups();
            nGroups = groups.nCols;
         else
            nGroups = 1;            
         end
         
         values = obj.numValues(:, 1);
                  
         % check color settings
         [fa, varargin] = getarg(varargin, 'FaceAlpha');
         if isempty(fa)
            fa = 0.4;
         end
            
         [fc, varargin] = getarg(varargin, 'FaceColor');
         if isempty(fc)
            fc = mdadata.getmycolors(nGroups);
         else
            if isnumeric(fc)
               nfc = size(fc, 1);
            else
               nfc = numel(fc);
               if size(fc, 2) > size(fc, 1)
                  fc = fc';
               end   
            end
            
            if nfc ~= nGroups
               error('Number of colors in "FaceColor" should be the same as number of groups!');
            end   
         end   
         
         [ec, varargin] = getarg(varargin, 'EdgeColor');
         if isempty(ec)
            ec = repmat('none', nGroups, 1);
         else
            if isnumeric(ec)
            % color is an array with numbers
               nec = size(ec, 1);
            else
            % color is a vector with symbols   
               nec = numel(ec);
               if size(ec, 2) > size(ec, 1)
                  ec = ec';
               end                  
            end
            
            if nec ~= nGroups || nec ~= 1
               error('Number of colors in "EdgeColor" should be one or the same as number of groups!');
            end               
         end   
         
         [lc, varargin] = getarg(varargin, 'Color');
         if isempty(lc)
            lc = fc;
         else
            if isnumeric(lc)
               nlc = size(lc, 1);
            else
               nlc = numel(lc);
               if size(lc, 2) > size(lc, 1)
                  lc = lc';
               end                                 
            end
            
            if nlc ~= nGroups
               error('Number of colors in "Color" should be the same as number of groups!');
            end               
         end   

         % check line parameters
         [lw, varargin] = getarg(varargin, 'LineWidth');
         if isempty(lw) 
            lw = 2;
         end
         
         [ls, varargin] = getarg(varargin, 'LineStyle');
         if isempty(ls) 
            ls = '-';
         end
         
         % check if showing normal distribution is needed
         [v, varargin] = getarg(varargin, 'ShowNormal');
         if ~isempty(v) && strcmp(v, 'on')
            showNormal = true;
         else
            showNormal = false;
         end
         
         % check what to show - frequency or density
         [v, varargin] = getarg(varargin, 'Density');
         if ~isempty(v) && strcmp(v, 'on')
            showDensity = true;
            ylabelStr = 'Density';
         else
            showDensity = false;
            ylabelStr = 'Frequencies';
         end
         
         % check if labels to show
         [v, varargin] = getarg(varargin, 'Labels');
         if ~isempty(v) && strcmp(v, 'on')
            showLabels = true;
         else
            showLabels = false;
         end
         
         % in 2014b bar has no children, transparency will not work
         showTransparent = true;
         hg2 = false;
         if ~verLessThan('matlab', '8.4')
            hg2 = true;
         end   
            
         isShowNormal = false;
         
            
         hb = cell(nGroups, 1);
         xlim = [];
         hold on
         for nGroup = 1:nGroups
            if nGroups > 1
               v = values(groups.values(:, nGroup) == 1, 1);
            else
               v = values(:, 1);
            end

            if nbins > 0
               [y, x] = hist(v, nbins);
            else   
               [y, x] = hist(v);
            end

            if isempty(xlim)
               xlim = [min(x) max(x)];
            else   
               if xlim(1) > min(x)
                  xlim(1) = min(x);
               end

               if xlim(2) < max(x);
                  xlim(2) = max(x);
               end   
            end

            % calculate x and y values for normal curve
            if showNormal == true;               
               m = mean(v);
               s2 = var(v);
               mnx = min(v);
               mxx = max(v);
               dx = (mxx - mnx)/20;
               if mnx < mxx
                  nx = linspace(mnx - dx, mxx + dx, 100);
                  ny = 1/sqrt(2 * pi * s2) * exp( - (nx - m).^2 / (2 * s2) );      
                  isShowNormal = true;
               else
                  isShowNormal = false;
               end                  
            end

            % amend y values for density/frequency case
            if showDensity
               y = y/sum(y)/(x(2) - x(1));
            else
               if isShowNormal
                  ny = ny * sum(y) * (x(2) - x(1));
               end     
            end

            % set up values for labels

            % show plot and set transparency
            hb{nGroup} = bar(double(x), double(y), 0.98, 'FaceColor', fc(nGroup, :), ...
               'EdgeColor', ec(nGroup, :), varargin{:});   
            if showTransparent
               if hg2
                  % TODO: fix HG2 transparancy
                  % hb{nGroup}.Face.ColorType = 'truecoloralpha';
                  % hb{nGroup}.Face.ColorData = uint8(255 * [fc(nGroup, :) fa]');
               else   
                  hp = arrayfun(@(x) allchild(x), double(hb{nGroup}));
                  set(hp, 'FaceAlpha', fa);               
               end   
            end

            if isShowNormal
              plot(nx, ny, 'Color', lc(nGroup, :), 'LineWidth', lw, 'LineStyle', ls); 
            end   

            if showLabels
               labels = strsplit(num2str(y, 3), ' ');
               mdadata.showlabels(x, y, labels, 'top');
            end
         end
         
         hold off   
         xlabel(obj.colFullNamesWithoutFactors{1})
         ylabel(ylabelStr)         
         title(obj.name)
         box on               

         % correct limits
         if strcmp(get(gca, 'NextPlot'), 'replace')
            correctaxislim([5 5 0.01 5], xlim);
         end
         
         if nGroups > 1
            % show legend and set transparancy for legend items
            hl = legend([hb{:}], groups.colFullNamesWithoutFactors, 'EdgeColor', obj.LEGEND_EDGE_COLOR);
            c = get(hl, 'Children');
            hp = arrayfun(@(x) allchild(x), c(1:2:end));
            set(hp, 'FaceAlpha', fa);                              
         end
         
         if nargout > 0
            varargout{1} = [];
         end   

      end
      
      function varargout = errorbar(obj, varargin)
      % 'errorbar' makes an error bar plot for dataset columns
      %
      %   errobar(data);
      %   errorbar(data, 'ParamName', ParamValue, ...);
      %   
      %   errobar(data, factors);
      %   errorbar(data, factors, 'ParamName', ParamValue, ...);
      %
      %
      % The method is similar to standard 'errorbar()' function, however 
      % all statistic are caclulated automatically, only dataset with original
      % values should be provided.
      %
      % Optional argument "factors" is a dataset with qualitative variables
      % (factors) used to split data values into groups and show error bars
      % separately for each group on the same axis. In this case one plot
      % will be made only for the first column of data.
      %
      % Parameters:
      % ------------
      % All parameters for Matlab's 'plot()' function (e.g. "Color", etc.)
      % can be used. Additional parameters are:
      %
      %  "Type" - how to calculate size of the error bars. By default ("ci") 
      %  error bars shows confidence interval for mean values. This can be
      %  changed to: "se" to show standard error, or to "sd" to show standard
      %  deviation. Both can be combined with 'Alpha' parameter, see
      %  examples below.
      %
      %  "Alpha" - significance level, a value between 0 and 1.
      %
      %
      % Examples:
      % ---------
      %   
      %   load people
      %   people.removecols('Income');
      %
      %   % show average and 95% confidence intervals
      %   figure
      %   errorbar(people)
      %
      %   % show average and 90% confidence intervals
      %   figure
      %   errorbar(people, 'Alpha', 0.1)
      %
      %   % show average +/- standard error
      %   figure
      %   errorbar(people, 'Type', 'se')
      %
      %   % show average +/- standard deviation
      %   figure
      %   errorbar(people, 'Type', 'sd')
      %
      %   % show average and 95% of most common values (+/- 1.96 sd)
      %   figure
      %   errorbar(people, 'Type', 'sd', 'Alpha', 0.05)
      %
      %   % confidence intervals for groups
      %   people.factor('Sex', {'Male', 'Female'});
      %   figure
      %   errorbar(people(:, {'Height', 'Weight'}), people(:, 'Sex'))
      %
         
         if ~ishold
            cla;
         end

         % check if factors are provided and generate groups
         if nargin > 1 && isa(varargin{1}, 'mdadata')
            groups = varargin{1};
            varargin(1) = [];
            groups = groups.getgroups();
            nGroups = groups.nCols;
         else
            groups = [];
            nGroups = 1;
            m = mean(obj);
         end
         
         [type, varargin] = getarg(varargin, 'Type');
         if isempty(type)
            type = 'ci';            
         end
         
         [alpha, varargin] = getarg(varargin, 'Alpha');
         if isempty(alpha)
            if strcmp(type, 'ci') 
               type = 'se';
               alpha = 0.05;
               t = [];
            else
               t = 1;
            end   
         else
            if strcmp(type, 'ci') 
               type = 'se';
            end   
            t = [];
         end

         if isempty(find(strcmp(varargin, 'LineStyle'), 1))
            varargin = [{'LineStyle', 'none'} varargin];
         end   
         
         if isempty(find(strcmp(varargin, 'Marker'), 1))
            varargin = [{'Marker', '.'} varargin];
            if isempty(find(strcmp(varargin, 'MarkerSize'), 1))
               varargin = [{'MarkerSize', 18} varargin];
            end   
         end   
         
         if isempty(find(strcmp(varargin, 'Color'), 1))
            varargin = [{'Color', mdadata.getmycolors(1)} varargin];
         end   
         
         values = obj.numValues(:, 1);
         
         % calculate error margin and mean values         
         if strcmp(type, 'se')
            if t == 1
               titlestr = '(std. error)';
            else
               titlestr = sprintf('(%.0f%% conf. int)', (1 - alpha) * 100);
            end   
            
            if nGroups == 1
               if isempty(t)
                  t = mdatinv(1 - alpha/2, obj.nRows - 1);
               end   
               err = se(obj) * t;
            else
               err = zeros(1, nGroups);
               m = zeros(1, nGroups);
               for nGroup = 1:nGroups
                  ind = groups.values(:, nGroup) == 1;
                  if isempty(t)
                     t = mdatinv(1 - alpha/2, sum(ind) - 1);
                  end   
                  m(nGroup) = mean(values(ind, 1));
                  err(nGroup) = mdase(values(ind, 1)) * t;
               end   
               m = mdadata(m, obj.colNamesWithoutFactors(1), groups.colNames);
               err = mdadata(err, obj.colNamesWithoutFactors(1), groups.colNames);               
               err.colFullNames = groups.colFullNames;
               err.rowFullNames = obj.colFullNamesWithoutFactors(1);
            end   
         else
            if t == 1
               titlestr = '(std)';
            else
               titlestr = sprintf('(%.0f%% interval)', (1 - alpha) * 100);
            end   
            
            if nGroups == 1
               if isempty(t)
                  t = mdatinv(1 - alpha/2, obj.nRows - 1);
               end   
               err = std(obj) * t;
            else
               err = zeros(1, nGroups);
               m = zeros(1, nGroups);
               for nGroup = 1:nGroups
                  ind = groups.values(:, nGroup) == 1;
                  if isempty(t)
                     t = mdatinv(1 - alpha/2, sum(ind) - 1);
                  end   
                  m(nGroup) = mean(values(ind, 1));                     
                  err(nGroup) = std(values(ind, 1)) * t;
               end   
               m = mdadata(m, obj.colNamesWithoutFactors(1), groups.colNames);
               err = mdadata(err, obj.colNamesWithoutFactors(1), groups.colNames);               
               err.colFullNames = groups.colFullNames;
               err.rowFullNames = obj.colFullNamesWithoutFactors(1);
            end   
         end   
                              
         x = 1:err.nCols;
         xticklabel = err.colFullNames;
 
         if numel(x) < 12
            xtick = x;
         else
            xtick = unique(round(linspace(1, numel(x), 12)));
         end
            
         h = errorbar(x, m.values, err.values, varargin{:});
                    
         if ~isempty(xticklabel)
            set(gca, 'XTick', xtick, 'XTickLabel', xticklabel(xtick));
         end
         
         % correct axis limits
         if strcmp(get(gca, 'NextPlot'), 'replace')
            correctaxislim(5, [min(x) max(x)]);
         end
            
         if nGroups == 1
            xlabel(obj.dimNames{2})         
            ylabel('')    
            title([obj.name ' ' titlestr])
         else
            xlabel(groups.dimNames{2})
            ylabel(err.rowFullNames{1})    
            title([err.rowFullNames{1} ' ' titlestr])
         end
         
         box on
         
         if nargout > 0
            varargout{1} = h;
         end            
      end
      
      function varargout = boxplot(obj, varargin)
      % 'boxplot' makes a box and whiskers plot for dataset columns
      %
      %   boxplot(data);
      %   boxplot(data, 'ParamName', ParamValue, ...);
      %
      %   boxplot(data, factors);
      %   boxplot(data, factors, 'ParamName', ParamValue, ...);
      %
      %
      % Optional argument "factors" is a dataset with qualitative variables
      % (factors) used to split data values into groups and show box and
      % whiskers separately for each group on the same axis. In this case the 
      % plot will be made only for the first column of data.
      %
      % Parameters:
      % ------------
      %
      %  "Whisker" - a factor 'w' that influences length of the whiskers. 
      %  The whiskers correspond to max and min values, after removing 
      %  outliers. The default value for w is 1.5, which corresponds 
      %  to 2.7 std interval (99.3% of most common values) if values are 
      %  normally distributed. 
      %
      %  "Labels" - show or not labels for outliers. Possible values are 
      %  "none" (default), "names" for name of objects and "numbers"
      %  for their numbers. 
      %
      %
      % Examples:
      % ---------
      %   
      %   load people
      %   
      %   % normal box plot for columns
      %   figure
      %   boxplot(people(:, {'Height', 'Weight', 'Swim'}));
      %
      %   % box plot for groups
      %   people.factor('Sex', {'Male', 'Female'})
      %   figure
      %   boxplot(people(:, {'Height', 'Weight'}), people(:, 'Sex'), 'Labels', 'on')
      %

         if ~ishold
            cla;
         end
            
         values = obj.numValues;
         
         % check if factors are provided and generate groups
         if nargin > 1 && isa(varargin{1}, 'mdadata')
            groups = varargin{1};
            varargin(1) = [];
            groups = groups.getgroups();
            nGroups = groups.nCols;
         else
            groups = [];
            nGroups = 1;
         end
                  
         % set up length of whiskers
         [w, varargin] = getarg(varargin, 'Whisker');
         if isempty(w)
            w = 1.5;
         end

         % set up colors
         c = mdadata.getmycolors(2);
         [bc, varargin] = getarg(varargin, 'EdgeColor');
         if isempty(bc)
            bc = c(1, :);
         end
         
         [mc, varargin] = getarg(varargin, 'Color');
         if isempty(mc)
            mc = c(2, :);
         end

         rowNames = obj.rowFullNames ;
         colNames = obj.colFullNamesWithoutFactors;
         
         % check if labels to show
         [showLabels, ~] = getarg(varargin, 'Labels');
         if strcmp(showLabels, 'names')
            labels = rowNames;
         elseif strcmp(showLabels, 'numbers')
            labels = textgen('', 1:numel(rowNames));
         else
            labels = [];            
         end
                
         % calculate number of boxes (n) and generate x, xticklabels
         if nGroups == 1
            n = obj.nNumCols;
            x = 1:n;         
            xticklabel = colNames;
            m = mean(values);
         else
            n = groups.nCols;
            x = 1:n;
            xticklabel = groups.colFullNames;
         end
         
         % correct number of ticks
         if numel(x) < 12
            xtick = x;
         else
            xtick = unique(round(linspace(1, numel(x), 12)));
         end
         
         % calculate width of boxes and limits
         if n > 1
            boxWidth = (max(x) - min(x)) / n * 0.75;
            lims = [1 20];
         else
            boxWidth = 1;
            lims = [50 10];
         end   
            
         outX = [];
         outY = [];
         outLabels = [];
            
         % loop for plotting boxes and whiskers
         hold on
         for i = 1:n
            if nGroups == 1
               v = values(:, i);
            else
               ind = groups.values(:, i) == 1;
               v = values(ind, 1);
               if ~isempty(obj.rowFullNames)
                  rowNames = obj.rowFullNames(ind);
               else
                  rowNames = [];
               end
               
               m (i) = mean(v);
            end   
               
            % calculate quartiles and limits
            q1 = mdapercentile(v, 25);
            q2 = mdapercentile(v, 50);
            q3 = mdapercentile(v, 75);
            h = q3 - q1;
            up = q3 + h * w;
            low = q1 - h * w;
               
            % show box
            if abs(h) > 0
               rectangle('Position', [x(i) - boxWidth/2, q1, boxWidth, h], 'EdgeColor', bc)
            end   
            line([x(i) - boxWidth/2, x(i) + boxWidth/2], [q2 q2], 'Color', mc);
            
            % detect outliers
            outind = v < low | v > up;
            outY = [outY; v(outind)];
            outX = [outX; x(i) * ones(sum(outind), 1)];
               
            if ~isempty(labels)
               outLabels = [outLabels; labels(outind)];            
            end
               
            % show whiskers
            mn = min(v(~outind));            
            line([x(i), x(i)], [mn, q1], 'Color', bc);
            line([x(i) - boxWidth/2, x(i) + boxWidth/2], [mn mn], 'Color', bc);

            mx = max(v(~outind));
            line([x(i), x(i)], [q3 mx], 'Color', bc);
            line([x(i) - boxWidth/2, x(i) + boxWidth/2], [mx mx], 'Color', bc);            
         end
            
         % plot outliers and average values
         if ~isempty(outX)
            scatter(double(outX), double(outY), 'x', 'MarkerEdgeColor', bc)            
         end   
         plot(x, m, '.', 'Color', mc, 'LineStyle', 'none');
         hold off
         
         if ~isempty(labels)
            mdadata.showlabels(outX, outY, outLabels, 'right');
         end   
         
         if ~isempty(xticklabel)
            set(gca, 'XTick', xtick, 'XTickLabel', xticklabel(xtick));
         end
         
         if nGroups == 1
            xlabel(obj.dimNames{2})         
            ylabel('')    
            title(obj.name)
         else
            xlabel(groups.dimNames{2})
            ylabel(colNames{1})
            title(obj.name)
         end
         
         box on
         if strcmp(get(gca, 'NextPlot'), 'replace')
            correctaxislim([5 5 0.01 5], [min(x) - boxWidth/1.8 max(x) + boxWidth / 1.8]);
         end
         
         if nargout > 0
            varargout{1} = h;
         end            
      end
      
      function varargout = qqplot(obj, varargin)
      % 'qqplot' makes a quantile-quantile plot for selected columns of dataset.
      %
      %   qqplot(data)
      %   qqplot(data, 'ParamName', ParamValue, ...)
      %   
      %   qqplot(data, factors)
      %   qqplot(data, factors, 'ParamName', ParamValue, ...)
      %
      %
      % Quantile-quantile plot for normal distribution calculates real and theoretical 
      % quantiles of each data value as if the values are distributed normally.
      % The calculated values are shown as a scatter plot and can be used to
      % evaluate if data is distributed normally or deviates from normal
      % distribution.      
      %
      % If dataset has more than one column, the method  will make the plot 
      % for the first column only.
      %
      % Optional argument "factors" is a dataset with qualitative variables
      % (factors) used to split values to groups and show points separately 
      % for each group on the same axis.
      %
      %
      % Parameters:
      % -----------
      % All parameters for Matlab's 'plot()' function will work. Extra parameters 
      % are shown below. If factors are used the color parameters should have 
      % a value for each group, made by combination of the factors.
      %
      %  "ShowNormal" - show or not a line for ideal normal distribution.
      %  Possible values are "off" and "on" (default). 
      % 
      %  "Labels" - show or not labels for the data points. Possible
      %  values are "none" (default), "names" for name of objects and "numbers"
      %  for their numbers. 
      %
      %  "LineColor" - a color of fitted line (the color of points can be
      %  changed using parameter "Color")
      %
      %
      % Examples:
      % ---------
      %
      %   load people
      %
      %   figure
      %   qqplot(people(:, 'Height'), 'Labels', 'on')   
      %   
      %   people.factor('Sex', {'Male', 'Female'})
      %   figure
      %   qqplot(people(:, 'IQ'), people(:, 'Sex'))
      %
      %

         if ~ishold
            cla;
         end
      
         % check arguments for groups and nbins
         if nargin > 1 && isa(varargin{1}, 'mdadata') 
            groups = varargin{1};
            varargin(1) = [];
            groups = groups.getgroups();
            nGroups = groups.nCols;            
         else
            groups = [];
            nGroups = 1;            
         end

         % limit number of variables by 12
         values = obj.numValues(:, 1);
                  
         % check color settings
         [fa, varargin] = getarg(varargin, 'FaceAlpha');
         if isempty(fa)
            fa = 0.5;
         end
            
         [mc, varargin] = getarg(varargin, 'Color');
         if isempty(mc)
            mc = mdadata.getmycolors(nGroups);
         else
            if isnumeric(mc)
               nmc = size(mc, 1);
            else
               nmc = numel(mc);
               if size(mc, 2) > size(mc, 1)
                  mc = mc';
               end   
            end
            
            if nmc ~= nGroups
               error('Number of colors in "Color" should be the same as number of groups!');
            end   
         end   
         
         [lc, varargin] = getarg(varargin, 'LineColor');
         if isempty(lc)
            lc = mc;
         else
            if isnumeric(lc)
               nlc = size(lc, 1);
            else
               nlc = numel(lc);
               if size(lc, 2) > size(lc, 1)
                  lc = lc';
               end                                 
            end
            
            if nlc ~= nGroups
               error('Number of colors in "LineColor" should be the same as number of groups!');
            end               
         end   

         [v, varargin] = getarg(varargin, 'ShowNormal');
         if ~isempty(v) && strcmp(v, 'off')
            showLine = false;
         else 
            showLine = true;
         end   
         
         % check line and marker parameters
         [lw, varargin] = getarg(varargin, 'LineWidth');
         if isempty(lw) 
            lw = 1;
         end
         
         [ls, varargin] = getarg(varargin, 'LineStyle');
         if isempty(ls) 
            ls = '--';
         end

         if isempty(find(strcmp(varargin, 'Marker'), 1))
            varargin = [{'Marker', 'o'} varargin];
         end   
         
         if isempty(find(strcmp(varargin, 'MarkerSize'), 1))
            varargin = [{'MarkerSize', 8} varargin];
         end   
         
         rowNames = obj.rowNames;

         % check if labels to show
         [showLabels, varargin] = getarg(varargin, 'Labels');
         if strcmp(showLabels, 'names') && ~isempty(obj.rowNames)
            labels = rowNames;
         elseif strcmp(showLabels, 'numbers')
            labels = textgen('', 1:obj.nRows);
         else
            labels = [];            
         end         
            
         hold on
         hp = zeros(nGroups, 1);
         hl = zeros(nGroups, 1);
         for nGroup = 1:nGroups
            if nGroups > 1
               ind = groups.values(:, nGroup) == 1;
               v = values(ind, 1);
            else
               ind = 1:size(values, 1);
               v = values(:, 1);
            end
               
            [v, sortind] = sort(v);

            n = numel(v);
            k = 1:n;
            x = (k - 0.5)/n;            
            x = mdatinv(x, 100000);
               
            hp(nGroup) = plot(x, v, 'MarkerEdgeColor', 'none', 'MarkerFaceColor', mc(nGroup, :),...
               'LineStyle', 'none', varargin{:});

            if showLine && numel(x) > 1
               qx = mdapercentile(x, [25 75]);
               qy = mdapercentile(v, [25 75]);
               
               b1 = diff(qy)/diff(qx);
               b0 = (qy(1) + qy(2))/2 - b1 * (qx(1) + qx(2))/2;               
               
               xp = [min(x), max(x)];
               yp = b0 + b1 * xp;
               
               h.normalLine = line(xp, yp, 'Color', lc(nGroup, :), 'LineStyle', ls, 'LineWidth', lw);
            end
               
            if ~isempty(labels)
               l = labels(ind);
               h.labels = mdadata.showlabels(x, v, l(sortind), 'top');      
            end            
         end     
         hold off
            
         axis auto
         title(obj.colFullNamesWithoutFactors{1})         
         ylabel('Data quantiles');         
         xlabel('Normal theoretical quantiles');
         box on
         correctaxislim([10 10])
            
         if nGroups > 1
               % show legend and set transparancy for legend items
            h.legend = legend(hp, groups.colFullNames, 'EdgeColor', obj.LEGEND_EDGE_COLOR);
%                c = get(hl, 'Children');
%                hp = arrayfun(@(x) allchild(x), c(1:2:end));
%                set(hp, 'FaceAlpha', fa);                              
         end
         h.plot = hp;         
         if nargout > 0
            varargout{1} = h;
         end   
      end

      %%% sort and display methods
            
      function show(obj, sigfig)
      % 'print' prints dataset name, information and table with values.
      %    
      %   show(data);
      %   show(data, sigfig)
      %
      %
      % Optional parameter 'sigfig' is a number of significant figures to
      % use for display the values. Default value is 3.
      %

         if nargin < 2
            sigfig = 3;
         else         
            sigfig = round(sigfig);
         end            
         
         fprintf('\n')
         if ~isempty(obj.name)
            fprintf('\n%s:\n', obj.name);
         end

         if ~isempty(obj.info)
            fprintf('%s\n', obj.info);
         end

         rowNames = obj.rowFullNames ;
         if ~isempty(rowNames)
            rowlength = max(cellfun('length', rowNames));
         else
            rowlength = 0;
         end
         values = obj.values;

         if ~isempty(obj.colFullNames)
            colNames = obj.colFullNames;
         else
            colNames = obj.colNames;
         end
         
         nCols = obj.nCols;
         nRows = obj.nRows;
         
         if nRows > 100
            warning('The data is too long, will show first 100 rows only.')
            nRows = 100;
            values = values(1:nRows, :);
            if ~isempty(rowNames)
               rowNames = rowNames(1:nRows);
            end   
         end
         
         % prepare text array for output
         if rowlength >= 1
            s = sprintf('%%%ds', rowlength);
            vout = cellfun(@(x)(sprintf(s, x)), rowNames', 'UniformOutput', false);
            if size(vout, 1) < size(vout, 2)
               vout = vout';
            end   
            vout = cell2mat(vout);
            vout = [repmat(' ', 2, rowlength); vout];
         else
            vout = '';
         end
         
         % convert values to text
         nFactor = 1;
         for i = 1:nCols
            if obj.isfactor(i)
               % mark a column name with asterisk
               colNames{i} = ['* ' colNames{i} ];
               
               % get factor values as indices
               [~, ~, v] = unique(values(:, i));
               
               % calculate maximal width for the field
               factors = obj.getfactorlevels(i);
               v = factors(v);
               lc = max(cellfun(@(x)(length(x)), factors));
               l = max(lc, numel(colNames{i})) + 2;
               
               % convert factor values into a char array
               s = sprintf('%%%ds', l);
               v = cellfun(@(x)(sprintf(s, x)), v, 'UniformOutput', false);
               if size(v, 1) ~= nRows
                  v = v';
               end   
               v = cell2mat(v);
               nFactor = nFactor + 1;
            else   
               v = num2str(values(:, i), sigfig);
               lc = size(v, 2);
               l = max(lc, numel(colNames{i})) + 2;               
               v = [repmat(' ', nRows, l - lc) v];               
            end   
            
            str = [sprintf('%*s', l, colNames{i}); [' ' repmat('-', 1, l - 1)]; v];  
            vout = [vout str];
         end
         
         if ~isempty(obj.dimNames) && numel(obj.dimNames) == 2 && ~isempty(obj.dimNames{2}) && nCols > 1
            width = size(vout, 2);
            fprintf('\n%*s\n', (width + numel(obj.dimNames{2}) + rowlength)/2 + 1, obj.dimNames{2});
         end
         disp(vout)
         fprintf('\n')         
      end
            
      function varargout = sort(obj, columns, mode)
      % 'sort' sort rows of dataset
      %
      %   sort(data, columns);
      %   sort(data, columns, mode);
      %
      %
      % The method sorts rows according to its values in the specified
      % columns. The argument 'columns' can be a vector of column numbers
      % or a cell array of column names. Argument 'mode' can have values
      % 'ascend' (default) or 'descend'.
      %
      % Examples:
      % ---------
      %
      %   load people
      %   
      %   people.sort('Height')
      %   disp(people)
      %   
      %   people.sort({'Sex', 'Region'}, 'descend');
      %   disp(people)
      %
      
      
      
         if nargin < 3
            mode = 'ascend';            
         end   
         
         if iscell(columns) || ischar(columns)
            columns = parsecolind(obj, columns);
         end
         
         if strcmp(mode, 'descend')
            columns = -columns;
         end
         
         [val, ind] = sortrows(obj.values, columns);
         
%         try
            row_ind = ~ind2bool(obj.excludedRows, obj.nRowsAll);
            col_ind = ~ind2bool(obj.excludedCols, obj.nColsAll);
            obj.valuesAll(row_ind, col_ind) = val;
            if ~isempty(obj.rowNames)
               obj.rowNames(row_ind) = obj.rowNames(ind);
               obj.rowFullNames(row_ind) = obj.rowFullNames(ind);
            end   
%         catch
%            error('Error during sorting the dataset rows!');
%         end   
         
         if nargout > 0
            varargout{1} = 1;
         end   
      end
            
      %%% GUI methods
      function guiplot(obj, varargin)
      % 'guiplot' is a GUI tool for exploring data with plots
      %
      %   guiplot(data)
      %
      %
      % The method allows to explore data with plots interactively. User can change
      % type of plot, main parameters of the current plot as well as manipulate with
      % objects and variables.
      %
      % The manipulation includes first of all selection, excluding, and
      % including of objects on scatter plot and variables on lineseries plot.
      % The following shortcats can be used (click on axes before): 
      % 
      % 's' - start polygon (scatter) or rectangular (line) selection. Double click 
      % inside the selection figure when it is ready.
      %
      % 'i' - invert selection.
      %  
      % 'e' - exclude selected objects or variables.
      %  
      % 'a' - add the selected excluded objects or variables back.
      %  
      % Combination 'Ctrl s' allows to save current plot as a file. Using arrows
      % allows to change current columns for X and Y axis.
      %


         fig = figure('Position', [100 100 800 600], 'Name', 'GUI tools for mdadata');
         p = DataPanel(fig, obj, {1, 1, 1, 'scatter'});
         set(fig, 'KeyPressFcn', @onKeyPress);


         function onKeyPress(src, event)
            p.onKeyPress(src, event);
         end   

      end
      
      function ind = inpolygon(obj, position)
      % 'inpolygon' returns indices of data points inside a polygon
      %
         if size(position, 1) > 2
            values = obj.valuesAll(:, 1:2);      
            ind = inpolygon(values(:, 1), values(:, 2), position(:, 1), position(:, 2));
         else
            ind = [];
         end      
      end
      
      function ind = inrect(obj, position)
      % 'inrect' returns indices of variables inside if at least one point is inside 
      %  a rectangle
      %

         ind = [];

         if numel(position) ~= 4
            return
         end

         obj.showExcludedCols
         if obj.showExcludedCols
            values = obj.valuesAll(:, ~obj.factorCols);
            nCols = obj.nNumColsAll;
         else   
            values = obj.numValues;
            nCols = obj.nNumCols;
         end

         x = [max(1, round(position(1))) min(round(position(1) + position(3)), nCols)];
         y = [round(position(2)) round(position(2) + position(4))];

         v = values(:, x(1):x(2));

         [~, c] = find(v >= y(1) & v <= y(2));
         i = unique(c) + x(1) - 1;   
         i = obj.getfullcolind(i, obj.showExcludedCols, false);

         ind = false(obj.nColsAll, 1);
         ind(i) = true;
         ind(obj.factorCols) = false;
      end 

   end
   
   methods (Static = true)
      [cmap, cgroup, args, isColorbar, colorbarTitle] = getplotcolorsettings(varargin)
      h = showcolorbar(cmap, cgroup, colorbarTitle, dx, dy)
      d = getsampledensity(x, y, nbins, smoothness, varargin)
      c = getmycolors(n)
      [args, varargin] = getgscatteroptions(nGroups, varargin)
      [args, varargin] = getgplotoptions(nGroups, varargin)      
      dens = quantizedens(dens)
      ind = reducerows(dens, factor)      
      [values, names] = cell2levels(v)            
      [values, names] = var2levels(v, varname)              
      h = showlabels(x, y, labels, position)      
      ind = parseind(ind, n, names, colnames, values); 
      showexcluded(ind, names)
      legend(varargin)
      readcsv(filename, varargin)
      readxls(filename, varargin)
      readspc(path, varargin)
   end
end

