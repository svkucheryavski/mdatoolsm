      function varargout = densscatter(obj, varargin)
      % 'densscatter' makes a density scatter plot for 'mdadata' object.
      %
      % Density scatter plot looks like a normal scatter plot where data points
      % are colored by their density - how many other data points are around.
      %
      % Parameters:
      % -----------
      % The syntax and parameters are similar to 'mdadata.scatter' The
      % additional parameters are:
      %  
      %  "NBins" - number of sections to split every axis of the plotting 
      %  area into. E.g. if it is 100, the XY plane will be split to 100x100
      %  sections and density of each section will be calculated.
      %  
      %  "Colormap" - which colormap to use for color separation. By default
      %  a built in palette based on colorbrewer 2 colors is used. Any
      %  Matlab colormap can be used ('@jet', '@spring', etc).
      %
      %
      % Examples:
      % ---------
      % 
      %   d = mdadata(randn(10000, 2));
      %
      %   figure
      %   subplot(1, 2, 1)
      %   densscatter(d)
      %   subplot(1, 2, 2)
      %   densscatter(d, 'NBins', 20, 'Colormap', @parula)
      %
      %
      
         % check if values for colorbar are provided
         [isColorbar, varargin] = getarg(varargin, 'Colorbar');
         if ~(isempty(isColorbar) && strcmp(isColorbar, 'on'))
            varargin = [varargin, {'Colorbar', 'off'}];
         end
         
         [nbins, varargin] = getarg(varargin, 'NBins');
         if isempty(nbins)
            nbins = 80;
         end   
         
         [mec, varargin] = getarg(varargin, 'MarkerEdgeColor');
         if isempty(mec)
            mec = 'none';
         end
         
         if size(obj.numValues, 2) ~= 2
            error('Specify for which two columns you want to make the plot for!')
         end

         plotValues = obj.numValues;
         x = plotValues(:, 1);
         y = plotValues(:, 2);
         nanind = isnan(x) | isnan(y);
         x(nanind) = [];
         y(nanind) = [];
         
         d = mdadata.getsampledensity(x, y, nbins);
        
         % remove Color argument if provided
         [~, varargin] = getarg(varargin, 'Color');

         varargin = [varargin {'Colorby', d, 'MarkerEdgeColor', mec, 'Density', 'on'}];
         h = obj.scatter(varargin{:});

         if nargout
            varargout{1} = h;
         end
      end
