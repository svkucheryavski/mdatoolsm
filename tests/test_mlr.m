function test_mlr(type, casen)
   clc
   close all

   if nargin < 1
      type = 'people';
   end
   
   if nargin < 2
      casen = 5;
   end
   
   switch type
      case 'people'
         d = load('people');
         oX = d.people(:, [1, 3:12]);
         oy = d.people(:, 2);
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
         d = load('simdata');
         oX = d.spectra(:, 1:2:end);
         oy = d.conc(:, 1);
         scale = 'on';
         info = 'Model for UV/Vis spectra (simdata)';
         factorCols = {};
         factorLevels = {};
         excludedCols = 1:20;
         excludedRows = 1:5:150;
         cind = true(oX.nRows, 1);
         cind(101:150) = false;  
         p = prep();
   end      
   
   exR = false(oX.nRows, 1);
   exR(excludedRows) = true;
   excludedRows = exR;
         
   switch casen
      case 1
         fprintf('1. Testing simple model\n')   
         X = copy(oX);
         y = copy(oy);

         m = mdamlr(X, y, 'Center', center, 'Scale', scale);
         m.info = info;   
         summary(m.calres)   
         showPlotsForModel(m);
         showPlotsForResult(m.calres);
      
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

         m = mdamlr(X, y, 'Center', center, 'Scale', scale);
         m.info = info;

         summary(m);
         summary(m.calres);
         showPlotsForModel(m);   
         showPlotsForResult(m.calres);
   
      case 3
         fprintf('3. Test set validation\n')   
         X = copy(oX);
         y = copy(oy);

         Xc = X(cind, :);
         yc = y(cind, :);

         Xt = X(~cind, :);
         yt = y(~cind, :);

         m = mdamlr(Xc, yc, 'TestSet', {Xt, yt}, 'Scale', scale);
         m.info = info;
         summary(m);
         summary(m.calres);
         summary(m.testres);
         showPlotsForModel(m, 'mcg');
         showPlotsForResult(m.calres);
         showPlotsForResult(m.testres);

      case 4
         fprintf('4. Cross-validation\n')   
         X = copy(oX);
         y = copy(oy);

         m = mdamlr(X, y, 'CV', {'rand', 4, 28}, 'Scale', scale);
         m.info = info;
         summary(m);
         summary(m.calres);
         summary(m.cvres);
         showPlotsForModel(m, 'mcg');
         showPlotsForResult(m.calres);
         showPlotsForResult(m.cvres);

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

         m = mdamlr(Xc, yc, 'TestSet', {Xt, yt}, 'CV', {'rand', 8, 4}, 'Prep', {p, prep()}, 'Scale', scale);
         m.info = info;

         summary(m);
         summary(m.calres);
         summary(m.cvres);
         summary(m.testres);
         showPlotsForModel(m, 'mcg');
         showPlotsForResult(m.calres);
         showPlotsForResult(m.cvres);
         showPlotsForResult(m.testres);
   end
end

function showPlotsForModel(m, col)
   if nargin < 2
      col = 'r';
   end
   
   show(m.regcoeffs.values)
   show(m.regcoeffs.values(1:5, 1, 1))
   
   summary(m.regcoeffs)
   summary(m.regcoeffs, 1, 1)
   
   summary(m)
   
   % overview plot
   figure('Name', 'Model overview')
   plot(m)

   % prediction and regcoeffs plots
   figure('Name', 'Model: predictions and coefficients')
   subplot(2, 2, 1)
   plotpredictions(m);
   subplot(2, 2, 2)
   plotpredictions(m, 'Labels', 'names', 'Color', col, 'ShowExcluded', 'on');
   subplot(2, 2, 3)
   plotregcoeffs(m);
   subplot(2, 2, 4)
   plotregcoeffs(m, 'Type', 'bar', 'CI', 'off');

   figure('Name', 'Model: residuals')
   subplot(2, 2, 1)
   plotyresiduals(m);
   subplot(2, 2, 2)
   plotyresiduals(m, 'Labels', 'names', 'Color', col, 'ShowExcluded', 'on');
   
   drawnow;   
end

function showPlotsForResult(res)
   summary(res)
      
   % plot overview
   figure('Name', 'Result overview')
   plot(res)
      
   % prediction and regcoeffs plots
   figure('Name', 'Result: predictions and residuals')
   subplot(2, 2, 1)
   plotpredictions(res);
   subplot(2, 2, 2)
   plotpredictions(res, 'Labels', 'names', 'Colorby', res.ypred(:, 1, 1), 'ShowExcluded', 'on');
   subplot(2, 2, 3)
   plotyresiduals(res);
   subplot(2, 2, 4)
   plotyresiduals(res, 'Labels', 'names', 'ShowExcluded', 'on');
   
end

