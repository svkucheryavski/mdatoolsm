function plotyresiduals(obj, varargin)

   [nresp, ncomp, varargin] = regres.getRegPlotParams(obj.nResp, obj.nComp, obj.calres.respNames,...
      varargin{:});
   
   args = mdadata.getgscatteroptions(3, varargin{:});
   
   hold on
   h(1) = obj.calres.plotyresiduals(nresp, ncomp, args{1}{:});
   legendStr{1} = 'cal';
   
   if ~isempty(obj.cvres)
      h(end + 1) = obj.cvres.plotyresiduals(nresp, ncomp, args{2}{:});
      legendStr{end + 1} = 'cv';
   end
   
   if ~isempty(obj.testres)
      h(end + 1) = obj.testres.plotyresiduals(nresp, ncomp, args{3}{:});
      legendStr{end + 1} = 'test';
   end
   
   hold off
   box on
   
   if numel(legendStr) > 1
      mdadata.legend(h, legendStr)
   end   

   line(xlim(), [0 0], 'LineStyle', '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility','off');
   
   if ncomp == obj.nComp
      title('Prediction residuals');
   else
      title(sprintf('Prediction residuals (ncomp = %d)', ncomp));
   end   
   
end
