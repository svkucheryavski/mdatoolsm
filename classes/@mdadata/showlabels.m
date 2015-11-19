function varargout = showlabels(x, y, labels, position, c)
   if nargin < 4 || isempty(position)
      position = 'top';
   end

   if nargin < 5
      c = mdadata.LABELS_COLOR;
   end
   
   lim = axis();
   dx = (lim(2) - lim(1))/50;
   dy = (lim(4) - lim(3))/40;

   if strcmp(position, 'top');
      h = text(x, y + dy, labels, 'HorizontalAlignment', 'center', 'Color', c);
   elseif strcmp(position, 'right')
      h = text(x + dx, y, labels, 'HorizontalAlignment', 'left', 'Color', c);       
   elseif strcmp(position, 'bottom')
      h = text(x, y - dy, labels, 'HorizontalAlignment', 'center', 'Color', c);  
   elseif strcmp(position, 'left')
      h = text(x - dx, y, labels, 'HorizontalAlignment', 'right', 'Color', c);  
   end
   
   varargout = {};
   if nargout > 0
      varargout{1} = h;
   else   
end  
