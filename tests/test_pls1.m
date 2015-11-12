function test_pls1
   close all
   clear
   clc

   types = {'people', 'spectra'};
   cases = 1:5;
   
   if isdir(mfilename('fullpath'))
      rmdir(mfilename('fullpath'), 's')
   end
   mkdir(mfilename('fullpath'))
   
   for t = 1:numel(types)
      for c = 1:numel(cases)
         m = do_test(types{t}, cases(c));
      end
   end
   
end

function m = do_test(type, casen)
   close all

   if nargin < 1
      type = 'spectra';
   end
   
   if nargin < 2
      casen = 5;
   end
   
   switch type
      case 'people'
         ncomp = 3;
         d = load('people');
         oX = d.people(:, [2:12]);
         oy = d.people(:, 1);
         info = 'Model for People data';   
         factorCols = {'Sex', 'Region'};
         factorLevels = { {'Male', 'Female'}, {'A', 'B'} };
         excludedCols = {'Income'};
         excludedRows = 1:8:32;
         cind = true(oX.nRows, 1);
         cind(1:4:end) = false;         
         scale = 'on';
         center = 'on';
         p = prep();
      case 'spectra'
         ncomp = 3;
         d = load('simdata');
         oX = d.spectra;
         oy = d.conc(:, 3);
         info = 'Model for UV/Vis spectra (simdata)';
         factorCols = {};
         factorLevels = {};
         scale = 'off';
         center = 'on';
         excludedCols = 1:20;
         excludedRows = 1:5:150;
         cind = true(oX.nRows, 1);
         cind(101:150) = false;  
         p = prep();
   end      
   
   exR = false(oX.nRows, 1);
   exR(excludedRows) = true;
   excludedRows = exR;

   cname = [type ' ' num2str(casen)];
   
   switch casen
      case 1
         fprintf('1. Testing simple model\n')   
         X = copy(oX);
         y = copy(oy);

         m = mdapls(X, y, ncomp, 'Center', center, 'Scale', scale);
         m.info = info;   
         summary(m.calres)   
         showPlotsForResult(m.calres, 'calres', cname);
         showPlotsForModel(m, [], cname);
      
      case 2
         fprintf('2. Testing data with excluded colums and rows\n')   
         X = copy(oX);
         y = copy(oy);
         for i = 1:numel(factorCols);
            X.factor(factorCols{i}, factorLevels{i});
         end
         X.excludecols(excludedCols);      
         X.excluderows(excludedRows);
         y.excluderows(excludedRows);

         m = mdapls(X, y, ncomp, 'Center', center, 'Scale', scale);
         m.info = info;

         summary(m);
         summary(m.calres);
         showPlotsForModel(m, [], cname);   
         showPlotsForResult(m.calres, 'calres', cname);
   
      case 3
         fprintf('3. Test set validation\n')   
         X = copy(oX);
         y = copy(oy);

         Xc = X(cind, :);
         yc = y(cind, :);

         Xt = X(~cind, :);
         yt = y(~cind, :);

         m = mdapls(Xc, yc, ncomp, 'TestSet', {Xt, yt}, 'Scale', scale);
         m.info = info;
         summary(m);
         summary(m.calres);
         summary(m.testres);
         showPlotsForResult(m.calres, 'calres', cname);
         showPlotsForResult(m.testres, 'cvres', cname);
         showPlotsForModel(m, 'mcg', cname);

      case 4
         fprintf('4. Cross-validation\n')   
         X = copy(oX);
         y = copy(oy);

         m = mdapls(X, y, ncomp, 'CV', {'rand', 8, 8}, 'Scale', scale);
         m.info = info;
         summary(m);
         summary(m.calres);
         summary(m.cvres);
         showPlotsForModel(m, 'mcg', cname);
         showPlotsForResult(m.calres, 'calres', cname);
         showPlotsForResult(m.cvres, 'cvres', cname);

      case 5
         fprintf('5. Test set and cross-validation for data with factors and hidden values\n')   
         X = copy(oX);
         y = copy(oy);
         for i = 1:numel(factorCols);
            X.factor(factorCols{i}, factorLevels{i});
         end
         X.excludecols(excludedCols);      

         Xc = X(cind, :);
         yc = y(cind, :);

         Xt = X(~cind, :);
         yt = y(~cind, :);

         Xc.excluderows(excludedRows(cind));
         yc.excluderows(excludedRows(cind));

         Xt.excluderows(excludedRows(~cind));
         yt.excluderows(excludedRows(~cind));

         m = mdapls(Xc, yc, ncomp, 'TestSet', {Xt, yt}, 'CV', {'full'}, 'Prep', {p, prep()}, 'Scale', scale);
         m.info = info;

         showPlotsForModel(m, 'mcg', cname);
         showPlotsForResult(m.calres, 'calres', cname);
         showPlotsForResult(m.cvres, 'cvres', cname);
         showPlotsForResult(m.testres, 'testres', cname);
   end
end

function showPlotsForModel(m, col, name)
   if nargin < 2 || isempty(col)
      col = 'r';
   end
   
   summary(m)
   
   % overview plot
   f = figure('Visible', 'off');
   plot(m);
   printplot(f, [mfilename('fullpath') '/' name ' - plsmodel - overview.png'], [1024 768], 'png', '-r90');

   % prediction and regcoeffs plots
   f = figure('Visible', 'off');
   subplot(2, 2, 1)
   plotpredictions(m);   
   subplot(2, 2, 2)
   plotpredictions(m, 1, 'Labels', 'names', 'ShowExcluded', 'on');
   subplot(2, 2, 3)
   plotpredictions(m, 1, 1);   
   subplot(2, 2, 4)
   plotpredictions(m, 2, 'Labels', 'names', 'ShowExcluded', 'on');
   printplot(f, [mfilename('fullpath') '/' name ' - plsmodel - predictions.png'], [1024 768], 'png', '-r90');
   
   f = figure('Visible', 'off');
   subplot(2, 2, 1)
   plotregcoeffs(m);
   subplot(2, 2, 2)
   plotregcoeffs(m, 1,'Type', 'line', 'CI', 'on');
   subplot(2, 2, 3)
   plotregcoeffs(m, 1, 2, 'Type', 'line');
   subplot(2, 2, 4)
   plotregcoeffs(m, 1, 'Type', 'bar', 'Labels', 'names', 'CI', 'off');
   printplot(f, [mfilename('fullpath') '/' name ' - plsmodel - regcoeffs.png'], [1024 768], 'png', '-r90');

   f = figure('Visible', 'off');
   subplot(2, 2, 1)
   plotyresiduals(m);
   subplot(2, 2, 2)
   plotyresiduals(m, 1, 'Labels', 'names');
   subplot(2, 2, 1)
   plotyresiduals(m, 1, 2, 'Labels', 'names');
   subplot(2, 2, 2)
   plotyresiduals(m, 1, 'Labels', 'names', 'Color', col, 'ShowExcluded', 'on');
   printplot(f, [mfilename('fullpath') '/' name ' - plsmodel - yresiduals.png'], [1024 768], 'png', '-r90');

   % Scores
   f = figure('Visible', 'off');
   subplot(2, 2, 1)
   plotxscores(m);
   subplot(2, 2, 2)
   plotxscores(m, [2 3], 'Labels', 'names', 'ShowExcluded', 'on');
   subplot(2, 2, 3)
   plotxyscores(m);
   subplot(2, 2, 4)
   plotxyscores(m, 1, 'Labels', 'names', 'ShowExcluded', 'on');
   printplot(f, [mfilename('fullpath') '/' name ' - plsmodel - scores.png'], [1024 768], 'png', '-r90');
   
   % explained variance for X
   f = figure('Visible', 'off');
   subplot(2, 2, 1)
   plotxexpvar(m);
   subplot(2, 2, 2)
   plotxexpvar(m, 'Type', 'bar');
   subplot(2, 2, 3)
   plotxcumexpvar(m);
   subplot(2, 2, 4)
   plotxcumexpvar(m, 'Type', 'bar');
   printplot(f, [mfilename('fullpath') '/' name ' - plsmodel - xexpvar.png'], [1024 768], 'png', '-r90');

   % explained variance for Y
   f = figure('Visible', 'off');
   subplot(2, 2, 1)
   plotyexpvar(m);
   subplot(2, 2, 2)
   plotyexpvar(m, 'Type', 'bar');
   subplot(2, 2, 3)
   plotycumexpvar(m);
   subplot(2, 2, 4)
   plotycumexpvar(m, 'Type', 'bar');
   printplot(f, [mfilename('fullpath') '/' name ' - plsmodel - yexpvar.png'], [1024 768], 'png', '-r90');
   
   % RMSE
   f = figure('Visible', 'off');
   subplot(2, 2, 1)
   plotrmse(m);
   subplot(2, 2, 2)
   plotrmse(m, 'Type', 'bar');
   subplot(2, 2, 3)
   plotxresiduals(m)
   subplot(2, 2, 4)
   plotxresiduals(m, 'Labels', 'names')
   printplot(f, [mfilename('fullpath') '/' name ' - plsmodel - rmse and xresid.png'], [1024 768], 'png', '-r90');

   % Vipscores and selratio
   f = figure('Visible', 'off');
   subplot(2, 2, 1)
   plotvipscores(m);
   subplot(2, 2, 2)
   plotvipscores(m, 1, 'Type', 'line');
   subplot(2, 2, 3)
   plotselratio(m);
   subplot(2, 2, 4)
   plotselratio(m, 1, 'Type', 'line');
   printplot(f, [mfilename('fullpath') '/' name ' - plsmodel - varsel.png'], [1024 768], 'png', '-r90');

   delete(f);
end

function showPlotsForResult(res, name, cname)
   summary(res)
      
   % plot overview
   f = figure('Visible', 'off');
   plot(res)
   printplot(f, [mfilename('fullpath') '/' cname ' - pls - ' name ' - overview'], [1024 768], 'png', '-r90');
      
   % prediction and regcoeffs plots
   f = figure('Visible', 'off');
   subplot(2, 2, 1)
   plotpredictions(res);
   subplot(2, 2, 2)
   plotpredictions(res, 'Labels', 'names', 'Colorby', res.ypred(1:end, 1, 1), 'ShowExcluded', 'on');
   subplot(2, 2, 3)
   plotyresiduals(res);
   subplot(2, 2, 4)
   plotyresiduals(res, 'Labels', 'names', 'ShowExcluded', 'on');
   printplot(f, [mfilename('fullpath') '/' cname ' - pls - ' name ' - predictions and yresiduals'], [1024 768], 'png', '-r90');

   % Scores
   f = figure('Visible', 'off');
   subplot(2, 2, 1)
   plotxscores(res);
   subplot(2, 2, 2)
   plotxscores(res, [2 3], 'Labels', 'names', 'Colorby', res.ypred(1:end, 1, 1), 'ShowExcluded', 'on');
   subplot(2, 2, 3)
   plotxyscores(res);
   subplot(2, 2, 4)
   plotxyscores(res, 2, 'Labels', 'names', 'Colorby', res.ypred(1:end, 1, 1), 'ShowExcluded', 'on');
   printplot(f, [mfilename('fullpath') '/' cname ' - pls - ' name ' - scores'], [1024 768], 'png', '-r90');
   
   % explained variance for X
   f = figure('Visible', 'off');
   subplot(2, 2, 1)
   plotxexpvar(res);
   subplot(2, 2, 2)
   plotxexpvar(res, 'Type', 'bar', 'Labels', 'values', 'FaceColor', 'r');
   subplot(2, 2, 3)
   plotxcumexpvar(res);
   subplot(2, 2, 4)
   plotxcumexpvar(res, 'Type', 'bar', 'Labels', 'values', 'FaceColor', 'r');
   printplot(f, [mfilename('fullpath') '/' cname ' - pls - ' name ' - xexpvar'], [1024 768], 'png', '-r90');

   % explained variance for Y
   f = figure('Visible', 'off');
   subplot(2, 2, 1)
   plotyexpvar(res);
   subplot(2, 2, 2)
   plotyexpvar(res, 'Type', 'bar', 'Labels', 'values', 'FaceColor', 'r');
   subplot(2, 2, 3)
   plotycumexpvar(res);
   subplot(2, 2, 4)
   plotycumexpvar(res, 'Type', 'bar', 'Labels', 'values', 'FaceColor', 'r');
   printplot(f, [mfilename('fullpath') '/' cname ' - pls - ' name ' - yexpvar'], [1024 768], 'png', '-r90');
   
   % RMSE
   f = figure('Visible', 'off');
   subplot(2, 2, 1)
   plotrmse(res);
   subplot(2, 2, 2)
   plotrmse(res, 'Type', 'bar', 'Labels', 'values', 'FaceColor', 'r');
   subplot(2, 2, 3)
   plotxresiduals(res)
   subplot(2, 2, 4)
   plotxresiduals(res, 'Labels', 'names', 'Color', 'r')
   printplot(f, [mfilename('fullpath') '/' cname ' - pls - ' name ' - rmse and xresiduals'], [1024 768], 'png', '-r90');
   
   delete(f);
end

