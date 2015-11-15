classdef simcares < pcares & classres
   
   properties (Dependent = true)
      nComp
   end   
   
   methods
      
      function obj = simcares(r, cpred, cref)
         if ~isa(r, 'pcares')
            error('The first argument should be an object of "pcares" class!')
         end
         
         obj@pcares(r.scores, [], [], r.tnorm, r.totvar, r.Q, r.T2, r.modpower);    
         obj.setClasses(cpred, cref);
         obj.getStat();
      end
      
      function out = get.nComp(obj)
         out = size(obj.cpred_, 3);
      end

      function plot(obj, varargin)
         
         [classes, ncomp, varargin] = classres.getClassPlotParams(obj.nClasses, obj.nComp, obj.classNames, varargin{:});
         
         subplot(2, 2, 1)
         plotscores(obj, ncomp);
         subplot(2, 2, 2)
         plotmisclassified(obj, classes(1));
         subplot(2, 2, 3)
         plotcumexpvar(obj);         
         subplot(2, 2, 4)
         plotclassification(obj, classes, ncomp);         
      end
      
      function summary(obj)
         iClass = 1;
         if ~isempty(obj.stat)
            expvar = obj.variance(:, 1);
            expvar.colNames = {'Expvar'};
            
            cumexpvar = obj.variance(:, 2);
            expvar.colNames = {'Cumexpvar'};

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

            out = [expvar cumexpvar fn fp sn sp mis];
            out.dimNames = {'', ''};
            out.name = ['Classification performance for ' obj.cpred_.wayNames{2}{iClass}];

            if ~isempty(obj.info)
               fprintf('\n%s', obj.info);
            end   
            show(out);
         end   
      end    
   end
   
   methods (Access = 'protected')
      
      function getStat(obj)
         getStat@classres(obj);
      end
      
   end   
end

