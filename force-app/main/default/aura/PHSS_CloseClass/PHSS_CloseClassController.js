({
    doInit : function(component, event, helper) {
        helper.fetchClassDetails(component, event, helper);
        helper.isCommunityCls(component);
    },
    
    showStep1 : function(component,event,helper){

        // add logic to differentiate - validateCart or find order
        var requestType = component.get("v.requestType");
        //if ((requestType !== "Full Service" && requestType !== "Community")) {
        if (requestType.indexOf("Full Service") < 0 && requestType !== "Community") {
            helper.validateCart(component, event, helper);
        }

        component.set("v.stepNumber", "One");
        //component.set("v.isLegalChecked",false);
        var checkCmp = component.find("checkbox");
        if(component.find("checkbox")) {
        	checkCmp.set("v.value",false);
        	component.set("v.showError",false);    
        }
    },
    CloseClassButtonHandler : function(component,event,helper){
        var EvntPayload = event.getParam("recordId");
        //component.set("v.recordId", EvntPayload);
        //helper.fetchClassDetails(component, event, helper);
        
    },
    
    showStep2 : function(component,event,helper){
        // Validate input fields
        helper.validateInput(component, event, helper);
        if(component.get("v.allValid")) {
        	component.set("v.stepNumber", "Two");    
        }
    },
    
    showStep3 : function(component,event,helper){
        // Validate input fields
        helper.validateInput(component, event, helper);
        if(component.get("v.allValid")) {
        	component.set("v.stepNumber", "Three");
        }
    },
    
    onGradeChange : function(component, event, helper) {
    	helper.mandateInput(component, event, helper);	    
    },
    
    onReasonChange : function(component, event, helper) {
    	helper.mandateInput(component, event, helper);	    
    },
   
    
    onclickNext : function(component,event,helper){ 
        var currentSN = component.get("v.stepNumber");
           
                   
                
        if(currentSN == "One")
        {
            // Validate input fields
            helper.validateInput(component, event, helper);
            console.log('cartid>>>'+component.get("v.cloudCrazeProdId"));
            console.log('Step one');
               
                
            if(component.get("v.allValid")) {
                           // if(isLegalCheckednext){

                var requestType = component.get("v.requestType");
                //if (requestType != "Full Service" && requestType !== "Community") {
                if (requestType.indexOf("Full Service") < 0 && requestType !== "Community") {
                    var action = component.get("c.updateCartProducts");

                    action.setParams({opportunitySfid : component.get("v.opportunityId"),
                                     CCProductId : component.get("v.cloudCrazeProdId"),
                                     noOfStudents : component.get("v.Students")});
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            var storeResponse = response.getReturnValue();
                            console.log("Cart updated"+JSON.stringify(storeResponse));
                             console.log("Cart updated>>>>>>>>>>>>>>>>>>>>."+storeResponse['encryptedCartId']);

                            var encid = component.set("v.cloudCrazeEncryptedId",storeResponse['encryptedCartId']);

                            console.log("Cart Encrypted Id value"+component.get("v.cloudCrazeEncryptedId"));
                             var action2 = component.get("c.Changecartowner");

                    action2.setParams({opportunitySfid : component.get("v.opportunityId"),
                                      EncryptedId : component.get("v.cloudCrazeEncryptedId")});
                    console.log('Encryptedid>>'+component.get("v.cloudCrazeEncryptedId"));
                      action2.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                             var storeResponse1 = response.getReturnValue();
                            console.log("Cartt successfully updated>>>"+JSON.stringify(storeResponse1));
                        }
                      });
                     $A.enqueueAction(action2);
                        }
                    });
                    $A.enqueueAction(action);


                    // Show/hide credit card info
                    //Will fetch AccountContactRelation record on the basis of loggedin user's ContactId and selected account id
                    //console.log('action1..');
                    var action1 = component.get("c.getDisplayPaymentInfo");
                    action1.setParams({ opportunityId : component.get("v.opportunityId")});
                    action1.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            debugger;
                            var data = response.getReturnValue();
                            component.set("v.displayPaymentInfo", data);
                            console.log('data..'+component.get("v.displayPaymentInfo"));
                        }
                    });
                    $A.enqueueAction(action1);
                }
            
                //Navigate to Step 2
                component.set("v.stepNumber", "Two");
            
            //} 
            }
            
            else if(component.get("v.allValid")){
                component.set("v.stepNumber", "Three"); 
            }
        }
        else if(currentSN == "Two")
        {
            
            component.set("v.stepNumber", "Three");
            
            /*var action = component.get("c.IsCartActive");
            action.setParams({opptyId : component.get("v.opportunityId")});
            action.setCallback(this, function(response) {
            	var state = response.getState();
                    if (state === "SUCCESS") {
                        var cartresponse = response.getReturnValue();
                        
                        component.set("v.IsCarActive", response.getReturnValue());
                    }
            });
			$A.enqueueAction(action);*/
        }
        else if(currentSN == "Three")
        {
        	component.set("v.stepNumber", "Complete");
        }
    },
    
    closeClass : function(cmp, evt, hlpr)
    {
        cmp.set("v.errorMessage","");
        cmp.set("v.showError",false);
        if(cmp.get("v.allValid")){
            
            // Legal checkbox validation
        	//var isLegalChecked = cmp.find("legalCheck").get("v.checked"); 
       		var isLegalChecked = cmp.get("v.isLegalChecked");
            console.log('isLegalChecked..'+isLegalChecked);
            if(isLegalChecked) {
               //cmp.set("v.isLegalChecked",true);
                var jsonWrap = '{ \"Students\": ';
                jsonWrap += JSON.stringify(cmp.get("v.studList"));       
                jsonWrap += ' }';
                                    
                console.log('jsonWrap..'+jsonWrap);
                
                var action = cmp.get("c.assignGrades");	
                action.setParams({ JSON : jsonWrap,
                                   SupInfo : cmp.get("v.SupplementInfo"),
                                  closeclass: true});
                action.setCallback(this, function(response) {
                    var state = response.getState();
                     if (state === "SUCCESS") {
                         cmp.set("v.stepNumber", "Zero");
                     }
                    
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + 
                                         errors[0].message);
                                cmp.set("v.errorMessage",errors[0].message);
                				cmp.set("v.showError",true);
                            }
                        } else {
                            console.log("Unknown error");
                            cmp.set("v.errorMessage",'Unknown error');
                            cmp.set("v.showError",true);
                        }
                    }
                });
                $A.enqueueAction(action);
                
              
                
            }
            else {
                cmp.set("v.errorMessage",'Please check Legal Agreement before submission');
                cmp.set("v.showError",true);
            }
        }
	},
    
    cancel : function(component, event, helper){    
        component.set("v.stepNumber", "Zero");
    },

    closefinalClass : function(cmp, event, helper){
    	cmp.set("v.stepNumber", "Zero");

    	var requestType = cmp.get("v.requestType");
    	console.log(requestType);
    	debugger;

        //if (requestType === "Full Service") {
        if (requestType.indexOf("Full Service") >= 0) {
            console.log('running update order FS');
            helper.updateOrder(cmp, event);
        }
        //if (requestType === "Full Service" || requestType === "Community") {
        if (requestType.indexOf("Full Service") >= 0 || requestType === "Community") {
            console.log('running close class FS/Community');            
            helper.closingClass(cmp, event, helper);
        }

    },
    
    updatePaymentComplete : function(component, event, helper) {
        
        component.set("v.paymentComplete", true);
        helper.closingClass(component, event, helper);
    },
    
    onLegalCheck : function(component, event, helper) {
      	 var checkCmp = component.find("checkbox");
		 component.set("v.isLegalChecked",checkCmp.get("v.value"));
        console.log('checkboxx value>>'+component.get("v.isLegalChecked"));
        }
})