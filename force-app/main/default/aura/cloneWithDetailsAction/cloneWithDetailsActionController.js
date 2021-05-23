({
	doInit: function(component, event, helper) {
	    var cloneAction = component.get("c.getStringFields");
        console.log('cloneAction');

        cloneAction.setParams({
            recordId: component.get("v.recordId"),
        });

        cloneAction.setCallback(this, function(response) {

            if(response.getReturnValue()) {
                component.set("v.cloneWithItems", true);
                component.set("v.defaultFieldsValues", response.getReturnValue());
                console.log(response.getReturnValue()); 
                helper.createRecord(component, event);
            }
        });

        $A.enqueueAction(cloneAction);
	}
})