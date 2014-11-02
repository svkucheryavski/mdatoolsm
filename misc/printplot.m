function printplot(cf, figname, figsize, type, res)
   if nargin < 3
      figsize = [350 210];
   end    
   
   if nargin < 4
      type = 'eps';
   end
   
   if nargin < 5
      res = '-r300';   
   end
   
   set(cf, 'Position', [100 100 figsize]);
   set(cf, 'PaperPositionMode', 'auto');
   
   if strcmp(type, 'eps')
      set(cf, 'renderer', 'painters')
      show(cf, '-depsc', figname);
   elseif strcmp(type, 'png')
      show(cf, '-dpng', res, figname);
   elseif strcmp(type, 'tiff')
      show(cf, '-dtiff', res, figname);
   end   
end
