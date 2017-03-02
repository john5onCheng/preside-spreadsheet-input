component extends="preside.system.handlers.admin.DataManager"{

	public any function manageOneToManyRecords( event, rc, prc ) {

		var objectName = rc.object ?: "";

		_checkObjectExists( argumentCollection=arguments, object=objectName );

		var parentDetails = _getParentDetailsForOneToManyActions( event, rc, prc );
		var objectTitle   = translateResource( "preside-objects.#objectName#:title" );

		prc.spreadSheetInput = isBoolean( rc.spreadSheetInput ?: "" ) && rc.spreadSheetInput;

		if( !prc.spreadSheetInput ){
			prc.gridFields    = _getObjectFieldsForGrid( objectName );
			prc.canAdd        = datamanagerService.isOperationAllowed( objectName, "add" );
			prc.delete        = datamanagerService.isOperationAllowed( objectName, "delete" );
		}else{
			var objectProperties   = presideObjectService.getObjectProperties( objectName );
			var objectFields       = [];
			var fieldsLabel        = "";
			var fieldsType         = "";
			var counter            = 0;
			var relationshipKey    = rc.relationshipKey ?: "";
			var parentId           = rc.parentId        ?: "";

			prc.objectPlaceholders = [];
			prc.objectFieldNames   = [];
			prc.objectFieldTypes   = [];
			prc.manyToOneFields    = [];

			var excludeFields      = "id,datecreated,datemodified,_version_is_draft,_version_has_drafts,#relationshipKey#";

			var objectFields = _getObjectListForSpreadSheetInput( excludeFields, objectProperties );

			for( var key in objectFields ){

				arrayAppend( prc.objectPlaceholders, structKeyExists( objectProperties[key], "spreadSheetPlaceholder" ) ? objectProperties[key].spreadSheetPlaceholder : "" );

				fieldsLabel = translateResource( "preside-objects.#objectName#:field.#objectProperties[key].name?:''#.title"  );
				if( objectProperties[key].required ){
					fieldsLabel = fieldsLabel & " *";
				}
				arrayAppend( prc.objectFieldNames, fieldsLabel );

			}

			var objectData = presideObjectService.selectData(
				  objectName   = objectName
				, selectFields = objectFields
				, filter       = { "#relationshipKey#"=parentId }
				, orderBy      = "#( rc.sortKey ?: 'datecreated' )# ASC"
			);

			for( var key in objectFields ){

				if( objectProperties[ key ].control == "textbox" && objectData.recordCount ){
					fieldsType = "{data:#counter# ,type: {renderer: descriptionRenderer}}";
				}else{
					fieldsType = "{data:#counter#}";
				}

				if( objectProperties[ key ].relationship == "many-to-one" ){

					var relatedObjectData = {
						  position = counter
						, data     = valueList(
							presideObjectService.selectData(
							 	  objectName   = objectProperties[ key ].relatedTo
								, selectFields = [ "${labelfield} as label" ]
								, orderBy      = "label"
							).label )
					}

					arrayAppend( prc.manyToOneFields, relatedObjectData );
				}
				arrayAppend( prc.objectFieldTypes, fieldsType );
				counter++;

			}

			prc.objectData = [];

			if( objectData.recordCount ){
				for( var row in objectData ){
					var dataRow = [];
					for( var column in objectFields ){
						var dataValue = row[ column ];
						if( structKeyExists( objectProperties[ column ], "datetimeFormat" ) ){
							dataValue = datetimeFormat( dataValue,  objectProperties[ column ].datetimeFormat );
						}
						if( objectProperties[ column ].relationship == "many-to-one" ){
							dataValue = renderLabel( objectProperties[ column ].relatedTo, dataValue );
						}
						arrayAppend( dataRow, dataValue  );
					}
					arrayAppend( prc.objectData, dataRow  );
				}
			}
		}


		prc.pageTitle     = translateResource( uri="cms:datamanager.oneToManyListing.page.title"   , data=[ objectTitle, parentDetails.parentObjectTitle, parentDetails.parentRecordLabel ] );
		prc.pageSubTitle  = translateResource( uri="cms:datamanager.oneToManyListing.page.subtitle", data=[ objectTitle, parentDetails.parentObjectTitle, parentDetails.parentRecordLabel ] );
		prc.pageIcon      = "puzzle-piece";

		event.setLayout( "adminModalDialog" );
	}


	public void function saveSpreadsheetRecords( event, rc, prc  ) {

		var dataSubmitted      = deserializeJSON( rc.data ?: "" );
		var objectName         = rc.object          ?: "";
		var relationshipKey    = rc.relationshipKey ?: "";
		var parentId           = rc.parentId        ?: "";
		var row                = "";
		var col                = "";
		var validationResult   = "";
		var formDatas          = [];
		var errorData          = [];
		var formatErrorFields  = [];
		var objectProperties   = presideObjectService.getObjectProperties( objectName );
		var excludeFields      = "id,datecreated,datemodified,_version_is_draft,_version_has_drafts,#relationshipKey#";

		if( arrayLen( dataSubmitted ) ){

			var objectFields = _getObjectListForSpreadSheetInput( excludeFields, objectProperties );

			loop from="#arrayLen( dataSubmitted )-1#" to=1 index="row" step=-1{

				var formData     = {};

				loop from="1" to=arrayLen( objectFields ) index="col"{
					try {
						formData[ objectFields[ col ] ] = Trim( dataSubmitted[row][col] );
					}
					catch( any ) {
						formData[ objectFields[ col ] ] = "";
					}
				}

				validationResult = validateForm( formName="preside-objects.#(rc.object?:'')#.admin.add", formData=formData );

				for( var formField in formData ){
					if( structKeyExists( objectProperties[ formField ], "regexFormat" ) ){
						if( !reFindNoCase( objectProperties[ formField ].regexFormat, formData[ formField ] ) ){
							var invalidFormatMessage = "Invalid format";
							if( structKeyExists( objectProperties[ formField ], "spreadSheetPlaceholder" ) ){
								invalidFormatMessage = invalidFormatMessage & " " & objectProperties[ formField ].spreadSheetPlaceholder
							}
							validationResult.addError(
								  fieldName = formField
								, message   = invalidFormatMessage
							)
						}
					}
					if( validationResult.validated() ){
						if( structKeyExists( objectProperties[ formField ], "datetimeFormat" ) && !isEmpty( formData[ formField ] ) ){
							formData[ formField ] =  LSParseDateTime( formData[ formField ], objectProperties[ formField ].datetimeLocale ? : 'english (united kingdom)');
						}

						if( structKeyExists( objectProperties[ formField ], "relationship" ) && objectProperties[ formField ].relationship == "many-to-one" ){
							var labelField        = presideObjectService.getObjectAttribute( objectProperties[ formField ].relatedTo, "labelField", "label" );
							formData[ formField ] = presideObjectService.selectData( objectName=objectProperties[ formField ].relatedTo, filter={ "#labelField#"=formData[ formField ] }, selectFields=["id"] ).id;
						}
					}
				}

				if( !validationResult.validated() ){
					var errorMessages = validationResult.getMessages();
					for( var key in errorMessages ){
						var validationError          = {};
						validationError.row          = int( row-1 );
						validationError.column       = int( ArrayFind( objectFields, key )-1 );
						validationError.errorMessage = translateResource( errorMessages[key].message ) != "**NOT FOUND**" ? translateResource( errorMessages[key].message ) : errorMessages[key].message;
						arrayAppend( errorData, validationError );
					}
				}

				arrayAppend( formDatas, formData );
			}

			if( !arrayLen( errorData ) ){

				transaction{
					try {
						presideObjectService.deleteData(
							  objectName   = objectName
							, selectFields = objectFields
							, filter       = { "#relationshipKey#"=parentId }
						);

						for( var formDataRow in formDatas ){
							var dataToInsert = formDataRow;
							dataToInsert[ relationshipKey ]= parentId;

							presideObjectService.insertData(
								  objectName  = objectName
								, data        = dataToInsert
							);
						}

					}
					catch(e) {
						writeDump(e);
						abort;
					}

				}
			}


		}else{
			// remove all data
			presideObjectService.deleteData(
				  objectName   = objectName
				, selectFields = objectFields
				, filter       = { "#relationshipKey#"=parentId }
			);
		}

		event.renderData( type="json", data=errorData );

	}


	private array function _getObjectListForSpreadSheetInput( required string excludeFields, required struct objectProperties ) {
		var objectFields = [];
		for( var key in arguments.objectProperties ){
			if( !listFindNoCase( arguments.excludeFields, key ) ){
				arrayAppend( objectFields, key );
			}
		}
		return objectFields;
	}



}