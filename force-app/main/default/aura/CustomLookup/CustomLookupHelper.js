({
	searchHelper : function(component,event,getInputkeyWord) {
	  
     var action = component.get("c.fetchLookUpValues");
      console.log('accountid obtained'+component.get("v.accountId"));
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName' : component.get("v.objectAPIName"),
            'accId' : component.get("v.accountId"),
            'learningplanid' : component.get("v.courseId")
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