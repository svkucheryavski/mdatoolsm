function plotregcoeffs(obj, varargin)
   [nresp, ncomp, varargin] = regres.getRegPlotParams(obj.nResp, obj.nComp, obj.calres.respNames, varargin{:});
   obj.regcoeffs.plot(nresp, ncomp, varargin{:});
end
