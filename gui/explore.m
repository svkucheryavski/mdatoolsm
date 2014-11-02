function explore(data)
   if nargin < 1 || ischar(data) && strcmp(data, 'people')
      load people
      data = mdadata(people.values, people.rowNames, people.colNames, people.dimNames, people.name);
      data.factor('Sex', {'Male', 'Female'});
      data.factor('Region', {'A', 'B'});
      data.excludecols('Income');      
   elseif ischar(data) && strcmp(data, 'spectra')
      load simdata
      data = mdadata(spectra.values, spectra.rowNames, spectra.colNames, spectra.dimNames, spectra.name);
   elseif ischar(data) && strcmp(data, 'image')
      load tablets
      data = tablets;
      data.removecols(1);
   end   
   e = Explorer(data);
end
