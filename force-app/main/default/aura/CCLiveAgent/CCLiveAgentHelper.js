({
    // Helper method to initiate live agent.
    initiateLiveAgent : function(cmp) {
        var buttonId = cmp.get('v.buttonId');
        var deploymentId = cmp.get('v.deploymentId');
        var orgId = cmp.get('v.orgId');
		var busyLabel = cmp.get('v.agentBusyLabel');
        var liveAgentInitUrl = cmp.get('v.liveagentInitUrl');
        
        // Button Callback functions.
        var buttonCallback = function(e){
            if (e == liveagent.BUTTON_EVENT.BUTTON_AVAILABLE) {
                if (cmp.isValid()) {
                    cmp.set('v.buttonDisabled', false);
                    $A.util.removeClass(cmp.find('liveagent_btn'), 'isDisabled');
                    cmp.set('v.status_reason', null);
                }
            }
            if (e == liveagent.BUTTON_EVENT.BUTTON_UNAVAILABLE) {
                if (cmp.isValid()) {
                    cmp.set('v.buttonDisabled', true);
                    $A.util.addClass(cmp.find('liveagent_btn'), 'isDisabled');
                    cmp.set('v.status_reason', busyLabel);
                }
            }
            
        }
        if(cmp.get('v.debugMode')){
        	liveagent.enableLogging();            
        }
        if (!window._laq) { window._laq = []; }
        window._laq.push(function(){
            liveagent.showWhenOnline(buttonId, document.getElementById(cmp.get('v.onlineButtonId')));
            liveagent.showWhenOffline(buttonId, document.getElementById(cmp.get('v.offlineButtonId')));
                                   });
        liveagent.addButtonEventHandler(buttonId, buttonCallback);

        /*    var userProfile = this.getUserProfile();
        if(userProfile !=null){
        	liveagent.setName(userProfile.Name);
        }
        if(userProfile.Contact !=null){
        }*/
        if(cmp.get('v.popupContact')){
            console.log('Calling Pop Contact');
            this.getUserProfile(cmp, function(userProfile){
                if(userProfile !=null){
                   liveagent.setName(userProfile.Name);
                   if(userProfile.Contact !=null){
                        liveagent.addCustomDetail('Contact ID', userProfile.Contact.Id, false);
                        console.log('Contact: ' + userProfile.Contact.Id);
                        liveagent.findOrCreate("Contact").map("Id", 'Contact ID', true, true, false); 
                       
                   }
                }
                liveagent.init(liveAgentInitUrl, deploymentId, orgId);
            });
        } else {
        	liveagent.init(liveAgentInitUrl, deploymentId, orgId);       
        }
        
    },
    getUserProfile : function(cmp, successCallBack) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var action = cmp.get("c.getUserProfile");
        action.setParams({
            "userId": userId
        });
        var self = this;
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                successCallBack(response.getReturnValue());
            } else {
                $A.error('Error querying User Profile');
                cmp.set('v.buttonDisabled', true);
                $A.util.addClass(cmp.find('liveagent_btn'), 'isDisabled');
            }
        });
        $A.enqueueAction(action);
    }
})