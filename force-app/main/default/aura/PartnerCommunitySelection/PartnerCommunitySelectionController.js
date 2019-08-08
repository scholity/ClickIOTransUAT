({
	getaccounts : function (component,event,helper){
        console.log("account Selected");
        var orgId 	= component.get("v.selectedLookUpRecord1").Id
        
        component.set("v.accId",orgId);
        
        console.log("***orgId***"+orgId);
  
    },
    fireApplicationEvent : function (component,event,helper){
        var Organization 	= component.get("v.selectedLookUpRecord1");
        var Instructor 	= component.get("v.selectedLookUpRecord4");
        var appEvent = $A.get("e.c:InstructorPassEvent");
        appEvent.setParams({
            "Organization" : Organization,
            "PartnerInstructor" : Instructor });
        appEvent.fire();
  
    }
})