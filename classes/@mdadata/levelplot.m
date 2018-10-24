      function varargout = levelplot(obj, varargin)
      % 'levelplot' makes a level plot for dataset values.
      %
      %   levelplot(data);
      %
      %
      % The method visualises a matrix of values from the dataset as a set of
      % rectangles (levels), oriented the same way as values in the matrix. 
      % Color of each rectangle corresponds to the value. This can be particularly
      % useful for comparison of the same factors obtained at different
      % conditions or for different groups (e.g. average values for males and
      % females) or pairwise comparison (e.g. covariance or correlation
      % matrices).
      %
      % Examples:
      % ---------
      %
      %   load people
      %   
      %   figure
      %   levelplot(corr(people(:, 1:6)))
      %
      %   figure
      %   levelplot(corr(people(:, 1:6)))
      %   colormap('winter')
      %   colorbar
      %
      
         if ~ishold
            cla;
         end
      
         h = imagesc(obj.numValues);
         set(gca, 'XTick', 1:obj.nNumCols, 'XTickLabel', obj.colNamesWithoutFactors);
         
         if ~isempty(obj.rowNames)
            set(gca, 'YTick', 1:obj.nRows, 'YTickLabel', obj.rowNames);
         end
         
         [cmap, ~] = getarg(varargin, 'Colormap');
         if ~isempty(cmap)
            colormap(cmap(64))
         else   
            colormap(mdadata.getmycolors())
         end
         
         title(obj.name);
         
         if ~isempty(obj.dimNames) && numel(obj.dimNames) == 2
            xlabel(obj.dimNames{2})
            ylabel(obj.dimNames{1})
         end
         
         if nargout > 0
            varargout{1} = h;
         end   
         
      end
