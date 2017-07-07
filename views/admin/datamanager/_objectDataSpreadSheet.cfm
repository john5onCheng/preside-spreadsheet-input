<cfscript>
	event.include( assetId="jq-handsontable" )
		 .include( assetId="jq-core-jquery", group="top" )
		 .include( assetId="css-handsontable" );
</cfscript>
<cfoutput>
	<script>
		$( document ).ready( function( ){

			var currentSize;
			var $container        = $( "##dataTable" );
			var objectData        = #serializeJSON( prc.objectData         ?: [] )#;
			var objectPlaceholder = #serializeJSON( prc.objectPlaceholders ?: [] )#;
			var columnHeader      = #serializeJSON( prc.objectFieldNames   ?: [] )#;
			var columnType        = [ #arrayToList( prc.objectFieldTypes ?: [] )# ];

			$container.handsontable( {
				  data         : objectData
				, colHeaders   : columnHeader
				, columns      : columnType
				, startRows    : 6
				, rowHeaders   : true
				, minSpareRows : 1
				, contextMenu  : ['row_above', 'row_below', 'remove_row','undo','redo']
				, cells        : function( row, col, prop ) {
					currentSize = parseInt( $('.handsontable .htCore tbody tr').size() );
					if( row == currentSize-1 ){
						var cellProperties = {};
						cellProperties.type = { renderer: defaultValueRenderer };
						return cellProperties;
					}
				 }
				 , onChange : function( changes, source ){
					for( var i=0 ; i<changes.length; i++ ){
						var iRow      = parseInt( changes[i][0] );
						var iColumn   = parseInt( changes[i][1] );
						var newValue  = changes[i][3];
						$('.handsontable .htCore tbody tr:eq('+iRow+') td:eq('+iColumn+')').removeAttr( 'style' );
						var escaped = Handsontable.helper.stringify(newValue);
							escaped = strip_tags(escaped, '<b><a><i>'); //be sure you only allow certain HTML tags to avoid XSS threats (you should also remove unwanted HTML attributes)
						$('.handsontable .htCore tbody tr:eq('+iRow+') td:eq('+iColumn+')').html( escaped );
					}
				 }

				<cfif ArrayLen( prc.manyToOneFields ?: [] )>
					, autoComplete: [ {
						<cfloop from="1" to="#arrayLen( prc.manyToOneFields )#" index="i">
							match: function (row, col, data) {
								if ( col === #prc.manyToOneFields[i].position# ) { //if column name contains word "color"
									return true;
								}
									return false;
								}
							, type: { renderer: myAutocompleteRenderer, editor: Handsontable.AutocompleteEditor }
							, source: function (row, col) {
								return [#listqualify(prc.manyToOneFields[i].data,'"',',')#]
							 }
							, strict: true //only accept predefined values (from array above)
						</cfloop>
					}]
				</cfif>
			});

			var handsontable = $container.data('handsontable');

			$('##preside-spreadsheet-form').submit(function () {

				$.ajax({
					  url      : $(this).attr('action')
					, data     : { "data": JSON.stringify( handsontable.getData() ) }
					, dataType : 'json'
					, type     : 'POST'
					, success  : function (response) {
						$('.handsontable .htCore tbody td.input-error').removeClass('input-error').removeAttr('title');

						if (!response.length) {
							alert( 'Data saved' );
						}else {
							$.each(response, function(index, item){
								$('.handsontable .htCore tbody tr:eq('+item.row+') td:eq('+item.column+')').addClass('input-error').attr('title',item.errorMessage);
							});
							alert('Saving error, Please check the error field which hight lighted in red box');
							$('html, body').animate({scrollTop: $('.input-error:first').offset().top}, 1000);
						}
					}
					, error: function () {
						alert('Saving error.');
					}
				});
				return false;

			});

			function greenRenderer(instance, td, row, col, prop, value, cellProperties) {
				Handsontable.TextCell.renderer.apply( this, arguments );
				$(td).css({
					background: 'green'
				});
			};

			function myAutocompleteRenderer(instance, td, row, col, prop, value, cellProperties) {
				Handsontable.AutocompleteCell.renderer.apply(this, arguments);
				td.title = 'Type to show the list of options';
			}

			function descriptionRenderer( instance, td, row, col, prop, value, cellProperties ) {
				var escaped = Handsontable.helper.stringify( value );
				escaped      = strip_tags(escaped, '<b><a><i>'); //be sure you only allow certain HTML tags to avoid XSS threats (you should also remove unwanted HTML attributes)
				td.innerHTML = escaped;

				return td;
			};

			function defaultValueRenderer( instance, td, row, col, prop, value, cellProperties ) {
				var args = $.extend( true, [], arguments );
				if( args[5] ==null && isEmptyRow( instance, row ) ) {
					args[5] = objectPlaceholder[ col ];
					td.style.color = '##999';
				}else {
					td.style.color = '';
				}
				Handsontable.TextCell.renderer.apply( this, args );
			}

			function isEmptyRow( instance, row ) {
				var rowData = instance.getData()[row];
				for ( var i = 0, ilen = rowData.length; i < ilen; i++ ) {
					if( rowData[i] !== null ) {
						return false;
					}
				}
				return true;
			}

			function strip_tags( input, allowed ) {
				allowed  = (((allowed || "") + "").toLowerCase().match(/<[a-z][a-z0-9]*>/g) || []).join(''); // making sure the allowed arg is a string containing only tags in lowercase (<a><b><c>)
				var tags = /<\/?([a-z][a-z0-9]*)\b[^>]*>/gi,
					commentsAndPhpTags = /<!--[\s\S]*?-->|<\?(?:php)?[\s\S]*?\?>/gi;
				return input.replace(commentsAndPhpTags, '').replace(tags, function ($0, $1) {
					return allowed.indexOf('<' + $1.toLowerCase() + '>') > -1 ? $0 : '';
				});
			}

		});

	</script>

	<form id="preside-spreadsheet-form" action="#event.buildAdminLink( linkTo='datamanager.saveSpreadsheetRecords', queryString='parentId=#( rc.parentId?:'' )#&object=#( rc.object?:'' )#&relationshipKey=#( rc.relationshipKey?:'' )#' )#" method="post">
		<div id="dataTable"></div>
		<br />
		<button type="submit" class="btn btn-primary"><i class="fa fa-check"></i> Save</button>
	</form>
</cfoutput>