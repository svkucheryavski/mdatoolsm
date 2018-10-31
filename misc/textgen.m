function out = textgen(str1, seq, str2)
   if nargin < 3
      str2 = '';
   end   
   
   if all((seq - floor(seq)) == 0)
      out = strsplit(sprintf([str1 '%d' str2 ':'], seq), ':');
   else
      out = strsplit(sprintf([str1 '%g' str2 ':'], seq), ':');
   end
   out = out(1:end-1);
end   