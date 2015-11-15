classdef pcares < ldecomp

   methods
      function obj = pcares(varargin)
         obj = obj@ldecomp(varargin{:});
      end
            
      function plot(obj, varargin)
         if nargin < 2 || ~isnumeric(varargin{1})
            comp = [1 2];
         else
            comp = varargin{1};
            varargin(1) = [];
            if min(comp) < 1 || max(comp) > obj.scores.nCols
               error('Wrong value for "comp" parameter!');
            end   
         end
         
         v = getarg(varargin, 'Labels');         
         sargs = {};
         if isempty(v) 
            if obj.Q.nRows < 100
               sargs = {'Labels', 'names'};
            end            
         else
            sargs = {'Labels', v};
         end   
         
         subplot(2, 2, 1)
         if ~isempty(obj.scores)
            plotscores(obj, comp, sargs{:})
         end   
         subplot(2, 2, 2)
         plotresiduals(obj, sargs{:})
         subplot(2, 2, 3)
         plotexpvar(obj)
         subplot(2, 2, 4)
         plotcumexpvar(obj)         
      end
      
   end   
end   