function cout = mdalight(cin)
   charValues = 'rgbcmywk';  
   rgbValues = [eye(3); 1-eye(3); 1 1 1; 0 0 0];

   if ischar(cin)
      [~, ind] = ismember(cin, charValues);
      cin = rgbValues(ind, :);
   end
   
   cout = rgb2hsv(cin);   
   
   % decrease saturation
   cout(2) = cout(2) * 0.5;
   if (cout(2) > 1) 
      cout(2) = 1;
   end;   
   
   % increase brightness
   cout(3) = cout(3) * 1.5;
   if (cout(3) > 1) 
      cout(3) = 1;
   end;   
   cout = hsv2rgb(cout);
   
   function chsv = rgb2hsv(crgb)
      r = crgb(1); g = crgb(2); b = crgb(3);
      range = (max(crgb) - min(crgb));
      
      v = max(crgb);
      
      if v == 0
         h = 0;
         s = 0;
         chsv = [h s v];
         return;
      end
      
      s = range / max(crgb);
      if s == 0
         h = 0;
         chsv = [h s v];
         return;
      end
      
      if r == min(crgb)
         h = 60 * (3 - (g - b) / range);
      elseif g == min(crgb)
         h = 60 * (5 - (b - r) / range);
      else
         h = 60 * (1 - (r - g) / range);         
      end
      
      chsv = [h s v];     
   end

   function crgb = hsv2rgb(chsv)

      h = chsv(1); s = chsv(2); v = chsv(3);
      
      if s == 0
         crgb = [v v v];
         return;
      end
      
      if v == 0
         crgb = [0 0 0];
         return;
      end
      
      c = v * s;
      hp = h / 60;
      x = c * (1 - abs(mod(hp, 2) - 1));
      
      switch floor(hp)
         case 0
            r = c; g = x; b = 0;
         case 1
            r = x; g = c; b = 0;
         case 2
            r = 0; g = c; b = x;
         case 3
            r = 0; g = x; b = c;
         case 4
            r = x; g = 0; b = c;
         case 5
            r = c; g = 0; b = x;
         case 6
            r = c; g = 0; b = x;
         otherwise
            r = 0; g = 0; b = 0;
      end
      
      m = v - c;
      
      r = r + m; 
      g = g + m;
      b = b + m;
                  
      crgb = [r g b];
   end
end