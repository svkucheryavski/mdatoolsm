function test_pca(type, casen)
   clc
   close all

   if nargin < 1
      type = 'people';
   end
   
   if nargin < 2
      casen = 1;
   end
   
   switch type
      case 'people'
         d = load('people');
         odata = d.people;
         scale = 'on';
         info = 'PCA model for People data';   
         factorCols = {'Sex', 'Region'};
         factorLevels = { {'Male', 'Female'}, {'A', 'B'} };
         excludedCols = {'Income'};
         excludedRows = 1:5:31;
         cind = true(odata.nRows, 1);
         cind(1:4:end) = false;         
         colorby = odata(:, 2);
         p = prep();
      case 'spectra'
         d = load('simdata');
         odata = d.spectra;
         scale = 'on';
         info = 'PCA model for UV/Vis spectra (simdata)';
         factorCols = {};
         factorLevels = {};
         excludedCols = 1:20;
         excludedRows = 1:5:100;
         cind = true(odata.nRows, 1);
         cind(1:8:end) = false;  
         colorby = d.conc(:, 2);
         p = prep();
         p.add('snv');
      case 'image'
         d = load('tablets');
         odata = d.tablets;
         scale = 'off';
         info = 'PCA model for HSI image of tablets';
         factorCols = {};
         factorLevels = {};
         excludedCols = 1:20;
         excludedRows = 1:5:100;
         cind = true(odata.height, 1);
         cind(1:2:end) = false;         
         colorby = odata(:, 80);
         p = prep();
         p.add('snv');
   end      
         
   switch casen
      case 1
         fprintf('1. Testing simple model\n')   
         data = copy(odata);
         m = mdapca(data, 5, 'Scale', scale, 'Alpha', 0.15);
         m.info = info;   
         summary(m);
         summary(m.calres);
         showPlotsForModel(m);
         showPlotsForResult(m.calres, colorby);
         
      case 2
         fprintf('2. Testing data with factors and excluded colums and rows\n')   
         data = copy(odata);
         for i = 1:numel(factorCols);
            data.factor(factorCols{i}, factorLevels{i});
         end
         data.excludecols(excludedCols);      
         data.excluderows(excludedRows);
         colorby.excluderows(excludedRows);

         m = mdapca(data, 5, 'Scale', scale);
         m.info = info;
         summary(m);
         summary(m.calres);
         showPlotsForModel(m);   
         showPlotsForResult(m.calres, colorby);

      case 3   
         fprintf('3. Test set validation\n')   
         data = copy(odata);
         cdata = data(cind, :);
         tdata = data(~cind, :);
         m = mdapca(cdata, 5, 'Scale', scale, 'TestSet', tdata);
         m.info = info;
         summary(m);
         summary(m.calres);
         summary(m.testres);
         showPlotsForModel(m, 'rg');
         showPlotsForResult(m.calres, colorby(cind, :));
         showPlotsForResult(m.testres);

      case 4   
         fprintf('4. Cross-validation\n')   
         data = copy(odata);
         m = mdapca(data, 5, 'Scale', scale, 'CV', {'rand', 8, 2});
         m.info = info;
         summary(m);
         summary(m.calres);
         summary(m.cvres);
         showPlotsForModel(m);
         showPlotsForResult(m.calres, colorby);
         showPlotsForResult(m.cvres, colorby);

      case 5   
         fprintf('5. Test set and cross-validation\n')   
         data = copy(odata);
         cdata = data(cind, :);
         tdata = data(~cind, :);
         m = mdapca(cdata, 5, 'Scale', scale, 'TestSet', tdata, 'CV', {'full'});
         m.info = info;
         summary(m);
         summary(m.calres);
         summary(m.cvres);
         summary(m.testres);
         showPlotsForModel(m, 'rgb');
         showPlotsForResult(m.calres, colorby(cind, :));
         showPlotsForResult(m.cvres, colorby(cind, :));
         showPlotsForResult(m.testres, colorby(~cind, :));

      case 6   
         fprintf('6. Test set and cross-validation for data with factors and hidden values\n')   
         data = copy(odata);

         for i = 1:numel(factorCols);
            data.factor(factorCols{i}, factorLevels{i});
         end

         data.excludecols(excludedCols);    

         if isa(data, 'mdaimage')
            cdata = data(cind, :, :);
            tdata = data(~cind, :, :);   
         else   
            cdata = data(cind, :);
            tdata = data(~cind, :);   
         end   

         exRows = data.excludedRows;
         exRows(excludedRows) = true;

         cdata.excluderows(exRows(cind));
         tdata.excluderows(exRows(~cind));

         m = mdapca(cdata, 4, 'Prep', p, 'Scale', scale, 'CV', {'rand', 4, 1}, 'TestSet', tdata);
         m.info = info;
         summary(m);
         summary(m.calres);
         summary(m.cvres);
         summary(m.testres);
         showPlotsForModel(m, 'rgb');

         if ~isa(data, 'mdaimage')
            showPlotsForResult(m.calres, colorby(~exRows & cind, :));
            showPlotsForResult(m.cvres, colorby(~exRows & cind, :));
            showPlotsForResult(m.testres, colorby(~exRows & ~cind, :));
         else
            showPlotsForResult(m.calres);
            showPlotsForResult(m.cvres);
            showPlotsForResult(m.testres);
         end
   end
end

function showPlotsForModel(m, col)
   if nargin < 2
      col = 'r';
   end
   
   % overview plot
   figure('Name', 'Model overview')
   plot(m)

   % scores plots
   figure('Name', 'Scores')
   subplot(2, 2, 1)
   plotscores(m);
   subplot(2, 2, 2)
   plotscores(m, [1 3], 'Labels', 'names');
   subplot(2, 2, 3)
   plotscores(m, [1 3], 'Labels', 'names');
   subplot(2, 2, 4)
   plotscores(m, 2, 'Labels', 'names', 'Legend', 'on', 'ShowExcluded', 'on');
   
   figure('Name', 'Loadings')
   subplot(2, 2, 1)
   plotloadings(m)
   subplot(2, 2, 2)
   plotloadings(m, [1 3], 'Labels', 'names')
   subplot(2, 2, 3)
   plotloadings(m, [1 2 3], 'Type', 'line', 'Marker', '.')
   subplot(2, 2, 4)
   plotloadings(m, [1 2 3], 'Type', 'bar')

   % explained variance plots
   figure('Name', 'Explained variance plots')
   subplot(2, 2, 1)
   plotexpvar(m)
   subplot(2, 2, 2)
   plotexpvar(m, 'Type', 'line', 'Marker', '.', 'Color', col)
   subplot(2, 2, 3)
   plotcumexpvar(m)
   subplot(2, 2, 4)
   plotcumexpvar(m, 'Type', 'line', 'Marker', '.', 'Color', col)

   % residuals plots
   figure('Name', 'Residuals plots')
   subplot(2, 2, 1)
   plotresiduals(m);
   subplot(2, 2, 2)
   plotresiduals(m, 4, 'Labels', 'names');
   subplot(2, 2, 3)
   plotresiduals(m);
   subplot(2, 2, 4)
   plotresiduals(m, 4, 'Labels', 'names', 'Legend', 'off', 'ShowExcluded', 'on');
   drawnow;   
end

function showPlotsForResult(res, colorby)
   if nargin < 2
      colorby = [];
   end
      
   % plot overview
   figure('Name', 'Overview')
   plot(res)
      
   % scores plots
   figure('Name', 'Scores')
   subplot(2, 2, 1)
   plotscores(res, [1 2], 'Labels', 'names');
   subplot(2, 2, 2)
   plotscores(res, 3, 'Labels', 'names', 'Colorby', colorby, 'ShowExcluded', 'on');
   subplot(2, 2, 3)
   plotscores(res, [1 2], 'Type', 'densscatter');
   subplot(2, 2, 4)
   if isa(res.scores, 'mdaimage')
      plotscores(res, [1 2], 'Type', 'density');
   else   
      plotscores(res, 2, 'Type', 'scatter');
   end
   
   % residuals and variance plots
   figure('Name', 'Residuals and explained variance')
   subplot(2, 2, 1)
   plotresiduals(res)
   subplot(2, 2, 2)
   plotresiduals(res, 3, 'Colorby', colorby, 'ShowExcluded', 'on')
   subplot(2, 2, 3)
   plotcumexpvar(res, 'Type', 'bar')
   subplot(2, 2, 4)
   plotexpvar(res, 'Type', 'bar', 'Labels', 'values')

   % plots for images
   if ~isempty(res.scores) && isa(res.scores, 'mdaimage') 
      figure('Name', 'Density scores and images')
      subplot(2, 2, 1)
      plotscores(res, [1 3], 'Type', 'density')
      subplot(2, 2, 2)
      imagesc(res.scores(:, :, 1))
      subplot(2, 2, 3)
      imagesc(res.Q2(:, :, 1))
      subplot(2, 2, 4)
      imagesc(res.T2(:, :, 1))
   end
   
   % combination of plots
   figure('Name', 'Combination of plots')
   hold on
   plotexpvar(res, 'Type', 'bar', 'Labels', 'values')
   plotcumexpvar(res, 'Type', 'line', 'Color', 'r')
   hold off
   drawnow;
   
end

