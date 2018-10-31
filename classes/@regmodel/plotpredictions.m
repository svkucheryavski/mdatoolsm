function plotpredictions(obj, varargin)
   [nresp, ncomp, varargin] = regres.getRegPlotParams(obj.nResp, obj.nComp, obj.calres.respNames,...
      varargin{:});
   
   args = mdadata.getgscatteroptions(3, varargin{:});
   
   h(1) = obj.calres.plotpredictions(nresp, ncomp, args{1}{:});
   legendStr{1} = 'cal';

   hold on   
   if ~isempty(obj.cvres)
      h(end + 1) = obj.cvres.plotpredictions(nresp, ncomp, args{2}{:});
      legendStr{end + 1} = 'cv';
   end
   
   if ~isempty(obj.testres)
      h(end + 1) = obj.testres.plotpredictions(nresp, ncomp, args{3}{:});
      legendStr{end + 1} = 'test';
   end   
   hold off
   box on
   
   if numel(legendStr) > 1
      mdadata.legend(h, legendStr)
   end   
   
   if ncomp == obj.nComp
      title('Predictions');
   else
      title(sprintf('Predictions (ncomp = %d)', ncomp));
   end   
end
