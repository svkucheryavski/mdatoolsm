function uninstall()
   path = mfilename('fullpath');

   if ~strcmp(path(end-17:end-10), 'mdatools')
      error('Change folder to "mdatools" and then run "uninstall"!');
   end

   s = input('The script will remove "mdatools" from path list \nand delete all toolbox files from disk. Continue (y/n): ', 's');

   if ~strcmpi(strtrim(s), 'y')
      return
   end

   path = path(1:end-10);

   try
      rmpath(genpath(path));
      cd(path);
      cd('..');
      rmdir(path, 's');
   catch e
      error('Error occured during the uninstallation of "mdatools":\n%s', e.message);
   end

   disp('The "mdatools" toolbox was uninstalled successfully!')
end
