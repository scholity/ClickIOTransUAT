({
    doInit : function (cmp, evt, helper) {
    	var sPageURL = decodeURIComponent(window.location.search.substring(1)); //You get the whole decoded URL of the page.
        var sURLVariables = sPageURL.split('&'); //Split by & so that you get the key value pairs separately in a list
        var sParameterName;
        var i;

        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('='); //to split the key from the value.
            if (sParameterName[0] === 'isNewLearner') { //lets say you are looking for param name - firstName
                sParameterName[1] === undefined ? 'Not found' : sParameterName[1];
            }
        }
        console.log('Param name'+sParameterName[0]);
        console.log('Param value'+sParameterName[1]);
        cmp.set("v.isNewLearner",sParameterName[1]);
    },
    
	handleLogin : function (cmp, evt, helper) {
        var attributes = { url: '/' };
        $A.get("e.force:navigateToURL").setParams(attributes).fire();
    },
})