%% added 22.10.2018 - new features - part 1
% Special code for testing new features - colValues, rowValues

close all
clear
clc

load simdata

indc = 1:2:150;
indv = 2:2:150;

sp = cell(6, 1);
cn = cell(6, 1);
sp{1} = mdadata(spectra.values, round(log(2:151), 3), 210:360, {'Time', 'Wavelength, nm'});
cn{1} = conc(:, 1);
sp{2} = sp{1}';
cn{2} = mdadata((210:360)');
sp{3} = sp{2}';
cn{3} = conc(:, 3);
sp{4} = mdadata(spectra.values, {}, {}, {'Object #', 'Variable #'});
cn{4} = conc(:, 1);
sp{5} = sp{4}';
cn{5} = mdadata((210:360)');
sp{6} = sp{5}';
cn{6} = conc(:, 3);

% original spectra
figure
for i = 1:numel(sp)
   subplot(3, 2, i), plot(sp{i})
end

% subset of rows
figure
for i = 1:numel(sp)
   s = sp{i};
   subplot(3, 2, i), plot(s(1:10, :));
end

% subset of columns
figure
for i = 1:numel(sp)
   s = sp{i};
   subplot(3, 2, i), plot(s(:, 20:100));
end

% subset of rows and columns
figure
for i = 1:numel(sp)
   s = sp{i};
   subplot(3, 2, i), plot(s(30:100, 20:100));
end


% subset of rows and concat
figure
for i = 1:numel(sp)
   s = sp{i};
   subplot(3, 2, i), plot([s(1:10, :); s(50:80, :)]);
end

% subset of columns and concat
figure
for i = 1:numel(sp)
   s = sp{i};
   subplot(3, 2, i), plot([s(:, 20:80), s(:, 100:end)]);
end

%% new features - part 2

% excluded rows
figure
for i = 1:numel(sp)
   s = sp{i};
   s.excluderows(20:80);
   subplot(3, 2, i), plot(s)
   s.includerows(1:150);
end

% excluded columns
figure
for i = 1:numel(sp)
   s = sp{i};
   s.excludecols(20:80);
   subplot(3, 2, i), plot(s)
   s.includecols(1:150);
end

% excluded columns
figure
for i = 1:numel(sp)
   s = sp{i};
   s.excludecols(20:80);
   subplot(3, 2, i), plot(s, 'ShowExcluded', 'on')
   s.includecols(1:150);
end

%% stats and math

fns = {@std, @var, @min, @max, @sum, @mean, @median};

for fn = fns
   f = fn{1};
   figure
   for i = 1:numel(sp)
      s = sp{i};
      subplot(3, 2, i), plot(f(s))
   end
end

%% bar, boxplot, errorbar, qqplot and hist

fns = {@bar, @boxplot, @errorbar, @qqplot, @hist};

for fn = fns
   f = fn{1};
   figure
   for i = 1:numel(sp)
      s = sp{i};
      subplot(3, 2, i), f(s)
   end
end

%% PCA - only calibration set

close all
clc
for i = 1:numel(sp)
   s = sp{i};
   m = mdapca(s, 5, 'Scale', 'on');
   figure
   subplot 431, plotloadings(m, 'Labels', 'names')
   subplot 432, plotloadings(m, 'Type', 'line')
   subplot 433, plotloadings(m, 'Type', 'bar')
   subplot 434, plotscores(m, [1,2], 'Labels', 'names')
   subplot 435, plotscores(m, [1,2], 'Type', 'line')
   subplot 436, plotscores(m, [1,2], 'Type', 'bar')
   subplot 437, plotresiduals(m, 'Labels', 'names')
   subplot 438, plotcumexpvar(m)
   subplot 439, plotcumexpvar(m, 'Type', 'bar', 'Labels', 'values')
   subplot(4,3,10), plotexpvar(m)
   subplot(4,3,11), plotexpvar(m, 'Type', 'bar', 'Labels', 'values')
end

%% PCA - cross-validation

close all
clc
for i = 1:numel(sp)
   s = sp{i};
   m = mdapca(s, 5, 'Scale', 'on', 'CV', {'full'});
   figure
   subplot 431, plotloadings(m, 'Labels', 'names')
   subplot 432, plotloadings(m, 'Type', 'line')
   subplot 433, plotloadings(m, 'Type', 'bar')
   subplot 434, plotscores(m, [1,2], 'Labels', 'names')
   subplot 435, plotscores(m, [1,2], 'Type', 'line')
   subplot 436, plotscores(m, [1,2], 'Type', 'bar')
   subplot 437, plotresiduals(m, 'Labels', 'names')
   subplot 438, plotcumexpvar(m)
   subplot 439, plotcumexpvar(m, 'Type', 'bar', 'Labels', 'values')
   subplot(4,3,10), plotexpvar(m)
   subplot(4,3,11), plotexpvar(m, 'Type', 'bar', 'Labels', 'values')
end

%% PCA - test set

close all
clc
for i = 1:numel(sp)
   s = sp{i};
   m = mdapca(s(indc, :), 5, 'TestSet', s(indv, :));
   figure
   subplot 431, plotloadings(m, 'Labels', 'names')
   subplot 432, plotloadings(m, 'Type', 'line')
   subplot 433, plotloadings(m, 'Type', 'bar')
   subplot 434, plotscores(m, [1,2], 'Labels', 'names')
   subplot 435, plotscores(m, [1,2], 'Type', 'line')
   subplot 436, plotscores(m, [1,2], 'Type', 'bar')
   subplot 437, plotresiduals(m, 'Labels', 'names')
   subplot 438, plotcumexpvar(m)
   subplot 439, plotcumexpvar(m, 'Type', 'bar', 'Labels', 'values')
   subplot(4,3,10), plotexpvar(m)
   subplot(4,3,11), plotexpvar(m, 'Type', 'bar', 'Labels', 'values')
end

%% PCA - cross-validation and test set

close all
clc
for i = 1:numel(sp)
   s = sp{i};
   m = mdapca(s(indc, :), 5, 'TestSet', s(indv, :), 'CV', {'full'});
   figure
   subplot 431, plotloadings(m, 'Labels', 'names')
   subplot 432, plotloadings(m, 'Type', 'line')
   subplot 433, plotloadings(m, 'Type', 'bar')
   subplot 434, plotscores(m, [1,2], 'Labels', 'names')
   subplot 435, plotscores(m, [1,2], 'Type', 'line')
   subplot 436, plotscores(m, [1,2], 'Type', 'bar')
   subplot 437, plotresiduals(m, 'Labels', 'names')
   subplot 438, plotcumexpvar(m)
   subplot 439, plotcumexpvar(m, 'Type', 'bar', 'Labels', 'values')
   subplot(4,3,10), plotexpvar(m)
   subplot(4,3,11), plotexpvar(m, 'Type', 'bar', 'Labels', 'values')
end


%% PLS - variable based plots

type = 4;
close all
clc
for i = 1:numel(sp)
   s = sp{i}; c = cn{i};
   
   if type == 1
      m = mdapls(s, c, 5);
   elseif type == 2
      m = mdapls(s, c, 5, 'CV', {'full'});
   elseif type == 3
      m = mdapls(s(indc, :), c(indc, :), 5, 'TestSet', {s(indv, :), c(indv, :)});      
   else
      m = mdapls(s(indc, :), c(indc, :), 5, 'CV', {'full'}, 'TestSet', {s(indv, :), c(indv, :)});      
   end
   
   figure
   subplot 531, plotregcoeffs(m)
   subplot 532, plotregcoeffs(m, 1, 2, 'Type', 'line')
   subplot 533, plotregcoeffs(m, 1, 2, 'Type', 'bar')
   
   subplot 534, plotxloadings(m, 'Labels', 'names')
   subplot 535, plotxloadings(m, 'Type', 'line')
   subplot 536, plotxloadings(m, 'Type', 'bar')
   
   subplot 537, plotweights(m, 'Labels', 'names')
   subplot 538, plotweights(m, 1:3, 'Type', 'line')
   subplot 539, plotweights(m, 1:2, 'Type', 'bar')
   
   subplot(5, 3, 10), plotvipscores(m)
   subplot(5, 3, 11), plotvipscores(m, 'Type', 'line')
   subplot(5, 3, 12), plotvipscores(m, 'Type', 'bar')
   
   subplot(5, 3, 13), plotselratio(m)
   subplot(5, 3, 14), plotselratio(m, 'Type', 'line')
   subplot(5, 3, 15), plotselratio(m, 'Type', 'bar')
end

%% PLS - object based plots

type = 4;
close all
clc

for i = 1:numel(sp)
   s = sp{i}; c = cn{i};
   
   if type == 1
      m = mdapls(s, c, 5);
   elseif type == 2
      m = mdapls(s, c, 5, 'CV', {'full'});
      res = m.cvres;
   elseif type == 3
      m = mdapls(s(indc, :), c(indc, :), 5, 'TestSet', {s(indv, :), c(indv, :)});      
      res = m.testres;
   else
      m = mdapls(s(indc, :), c(indc, :), 5, 'CV', {'full'}, 'TestSet', {s(indv, :), c(indv, :)});
      res = m.testres;
   end
   
   figure
   subplot 531, plotxscores(m, 'Labels', 'names')
   subplot 532, plotxscores(m, 1:3, 'Type', 'line')
   subplot 533, plotxscores(m, 1:2, 'Type', 'bar')
   
   subplot 534, plotxyscores(m, 'Labels', 'names')
   subplot 535, plotxyscores(m, 1, 'Labels', 'names')
   subplot 536, gplot(m.calres.ydecomp.scores(:, 1:2)')
   
   subplot 537, plotxresiduals(m, 'Labels', 'names')
   subplot 538, gplot(res.xdecomp.T2(:, 1:2)')
   subplot 539, gplot(res.xdecomp.Q(:, 1:2)')
   
   subplot(5, 3, 10), plotyresiduals(m, 'Labels', 'names')
   subplot(5, 3, 11), plotyresiduals(m, c.getColLabels(1), 'Labels', 'names')
   subplot(5, 3, 12), gplot(res.ypred(1:end, 1, 1:2)' - m.calres.yref')
     
   subplot(5, 3, 13), plotpredictions(m, 'Labels', 'names')
   subplot(5, 3, 14), plotpredictions(m, c.getColLabels(1), 'Labels', 'names')
   subplot(5, 3, 15), gplot(res.ypred(1:end, 1, 1:2)')
end

