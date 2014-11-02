function [val, args] = getarg(args, name)
% GETARG finds and return a value for an argument with a given name
%
% Example:
% --------
% [marker, varargin] = getarg('Marker', varargin);
%
   val = [];
   if numel(args) > 0
      i = find(strcmp(args, name));
      if ~isempty(i) 
         val = args{i(1) + 1};
         args([i i+1]) = [];
      end
   end   
end   