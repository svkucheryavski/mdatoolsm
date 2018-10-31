function varargout = plotvarres(obj, colind, varargin)

   if isempty(obj.residuals)
      warning('Residuals values are not available!')
      return
   end   
      
   [type, varargin] = getarg(varargin, 'Type');
   if isempty(type)
      if obj.residuals.nRows > 20
         type = 'line';
      else
         type = 'bar';
      end   
   end
         
   if strcmp(type, 'line')   
      h = gplot(obj.residuals(:, colind)', varargin{:});
   elseif strcmp(type, 'bar')   
      h = gbar(obj.residuals(:, colind)', varargin{:});
   else
      error('Wrong plot type!');
   end
   title('Objects residuals');
   
   if strcmp(type, 'line') 
      line(xlim(), [0 0], 'LineStyle', '--', 'Color', [0.5 0.5 0.5]);
   end   
      
   if nargout > 0
      varargout{1} = h.plot;
   end   
end