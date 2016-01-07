function out = textgen(str1, seq, str2)
   if nargin < 3
      str2 = '';
   end   
   out = strsplit(sprintf([str1 '%d' str2 ':'], seq), ':');
   out = out(1:end-1);
end   