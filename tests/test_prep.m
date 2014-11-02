function test_prep()
   d = load('simdata');
   s = d.spectra;
   s = s + mdadata(0.01*randn(size(s)));
   p = prep();
   p.add('savgol', 1, 21, 2)
   sp = copy(s);
   p.apply(sp);

   figure
   subplot(2, 1, 1)
   plot(s)
   subplot(2, 1, 2)
   plot(sp)
end
