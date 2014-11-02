function showexcluded(ind, names)
% 'showexcluded' prints number and names of excluded
% rows or columns

   % find if there are any sequences in the indices
   indSeq = [false diff(ind') == 1];

   % matrix f will have two columns - start and end of each sequence
   f = [false, indSeq] ~= [indSeq, false];
   f = find(f(2:end));
   f = reshape(f, 2, numel(f)/2)';

   if isempty(f)
   % in case if there are no sequences we make a false f with 
   % values outside number of elements in ind and will catch this
   % situation in the loops below
      f = [numel(ind) + 1 numel(ind) + 1];
   end   

   % calculate maximal number of digits and length for numbers field
   nDigits = floor(log10(max(ind))) + 1;
   fieldLength = 2 * nDigits + 2;

   if isempty(names)
   % without row names

      fprintf('%*s\n', fieldLength, 'Num');
      fprintf('%*s\n', fieldLength, repmat('-', 1, fieldLength));

      for iRow = 1:size(f, 1)

         if iRow == 1
            % get indices before first sequence                  
            i = ind(1:(f(iRow, 1) - 1));                  
         else
            % get indices between previous and current sequences                  
            i = ind((f(iRow - 1, 2) + 1):(f(iRow, 1) - 1));
         end

         if ~isempty(i)
            % show values for found indices   
            fprintf(sprintf('%%%dd\n', fieldLength), i);
         end   

         if f(iRow, 1) > numel(ind) || f(iRow, 2) > numel(ind)
            % catch if f was false, there are no sequences   
            break;
         else   
            % show sequence
            fprintf('%*s\n', fieldLength, sprintf('%d:%d', ind(f(iRow, 1)), ind(f(iRow, 2))));
         end   
      end

      % show indices after the last sequence if any
      if iRow < numel(ind)
         i = ind((f(iRow, 2) + 1):end);
         if ~isempty(i)
            fprintf('%*d\n', fieldLength, i);
         end
      end   
   else            
   % with row names   

      strFieldLength = 2 * max(cellfun(@numel, names)) + 4;
      fprintf('%*s\t%*s\n', fieldLength, 'Num', strFieldLength, 'Names');
      fprintf('%*s\t%*s\n', fieldLength, repmat('-', 1, fieldLength), ...
         strFieldLength, repmat('-', 1, strFieldLength));
               names = names';

      for iRow = 1:size(f, 1)
         if iRow == 1
            % get indices before first sequence
            i = ind(1:(f(iRow, 1) - 1));
         else   
            % get indices between previous and current sequences
            i = ind((f(iRow - 1, 2) + 1):(f(iRow, 1) - 1));
         end

         if ~isempty(i)
            % show values for found indices
            names(i) = strcat('''', names(i), '''');
            outstr = [textgen('', i)' names(i)']';
            fprintf(sprintf('%%%ds\t%%%ds\n', fieldLength, strFieldLength), outstr{:});
         end   

         if f(iRow, 1) > numel(ind) || f(iRow, 2) > numel(ind)
            % catch if f was false, there are no sequences   
            break;
         else   
            % show values for current sequence
            str1 = sprintf('%d:%d', ind(f(iRow, 1)), ind(f(iRow, 2)));
            str2 = sprintf('%s:%s', names{ind(f(iRow, 1))}, names{ind(f(iRow, 2))});
            fprintf('%*s\t%*s\n', fieldLength, str1, strFieldLength, ['''' str2 '''']);
         end
      end   

      % show indices after the last sequence if any
      if iRow < numel(ind)
         i = ind((f(iRow, 2) + 1):end);
         if ~isempty(i)
            names(i) = strcat('''', names(i), '''');
            outstr = [textgen('', i); names(i)'];
            fprintf(sprintf('%%%ds\t%%%ds\n', fieldLength, strFieldLength), outstr{:});
         end   
      end   
   end

   fprintf('\n')         
end
