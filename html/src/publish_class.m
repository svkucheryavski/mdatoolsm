function publish_class(classname, varargin)
   
   methods = {};
   
   try
      lines = textscan(help(classname), '%s','delimiter','\n', 'whitespace', '');
      lines = lines{:};
   catch
      return
   end
   
   
   out = {};   
   n = 1;
   i = 1;
   is_code = false;
   properties_list = false;
   methods_list = false;
   
   if ~isempty(strfind(version, 'R2014b')) && ~isempty(strfind(lines{i}, 'Contents of'))
      lines(1:6) = [];
   end
   
   while i < size(lines, 1)
      % get current line and next line
      curline = lines{i};      
      nextline = lines{i + 1};
      
      stop_code = false;
      if i < size(lines, 1) - 1 && isempty(strtrim(lines{i + 1})) && isempty(strtrim(lines{i + 2}))
      % two empty lines next - stop code block  
         stop_code = true;
      end   
         
      % remove extra leading space
      curline = curline(2:end);
      nextline = nextline(2:end);
      
      if i == 1
      % first line of comment block, make as a header section   
         disp(curline)
         out{n} = ['%% ' classname];
         out{n + 1} = ['%' parseQuotes(curline)];
         n = n + 2;
      
      elseif length(nextline) > 2 && strcmp(nextline(1:3), ' --');
      % the current line is a header of a section   
         
         if strcmp(strtrim(out{n - 1}), '%%')
         % if there is an empty header before, remove it   
            out(n - 1) = [];
            n = n - 1;
         end
         
         text = regexprep(curline, ':$', '');
         out{n} = ['%%' text];
         out{n + 1} = '% ';
         i = i + 1;
         n = n + 2;
         
         % Check if a header title is for properties or for methods list
         % - take first word of the title
         title = regexp(strtrim(text), '^\w+', 'match');
         
         % - compare it with Properties
         if strcmp(title, 'Properties') || strcmp(title, 'Parameters') || strcmp(title, 'Arguments')
            properties_list = true;
            nlist = 1;
         else
            if properties_list
            % if the header breaks the property list, stop the list    
               properties_list = false;
               out{n} = '% </table></html>';
               n = n + 1;
            end   
         end
         
         % - compare it with methods
         if strcmp(title, 'Methods')
            methods_list = true;
            nlist = 1;
         else
            if methods_list
            % if the header breaks the property list, stop the list    
               methods_list = false;
               out{n} = '% </table></html>';
               n = n + 1;
            end   
         end         
         
         % check if everything works
         %disp('---- check 1 -----')
         %disp(strtrim(text))
         %disp(title)
         %disp(strcmp(title, 'Properties'))
         %disp(strcmp(title, 'Methods'))
         %disp(methods_list)
         %disp(properties_list)
         %disp('------ end --------')
         
      elseif length(curline) > 2 && strcmp(curline(1:3), '   ');
      % three spaces mean it is a code line   
         
         if is_code == false            
            is_code = true;
            out{n} = '%% '; n = n + 1;
            out{n} = '%  '; n = n + 1;
         end
         
         out{n} = curline;     
         n = n + 1;
         
         if stop_code
            out{n} = ' ';            
            out{n + 1} = '%%';            
            n = n + 2;
            i = i + 2;
            is_code = false;
         end
      elseif length(curline) > 2 && strcmp(curline(1:2), '  ') && (properties_list || methods_list);
      % two spaces mean list of properties or methods   

         if nlist == 1
         % if list starts with this line add proper HTML code   
            if properties_list
               out{n} = '% <html><table class="properties-list">';
               n = n + 1;
            else
               out{n} = '% <html><table class="methods-list">';
               n = n + 1;
            end
         end
         
         % split the line to "name - text" and make HTML 
         s = strsplit(curline, ' - ');
         
         if numel(s) == 2
            name = strtrim(strrep(s{1}, char(34), ''''));
            name = strrep(name, char(39), '');
            text = s{2};
            
            k = 1;
            % loop if text for a name is on several lines (do not use symbol "-" 
            % in this text not to confuse the script  
            while (k == 1 && i < size(lines, 1))
               curline = lines{i + 1};
               curline = curline(2:end);   
               s = strsplit(curline, ' - ');
               if numel(s) == 1 && length(curline) > 2 && strcmp(curline(1:2), '  ')
                  text = [text s{1}];
                  i = i + 1;
               else
                  k = 0;
               end   
            end
            
            text = parseQuotes(text, true);
            
            % add HTML code for a list item
            if methods_list
               method_id = [classname '.' name];
               if isempty(help(method_id))
                  class = 'name-nohelp';
                  name_leader = '<span>&nbsp;</span>';
               else   
                  class = 'name';
                  name_leader = '<span>&plus;</span>';
                  methods = [methods method_id];
               end   
               out{n} = ['% <tr><td id="' method_id '" class="' class '">' ...
                  name_leader name '</td><td class="text">'  text '</td></tr>']; 
            else   
               out{n} = ['% <tr><td class="name">' name '</td><td class="text">'  text '</td></tr>']; 
            end
            n = n + 1;         
            nlist = nlist + 1;        
            
            
            % check if only one empty line after the current and the next 
            % line after empty is a list again, skip the empty line
            if i < size(lines, 1) - 1 
               nextline = strtrim(lines{i + 1});
               nextnextline = lines{i + 2};
               
               if isempty(nextline) && length(strtrim(nextnextline)) > 2 && strcmp(nextnextline(1:2), '  ')
                  i = i + 1;
               end
            end   
         end   
      else         
         if (properties_list || methods_list) && nlist > 1
         % if this line breaks properties or methods list, stop the list   
            properties_list = false;
            methods_list = false;
            out{n} = '% </table></html>';
            n = n + 1;
         end
         
         if is_code == false
         % ordinary line, parse it and add comment mark          
            out{n} = ['%' parseQuotes(curline)];         
            n = n + 1;
         else
         % empty line with code, no comment mark and no parsing
            out{n} = curline;         
            n = n + 1;
         end         
      end   
      
      i = i + 1;
   end
    
   if ~isdir('./tmp')
      mkdir('./tmp');
   end
   cd('./tmp');
   
   filename = [strrep(classname, '/', '.') '.m'];
   f = fopen(filename, 'w');   
   if f > 0
      fprintf(f, '%s\n', out{:});
      fclose(f);  
      publish(['./' filename], varargin{:}, 'evalCode', false);
   end
   
   cd('..');
   rmdir('./tmp', 's');
   
   for i = 1:numel(methods)
      publish_class(methods{i}, varargin{:});
   end   
end

function l = parseQuotes(l, is_html)
% takes all words as 'xxx' and convert to |xxx| (inline code)
% takes all words as "xxx" and convert to |'xxx'| (string constants)
   if nargin < 2 || is_html == false
      
      l = regexprep(l, '<a href="([^"]*)">([\w\s])*</a>', '<../$1 $2>');

      if ~isempty(regexp(l, '(")([A-Za-z0-9 ,.''_()@]+)(")', 'ONCE'))
         % complex line like 'p.add("name")'
         l = regexprep(l, '(")([A-Za-z0-9 ,.''_()@]+)(")', '|${strrep($0, char(34), '''')}|');
      else
         l = regexprep(l, '('')([A-Za-z0-9_()@]+)('')', '|${strrep($0, char(39), '''')}|');
         l = regexprep(l, '(")([A-Za-z0-9_()@]+)(")', '|''${strrep($0, char(34), '''')}''|');
      end
            
      if ~isempty(strfind(l, 'See also'))
         l = [' See also: ', regexprep(strrep(l, 'See also ', ''), ...
            '([A-Za-z\.])*', ' <${strtrim(lower($0))}.html ${strtrim(lower($0))}>')];      
      end      
   else   
      l = regexprep(l, '('')([A-Za-z0-9_()@]+)('')', '<tt>${strrep($0, char(39), '''')}</tt>');
      l = regexprep(l, '(")([A-Za-z0-9_()@]+)(")', '<tt>''${strrep($0, char(34), '''')}''</tt>');
   end  
end