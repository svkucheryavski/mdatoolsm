function m = test_simca(type, casen)
   clc
   clear

   if nargin < 1
      type = 'people';
   end
   
   if nargin < 2
      casen = 5;
   end
   
   switch type
      case 'people'
         ncomp = 2;
         d = load('people');
         d.people.sort('Region', 'descend')         
         oX = d.people(:, 1:10);
         oc = d.people(:, 11);
         oc.factor(1, {'A', 'B'});
         info = 'Model for People data';   
         factorCols = {'Sex'};
         factorLevels = { {'Male', 'Female'}};
         excludedCols = {'Income'};
         excludedRows = 1:8:32;
         cind = d.people(:, 'Region') == -1;
         scale = 'on';
         center = 'on';
         cname = 'A';
         p = prep();
   end      
   
   exR = false(oX.nRows, 1);
   exR(excludedRows) = true;
   excludedRows = exR;
         
   Xc = oX(cind, :);
   cc = oc(cind, :);

   Xt = oX;
   ct = oc;
      
   switch casen
      case 1
         fprintf('1. Testing simple model\n')   
         
         m = mdasimca(Xc, cname, ncomp, 'Center', center, 'Scale', scale);
         m.info = info;   
         showPlotsForResult(m.calres, cname, 'Calibration');      
         showPlotsForModel(m, cname);
         
      case 2
         fprintf('2. Testing data with excluded colums and rows\n')   
         
         for i = 1:numel(factorCols);
            Xc.factor(factorCols{i}, factorLevels{i});
         end
         
         Xc.excludecols(excludedCols);
         Xc.excluderows(excludedRows(cind));
         cc.excluderows(excludedRows(cind));

         m = mdasimca(Xc, cname, ncomp, 'Center', center, 'Scale', scale);
         m.info = info;

         summary(m);
         summary(m.calres);
         showPlotsForModel(m, cname);   
         showPlotsForResult(m.calres, cname, 'Calibration');
   
      case 3
         fprintf('3. Test set validation\n')   
         m = mdasimca(Xc, cname, ncomp, 'TestSet', {Xt, ct}, 'Scale', scale);
         m.info = info;
         summary(m);
         summary(m.calres);
         summary(m.testres);
         
         showPlotsForResult(m.calres, cname, 'Calibration');
         showPlotsForResult(m.testres, cname, 'Test');
         showPlotsForModel(m, cname);

      case 4
         fprintf('4. Cross-validation\n')   

         m = mdasimca(Xc, cname, ncomp, 'CV', {'rand', 8, 8}, 'Scale', scale);
         m.info = info;
         summary(m);
         summary(m.calres);
         summary(m.cvres);
         showPlotsForResult(m.calres, cname, 'Calibration');
         showPlotsForResult(m.cvres, cname, 'Cross-validation');
         showPlotsForModel(m, cname);

      case 5
         fprintf('5. Test set and cross-validation for data with factors and hidden values\n')   

         for i = 1:numel(factorCols);
            Xc.factor(factorCols{i}, factorLevels{i});
            Xt.factor(factorCols{i}, factorLevels{i});
         end
         Xc.excludecols(excludedCols);      
         Xt.excludecols(excludedCols);      

         Xc.excluderows(excludedRows(cind));
         cc.excluderows(excludedRows(cind));

         Xt.excluderows(excludedRows(~cind));
         ct.excluderows(excludedRows(~cind));
         
         m = mdasimca(Xc, cname, ncomp, 'TestSet', {Xt, ct}, 'CV', {'rand', 8, 4}, 'Prep', ...
            p, 'Scale', scale);
         m.info = info;
         
         plotclassification(m, 'Labels', 'names', 'ShowExcluded', 'on');
         showPlotsForModel(m, cname);
         showPlotsForResult(m.calres, cname, 'Cal');
         showPlotsForResult(m.cvres, cname, 'CV');
         showPlotsForResult(m.testres, cname, 'Test');
   end
end

function showPlotsForModel(m, cname)
   
   summary(m)
   
   % overview plot
   figure('Name', 'Model overview')
   plot(m)

   % prediction and regcoeffs plots
   plotclassification(m);
   plotclassification(m, cname);
   plotclassification(m, cname, 1);
   
   figure('Name', 'Model: loadings')
   subplot(2, 2, 1)
   plotloadings(m);
   subplot(2, 2, 2)
   plotloadings(m, 1 ,'Type', 'line');
   subplot(2, 2, 3)
   plotloadings(m, 1:2, 'Type', 'line');
   subplot(2, 2, 4)
   plotloadings(m, 1, 'Type', 'bar', 'Labels', 'names');

   figure('Name', 'Model: Y residuals')
   subplot(2, 2, 1)
   plotresiduals(m);
   subplot(2, 2, 2)
   plotresiduals(m, 2, 'Labels', 'names');
   subplot(2, 2, 3)
   plotresiduals(m, 1, 2, 'Labels', 'names');
   subplot(2, 2, 4)
   plotresiduals(m, 1, 'Labels', 'names', 'ShowExcluded', 'on');

   % Scores
   figure('Name', 'Model: scores')
   subplot(2, 2, 1)
   plotscores(m);
   subplot(2, 2, 2)
   plotscores(m, [1 2], 'Labels', 'names', 'ShowExcluded', 'on');
   subplot(2, 2, 3)
   plotscores(m);
   subplot(2, 2, 4)
   plotscores(m, 1, 'Labels', 'names', 'ShowExcluded', 'on');
   
   % explained variance for X
   figure('Name', 'Model: explained variance for X')
   subplot(2, 2, 1)
   plotexpvar(m);
   subplot(2, 2, 2)
   plotexpvar(m, 'Type', 'bar');
   subplot(2, 2, 3)
   plotcumexpvar(m);
   subplot(2, 2, 4)
   plotcumexpvar(m, 'Type', 'bar');
   
   % Performance
   figure('Name', 'Model: performance')
   subplot(2, 2, 1)
   plotmisclassified(m, 1);
   subplot(2, 2, 2)
   plotmisclassified(m, cname, 'Type', 'bar');
   subplot(2, 2, 3)
   plotsensitivity(m, 1)
   subplot(2, 2, 4)
   plotspecificity(m, cname, 'Labels', 'names')

end

function showPlotsForResult(res, cname, name)
   summary(res)
      
   % plot overview
   figure('Name', sprintf('Result overview (%s)', name))
   plot(res)
      
   % prediction and regcoeffs plots
   figure('Name', sprintf('Result: predictions (%s)', name))
   subplot(2, 2, 1)
   plotresiduals(res);
   subplot(2, 2, 2)
   plotclassification(res, 'Labels', 'names', 'ShowExcluded', 'on');
   subplot(2, 2, 3)
   plotresiduals(res, 1);
   subplot(2, 2, 4)
   plotclassification(res, 'Labels', 'names', 'ShowExcluded', 'on');

   % Performance
   figure('Name', sprintf('Results: performance (%s)', name))
   subplot(2, 2, 1)
   plotmisclassified(res, cname);
   subplot(2, 2, 2)
   plotmisclassified(res, 1, 'Type', 'bar', 'Labels', 'values');
   subplot(2, 2, 3)
   plotsensitivity(res, res.nClasses)
   subplot(2, 2, 4)
   plotspecificity(res, cname)
   
end

