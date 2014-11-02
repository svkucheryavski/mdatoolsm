function dens = quantizedens(dens)
   dens(dens < 6) = 1;
   dens(dens > 6 & dens < 10) = 2;
   dens(dens > 10 & dens <= 30) = 4;
   dens(dens > 30 & dens <= 60) = 8;
   dens(dens > 60 & dens <= 100) = 20;
   dens(dens > 100 & dens <= 300) = 30;
   dens(dens > 300 & dens <= 600) = 60;
   dens(dens > 600 & dens <= 1000) = 120;
   dens(dens > 1000 & dens < 3000) = 200;
   dens(dens > 3000 & dens < 6000) = 800;
   dens(dens > 6000 & dens < 10000) = 1200;
   dens(dens > 10000 & dens < 30000) = 2400;
   dens(dens > 30000) = 8000;   
end
