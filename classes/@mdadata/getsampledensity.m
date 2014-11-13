function dens = getsampledensity(x, y, nbins, varargin)
% 'getsampledensity' calculates and returns density value for each point of a
% two variable data
%
% Arguments:
% ----------
%  'x' - vector with X values
%  'y' - vector with Y values
%  'nbins' - number of bins to split the XY space into
%  'smoothness' - smoothness parameter for bluring density values
%

   
   if nargin < 3
      nbins = 80;
   end
   
   x = fix((x - min(x)) / (max(x) - min(x)) * (nbins - 1) + 1);
   y = fix((y - min(y)) / (max(y) - min(y)) * (nbins - 1) + 1);

   xd = 0:nbins;
   yd = 0:nbins;

   ny = length(yd) - 1;
   nx = length(xd) - 1;

   h = zeros(ny, nx);

   for i = 1:ny

      ylb = yd(i);
      yub = yd(i + 1);

      yidx = (y > ylb) & (y <= yub);

      xfound = x(yidx);

      if (~isempty(xfound))

         v = histc (xfound, xd);
         n = length(v) - 1;

         if (n ~= nx)
            error ('Problem with size!')
         end

         [nyfound, nxfound] = size(v);

         nyfound = nyfound - 1;
         nxfound = nxfound - 1;

         if nyfound == nx
            h(i, :)= v(1:n)';
         elseif nxfound == nx
            h(i, :)= v(1:n);
         else
            error ('Problem with size!')
         end
      end
   end
   
   % TODO:
   % solve problem with 2D filtering without using toolboxes
   
   %h = conv2(h, fspecial('gaussian', round([nbins/12 nbins/12]), smoothness));
   
   dens = h((x - 1) * nbins + y);

   % quantize density values
   q = getarg(varargin, 'Quantize');
   if ~isempty(q) && strcmp(q, 'on')
      dens = mdadata.quantizedens(dens);
   end   
end
