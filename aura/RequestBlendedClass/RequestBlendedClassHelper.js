({
    uploadHelper: function(component, event) {
        component.set("v.showLoadingSpinner", true);
        
        var fileInput = component.find("fileId").get("v.files");
        console.log(fileInput + 'This is File input');
        var file = fileInput[0];
        var self = this;
        var objFileReader = new FileReader();
        
        objFileReader.onload = $A.getCallback(function() {
            console.log(fileInput + 'This is File input onload');
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;    
            fileContents = fileContents.substring(dataStart);
            self.uploadInChunk(component, file, fileContents);
        });
        objFileReader.readAsDataURL(file);
    },
    //
    checkPreq : function(component, event, helper) {
          console.log('Get in method');
        var CCProductId = component.get("v.CCProductId");
         var extUser = component.get("v.isExtUser");
        var isParnter = component.get("v.isPartner");
        var Nextbutton = component.get("v.Nextbuttonbool");
          // Prereq check
         if(typeof CCProductId !== 'undefined' && extUser===true && isParnter===false)
         //if(typeof CCProductId !== 'undefined')
         {
          console.log('Get in new');
          var action1 = component.get("c.checkPrereq");
          action1.setParams({ccProdId : CCProductId});
		  action1.setCallback(this, function(response) {
            var state = response.getState();
              
            if (state === "SUCCESS") {
                 var storeResponse = response.getReturnValue();
			//component.set("v.calciinstructor",true);
                 if(storeResponse==true) {
                     component.set("v.Nextbuttonbool",true);
                 }
                else
                {
                     component.set("v.Nextbuttonbool",false);

                     console.log("Error message: Instructor does not meet the prereq");
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "mode": "pester",
                                    "duration":" 10000",
                                    "title": "Invalid Instructor",
                                    "type" : "error",
                                    "message": "You are not a Certified Instructor"
                                });
                                toastEvent.fire();
                }
            }
                });
        $A.enqueueAction(action1);
         }
    },
    uploadInChunk: function(component, file, fileContents, startPosition, endPosition, attachId) {
        var action = component.get("c.saveChunk");
        action.setParams({
            base64Data: encodeURIComponent(fileContents),
            contentType: file.type,
            isCRE: false
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
    
    stepOne : function(component,event){
        console.log('This is my log');
        //alert('Count-->'+component.get("v.Students"));
        var action = component.get("c.initializeStudents");
        action.setParams({Count : component.get("v.Students")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();   
                component.set("v.numberOfStudentsList", storeResponse);
                //alert('v.numberOfStudentsList--->'+storeResponse);
            }
        });
        $A.enqueueAction(action);
        
        var startDate 	= component.get("v.StartDate");
        var splitStartDate = startDate.split('-');        
        var year1 	= splitStartDate[0];
        var month1 	= splitStartDate[1];
        var day1	= splitStartDate[2]; 
        var startDateFrmtd = month1 + '/' + day1 + '/' + year1;
        component.set("v.StartDateFmt",startDateFrmtd);
        
        var endDate 	= component.get("v.EndDate");
        var splitEndDate = endDate.split('-');
        var year 	= splitEndDate[0];
        var month 	= splitEndDate[1];
        var day 	= splitEndDate[2]; 
        var endDateFrmtd = month + '/' + day + '/' + year;
        component.set("v.EndDateFmt",endDateFrmtd);
        
        var extUser = component.get("v.isExtUser");
        var isParnter = component.get("v.isPartner")
        if(extUser === true && isParnter===false)
        {
            var instructor 	= component.get("v.Instructor1"); // Is this needed??
        } else {
            var instructor1Id = component.get("v.selectedLookUpRecord4").Id;
            component.set("v.userId1",instructor1Id);
            var instructor1Name = component.get("v.selectedLookUpRecord4").Name;
            component.set("v.userName1",instructor1Name);
        }
        
        var vouchers 	= component.get("v.Vouchers");
        var accountId = component.get("v.accId");
        
        component.set("v.accName",component.get("v.selectedLookUpRecord1").Name);
        
        var action = component.get("c.getLearningPlanId");
        action.setParams({ccProdId : component.get("v.CCProductId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();   
                console.log('sucesss1..'+storeResponse.LMS_Learning_Plan__c);
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
        
        component.set("v.userId2",component.get("v.selectedLookUpRecord3").Id);
        component.set("v.userName2",component.get("v.selectedLookUpRecord3").Name);
        //Training Site
        var siteName = component.get("v.SiteName");
        var add1 = component.get("v.Address1");
        var add2 = component.get("v.Address2");
        var city = component.get("v.City");
        var state = component.get("v.State");
        var zip = component.get("v.Zip");
        
        }
})