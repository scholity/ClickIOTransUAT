({
//    // Method to initialize wrapper
//	initializeWrapper : function(cmp, evt, helper) {
//        var action = cmp.get('c.initializeStudents');
//        action.setParams({ count : 1 });
//        action.setCallback(this, function(response) {
//            var state = response.getState();
//            if (state === "SUCCESS") {
//            	cmp.set('v.formWrap', response.getReturnValue()[0]);
//
//                // Get voucherid from url
//                var sPageURL = decodeURIComponent(window.location.search.substring(1));
//                var sURLVariables = sPageURL.split('&'); //Split by & so that you get the key value pairs separately in a list
//                var sParameterName;
//                var i;
//
//                for (i = 0; i < sURLVariables.length; i++) {
//                    sParameterName = sURLVariables[i].split('='); //to split the key from the value.
//
//                    if (sParameterName[0] === 'voucherid') { //lets say you are looking for param name - firstName
//                        sParameterName[1] === undefined ? 'Not found' : sParameterName[1];
//                        //cmp.set("v.voucherId", ParameterName[1]);
//                    }
//
//
//                }
//                if(cmp.get("v.recordId"))
//                {
//                    cmp.set("v.formWrap.voucherid",cmp.get("v.recordId").substring(0,cmp.get("v.recordId").length-3));
//                    cmp.set("v.registerBtnLabel","Enroll Learner");
//                }
//                else
//                {
//                cmp.set("v.formWrap.voucherid",sParameterName[1]);
//                }
//
//                // Enroll Learner in Community
//                if(cmp.get("v.voucherId")) {
//                    cmp.set("v.formWrap.voucherid",cmp.get("v.voucherId"));
//                }
//            }
//
//        });
//        $A.enqueueAction(action);
//	},

    // Method to initialize wrapper - 2nd version testing promise
    initializeWrapper : function(cmp, evt, helper) {
        var action = cmp.get('c.initializeStudents');


        return new Promise(function (resolve, reject) {
            action.setParams({ count : 1 });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    cmp.set('v.formWrap', response.getReturnValue()[0]);

                    // Get voucherid from url
                    var sPageURL = decodeURIComponent(window.location.search.substring(1));
                    var sURLVariables = sPageURL.split('&'); //Split by & so that you get the key value pairs separately in a list
                    var sParameterName;
                    var i;

                    for (i = 0; i < sURLVariables.length; i++) {
                        sParameterName = sURLVariables[i].split('='); //to split the key from the value.

                        if (sParameterName[0] === 'voucherid') { //lets say you are looking for param name - firstName
                            sParameterName[1] === undefined ? 'Not found' : sParameterName[1];
//                            cmp.set("v.voucherId", ParameterName[1]);
                        }


                    }
                    if(cmp.get("v.recordId"))
                    {
                        cmp.set("v.formWrap.voucherid",cmp.get("v.recordId").substring(0,cmp.get("v.recordId").length-3));
                        cmp.set("v.registerBtnLabel","Enroll Learner");
                    }
                    else
                    {
                    cmp.set("v.formWrap.voucherid",sParameterName[1]);
                    }

                    // Enroll Learner in Community
                    if(cmp.get("v.voucherId")) {
                        cmp.set("v.formWrap.voucherid",cmp.get("v.voucherId"));
                    }
                    resolve();
                } else {
                    reject();
                }

            });
            $A.enqueueAction(action);
        });
    },
    
    // Method to initialize wrapper
	validateClaim : function(cmp, evt, helper) {
        var action = cmp.get('c.validateVoucher');
        var recid = cmp.get("v.recordId");
        if (!recid) {
            recid = cmp.get("v.formWrap.voucherid");
        }
        console.log('recid '+recid);

        action.setParams({ recordId : recid });
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var voucherstatus = response.getReturnValue();
                cmp.set("v.validVoucher",voucherstatus);

            } else {
                cmp.set("v.validVoucher",false);
            }
        });
        $A.enqueueAction(action);
    },
    
    // Method to register learner 
    registerLearner : function(cmp, evt, helper) {               
        
        // check if the user is new/existing user
        var newUser = true;
        var action1 = cmp.get('c.UserExisting');
        
        action1.setParams({ firstName : cmp.get("v.formWrap.FirstName"),
                           LastName  : cmp.get("v.formWrap.LastName"),
                           Email     : cmp.get("v.formWrap.Email") });
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue()) {
                    console.log('existing User...');
                    newUser = false;
                }
                
                // call server side action to register learner
                var action = cmp.get('c.addStudents');
                
                var jsonWrap = '{'+'\"Students\":[ ' + JSON.stringify(cmp.get("v.formWrap")) + ']}';
                console.log('jsonWrap..'+jsonWrap);
                action.setParams({ JSON : jsonWrap });
                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        // Enroll Learner via community
                        if(cmp.get("v.voucherId") != null) {
                            var compEvnt = cmp.getEvent("refreshVoucherList");
                            compEvnt.fire();
                        }
                        else if(!newUser && cmp.get("v.recordId")==null) {
                            var attributes = { url: '/claimVoucherSuccess?isNewLearner=false' };
                            $A.get("e.force:navigateToURL").setParams(attributes).fire();
                        }
                        else if(!newUser && cmp.get("v.recordId")!=null)
                        {
                           $A.get("e.force:closeQuickAction").fire();
                		   $A.get('e.force:refreshView').fire();
                        }
                        else if(newUser && cmp.get("v.recordId")!=null)
                        {
							$A.get("e.force:closeQuickAction").fire();
                			$A.get('e.force:refreshView').fire();                        
                        }
                        else {
                            var attributes = { url: '/claimVoucherSuccess?isNewLearner=true' };
                            $A.get("e.force:navigateToURL").setParams(attributes).fire();
                        }
                    }
                    else if (state === "ERROR") {
                        // Process error returned by server
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + errors[0].message);
                                cmp.set("v.errorMessage",errors[0].message);
                                cmp.set("v.showError",true);
                                
                                cmp.get("v.errorMessage");
                                cmp.get("v.showError");
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
                });
                $A.enqueueAction(action);
            }
            else if (state === "ERROR") {
                // Process error returned by server
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message1: " + errors[0].message);
                        cmp.set("v.errorMessage",errors[0].message);
                        cmp.set("v.showError",true);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action1);
    },
})