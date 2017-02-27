component output=false {

	public void function configure( bundle ) output=false {
		bundle.addAsset( id="jq-handsontable"  , path="/js/jquery.handsontable.js" );
		bundle.addAsset( id="jq-spreadsheet"   , path="/js/spreadsheetInput.js" );
		bundle.addAsset( id="css-handsontable" , path="/css/handsontable.css"      );
	}

}