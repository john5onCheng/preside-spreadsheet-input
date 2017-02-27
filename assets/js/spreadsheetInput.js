$(document).ready(function(){
          var aData = [["Adaption of <i>Mycobacterium abscessus</i> to transmission and lung infection","","17/04/2014 09:00:00","17/04/2014 09:30:00","Julian Parkhill (Wellcome Trust Sanger Institute, UK)","","Ross Fitzgerald (The Roslin Institute, The University of Edinburgh, UK)","","",""],["Evolution of antibiotic resistance in the host","","17/04/2014 09:30:00","17/04/2014 10:00:00","Ben Howden (University of Melbourne, Australia)","","","","",""],["Evolution of <i>Pseudomonas syringae</i> in planta","","17/04/2014 10:00:00","17/04/2014 10:30:00","Dawn Arnold (University of West of England, UK)","","","","",""],["Refreshments and Exhibition","","17/04/2014 10:30:00","17/04/2014 11:00:00","","","","","",""],["<i>Salmonella enteritidis</i>: rapid evolution within an immunocompromised patient","","17/04/2014 11:00:00","17/04/2014 11:30:00","Robert Kingsley (Wellcome Trust Sanger Institute, UK)","","","","",""],["Offered paper - Experimental evolution reveals extensive horizontal gene transfer during <i>Staphylococcus aureus</i> host adaptation","","17/04/2014 11:30:00","17/04/2014 11:45:00","Jodi Lindsay (St. George’s University, UK)","","","","",""],["Offered paper - Recombination drives extensive phenotypic and genotypic diversity of a <i>Pseudomonas aeruginosa</I> population within a single cystic fibrosis patient","","17/04/2014 11:45:00","17/04/2014 12:00:00","Alan McNally (Nottingham Trent University, UK)","","","","",""],["Lunch and Exhibition","","17/04/2014 12:00:00","17/04/2014 13:00:00","","","","","",""],["Evolution and Pathoadaptation of <i>Pseudomonas aeruginos</i> in cystic fibrosis patients","","17/04/2014 13:00:00","17/04/2014 13:30:00","Rasmus Marvig (Technical University of Denmark, Denmark)","","Nick Thompson (Wellcome Trust Sanger Institute, UK)","","",""],["Offered paper - Genetic variation is localised to hypermutable sequences during persistent meningococcal carriage","","17/04/2014 13:30:00","17/04/2014 13:45:00","Mohamed Alamro (University of Leicester, UK)","","","","",""],["Offered paper - Multiple independent emergence and rapid expansion of pertactin-deficient <i>Bordetella pertussis</i> in Australia","","17/04/2014 13:45:00","17/04/2014 14:00:00","Ruiting Lan (University of New South Wales, Australia)","","","","",""],["Genomic evolution of <i>Helicobacter pylori</i> within its human host","","17/04/2014 14:00:00","17/04/2014 14:30:00","Xavier Didelot (Imperial College London, UK)","","","","",""],["Within-host evolution of <i>Staphylococcus aureus</i> during asymptomatic carriage","","17/04/2014 14:30:00","17/04/2014 15:00:00","Daniel Wilson (University of Oxford, UK)","","","","",""]];
          var $container = $("#dataTable");
          var tpl = ["","","DD/MM/YYYY HH:MM:SS","DD/MM/YYYY HH:MM:SS","","","","","",""];
          var aHeaderColumn = ["Title *","Session SubTopic","Start Date/Time *","End Date/Time *","Speaker(s)","Speaker detail","Chair(s)","Summary","Room","Abstract file name"];
          var aFieldName = ["obj_label","subtopic","start_date","end_date","speakers","speaker_detail","chairs","summary","room","serial_number"];
          var aFieldType = ["textbox","text","datepicker","datepicker","text","textbox","text","textbox","object","text"];
          var aDataSchema = {obj_label:null,subtopic:null,start_date:null,end_date:null,speakers:null,speaker_detail:null,chairs:null,summary:null,room:null,serial_number:null};


            var aColumns= [{data:0 ,type: {renderer: descriptionRenderer}},{data:1},{data:2},{data:3},{data:4},{data:5 ,type: {renderer: descriptionRenderer}},{data:6},{data:7 ,type: {renderer: descriptionRenderer}},{data:8},{data:9}] ;


          var iCurrentSize;

           $container.handsontable({
              data: aData,
              //
              colHeaders: aHeaderColumn,
              startRows: 6,
              rowHeaders: true,
              minSpareRows: 1,
              contextMenu:  ['row_above', 'row_below', 'remove_row','undo','redo']
              ,columns: aColumns
            ,cells: function (row, col, prop) {
               iCurrentSize = parseInt($('.handsontable .htCore tbody tr').size());
               if(row==iCurrentSize-1){
                  var cellProperties = {};
                  cellProperties.type = {renderer: defaultValueRenderer};
                  return cellProperties;
                }
             }
             ,onChange:function(changes, source){
              for(var i=0 ; i<changes.length;i++){
                var iRow    = parseInt(changes[i][0]);
                  var iColumn = parseInt(changes[i][1]);
                  var sNewValue = changes[i][3];
                   $('.handsontable .htCore tbody tr:eq('+iRow+') td:eq('+iColumn+')').removeAttr('style');

                    var escaped = Handsontable.helper.stringify(sNewValue);
                    escaped = strip_tags(escaped, '<b><a><i>'); //be sure you only allow certain HTML tags to avoid XSS threats (you should also remove unwanted HTML attributes)
                    $('.handsontable .htCore tbody tr:eq('+iRow+') td:eq('+iColumn+')').html(escaped);

              }
             }

              ,autoComplete: [
              {

                    match: function (row, col, data) {
                      if (col===8) { //if column name contains word "color"
                        return true;
                      }
                      return false;
                    },
                    type: {renderer: myAutocompleteRenderer, editor: Handsontable.AutocompleteEditor},
                    source: function (row, col) {
                      return ["Exchange Foyer","Charter 1-3","Charter 4","Exchange 8-10","Exchange 1","Exchange 11","Exchange 2-3","Auditorium","Charter 1-3","Charter 4","Chichester Lecture Theatre","A2 Lecture Theatre","A1 Lecture Theatre","Pevensey 1A6 Lecture Theatre","Arts Marquee","Jurys Inn"," Liverpool ","Hall 1A"," Arena and Convention Centre Liverpool ","Room 11B"," Arena and Convention Centre Liverpool ","Hall 2"," Arena and Convention Centre Liverpool ","Upper Level Lobby"," Arena and Convention Centre Liverpool","Room 12"," Arena and Conference Centre Liverpool","Hall 11A"," Arena and Convention Centre Liverpool","ICC Birmingham","Hall 3"," ICC Birmingham","Hall 7a"," ICC Birmingham","Hall 1"," ICC Birmingham","Hall 7b"," ICC Birmingham","Level 4 Foyer"," ICC Birmingham","Hall 1","Hall 5","Hall 8a","Hall 8b","Hall 11a","Hall 7","Hall 6","Hall 10a","Hall 9","Hall 10b","Hall 11b","Park Suite"," Mercure Manchester Piccadilly Hotel","Hall 1B","Hall 1A","Room 4","Room 2F","Room 11C","Room 1C","Room 2F","Room 12","Room 3B","Room 1A","Hall 1C","Hall 2F","Room 1B","Room 3A","Room 4","Hall 2N","Hall 1A","Lower Gallery","Poster and exhibition space","Hall 2","Halls 2N + 2F","Room 11A","Rooms 11B + 11C","Foyer","Moyne Lecture Theatre","The Farm on Dawson Street","Estuary Suite","Kiltegan Suite","Devonshire Suite","Ground Floor Atrium"," Western Gateway Building","G05"," Western Gateway Building","City Hall","The Grainstore"," Ballymaloe","Devere Hall","Lammermuir Suite Level -2","Pentland Suite Level 3","Sidlaw Level 3","Fintry Level 3","Carrick Rooms Level 1","Harris Suite Level 1","Ochil Rooms Level 1","Lennox Suite Level -2","Tinto Level 0","Moorfoot Level 0","Kilsyth Level 0","Pentland and Fintry Level 3","Ghillie Dhu"," 2 Rutland Place"," Edinburgh EH1 2AD","The Hub"," Castlehill"," Edinburgh EH1 2NE","Platform 5 cafe Level 1","Kilsyth Level 1","Kilsyth Level 2","Kilsyth Level 3","Strathblane Level 0","Cromdale Hall Level -2","Lennox Suite Level -2 (Society stand)"]
                    },
                    strict: true //only accept predefined values (from array above)

              }]


          });

          var handsontable = $container.data('handsontable');

          // $('#pcms-component-form').submit(function () {

          //     var jsonData = {"data":handsontable.getData(),"targettype": "session","parentobject":"subject_area","parentobj_id":"0AB51253-D84D-41C6-8E4AE9CBA0616C87", "fieldList":aFieldName,"fieldType":aFieldType, "bData":13};


          //   $.ajax({
          //       url: $(this).attr('action'),
          //       data: JSON.stringify(jsonData),
          //       dataType: 'json',
          //       type: 'POST',
          //       success: function (response) {
          //         $('.handsontable .htCore tbody td.input-error').removeClass('input-error').removeAttr('title');

          //         if (!response.length) {
          //            alert('Data saved');
          //         }else {
          //             $.each(response, function(index, item){
          //           $('.handsontable .htCore tbody tr:eq('+item.row+') td:eq('+item.column+')').addClass('input-error').attr('title',item.errorMessage);
          //         });
          //             alert('Saving error, Please check the error field which hight lighted in red box');
          //             $('html, body').animate({scrollTop: $('.input-error:first').offset().top}, 1000);
          //         }
          //       },
          //       error: function () {
          //        alert('Saving error.');
          //       }
          //    });
          //   return false;
          // });

          function greenRenderer(instance, td, row, col, prop, value, cellProperties) {
            Handsontable.TextCell.renderer.apply(this, arguments);
            $(td).css({
              background: 'green'
            });
          };

          function myAutocompleteRenderer(instance, td, row, col, prop, value, cellProperties) {
            Handsontable.AutocompleteCell.renderer.apply(this, arguments);
            td.title = 'Type to show the list of options';
          }

          function descriptionRenderer(instance, td, row, col, prop, value, cellProperties) {
            var escaped = Handsontable.helper.stringify(value);
            escaped = strip_tags(escaped, '<b><a><i>'); //be sure you only allow certain HTML tags to avoid XSS threats (you should also remove unwanted HTML attributes)
            td.innerHTML = escaped;

            return td;
          };

          function defaultValueRenderer(instance, td, row, col, prop, value, cellProperties) {
            var args = $.extend(true, [], arguments);
            if (args[5] ==null && isEmptyRow(instance, row)) {
              args[5] = tpl[col];
              td.style.color = '#999';
            }else {
              td.style.color = '';
            }
            Handsontable.TextCell.renderer.apply(this, args);
          }

          function isEmptyRow(instance, row) {
            var rowData = instance.getData()[row];
            for (var i = 0, ilen = rowData.length; i < ilen; i++) {
              if (rowData[i] !== null) {
                return false;
              }
            }
            return true;
          }

          function strip_tags (input, allowed) {
            allowed = (((allowed || "") + "").toLowerCase().match(/<[a-z][a-z0-9]*>/g) || []).join(''); // making sure the allowed arg is a string containing only tags in lowercase (<a><b><c>)
            var tags = /<\/?([a-z][a-z0-9]*)\b[^>]*>/gi,
              commentsAndPhpTags = /<!--[\s\S]*?-->|<\?(?:php)?[\s\S]*?\?>/gi;
            return input.replace(commentsAndPhpTags, '').replace(tags, function ($0, $1) {
              return allowed.indexOf('<' + $1.toLowerCase() + '>') > -1 ? $0 : '';
            });
          }

        });
