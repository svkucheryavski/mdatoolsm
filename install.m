function install()
   path = mfilename('fullpath');

   if ~strcmp(path(end-15:end-8), 'mdatools')
      error('Change folder to "mdadata" and then run "install"!');
   end

   path = path(1:end-8);
   
   dirs = {'classes',...
      'data',...
      'gui',...
      'misc',...
      'html',...
      'preprocessing'...
   };

   try
      for i = 1:numel(dirs)
         addpath(genpath([path '/' dirs{i}]));
      end   
      addpath(path);
      savepath;
      %builddocsearchdb([path '/html']);
   catch e
      error('Error occured during the installation of "mdatools":\n%s', e.message);
   end

   disp('The "mdatools" toolbox was installed successfully!')
end
