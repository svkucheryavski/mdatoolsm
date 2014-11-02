classdef mdaimage < mdadata
   
   properties (GetAccess = 'public', SetAccess = 'protected')
      width 
      height
   end   
   
   properties (Dependent)
      image
   end
   
   %%% Class methods
   methods
      
      function obj = mdaimage(image, varnames, dimnames, name)
      % MDAIMAGE creates an object of class MDAIMAGE
      %
         [h, w, c] = size(image);
                  
         if nargin < 4
            name = '';
         end
         
         if nargin < 3 || isempty(dimnames)
            dimnames = {'Pixels', 'Channels'};
         end
         
         if nargin < 2 || isempty(varnames)
            varnames = [];
         end
         
         values = double(reshape(image, w * h, c));
         obj = obj@mdadata(values, [], varnames, dimnames, name); 
         obj.width = w;
         obj.height = h;
      end
      
      function out = end(obj, k, s)                  
         out = size(obj.image, k);
      end
      
      %%% getters and setters
      function image = get.image(obj)
         image = reshape(obj.valuesAll(:, ~(obj.excludedCols | obj.factorCols)), obj.height, obj.width, obj.nNumCols);
      end         
      
      function image = getNeighborhood(obj, x, y, r, c)
            
         x = x - r:x + r;
         y = y - r:y + r;
   
         if nargin < 5
            image = obj.subset(y, x, :);               
         else
            image = obj.subset(y, x, c);               
         end
      end
      
      function varargout = subset(obj, varargin)
      % SUBSET returns a subset of the data set
      %
         if numel(varargin) < 3
         % subset as normal 2-way data and return MDADATA object
            data = subset@mdadata(obj, varargin{:});
            varargout{1} = data;      
         else
         % subset as 3-way data and return MDAIMAGE object
            irows_idx = varargin{1};
            icols_idx = varargin{2};
            ichan_idx = varargin{3};
            
            % process indices values
            if isempty(irows_idx) || (ischar(irows_idx) && strcmp(irows_idx, ':'))
               irows_idx = 1:obj.height;
            elseif islogical(irows_idx)
               irows_idx = find(irows_idx);
            end

            if isempty(icols_idx) || (ischar(icols_idx) && strcmp(icols_idx, ':'))
               icols_idx = 1:obj.width;
            elseif islogical(icols_idx)
               icols_idx = find(icols_idx);
            end
            
            if isempty(ichan_idx) || (ischar(ichan_idx) && strcmp(ichan_idx, ':'))
               ichan_idx = 1:obj.nNumCols;
            else
               ichan_idx = obj.parsecolind(ichan_idx);
            end            
            
            width_new = numel(icols_idx);
            height_new = numel(irows_idx);

            % calculate indices for rows of data matrix
            icols_comb = repmat(icols_idx, height_new, 1);
            irows_comb = repmat(irows_idx, 1, width_new);      
            drow_idx = sub2ind([obj.height, obj.width], irows_comb(:), icols_comb(:));

            % subset image and names            
            simage = obj.image;
            simage = simage(irows_idx, icols_idx, ichan_idx);
            scolnames = obj.colNames(ichan_idx);
            
            % get excluded objects and variables
            sexcludedRows = ismember(drow_idx, find(obj.excludedRows));
            %sexcludedCols = ismember(ichan_idx, find(obj.excludedCols));
            
            image = mdaimage(simage, scolnames, obj.dimNames, obj.name);
            %image.excludedCols(sexcludedCols) = true;
            image.excludedRows(sexcludedRows) = true;

            varargout{1} = image;
         end   
      end   
      
      function varargout = imagesc(obj, varargin)
         if obj.nCols ~= 1
            error('Specify channel to show as an image!');
         end

         if ~isempty(varargin) && isnumeric(varargin{1})
            clim = varargin{1};
         else
            clim = [min(obj.values) max(obj.values)];
         end   

         cmap = getarg(varargin, 'Colormap');
         if isempty(cmap)
            cmap = @mdadata.getmycolors;
         end   
         
         alpha = ones(obj.width * obj.height, 1);
         alpha(obj.excludedRows) = 0;
         alpha = reshape(alpha, obj.height, obj.width);
         h = imagesc(obj.image, clim);
         colormap(cmap(64));
         set(h, 'AlphaData', alpha);
         axis off
         if nargout > 0
            varargout{1} = h;
         end   
      end
      
   end
end

