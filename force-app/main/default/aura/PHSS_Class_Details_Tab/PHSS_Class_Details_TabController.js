({
    doInit : function(component, event, helper) {
        var hostDomainPattern = new RegExp("^(https:////.*)//");
        var urlString = hostDomainPattern.exec(location.href);
        if (urlString != null && urlString[1] != null) {
            var hostDomain = urlString[1];
            component.set("v.hostDomain",hostDomain);
        }        
 
        helper.getData(component);
    }
})