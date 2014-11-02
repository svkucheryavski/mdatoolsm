function out = textgen(str, seq)
   out = strsplit(sprintf([str '%d:'], seq), ':');
   out = out(1:end-1);
end   