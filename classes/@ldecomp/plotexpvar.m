function varargout = plotexpvar(obj, varargin)
   [type, varargin] = getarg(varargin, 'Type');
   if isempty(type)
      type = 'line';
   end
   
   mr = getarg(varargin, 'Marker');
   [mr, varargin] = getarg(varargin, 'Marker');
   if strcmp(type, 'line') 
      if isempty(mr)
         mr = '.';
      end    
      varargin = [varargin 'Marker', mr];      
   end   
   
   if strcmp(type, 'line')
      h = plot(obj.variance(:, 1)', 1:obj.variance.nRows, varargin{:});
      xlim([0.75 obj.variance.nRows + 0.25])
   elseif strcmp(type, 'bar')   
      h = bar(obj.variance(:, 1)', 1:obj.variance.nRows, varargin{:});
      xlim([0.25 obj.variance.nRows + 0.75])
   else
      error('Wrong plot type!');
   end
   
   set(gca, 'XTick', 1:obj.variance.nRows);
   
   title('Explained varaince')
   ylabel('Variance, %')
   xlabel('Components')
   
   if nargout > 0
      varargout{1} = h;
   end   
end