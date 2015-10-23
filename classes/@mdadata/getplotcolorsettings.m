function [cmap, cgroup, args, isColorbar, colorbarTitle] = getplotcolorsettings(varargin)
% 'getplotcolorsettings()' checks and returns various color settings for plot,
% e.g. color grouping, color map etc.
%
   args = varargin;
   
   cmap = [];
   [cgroup, args] = getarg(args, 'Colorby');
   if ~isempty(cgroup)

      if isa(cgroup, 'mdadata')
         cgroup = cgroup.values(:, 1);
      end
      
      if islogical(cgroup)
         cgroup = double(cgroup);
      end
      
      if ~isnumeric(cgroup)
         error('Colorby parameter should either numeric, logical or be an object of mdadata class!');
      end
            
      ncol = numel(unique(cgroup));
      if ncol > 64
         ncol = 64;
      end   
      
      % check if values for color grouping are provided
      [cmap, args] = getarg(args, 'Colormap');
      if ~isempty(cmap)
         cmap = colormap(cmap(ncol));
      else
         cmap = mdadata.getmycolors(ncol);
      end
      
      % remove extra Color option if specified
      [~, args] = getarg(args, 'Color');
   else
      cgroup = [];
      [c, args] = getarg(args, 'Color');
      
      if isempty(c)
         c = mdadata.getmycolors(1);
      end
      
      if size(c, 1) > 1
         % several colors provided - make each line with its color
         cmap = c;
         cgroup = 1:size(c, 1);
      else
         args = [{'Color', c} args];
      end
   end   
   
   % check if values for colorbar are provided
   [isColorbar, args] = getarg(args, 'Colorbar');
   if (~isempty(isColorbar) && strcmp(isColorbar, 'off')) || isempty(cmap)
      isColorbar = false;
   else
      isColorbar = true;
   end

   % check if values for colorbar title are provided
   [colorbarTitle, args] = getarg(args, 'ColorbarTitle');
   if isempty(colorbarTitle) || ~isColorbar
      colorbarTitle = '';
   end
end

