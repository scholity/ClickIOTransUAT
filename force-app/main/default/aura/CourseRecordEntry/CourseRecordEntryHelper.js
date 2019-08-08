({
    validateInput : function(component, event, helper) 
    {
        component.set("v.allValid",true);
        
        var tempList = component.get("v.numberOfStudentsList");
        
        console.log("***tempList***"+tempList);
        
        for (var i = 0; i < tempList.length; i++)
        {
            if(tempList[i].Grade !== "Successful" && tempList[i].Grade !== "Unsuccessful" && tempList[i].Grade !== "Not Evaluated") {
                console.log("***tempList[i].Grade***"+tempList[i].Grade);
                document.getElementById('gradeErr-'+(i+1)).classList.add('errMsg');
                component.set("v.allValid",false);
            }
            else if(document.getElementById('gradeErr-'+(i+1)) != null){
                document.getElementById('gradeErr-'+(i+1)).classList.remove('errMsg');
            }
            
            if((tempList[i].Grade == "Unsuccessful" || tempList[i].Grade == "Not Evaluated") && 
               tempList[i].Fail_Reason !== "Did not successfully complete course all objectives" &&
               tempList[i].Fail_Reason !== "Failed written exam" &&
               tempList[i].Fail_Reason !== "Unable to perform one or more skills" &&
               tempList[i].Fail_Reason !== "Did not attend all course sessions" &&
               tempList[i].Fail_Reason !== "Did not desire grade/certificate" &&
               tempList[i].Fail_Reason !== "Arrangements to complete course objectives")
            {
                document.getElementById('reasonErr-'+(i+1)).classList.add('errMsg');
                  component.set("v.allValid",false);
            }
            else if(document.getElementById('reasonErr-'+(i+1)) != null) {
                document.getElementById('reasonErr-'+(i+1)).classList.remove('errMsg');
            }
        }   
    },


    checkPreq: function (component, event, helper) {

        var CCProductId = component.get("v.CCProductId");
        var extUser = component.get("v.isExtUser");
        var isPartner = component.get("v.isPartner");
        // Prereq check
        if (typeof CCProductId !== 'undefined' && extUser === true && isPartner === false) {
        //if(typeof CCProductId !== 'undefined') { //for testing
            var action1 = component.get("c.checkPrereq");
            action1.setParams({ccProdId: CCProductId});
            action1.setCallback(this, function (response) {
                var state = response.getState();

                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    component.set("v.calciinstructor", true);
                    if (storeResponse == true) {
                        component.set("v.instructorHasPrerequisites", true);
                        console.log("Instructor has met the prereq");
                    } else {
                        component.set("v.instructorHasPrerequisites", false);

                        console.log("Error message: Instructor does not meet the prereq");
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "mode": "pester",
                            "duration": " 10000",
                            "title": "Invalid Instructor",
                            "type": "error",
                            "message": "You are not a Certified Instructor"
                        });
                        toastEvent.fire();
                    }
                }
            });
            $A.enqueueAction(action1);
        }
    },
    mandateInput : function(component, event, helper) 
    {
        var tempList = component.get("v.numberOfStudentsList");
        //var studentCount = component.get("v.Students");
        
        for (var i = 0; i < tempList.length; i++)
        {
            if(tempList[i].Grade == "Successful" || tempList[i].Grade == "") {
                tempList[i].Fail_Reason = "";
                document.getElementById('reasonErr-'+(i+1)).classList.remove('errMsg');
            }
            if(tempList[i].Grade != "") {
                document.getElementById('gradeErr-'+(i+1)).classList.remove('errMsg');
            }
            if(tempList[i].Fail_Reason != "") {
                document.getElementById('reasonErr-'+(i+1)).classList.remove('errMsg');
            }
        }   
        component.set("v.numberOfStudentsList",tempList);
    },
    
    
    uploadHelper: function(component, event) {
        
        component.set("v.showLoadingSpinner", true);
        
        var fileInput = component.find("fileId").get("v.files");
        
        var file = fileInput[0];
        var self = this;
        
        var objFileReader = new FileReader();
        
        objFileReader.onload = $A.getCallback(function() {
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
            
            fileContents = fileContents.substring(dataStart);
            
            self.uploadInChunk(component, file, fileContents);
        });
        
        objFileReader.readAsDataURL(file);
    },
    
    uploadInChunk: function(component, file, fileContents, startPosition, endPosition, attachId) {
        
        var action = component.get("c.saveChunk");
        action.setParams({
            base64Data: encodeURIComponent(fileContents),
            contentType: file.type,
            isCRE : true
        });
        
        action.setCallback(this, function(response) {
            
            attachId = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var storecsvdata = response.getReturnValue();
                
                component.set("v.numberOfStudentsList", storecsvdata);
                component.set("v.showLoadingSpinner", false);
                component.set("v.isPrompt", "false");
                component.set("v.isUploaded", "true");
                
                var studentListLength = component.get("v.numberOfStudentsList").length;
                
                component.set("v.Students",studentListLength);
                
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
//            var tSite = cmp.get("v.Location"); // TODO: Remove this
            
            var siteName  = cmp.get("v.SiteName");
            var add1  = cmp.get("v.Address1");
            var add2  = cmp.get("v.Address2");
            var city  = cmp.get("v.City");
            var state = cmp.get("v.State");
            var zip   = cmp.get("v.Zip");
            var location = cmp.get("v.locationId");

            
            var obj = new Object();
            
            obj.Account		=	accID;
            obj.Course		=	course;
            obj.EndDate		=	endDateFrmtd;
            obj.Students	=	numOfStudents;
            obj.SupplementInfo  =   Suppinfo;
            obj.Instructor1 =	user1;
            obj.Instructor2 =	user2;
//            obj.Location	=	tSite;
            obj.Location    =   location;

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

            // Learn to Swim
            var isLearnToSwimProduct = cmp.get('v.isLearnToSwimProduct');
            if (isLearnToSwimProduct) {
                obj.IsLearnToSwimProduct = true;
                obj.SuccessfulEvals = cmp.get('v.numberOfSuccessfulEvaluations');
                obj.UnsuccessfulEvals = cmp.get('v.numberOfUnsuccessfulEvaluations');
                obj.NonEvals = cmp.get('v.numberOfNonEvaluations');
            }


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
            action.setParams({ JSON : classDetailJSON, JSON1 : jsonStr });
            action.setCallback(this, function(response) {

                var state = response.getState();

                cmp.set("v.isSubmitted", 'true');

                console.log(state);
                if (state === "SUCCESS") {

                     cmp.set("v.isSuccess", 'true');

                    cmp.set("v.messageType", 'success' );
                    cmp.set("v.message", 'Completed Successfully!' );

                    /*var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Record Saved Successfully.",
                        "type":"success"
                    });
                    toastEvent.fire();*/
                    //$A.get("e.force:refreshView").fire();
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
                
                cmp.set("v.isSubmitted", 'false');
                cmp.set("v.showLoadingSpinner", false);
            });

            $A.enqueueAction(action);
        }
    },
    stepOne : function(component,event){
        
        //if(allValid && crsBool) {
        //Number of Students
        var numOfStudents = component.get("v.Students");
        var action = component.get("c.initializeStudents");
        action.setParams({Count : component.get("v.Students")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();   
                component.set("v.numberOfStudentsList", storeResponse);
            }
        });
        $A.enqueueAction(action);
        
        //Organization
        /*var accountId = component.get("v.selectedLookUpRecord1").Id;
        component.set("v.accId",accountId);
        
                var accId = component.get("v.selectedValue");
                console.log("accId"+accId);
                */
        var accountId = component.get("v.accId");
        
        var accountName = component.get("v.selectedLookUpRecord1").Name;
        component.set("v.accName",accountName);
        
        //Course
        //var crsId =  component.get("v.selectedLookUpRecord2").Id;
        //component.set("v.courseId",crsId);
        
        /*Get Learing Plan from CC Product*/
        
        
        var action = component.get("c.getLearningPlanId");
        console.log("CCProductId***"+component.get("v.CCProductId"));
        action.setParams({ccProdId : component.get("v.CCProductId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var storeResponse = response.getReturnValue();
                //console.log("storeResponse>>>"+storeResponse.LMS_Learning_Plan__r.Name);
                if(storeResponse.LMS_Learning_Plan__c) {
                component.set("v.courseId", storeResponse.LMS_Learning_Plan__c);
                component.set("v.courseName",storeResponse.LMS_Learning_Plan__r.Name);
                
                 // Check if the learning plan has learning plan section items
                var action1 = component.get("c.isValidCourse");

                    action1.setParams({learningPlanId : component.get("v.courseId")});
                    action1.setCallback(this, function(response) {
                        var state = response.getState();

                        if (state === "SUCCESS") {
                            var storeResponse = response.getReturnValue(); 
                            if(storeResponse) {
                            	//Navigate to Step 2
        						component.set("v.stepNumber", "Two");    
                            }
                            else {

                                console.log("Error message: Selected course does not have a Learning Plan Section Item");
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "title": "Invalid Course",
                                    "type" : "error",
                                    "message": "Selected course does not have a valid Learning object with ILT Event record"
                                });
                                toastEvent.fire();
                            }
            }
        });
        $A.enqueueAction(action1);
                }
                else {
                	console.log("Error message: Selected course does not have a Learning Plan");
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Invalid Course",
                        "type" : "error",
                        "message": "Selected course is not a valid course"
                    });
                    toastEvent.fire();    
                }
            }
            console.log('not success');
        });
        $A.enqueueAction(action);
        
        
        /*
        var crsName =  component.get("v.selectedLookUpRecord2").Name;
        component.set("v.courseName",crsName);*/
        
        //Course Ending Date            
        var endDate = component.get("v.EndDate");
        
        console.log("endDate***"+endDate);
        
        var extUser = component.get("v.isExtUser");
        var isParnter = component.get("v.isPartner")
         if(extUser === true && isParnter===false)
        {
            var instructor1 = component.get("v.Instructor1");
        } else {    
            var instructor1Id = component.get("v.selectedLookUpRecord4").Id;
            component.set("v.userId1",instructor1Id);
            
            var instructor1Name = component.get("v.selectedLookUpRecord4").Name;
            component.set("v.userName1",instructor1Name);
            
            console.log("***Internal***" +instructor1Name);
        }
        
        // User 2            
        var instructor2Id = component.get("v.selectedLookUpRecord3").Id;
        component.set("v.userId2",instructor2Id);
        
        var instructor2Name = component.get("v.selectedLookUpRecord3").Name;
        component.set("v.userName2",instructor2Name);
        
        //Training Site
        var tSite = component.get("v.Location");
        
        var siteName = component.get("v.SiteName");
        var add1 = component.get("v.Address1");
        var add2 = component.get("v.Address2");
        var city = component.get("v.City");
        var state = component.get("v.State");
        var zip = component.get("v.Zip");
        
        //Navigate to Step 2
      //  component.set("v.stepNumber", "Two");
    },

    checkLTSProductSpec : function(component, productId) {
        console.log('checking for Learn to Swim product spec on: ' + productId);
        component.set('v.isLearnToSwimProduct', false);
        var action = component.get('c.isLTSProduct');
        action.setParams({productId: productId});
        action.setCallback(this, function(response) {
            console.log('checkLTSProductSpec callback');
            if (response.getState() === 'SUCCESS') {
                var returnValue = response.getReturnValue();
                if (returnValue[productId] == true) {
                    component.set('v.isLearnToSwimProduct', true);
                    console.log('Product [id=' + productId + '] is LTS');
                } else {
                    component.set('v.isLearnToSwimProduct', false);
                    console.log('Product [id=' + productId + '] is NOT LTS');
                    console.log(returnValue);
                }
            } else {
                console.log('Failed to identify whether the selected product is LTS.');
            }
        });
        $A.enqueueAction(action);
    },

    createIltLocation : function(component) {

        var accountId = component.get('v.accId');
        var siteName = component.get('v.SiteName');
        var address1 = component.get('v.Address1');
        var zip = component.get('v.Zip');
        var state = component.get('v.State');
        var city = component.get('v.City');

        if (accountId && siteName && address1 && zip && state && city) {
            // call apex method with the respective parameters
            var action = component.get('c.createIltLocation');
            action.setParams({
                accountId: accountId,
                name: siteName,
                address1: address1,
                address2: component.get('v.Address2'),
                postcode: zip,
                state: state,
                city: city
            });

            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    var storeResponse = response.getReturnValue();
                    console.log('response from createIltLocation: '+ storeResponse);
                    component.set('v.locationId', storeResponse);
                }
            });
            $A.enqueueAction(action);
        }
    }

})