({
    doInit : function(component, event, helper) {
        component.set("v.objName","Account");
        component.set("v.objInsName","User");
        helper.getValues(component);
    },
    fetchIns : function(component, event, helper) {
        
        var action = component.get("c.fetchAchv");
        var orgId 	= component.get("v.selectedAccount")
        var InsId   = component.get("v.selectedInstructor")
        var orgg;
        var Ins;
        if((orgId!=null||orgId!=undefined||orgId!='') && (InsId==null||InsId==undefined||InsId==''))
        {
            orgg = orgId;
            Ins = 'Not';
        }
        if((orgId==null||orgId==undefined||orgId=='') && (InsId!=null||InsId!=undefined||InsId!=''))
        {
            orgg = 'Not';
            Ins = InsId;
        }
        if((orgId!=null && InsId!=undefined && orgId!='' && InsId!=''))
        {
            orgg = orgId;
            Ins = InsId;
        }
        
        console.log('Accountid>>>>>>>>'+orgg);
        console.log('Instructor idd>>>>>>>>'+Ins);
        var idx = event.target.id;
        
        action.setParams({accId : orgg,instId :Ins});
        
        
        
        console.log('Button id>>>>>>>>'+idx);
        action.setCallback(this, function(response){
            
            var state = response.getState();
            console.log('Expected State'+state);
            if (state === "SUCCESS") {
                var a = response.getReturnValue();
                console.log('success'+a);
                console.log('getting inside succes'+JSON.stringify(a));
                component.set("v.Listss", response.getReturnValue());
                
                
            }
        });
        $A.enqueueAction(action);
    },
    sortField : function(component, event, helper) {
        var dataset = event.target.dataset;
        console.log('array..'+dataset.array);
        console.log('field..'+dataset.field);
        console.log('order..'+dataset.order);
        helper.sortFields(component, dataset.array, dataset.field, dataset.order);
    },
})