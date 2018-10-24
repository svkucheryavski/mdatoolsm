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
         valuesAll = obj.valuesAll(:, ~obj.excludedCols);

         if ~isempty(obj.colFullNames)
            colNames = obj.colFullNames;
         else
            colNames = obj.colNames;
         end
         
         nCols = obj.nCols;
         nRows = obj.nRows;
         
         if nRows > 200
            warning('The data is too long, will show first 200 rows only.')
            nRows = 200;
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
               [~, ~, v] = unique(valuesAll(:, i));
               v = v(~obj.excludedRows);
               v = v(1:nRows);
               
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
