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
% any operation is also an mdadata object.
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
%  'gscatter' - group version of scatter plot 
%  'gplot' - group version of line plot
%  'gbar' - group version for bar plot
%
%

   properties (Constant = true, Hidden = true)
      LEGEND_EDGE_COLOR = [0.2 0.2 0.2]
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
      colValuesAll      % numeric vector with column values used to make line plot
      rowValuesAll      % numeric vector with row values used to make line plot
   end
   
   properties (SetAccess = 'protected', Hidden = true, SetObservable = true)
      excludedRows      % vector with hidden (excluded) rows
      excludedCols      % vector with hidden (excluded) columns
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
      colValues         % numeric values for columns used for making line plots
      rowValues         % numeric values for columns used for making line plots
   end
   
   properties (Dependent = true, Hidden = true)
      factors           % factor values
      numValues         % get data values without factors
   end
   
   properties (Dependent = true, Hidden = true)
      valuesHidden      % values for excluded rows
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
      colValuesWithoutFactors % column values only for quantitative data
      colValuesAllWithoutFactors % column values only for quantitative data including hidden columns
   end
      
   methods
      
      %%% constructor 
      
      function obj = mdadata(values, rowNames, colNames, dimNames, name)
         % 'mdadata' creates an object of class 'mdadata'
         %

         if size(values, 1) == 0 || size(values, 2) == 0
            error('Argument "values" is an empty matrix!')
         end   
            
         if nargin < 5
            name = '';
         end
         
         if nargin < 4 || numel(dimNames) ~= 2
            dimNames = {'Objects', 'Variables'};
         end
         
         if nargin < 3 || numel(colNames) ~= size(values, 2)
            colNames = {};
         elseif ~(iscell(colNames) || isnumeric(colNames))   
             error('Column names should be either vector with numbers or cells!');   
         end
         
         if nargin < 2 || numel(rowNames) ~= size(values, 1)
            rowNames = {};
         elseif ~(iscell(rowNames) || isnumeric(rowNames))   
             error('Row names should be either vector with numbers or cells!');   
         end   
         
         % set data values 
         obj.valuesAll = double(values);
         
         % set names and axis values for columns
         obj.colNamesAll = colNames;
         obj.colFullNamesAll = colNames;
         obj.colValuesAll = colNames;
         
         % set names and axis values for rows
         obj.rowNamesAll = rowNames;
         obj.rowFullNamesAll = rowNames;
         obj.rowValuesAll = rowNames;
         
         % set other attribites
         obj.dimNames = dimNames; 
         obj.excludedRows = false(obj.nRowsAll, 1);
         obj.excludedCols = false(obj.nColsAll, 1);
         obj.factorCols = false(obj.nColsAll, 1);
         obj.factorLevelNames = cell(obj.nColsAll, 1);                  
         obj.name = name;
      end
      
      %%% getters and setters
      
      function out = get.values(obj) 
      % get matrix with non-hidden values 
         row_ind = ~obj.excludedRows;
         col_ind = ~obj.excludedCols;
         out = obj.valuesAll(row_ind, col_ind);
      end
      
      function out = get.factors(obj)         
      % get matrix with factor values   
         row_ind = ~obj.excludedRows;
         col_ind = ~(obj.excludedCols) & obj.factorCols;
         out = obj.valuesAll(row_ind, col_ind);
      end
      
      function out = get.numValues(obj)         
      % return matrix with numeric values (only non-hidden rows)   
         row_ind = ~obj.excludedRows;
         col_ind = ~(obj.excludedCols | obj.factorCols);
         out = obj.valuesAll(row_ind, col_ind);
      end
      
      function out = get.numValuesAll(obj)
      % return matrix with numeric values (including hidden rows)   
         col_ind = ~(obj.excludedCols | obj.factorCols);
         out = obj.valuesAll(:, col_ind);
      end
                        
      function out = get.nRows(obj)
      % return number of non-hidden rows
         out = obj.nRowsAll - sum(obj.excludedRows);
      end   
      
      function out = get.nCols(obj)
      % return number of non-hidden columns
         out = obj.nColsAll - sum(obj.excludedCols);
      end
      
      function out = get.nNumCols(obj)
      % return number of all numeric and non-hidden columns
         out = obj.nColsAll - sum(obj.excludedCols) - sum(obj.factorCols);
      end   
      
      function out = get.nColsAll(obj)
      % return number of all columns
         out = size(obj.valuesAll, 2);
      end
      
      function out = get.nNumColsAll(obj)
      % return number of all non-factor columns   
         out = size(obj.valuesAll, 2) - sum(obj.factorCols);
      end   
      
      function out = get.nRowsAll(obj)
      % return number of all rows
         out = size(obj.valuesAll, 1);
      end   
            
      function out = get.nFactors(obj)
      % return number of factor columns   
         out = sum(obj.factorCols(~obj.excludedCols));
      end      
      
      function out = get.valuesHidden(obj)
      % return matrix for hidden rows and non-hidden columns
         row_ind = obj.excludedRows;
         col_ind = ~obj.excludedCols;
         out = obj.valuesAll(row_ind, col_ind);      
      end
                           
      function out = get.colNames(obj)         
      % return names for all non-hidden columns
         out = obj.colNamesAll;         
         if ~isempty(out)
            out(obj.excludedCols) = [];
         end   
      end
      
      function out = get.colValues(obj)
      % return column values (x-axis values)   
         out = obj.colValuesAll;         
         if ~isempty(out)
            out(obj.excludedCols) = [];
         end   
      end
      
      function out = get.rowValues(obj)
      % return row values (y-axis values)   
         out = obj.rowValuesAll;         
         if ~isempty(out)
            out(obj.excludedRows) = [];
         end   
      end
      
      function out = get.colFullNamesAll(obj)
      % return full names for all non-hidden columns   
         if isempty(obj.colFullNamesAll)
            out = obj.colNamesAll;
         else
            out = obj.colFullNamesAll;
         end         
      end
      
      function out = get.colFullNames(obj)
      % return full names for all non-hidden columns   
         if isempty(obj.colFullNamesAll)
            out = obj.colNamesAll;
         else
            out = obj.colFullNamesAll;
         end         
         if ~isempty(out)
            out(obj.excludedCols) = [];
         end   
      end
      
      function out = get.factorNames(obj)
      % return names for factor columns 
         out = obj.colNamesAll;   
         if ~isempty(out)
            out(~obj.factorCols | obj.excludedCols) = [];
         end         
      end
      
      function out = get.factorFullNames(obj)
      % return full names for columns
         out = obj.colFullNamesAll;         
         if ~isempty(out)
            out(~obj.factorCols | obj.excludedCols) = [];
         end         
      end
      
      function out = get.colNamesWithoutFactors(obj)
      % return column names for all non-factor columns
         out = obj.colNamesAll;         
         if ~isempty(out) 
            out(obj.factorCols | obj.excludedCols) = [];
         end   
      end
      
      function out = get.colValuesWithoutFactors(obj)
      % return column values (xaxis values) for non-hidden non-factor columns   
         out = obj.colValuesAll;         
         if ~isempty(out) 
            out(obj.factorCols | obj.excludedCols) = [];
         end   
      end
      
      function out = get.colNamesAllWithoutFactors(obj)
      % return column names for all non-factor columns            
         out = obj.colNamesAll;         
         if ~isempty(out) 
            out(obj.factorCols) = [];
         end   
      end
      
      function out = get.colValuesAllWithoutFactors(obj)
      % return column values (xaxis values) for all non-factor columns   
         out = obj.colValuesAll;         
         if ~isempty(out) 
            out(obj.factorCols) = [];
         end   
      end
      
      function out = get.colFullNamesWithoutFactors(obj)
      % return column fll names for non-hidden non-factor columns   
         out = obj.colFullNamesAll;         
         if ~isempty(out) 
            out(obj.factorCols | obj.excludedCols) = [];
         end   
      end
      
      function out = get.colFullNamesAllWithoutFactors(obj)
      % return column fll names for all non-factor columns   
         out = obj.colFullNamesAll;         
         if ~isempty(out) 
            out(obj.factorCols) = [];
         end   
      end
      
      function out = get.rowNames(obj)
      % return names for non-hidden rows 
         out = obj.rowNamesAll;         
         if ~isempty(out)
            out(obj.excludedRows) = [];
         end   
      end
      
      function out = get.rowFullNames (obj)
      % return full names for non-hidden rows
         out = obj.rowFullNamesAll;         
         if ~isempty(out)
            out(obj.excludedRows) = [];
         end   
      end
      
      function out = get.rowFullNamesAll(obj)
      % return full names for all non-hidden rows   
         if isempty(obj.rowFullNamesAll)
            out = obj.rowNamesAll;
         else
            out = obj.rowFullNamesAll;
         end         
      end
      
      %%% setters
      
      function set.colValuesAll(obj, colValues)         
      % set values for columns (x-axis values)
         if isempty(colValues) || ~isnumeric(colValues)
            obj.colValuesAll = [];
         else
            obj.colValuesAll = colValues;
         end
      end
      
      function set.colNames(obj, colNames)
         obj.colNamesAll = colNames;
         obj.colFullNamesAll = colNames;
         if isnumeric(colNames)
            obj.colValuesAll = colNames;
         end
      end
         
      function set.colNamesAll(obj, colNames)         
      % set names for all column names            
         
         if isempty(colNames) 
            obj.colNamesAll = {};
            return
         end
         
         if iscell(colNames) && ischar(colNames{1})
         % remove all symbols which are non letter nor numbers
         % merge words and capitalise them
            for i = 1:numel(colNames)
               %a = regexp(colNames{i}, '[^A-Za-z0-9\.\-\s]', 'split');
               %a = regexp(strtrim(a{1}), '\s', 'split');
               %a = cellfun(@(x)([upper(x(1)) x(2:end)]), a, 'UniformOutput', false);
               %colNames{i} = sprintf('%s', a{:});
               colNames{i} = regexprep(colNames{i}, '[^A-Za-z0-9\.\-]', '');
            end
         end
            
         if numel(unique(colNames)) ~= numel(colNames)
            error('Column names must be unique!')
         elseif isnumeric(colNames)
            obj.colNamesAll = textgen('', colNames);
         elseif iscell(colNames) && ischar([colNames{:}])
            obj.colNamesAll = colNames;
         else
            error('Values for "colNames" argument must be either numeric or cell array with text!');
         end   
      end
      
      function set.colFullNamesAll(obj, colNames)
      % set full names for columns
         if isempty(colNames)
            obj.colFullNamesAll = {};
         else
            if numel(unique(colNames)) ~= numel(colNames)
               error('Column names must be unique!')
            elseif isnumeric(colNames)
               obj.colFullNamesAll = textgen('', colNames);
            elseif iscell(colNames) && ischar([colNames{:}])
               obj.colFullNamesAll = colNames;
            else
               error('Values for "colNames" argument must be either numeric or cell array with text!');
            end
         end
      end
            
      function set.rowValuesAll(obj, rowValues)         
      % set axis values for rows (y-axis values)
         if isempty(rowValues) || ~isnumeric(rowValues)
            obj.rowValuesAll = [];
         else
            obj.rowValuesAll = rowValues;
         end
      end
      
      function set.rowNames(obj, rowNames)
         obj.rowNamesAll = rowNames;
         obj.rowFullNamesAll = rowNames;
         if isnumeric(rowNames)
            obj.rowValuesAll = rowNames;
         end
      end
      
      function set.rowNamesAll(obj, rowNames)         
      % set names for all column names            
         
         if isempty(rowNames) 
            obj.rowNamesAll = {};
            return
         end
         
         if iscell(rowNames) && ischar(rowNames{1})
         % remove all symbols which are non letter nor numbers
         % merge words and capitalise them
            for i = 1:numel(rowNames)
               %a = regexp(colNames{i}, '[^A-Za-z0-9\.\-\s]', 'split');
               %a = regexp(strtrim(a{1}), '\s', 'split');
               %a = cellfun(@(x)([upper(x(1)) x(2:end)]), a, 'UniformOutput', false);
               %colNames{i} = sprintf('%s', a{:});
               rowNames{i} = regexprep(rowNames{i}, '[^A-Za-z0-9\.\-]', '');
            end
         end
            
         if numel(unique(rowNames)) ~= numel(rowNames)
            error('Row names must be unique!')
         elseif isnumeric(rowNames)
            obj.rowNamesAll = textgen('', rowNames);
         elseif iscell(rowNames) && ischar([rowNames{:}])
            obj.rowNamesAll = rowNames;
         else
            error('Values for "rowNames" argument must be either numeric or cell array with text!');
         end   
      end
      
      function set.rowFullNamesAll(obj, rowNames)
         if isempty(rowNames)
            obj.rowFullNamesAll = {};
         else
            if numel(unique(rowNames)) ~= numel(rowNames)
               error('Row names must be unique!')
            elseif isnumeric(rowNames)
               obj.rowFullNamesAll = textgen('', rowNames);
            elseif iscell(rowNames) && ischar([rowNames{:}])
               obj.rowFullNamesAll = rowNames;
            else
               error('Values for "rowNames" argument must be either numeric or cell array with text!');
            end   
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
      
      %%% extra getters for column and row labels
      
      function labels = getRowLabels(obj, ind)
      % return row labels for selected (or all) rows
      
         if ~isempty(obj.rowNamesAll)
            labels = obj.rowFullNames;
         elseif ~isempty(obj.rowValuesAll)
            labels = textgen('', obj.rowValues);
         else
            labels = textgen('', 1:obj.nRows);
         end
         
         if nargin == 2
            labels = labels(ind);
         end
      end
      
      function labels = getColLabels(obj, ind)
      % return column labels for selected (or all) columns
      
         if ~isempty(obj.colNamesAll)
            labels = obj.colFullNames;
         elseif ~isempty(obj.colValuesAll)
            labels = textgen('', obj.colValues);
         else
            labels = textgen('', 1:obj.nCols);
         end
         
         if nargin == 2
            labels = labels(ind);
         end
      end
           
      %%% methods for including/excluding/removing values and variables
      
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
         
         if ~isempty(obj.colValuesAll)
            obj.colValuesAll(ind) = [];
         end
         
         if ~isempty(obj.colNamesAll)
            obj.colNamesAll = obj.colNamesAll(~ind);
            obj.colFullNamesAll = fullNames(~ind);      
         end
         
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
         
         if ~isempty(obj.rowValuesAll)
            obj.rowValuesAll(ind) = [];
         end
         
         if ~isempty(obj.rowNamesAll)
            obj.rowNamesAll(ind) = [];
            obj.rowFullNamesAll(ind) = [];            
         end
         
         obj.excludedRows(ind) = [];
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
         
         if size(levelNames, 1) < size(levelNames, 2)
            levelNames = levelNames';
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
         
         subValues = obj.valuesAll(:, ind);
         levels = unique(subValues);
         levelNames = obj.factorLevelNames{ind};
         nlevels = numel(levels);
         
         newvalues = zeros(size(subValues, 1), nlevels);
         
         for i = 1:nlevels
            newvalues(:, i) = (subValues == levels(i)) * 2 - 1;
         end
         
         out = mdadata(newvalues, obj.rowNamesAll, levelNames, {obj.dimNames{1} obj.getColLabels{ind}});
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
         
         subValuesAll = obj.valuesAll(:, ~obj.excludedCols);
         subValuesAll = subValuesAll(:, ind);
         nFactorCols = numel(ind);
         
         if ~isempty(obj.colNames)
            gColNames = obj.colNames(ind);
         else
            gColNames = textgen('X', 1:nFactorCols);
         end
         
         
         % get factor values as level indices (1, 2, 3)
         subValues = zeros(obj.nRowsAll, nFactorCols);
         for i = 1:numel(ind)             
            [~, ~, subValues(:, i)] = unique(subValuesAll(:, i));
         end   
         subValues = subValues(~obj.excludedRows, :);
         
         % get factor values as names
         levelNames = obj.factorLevelNames(ind);
         nlevels = cellfun(@(x)(numel(unique(x))), num2cell(subValues, 1));
         
         % set up a vector with level sequences for each factor
         arg = cell(nFactorCols, 1);
         for i = 1:nFactorCols
            arg{i} = 1:nlevels(i);
         end   
         
         % get all possible combinations of levels
         comb = allcomb(arg{:});
         
         % for each combination get vector of logical values for rows
         nComb = size(comb, 1);
         groups = zeros(obj.nRows, nComb);
         fullNames = cell(nComb, 1);
         shortNames = cell(nComb, 1);
         for i = 1:nComb
            levels = unique(subValues(:, 1));
            ind = levels(comb(i, 1));
            v = subValues(:, 1) == ind;
            fullName = [levelNames{1}{ind}];
            shortName = [levelNames{1}{ind}];
            for j = 2:nFactorCols
               levelsj = unique(subValues(:, j));               
               indj = levelsj(comb(i, j));
               v = v & subValues(:, j) == indj;               
               fullName = [fullName ', ' levelNames{j}{indj}];
               shortName = [shortName levelNames{j}{indj}];
            end   
            fullNames{i} = fullName;
            shortNames{i} = shortName;
            groups(:, i) = v;
         end   
         dimName = sprintf('%s, ', gColNames{:});
         dimName = ['Groups (' dimName(1:end-2) ')'];
         groups = mdadata(groups, obj.rowNames, {}, {obj.dimNames{1}, dimName});
         groups.colNamesAll = fullNames;
         
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
            newColNames = a.colNamesWithoutFactors;
            newColFullNames = a.colFullNamesWithoutFactors;
         else
            if ~isa(b, 'mdadata')
               b = mdadata(b);
            end
            newColNames = b.colNamesWithoutFactors;
            newColFullNames = b.colFullNamesWithoutFactors;
         end   
         out = op(a, b, @mtimes, a.rowNames, a.rowFullNames , newColNames, newColFullNames);         
      end
      
      function out = rdivide(a, b)
         out = op(a, b, @rdivide);
      end
      
      function out = mrdivide(a, b)
         if isscalar(a)
            newColFullNames = b.colFullNamesWithoutFactors;
            newColNames = b.colNamesWithoutFactors;
            newColValues = b.colValues;
            newRowFullNames = b.rowFullNames;
            newRowNames = b.rowNames;
            newColValues = b.rowValues;
         elseif isscalar(b)
            newColFullNames = a.colFullNamesWithoutFactors;
            newColNames = a.colNamesWithoutFactors;
            newColValues = a.colValues;
            newRowFullNames = a.rowFullNames;
            newRowNames = a.rowNames;
            newRowValues = a.rowValues;
         else
            newRowFullNames = a.rowFullNames;
            newRowNames = a.rowNames;
            newRowValues = a.rowValues;
            newColFullNames = b.rowFullNames;
            newColNames = b.rowNames;
            newColValues = b.rowValues;
         end   
         out = op(a, b, @mrdivide, newRowNames, newRowFullNames , newColNames, newColFullNames);
         out.colValuesAll = newColValues;
         out.rowValuesAll = newRowValues;
      end
      
      function out = ldivide(a, b)
         out = op(a, b, @ldivide);
      end
      
      function out = bsxfun(a, b, fun)
         out = mdadata(bsxfun(fun, a.numValues, b.numValues), a.rowNames, a.colNamesWithoutFactors,...
            a.dimNames, a.name);
         
         if ~isempty(a.colFullNamesAll)
            out.colFullNames = a.colFullNamesAll(~a.factorCols & ~a.excludedCols);
         end
         
         if ~isempty(a.rowFullNames)
            out.rowFullNames = a.rowFullNames;
         end
      end
       
      function out = mldivide(a, b)
         out = op(a, b, @mldivide, a.colNames, a.colFullNames, b.colNamesWithoutFactors, ...
            b.colFullNamesWithoutFactors);
         out.rowValuesAll = a.colValues;
         out.colValuesAll = b.colValues;
         out.dimNames = {'Coefficients', 'Variables'};
      end
                 
      function out = ctranspose(a)
         out = mdadata(ctranspose(a.numValues), a.colNamesWithoutFactors, a.rowNames, a.dimNames(end:-1:1));
         out.name = a.name;
         out.info = a.info;
         out.colNamesAll = a.rowNames;
         out.colFullNamesAll = a.rowFullNames;
         out.colValuesAll = a.rowValues;
         out.rowNamesAll = a.colFullNamesWithoutFactors;
         out.rowFullNamesAll = a.colFullNamesWithoutFactors;
         out.rowValuesAll = a.colValuesAllWithoutFactors;
      end
      
      function out = horzcat(a, varargin)
      % horizontal concatenation is made only for non-hidden rows and columns   
         out = copy(a);       
         
         for i = 1:numel(varargin)
            b = varargin{i};
            
            if ~isempty(out.colNames) && ~isempty(b.colNames)
               if any(ismember(out.colFullNames, b.colFullNames))
                  newColNames = [out.colNames, strcat('V', b.colNames)];
                  newColFullNames = [out.colFullNames, strcat('V', b.colFullNames)];
               else
                  newColNames = [out.colNames, b.colNames];
                  newColFullNames = [out.colFullNames, b.colFullNames];
               end   
            else
               newColNames = {};
               newColFullNames = {};
            end

            if ~isempty(out.colValues) && ~isempty(b.colValues)
               newColValues = [out.colValues, b.colValues];
            else   
               newColValues = [];
            end
            
            newFactorCols = [out.factorCols; b.factorCols];
            newFactorLevelNames = [out.factorLevelNames; b.factorLevelNames];    
            out = op(out, b, @horzcat, out.rowNames, out.rowFullNames , newColNames,...
               newColFullNames, out.dimNames, true);
            out.factorCols = newFactorCols;
            out.factorLevelNames = newFactorLevelNames;
            out.colValuesAll = newColValues;            
         end   
         
         out.rowValuesAll = a.rowValues;                  
      end
      
      function out = vertcat(a, varargin)
      % vertical concatenation is made only for non-hidden rows and columns   

        out = copy(a);       
        outExcludedRows = out.excludedRows;
        out.includerows(outExcludedRows);
        
        fCols = out.factorCols;
        fColsInd = find(fCols);
        fln = out.factorLevelNames';
        flv = cellfun(@unique, num2cell(out.values, 1), 'UniformOutput', false);
        
        for i = 1:numel(varargin)            
           b = copy(varargin{i});
           outExcludedRows = [outExcludedRows; b.excludedRows];
           b.includerows(b.excludedRows);
            
            % check factor columns
            bf = find(b.factorCols);            
            if ~all(fColsInd == bf)
               error('Factor columns in data "a" should correspond to factor columns in data "b"!')
            else
                fln = [fln; b.factorLevelNames'];
                flv = [flv; cellfun(@unique, num2cell(b.values, 1), 'UniformOutput', false)];
            end
            
            % add "O" to row names if they are not unique
            if ~isempty(out.rowNames) && ~isempty(b.rowNames)
               if sum(ismember(out.rowNames, b.rowNames)) > 0
                  newRowNames = [out.rowNames(:); strcat('O', b.rowNames(:))];
                  newRowFullNames = [out.rowFullNames(:); strcat('O', b.rowFullNames(:) )];
               else
                  newRowNames = [out.rowNames(:); b.rowNames(:)];
                  newRowFullNames = [out.rowFullNames(:); b.rowFullNames(:)];
               end
            else
               newRowNames = {};
               newRowFullNames = {};
            end
            
            % make correct row values
            if ~isempty(out.rowValues) && ~isempty(b.rowValues)
               newRowValues = [out.rowValues, b.rowValues];
            else   
               newRowValues = [];
            end
                        
            % merge datasets
            out = op(out, b, @vertcat, newRowNames, newRowFullNames, out.colNames, ...
               out.colFullNames, out.dimNames, true);
            out.rowValuesAll = newRowValues;
        end
        
        out.colValuesAll = a.colValues;                  
        out.excluderows(outExcludedRows);        
        out.factorCols = fCols;
        
        % process all factors
        for i = 1:numel(fColsInd)
            % concatenate level names and keep only unique in the same
            % order as they were added in
            ln = vertcat(fln{:, fColsInd(i)});            
            ln = unique(ln(:), 'stable'); 
            
            % concatenate level values and keep only unique in the same
            % order as they were added in
            lv = vertcat(flv{:, fColsInd(i)});
            lv = unique(lv(:), 'stable');
            if numel(lv) ~= numel(ln)
                error('Number of levels does not correspond to number of level names!');
            end
            
            % sort level values and resort names accordingly            
            [~, ind] = sort(lv);
            out.factorLevelNames{fColsInd(i)} = ln(ind);
         end         
      end
      
      function out = power(a, b)
      % power of dataset and scalar   
         out = op(a, b, @power);         
         out.valuesAll = double(out.valuesAll);
      end
      
      function out = log(a)
      % natural logarithm for every element of dataset   
         out = op(a, [], @log);         
         out.valuesAll = double(out.valuesAll);
      end
      
      function out = sqrt(a)
      % square root for every element of dataset   
         out = op(a, [], @sqrt);         
         out.valuesAll = double(out.valuesAll);
      end
      
      function out = abs(a)
      % absolute value for every element of dataset   
         out = op(a, [], @abs);         
      end
      
      function out = exp(a)         
         out = op(a, [], @exp);         
      end
      
      function out = round(a)
         out = op(a, [], @round);         
      end

      function out = op(a, b, fun, rowNames, rowFullNames , colNames, colFullNames, dimNames, ...
            useAllValues)
      % 'op' a general function for arithmetic operations with mdadata
      %
         outRowValues = [];
         outColValues = [];
         
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
            outColValues = a.colValues;
         end
         
         if nargin < 6
            colNames = a.colNamesWithoutFactors; 
            outColValues = a.colValues;
         end

         if nargin < 5
            rowFullNames = a.rowFullNames;
            outRowValues = a.rowValues;
         end
         
         if nargin < 4
            rowNames = a.rowNames;
            outRowValues = a.rowValues;
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
            out.colFullNamesAll = colFullNames;
         end   
         
         if ~isempty(rowFullNames)
            out.rowFullNamesAll = rowFullNames;
         end   
         
         if ~isempty(outRowValues)
            out.rowValuesAll = outRowValues;
         end
         
         if ~isempty(outColValues)
            out.colValuesAll = outColValues;
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
      % 'var' calculates variance for each column of dataset.
      %
      %   s2 = var(data);
      %   s2 = var(data, factors);
      %
      %
      % By default, method calculates variance for each column of the
      % 'data' object. If a dataset with factors is also provided the
      % method will calculate the variance for columns by splitting 
      % data rows into groups, corresponded to all possible combination 
      % of the factors.
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
      
         groups = [];
         if numel(varargin) > 0 && isa(varargin{1}, 'mdadata')
            groups = varargin{1};
            varargin(1) = [];
         end
      
         if isempty(varargin)
            varargin{1} = 0;
            varargin{2} = 1;
         elseif numel(varargin) > 0
            varargin{2} = 1;
         end   

         out = stat(obj, groups, @var, 'Variance', varargin{:});
      end
      
      function out = cov(obj)
      % 'cov' calculates covariance matrix for all pairwise combinations of columns.
      %
      %   c = cov(data);
      %
         
         out = op(obj, [], @cov, obj.colNamesWithoutFactors, obj.colFullNamesWithoutFactors,...
            obj.colNamesWithoutFactors, obj.colFullNamesWithoutFactors);         
         out.colValuesAll = obj.colValuesWithoutFactors;
         out.rowValuesAll = [];
         out.dimNames = {'Variables', 'Variables'};
         out.name = 'Covariance';
      end
      
      function out = corr(obj, varargin)
      % 'corr' calculates correlation matrix for all pairwise combinations of columns.
      %
      %   r = corr(data);
      %
      
         %TODO: add calculation of confidence intervals and p-values
         out = op(obj, [], @mdacorr, obj.colNamesWithoutFactors, obj.colFullNamesWithoutFactors,...
            obj.colNamesWithoutFactors, obj.colFullNamesWithoutFactors);         
         out.colValuesAll = obj.colValuesWithoutFactors;
         out.rowValuesAll = [];
         out.dimNames = {'Variables', 'Variables'};
         out.name = 'Correlation';
      end
                  
      function out = mean(obj, varargin)
      % 'mean' calculates average value for each column of dataset.
      %
      %    m = mean(data);
      %    m = mean(data, factors);
      %
      %
      % By default, method calculates mean value for each column of the
      % 'data' object. If a dataset with factors is also provided the
      % method will calculate the mean value for columns by splitting 
      % data rows into groups, corresponded to all possible combination 
      % of the factors.
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
      
         groups = [];
         if numel(varargin) > 0 && isa(varargin{1}, 'mdadata')
            groups = varargin{1};
            varargin(1) = [];
         end
      
         out = stat(obj, groups, @mean, 'Mean');
      end
      
      function out = std(obj, varargin)
      % 'std' calculates standard deviation for each column of dataset.
      %
      %    s = std(data);
      %    s = std(data, factors);
      %
      %
      % By default, method calculates std value for each column of the
      % 'data' object. If a dataset with factors is also provided the
      % method will calculate the std value for columns by splitting 
      % data rows into groups, corresponded to all possible combination 
      % of the factors.
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
      
         groups = [];
         if numel(varargin) > 0 && isa(varargin{1}, 'mdadata')
            groups = varargin{1};
            varargin(1) = [];
         end
      
         if isempty(varargin)
            varargin{1} = 0;
            varargin{2} = 1;
         elseif numel(varargin) > 0
            varargin{2} = 1;
         end   

         out = stat(obj, groups, @std, 'Std', varargin{:});
      end
      
      function out = se(obj, varargin)
      % 'se' calculates standard error of mean for each column of dataset.
      %
      %   s = se(data);
      %   s = se(data, factors);
      %
      %
      % By default, method calculates the se value for each column of the
      % 'data' object. If a dataset with factors is also provided the
      % method will calculate the se value for columns by splitting 
      % data rows into groups, corresponded to all possible combination 
      % of the factors.
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
      
         groups = [];
         if numel(varargin) > 0 && isa(varargin{1}, 'mdadata')
            groups = varargin{1};
            varargin(1) = [];
         end
         
         out = stat(obj, groups, @mdase, 'Std. error');
      end
      
      function out = min(obj, varargin)
      % 'min' calculates minimal value for each column of dataset.
      %
      %   mn = min(data);
      %   mn = min(data, factors);
      %
      %
      % By default, method calculates min value for each column of the
      % 'data' object. If a dataset with factors is also provided the
      % method will calculate the min value for columns by splitting 
      % data rows into groups, corresponded to all possible combination 
      % of the factors.
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
      
         groups = [];
         if numel(varargin) > 0 && isa(varargin{1}, 'mdadata')
            groups = varargin{1};
            varargin(1) = [];
         end
      
         varargin{1} = [];
         varargin{2} = 1;
      
         out = stat(obj, groups, @min, 'Min', varargin{:});
      end
      
      function out = max(obj, varargin)
      % 'max' calculates maximal value for each column of dataset.
      %
      %   mx = max(data);
      %   mx = max(data, factors);
      %
      %
      % By default, method calculates max value for each column of the
      % 'data' object. If a dataset with factors is also provided the
      % method will calculate the max value for columns by splitting 
      % data rows into groups, corresponded to all possible combination 
      % of the factors.
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
      
         groups = [];
         if numel(varargin) > 0 && isa(varargin{1}, 'mdadata')
            groups = varargin{1};
            varargin(1) = [];
         end
      
         varargin{1} = [];
         varargin{2} = 1;
      
         out = stat(obj, groups, @max, 'Max', varargin{:});
      end
                  
      function out = median(obj, varargin)
      % 'median' calculates median value for each column of dataset.
      %
      %   md = median(data);
      %   md = median(data, factors);
      %
      %
      % By default, method calculates median value for each column of the
      % 'data' object. If a dataset with factors is also provided the
      % method will calculate the median value for columns by splitting 
      % data rows into groups, corresponded to all possible combination 
      % of the factors.
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
      
         groups = [];
         if numel(varargin) > 0 && isa(varargin{1}, 'mdadata')
            groups = varargin{1};
            varargin(1) = [];
         end
      
         out = stat(obj, groups, @median, 'Median');
      end
      
      function out = sum(obj, varargin)
      % 'sum' calculates the sum of values in each column of dataset.
      %
      %   s = sum(data);
      %   s = sum(data, factors);
      %
      %
      % By default, method calculates sum value for each column of the
      % 'data' object. If a dataset with factors is also provided the
      % method will calculate the sum value for columns by splitting 
      % data rows into groups, corresponded to all possible combination 
      % of the factors.
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
      
         groups = [];
         if numel(varargin) > 0 && isa(varargin{1}, 'mdadata')
            groups = varargin{1};
            varargin(1) = [];
         end
            
         out = stat(obj, groups, @sum, 'Sum');
      end
      
      function out = percentile(obj, varargin)
      % 'percentile' calculates n-th percentile for each column of dataset.
      % 
      %   p = percentile(data, n); 
      %   p = percentile(data, factors, n);
      %
      %
      % By default, method calculates percentile for each column of the
      % 'data' object. If a dataset with factors is also provided the
      % method will calculate the percentile for columns by splitting 
      % data rows into groups, corresponded to all possible combination 
      % of the factors.
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
      
         groups = [];
         if numel(varargin) > 0 && isa(varargin{1}, 'mdadata')
            groups = varargin{1};
            varargin(1) = [];
         end
      
         if numel(varargin) == 0
            error('Specify which percentile should be calculated!')
         else
            if ~isnumeric(varargin{1}) 
               error('Specify which percentile should be calculated!')
            else   
               n = varargin{1};
            end   
         end
         
         rowNames = textgen('', n, '%%');
         out = stat(obj, groups, @mdapercentile, 'Percentiles', rowNames, n);
      end
      
      function out = summary(obj, varargin)
      % 'summary' calculates summary statistics for each column of dataset.
      %
      %   s = summary(data);
      %
      % The statistics include min, max, mean, median, first and third
      % quartiles.
      %
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
      %
                     
         out = [min(obj); percentile(obj, 25); median(obj);...
            mean(obj); percentile(obj, 75); max(obj)];
         out.rowNames = {'Min', 'Q1', 'Median', 'Mean', 'Q3', 'Max'};
         
         if isempty(obj.name)
            out.name = 'Summary statistics' ;
         else   
            out.name = ['Summary statistics for ' obj.name];
         end   
      end
      
      function out = ci(obj, varargin)
      % 'ci' calculates confidence interval using Student's t-distribution either 
      % for each column of dataset.
      %
      %   s = ci(data);
      %   s = ci(data, alpha);
      %   s = ci(data, factors);
      %   s = ci(data, factors, alpha);
      %
      %
      % By default, method calculates intervals for each column of the
      % 'data' object. If a dataset with factors is also provided the
      % method will calculate the intervals for columns by splitting 
      % data rows into groups, corresponded to all possible combination 
      % of the factors.
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
      
         groups = [];
         if numel(varargin) > 0 && isa(varargin{1}, 'mdadata')
            groups = varargin{1};
            varargin(1) = [];
         end
      
         alpha = 0.05;
         if numel(varargin) > 0
            alpha = varargin{1};
         end
         
         out = stat(obj, groups, @mdaci, ...
                  sprintf('Confidence intervals (%.0f%%)', 100 * (1 - alpha)), {'Lower', 'Upper'}, ...
                  alpha);
      end
      
      function out = ttest(obj, varargin)
      % 'ttest' calculates one-sample t-test p-value for each column of dataset.
      %
      %   p = ttest(data);
      %   p = ttest(data, mu);
      %   p = ttest(data, factors);
      %   p = ttest(data, factors, mu);
      %
      %
      % By default, method calculates p-value for each column of the
      % 'data' object. If a dataset with factors is also provided the
      % method will calculate the p-value for columns by splitting 
      % data rows into groups, corresponded to all possible combination 
      % of the factors.
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
      
         groups = [];
         if numel(varargin) > 0 && isa(varargin{1}, 'mdadata')
            groups = varargin{1};
            varargin(1) = [];
         end
      
         mu = 0;
         if numel(varargin) > 0 && isnumeric(varargin{1})
            mu = varargin{1};
         end
         
         if numel(mu) > 1
            error('Argument "mu" should have one value!')
         end
         
         out = stat(obj, groups, @mdattest, sprintf('P-values (mu = %s)', num2str(mu, 3)), ...
            {'Left tail', 'Both tails', 'Right tail'}, mu);
      end
                  
      function out = stat(obj, groups, fun, name, varargin)         
         if nargin < 4
            name = '';
         end
         
         outRowNames = [];
         if isempty(varargin)
            varargin{1} = 1;
         elseif iscell(varargin{1})
            outRowNames = varargin{1};
            varargin(1) = [];
         end
                  
         if isempty(groups)
            if isempty(outRowNames)
               outRowNames = {name};
            end   
            out = mdadata(fun(obj.numValues, varargin{:}), outRowNames, ...
               obj.colFullNamesWithoutFactors, ...
               {'Statistics', obj.dimNames{2}}, obj.name); 
            out.rowValuesAll = [];
            out.colValuesAll = obj.colValuesWithoutFactors;
         else
            groups = groups.getgroups();
            locValues = obj.numValues;
            out = [];
            
            for i = 1:groups.nCols
               f = fun(locValues(groups.values(:, i) == 1, :), varargin{:});
               out = [out; f];
            end
            
            if isempty(name)
               name = [obj.name];
            elseif ~isempty(obj.name)
               name = [name ' for ' obj.name];
            end
            
            if isempty(outRowNames)
               orowNames = groups.colNames;
               orowFullNames = groups.colFullNames;
            else
               nNames = numel(outRowNames);
               outRowNames = repmat(outRowNames, 1, groups.nCols);
               
               gcolNames = groups.colNames(:)';
               gcolNames = repmat(gcolNames, nNames, 1);
               gcolNames = gcolNames(:)';
               
               gcolFullNames = groups.colFullNames(:)';
               gcolFullNames = repmat(gcolFullNames, nNames, 1);
               gcolFullNames = gcolFullNames(:)';

               orowNames = cellfun(@(x, y) [x  '-' y], outRowNames, gcolNames, 'un', 0);
               orowFullNames = cellfun(@(x, y) [x  ' ' y], outRowNames, gcolFullNames, 'un', 0);
            end   
            out = mdadata(out, orowNames, obj.colNamesWithoutFactors, ...
               {groups.dimNames{2}, obj.dimNames{2}}, name); 
            out.rowFullNamesAll = orowFullNames;
            out.colFullNamesAll = obj.colFullNamesWithoutFactors;
            out.rowValuesAll = [];
            out.colValuesAll = obj.colValuesWithoutFactors;
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
         out.rowFullNamesAll = {'Freq', 'Rel. Freq', sprintf('Lower (%d%%)', round((1 - alpha)*100)),...
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
         row_ind = ~ind2bool(obj.excludedRows, obj.nRowsAll);
         col_ind = ~ind2bool(obj.excludedCols, obj.nColsAll);
         obj.valuesAll(row_ind, col_ind) = val;
         
         if ~isempty(obj.rowNames)
            obj.rowNamesAll(row_ind) = obj.rowNames(ind);
            obj.rowFullNamesAll(row_ind) = obj.rowFullNames(ind);
         end   
         
         if nargout > 0
            varargout{1} = 1;
         end   
      end
      
   end
   
   methods (Static = true)
      [cmap, cgroup, args, isColorbar, colorbarTitle, cgroupLevels] = getplotcolorsettings(varargin)
      h = showcolorbar(cmap, cgroup, colorbarTitle, dx, dy, cgroupLevels)
      d = getsampledensity(x, y, nbins, smoothness, varargin)
      c = getmycolors(n)
      [args, varargin] = getgscatteroptions(nGroups, varargin)
      [args, varargin] = getgplotoptions(nGroups, varargin)      
      dens = quantizedens(dens)
      ind = reducerows(dens, factor)      
      [values, names] = cell2levels(v)            
      [values, names] = var2levels(v, varname)              
      h = showlabels(x, y, labels, position, c)      
      ind = parseind(ind, n, names, colnames, values); 
      showexcluded(ind, names)
      legend(varargin)
      readcsv(filename, varargin)
      readxls(filename, varargin)
      readspc(path, varargin)
   end
end

