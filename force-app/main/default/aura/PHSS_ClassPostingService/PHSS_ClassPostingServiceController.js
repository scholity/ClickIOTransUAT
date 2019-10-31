({
	doInit : function(component, event, helper) {
		component.set("v.storeFrontName","CPS");
        
        helper.initializeWrapper(component, event, helper);
        helper.initalizeProductQuantityMap(component, event, helper);
        
        var days = '7';
        
        // Get today's date
        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth()+1; //January is 0!
        var yyyy = today.getFullYear();
        today = yyyy + '-' + mm + '-' + dd;
        component.set("v.todaysDate",today);

        // Get today's date plus 7
        var todayPlus7 = new Date();
        todayPlus7.setTime(todayPlus7.getTime() + (days * 24 * 60 * 60 * 1000));
        dd = todayPlus7.getDate();
        mm = todayPlus7.getMonth()+1; //January is 0!
        yyyy = todayPlus7.getFullYear();
        todayPlus7 = yyyy + '-' + mm + '-' + dd;
		//alert('Date + 7 ' + todayPlus7);        
        
        component.set("v.todaysDatePlus7",todayPlus7);
    },
    
    productCountIncrement: function (component, event, helper) {
        var productSfid = event.getParam('productSfid');
        var previousCCProductId = component.get("v.cpsWrap.ccProductId");
        var previousQuantity = component.get("v.cpsWrap.quantity");
        
        console.log("productSfid**>>**"+productSfid);
 
        //Edit Changed Product
        if(previousCCProductId != "" && previousQuantity == "0"){
            component.set("v.productChange", true);
            component.set("v.cpsWrap.ccProductId",previousCCProductId);
            component.set("v.cpsWrap.quantity", "-1");
            helper.updateProductQuantityMap(component,event,helper);
		}
        component.set("v.courseError",false);
        component.set("v.scheduleError",false);
        component.set("v.CCProductId",productSfid);
        component.set("v.cpsWrap.ccProductId",productSfid);
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
		//helper.requiredSchedule(component,event,helper);
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
        component.set("v.cpsWrap.sessionList",tempList);
    },
    
    editOffering : function(component, event, helper) {
 		var edit_index = event.getSource().get('v.value');
        //alert("Edit Offering: " + edit_index); 
        
        var tempList = component.get("v.offeringsList");
        
        if(edit_index == 'One'){
            edit_index = tempList.length;
        }
        
        var offering = tempList[edit_index -1];

        //component.set("v.offeringId", offering.offeringId);
        component.set("v.courseError",false);
        component.set("v.formatError",false);
        component.set("v.zoneError",false);
        component.set("v.scheduleError",false);
        component.set("v.showError",false);
        component.set("v.productChange", false);
		component.set("v.cpsWrap.offeringId", offering.offeringId);
        component.set("v.cpsWrap.accId",offering.accId);
        component.set("v.cpsWrap.accName",offering.accName);
        component.set("v.CCProductId",offering.ccProductId);
        component.set("v.cpsWrap.ccProductId",offering.ccProductId);
		component.set("v.LPName", offering.courseName);
        component.set("v.cpsWrap.courseName",offering.courseName);
        component.set("v.cpsWrap.courseId",offering.courseId);
        component.set("v.LPClassroomSetting",offering.classFormat);
        component.set("v.cpsWrap.classFormat",offering.classFormat);
        component.set("v.cpsWrap.quantity","0");
        component.set("v.LPDuration",offering.classDuration);
        component.set("v.cpsWrap.classDuration",offering.classDuration);
        component.set("v.cpsWrap.sessionList",offering.sessionList);
        component.set("v.cpsWrap.locationId",offering.locationId);
        component.set("v.cpsWrap.siteName",offering.siteName);
        component.set("v.cpsWrap.address1",offering.address1);
        component.set("v.cpsWrap.address2",offering.address2);
        component.set("v.cpsWrap.city",offering.city);
        component.set("v.cpsWrap.state",offering.state);
        component.set("v.cpsWrap.zip",offering.zip);
        component.set("v.cpsWrap.geoLat",offering.geoLat);
        component.set("v.cpsWrap.geoLng",offering.geoLng);
        component.set("v.cpsWrap.regUrl",offering.regUrl);
        component.set("v.cpsWrap.regPhone",offering.regPhone);
        component.set("v.cpsWrap.regFee",offering.regFee);
        component.set("v.selectedLookUpRecord1",offering.OfferingInformation.selectedAccount);
        component.set("v.selectedLookUpRecord5",offering.OfferingInformation.selectedFacility);
		//alert("Selected Facility "+ JSON.stringify((offering.OfferingInformation.selectedFacility)));

		helper.requiredSchedule(component,event,helper);
		component.set("v.stepNumber", "One");        
    },
    
    deleteOffering : function(component, event, helper) {
        var del_index = event.getSource().get('v.value');
        //alert("Delete Offering: " + del_index);  

		var tempList = component.get("v.offeringsList");
        var offering = tempList[del_index -1];
        var offeringStartDate = $A.localizationService.formatDate(offering.sessionList[0].classDate, "MM/dd/yyyy");

        var yes = confirm("Are you you sure want to delete offering: " + offering.courseName + " " + offeringStartDate );
        
        
        if(yes){
            var newOfferingId = 0;
            var newOfferingList = [];
            tempList.forEach(function(offering) {
                if(offering.offeringId != del_index){
                    offering.offeringId = ++newOfferingId;
                    newOfferingList.push(offering);
                } else {
                    component.set("v.cpsWrap.ccProductId",offering.ccProductId);
                    component.set("v.cpsWrap.quantity", "-1");
                    helper.updateProductQuantityMap(component,event,helper);
                }
            });
            component.set("v.offeringId", newOfferingId);
            component.set("v.offeringsList",newOfferingList);
        }
		
        if(newOfferingList.length <= 0){
            $A.get("e.force:refreshView").fire();
        }

    },   
    addSession : function(component, event, helper) {
        var lastDate = '';
        var tempList = component.get("v.cpsWrap.sessionList");
        
        //Get the Last Session Date to Set on Calendar
        tempList.forEach(function(session) {
            lastDate = session.classDate
        });
        
        component.set("v.todaysDateFromLastEnterDate", lastDate);
        
        tempList.push({'classDate':'',
                       'startTime':'',
                       'endTime':'',
                       'timeZone':tempList[0].timeZone,});
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
        var timeOut = '2000';
        
        if(currentSN == "One")            
        {
            helper.updateGeoLatLong(component,event,helper);
            helper.requiredSchedule(component,event,helper);
            helper.formatTime(component,event,helper);
            helper.validateFields(component,event,helper);
            helper.createIltLocation(component);
            
            if(component.get('v.cpsWrap.locationId') != ""){
                var timeOut = '0';
            }
            
            if(component.get("v.allValid") == false && component.get("v.offeringId") > 0 && component.get("v.cpsWrap.offeringId") == "0"){
                    component.set("v.showError","false");
                    component.set("v.errorMessage","");
            }
            
            if(component.get("v.allValid") == true){
                document.getElementById("Accspinner").style.display = "block";
            }
            
            
        	setTimeout(function(){
                document.getElementById("Accspinner").style.display = "none";
                //alert("Location ID " + component.get('v.cpsWrap.locationId'));

                var vorgId 	= component.get("v.selectedLookUpRecord1").Id
                if(vorgId === undefined){
                    component.set("v.orgError",true);
                }else{
                    component.set("v.orgError",false);
                }
                
                if(component.get("v.allValid") && component.get("v.isUrlValid") && !component.get("v.orgError")) {
                    var tempList = component.get("v.offeringsList");
                    var existingOfferingInCart = component.get("v.cpsWrap.offeringId");
                    var offeringJson = JSON.stringify(component.get("v.cpsWrap"));
                    //alert('***New Offerings.. '+offeringJson);
                    if(existingOfferingInCart != "0"){
                        tempList[existingOfferingInCart -1].quantity = "1";
                        if(component.get("v.productChange")){
                            component.set("v.cpsWrap.quantity", "1");
                        } else {
                            component.set("v.cpsWrap.quantity", "0");
                        }
                        component.set("v.productChange", false);
                        tempList[existingOfferingInCart -1] = JSON.parse(offeringJson);
                        
                    } else {
                        var offeringId = component.get("v.offeringId");
                        offeringId = offeringId + 1;
                        component.set("v.offeringId", offeringId);
                        component.set("v.cpsWrap.offeringId", offeringId);
                        component.set("v.cpsWrap.quantity", "1");
                        offeringJson = JSON.stringify(component.get("v.cpsWrap"));
                        tempList.push(JSON.parse(offeringJson));                 
                    }
                    component.set("v.offeringsList", tempList);
    
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
                    
                    helper.updateProductQuantityMap(component,event,helper);
                    
                    helper.clearForm(component,event,helper);
                    
                    component.set("v.stepNumber", "Two");    
                } else if(component.get("v.offeringId") > 0 && component.get("v.cpsWrap.offeringId") == "0") {
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
                    
                    helper.clearForm(component,event,helper);
                    
                    component.set("v.showError","false");
                    component.set("v.errorMessage","");
                    component.set("v.stepNumber", "Two");
                }
        	},timeOut);
        }
        else if(currentSN == "Three")
        {
            component.set("v.stepNumber", "Four");	
            console.log("***PaymentInfo " + JSON.stringify(component.get("v.displayPaymentInfo")));
        }
        else if(currentSN == "Two")
        {
            helper.formatTime(component,event,helper);
            
            //alert("myProductQuantityMap "+ JSON.stringify(component.get("v.myProductQuantityMap")) );
            var action = component.get("c.updateCartProducts");
            action.setParams({opportunitySfid : component.get("v.oppIdParent"),
                              productQuantityMap : component.get("v.myProductQuantityMap")});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    //alert("Updated Cart!")
                    var storeResponse = response.getReturnValue();
                } 
            });
            $A.enqueueAction(action);
            
            component.set("v.stepNumber", "Three");
        }
        else if(currentSN == "Four")
        {
            //helper.clearForm(component,event,helper);
        	$A.get("e.force:refreshView").fire();
        	component.set("v.stepNumber", "Complete");
        }
    },
    
    showStep1 : function(component,event,helper){
        component.set("v.stepNumber", "One");
    },
    
    showStep2 : function(component,event,helper){
        if(component.set("v.stepNumber") == "One") {
            helper.requiredSchedule(component,event,helper);
        	helper.validateFields(component,event,helper);
            if(component.get("v.allValid") && component.get("v.isUrlValid")) {
                helper.formatTime(component,event,helper);
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
            helper.formatTime(component,event,helper);
            helper.validateFields(component,event,helper);
            helper.createIltLocation(component);

            if(component.get("v.allValid") == true){
                document.getElementById("Accspinner").style.display = "block";
            }
        
        	setTimeout(function(){
                document.getElementById("Accspinner").style.display = "none";
                //alert("Location ID " + component.get('v.cpsWrap.locationId'));
                
                var vorgId 	= component.get("v.selectedLookUpRecord1").Id
                if(vorgId === undefined){
                    component.set("v.orgError",true);
                }else{
                    component.set("v.orgError",false);
                }
                
                if(component.get("v.allValid") && component.get("v.isUrlValid") && !component.get("v.orgError")) {
                    var tempList = component.get("v.offeringsList");
                    var existingOfferingInCart = component.get("v.cpsWrap.offeringId");
                    var offeringJson = JSON.stringify(component.get("v.cpsWrap"));
                    //alert('***New Offerings.. '+offeringJson);
                    if(existingOfferingInCart != "0"){
                        tempList[existingOfferingInCart -1].quantity = "1";
                        if(component.get("v.productChange")){
                            component.set("v.cpsWrap.quantity", "1");
                        } else {
                            component.set("v.cpsWrap.quantity", "0");
                        }
                        component.set("v.productChange", false);
                        tempList[existingOfferingInCart -1] = JSON.parse(offeringJson);
                    } else {
                        var offeringId = component.get("v.offeringId");
                        offeringId = offeringId + 1;
                        component.set("v.offeringId", offeringId);
                        component.set("v.cpsWrap.offeringId", offeringId);
                        component.set("v.cpsWrap.quantity", "1");
                        offeringJson = JSON.stringify(component.get("v.cpsWrap"));
                        tempList.push(JSON.parse(offeringJson));                    
                    }
                    component.set("v.offeringsList", tempList);
                    //alert("Offerings " + JSON.stringify(component.get("v.offeringsList")));
                    
                    helper.updateProductQuantityMap(component,event,helper);
    
                    var offeringStartDate = $A.localizationService.formatDate(component.get("v.cpsWrap.sessionList[0].classDate"), "MM/dd/yyyy");
                    alert("Offering " + component.get("v.cpsWrap.courseName") + " " +  offeringStartDate + " has been add to your shopping cart.\n\nTo continue adding offerings to your shopping cart click on the \"Add To Cart\" button. When you are finished adding offerings, click on the \"Next\" button to review your Order Summary.");
                    helper.clearForm(component,event,helper);
                    component.set("v.stepNumber", "One");    
                }
            },2000);
    },
    
    createClass : function(component, event, helper) {

		//alert("myProductQuantityMap "+ JSON.stringify(component.get("v.myProductQuantityMap")) );
        var action = component.get("c.updateCartProducts");
        action.setParams({opportunitySfid : component.get("v.oppIdParent"),
                          productQuantityMap : component.get("v.myProductQuantityMap")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var storeResponse = response.getReturnValue();
                console.log("Cart updated"+storeResponse);
            }
        });
        $A.enqueueAction(action);

        helper.createClass(component, event, helper);
        $A.get("e.force:refreshView").fire();

    },
    
    cancel : function(component, event, helper){
        //helper.clearForm(component,event,helper);
        
        var madePayment = component.get("v.paymentComplete");
        
        if(madePayment)            
        {
            var button = component.find("cancelButton");
        	$A.util.addClass(button.getElement(), 'slds-hidden');
            /*
            var yes = confirm("You have already submitted yor payment. If you Cancel now, the offering(s) you paid for will Not be Posted on RCO! To post your offering(s) click on Cancel on the dialog window and then click on Checkout at the bottom right.");
       
            if(yes){
                $A.get("e.force:refreshView").fire();
                component.set("v.stepNumber", "Zero");
            }
            */
        } else {
        	$A.get("e.force:refreshView").fire();
        	component.set("v.stepNumber", "Zero");
        }
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
        if(!$A.util.isUndefinedOrNull(siteId)){
            console.log("Site Selected: " + JSON.stringify(selectedSite));
            component.set("v.cpsWrap.siteName", selectedSite["Name"]);
            component.set("v.cpsWrap.address1", selectedSite["redwing__Address_1__c"]);
            component.set("v.cpsWrap.address2", selectedSite["redwing__Address_2__c"]);
            component.set("v.cpsWrap.city", selectedSite["redwing__City__c"]);
            component.set("v.cpsWrap.state", selectedSite["redwing__State__c"]);
            component.set("v.cpsWrap.zip", selectedSite["redwing__Postal_Code__c"]);
            component.set('v.cpsWrap.locationId', siteId);
        	//alert("siteSelected Location ID " + siteId);
            //alert("siteSelected Location ID " + component.get('v.cpsWrap.locationId'));            
        }

    },
    updatePaymentComplete : function(component,event,helper){

        component.set("v.paymentComplete", true);

        console.log('check if payment completed'+component.get("v.paymentComplete"));

    },

})