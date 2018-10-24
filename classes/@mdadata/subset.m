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

   srowNames = {};
   srowFullNames = {};
   srowValues = [];

   scolNames = {};
   scolFullNames = {};
   scolValues = [];

   if ischar(row_ind) && strcmp(row_ind, ':')

      % subset with all rows - with excluded rows   
      col_ind = getfullcolind(obj, col_ind);                        
      svalues = obj.valuesAll(:, col_ind);
      sexcludedRows = find(obj.excludedRows);
      sexcludedCols = [];            
      srowNames = obj.rowNamesAll;
      srowFullNames = obj.rowFullNamesAll;
      srowValues = obj.rowValuesAll;

      if ~isempty(obj.colNamesAll)
         scolNames = obj.colNamesAll(col_ind);
         scolFullNames = obj.colFullNamesAll(col_ind);
      end

      if ~isempty(obj.colValuesAll)
         scolValues = obj.colValuesAll(col_ind);
      end

   elseif ischar(col_ind) && strcmp(col_ind, ':')
      % subset with all cols - with excluded cols  
      col_ind = 1:obj.nColsAll;            
      row_ind = getfullrowind(obj, row_ind);            

      svalues = obj.valuesAll(row_ind, :);
      scolNames = obj.colNamesAll;
      scolFullNames = obj.colFullNamesAll;
      scolValues = obj.colValuesAll;
      sexcludedCols = find(obj.excludedCols);
      sexcludedRows = [];

      if ~isempty(obj.rowNamesAll)
         srowNames = obj.rowNamesAll(row_ind);
         srowFullNames = obj.rowFullNamesAll(row_ind);
      end         

      if ~isempty(obj.rowValuesAll)
         srowValues = obj.rowValuesAll(row_ind);
      end

   else
      % partial subset for both rows and cols - no excluded data    
      col_ind = getfullcolind(obj, col_ind);   
      row_ind = getfullrowind(obj, row_ind);                        
      svalues = obj.valuesAll(row_ind, col_ind);
      sexcludedRows = [];
      sexcludedCols = [];

      if ~isempty(obj.colNamesAll)
         scolNames = obj.colNamesAll(col_ind);
         scolFullNames = obj.colFullNamesAll(col_ind);
      end   

      if ~isempty(obj.colValuesAll)
         scolValues = obj.colValuesAll(col_ind);
      end

      if ~isempty(obj.rowNamesAll)
         srowNames = obj.rowNamesAll(row_ind);
         srowFullNames = obj.rowFullNamesAll(row_ind);
      end

      if ~isempty(obj.rowValuesAll)
         srowValues = obj.rowValuesAll(row_ind);
      end

   end

   data = mdadata(svalues, srowNames, scolNames, obj.dimNames, obj.name);
   data.info = obj.info;
   data.colFullNamesAll = scolFullNames;
   data.rowFullNamesAll = srowFullNames;
   data.colValuesAll = scolValues;
   data.rowValuesAll = srowValues;

   objFactorCols = col_ind(ismember(col_ind, find(obj.factorCols)));
   dataFactorCols = find(obj.factorCols(col_ind));

   for i = 1:numel(dataFactorCols)
      objLevels = unique(values(:, objFactorCols(i)));
      dataLevels = unique(svalues(:, dataFactorCols(i)));

      levels = obj.factorLevelNames{objFactorCols(i)}(ismember(objLevels, dataLevels));

      data.factorCols(dataFactorCols(i)) = true;            
      data.factorLevelNames{dataFactorCols(i)} = levels;
   end

   data.excludecols(sexcludedCols);
   data.excluderows(sexcludedRows);

   data.showExcludedRows = obj.showExcludedRows;
   data.showExcludedCols = obj.showExcludedCols;

   varargout{1} = data;
end   

