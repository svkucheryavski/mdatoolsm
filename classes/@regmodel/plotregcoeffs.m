function plotregcoeffs(obj, varargin)
   [nresp, ncomp, varargin] = regres.getRegPlotParams(obj.nResp, obj.nComp, varargin{:});
   obj.regcoeffs.plot(nresp, ncomp, varargin{:});
end
