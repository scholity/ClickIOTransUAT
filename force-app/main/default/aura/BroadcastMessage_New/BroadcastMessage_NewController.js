({
    doInit : function(component, event, helper) {
        // load messages from the backend
        helper.getMessages(component);
        
        window.setTimeout(
            $A.getCallback(function() {
                var notification = component.find('notification');
                $A.util.removeClass(notification, 'slds-hide');
            }), 5000
        );
        window.setTimeout(
            $A.getCallback(function() {
                var notification = component.find('notification');
                $A.util.addClass(notification, 'slds-hide');
            }), 20000
        );
    },
    handleClick : function(cmp, event) {
        var attributeValue = cmp.get("v.show");
        cmp.set("v.show", "false");
    },
    close : function(component, event, helper){
        var close = component.find('notification');
        $A.util.addClass(close, 'slds-hide');
    }
    
})