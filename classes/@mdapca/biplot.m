function varargout = biplot(obj, comp, varargin)   
% BIPLOT shows a bi-plot for a PCA model
%
%     biplot(model)
%     biplot(model, comp)
%     biplot(model, comp, 'Param1', val1, 'Param2', val2, ...)
%
% Arguments:
% ----------
% model  - a PCA model (object of "mdapca" class)
% comp   - vector with component numbers for the plot (default [1, 2])
%
% Parameters:
% -----------
% 'Labels' - what to show as labels ('names', 'numbers' or 'none')
% 'Marker' - marker symbol for scores
% 'MarkerEdgeColor' - color for the marker's edge
% 'ScoresColor' - color for the marker's face
% 'LoadingsColor' - color for the lines representing loadings
% 'ScoresTextColor' - color for text labels (scores)
% 'LoadingsTextColor' - color for text lavels (loadings)
%
%


   if obj.nComp < 2
      error('Model must have at least two components for the plot!');
   end
   
   if nargin < 2
      comp = [1 2];
   end
   
   if numel(comp) ~= 2
      error('Wrong value for "comp", specify two components for the plot!');
   end   

   pcolors = mdadata.getmycolors(2);
   tcolors = [0.6 0.6 0.8; 0.8 0.6 0.6];
   
   % check color settings
   [sc, varargin] = getarg(varargin, 'ScoresColor');
   if isempty(sc)
      sc = pcolors(1, :);
   end   
   [lc, varargin] = getarg(varargin, 'LoadingsColor');
   if isempty(lc)
      lc = pcolors(2, :);
   end   
   [stc, varargin] = getarg(varargin, 'ScoresTextColor');
   if isempty(stc)
      stc = tcolors(1, :);
   end   
   [ltc, varargin] = getarg(varargin, 'LoadingsTextColor');
   if isempty(ltc)
      ltc = tcolors(2, :);
   end   
   [lb, varargin] = getarg(varargin, 'Labels');
   if isempty(lb)
      lb = 'none';
   end   
   [mr, varargin] = getarg(varargin, 'Marker');
   if isempty(mr)
      mr = 'o';
   end   
   [mec, varargin] = getarg(varargin, 'MarkerEdgeColor');
   if isempty(mec)
      mec = 'none';
   end   
   
   loads = obj.loadings.values(:, comp);
   scores = obj.calres.scores.values(:, comp);
   varnames = obj.loadings.rowNames;
   objnames = obj.calres.scores.rowNames;
  
   loadsScaleFactor = sqrt(max(sum(loads.^2, 2)));
   scoresScaleFactor = max(abs(scores(:)));
   scores = (scores / scoresScaleFactor) * loadsScaleFactor;   
   
   h = plot(scores(:, 1), scores(:, 2), 'LineStyle', 'none', 'Marker', mr,...
      'MarkerEdgeColor', mec, ...
      'MarkerFaceColor', sc, ...
      varargin{:});
   for i = 1:size(loads, 1)
      line([0 loads(i, 1)], [0 loads(i, 2)], 'Color', lc);
   end   
   
   if strcmp(lb, 'names')
      mdadata.showlabels(scores(:, 1), scores(:, 2), objnames, [], stc);
      mdadata.showlabels(loads(:, 1), loads(:, 2), varnames, [], ltc)
   elseif strcmp(lb, 'numbers')
      mdadata.showlabels(scores(:, 1), scores(:, 2), objnames, [], stc);
      mdadata.showlabels(loads(:, 1), loads(:, 2), textgen('', 1:numel(varnames)), [], ltc)
   end      
   
   title('Biplot')
   axis auto
   
   
   correctaxislim(5, xlim(), ylim());
   lim = axis();
   line([lim(1) lim(2)], [0 0], 'LineStyle', '--', 'Color', [0.5 0.5 0.5]);   
   line([0 0], [lim(3) lim(4)], 'LineStyle', '--', 'Color', [0.5 0.5 0.5]);
   
   
   if nargout > 0
      varargout{1} = h;
   end      
end
