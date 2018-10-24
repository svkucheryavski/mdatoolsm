
      function varargout = matrixplot(obj, varargin)
      % 'matrixplot' makes a 3D plot for dataset values.
      %
      %   matrixplot(data);
      %
      %
      % The method shows a matrix of values from the dataset as a 3D surface 
      % with color identication of the surfacce levels.
      %
      % Examples:
      % ---------
      %
      %   load people
      %   
      %   figure
      %   matrixplot(people(1:8, {'Height', 'Weight', 'Beer', 'Wine'}))
      %
      %

         if ~ishold
            cla;
         end
            
         h = mesh(obj.numValues);
         
         if ~isempty(obj.colNamesAll)
            set(gca, 'XTick', 1:obj.nNumCols, 'XTickLabel', obj.colNamesWithoutFactors);
         end
         
         if ~isempty(obj.rowNamesAll)
            set(gca, 'YTick', 1:obj.nRows, 'YTickLabel', obj.rowNames);
         end
         
         [cmap, ~] = getarg(varargin, 'Colormap');
         if ~isempty(cmap)
            colormap(cmap(64))
         else   
            colormap(mdadata.getmycolors())
         end
         
         view(45, 45)
         title(obj.name);
         
         if ~isempty(obj.dimNames) && numel(obj.dimNames) == 2
            xlabel(obj.dimNames{2})
            ylabel(obj.dimNames{1})
         end
         
         if nargout > 0
            varargout{1} = h;
         end   
         
      end
