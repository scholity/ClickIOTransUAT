({
    init: function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToURL");
        navEvt.setParams({
            "url": "https://arc.my.skedulo.com/availability/calendar"
        });
        console.log(component.getElement());
        window.setTimeout($A.getCallback(function () {
        	$A.get("e.force:closeQuickAction").fire();
        	navEvt.fire();
        }));
    },
	mangeResourceAvailability: function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToURL");
        navEvt.setParams({
            "url": "https://arc.my.skedulo.com/availability/calendar"
        });
        navEvt.fire();
    }
})