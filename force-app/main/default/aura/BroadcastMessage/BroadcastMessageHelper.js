({
    /**
     *  Method queries server for list of messages to display
     *  @param component Component instance
     */
    getMessages: function(component) {
        // Load all message data
        var that = this;
        var action = component.get("c.getBroadcastMessages");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var messages = response.getReturnValue();
                 if (messages.length > 0) {
                    component.set("v.messages", messages);
                    // Initial broadcast
                    that.startBroadcast(component);
                    
                    /* sfdc support case #17411073 - original
                       window.setTimeout(
                         $A.getCallback(function() {
                             if(component.isValid())
                             that.startBroadcast(component);
                         }), component.get("v.interval")
                     );
                     */
                     
                     // sfdc support case #17411073 - added
                     window.setInterval(
                         function() {                           
                             if(component.isValid())                                 
                             that.startBroadcast(component);
                         }, component.get("v.interval")
                     );         
                     
                }
            }
        });
        $A.enqueueAction(action);
    },
    startBroadcast: function(component) {
        var messages = component.get('v.messages');
        var currentIndex = component.get('v.messageIndex');
        component.set('v.currentMessage', messages[currentIndex].Message__c);
        component.set('v.currentMessageLink', messages[currentIndex].Clickable_Link__c);
        component.set('v.messageIndex', currentIndex === messages.length - 1 ? 0 : ++currentIndex);
    }
})