function varargout = plotcumexpvar(obj, varargin)

   i = find(strcmp(varargin, 'Type'), 1);
   if ~isempty(i)
      type = varargin{i + 1};
      varargin(i:i+1) = [];
   else
      type = 'line';
   end
   
   [mr, varargin] = getarg(varargin, 'Marker');
   if isempty(mr)
      mr = '.';
   end   
   
   lead = mdadata(0, {'Cumexpvar'}, {'Comp 0'});
   plotData = [lead obj.calres.variance(:, 2)'];
   plotData.name = obj.calres.variance.name;
   plotData.dimNames = {'Results', obj.calres.variance.dimNames{2}};
   plotData.rowNames = {'cal'};

   if ~isempty(obj.cvres) && isa(obj.cvres, 'pcares')
      plotData = [plotData; [lead obj.cvres.variance(:, 2)']];
      plotData(end, :).rowNames = {'cv'};
   end   
   
   if ~isempty(obj.testres) && isa(obj.testres, 'pcares')
      plotData = [plotData; [lead obj.testres.variance(:, 2)']];
      plotData(end, :).rowNames = {'test'};
   end   
      
   if strcmp(type, 'bar')   
      h = gbar(plotData, varargin{:});
   elseif strcmp(type, 'line')   
      h = gplot(plotData, varargin{:}, 'Marker', mr);
   else
      error('Wrong plot type!');
   end
   
   if nargout > 0
      varargout{1} = h;
   end   
end