({
    getILTClassData : function(component){
        var getItemInfo = component.get("c.getItemInfo");
        var recordId = component.get('v.recordId');
        if($A.util.isEmpty(recordId)){
            var urlRecordId = /[&?]urlRecordId(=([^&]*)|&|$)/.exec(location.href);
            if (urlRecordId != null && urlRecordId.length > 2 && urlRecordId[2] != null) {
                recordId = urlRecordId[2];
            }
        }
        var planId = '';
        var urlPlanId = /[&]pId(=([^&]*)|&|$)/.exec(location.href);
            if (urlPlanId != null && urlPlanId.length > 2 && urlPlanId[2] != null) {
                planId = urlPlanId[2];
            }
        getItemInfo.setParams({
            "itemId": recordId,
            "planId": planId
        });

        getItemInfo.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();

                if (result.status === 'SUCCESS') {
                    moment.locale(result.lang);
                    if(result.item){
                        component.set("v.item", result.item);
                        var extraFields = [];
                        if(result.item.startDate){
                            extraFields.push({
                                fieldPath : "",
                                label : component.get("v.label_Start_Date"),
                                type  : "DATE",
                                value : moment(result.item.startDate).format('L')
                            });
                        }
                        if(result.item.endDate){
                            extraFields.push({
                                fieldPath : "",
                                label : component.get("v.label_End_Date"),
                                type  : "DATE",
                                value : moment(result.item.endDate).format('L')
                            });
                        }
                        if(result.item.organization){
                            extraFields.push({
                                fieldPath : "",
                                label : component.get("v.label_Organization"),
                                type  : "STRING",
                                value : result.item.organization
                            });
                        }
                        if(result.item.classSettings){
                            extraFields.push({
                                fieldPath : "",
                                label : component.get("v.label_Class_Setting"),
                                type  : "STRING",
                                value : result.item.classSettings
                            });
                        }
                        /*if(result.item.language){
                            extraFields.push({
                                fieldPath : "",
                                label : component.get("v.label_Language"),
                                type  : "STRING",
                                value : result.item.language
                            });
                        }*/
                        /*
                        if(result.item.numberOfStudents >= 0){
                            extraFields.push({
                                fieldPath : "",
                                label : component.get("v.label_Number_Of_Students"),
                                type  : "INTEGER",
                                value : result.item.numberOfStudents
                            });
                        }
                        */
                        if(result.item.status){
                            extraFields.push({
                                fieldPath : "",
                                label : component.get("v.label_Status"),
                                type  : "STRING",
                                value : result.item.status
                            });
                        }
                        component.set('v.extraFields', extraFields);
                    }

                } else {
                    this.showMessage(result.status, result.message, 'error');
                }

            } else {
                console.log('error');
            }
        });

        $A.enqueueAction(getItemInfo);
    },
    showMessage: function(title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        if (toastEvent) {
            toastEvent.setParams({
                "title":    title,
                "message":  message,
                "type":     $A.util.isEmpty(type) ? 'info' : type
            });
            toastEvent.fire();
        } else {
            alert(title + ': ' + message);
        }
    }
});