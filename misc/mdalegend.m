function mdalegend(varargin)
   h = legend(varargin{:});
   set(h, 'EdgeColor', mdadata.LEGEND_EDGE_COLOR);
end