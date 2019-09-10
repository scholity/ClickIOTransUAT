({
   handleClick: function(component, event, helper) {
        console.log("Start "  );
        var recordId = component.get("v.recordId");
        var object = component.get("v.object");
        var doclist = component.get("v.doclist");
        var prepMail = component.get("v.prepMail");
        var btnClicked = event.getSource(); // the button
        var btnMessage = btnClicked.get("v.value"); // the button value
        var childObjName= component.get("v.childObjName");
        var lookUpField= component.get("v.lookUpField");
        var combineAll= component.get("v.combineAll");
        var autoRedirect= component.get("v.autoRedirect");      
        var relatedReport= component.get("v.relatedReport");      
        var additionalFilters= component.get("v.additionalFilters");      

        if($A.util.isEmpty(recordId)){
            var recordIdpattern = new RegExp("[?&]recordId=(([^&]*)&?|&|$)");
            var urlRecordId = recordIdpattern.exec(location.href);
            //var urlRecordId = /[?&]urlRecordId(=([^&]*)|&|$)/.exec(location.href);
            if (urlRecordId != null && urlRecordId.length > 2 && urlRecordId[2] != null && urlRecordId[2].length > 2) {
                recordId = urlRecordId[2];
            }
        }
        var planId = '';
        var planIdpattern = new RegExp("[?&]pId=(([^&]*)&?|&|$)");
        var urlPlanId = planIdpattern.exec(location.href);        
        //var urlPlanId = /[&]pId(=([^&]*)|&|$)/.exec(location.href);
        if (urlPlanId != null && urlPlanId.length > 2 && urlPlanId[2] != null && urlPlanId[2].length > 2) {
            planId = urlPlanId[2];
        }
        console.log("planId: " + planId);
        console.log("recordId: " + recordId );
        console.log("object: " + object );
       
   
        var sdocURL = ' ';
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));
        // sdocURL = baseURL+'/apex/SDOC__SDCreate1?id='+recordId+'&Object='+object+'&doclist='+doclist+'&prepmail='+prepMail+'&Site='+baseURL;
        console.log("Start "  );

        if(relatedReport !=="1") {
           sdocURL = baseURL+'/apex/SDOC__SDCreate1?id='+recordId+'&Object='+object+'&doclist='+doclist+'&prepmail='+prepMail+'&uiLanguage=English';
        }
        else {
           sdocURL = baseURL+'/apex/SDRelatedListDocuments?parentId='+recordId+'&childObjName='+childObjName+'&LookupFieldName='+lookUpField+'&doclist='+doclist+'&allowEmail='+prepMail+'&combineAll='+combineAll+'&autoRedirect='+autoRedirect+'&additionalFilters='+additionalFilters+'&uiLanguage=English';
        };
        console.log("sdocURL: " + sdocURL );
        
        component.set("v.sdocURL", sdocURL);
      
           var attr_value = component.get("v.buttonURL");
		// Find the text value of the component with aura:id set to "address"
    	var address = component.find("address").get("v.value");
        var urlEvent = $A.get("e.force:navigateToURL");
        //urlEvent.setParams({"url": attr_value});
        urlEvent.setParams({"url": sdocURL});
        urlEvent.fire();
     
   }
})