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

    requiredSchedule : function(component,event,helper){

        // Required Time Counter decrement value
        var required_time = component.get('v.LPDuration');
        component.set("v.ScheduledTime",0);
        component.get("v.cpsWrap.sessionList").forEach(function(session) {
            if(session.classDate && session.startTime && session.endTime){
                var diff = Math.abs(new Date(session.classDate + " " + session.startTime) - new Date(session.classDate + " " + session.endTime));
                var minutes = Math.floor(diff/60000);
                // console.log("Minutes: " + minutes);
                var hours = Math.floor(minutes / 60);
                // console.log("Hours: " + hours);
                var timeScheduled = (component.get('v.ScheduledTime') +  hours);
                if(timeScheduled >= required_time){
                    component.set("v.scheduleError",false);
                } else {
                    component.set("v.scheduleError",true);
                }

                component.set("v.ScheduledTime",timeScheduled);
            }

        });
    },

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

                //console.log("accId***"+resp.accId);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error: " + errors[0].message);
                        // component.set("v.errorMessage",errors[0].message);
                        // component.set("v.showError",true);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    getLearningPlanAttributes : function(component, event, helper) {
        var action = component.get("c.getLearningPlanAttributes");
        action.setParams({ccProdId : component.get("v.CCProductId")});

        action.setCallback(this, function(response) {
            //var state = response.getState();
            //if (state === "SUCCESS") {

            var getResponse = response.getReturnValue();

            var learningPlan = getResponse.LMS_Learning_Plan__c;

            if (learningPlan != undefined) {
                var courseName = getResponse.LMS_Learning_Plan__r.Name;
                var courseFormat = getResponse.LMS_Learning_Plan__r.Classroom_Setting__c;
                var courseDuration = getResponse.LMS_Learning_Plan__r.redwing__Duration__c;

                //console.log("ccProdId " + component.get("v.CCProductId"));
                //console.log("courseName " + courseName);
                //console.log("courseFormat " + courseFormat);
                //console.log("courseDuration " + courseDuration);

                component.set("v.cpsWrap.courseId", learningPlan);
                component.set("v.cpsWrap.courseName", getResponse.LMS_Learning_Plan__r.Name);

                component.set("v.LPName", courseName);
                component.set("v.LPClassroomSetting", courseFormat);
                var hours = Math.floor(courseDuration / 60);
                console.log("Hours: " + hours);
                component.set("v.LPDuration", hours);
                //component.set("v.ScheduledTime", hours);
            } else {
                component.set("v.cpsWrap.courseId", '');
                component.set("v.cpsWrap.courseName", 'Not Found');

                component.set("v.LPName", 'Not Found');
                component.set("v.LPClassroomSetting", '');
                component.set("v.LPDuration", '');
            }
            //}
        });
        $A.enqueueAction(action);
    },

    formatTime : function(component, event, helper) {
        // Format Start Time and End Time
        var updatedSessions = [];
        component.get("v.cpsWrap.sessionList").forEach(function(session) {
            console.log(session);
            var startTime = session.startTime;
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
            // component.set("v.formattedStartTime",startTime);
            // session.startTime = startTime;
            session.formattedStartTime = startTime;
            var endTime = session.endTime;
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
            //component.set("v.formattedEndTime",endTime);
            // session.endTime = endTime;
            session.formattedEndTime = endTime;
            updatedSessions.push(session);
        });
        component.set("v.cpsWrap.sessionList", updatedSessions);
        helper.setStartEndDate(component, event);
    },

    setStartEndDate : function(component, event, helper) {
        // Format Start Time and End Time
        var minStartDate = new Date();
        component.get("v.cpsWrap.sessionList").forEach(function(session) {
            var timeZone = session.timeZoneName;
            console.log('session.timeZone: ' + timeZone);
            console.log('session.classDate: ' + session.classDate);
            console.log('startDateString: ' + session.startTime);

            var gmtTime = new Date().toLocaleString("en-US", {timeZone: "GMT"});
            var timeZoneTime = new Date().toLocaleString("en-US", {timeZone: timeZone});
            var diff = new Date(timeZoneTime) - new Date(gmtTime);
            console.log('diff: ' + diff);



            var firstDate = new Date(session.classDate + " " + session.startTime);
            firstDate = new Date(new Date(firstDate.getTime() - diff).toLocaleString("UTC", {timeZone: "GMT"}));
            console.log('firstDate: ' + firstDate);
            var startDate = new Date(session.classDate + " " + session.startTime).toLocaleString("UTC", {timeZone: timeZone});
            console.log('startDate: ' + startDate);
            //var startDate = new Date(session.classDate, 'yyyy-MM-dd');// + "T" + session.startTime);//.toLocaleString("en", {timeZoneName: "short", timeZone: timeZone});
            var newDate = new Date(startDate);
            console.log('newDate: ' + newDate);

            // var diff = firstDate - new Date(startDate);
            // console.log('diff: ' + diff);
            var thirdDate = firstDate - newDate;
            console.log('thirdDate: ' + thirdDate);


            var adjustedStartDate = new Date(startDate);
            console.log('adjustedStartDate: ' + adjustedStartDate);

            // var adjustedStartDate = helper.changeTimezone(startDate, timeZone);
            // console.log('adjustedStartDate: ' + adjustedStartDate);
            // if (minStartDate === undefined) {
            //     minStartDate = startDate;
            //     console.log('minStartDate: ' + minStartDate);
            // }
            var startTime = session.formattedStartTime;
            var endTime = session.formattedEndTime;
            console.log('formattedStartTime: ' + startTime);
            console.log('formattedEndTime: ' + endTime);
            console.log('endDateString: ' + session.endTime);
            var endDate = new Date(session.classDate + " " + session.endTime);//.toLocaleString("en", {timeZoneName: "short", timeZone: timeZone});
            //var endDate = new Date(session.classDate, 'yyyy-MM-dd');// + "T" + session.endTime);//.toLocaleString("en", {timeZoneName: "short", timeZone: timeZone});
            console.log('endDate: ' + endDate);

            // var startTimeHrs = startTime.substring(0,2);
            // console.log('startTimeHrs: ' + startTimeHrs);
            // var startTimeMins = startTime.substring(3,5);
            // console.log('startTimeMins: ' + startTimeMins);
            // startDate.setHours(parseInt(startTimeHrs), parseInt(startTimeMins), 0);
            // console.log('final startDate: ' + startDate);
            // var endTimeHrs = endTime.substring(0,2);
            // console.log('endTimeHrs: ' + endTimeHrs);
            // var endTimeMins = endTime.substring(3,5);
            // console.log('endTimeMins: ' + endTimeMins);
            // endDate.setHours(parseInt(endTimeHrs), parseInt(endTimeMins), 0);
            // console.log('final endDate: ' + endDate);
            // var startTimeHrs = startTime.substring(0,2);
            // var startTimeAmOrPm;
            // console.log('startTimeHrs..'+startTimeHrs);
            // console.log('con..'+(startTimeHrs == '00'));
            // console.log('parsed..'+parseInt(startTimeHrs));

            // if(startTimeHrs == '12') {
            //     startTimeAmOrPm = 'PM';
            // }
            // else if(startTimeHrs == '00') {
            //     startTimeHrs = '12';
            //     startTimeAmOrPm = 'AM';
            // }
            // else if(parseInt(startTimeHrs) > 12 && parseInt(startTimeHrs) < 24) {
            //     startTimeHrs = parseInt(startTimeHrs) - 12;
            //     startTimeAmOrPm = 'PM';
            // }
            // else {
            //     startTimeAmOrPm = 'AM';
            // }
            // startTime = startTimeHrs + ':' + startTime.substring(3,5) + ' ' + startTimeAmOrPm;
            // console.log('startTime..'+startTime);
            // // component.set("v.formattedStartTime",startTime);
            // // session.startTime = startTime;
            // session.formattedStartTime = startTime;
            // var endTime = session.endTime;
            // var endTimeHrs = endTime.substring(0,2);
            // var endTimeAmOrPm;
            // console.log('endTimeHrs..'+endTimeHrs);
            // console.log('con..'+(endTimeHrs == '00'));
            // console.log('parsed..'+parseInt(endTimeHrs));
            //
            // if(endTimeHrs == '12') {
            //     endTimeAmOrPm = 'PM';
            // }
            // else if(endTimeHrs == '00') {
            //     endTimeHrs = '12';
            //     endTimeAmOrPm = 'AM';
            // }
            // else if(parseInt(endTimeHrs) > 12 && parseInt(endTimeHrs) < 24) {
            //     endTimeHrs = parseInt(endTimeHrs) - 12;
            //     endTimeAmOrPm = 'PM';
            // }
            // else {
            //     endTimeAmOrPm = 'AM';
            // }
            // endTime = endTimeHrs + ':' + endTime.substring(3,5) + ' ' + endTimeAmOrPm;
            // console.log('endTime..'+endTime);
            // //component.set("v.formattedEndTime",endTime);
            // // session.endTime = endTime;
            // session.formattedEndTime = endTime;
            // updatedSessions.push(session);
        });
        // component.set("v.cpsWrap.sessionList", updatedSessions);
    },

    changeTimezone : function (date,ianatz) {

        // suppose the date is 12:00 UTC
        var invdate = new Date(date.toLocaleString('en-US', {
            timeZone: ianatz
        }));

        // then invdate will be 07:00 in Toronto
        // and the diff is 5 hours
        var diff = date.getTime()-invdate.getTime();

        // so 12:00 in Toronto is 17:00 UTC
        return new Date(date.getTime()+diff);

    },

    //
    checkPreq : function(component, event, helper) {
        var CCProductId = component.get("v.CCProductId");
        var extUser = component.get("v.isExtUser");
        var isPartner = component.get("v.isPartner");
        // Prereq check
        if (typeof CCProductId !== 'undefined' && extUser === true && isPartner === false)
        //if(typeof CCProductId !== 'undefined')
        {
            var action1 = component.get("c.checkPrereq");
            action1.setParams({ccProdId: CCProductId});
            action1.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    //component.set("v.calciinstructor",true);
                    if (storeResponse == true) {
                        //component.set("v.Nextbuttonbool", true);
                        component.set("v.instructorHasPrerequisites", true);
                    } else {
                        //component.set("v.Nextbuttonbool", false);
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