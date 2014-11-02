function varargout = plotexpvar(obj, varargin)
   [type, varargin] = getarg(varargin, 'Type');
   if isempty(type)
      type = 'line';
   end
   
   mr = getarg(varargin, 'Marker');
   if strcmp(type, 'line') && isempty(mr)
      varargin = [varargin 'Marker', '.'];
   end   
   
   if strcmp(type, 'line')
      h = plot(obj.variance(:, 1)', varargin{:});
   elseif strcmp(type, 'bar')   
      h = bar(obj.variance(:, 1)', varargin{:});
   else
      error('Wrong plot type!');
   end
   
   title('Explained varaince')
   ylabel('Variance, %')
   xlabel('Components')
   
   if nargout > 0
      varargout{1} = h;
   end   
end