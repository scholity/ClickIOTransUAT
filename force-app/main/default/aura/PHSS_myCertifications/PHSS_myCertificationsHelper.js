({
	 fetchCert : function(component, event, helper) {
        var Pagelimit=component.get("v.Pagelimit");
         var action = component.get("c.fetchAchv");        
        action.setCallback(this, function(response){
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log('data++++1'+JSON.stringify(data));
                
                var FirstList= data.splice(0,Pagelimit);
                 console.log('FirstList++++'+JSON.stringify(FirstList));
                 console.log('data++++2'+JSON.stringify(data));
                component.set("v.ListAchivementAssignment",FirstList);
                component.set("v.TempListAA", data);
            }
        });
        $A.enqueueAction(action);
    }
})