function varargout = plotscores(obj, comp, varargin)         
   if nargin < 2
      comp = [1 2];
   end
   
   if numel(comp) < 1 || numel(comp) > 2
      error('Wrong value for "comp", specify one or two components for the plot!');
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
