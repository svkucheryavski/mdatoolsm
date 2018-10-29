function varargout = plotscores(obj, varargin)         

   if numel(varargin) > 0 && isnumeric(varargin{1})
      comp = varargin{1};
      varargin(1) = [];
      if min(comp) < 1 || max(comp) > obj.nComp
         error('Wrong value for components!');
      end   
   else
      comp = [1 2];
   end

   [type, varargin] = getarg(varargin, 'Type');
   if isempty(type) 
      if numel(comp) < 3
         type = 'scatter';
      else
         type = 'line';
      end   
   end
   
   if strcmp(type, 'scatter') && ~isempty(obj.testres)
      args = mdadata.getgscatteroptions(3, varargin{:});
      h = obj.calres.plotscores(comp, 'Type', type, args{1}{:});
      hold on
      h(end + 1) = obj.testres.plotscores(comp, args{3}{:});
      hold off
      title('Scores');
      legend({'cal', 'test'});
   else   
      h = obj.calres.plotscores(comp, 'Type', type, varargin{:});
      title('Scores (cal set)');
   end
      
   box on   
   if nargout > 0
      varargout{1} = h;
   end      
end
