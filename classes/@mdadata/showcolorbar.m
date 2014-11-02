function h = showColorbar(cmap, cgroup, colorbarTitle, dx, dy)
% showColorbar shows colorbar on a plot
%
% Inputs:
% -------
% CMAP - colrmap (matrix with colors for each color group)
% CGROUP - vector of values used to make the color grouping
% COLORBARTITLE - title for the colorbar if needed
% DX - width of X space
% DY - width of Y space
%

   lim = axis();
   
   if nargin < 5
      dy = lim(4) - lim(3);
   end   
   
   if nargin < 4
      dx = lim(2) - lim(1);
   end
   
   n = size(cmap, 1);
   cbWidth = dx * 0.85/n;
   cbHeight = dy * 0.05;
   xinit = lim(1) + (lim(2) - lim(1))/2 - cbWidth * n/2;
   yinit = lim(4) + cbHeight * 1.5;
   
   hr = zeros(n);
   for i = 1:n
      hr(i) = rectangle('Position', [xinit + (i - 1) * cbWidth, yinit, cbWidth, cbHeight * 0.75],...
         'FaceColor', cmap(i, :), 'EdgeColor', 'none');
   end   
   h.bars = hr;
   
   if n > 6
      ng = 6;
   else
      ng = n;
   end
   
   % show labels for colorbar elements
   x = linspace(xinit, xinit + (n - 1) * cbWidth, ng);
   y = ones(1, ng) * yinit - cbHeight * 0.75;
   v = num2str(linspace(min(cgroup), max(cgroup), ng), 3);
   
   sz = get(gca, 'FontSize');
   h.labels = text(x + cbWidth/2, y, strsplit(v, ' '), 'FontSize', sz * 0.85, 'HorizontalAlignment','center');
   
   if ~isempty(colorbarTitle)
      yfactor = 1.8;
      h.title = text(xinit + cbWidth * n / 2, yinit + cbHeight * 1.5, colorbarTitle, ...
         'FontSize', sz * 0.95, 'HorizontalAlignment','center');
   else
      yfactor = 0;
   end
   
   axis([lim(1) lim(2) lim(3) lim(4) + cbHeight * (3 + yfactor)]);
end