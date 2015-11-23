function varargout = plotxyloadings(obj, varargin)         
   if obj.nComp < 2
      warning('XY-loadings plot can not be created if number of components is < 2!')
      return
   end   
      
   if numel(varargin) > 0 && isnumeric(varargin{1})
      comp = varargin{1};
      varargin(1) = [];
      if numel(comp) ~= 2
         error('Wrong value for "comp" parameter!');
      end   
   else
      comp = [1 2];
   end
   
   args = mdadata.getgscatteroptions(2, varargin{:});

   hold on
   h1 = scatter(obj.xloadings(:, comp), args{1}{:});
   legendStr{1} = 'X';
   h2 = scatter(obj.yloadings(:, comp), args{2}{:});
   legendStr{2} = 'Y';
   hold off
   box on
   
   mdadata.legend([h1.plot, h2.plot], legendStr)
   title('XY loadings');
   xlabel(sprintf('Comp %d', comp(1)));
   ylabel(sprintf('Comp %d', comp(2)));
   
   axis auto
   correctaxislim(5, xlim(), ylim());
   lim = axis();
   line([0 0], [lim(3) lim(4)], 'LineStyle', '--', 'Color', [0.5 0.5 0.5]);
   line([lim(1)  lim(2)], [0 0], 'LineStyle', '--', 'Color', [0.5 0.5 0.5]);
            
   if nargout > 0
      varargout{1} = h;
   end      
end
