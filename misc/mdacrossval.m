function idx = mdacrossval(nobj, cv)
% 'crossval' generate sequence of indices for cross-validation
%
% cross-validation settings is a cell array: cv = {'full'} for 
% full cross-validation, cv = {'rand', nseg, nrep} for random 
% repeated cross-validation with nseg segments and nrep repetitions or 
% cv = {'ven', nseg} for systematic splits to nseg segments 
% ('venetian blinds').  
%
   methods = {'rand', 'ven', 'full'};
   
   if nargin < 2
      cv = [];
   end
   
   if isempty(cv)
      type = 'rand';
      nrep = 1;
      if nobj < 24
         nseg = nobj;         
      elseif nobj >= 24 && nobj < 40
         nseg = 8;
      elseif nobj >= 40 
         nseg = 4;
      end   
   else
      type = cv{1};
      
      if strcmp(type, 'full')
         type = 'rand';
         nseg = nobj;
         nrep = 1;
      else
         nseg = cv{2};
      
         if numel(cv) > 2
            nrep = cv{3};
         else
            nrep = 1;
         end
      end
   end   
   
   if ~any(ismember(type, methods)) 
      error('Wrong name for cross-valudation method!')      
   end
   
   if ~strcmp(type, 'rand')
      nrep = 1;
   end   
   
   seglen = ceil(nobj / nseg);
   fulllen = seglen * nseg;
   idx = zeros(nseg, ceil(nobj / nseg), nrep);
   if strcmp(type, 'rand')
      for irep = 1:nrep
         v = [randperm(nobj) nan(1, fulllen - nobj)];
         idx(:, :, irep) = reshape(v, nseg, numel(v)/nseg);   
      end   
   else
      v = [1:nobj nan(1, fulllen - nobj)];
      idx(:, :, 1) = reshape(v, nseg, numel(v)/nseg);   
   end
end  