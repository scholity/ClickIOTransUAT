({
    doInit : function(component, event, helper) {
        
        component.set("v.storeFrontName","CREStore");
        //component.set("v.storeFrontName","GeneralStore");
        helper.initializeWrapper(component, event, helper);
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
        var mm		= today.getMonth() + 1; //January is 0!
        var yyyy	= today.getFullYear();
        
        if(dd < 10)
        {
            dd = '0' + dd
        } 
        
        if(mm < 10)
        {
            mm = '0' + mm
        } 
        today = yyyy + '-' + mm + '-' + dd;
        component.set("v.MaxDate",today);
    },

    validateEmail : function(component, event, helper) {
        log.console("validateEmail!!!");
        var isValidEmail = true;
        var emailField = component.find("emailField");
        var emailFieldValue = emailField.get("v.value");
        // Store Regular Expression That 99.99% Works. [ http://emailregex.com/]
        //var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        var regExpEmailformat = /[a-zA-Z0-9\\+\\.\\_\\%\\-\\+]{1,256}\\@[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}(\\.[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25})+/;
        // check if Email field in not blank,
        // and if Email field value is valid then set error message to null,
        // and remove error CSS class.
        // ELSE if Email field value is invalid then add Error Style Css Class.
        // and set the error Message.
        // and set isValidEmail boolean flag value to false.

        if(!$A.util.isEmpty(emailFieldValue)){
            if(emailFieldValue.match(regExpEmailformat)){
                emailField.set("v.errors", [{message: null}]);
                $A.util.removeClass(emailField, 'slds-has-error');
                isValidEmail = true;
            }else{
                $A.util.addClass(emailField, 'slds-has-error');
                log.console("Here!!!");
                emailField.set("v.errors", [{message: "Please Enter a Valid Email Address"}]);
                isValidEmail = false;
            }
        }

        // if Email Address is valid then execute code
        if(isValidEmail){
            // code write here..if Email Address is valid.
        }
    },

    productCountIncrement: function (component, event, helper) {
        component.set("v.CCProductId",event.getParam('productSfid'));
        helper.getLearningPlanAttributes(component, event, helper);

        var delayInMilliseconds = "8000"; //10 seconds
        window.setTimeout(
            $A.getCallback(function() {
        helper.checkPreq(component, event, helper);
                 }), delayInMilliseconds
        );     

    },
    
    handleUploadFinished: function (cmp, event) {
        // This will contain the List of File uploaded data and status
        var uploadedFiles = event.getParam("files");
    },
    
    showPrompt : function(component, event, helper) {
    	component.set("v.isPrompt", "true");
	},
    
    closePrompt : function(component, event, helper) {
    	component.set("v.isPrompt", "false");
	},
        
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            console.log('this is inside');
            fileName = event.getSource().get("v.files")[0]['name'];
            console.log('this is inside'+fileName);
            helper.uploadHelper(component, event);
        }
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
        if(currentSN == "Three")
        {
        	component.set("v.stepNumber", "Two");
        }
    },
    
    calculateStudentInstructorRatio : function(component,event,helper){
        console.log('Get in method');
        var CCProductId = component.get("v.CCProductId");
        var Students = component.get("v.Students");
    	var Vouchers = component.get("v.Vouchers");
         var extUser = component.get("v.isExtUser");
        var isParnter = component.get("v.isPartner");
        var Nextbutton = component.get("v.Nextbuttonbool");
        if(Students == "") {
            Students = 0;
        }
        if(Vouchers == "") {
            Vouchers = 0;
        }
         
        //
        if(typeof CCProductId !== 'undefined' && typeof Students !== 'undefined' && typeof Vouchers !== 'undefined'){
            console.log('calculating instructor Ratio');
            if(CCProductId && Students){
                var numberOfStudents = parseInt(Students);
                var numberOfVouchers = parseInt(Vouchers);
                if (numberOfStudents >= 0 && numberOfVouchers >= 0) {
                    var totalStudents = numberOfStudents + numberOfVouchers;
                    var SIRatio;
                    var action = component.get("c.getLearningPlanId");
                    action.setParams({ccProdId : CCProductId});
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            var storeResponse = response.getReturnValue();
                            if(storeResponse.LMS_Learning_Plan__c) {
                                component.set("v.courseId", storeResponse.LMS_Learning_Plan__c);
                            }

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
            else {
                var action = component.get("c.getLearningPlanId");
                action.setParams({ccProdId : CCProductId});
        	    action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var storeResponse = response.getReturnValue();
                        if(storeResponse.LMS_Learning_Plan__c) {
                            component.set("v.courseId", storeResponse.LMS_Learning_Plan__c);
                        }
                    }
                });
                $A.enqueueAction(action);
            }
        }
    
    },
        
    onclickNext : function(component,event,helper){
        var currentSN = component.get("v.stepNumber");
        if(currentSN == "One")
        {
            helper.formatTime(component,event,helper);
            var vorgId 	= component.get("v.selectedLookUpRecord1").Id;
            var orgBool	= true;
            if(vorgId === undefined){
                component.set("v.orgError", "No organization was selected. Complete this field.");
                orgBool	= false;
            }else{
                component.set("v.orgError", null);
            }
            
            var vcrsId 	= component.get("v.CCProductId");
            var crsBool	= true;
            if(vcrsId === undefined || vcrsId == ''){
                component.set("v.crsError", "No course was selected. Complete this field.");
                crsBool	= false;
            }else{
                component.set("v.crsError", null);
            }
            
            var intUsrId = component.get("v.selectedLookUpRecord4").Id;
            var usrBool	 = true;
            if(intUsrId === undefined){
                component.set("v.usrError",true);
                usrBool	= false;
            }else{
                component.set("v.usrError",false);
            }
            console.log('hello');
            var instructorHasPrerequisites = component.get('v.instructorHasPrerequisites');
            if (instructorHasPrerequisites === false && usrBool) {
                console.log('prereqError: true');
                component.set("v.prereqError", true);
            } else {
                console.log('prereqError: false');
                component.set("v.prereqError", false);
            }

            var allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);

            allValid &= instructorHasPrerequisites;

            if (allValid) {

                // Student/Voucher Count
                var numberOfStudents = component.get('v.Students');
                var numberOfVouchers = component.get('v.Vouchers');

                if (parseInt(numberOfStudents) + parseInt(numberOfVouchers) <= 0) {
                    allValid = false;

                    component.set('v.Students', '');
                    component.set('v.Vouchers', '');
                    component.find('field').forEach(function(inputCmp) {
                        inputCmp.reportValidity();
                    });

                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "mode" : "sticky",
                        "title": "Missing Students and/or Vouchers",
                        "type" : "error",
                        "message": "A blended class cannot be created for NO students and NO vouchers. Please indicate at least ONE student and/or ONE voucher."
                    });
                    toastEvent.fire();
                }
            }

            
            //check if same instrucotr is added multiple times
        	/*var primaryInstructor =  component.get("v.instructor");
            var addInstructors = component.get("v.AdditionalInstructors");
            console.log('BeforePush-->');
            console.log(component.get("v.AdditionalInstructors"));
           
            var isDuplicate = false;
            var newArray = new Array();
            for(var i=0;i<addInstructors.length;i++){
                newArray.push(addInstructors[i]);
            }
            newArray.push(primaryInstructor);
            isDuplicate = (new Set(newArray)).size !=  newArray.length ? true : false;
            
            console.log('AfterPush-->');
            console.log(component.get("v.AdditionalInstructors"));*/
            
            var extUser = component.get("v.isExtUser");
        
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
            helper.createIltLocation(component);
        }
        
        else if(currentSN == "Two")
        {
            helper.formatTime(component,event,helper);
            var allValid = true;
            if(typeof component.find('field') !== "undefined"){ 
                allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
                }, true);
            }
            
            if(allValid)
            {
                for(var i=0;i<component.get("v.AdditionalInstructors").length;i++){
                    var val = component.get("v.AdditionalInstructors")[0];
                    if(val) {
                        component.set("v.isAddInstructors",true);
                    }
                }
                component.set("v.stepNumber", "Three");
            }
        }
        
        else if(currentSN == "Three")
        {
            helper.formatTime(component,event,helper);
            component.set("v.stepNumber", "Four");
        }
    },

    handleComponentEvent: function (component, event, helper) {
        console.log("Here RBCController");
        var instanceID = event.getParam('instanceID');
        if (instanceID.includes('Instructor')) {
            var itemNumber = parseInt(instanceID.slice(10));
            var addInstr = component.get("v.AdditionalInstructors");
            if (event.getParam('isClear')) {
                //addInstr[itemNumber-1] = null;
                delete addInstr[itemNumber - 1];
                //component.set("v.AdditionalInstructors",addInstr);
                console.log('OnDelete-->');
                console.log(component.get("v.AdditionalInstructors"));
            } else {
                addInstr[itemNumber - 1] = event.getParam('SelectedValue');
                //component.set("v.AdditionalInstructors",addInstr);
                console.log('OnAdd-->');
                console.log(component.get("v.AdditionalInstructors"));
            }
        }

    },

    handleTimeZoneEvent: function (component, event, helper) {
        console.log("Here handleTimeZoneEvent");
        var instanceID = event.getParam('instanceID');
        if (instanceID.includes('Instructor')) {
            var itemNumber = parseInt(instanceID.slice(10));
            var addInstr = component.get("v.AdditionalInstructors");
            if (event.getParam('isClear')) {
                //addInstr[itemNumber-1] = null;
                delete addInstr[itemNumber - 1];
                //component.set("v.AdditionalInstructors",addInstr);
                console.log('OnDelete-->');
                console.log(component.get("v.AdditionalInstructors"));
            } else {
                addInstr[itemNumber - 1] = event.getParam('SelectedValue');
                //component.set("v.AdditionalInstructors",addInstr);
                console.log('OnAdd-->');
                console.log(component.get("v.AdditionalInstructors"));
            }
        }

    },

    classSelected : function (component,event) {
        var classId = component.get("v.selectedLookUpRecord5").Id;
        var selectedClass = component.get("v.selectedLookUpRecord5");
        console.log(JSON.stringify(selectedClass));
        component.set("v.SiteName", selectedClass["Site_Name__c"]);
        component.set("v.Address1", selectedClass["Site_Address_1__c"]);
        component.set("v.Address2", selectedClass["Site_Address_2__c"]);
        component.set("v.City", selectedClass["Site_City__c"]);
        component.set("v.State", selectedClass["State__c"]);
        component.set("v.Zip", selectedClass["Site_Postal_Code__c"]);
    },

    siteSelected : function (component, event) {
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

    accountSelected : function (component,event,helper){
        var orgId 	= component.get("v.selectedLookUpRecord1").Id;
        console.log(orgId);
        if(orgId != null || orgId != undefined){
            
        
        component.set("v.accId",orgId);
        console.log(orgId + 'This is the org id');  
            console.log(component.get("v.oppIdParent")+'This is the oppty');
            var opptyId = component.get("v.oppIdParent");
        var action = component.get("c.createOppForCCUpdate");
        action.setParams({
            AccountId: orgId,
            storeFront: 'CRE',
            opptyId : opptyId 
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
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
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            
        });
        $A.enqueueAction(action);
        }
    },
    
    processRBC : function(cmp, evt, hlpr)
    {    	
        var obj = new Object();
        var extUser = cmp.get("v.isExtUser");
        var isParnter = cmp.get("v.isPartner");
        var user1;
        if(extUser === true && isParnter === false){
            user1 = cmp.get("v.instructor.Id");
            }
        else{
            user1 = cmp.get("v.userId1");
        }
        
         // Supplement Info
            
            var Suppinfo = cmp.get("v.SupplementInfo");
            console.log("Supp Info" +Suppinfo);
        
        obj.Account		  =	cmp.get("v.accId");
        obj.Course		  =	cmp.get("v.courseId");
        obj.StartDate	  =	cmp.get("v.StartDateFmt");
        obj.EndDate		  =	cmp.get("v.EndDateFmt");
        obj.Students	  =	cmp.get("v.Students");
        obj.SupplementInfo  =   Suppinfo;
        obj.Voucher		  =	cmp.get("v.Vouchers");
        obj.Instructor1   =	user1;						//cmp.get("v.instructor").Id;
        obj.Instructor2   =	cmp.get("v.userId2");
        
        
        
        var addInstr = '';
        if(typeof cmp.get("v.AdditionalInstructors") !== 'undefined' && cmp.get("v.AdditionalInstructors") != null)
        for(var i=0;i<cmp.get("v.AdditionalInstructors").length;i++){
            if(cmp.get("v.AdditionalInstructors")[i] != null)
            	addInstr = addInstr + cmp.get("v.AdditionalInstructors")[i].Id + ';';
        }
        obj.AdditionalInstructors = addInstr;
        
        
		//Training Site
		var siteName = cmp.get("v.SiteName");
        var add1  = cmp.get("v.Address1");
        var add2  = cmp.get("v.Address2");
        var city  = cmp.get("v.City");
        var state = cmp.get("v.State");
        var zip   = cmp.get("v.Zip");
        var location = cmp.get("v.locationId");
        
        obj.SiteName    =   siteName; 
        obj.Address1 	= 	add1;
        obj.Address2 	= 	add2;
        obj.City 		= 	city;
        obj.State 		= 	state;
        obj.Zip 		= 	zip;
        obj.Location    =   location;
        
        obj.OpportunityId = cmp.get("v.oppIdParent");
        obj.CloudCrazeProdId = cmp.get("v.CCProductId");
        
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
        if(jsonStr!='')
        	jsonStr = '{'+'\"Students\": ['+jsonStr+'] } ';
        
        var action = cmp.get("c.invokeMethodswithboolean");
        console.log("cpsWrap: " + JSON.stringify(cmp.get("v.cpsWrap")));
        action.setParams({ JSON : classDetailJSON, JSON1 : jsonStr, blend1 : true , wrapper: cmp.get("v.cpsWrap")});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.messageType", 'success' );
                cmp.set("v.message", 'Submitted Successfully!' );
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        cmp.set("v.messageType", 'error');
                        cmp.set("v.message", errors[0].message );
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            // Show Submission screen on submission            
            cmp.set("v.stepNumber", "Four");
        });
        $A.enqueueAction(action);
    },
    
    cancel : function(component, event, helper){
        $A.get("e.force:refreshView").fire();
        component.set("v.stepNumber", "Zero");
    },

    addSession : function(component, event, helper) {
        var tempList = component.get("v.cpsWrap.sessionList");
        console.log("tempList");
        console.log(tempList);
        console.log(tempList[0].timeZone);
        console.log(tempList[0].timeZoneName);

        //console.log(tempList.timeZoneName[0]);
        tempList.push({'classDate':'',
            'startTime':'',
            'endTime':'',
            'timeZone':tempList[0].timeZone,
            'timeZoneName':tempList[0].timeZoneName
            });
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

    onZoneChange : function(component, event, helper) {
        helper.requiredSchedule(component,event,helper);

        var target = event.target;
        var value = target.value;
        var sessionIndex = target.getAttribute('data-row-index');

        var cpsWrap = component.get("v.cpsWrap");
        if (cpsWrap != null) {
            cpsWrap.sessionList[sessionIndex].timeZone = value;
            cpsWrap.sessionList[sessionIndex].timeZoneName = (value == '' ? '' : cpsWrap.timeZoneList[value]);

            var errorDivs = component.find('zoneError');
            if (cpsWrap.sessionList.length == 1) {
                errorDivs = [errorDivs];        // convert the single div into an array
            }

            if (cpsWrap.sessionList[sessionIndex].timeZone == '') {
                $A.util.removeClass(errorDivs[sessionIndex], 'hide');
            } else {
                $A.util.addClass(errorDivs[sessionIndex], 'hide');
            }
        }
    },

    zoneUpdate : function(component, event, helper) {
        console.log('zoneUpdate method');

    }
})