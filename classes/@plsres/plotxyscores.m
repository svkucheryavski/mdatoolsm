function varargout = plotxyscores(obj, varargin)         
   if numel(varargin) > 0 && isnumeric(varargin{1})
      ncomp = varargin{1};
      varargin(1) = [];
      if ncomp < 1 || ncomp > obj.nComp
         error('Wrong value for "ncomp" parameter!');
      end   
   else
      ncomp = obj.nComp;
   end
   
   if isempty(obj.xdecomp.scores)
      warning('Scores are not available for cross-validation results!')
      return
   end

   if isempty(obj.ydecomp)
      warning('Y decomposition is not available for this PLS results.')
      return
   end
   
   plotData = [obj.xdecomp.scores(:, ncomp) obj.ydecomp.scores(:, ncomp)];
         
   h = plotData.scatter(varargin{:});

   if ~ishold
      box on
      title('XY scores');
      xlabel(sprintf('X scores (Comp %d)', ncomp));
      ylabel(sprintf('Y scores (Comp %d)', ncomp));
   end
   
   if nargout > 0
      varargout{1} = h.plot;
   end      
end
