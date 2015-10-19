
$( document ).ready(function() {
  var xmltext = '\
  <toc version="2.0">\
  <tocitem target="mdatools.html">Multivariate Data Analysis Toolbox (mdatools)\
     <tocitem target="mdatools_quick.html">Quick start guide</tocitem>\
     <tocitem target="mdatools_ug.html" image="HelpIcon.GETTING_STARTED">User guide\
        <tocitem target="mdatools_ug_mdadata.html">Dataset object (mdadata)\
           <tocitem target="mdatools_ug_mdadata_intro.html">Introduction to mdadata class</tocitem>\
           <tocitem target="mdatools_ug_mdadata_subsets.html">Sorting data and making subsets</tocitem>\
           <tocitem target="mdatools_ug_mdadata_math.html">Mathematical operators and functions</tocitem>\
           <tocitem target="mdatools_ug_mdadata_stat.html">Quantitative statistics</tocitem>\
           <tocitem target="mdatools_ug_mdadata_plots.html">Simple plots</tocitem>\
           <tocitem target="mdatools_ug_mdadata_groups.html">Factors and groups</tocitem>\
           <tocitem target="mdatools_ug_mdadata_gplots.html">Group plots</tocitem>\
           <tocitem target="mdatools_ug_mdadata_exclude.html">Hiding rows and columns</tocitem>\
           <tocitem target="mdatools_ug_mdadata_gui.html">GUI tools</tocitem>\
        </tocitem>\
        <tocitem target="mdatools_ug_mdaimage.html">Working with images (mdaimage)</tocitem>\
        <tocitem target="mdatools_ug_prep.html">Data preprocessing</tocitem>\
        <tocitem target="mdatools_ug_prep.html">Principal component analysis</tocitem>\
        <tocitem target="mdatools_ug_mlr.html">Multiple linear regression</tocitem>\
        <tocitem target="mdatools_ug_pls.html">Partial least squares regression</tocitem>\
        <tocitem target="mdatools_ug_simca.html">SIMCA classification</tocitem>\
        <tocitem target="mdatools_ug_plsda.html">PLS discriminant analysis</tocitem>\
        <tocitem target="mdatools_ug_explore.html">GUI tool for interactive modelling</tocitem>\
     </tocitem>\
     <tocitem target="classes/mdadata.html" image="HelpIcon.FUNCTIONS">Class "mdadata"</tocitem>\
     <tocitem target="classes/mdaimage.html" image="HelpIcon.FUNCTIONS">Class "mdaimage"</tocitem>\
     <tocitem target="classes/prep.html" image="HelpIcon.FUNCTIONS">Class "prep"</tocitem>\
  </tocitem>\
  </toc>\
  ';



   if ((typeof is_method != 'undefined') && is_method) {
      var urlstr = '../';
      var targetstr = 'classes/';
   } else {
      var urlstr = '';
      var targetstr = '';
   }

   parseToc(xmltext);

   $('table.methods-list td.name').click(function(){
      var el = $(this);
      file = this.id.toString() + '.html';

      $.ajax({
         type: "GET",
         url: file,
         dataType: "html",
      }).done(function(data) {

         if (el.parent().hasClass('selected')) {
            el.parent().removeClass('selected');
            el.find('span').html('&plus;');
            el.next().html(el.next().find('div.hidden').html());
         } else {
            // get document for selected function and remove header and footer
            var tempDom = $('<output>').append($.parseHTML(data));
            var content = tempDom.find('div.content');
            content.find('h1').remove();
            content.find('p.footer').remove();

            // show its content instead of short text about the function
            el.parent().addClass('selected');
            el.next().html('<div class="hidden">' + el.next().html() + '</div>' + $('div.content', tempDom).html());
            el.find('span').html('&minus;');
         }
      });
   })

   function parseToc(xmltext)
   {
      var xml = $.parseXML(xmltext);

      var filename = window.location.href.substr(window.location.href.lastIndexOf("/")+1);
      var nav = [];
      var node = $(xml).find('tocitem[target="' + targetstr + filename + '"]');

      // parse node tree to get all parents
      $(node).parents().each(function(){
         if (this.tagName == 'tocitem') {
            var text=$(this).contents().eq(0).text();
            nav.unshift('<li><a href="' + urlstr + $(this).attr('target') + '">' + text + '</a><span>></span></li>');
         }
      });

      // set up navigation bar
      if (nav.length > 0) {
         var text=$(node).contents().eq(0).text();
         nav.push('<li><b>' + text + '</b></li>');
         var navstr = '<div class="nav-arrows">';

         // arrow-link to the previous node
         var np = $(node).prev();
         if (np != undefined && $(np).attr('target') != undefined) {
            var npstr = '<li class="arrow"><a title="' + $(np).contents().eq(0).text() + '" href="' + urlstr + $(np).attr('target') + '">&#9668;</a></li>';
            var npstr_footer = '<li class="prev-node">&larr;&nbsp;<a href="' + urlstr + $(np).attr('target') + '">' + $(np).contents().eq(0).text() + '</a></li>';
            nav.unshift(npstr);
         } else {
            var npstr_footer = '<li class="prev-node"></li>';
            nav.unshift('<li class="arrow"><span>&#9668;</span></a>');
         }


         // arrow-link to the next node
         var nn = $(node).next();
         if (nn != undefined && $(nn).attr('target') != undefined) {
            var nnstr = '<li class="arrow"><a title="' + $(nn).contents().eq(0).text() + '" href="' + urlstr + $(nn).attr('target') + '">&#9658;</a></li>';
            var nnstr_footer = '<li class="next-node"><a href="' + urlstr + $(nn).attr('target') + '">' + $(nn).contents().eq(0).text() + '</a>&nbsp;&rarr;</li>';
            nav.unshift(nnstr);
         } else {
            var nnstr_footer = '<li class="next-node"></li>';
            nav.unshift('<li class="arrow"><span>&#9658;</span></a>');
         }

         // assemble and show top navigation bar
         navstr = '<ul class="nav-list">' + nav.join('') + '</ul><div style="clear:both"></div>';
         $(navstr).prependTo('body')

         // make and show bottom navigation bar
         $("div.content").append('<ul class="nav-footer">' + npstr_footer + nnstr_footer + '</ul>');
      }

      if (show_toc) {
         var nav = [];
         $(node).children().each(function(){
            if (this.tagName == 'tocitem') {
               var text=$(this).contents().eq(0).text();
               nav.push('<li><a href="' + $(this).attr('target') + '">' + text + '</a></li>');
            }
         });

         if (nav.length > 0) {
            var nav = '<h2>Content</h2><ul class="toc-list">' + nav.join('') + '</ul>'
            $("p.footer").before($(nav));
         }
      }

      $("p.footer").remove();
   }
});
