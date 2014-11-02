function f = getserind(seq)
% 'genserinf' detect series in a vector of values and return a matrix with 
% first and last elements for each series. If there are single elements,
% which are not member of any series the first and last elements are the
% same.
% 
   if size(seq, 1) > size(seq, 2)
      seq = seq';
   end
   
   % find if there are any sequences in the indices
   indSeq = [false diff(seq) == 1];
   
   %~ matrix f will have two columns - start and end of each sequence
   f = [false, indSeq] ~= [indSeq, false];
   
   ff = find(~indSeq & ~f(2:end));
   ff = [ff' ff'];
   
   f = find(f(2:end));
   f = reshape(f, 2, numel(f)/2)';

   f = [f; ff];
   f = sort(f);
end