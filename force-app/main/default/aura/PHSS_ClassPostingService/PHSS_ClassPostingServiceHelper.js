({
	initializeWrapper : function(component, event, helper) {
		var action = component.get("c.initWrapper");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                var resp = response.getReturnValue();    
                component.set("v.cpsWrap",resp);
                component.set("v.initialWrap",resp);
                console.log('response..'+JSON.stringify(resp));
                
                var zones = [];
                var zoneResp = resp.timeZoneList;
                for(var key in zoneResp){
                    zones.push({value:zoneResp[key], key:key}); 
                }
                component.set("v.zoneList",zones); 
      
                console.log('map..'+component.get("v.zoneList"));
                
                console.log("accId***"+resp.accId);
            }
            else if (state === "ERROR") {
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
    
    validateFields : function(component, event, helper) {
        component.set("v.allValid",true);
        component.set("v.isUrlValid",true);
        component.set("v.courseError",false);
        component.set("v.formatError",false);
        component.set("v.zoneError",false);
        component.set("v.showError",false);
        component.set("v.errorMessage","");
        
        // Course validation
        /*var courseId 	= component.get("v.selectedCourse").Id;
        component.set("v.cpsWrap.courseId",courseId);
        component.set("v.cpsWrap.courseName",component.get("v.selectedCourse").Name);*/
        
        if(!component.get("v.CCProductId")) {
        	component.set("v.courseError",true);
        	component.set("v.allValid",false);    
        }
        
        var action = component.get("c.getLearningPlanId");
        console.log("CCProductId***"+component.get("v.CCProductId"));
        action.setParams({ccProdId : component.get("v.CCProductId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var storeResponse = response.getReturnValue();
                var courseId 	= storeResponse.LMS_Learning_Plan__c;
                console.log("storeResponse***>>>"+storeResponse.LMS_Learning_Plan__r.Name);
                component.set("v.cpsWrap.courseId", courseId);
                component.set("v.cpsWrap.courseName",storeResponse.LMS_Learning_Plan__r.Name);
                
                var courseId 	= component.get("v.cpsWrap.courseId");
        		if(courseId == undefined){
                    component.set("v.courseError",true);
                    component.set("v.allValid",false); 
                }
            }
        });
        $A.enqueueAction(action);
        
        // Class format validation
        component.set("v.cpsWrap.classFormat",document.getElementById('formatSelect').value);
        
        if(component.get("v.cpsWrap.classFormat")) {
            document.getElementById('formatSelect').classList.remove('requiredSelect');    
        }
        else {
            component.set("v.formatError",true);
        	component.set("v.allValid",false);
            document.getElementById('formatSelect').classList.add('requiredSelect');
        }
        
        // Time Zone validation
        var tempList = component.get("v.cpsWrap.sessionList");
        tempList[0].timeZone = document.getElementById('zoneSelect').value;
        component.set("v.cpsWrap.sessionList",tempList);
        
        if(component.get("v.cpsWrap.sessionList")[0].timeZone) {
            document.getElementById('zoneSelect').classList.remove('requiredSelect');    
        }
        else {
            component.set("v.zoneError",true);
        	component.set("v.allValid",false);
            document.getElementById('zoneSelect').classList.add('requiredSelect');
            console.log('classes..'+document.getElementById('zoneSelect').classList);
        }
        
        // Other fields validation
        var allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        
        if(!allValid) {
        	component.set("v.allValid",allValid);    
        }
        
        if(!component.get("v.allValid")) {
            component.set("v.showError","true");
            component.set("v.errorMessage","Please fill all the mandatory details");
        }
        
        // Registration - URL or Phone validation
        if(component.get("v.allValid") && !component.get("v.cpsWrap").regUrl  && !component.get("v.cpsWrap").regPhone) {
            component.set("v.showError","true");
            var errMsg = "Either \'URL for registration\' or \'Phone for registration\' fields must be filled.";
            component.set("v.errorMessage",errMsg);
            component.set("v.isUrlValid",false);
        } 
        
    },
    
    formatTime : function(component, event, helper) {
    	// Format Start Time and End Time
        var startTime = component.get("v.cpsWrap.sessionList")[0].startTime;
        var startTimeHrs = startTime.substring(0,2);
        var startTimeAmOrPm;
        console.log('startTimeHrs..'+startTimeHrs);
        console.log('con..'+(startTimeHrs == '00'));
        console.log('parsed..'+parseInt(startTimeHrs));
        
        if(startTimeHrs == '12') {
            startTimeAmOrPm = 'PM';
        }
        else if(startTimeHrs == '00') {
            startTimeHrs = '12';
            startTimeAmOrPm = 'AM';
        }
        else if(parseInt(startTimeHrs) > 12 && parseInt(startTimeHrs) < 24) {
    		startTimeHrs = parseInt(startTimeHrs) - 12; 
            startTimeAmOrPm = 'PM';
        }
        else {
        	startTimeAmOrPm = 'AM';
        }
        startTime = startTimeHrs + ':' + startTime.substring(3,5) + ' ' + startTimeAmOrPm;
        console.log('startTime..'+startTime);  
        component.set("v.formattedStartTime",startTime);
        
        var endTime = component.get("v.cpsWrap.sessionList")[0].endTime;
        var endTimeHrs = endTime.substring(0,2);
        var endTimeAmOrPm;
        console.log('endTimeHrs..'+endTimeHrs);
        console.log('con..'+(endTimeHrs == '00'));
        console.log('parsed..'+parseInt(endTimeHrs));
        
        if(endTimeHrs == '12') {
            endTimeAmOrPm = 'PM';
        }
        else if(endTimeHrs == '00') {
            endTimeHrs = '12';
            endTimeAmOrPm = 'AM';
        }
        else if(parseInt(endTimeHrs) > 12 && parseInt(endTimeHrs) < 24) {
    		endTimeHrs = parseInt(endTimeHrs) - 12; 
            endTimeAmOrPm = 'PM';
        }
        else {
        	endTimeAmOrPm = 'AM';
        }
        endTime = endTimeHrs + ':' + endTime.substring(3,5) + ' ' + endTimeAmOrPm;
        console.log('endTime..'+endTime); 
        component.set("v.formattedEndTime",endTime);
    },
    
    createClass : function(component, event, helper) {
        console.log('wrap..'+JSON.stringify(component.get("v.cpsWrap")));
        
        var action = component.get("c.postClass");
        action.setParams({ jsonStr : JSON.stringify(component.get("v.cpsWrap")) });
        
        action.setCallback(this, function(response) {
            var resp = response.getReturnValue();
            console.log('response..'+resp);
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('success');
                alert('Class posted successfully!!!');
                component.set("v.stepNumber", "Zero");
                this.initializeWrapper(component, event, helper);
				component.set("v.selectedCourse",null);
            } 
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        component.set("v.showError","true");
            			component.set("v.errorMessage",errors[0].message);	
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }
})