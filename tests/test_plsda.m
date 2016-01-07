function test_plsda
   close all
   clear
   clc

   types = {'people'};
   cases = 1:6;
   
   if isdir(mfilename('fullpath'))
      rmdir(mfilename('fullpath'), 's')
   end
   mkdir(mfilename('fullpath'))
   
   for t = 1:numel(types)
      for c = 1:numel(cases)
         m = do_test(types{t}, cases(c));
      end
   end
   
   close all
end

function m = do_test(type, casen)
   close all
   clc

   if nargin < 1
      type = 'people';
   end
   
   if nargin < 2
      casen = 5;
   end
   
   switch type
      case 'people'
         ncomp = 3;
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
         cind = true(oX.nRows, 1);
         cind(1:4:end) = false;         
         scale = 'on';
         center = 'on';
         cname = 'B';
         p = prep();
   end      
   
   exR = false(oX.nRows, 1);
   exR(excludedRows) = true;
   excludedRows = exR;
         
   X = copy(oX);
   c = copy(oc);
   
   switch casen
      case 1
         fprintf('1. Testing simple model\n')   

         m = mdaplsda(X, c, cname, ncomp, 'Center', center, 'Scale', scale);
         m.info = info;   
         showPlotsForResult(m.calres, cname, 'case 1 - calres');      
         showPlotsForModel(m, cname, 'case 1');
         
      case 2
         fprintf('2. Testing data with excluded colums and rows\n')   
         
         for i = 1:numel(factorCols);
            X.factor(factorCols{i}, factorLevels{i});
         end
         
         X.excludecols(excludedCols);
         X.excluderows(excludedRows);
         c.excluderows(excludedRows);

         m = mdaplsda(X, c, cname, ncomp, 'Center', center, 'Scale', scale);
         m.info = info;

         summary(m);
         summary(m.calres);
         showPlotsForResult(m.calres, cname, 'case 2 - calres');
         showPlotsForModel(m, cname, 'case 2');   
   
      case 3
         fprintf('3. Test set validation\n')   
         Xc = X(cind, :);
         cc = c(cind, :);

         Xt = X(~cind, :);
         ct = c(~cind, :);

         m = mdaplsda(Xc, cc, cname, ncomp, 'TestSet', {Xt, ct}, 'Scale', scale);
         m.info = info;
         summary(m);
         summary(m.calres);
         summary(m.testres);
         showPlotsForResult(m.calres, cname, 'case 3 - calres');
         showPlotsForResult(m.testres, cname, 'case 3 - test');
         showPlotsForModel(m, cname, 'case 3');

      case 4
         fprintf('4. Cross-validation\n')   
         X = copy(oX);
         c = copy(oc);

         m = mdaplsda(X, c, cname, ncomp, 'CV', {'rand', 8, 8}, 'Scale', scale);
         m.info = info;
         summary(m);
         summary(m.calres);
         summary(m.cvres);
         showPlotsForResult(m.calres, cname, 'case 4 - calres');
         showPlotsForResult(m.cvres, cname, 'case 4 - cvres');
         showPlotsForModel(m, cname, 'case 4');

      case 5
         fprintf('5. Test set and cross-validation for data with factors and hidden values\n')   

         for i = 1:numel(factorCols);
            X.factor(factorCols{i}, factorLevels{i});
         end
         X.excludecols(excludedCols);      
         Xc = X(cind, :);
         cc = c(cind, :);
         
         Xt = X(~cind, :);
         ct = c(~cind, :);

         Xc.excluderows(excludedRows(cind));
         cc.excluderows(excludedRows(cind));

         Xt.excluderows(excludedRows(~cind));
         ct.excluderows(excludedRows(~cind));

         m = mdaplsda(Xc, cc, cname, ncomp, 'TestSet', {Xt, ct}, 'CV', {'rand', 8, 4}, 'Prep', {p, prep()}, 'Scale', scale);
         m.info = info;
         plotclassification(m, 'Labels', 'names', 'ShowExcluded', 'on');
         showPlotsForResult(m.calres, cname, 'case 5 - calres');
         showPlotsForResult(m.cvres, cname, 'case 5 - cvres');
         showPlotsForResult(m.testres, cname, 'case 5 - test');
         showPlotsForModel(m, cname, 'case 5');
      case 6
         fprintf('5. Prediction for a new data\n')   

         for i = 1:numel(factorCols);
            X.factor(factorCols{i}, factorLevels{i});
         end
         X.excludecols(excludedCols);      
         Xc = X(cind, :);
         cc = c(cind, :);
         
         Xt = X(~cind, :);
         ct = c(~cind, :);

         Xc.excluderows(excludedRows(cind));
         cc.excluderows(excludedRows(cind));

         Xt.excluderows(excludedRows(~cind));
         ct.excluderows(excludedRows(~cind));

         m = mdaplsda(Xc, cc, cname, ncomp, 'CV', {'rand', 8, 4}, 'Prep', {p, prep()}, 'Scale', scale);
         
         res1 = m.predict(Xt);
         res2 = m.predict(Xt, ct);
         res3 = m.predict(Xt, ct == cname);
         showPlotsForResult(res1, cname, 'case 6 - res1');
         showPlotsForResult(res2, cname, 'case 6 - res2');
         showPlotsForResult(res2, cname, 'case 6 - res3');

   end
end

function showPlotsForModel(m, cname, name)
   

   summary(m)
   name = [name ' model'];
   % overview plot
   figure('Name', 'Model overview')
   plot(m)
   printplot(gcf, [mfilename('fullpath') '/' name ' - model - overview.png'], [1024 768], 'png', '-r90');

   % prediction and regcoeffs plots
   figure('Name', 'Model: predictions')
   subplot(2, 2, 1)
   plotpredictions(m);   
   subplot(2, 2, 2)
   plotpredictions(m, 1, 1, 'Labels', 'names', 'ShowExcluded', 'on');
   printplot(gcf, [mfilename('fullpath') '/' name ' - model - predictions.png'], [1024 768], 'png', '-r90');

   plotclassification(m);
   printplot(gcf, [mfilename('fullpath') '/' name ' - model - classification.png'], [1024 768], 'png', '-r90');
   plotclassification(m, cname);
   plotclassification(m, cname, 2);
   
   figure('Name', 'Model: regression coefficients')
   subplot(2, 2, 1)
   plotregcoeffs(m);
   subplot(2, 2, 2)
   plotregcoeffs(m, 1,'Type', 'line');
   subplot(2, 2, 3)
   plotregcoeffs(m, 1, 2, 'Type', 'line');
   subplot(2, 2, 4)
   plotregcoeffs(m, 1, 'Type', 'bar', 'Labels', 'names', 'CI', 'off');
   printplot(gcf, [mfilename('fullpath') '/' name ' - model - regcoeffs.png'], [1024 768], 'png', '-r90');

   figure('Name', 'Model: Y residuals')
   subplot(2, 2, 1)
   plotyresiduals(m);
   subplot(2, 2, 2)
   plotyresiduals(m, 1, 'Labels', 'names');
   subplot(2, 2, 1)
   plotyresiduals(m, 1, 2, 'Labels', 'names');
   subplot(2, 2, 2)
   plotyresiduals(m, 1, 'Labels', 'names', 'ShowExcluded', 'on');
   printplot(gcf, [mfilename('fullpath') '/' name ' - model - residuals.png'], [1024 768], 'png', '-r90');

   % Scores
   figure('Name', 'Model: scores')
   subplot(2, 2, 1)
   plotxscores(m);
   subplot(2, 2, 2)
   plotxscores(m, [2 3], 'Labels', 'names', 'ShowExcluded', 'on');
   subplot(2, 2, 3)
   plotxyscores(m);
   subplot(2, 2, 4)
   plotxyscores(m, 1, 'Labels', 'names', 'ShowExcluded', 'on');
   printplot(gcf, [mfilename('fullpath') '/' name ' - model - scores.png'], [1024 768], 'png', '-r90');
   
   % explained variance for X
   figure('Name', 'Model: explained variance for X')
   subplot(2, 2, 1)
   plotxexpvar(m);
   subplot(2, 2, 2)
   plotxexpvar(m, 'Type', 'bar');
   subplot(2, 2, 3)
   plotxcumexpvar(m);
   subplot(2, 2, 4)
   plotxcumexpvar(m, 'Type', 'bar');
   printplot(gcf, [mfilename('fullpath') '/' name ' - model - xvar.png'], [1024 768], 'png', '-r90');

   % explained variance for Y
   figure('Name', 'Model: explained variance for Y')
   subplot(2, 2, 1)
   plotyexpvar(m);
   subplot(2, 2, 2)
   plotyexpvar(m, 'Type', 'bar');
   subplot(2, 2, 3)
   plotycumexpvar(m);
   subplot(2, 2, 4)
   plotycumexpvar(m, 'Type', 'bar');
   printplot(gcf, [mfilename('fullpath') '/' name ' - model - yvar.png'], [1024 768], 'png', '-r90');
   
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
   printplot(gcf, [mfilename('fullpath') '/' name ' - model - preformance.png'], [1024 768], 'png', '-r90');

end

function showPlotsForResult(res, cname, name)
   summary(res)
      
   % plot overview
   figure('Name', sprintf('Result overview (%s)', name))
   plot(res)
      
   % prediction and regcoeffs plots
   figure('Name', sprintf('Result: predictions (%s)', name))
   subplot(2, 2, 1)
   plotpredictions(res);
   subplot(2, 2, 2)
   plotclassification(res, 'Labels', 'names', 'ShowExcluded', 'on');
   subplot(2, 2, 3)
   plotpredictions(res, cname);
   subplot(2, 2, 4)
   plotclassification(res, 'Labels', 'names', 'ShowExcluded', 'on');
   printplot(gcf, [mfilename('fullpath') '/' name ' - results - predictions.png'], [1024 768], 'png', '-r90');

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
   printplot(gcf, [mfilename('fullpath') '/' name ' - results - performance.png'], [1024 768], 'png', '-r90');
   
end

