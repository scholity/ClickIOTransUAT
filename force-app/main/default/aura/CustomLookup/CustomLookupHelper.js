({
	searchHelper : function(component,event,getInputkeyWord) {
	    var action = component.get("c.fetchLookUpValues");
	    console.log('accountid obtained'+component.get("v.accountId"));

	    var objectName = component.get('v.objectAPIName');
	    var accountId = component.get('v.accountId');
	    var learningplanid = component.get('v.courseId');
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName' : objectName,
            'accId' : accountId,
            'learningplanid' : learningplanid
          });
      
        action.setCallback(this, function(response) {
          $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
      
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }

               console.log('accountt value>>>>'+JSON.stringify(storeResponse));
                var allValue={"Id":"All","Name":"All"};
               // ops.push('{Id:All,Name:All}');
               	var ops =[];
                ops.push(allValue);	
                var ops2 =storeResponse;
                var opsresult = ops.concat(ops2);
                if(component.get("v.objectAPIName")=='Account'){
                console.log('getting all response>>>'+JSON.stringify(opsresult));
                component.set("v.listOfSearchRecords", opsresult);
                }
                else
                {
                component.set("v.listOfSearchRecords", storeResponse);
  
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
 
        });

        $A.enqueueAction(action);
    
	},

    clearErrorMessage: function (component) {
        var textField = component.find("inputTextField");
        textField.set("v.errors", null);
        $A.util.removeClass(textField, "slds-has-error");
        $A.util.removeClass(textField, "text-field-error");
    },

    displayErrorMessage: function (component, errorMessage) {
        var textField = component.find("inputTextField");
        textField.set("v.errors", [{message: errorMessage}]); 
        $A.util.addClass(textField, "slds-has-error");
        $A.util.addClass(textField, "text-field-error");
    }
})