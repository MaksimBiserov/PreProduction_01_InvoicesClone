({
	createRecord: function(component, event) {
		let createRecordEvent = $A.get("e.force:createRecord");
		let dfv = '{' + component.get("v.defaultFieldsValues").toString() +
				  ', "IsDeepClone__c" : true}';
		dfv = dfv.replaceAll("'", '"');

		console.log('dfv: ' + dfv);
		console.log('dfv value: ' + valueOf(dfv));

		createRecordEvent.setParams({
		    "entityApiName": "Invoice__c",
			"defaultFieldValues": JSON.parse(dfv)
		});

		createRecordEvent.fire();
	    $A.get("e.force:closeQuickAction").fire();
   }
})