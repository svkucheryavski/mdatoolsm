function c = getmycolors(n)
% 'getmycolors' generates and returns a colormap based on colorbrewer2.org
% scheme
%

   cc = [...
         170,52,69;...
         213,62,79;...
         244,109,67;...
         253,174,97;...
         254,224,139;...
         230,245,152;...
         171,221,164;...
         102,194,165;...
         50,136,189;
         30,96,149;
         ]/255;

   cc = cc(end:-1:1, :);
   
   c = zeros(64, 3);
   for i = 1:3
      c(:, i) = interp1(linspace(0, 1, size(cc, 1)), cc(:, i), linspace(0, 1, 64));
   end
   
   if nargin == 1
      if n == 1
         c = c(1, :);
      elseif n == 3
         c = [c(1, :); [252 163 64]/255; c(end, :)];
      else
         x = round(linspace(1, size(c, 1), n));
         c = c(x, :);
      end
   end   
end   
