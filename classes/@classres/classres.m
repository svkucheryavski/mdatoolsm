classdef classres < res
      
   properties (SetAccess = 'protected')
      cref      
      nClasses
   end
      
   properties (SetAccess = 'protected', Hidden = true)
      cpred_
   end
      
	properties (Dependent = true, Hidden = true)
      classNames
   end
   
   properties (Dependent = true, Access = 'private', Hidden = true)
      nPred
      nComp
	end
   
   methods
      function setClasses(obj, cpred, cref)
         if nargin < 3
            obj.cref = [];
         else   
            obj.cref = cref;
         end
         
         obj.cpred_ = cpred;         
      end
      
      function out = cpred(obj, varargin)
        out = obj.cpred_(varargin{:}).values;
      end
      
      function out = get.nPred(obj)
         out = size(obj.cpred_, 1);
      end
      
      function out = get.nClasses(obj)
         out = size(obj.cpred_, 2);
      end
      
      function out = get.nComp(obj)
         out = size(obj.cpred_, 3);
      end
      
      function out = get.classNames(obj)
         out = obj.cpred_.wayNames{2};
      end
      
      function summary(obj, nresp)
         if nargin < 2
             nresp = 1:obj.nClasses;
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
   
   methods (Access = 'protected')
      
      function getStat(obj)
         if isempty(obj.cref) || size(obj.cref, 1) < 2
            return;
         end   
         
         nComp = obj.nComp;
         nClasses = obj.nClasses;
         
         cpred = obj.cpred_.values_(~obj.cpred_.excludedRows, :, :);
         cref = obj.cref.values;
         
         fn = zeros(nComp, nClasses);
         fp = zeros(nComp, nClasses);
         tp = zeros(nComp, nClasses);
         tn = zeros(nComp, nClasses);
         
         for i = 1:obj.nClasses
            c = squeeze(cpred(:, i, :));
            fn(:, i) = sum(bsxfun(@times, cref(:, i) == 1, c == -1));
            fp(:, i) = sum(bsxfun(@times, cref(:, i) == 0, c == 1));
            tp(:, i) = sum(bsxfun(@times, cref(:, i) == 1, c == 1));
            tn(:, i) = sum(bsxfun(@times, cref(:, i) == 0, c == -1));
         end
         
         sensitivity = tp ./ (tp + fn);
         specificity = tn ./ (tn + fp);
         misclassified = (fp + fn)/size(cref, 1);
                           
         dimNames = {'', ''};
         rowNames = obj.cpred_.wayNames{3};
         colNames = obj.cpred_.wayNames{2};
         rowValues = 1:nComp;
         dimNames{2} = 'Classes';
         dimNames{1} = 'Components';
         
         obj.stat.fp = mdadata(fp, rowNames, colNames, dimNames, 'False positives');
         obj.stat.fp.rowValuesAll = rowValues;
         obj.stat.fn  = mdadata(fn, rowNames, colNames, dimNames, 'False negatives');         
         obj.stat.fn.rowValuesAll = rowValues;
         obj.stat.tp = mdadata(tp, rowNames, colNames, dimNames, 'True positives');
         obj.stat.tp.rowValuesAll = rowValues;
         obj.stat.tn = mdadata(tn, rowNames, colNames, dimNames, 'True negatives');
         obj.stat.tn.rowValuesAll = rowValues;
         obj.stat.sensitivity = mdadata(sensitivity, rowNames, colNames, dimNames, 'Sensitivity');         
         obj.stat.sensitivity.rowValuesAll = rowValues;
         obj.stat.specificity = mdadata(specificity , rowNames, colNames, dimNames, 'Specificity');
         obj.stat.specificity.rowValuesAll = rowValues;
         obj.stat.misclassified = mdadata(misclassified, rowNames, colNames, dimNames, 'Misclassified');
         obj.stat.misclassified.rowValuesAll = rowValues;
      end   
      
   end
   
   methods (Static = true)
      function [nclasses, ncomp, varargin] = getClassPlotParams(nClasses, nComp, classNames, varargin)
      % detect classes and components if specified by user
      % algorithm:
      %
      % 1. If first value is text, check if the name is among classes
      % names. If not, no components and no classes are specified. If yes,
      % check second value, if it is numeric, it is number of components.
      %
      % 2. If first value is numeric, check if second value is numeric as
      % well. If not, consider the value as number of components. If yes, 
      % first value is classes and second is number of
      % components
      %
      
         nclasses = 1:nClasses;
         ncomp = nComp;
         
         if numel(varargin) == 1
            if iscell(varargin{1}) || ischar(varargin{1})
               % classname(s) are specified
               nclasses = ismember(classNames, varargin{1});
               if ~any(nclasses)
                  error('Wrong class name!');
               else
                  nclasses = find(nclasses);
               end   
               varargin(1) = [];
            elseif isnumeric(varargin{1})               
               % numeric value, consider as number of components or (if
               % only one component is used, number of class.
               if nComp == 1
                  nclasses = varargin{1};
               else
                  ncomp = varargin{1};
               end   
               varargin(1) = [];
            end   
         elseif numel(varargin) > 1
            if iscell(varargin{1}) || ischar(varargin{1}) 
               ind = ismember(classNames, varargin{1});
               if any(ind)
                  nclasses = find(ind);
                  if isnumeric(varargin{2})
                     ncomp = varargin{2};
                     varargin(1:2) = [];
                  else
                     varargin(1) = [];
                  end
               end
            elseif isnumeric(varargin{1}) 
               if ~isnumeric(varargin{2})
                  if nComp == 1
                     nclasses = varargin{1};
                  else
                     ncomp = varargin{1};
                  end   
                  varargin(1) = [];
               else   
                  nclasses = varargin{1};
                  ncomp = varargin{2};
                  varargin(1:2) = [];
               end   
            end   
         end
         
         if numel(ncomp) ~= 1 || ncomp < 1 || ncomp > nComp
            error('Wrong value for number of components!')
         end
         
         if min(nclasses) < 1 || max(nclasses) > nClasses
            error('Wrong value for classes indices!');
         end   
      end
      
      function [nclass, varargin] = getClassNum(nClasses, classNames, varargin)
         nclass = 1;
         if numel(varargin) == 0 
            if nClasses > 1
               error('Specify which class you want to make the plot for!')
            end   
         elseif isnumeric(varargin{1})
            nclass = varargin{1};
            varargin(1) = [];
         elseif ischar(varargin{1}) 
            nclass = find(ismember(classNames, varargin{1}), 1);
            if numel(nclass) == 0 
               if nClasses > 1
                  error('Wrong class name!');
               else
                  nclass = 1;
               end   
            else   
               varargin(1) = [];
            end   
         end
         
         if numel(nclass) ~= 1 || nclass < 1 || nclass > nClasses
            error('Wrong value for class index!');
         end   
      end   
   end   
end

