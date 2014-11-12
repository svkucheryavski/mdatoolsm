classdef classres < handle
   
   properties 
      info
   end
   
   properties (SetAccess = 'protected')
      cref      
      cpred
      stat
   end
         
	properties (Access = 'protected', Hidden = true)
      classNames
      nClasses
   end
   
   methods
      function obj = classres(cpred, cref, stat)
         
         if nargin < 2
            obj.cref = [];
            obj.classNames = cpred.factorLevelNames{1};
         else   
            obj.cref = cref;
            obj.classNames = cref.factorLevelNames{1};
         end
         
         obj.nClasses = numel(obj.classNames) - 1;
         
         if nargin < 3
            stat = [];
         end
         
         obj.cpred = cpred;
         
         if isempty(stat) && ~isempty(cref)
            obj.getStat();
         end   
      end
                  
      function getStat(obj)
         
         if isempty(obj.cref) || size(obj.cref, 1) < 2
            return;
         end   
         
         cpred = obj.cpred.values;
         cref = obj.cref.values;
         
         nComp = size(cpred, 2);
                           
         fn = zeros(nComp, nClasses);
         fp = zeros(nComp, nClasses);
         tp = zeros(nComp, nClasses);
         
         for i = 1:obj.nClasses
            fn(:, i) = sum(cref == i & c ~= i);
            fp(:, i) = sum(cref ~= i & c == i);
            tp(:, i) = sum(cref == i & c == i);
         end
         
         sensitivity = tp / (tp + fn);
         specificity = tp / (tp + fp);
         misclassified = (fp + fn)/size(cref, 1);
                  
         dimNames = {'', 'Classes'};
         rowNames = obj.ypred.colFullNames;
         colNames = obj.classNames;
         
         if nComp > 1
            dimNames{1} = 'Components';
         else
            rowNames = {};
         end
         
         obj.stat.fp = mdadata(fp, rowNames, colNames, dimNames, 'False positives');
         obj.stat.fn  = mdadata(fn, rowNames, colNames, dimNames, 'False negatives');         
         obj.stat.tp = mdadata(tp, rowNames, colNames, dimNames, 'True positives');
         obj.stat.sensitivity = mdadata(sensitivity, rowNames, colNames, dimNames, 'Sensitivity');         
         obj.stat.specificity = mdadata(specificity , rowNames, colNames, dimNames, 'Specificity');
         obj.stat.misclassified = mdadata(misclassified, rowNames, colNames, dimNames, 'Misclassified');
      end   
      
      function plot(obj, nresp, ncomp, varargin)
        if nargin < 2
            nresp = 1;
        end
        
        if nargin < 3
            ncomp = obj.nComp;
        end
        
        if numel(ncomp) ~= 1 || numel(nresp) ~= 1
            error('Specify response variable and number of components to show the plot for!')
        end
        
        if obj.nComp > 1 && ~isempty(obj.stat)
            subplot(1, 2, 1)
            plotpredictions(obj, nresp, ncomp, varargin{:});
            subplot(1, 2, 2)
            plotmisclassified(obj, nresp, varargin{:});
        else 
            plotpredictions(obj, nresp, ncomp, varargin{:});
        end
      end
      
      function summary(obj, nresp)
         if nargin < 2
             nresp = 1:obj.nResp;
         end
         
         if ~isempty(obj.stat)
         
            for iResp = nresp
               fn = obj.stat.fn(:, iResp);
               fn.colNames = {'FN'};
               
               fp = obj.stat.fp(:, iResp);
               fp.colNames = {'FP'};
               
               sn = obj.stat.sensitivity(:, iResp);
               sn.colNames = {'Sens'};
               
               sp = obj.stat.specificity(:, iResp);
               sp.colNames = {'Spec'};
               
               mis = obj.stat.misclassified(:, iResp);
               mis.colNames = {'Mis'};
               
               out = [fn fp sn sp mis];
               out.dimNames = {'', ''};
               out.name = ['Prediction performance for ' obj.classNames(iClass)];
               
               if ~isempty(obj.info)
                  fprintf('\n%s', obj.info);
               end   
               show(out);
            end   
         end
      end   
      
   end   
end

