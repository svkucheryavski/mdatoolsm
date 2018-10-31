classdef mdadata3 < handle & matlab.mixin.Copyable
% 'mdadata3' is a class to keep 3-way data. It has some features of 'mdadata'   
% like names for rows, cols and the third way, and ability to hide rows.
%

	properties (Access = 'protected', Hidden = true)
      values_
      dimNames
      wayNamesAll
      wayFullNamesAll
      excludedRows      
   end
   
	properties 
      name 
      wayValuesAll
   end
   
	properties (Dependent = true)
      values
      valuesAll
      wayNames
      wayFullNames
      wayValues
	end

	methods
		function obj = mdadata3(values, wayNames, wayFullNames, dimNames, name)         
         if nargin < 2
            wayNames = {};
         end
         
         if nargin < 3
            wayFullNames = {};
         end
         
         if nargin < 4
            dimNames = {};
         end
         
         if nargin < 5
            name = '';
         end
         
         obj.values_ = values;
         obj.wayNamesAll = wayNames;
         obj.wayFullNamesAll = wayFullNames;
         obj.wayValuesAll = cell(1, 3);
         obj.dimNames = dimNames;
         obj.name = name;
         obj.excludedRows = false(size(values, 1), 1);
      end
      
      function set.dimNames(obj, value)
         if isempty(value)
            value = {'Objects', 'Responses', 'Components'};
         end
         
         obj.dimNames = value;
      end

      function out = get.wayValues(obj)        
         if ~isempty(obj.wayValuesAll{1})
            out{1} = obj.wayValuesAll{1}(~obj.excludedRows);
         else
            out{1} = {};
         end   
         if ~isempty(obj.wayValuesAll{2})
            out{2} = obj.wayValuesAll{2}(~obj.excludedCols);
         else
            out{2} = {};
         end   
         out{3} = obj.wayValuesAll{3};
      end
      
      function out = get.wayNames(obj)
         if ~isempty(obj.wayNamesAll{1})
            out{1} = obj.wayNamesAll{1}(~obj.excludedRows);
         else
            out{1} = {};
         end   
         out{2} = obj.wayNamesAll{2};
         out{3} = obj.wayNamesAll{3};
      end
      
      function out = get.wayFullNames(obj)
         if ~isempty(obj.wayFullNamesAll{1})
            out{1} = obj.wayFullNamesAll{1}(~obj.excludedRows);
         else
            out{1} = {};
         end   
         out{2} = obj.wayFullNamesAll{2};
         out{3} = obj.wayFullNamesAll{3};
      end
      
      function set.wayNamesAll(obj, value)
         if isempty(value)
            value = obj.genWayNames();
         end
         obj.wayNamesAll = value;
      end
      
      function set.wayFullNamesAll(obj, value)
         if isempty(value)
            value = obj.genWayFullNames();
         end
         
         obj.wayFullNamesAll = value;
      end
      
      function out = genWayNames(obj)
         out{1} = textgen('O', 1:size(obj.valuesAll, 1));
         out{2} = textgen('Y', 1:size(obj.valuesAll, 2));
         out{3} = textgen('Comp', 1:size(obj.valuesAll, 3));
      end   
      
      function out = genWayFullNames(obj)
         out{1} = textgen('O ', 1:size(obj.valuesAll, 1));
         out{2} = textgen('Y ', 1:size(obj.valuesAll, 2));
         out{3} = textgen('Comp ', 1:size(obj.valuesAll, 3));
      end   
      
      function excluderows(obj, ind)
         obj.excludedRows(ind) = true;
      end
      
      function includerows(obj, ind)
         obj.excludedRows(ind) = false;
      end
                           
      function out = get.valuesAll(obj)
         
         values = obj.values_;
         
         if size(obj, 3) == 1
            dimin = [1 2];
            dimout = 3;
         elseif size(obj, 2) == 1
            dimin = [1 3];
            dimout = 2;
         else
            error('You need to specify indices for second and third dimension!')
         end   
         
         out = squeeze(values);
         out = mdadata(out, obj.wayNamesAll{dimin(1)}, obj.wayNamesAll{dimin(2)});
         out.rowFullNamesAll = obj.wayFullNamesAll{dimin(1)};
         out.colFullNamesAll = obj.wayFullNamesAll{dimin(2)};        
         out.rowValuesAll = obj.wayValuesAll{dimin(1)};
         out.colValuesAll = obj.wayValuesAll{dimin(2)};
         
         out.dimNames = obj.dimNames(dimin);
         if isempty(obj.wayNamesAll{dimout}) || strcmp(obj.wayNamesAll{dimout}{1}, 'x')
            out.name = obj.name;
         else
            out.name = sprintf('%s (%s)', obj.name, obj.wayNamesAll{dimout}{1});
         end               
         
      end
      
      function out = get.values(obj)
         out = obj.valuesAll;         
         out.excluderows(obj.excludedRows);
      end
      
      function out = end(obj, k, ~)                  
         values = obj.values_(obj.excludedRows, :, :);
         out = size(values, k);
      end
                  
      function varargout = size(obj, varargin)
         values = obj.values_(~obj.excludedRows, :, :);
         
         if nargout == 1
            varargout{1} = size(values, varargin{:});
         elseif nargout == 3
            [nr, nc, ns] = size(values, varargin{:});   
            varargout{1} = nr;
            varargout{2} = nc;
            varargout{3} = ns;
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
      
      function varargout = subset(obj, varargin)
      % 'subset' returns a subset of the data set
      %
         if isempty(varargin)
            varargout{1} = obj;
            return;
         end
         
         if nargin  < 4
         % only two indices 
            ind{1} = 1:size(obj.values_, 1);
            ind{2} = varargin{1};
            ind{3} = varargin{2};            
         else   
         % three indices   
            ind{1} = varargin{1};
            ind{2} = varargin{2};
            ind{3} = varargin{3};
         end

         swayNamesAll = cell(3, 1);
         swayFullNamesAll = cell(3, 1);
         swayValuesAll = cell(3, 1);
         
         for i = 1:3    
            % TODO: change to mdaparseind() to work with names as well
            if ischar(ind{i}) && strcmp(ind{i}, ':')
               ind{i} = 1:size(obj.values_, i);
            end
            
            if i > 1
               if ~isempty(obj.wayValuesAll{i})
                  swayValuesAll{i} = obj.wayValuesAll{i}(ind{i});
               end   
               
               if ~isempty(obj.wayNamesAll{i})
                  swayNamesAll{i} = obj.wayNamesAll{i}(ind{i});
               end   
            
               if ~isempty(obj.wayFullNamesAll{i})
                  swayFullNamesAll{i} = obj.wayFullNamesAll{i}(ind{i});
               end                           
            end   
         end
         
         if numel(ind{1}) == size(obj.values_, 1)
            sexcludedRows = obj.excludedRows;
            svalues = obj.values_(:, ind{2}, ind{3});
            swayValuesAll{1} = obj.wayValuesAll{1};
            swayNamesAll{1} = obj.wayNamesAll{1};
            swayFullNamesAll{1} = obj.wayFullNamesAll{1};
         else
            sexcludedRows = [];
            svalues = obj.values_(~obj.excludedRows, ind{2}, ind{3});
            if ~isempty(obj.wayValuesAll{1})
               swayValuesAll{1} = obj.wayValuesAll{1}(~obj.excludedRows);
            end
            if ~isempty(obj.wayNamesAll{1})
               swayNamesAll{1} = obj.wayNamesAll{1}(~obj.excludedRows);
            end
            if ~isempty(obj.wayFullNamesAll{1})
               swayFullNamesAll{1} = obj.wayFullNamesAll{1}(~obj.excludedRows);
            end
         end   
            
         data = mdadata3(svalues, swayNamesAll, swayFullNamesAll, obj.dimNames, obj.name);
         data.wayValuesAll = swayValuesAll;
         if ~isempty(sexcludedRows)
            data.excluderows(sexcludedRows);
         end
                  
         varargout{1} = data;
      end   

	end
end
