clc
clear classes

helpdir = '/Users/svkucheryavski/Dropbox/Sync/Work/Developing/Matlab/mdatools/html/';

ssh = [helpdir 'assets/mdastyles.xsl'];
ssh_toc = [helpdir 'assets/mdastyles_toc.xsl'];   

ssh_methods = [helpdir 'assets/mdastyles_methods.xsl'];   

publish('mdatools_quick.m', 'format', 'html', 'outputDir', helpdir, 'stylesheet', ssh);

%% front page and quck start
publish('mdatools.m', 'format', 'html', 'outputDir', helpdir, 'stylesheet', ssh_toc);
publish('mdatools_ug.m', 'format', 'html', 'outputDir', helpdir, 'stylesheet', ssh_toc);

%% mdadata
publish('mdatools_ug_mdadata.m', 'format', 'html', 'outputDir', helpdir, 'stylesheet', ssh_toc);
publish('mdatools_ug_mdadata_intro.m', 'format', 'html', 'outputDir', helpdir, 'stylesheet', ssh);
publish('mdatools_ug_mdadata_subsets.m', 'format', 'html', 'outputDir', helpdir, 'stylesheet', ssh);
publish('mdatools_ug_mdadata_math.m', 'format', 'html', 'outputDir', helpdir, 'stylesheet', ssh);
publish('mdatools_ug_mdadata_stat.m', 'format', 'html', 'outputDir', helpdir, 'stylesheet', ssh);
publish('mdatools_ug_mdadata_plots.m', 'format', 'html', 'outputDir', helpdir, 'stylesheet', ssh);
publish('mdatools_ug_mdadata_groups.m', 'format', 'html', 'outputDir', helpdir, 'stylesheet', ssh);
publish('mdatools_ug_mdadata_exclude.m', 'format', 'html', 'outputDir', helpdir, 'stylesheet', ssh);
publish('mdatools_ug_mdadata_gui.m', 'format', 'html', 'outputDir', helpdir, 'stylesheet', ssh);

%% mdaimage
%publish('mdatools_ug_mdaimage.m', 'format', 'html', 'outputDir', helpdir, 'stylesheet', ssh);
publish('mdatools_ug_mdadata_gplots.m', 'format', 'html', 'outputDir', helpdir, 'stylesheet', ssh);

%% classes and functions
publish_class('mdadata', 'format', 'html', 'outputDir', [helpdir 'classes'], 'stylesheet', ssh_methods);
publish_class('mdaimage', 'format', 'html', 'outputDir', [helpdir 'classes'], 'stylesheet', ssh_methods);


 

