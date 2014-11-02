function h = showlabels(x, y, labels, position)
   if nargin < 4
      position = 'top';
   end

   c = mdadata.LABELS_COLOR;

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
end  
