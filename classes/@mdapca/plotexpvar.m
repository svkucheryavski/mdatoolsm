function varargout = plotexpvar(obj, varargin)

   i = find(strcmp(varargin, 'Type'), 1);
   if ~isempty(i)
      type = varargin{i + 1};
      varargin(i:i+1) = [];
   else
      type = 'bar';
   end   

   plotData = obj.calres.variance(:, 1)';
   plotData.rowNames = {'cal'};

   if ~isempty(obj.cvres) && isa(obj.cvres, 'pcares')
      plotData = [plotData; obj.cvres.variance(:, 1)'];
      plotData(end, :).rowNames = {'cv'};
   end   
   
   if ~isempty(obj.testres) && isa(obj.testres, 'pcares')
      plotData = [plotData; obj.testres.variance(:, 1)'];
      plotData(end, :).rowNames = {'test'};
   end
   
   plotData.name = 'Explained variance';
   
   if strcmp(type, 'bar')   
      h = gbar(plotData, varargin{:});
   elseif strcmp(type, 'line')   
      h = gplot(plotData, varargin{:});
   else
      error('Wrong plot type!');
   end
   
   ylabel('Variance, %');
   xlabel('Components');
   
   if nargout > 0
      varargout{1} = h;
   end   
end