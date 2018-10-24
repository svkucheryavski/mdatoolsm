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
               
               if ~isempty(obj.colNamesAll)
                  outColNames = obj.colNamesAll;
                  outColFullNames = obj.colFullNamesAll;
                  outColNames(col_ind) = b;
                  outColFullNames(col_ind) = b;
                  obj.colNamesAll = outColNames;
                  obj.colFullNamesAll = outColFullNames;
               end
            elseif strcmp(s(2).subs, 'colFullNames') && ~isempty(obj.colFullNamesAll)
               if ~iscell(b) && ischar(b)
                  b = {b};
               end   
               
               if numel(b) ~= numel(col_ind)
                  error('Subscripted assignment dimension mismatch!');
               elseif ~iscell(b) || ~ischar(b{1})    
                  error('Cell array with text values must be used as names!')
               end
               
               outColFullNames = obj.colFullNamesAll;
               outColFullNames(col_ind) = b;
               obj.colFullNamesAll = outColFullNames;
            elseif strcmp(s(2).subs, 'rowNames')
               if ~iscell(b) && ischar(b)
                  b = {b};
               end   
               
               if numel(b) ~= numel(row_ind)
                  error('Subscripted assignment dimension mismatch!');
               elseif ~iscell(b) || ~ischar(b{1})    
                  error('Cell array with text values must be used as names!')
               end
               
               if ~isempty(obj.rowNamesAll)
                  outRowNames = obj.rowNamesAll;
                  outRowFullNames = obj.rowFullNamesAll ;
                  outRowNames(row_ind) = b;
                  outRowFullNames(row_ind) = b;
                  obj.rowNamesAll = outRowNames;
                  obj.rowFullNamesAll = outRowFullNames;
               end
            elseif strcmp(s(2).subs, 'rowFullNames') && ~isempty(obj.rowFullNames)
               if ~iscell(b) && ischar(b)
                  b = {b};
               end   
               
               if numel(b) ~= numel(row_ind)
                  error('Subscripted assignment dimension mismatch!');
               elseif ~iscell(b) || ~ischar(b{1})    
                  error('Cell array with text values must be used as names!')
               end
                  
               outRowFullNames = obj.rowFullNamesAll;
               outRowFullNames(row_ind) = b;
               obj.rowFullNamesAll = outRowFullNames;               
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
