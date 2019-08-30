({
	doInit : function(component, event, helper) {
		component.set("v.storeFrontName","CPSStore");
        
        helper.initializeWrapper(component, event, helper);
        	
        // Get today's date
        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth()+1; //January is 0!
        var yyyy = today.getFullYear();
        today = yyyy + '-' + mm + '-' + dd;
        component.set("v.todaysDate",today);
        
        
          
    },
    
    productCountIncrement: function (component, event, helper) {
        var productQuantityMap = component.get('v.productQuantityMap');
        var productSfid = event.getParam('productSfid');
        
        console.log("productSfid**>>**"+productSfid);
        
        component.set("v.CCProductId",productSfid);
        helper.getLearningPlanAttributes(component, event, helper);
        
        //console.log("CCProductId " + component.get('v.CCProductId'));
        //console.log("LPName " + component.get('v.LPName'));
        //console.log("LPClassroomSetting " + component.get('v.LPClassroomSetting'));
        //console.log("LPDuration " + component.get('v.LPDuration'));
        
    },
    
    onAddressChange : function (component, event, helper) {
        if(component.get("v.cpsWrap.address1") &&
           component.get("v.cpsWrap.city") &&
           component.get("v.cpsWrap.state") &&
           component.get("v.cpsWrap.zip"))
           helper.getGeocode(component,event,helper);
    },  
    onFormatChange : function(component, event, helper) {
        component.set("v.formatError",false);
        
        // Class format validation
        var format = document.getElementById('formatSelect').value;
        component.set("v.cpsWrap.classFormat",format);
        if(component.get("v.cpsWrap.classFormat")) {
            document.getElementById('formatSelect').classList.remove('requiredSelect');
        }
        else {
            component.set("v.formatError",true);
            document.getElementById('formatSelect').classList.add('requiredSelect');
        }
    },
    
    onZoneChange : function(component, event, helper) {
        helper.requiredSchedule(component,event,helper);
        component.set("v.zoneError",false);
        
        // Time Zone validation
        var tempList = component.get("v.cpsWrap.sessionList");
        tempList.forEach(function(session) {
            session.timeZone = document.getElementById('zoneSelect').value;
            if(session.timeZone) {
                document.getElementById('zoneSelect').classList.remove('requiredSelect');
            }
            else {
                component.set("v.zoneError",true);
                document.getElementById('zoneSelect').classList.add('requiredSelect');
            }
        });
        component.set("v.cpsWrap.sessionList",updatedList);
    },
    

    addSession : function(component, event, helper) {
        var tempList = component.get("v.cpsWrap.sessionList");
        tempList.push({'classDate':'',
                       'startTime':'',
                       'endTime':''});
        component.set("v.cpsWrap.sessionList",tempList);
        
        helper.requiredSchedule(component,event,helper);
        
    },
    
    deleteSession : function(component, event, helper) {
        var del_index = event.getSource().get('v.value');
        console.log("Delete Record: " + del_index);
        
        var tempList = component.get("v.cpsWrap.sessionList");
        tempList.splice( tempList.indexOf(del_index), 1 );
        component.set("v.cpsWrap.sessionList",tempList);

        helper.requiredSchedule(component,event,helper);
        
    },
    
    
    onclickNext : function(component,event,helper){
        
        var currentSN = component.get("v.stepNumber");
        
        if(currentSN == "One")            
        {
            helper.updateGeoLatLong(component,event,helper);
            helper.requiredSchedule(component,event,helper);
            helper.formatTime(component,event,helper);
            helper.validateFields(component,event,helper);
            helper.createIltLocation(component);
            
            var vorgId 	= component.get("v.selectedLookUpRecord1").Id
            if(vorgId === undefined){
                component.set("v.orgError",true);
            }else{
                component.set("v.orgError",false);
            }
            
            if(component.get("v.allValid") && component.get("v.isUrlValid") && !component.get("v.orgError")) {
                // Show/hide credit card info
                //Will fetch AccountContactRelation record on the basis of loggedin user's ContactId and selected account id
                var action = component.get("c.getDisplayPaymentInfo"); 
                action.setParams({ opportunityId : component.get("v.oppIdParent")});
                action.setCallback(this, function(response) {
                    
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        //debugger;
                        console.log("Payment Info: " + JSON.stringify(response));
                        var data = response.getReturnValue();
                        component.set("v.displayPaymentInfo", data);
                    }
                });
                $A.enqueueAction(action);
                
            	component.set("v.stepNumber", "Two");    
            }
        }
        else if(currentSN == "Two")
        {
            helper.formatTime(component,event,helper);
            component.set("v.stepNumber", "Three");	
            console.log("***PaymentInfo " + JSON.stringify(component.get("v.displayPaymentInfo")));
        }
        else if(currentSN == "Three")
        {
            component.set("v.stepNumber", "Four");
        }
        else if(currentSN == "Four")
        {
        	component.set("v.stepNumber", "Complete");
        }
    },
    
    showStep1 : function(component,event,helper){
        component.set("v.stepNumber", "One");
        component.set("v.cpsWrap.zip","");
        /*
        var action = component.get("c.createOppForCC");
        action.setParams({
            AccountId: component.get("v.cpsWrap.accId")
        });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            
            console.log(state);
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if(storeResponse != null){
                   component.set("v.oppIdParent",storeResponse);
                }
            }
            else if (state === "ERROR") {
                
                var errors = response.getError();
                if (errors) {
                    
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            
        });
        
        $A.enqueueAction(action);
        */
    },
    
    showStep2 : function(component,event,helper){
        if(component.set("v.stepNumber") == "One") {
            helper.requiredSchedule(component,event,helper);
        	helper.validateFields(component,event,helper);
            if(component.get("v.allValid") && component.get("v.isUrlValid")) {
                component.set("v.stepNumber", "Two");    
            }    
        }
        else {
            component.set("v.stepNumber", "Two");
        }
        
    },
    
    showStep3 : function(component,event,helper){
        if(component.set("v.stepNumber") == "One") {
            helper.requiredSchedule(component,event,helper);
            helper.validateFields(component,event,helper);
            if(component.get("v.allValid") && component.get("v.isUrlValid")) {
                helper.formatTime(component,event,helper);
                component.set("v.stepNumber", "Three");    
            }
        }
        else {
            helper.formatTime(component,event,helper);
            component.set("v.stepNumber", "Three"); 
        }
    },
    
    showPO : function(component, event, helper) {
        component.set("v.pMethod", "po");
    },
    
    showBillSprt : function(component, event, helper) {
        component.set("v.pMethod", "billSprt");
    },
    
    onclickAddToCart : function(component, event, helper) { 
        helper.updateGeoLatLong(component,event,helper);
        helper.requiredSchedule(component,event,helper);
        helper.validateFields(component,event,helper); 

            var vorgId 	= component.get("v.selectedLookUpRecord1").Id
            if(vorgId === undefined){
                component.set("v.orgError",true);
            }else{
                component.set("v.orgError",false);
            }
            
            if(component.get("v.allValid") && component.get("v.isUrlValid") && !component.get("v.orgError")) {
                //Will fetch AccountContactRelation record on the basis of loggedin user's ContactId and selected account id
                var action = component.get("c.getDisplayPaymentInfo"); 
                action.setParams({ opportunityId : component.get("v.oppIdParent")});
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                //        debugger;
                //        var data = response.getReturnValue();
                        component.set("v.displayPaymentInfo", FALSE);
                    }
                 });
				$A.enqueueAction(action);
                helper.clearForm(component,event,helper);
            	component.set("v.stepNumber", "One"); 
            } 
    },
    
    createClass : function(component, event, helper) {


        var action = component.get("c.updateCartProducts");
        
        action.setParams({opportunitySfid : component.get("v.oppIdParent"),
                          CCProductId : component.get("v.CCProductId"),
                          noOfStudents : '1',
                          storeFrontName : 'CPS'});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var storeResponse = response.getReturnValue();
                console.log("Cart updated"+storeResponse);
            }
        });
        $A.enqueueAction(action);

        helper.createClass(component, event, helper);    
    },
    
    cancel : function(component, event, helper){
        helper.clearForm(component,event,helper);
        component.set("v.stepNumber", "Zero");
    },
        
    handleChange : function (component, event) {
        // This will contain the string of the "value" attribute of the selected option
        var selectedOptionValue = event.getParam("value");
        alert("Option selected with value: '" + selectedOptionValue + "'");
    },
    
	accountSelected : function (component,event,helper){
        console.log("account Selected");
        var orgId 	= component.get("v.selectedLookUpRecord1").Id
        
        component.set("v.cpsWrap.accId",orgId);
        
        console.log("***orgId***"+orgId);
        if(orgId != null || orgId != undefined){
        var opptyId = component.get("v.oppIdParent");
        var action = component.get("c.createOppForCCUpdate");
        console.log("***oppId***"+opptyId);
        action.setParams({
            AccountId: orgId,
            storeFront: 'CPS',
            opptyId : opptyId
        });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            
            console.log(state);
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if(storeResponse != null){
                   component.set("v.oppIdParent",storeResponse);
 		   		   component.set("v.cpsWrap.oppId",storeResponse);
                }
            }
            else if (state === "ERROR") {
                
                var errors = response.getError();
                if (errors) {
                    
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            
        });
        
        $A.enqueueAction(action);
        }
    },
    
    
    afterGoogleMapsLoaded : function(component, event, helper) {
        console.log("Google Maps API Call");
    },
    siteSelected: function(component, event, helper) {
        var siteId = component.get("v.selectedLookUpRecord5").Id;
        var selectedSite = component.get("v.selectedLookUpRecord5");
        console.log("Site Selected: " + JSON.stringify(selectedSite));
        component.set("v.cpsWrap.siteName", selectedSite["Name"]);
        component.set("v.cpsWrap.address1", selectedSite["redwing__Address_1__c"]);
        component.set("v.cpsWrap.address2", selectedSite["redwing__Address_2__c"]);
        component.set("v.cpsWrap.city", selectedSite["redwing__City__c"]);
        component.set("v.cpsWrap.state", selectedSite["redwing__State__c"]);
        component.set("v.cpsWrap.zip", selectedSite["redwing__Postal_Code__c"]);
    },
    updatePaymentComplete : function(component,event,helper){

        component.set("v.paymentComplete", true);

        console.log('check if payment completed'+component.get("v.paymentComplete"));

    },
})