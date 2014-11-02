function [args, varargin] = getgplotoptions(nGroups, varargin)

   args = cell(nGroups, 1);
      
   % check color settings
   [mc, varargin] = getarg(varargin, 'Color');
   if isempty(mc)
      mc = mdadata.getmycolors(nGroups);
   else            
      if isnumeric(mc)
         nmc = size(mc, 1);
      else
         nmc = numel(mc);
         if size(mc, 2) > size(mc, 1)
            mc = mc';
         end   
      end
      
      if nmc == 1
         mc = repmat(mc, nGroups, 1);
      elseif nmc ~= nGroups
         error('Number of colors in "Color" should be the same as number of groups!');
      end   
   end   

   [mr, varargin] = getarg(varargin, 'Marker');
   if isempty(mr) 
      mr = repmat({'o'}, nGroups, 1);
   else
      if numel(mr) == 1 
         mr = repmat({mr}, nGroups, 1);
      elseif numel(mr) ~= nGroups
         error('Argument "Marker" should have one value or values for each groups!');
      elseif ~iscell(mr)
         mr = cellstr(mr');
      end   
   end

   [mec, varargin] = getarg(varargin, 'MarkerEdgeColor');
   if ~isempty(mec)
      if isnumeric(mec)
         nmec = size(mec, 1);
      else
         nmec = numel(mec);
         if size(mec, 2) > size(mec, 1)
            mec = mec';
         end   
      end

      if nmec == 1
         mec = repmat(mec, nGroups, 1);
      elseif nmec ~= nGroups
         error('Number of colors in "MarkerEdgeColor" should be the same as number of groups!');
      end   
   else
      if strcmp(mr, '.')
         mec = mc;
      else
         mec = repmat('none', nGroups, 1);
      end   
   end   

   [mfc, varargin] = getarg(varargin, 'MarkerFaceColor');
   if isempty(mfc)
      mfc = mc;
   else            
      if isnumeric(mfc)
         nmfc = size(mfc, 1);
      else
         nmfc = numel(mfc);
         if size(mfc, 2) > size(mfc, 1)
            mfc = mfc';
         end   
      end

      if nmfc == 1
         mfc = repmat(mfc, nGroups, 1);
      elseif nmfc ~= nGroups
         error('Number of colors in "MarkerFaceColor" should be the same as number of groups!');
      end   
   end   

   [ms, varargin] = getarg(varargin, 'MarkerSize');
   if isempty(ms) 
      if strcmp(mr{1}, '.') 
         ms = repmat(14, nGroups, 1);
      else
         ms = repmat(7, nGroups, 1);
      end   
   else
      if numel(ms) == 1
         ms = repmat(ms, nGroups, 1);
      elseif numel(ms) ~= nGroups
         error('Argument "MarkerSize" should have one value or values for each groups!');
      end   
   end

   for i = 1:nGroups
      args{i} = {'Color', mc(i, :), 'Marker', mr{i}, 'MarkerSize', ms(i),...
         'MarkerEdgeColor', mec(i, :), 'MarkerFaceColor', mfc(i, :), varargin{:}};
   end   
end
