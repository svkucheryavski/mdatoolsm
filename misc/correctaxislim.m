function correctaxislim(n, xlim, ylim)
   if nargin < 1
      n = [5 5 5 5];
   elseif numel(n) == 1
      n = ones(1, 4) * n;
   elseif numel(n) == 2
      n = [n(1) n(1) n(2) n(2)];
   end
   
   if (sum(n > 1) > 0)
      n = n/100;
   end
   
   lim = axis();
   
   if nargin < 2 || isempty(xlim)
      xlim = lim(1:2);
   end
   
   if nargin < 3 || isempty(ylim)
      ylim = lim(3:4);
   end
   
   dx = (xlim(2) - xlim(1)) .* n(1:2);
   dy = (ylim(2) - ylim(1)) .* n(3:4);
   axis([xlim(1) - dx(1) xlim(2) + dx(2) ylim(1) - dy(1) ylim(2) + dy(2)]);

end