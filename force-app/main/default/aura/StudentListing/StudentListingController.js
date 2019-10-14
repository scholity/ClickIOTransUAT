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
        component.set("v.expirationDateFrom",today);
        
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
        component.set("v.expirationDateTo",endDate);
        
        component.set("v.objName","Account");
        component.set("v.objInsName","User");
        helper.getValues(component, event, helper);
    },
    
    getInstructorValues : function(component, event, helper) 
    {
        component.set("v.objName","User");
        helper.getValues(component, event, helper); 
    },
    
    fetchIns : function(component, event, helper) {
        helper.fetchIns(component, event, helper);
    },
    
    getStudentsOnChangeDate : function(component, event, helper) {
        helper.fetchIns(component, event, helper);
    },
    
    getStudentsOnChangeLookUp : function(component, event, helper) {
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
        var companyName = component.get("v.Listss")[0].OrganizationName;
        console.log('dataToSend='+component.get("v.Listss"));
        var dataToSend = component.get("v.Listss");
        
        //invoke vf page js method
        sendData(dataToSend, 'PDF', companyName, component.get("v.expirationDateFrom"), component.get("v.expirationDateTo"), function(){
            //handle callback
        });
    },
    
    exportDocument : function(component, event, helper){
        var sendData = component.get("v.sendData");
        var companyName = component.get("v.Listss")[0].OrganizationName;
        console.log('dataToSend='+component.get("v.Listss"));
        var dataToSend = component.get("v.Listss");
        
        //invoke vf page js method
        sendData(dataToSend, 'XLS', companyName, component.get("v.expirationDateFrom"), component.get("v.expirationDateTo"), function(){
            //handle callback
        });
    }
})