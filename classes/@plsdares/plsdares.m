classdef plsdares < plsres & classres
   
   properties (Dependent = true)
      nComp
   end   
   
   methods
      
      function obj = plsdares(r, cpred, cref)
         obj = obj@plsres(r.xdecomp, r.ydecomp, r.ypred, r.yref);
         obj.setClasses(cpred, cref);
         obj.getStat();
      end
      
      function out = get.nComp(obj)
         out = size(obj.cpred_, 3);
      end

      function plot(obj, varargin)
         
         [classes, ncomp, varargin] = classres.getClassPlotParams(obj.nClasses, obj.nComp, obj.classNames, varargin{:});
         
         subplot(2, 2, 1)
         plotxresiduals(obj, ncomp);
         subplot(2, 2, 2)
         plotmisclassified(obj, classes(1));
         subplot(2, 2, [3 4])
         plotclassification(obj, classes, ncomp);         
      end
      
      function summary(obj, nclass)
            if nargin < 2
                nclass = 1:obj.nClasses;
            end

            if ~isempty(obj.stat)

               for iClass = nclass
                  xexpvar = obj.xdecomp.variance(:, 1);
                  xexpvar.colNames = {'X expvar'};
               
                  yexpvar = obj.ydecomp.variance(:, 1);
                  yexpvar.colNames = {'Y expvar'};
               
                  fn = obj.stat.fn(:, iClass);
                  fn.colNames = {'FN'};

                  fp = obj.stat.fp(:, iClass);
                  fp.colNames = {'FP'};

                  sn = obj.stat.sensitivity(:, iClass);
                  sn.colNames = {'Sens'};

                  sp = obj.stat.specificity(:, iClass);
                  sp.colNames = {'Spec'};

                  mis = obj.stat.misclassified(:, iClass);
                  mis.colNames = {'Mis'};

                  out = [xexpvar yexpvar fn fp sn sp mis];
                  out.dimNames = {'', ''};
                  out.name = ['Classification performance for ' obj.cpred_.wayFullNames{2}{iClass}];

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
         getStat@regres(obj);
         getStat@classres(obj);
      end
      
   end   
end

