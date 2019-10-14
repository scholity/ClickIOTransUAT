({
    doInit : function(component, event, helper) {
        //Set Start Date
        var today = new Date();
        var ddStart = today.getDate();
        var mmStart = today.getMonth()+1; 
        var yyyyStart = today.getFullYear();
        if(ddStart<10) 
        {
            ddStart ='0'+ddStart;
        } 
        
        if(mmStart<10) 
        {
            mmStart ='0'+mmStart;
        } 
        today = yyyyStart+'-'+mmStart+'-'+ddStart;
        component.set("v.StartDateFrom",today);
        
        //Set End Date
        var endDate = new Date(); 
        endDate.setDate(endDate.getDate() + 90);
        var ddEnd = endDate.getDate();
        var mmEnd = endDate.getMonth()+1; 
        var yyyyEnd = endDate.getFullYear();
        if(ddEnd<10) 
        {
            ddEnd ='0'+ddEnd;
        } 
        
        if(mmEnd<10) 
        {
            mmEnd ='0'+mmEnd;
        } 
        endDate = yyyyEnd+'-'+mmEnd+'-'+ddEnd;
        component.set("v.StartDateTo",endDate);
        
        component.set("v.objName","Account");
        helper.getValues(component, helper);
    },
    
    getCPSClasses : function(component, event, helper) {
        helper.getData(component, helper);
    },
    
    getClassesOnChangeDate : function(component, event, helper) {
        helper.getData(component, helper);
    },
    
    getClassesOnChangeLookUp : function(component, event, helper) {
        helper.getData(component, helper);
    },
    
    sortField : function(component, event, helper) {
        var dataset = event.target.dataset;
        helper.sortFields(component, dataset.field, dataset.order);
    },
    
    downloadDocumentCurrent : function(component, event, helper){
        var sendData = component.get("v.sendData");
        
        console.log('dataToSend='+component.get("v.Classes"));        
        var dataToSend = component.get("v.Classes");
        
        //invoke vf page js method
        sendData(dataToSend, 'PDF', function(){
            //handle callback
        });
    },
    
    exportDocumentCurrent : function(component, event, helper){
        var sendData = component.get("v.sendData");
        
        console.log('dataToSend='+component.get("v.Classes"));        
        var dataToSend = component.get("v.Classes");
        
        //invoke vf page js method
        sendData(dataToSend, 'XLS', function(){
            //handle callback
        });
    }
})