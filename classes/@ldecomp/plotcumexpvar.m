function varargout = plotcumexpvar(obj, varargin)
   
   [type, varargin] = getarg(varargin, 'Type');

   if isempty(type)
      type = 'line';
   end
   
   [mr, varargin] = getarg(varargin, 'Marker');
   if strcmp(type, 'line') 
      if isempty(mr)
         mr = '.';
      end    
      varargin = [varargin 'Marker', mr];      
   end   
   
   if strcmp(type, 'line')
      h = plot([mdadata(0, {}, {'Comp 0'}) obj.variance(:, 2)'], 0:obj.variance.nRows, varargin{:});
   elseif strcmp(type, 'bar')   
      h = bar([mdadata(0, {}, {'Comp 0'}) obj.variance(:, 2)'], 0:obj.variance.nRows, varargin{:});
   else
      error('Wrong plot type!');
   end
   
   title('Cumulative explained varaince')
   ylabel('Variance, %')
   xlabel('Components')
   
   if nargout > 0
      varargout{1} = h;
   end   
end