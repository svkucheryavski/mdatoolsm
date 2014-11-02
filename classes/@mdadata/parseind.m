function varargout = parseind(ind, n, names, colnames, values)
% 'parseind' parses indices for columns or rows and return parsed values
%
% It may work with a name, array of names or sequence of names, logical 
% expressions as well as with numeric values.
%
% Inputs:
% -------
% 'ind' - indices specified by user, e.g. 1:5, [1, 3], 'Height:Weight', etc
% 'names' - cell array with names
% 'colnames' - column names to parse logical expressions (optional argument)
%

   if nargin < 5
      values = [];
   end

   if nargin < 4
      colnames = [];
   end
   
   if isempty(ind)
      error('No indices provided!');
   end

   if numel(ind) == 1 
   % only one index
      if ischar(ind) && strcmp(ind, ':')
         ind = 1:n;
      elseif iscell(ind)
         ind = ind{1};
      end   
   end
      
   if numel(ind) > 1 
   % more than one index   
      
      if (ischar(ind))
      % indices are provided as a string   
         
         if isempty(names)
         % text indices provided but names are not available
            error('Names are not available!')
         end
         
         if ~isempty(strfind(ind, ':'))
         % sequence of names, e.g. 'A1:A10'
            s = strsplit(ind, ':');
            if numel(s) ~= 2
               error(errmsg)
            end
            ind1 = find(ismember(names, s{1})); 
            ind2 = find(ismember(names, s{2})); 
            if isempty(ind1) || isempty(ind2) 
               error(errmsg)
            end               
            ind = ind1:ind2;
            
         elseif ~isempty(regexp(ind, '[<>=~&|]', 'ONCE'))
         % logical expression
         
            if isempty(colnames) 
               error('Column names are not available to parse logical expression!')
            end
            
            % function that returns number of a column n with a given name x
            f = @(x)(num2str(find(ismember(colnames, x))));
            
            % replace all column names with values(:, n)
            a = regexprep(ind, '([0-9]*[A-Za-z])+(?=\W)', 'values(:, ${f($1)})');
            % replace all $n text with values(:, n)
            a = regexprep(a, '(\$)\d+', 'values(:, $0) ');
            % remove all dollar symbols
            a = regexprep(a, '(\$)(?=\d+)', '');
            % evaluate the logical expression
            ind = eval(a);
         else
         % name of a column or of an a row
            ind = find(ismember(names, ind));
         end   
      elseif iscell(ind)   
      % one or several names in a cell array
         
         sind = ind;
         ind = zeros(1, numel(sind));         
         for i = 1:numel(ind)
            r = find(ismember(names, sind{i}));
            if isempty(r)
               error('Wrong value for indices!');
            end   
            ind(i) = r;
         end
         if any(ind == 0)
            error('Wrong value for indices!')
         end   
      elseif islogical(ind)
      % indices are result of logical expression   
         if numel(ind) ~= n
            error('Wrong value for indices!')
         end   
      elseif isnumeric(ind)   
      % indices are numbers
         if min(ind) < 1 || max(ind) > n
            error('Wrong value for indices!')
         end   
      end   
   end
   
   if islogical(ind)
      ind = find(ind);
   end
      
   if nargout > 0
      varargout{1} = ind;
   end   
end