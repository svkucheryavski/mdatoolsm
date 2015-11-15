function varargout = plotobjres(obj, rowind, varargin)

   if isempty(obj.residuals)
      warning('Residuals values are not available!')
      return
   end   
      
   [type, varargin] = getarg(varargin, 'Type');
   if isempty(type)
      if obj.residuals.nCols > 20
         type = 'line';
      else
         type = 'bar';
      end   
   end
         
   if strcmp(type, 'line')   
      h = gplot(obj.residuals(rowind, :), varargin{:});
   elseif strcmp(type, 'bar')   
      h = gbar(obj.residuals(rowind, :), varargin{:});
   else
      error('Wrong plot type!');
   end
   title('Objects residuals');
   
   if strcmp(type, 'line') 
      lim = axis();
      line([lim(1) lim(2)], [0 0], 'LineStyle', '--', 'Color', [0.5 0.5 0.5]);
   end   
      
   if nargout > 0
      varargout{1} = h.plot;
   end   
end