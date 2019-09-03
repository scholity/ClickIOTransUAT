({
    doInit : function(component, event, helper) {
        
        component.set("v.storeFrontName","CREStore");

        // Get today's date
        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth()+1; //January is 0!
        var yyyy = today.getFullYear();
        today = yyyy + '-' + mm + '-' + dd;
        component.set("v.todaysDate",today);

        var addInstru = new Array(1);
        component.set("v.AdditionalInstructors",addInstru);
        
        var action = component.get("c.fetchUser");
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
           
            if (state === "SUCCESS") {
                
                var storeResponse = response.getReturnValue();
                
                console.log("***storeResponse***"+storeResponse.Profile.UserLicense.Name);
                
                if(storeResponse.Profile.UserLicense.Name === "Salesforce"){
                    component.set("v.isExtUser", "false");
                }
                 if(storeResponse.Profile.Name === "SB PHSS-Partner-Community Plus Login"){
                    component.set("v.isPartner", true);
                }

               
                component.set("v.instructor", storeResponse);
            }
      
        });
        
        $A.enqueueAction(action);
        
        //get today's date
        var today	= new Date();
        
        var dd		= today.getDate();
        var mm		= today.getMonth()+1; //January is 0!
        var yyyy	= today.getFullYear();
        
        if(dd<10)
        {
            dd = '0'+dd
        } 
        
        if(mm<10)
        {
            mm = '0'+mm
        } 
        today = yyyy + '-' + mm + '-' + dd;
        
        component.set("v.MaxDate",today);
        
        
        //Will fetch AccountContactRelation record on the basis of loggedin user's ContactId
        /*var action = component.get("c.GetAccountContactRelation"); 
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if (state === "SUCCESS") {
                debugger;
                var data = response.getReturnValue();
                
                console.log("***data***"+data[0]);
                
                if(data != ''){
                    component.set("v.DisplayPaymentInfo", data[0].Display_Payment_Info__c);
                    //alert('Display_Payment_Info__c'+data[0].Display_Payment_Info__c);
                }
            }
        });
        
        $A.enqueueAction(action);*/
        
        /*
        var action = component.get("c.getAccountList");
        
        var options = [];
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var receivedValues = response.getReturnValue();
                component.set("v.acrInfo", receivedValues);
                
                // To display CRE as a lightning component tab
                /*if(!component.get("v.isCommunity")) {
                    component.set("v.stepNumber","One");
                    component.set("v.isShowForm", "true");
                }*/
            /*}
        });
        
        $A.enqueueAction(action);*/
    },
    
    productCountIncrement: function (component, event, helper) {
        var productQuantityMap = component.get('v.productQuantityMap');
        var productSfid = event.getParam('productSfid');
        
        console.log("productSfid**>>**"+productSfid);
        
        component.set("v.CCProductId",productSfid);

        //helper.getLearningPlanAttributes(component, event, helper);

        var delayInMilliseconds = "8000"; //10 seconds
        window.setTimeout(
            $A.getCallback(function() {
                helper.checkPreq(component, event, helper);
            }), delayInMilliseconds
        );     
        
        //var prodId = component.get();
        /*
        if (isNaN(productQuantityMap[productSfid])) {
            productQuantityMap[productSfid] = 1;
        }
        else {
            productQuantityMap[productSfid] = Number(productQuantityMap[productSfid]) + 1;
        }

        component.set('v.productQuantityMap', productQuantityMap);*/
        helper.checkLTSProductSpec(component, productSfid);
    },
    
    showPrompt : function(component, event, helper) {
        component.set("v.isPrompt", "true");	
	},
    
    closePrompt : function(component, event, helper) {
    	component.set("v.isPrompt", "false");
        console.log("closePrompt");
	},
    /*
    handleEvent : function(component, event, helper){
        event.setParams({"OppId": "0065B00000AqT1yQAF"});
        event.fire();
        console.log("handleEvent");
    },*/
        
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
            helper.uploadHelper(component, event);
        }
        //component.set("v.fileName", fileName);
        //component.set("v.showIcon", "true");
    },
    processingCRE : function(cmp, evt, hlpr)
    {    
        var checkbox = cmp.get("v.tncCheck");
      
        
        console.log("***checkbox***"+checkbox);
        if(!checkbox){
            cmp.set("v.tncError",true);
        }else{
            
            //Organization
            var accID = cmp.get("v.accId");
            
            //var accID = cmp.get("v.selectedValue");
            
            //Course
            var course =  cmp.get("v.courseId");
            
            //Course Ending Date            
            var endDate   = cmp.get("v.EndDate");
            var splitDate = endDate.split('-');
            
            var year 	  = splitDate[0];
            var month     = splitDate[1];
            var day 	  = splitDate[2]; 
            
            var endDateFrmtd = month + '/' + day + '/' + year;
            
            var startDate 	= cmp.get("v.StartDate");
            
            console.log("startDate***"+startDate);
            
            var splitDate1 = startDate.split('-');
            
            var year1 	  = splitDate1[0];
            var month1    = splitDate1[1];
            var day1	  = splitDate1[2]; 
            
            var startDateFrmtd = month1 + '/' + day1 + '/' + year1;
            
            // User            
            
            
            var extUser = cmp.get("v.isExtUser");
            var isParnter = cmp.get("v.isPartner");
          if(extUser === true && isParnter === false){
               
    
                        var user1 = cmp.get("v.instructor.Id");
                        console.log("***userInt***"+user1);
            }else{
                var user1 = cmp.get("v.userId1");
                console.log("***userExt***"+user1);
            }
            
            console.log('***user1***'+user1);
            var user2 = cmp.get("v.Instructor2"); 
            
            //Number of Students
            var numOfStudents = cmp.get("v.Students");
            console.log("numOfStudents" +numOfStudents);
            
            // Supplement Info
            
            var Suppinfo = cmp.get("v.SupplementInfo");
            console.log("Supp Info" +Suppinfo);
            //Training Site
            var tSite = cmp.get("v.Location"); // TODO: Remove this
            
            var siteName  = cmp.get("v.SiteName");
            var add1  = cmp.get("v.Address1");
            var add2  = cmp.get("v.Address2");
            var city  = cmp.get("v.City");
            var state = cmp.get("v.State");
            var zip   = cmp.get("v.Zip");
            
            
            var obj = new Object();
            
            obj.Account		=	accID;
            obj.Course		=	course;
            obj.EndDate		=	endDateFrmtd;
            obj.Students	=	numOfStudents;
            obj.SupplementInfo  =   Suppinfo;
            obj.Instructor1 =	user1;
            obj.Instructor2 =	user2;
            obj.Location	=	tSite;
            
            obj.StartDate	= 	startDateFrmtd;
            obj.SiteName    =   siteName;
            obj.Address1 	= 	add1;
            obj.Address2 	= 	add2;
            obj.City 		= 	city;
            obj.State 		= 	state;
            obj.Zip 		= 	zip;
            obj.OpportunityId = cmp.get("v.oppIdParent");
            var addInstr = '';
            if(typeof cmp.get("v.AdditionalInstructors") !== 'undefined' && cmp.get("v.AdditionalInstructors") != null)
            for(var i=0;i<cmp.get("v.AdditionalInstructors").length;i++){
                if(cmp.get("v.AdditionalInstructors")[i] != null)
                    addInstr = addInstr + cmp.get("v.AdditionalInstructors")[i].Id + ';';
            }
            obj.AdditionalInstructors = addInstr;
            
            console.log(obj);
            
            var classDetailJSON = JSON.stringify(obj);
            
            //Forming the json which accepts ILT Class details format
            
            classDetailJSON = '{'+'\"ClassDetails\": '+classDetailJSON+'}';
            
            console.log("***classDetailJSON***"+classDetailJSON);
            //Calling the server to assign the organization, location and etc in ILT Class & Session
            // Creating Json format and assigning the grades for that student(Passing value to server side controller)
            
            var studentDetails = cmp.get("v.numberOfStudentsList");
            var ids=new Array();
            var jsonStr = '';
            for (var idx=0; idx<studentDetails.length; idx++) {
                jsonStr += JSON.stringify(studentDetails[idx]);
                if(idx != (studentDetails.length)-1)
                    jsonStr+=',';
            }
            console.log(jsonStr);
            jsonStr = '{'+'\"Students\": ['+jsonStr+'] } ';
            console.log(jsonStr);
            
            var action = cmp.get("c.invokeMethods");
            console.log("cpsWrap: " + JSON.stringify(cmp.get("v.cpsWrap")));
            action.setParams({ JSON : classDetailJSON, JSON1 : jsonStr, wrapper: cmp.get("v.cpsWrap") });
            action.setCallback(this, function(response) {
                
                var state = response.getState();
                
                cmp.set("v.isSubmitted", 'true');
                
                console.log(state);
                if (state === "SUCCESS") {
                    
                     cmp.set("v.isSuccess", 'true');
                    
                    cmp.set("v.messageType", 'success' );
                    cmp.set("v.message", 'Completed Successfully!' );
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Record Saved Successfully.",
                        "type":"success"
                    });
                    toastEvent.fire();
                    $A.get("e.force:refreshView").fire();
                    //cmp.set("v.stepNumber", "Zero");

                }
                else if (state === "ERROR") {
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "message": "An error has occurred.",
                        "type":"error"
                    });
                    toastEvent.fire();
                    
                    //cmp.set("v.hasError", 'true');
                    
                    var errors = response.getError();
                    if (errors) {
                        
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                            cmp.set("v.messageType", 'error');
                            cmp.set("v.message", 'Please make sure you have selected a Valid Course');
                            
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
                
            });
            
            $A.enqueueAction(action);
        }
    },
    showPO : function(component, event, helper) {
        component.set("v.pMethod", "po");
    },
    
    showBillSprt : function(component, event, helper) {
        component.set("v.pMethod", "billSprt");
    },
    
    onGradeChange : function(component, event, helper) {
    	helper.mandateInput(component, event, helper);	    
    },
    
    onReasonChange : function(component, event, helper) {
    	helper.mandateInput(component, event, helper);	    
    },
    
    showSpinner : function (component, event, helper) {
        component.set("v.isSubmitted", 'true');
    },
    
    hideSpinner : function (component, event, helper) {
        component.set("v.isSubmitted", 'false');
    },
    showStep0 : function(component,event,helper){       
        component.set("v.stepNumber", "Zero");
    },
    
    showStep1 : function(component,event,helper){        
        component.set("v.stepNumber", "One");  
        component.set("v.isUploaded", 'false');
    },
    
    showStep2 : function(component,event,helper){
    var currentSN = component.get("v.stepNumber");
        if(currentSN != "One"){
        	component.set("v.stepNumber", "Two");
            console.log('This is step number 2');
        }
    },
    
    showStep3 : function(component,event,helper){
        var currentSN = component.get("v.stepNumber");
        if(currentSN === "Four"){
        	component.set("v.stepNumber", "Three");
            onsole.log('This is step number 3');

        }
    },
    
    updatePaymentComplete : function(component,event,helper){
         component.set("v.paymentComplete", true);
        console.log('check if payment completed'+component.get("v.paymentComplete"));
        helper.processingCRE(component, event, helper);
        component.set("v.showLoadingSpinner", true);
        
    },
    cancel : function(component, event, helper){
        $A.get("e.force:refreshView").fire();
        //$A.get("e.force:refreshView").fire();
        component.set("v.stepNumber", "Zero");
    },
    
    calculateStudentInstructorRatio : function(component,event,helper){
        var CCProductId = component.get("v.CCProductId");
        var Students = component.get("v.Students");
          var extUser = component.get("v.isExtUser");
        var isParnter = component.get("v.isPartner");
        if(Students == null || Students == "") {
            Students = 0;
        }
      
        //
        if(typeof CCProductId !== 'undefined' && typeof Students !== 'undefined'){
        if(CCProductId && Students){ 
            var totalStudents = parseInt(Students);
            var SIRatio;
    		var action = component.get("c.getLearningPlanId");
            action.setParams({ccProdId : CCProductId});
        	action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                //alert('InSuccess-->'+JSON.stringify(storeResponse));
                if(storeResponse.LMS_Learning_Plan__c) {
                    component.set("v.courseId", storeResponse.LMS_Learning_Plan__c);}
     
                if (storeResponse.Course_Catalog__c && storeResponse.Course_Catalog__r.Ratio_to_Instructor__c) {
                    SIRatio = storeResponse.Course_Catalog__r.Ratio_to_Instructor__c;
                } else if (storeResponse.Ratio_to_Instructor__c) {
                    SIRatio = storeResponse.Ratio_to_Instructor__c;
                }
                
                if (SIRatio && SIRatio.includes(':')) {
                    var arr_SIRatio = SIRatio.split(':');
                    if (arr_SIRatio[0] && arr_SIRatio[1]) {
                        var ratio = parseInt(arr_SIRatio[0])/parseInt(arr_SIRatio[1]);
                        var numberOfInstructors = Math.ceil(totalStudents*ratio)-1;
                        
                        if (numberOfInstructors < 0) {
                            numberOfInstructors = 0;
                        }
                        component.set("v.StudentInstructorRatio", numberOfInstructors);
                        if(numberOfInstructors > 0 && numberOfInstructors <= 6){
                            var arr_Instructors = new Array(numberOfInstructors);
                            component.set("v.AdditionalInstructors", arr_Instructors);
                        }
                        else if(numberOfInstructors == 0){
                            var arr_Instructors = new Array(1);
                            component.set("v.AdditionalInstructors", arr_Instructors);
                        }
                            else{
                                var arr_Instructors = new Array(6);
                                component.set("v.AdditionalInstructors", arr_Instructors);
                            }
                    } else {
                        var arr_Instructors = new Array(1);
                        component.set("v.AdditionalInstructors", arr_Instructors);                                    
                    }
                }   
            } 
        });
        $A.enqueueAction(action);
        }
        }
    
    },
    
    handleComponentEvent : function(component, event, helper) {
  
      var instanceID = event.getParam('instanceID');
        if(instanceID.includes('Instructor')){
            var itemNumber = parseInt(instanceID.slice(10));
            var addInstr = component.get("v.AdditionalInstructors");
            if(event.getParam('isClear')){ 
            	//addInstr[itemNumber-1] = null; 
            	delete addInstr[itemNumber-1];
                //component.set("v.AdditionalInstructors",addInstr); 
                console.log('OnDelete-->');
                console.log(component.get("v.AdditionalInstructors"));
            }
            else{ 
                addInstr[itemNumber-1] = event.getParam('SelectedValue');
                //component.set("v.AdditionalInstructors",addInstr);
                console.log('OnAdd-->');
                console.log(component.get("v.AdditionalInstructors"));
            }             
        }
      	
	},
    
    
    onclickNext : function(component,event,helper){

        
        var currentSN = component.get("v.stepNumber");
        var DispPaymentInfo = component.get("v.DisplayPaymentInfo");
        
        if(currentSN == "One")
        {
            var vorgId 	= component.get("v.selectedLookUpRecord1").Id
            
            var orgBool	= true;
            
            if(vorgId === undefined){
                component.set("v.orgError",true);
                orgBool	= false;
            }else{
                component.set("v.orgError",false);
            }
            
            var vcrsId 	= component.get("v.selectedLookUpRecord2").Id
            var crsBool	= true;
            if(vcrsId === undefined){
                component.set("v.crsError",true);
                crsBool	= false;
            }else{
                component.set("v.crsError",false);
            }
            var intUsrId = component.get("v.selectedLookUpRecord4").Id;
            var usrBool	 = true;
            if(intUsrId === undefined){
                component.set("v.usrError",true);
                usrBool	= false;
            }else{
                component.set("v.usrError",false);
            }
            var instructorHasPrerequisites = component.get('v.instructorHasPrerequisites');
            if (instructorHasPrerequisites === false && usrBool) {
                component.set("v.prereqError", true);
            } else {
                component.set("v.prereqError", false);
            }
            var allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);

            allValid &= instructorHasPrerequisites;

            var extUser = component.get("v.isExtUser");
            //var isParnter = component.get("v.isParnter")
            if(extUser === true)
            {
                //if(allValid && orgBool && crsBool)
                if(allValid && orgBool)
                {
                    helper.stepOne(component, event);
                }
            } else {
                //if(allValid && orgBool && crsBool && usrBool)
                if(allValid && orgBool && usrBool)
                {
                    helper.stepOne(component, event);
                }
            }
            // Show/hide credit card info
            //Will fetch AccountContactRelation record on the basis of loggedin user's ContactId and selected account id
            if(component.get("v.oppIdParent")) {
                var action = component.get("c.getDisplayPaymentInfo"); 
                console.log('opp..'+component.get("v.oppIdParent"));
                action.setParams({ opportunityId : component.get("v.oppIdParent")});
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        // debugger;
                        
                        var data = response.getReturnValue();
                        console.log('data..'+data);
                        component.set("v.displayPaymentInfo", data);
                        console.log('display..'+component.get("v.displayPaymentInfo"));
                        component.set('v.showExtendedPrice', !data);
                    }
                });
                $A.enqueueAction(action); 
            }
            helper.createIltLocation(component);
        }
        
        else if(currentSN == "Two")
        {

            var isLTS = component.get('v.isLearnToSwimProduct');
            if (isLTS) {
                var isValid = component.get("v.allValid");
                if (isValid) {
                    var action = component.get("c.updateCartProducts");

                    action.setParams({opportunitySfid : component.get("v.oppIdParent"),
                        CCProductId : component.get("v.CCProductId"),
                        noOfStudents : component.get("v.Students"),
                        storeFrontName : 'CREStore'});
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {

                            var storeResponse = response.getReturnValue();
                            console.log("Cart updated"+storeResponse);
                        }
                    });
                    $A.enqueueAction(action);

                    for(var i=0;i<component.get("v.AdditionalInstructors").length;i++){
                        var val = component.get("v.AdditionalInstructors")[0];
                        if(val) {
                            component.set("v.isAddInstructors",true);
                        }
                    }

                    component.set("v.stepNumber", "Three");
                }

            } else {

                var allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
                }, true);

                helper.validateInput(component, event, helper);

                if(component.get("v.allValid") && allValid)
                {
                    var action = component.get("c.updateCartProducts");

                    action.setParams({opportunitySfid : component.get("v.oppIdParent"),
                        CCProductId : component.get("v.CCProductId"),
                        noOfStudents : component.get("v.Students"),
                        storeFrontName : 'CREStore'});
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {

                            var storeResponse = response.getReturnValue();
                            console.log("Cart updated"+storeResponse);
                        }
                    });
                    $A.enqueueAction(action);

                    for(var i=0;i<component.get("v.AdditionalInstructors").length;i++){
                        var val = component.get("v.AdditionalInstructors")[0];
                        if(val) {
                            component.set("v.isAddInstructors",true);
                        }
                    }

                    component.set("v.stepNumber", "Three");

                }
                else if(component.get("v.allValid") && allValid)
                {
                    component.set("v.stepNumber", "Four");
                }
            }
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
    
    accountSelected : function (component,event,helper){
        console.log("account Selected");
        var orgId 	= component.get("v.selectedLookUpRecord1").Id
        
        component.set("v.accId",orgId);
        
        console.log("***orgId***"+orgId);
        if(orgId != null || orgId != undefined){
        var opptyId = component.get("v.oppIdParent");
        var action = component.get("c.createOppForCCUpdate");
        
        action.setParams({
            AccountId: orgId,
            storeFront: 'CRE',
            opptyId : opptyId
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
        }
    },

    siteSelected: function(component, event, helper) {
        var siteId = component.get("v.selectedLookUpRecord5").Id;
        var selectedSite = component.get("v.selectedLookUpRecord5");
        console.log(JSON.stringify(selectedSite));
        component.set("v.SiteName", selectedSite["Name"]);
        component.set("v.Address1", selectedSite["redwing__Address_1__c"]);
        component.set("v.Address2", selectedSite["redwing__Address_2__c"]);
        component.set("v.City", selectedSite["redwing__City__c"]);
        component.set("v.State", selectedSite["redwing__State__c"]);
        component.set("v.Zip", selectedSite["redwing__Postal_Code__c"]);
    },
    
    cancel : function(component, event, helper){
        $A.get("e.force:refreshView").fire();
        component.set("v.stepNumber", "Zero");
    }
})