function legend(varargin)
   h = legend(varargin{:});
   set(h, 'EdgeColor', mdadata.LEGEND_EDGE_COLOR);
end