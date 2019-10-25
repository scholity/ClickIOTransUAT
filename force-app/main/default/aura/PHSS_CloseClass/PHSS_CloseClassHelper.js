({
    isCommunityCls : function(component) {
    	var action = component.get('c.isCommunityClass');
		
        action.setParams({
            classId  : component.get("v.recordId")
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();
                if (returnValue != null && returnValue.Error == null) {
                    component.set('v.isSkeduloCourse',returnValue);
                    console.log('isCOmmunity..'+component.get("v.isSkeduloCourse"));

                    // NEXT: Check if class is LTS
                    this.checkIsLearnToSwimClass(component);
                } else if (returnValue != null && returnValue.Error != null) {
                    component.set("v.errorMessage",'Error initializing case form');
                    component.set("v.showError",true);
                }
            } else {
                component.set("v.errorMessage",'Unable to contact server.');
                component.set("v.showError",true);
            }
        });
        $A.enqueueAction(action);	    
    },

    checkIsLearnToSwimClass : function(component) {
        var classId = component.get('v.recordId');
        var action = component.get('c.isLTSClass');
        action.setParams({
            classId: classId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();
                if (returnValue[classId] == true) {
                    component.set('v.isLearnToSwimClass', true);
                    console.log('This IS a Learn-to-Swim class');
                } else {
                    component.set('v.isLearnToSwimClass', false);
                    console.log('This IS NOT a Learn-to-Swim class');
                }
            } else {
                component.set('v.errorMessage', 'Unable to contact server.');
                component.set('v.showError', true);
            }
        });
        $A.enqueueAction(action);
    },

    validateCart : function (component,event,helper) {
        var action = component.get('c.IsCartActive');
		action.setParams({
            opptyId  : component.get("v.opportunityId")
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();
                if(returnValue.cartStatus){
                    component.set("v.IsCarActive",true);
                } else{
                    component.set("v.IsCarActive",false);
                    if(returnValue.cartid!=''){
                        
                        var errstring = 'Oppty '+component.get("v.opportunityId")+' - Cart '+ returnValue.cartid;
                    	component.set("v.cartErrorMessage",errstring);    
                    } else{
                        var errstring = 'Oppty '+component.get("v.opportunityId")+' - No Active Cart';
                       component.set("v.cartErrorMessage",errstring); 
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    
	fetchClassDetails : function (component,event,helper) {
    	// using class id, get the number of students and students list
        var action = component.get("c.courseInfo");
        
          
        console.log('recordId..'+component.get("v.recordId"));
        action.setParams({ ClassId : component.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                var storeResponse = response.getReturnValue();
                
                console.log('response..'+JSON.stringify(storeResponse));
                //console.log('response supinfo..'+JSON.stringify(storeResponse.SuppInfo));
                // Set course details
                component.set("v.courseName",storeResponse.CourseName);
                component.set("v.EndDate",storeResponse.EndDate);
                component.set("v.accName",storeResponse.Account);
                component.set("v.Location",storeResponse.Location);
                component.set("v.Instructor1",storeResponse.Instructor1);
                component.set("v.Instructor2",storeResponse.Instructor2);
                component.set("v.sessionId",storeResponse.SessionId);
                component.set("v.numberOfStudentsList", storeResponse.lstStudents);
                component.set("v.studList", storeResponse.lstStudents);
                var studentsList = storeResponse.lstStudents;
                if(storeResponse.lstStudents.length==0){
                    component.set("v.Emptystudentlist",true);
                }
                else
                { 
                    component.set("v.Emptystudentlist",false);
                }
                component.set("v.Students",studentsList.length);
                component.set("v.SupplementInfo",storeResponse.SuppInfo);
                component.set("v.classclosed",storeResponse.classclosed);
                component.set("v.Futuredates",storeResponse.futureDate);
                component.set("v.classclosedDate",storeResponse.closedDate);
                /*if(storeResponse.lstStudents[0].Grade != ''){ 
                	component.set("v.initialLoad","false");
                }*/
                
                // Populate Grade and Failed/Not Evaluated Reason picklist fields
                component.set("v.gradeList",storeResponse.lsgralist);
                component.set("v.reasonList",storeResponse.lsrealist);
                
                component.set("v.opportunityId",storeResponse.oppId);
                component.set("v.cloudCrazeProdId",storeResponse.ccProdId);
                console.log('close clas value..'+component.get("v.Emptystudentlist"));

                component.set("v.requestType", storeResponse.RequestType);
                component.set("v.trainingEventId", storeResponse.TrainingEventId);

                var isCartActive = component.get("v.isCarActive");
                if (storeResponse.RequestType.indexOf("Full Service") >= 0 || isCartActive) {
                    component.set("v.eligibleForClose", "true");
                }
            }
            else if (state === "ERROR") {
                // Process error returned by server
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.errorMessage",errors[0].message);
                        component.set("v.showError",true);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
   
    validateInput : function(component, event, helper) 
    {
        component.set("v.allValid",true);
        var tempList = component.get("v.numberOfStudentsList");
        for (var i = 0; i < tempList.length; i++)
        {
            if(tempList[i].Grade == "") {
                document.getElementById('gradeErr-'+(i+1)).classList.add('errMsg');
                component.set("v.allValid",false);
            }
            else if(document.getElementById('gradeErr-'+(i+1)) != null){
                document.getElementById('gradeErr-'+(i+1)).classList.remove('errMsg');
            }
            
            if((tempList[i].Grade == "Unsuccessful" || tempList[i].Grade == "Not Evaluated") && 
              	tempList[i].Fail_Reason == "") {
                document.getElementById('reasonErr-'+(i+1)).classList.add('errMsg');
                component.set("v.allValid",false);
            }
            else if(document.getElementById('reasonErr-'+(i+1)) != null) {
                document.getElementById('reasonErr-'+(i+1)).classList.remove('errMsg');
            }

            var phone = tempList[i].Phone;
            if (phone) {
                if (! phone.match(/^(\d{10})$/)) {
                    component.set('v.allValid', false);
                }
            }
        }
    },
    
    mandateInput : function(component, event, helper) 
    {
        var tempList = component.get("v.numberOfStudentsList");
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
    
    closingClass : function(cmp, event, helper){
        
        cmp.set("v.errorMessage","");
       
        cmp.set("v.showError",false);
        
        if(cmp.get("v.allValid")){
            
            // Legal checkbox validation
        	//var isLegalChecked = cmp.find("legalCheck").get("v.checked"); 
       		var isLegalChecked = cmp.get("v.isLegalChecked");
            
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
                         //cmp.set("v.stepNumber", "Zero");
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

    updateOrder : function(cmp, event) {

         var studentCount = cmp.get("v.numberOfStudentsList").length;
         console.log('studentCount '+studentCount);

         var classId = cmp.get("v.recordId");
         console.log('classId '+classId);

         var trainingEventId = cmp.get("v.trainingEventId");
         console.log('trainingEventId '+trainingEventId);

         var action = cmp.get("c.handleFullServiceClass");
      
         action.setParams({
             classId : classId, studentCount : studentCount, trainingEventId : trainingEventId
         });

         action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("Response message from handle order: "+response.getReturnValue());
            }
         });
         $A.enqueueAction(action);
    }
})