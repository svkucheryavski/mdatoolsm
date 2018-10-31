function varargout = plotresiduals(obj, varargin)     

   if nargin < 2 || ~isnumeric(varargin{1})
      ncomp = obj.Q.nCols;
      strTitle = 'Residuals';
   else
      ncomp = varargin{1};
      varargin(1) = [];
      if ncomp < 1 || ncomp > obj.Q.nCols
         error('Wrong value for "ncomp" parameter!');
      end   
      strTitle = sprintf('Residuals (ncomp = %d)', ncomp);
   end
   
   plotData = mdadata([obj.T2(:, ncomp).valuesAll obj.Q(:, ncomp).valuesAll]);
   plotData.rowNamesAll = obj.T2.rowNamesAll;
   plotData.rowFullNamesAll = obj.T2.rowFullNamesAll;
   plotData.excluderows(obj.T2.excludedRows);
   
   h = scatter(plotData, varargin{:});
   xlabel(obj.T2.name);
   ylabel(obj.Q.name);
   title(strTitle);
   
   if nargout > 0
      varargout{1} = h.plot;
   end      
end
