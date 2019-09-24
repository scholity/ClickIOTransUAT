({
    doInit : function(component, event, helper) {
        component.set("v.objName","Account");
        component.set("v.objInsName","User");
        helper.getValues(component, event, helper);
        //helper.fetchIns(component, event, helper);
    },
    getInstructorValues : function(component, event, helper) {
        if(component.get("v.selectedAccount") == "") {
            component.set("v.selectedInstructor","");
        }    
        else { 
            component.set("v.objName","User");
            helper.getValues(component, event, helper); 
        }
    },
    sortOrgName: function(component, event, helper) {
        // set current selected header field on selectedTabsoft attribute.     
        component.set("v.selectedTabsoft", 'OrganizationName');
        // call the helper function with pass sortField Name   
        // helper.sortHelper(component, event, 'Name');
    },
    fetchIns : function(component, event, helper) {
        helper.fetchIns(component, event, helper);
    },
    sortField : function(component, event, helper) {
        var dataset = event.target.dataset;
        console.log('array..'+dataset.array);
        console.log('field..'+dataset.field);
        console.log('order..'+dataset.order);
        helper.sortFields(component, dataset.array, dataset.field, dataset.order);
    },
    downloadDocument : function(component, event, helper){
        var sendData = component.get("v.sendData");
        
        console.log('dataToSend='+component.get("v.Listss"));
        var dataToSend = component.get("v.Listss");
        
        //invoke vf page js method
        sendData(dataToSend, 'PDF', function(){
            //handle callback
        });
    },
    exportDocument : function(component, event, helper){
        var sendData = component.get("v.sendData");
        
        console.log('dataToSend='+component.get("v.Listss"));
        var dataToSend = component.get("v.Listss");
        
        //invoke vf page js method
        sendData(dataToSend, 'XLS', function(){
            //handle callback
        });
    }
})