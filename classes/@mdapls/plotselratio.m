function varargout = plotselratio(obj, varargin)

   nResp = 1;
   if nargin > 1
      if isnumeric(varargin{1})
         nResp = varargin{1};
         varargin(1) = [];
      elseif ischar(varargin{1}) && any(ismember(obj.vipscores.colNames, varargin{1}))
         nResp = varargin{1};
         varargin(1) = [];
      end
   end
   
   i = find(strcmp(varargin, 'Type'), 1);
   if ~isempty(i)
      type = varargin{i + 1};
      varargin(i:i+1) = [];
   else
      type = 'bar';
   end
   
   if strcmp(type, 'bar')   
      h = bar(obj.selratio(:, nResp)', varargin{:});
   elseif strcmp(type, 'line')   
      h = plot(obj.selratio(:, nResp)', varargin{:});
   else
      error('Wrong plot type!');
   end
   
   title('Selectivity ratio')
   
   if nargout > 0
      varargout{1} = h.plot;
   end   
end
