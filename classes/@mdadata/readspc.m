function readspc(filename)
   fid = fopen(filename, 'rb', 'l');
   if fid == -1
      error('Can not open the SPC file!');
   end
   
   v = fread(fid, 1, '*uint8');
   
   flags.sprec = logical(bitand(v, uint8(1)));
   flags.cgram = logical(bitand(v, uint8(2)));
   flags.multi = logical(bitand(v, uint8(4)));
   flags.randm = logical(bitand(v, uint8(8)));
   flags.ordrd = logical(bitand(v, uint8(16)));
   flags.alabs = logical(bitand(v, uint8(32)));
   flags.xyxys = logical(bitand(v, uint8(64)));
   flags.xvals = logical(bitand(v, uint8(128)));
   
   version = fread(fid, 1, '*uint8');
   
   if version ~= 75
      error('Old version of SPC file is not supported!');
   end   
   
   
end