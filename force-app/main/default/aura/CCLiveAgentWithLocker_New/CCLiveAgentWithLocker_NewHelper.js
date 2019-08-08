({
    initLiveAgent: function(component) {
        this.getUserProfile(component, function(userProfile) {
            var liveagentattrs = {};
            if (userProfile != null) {
                liveagentattrs.name = userProfile.Name;
                if (userProfile.Contact != null) {
                    liveagentattrs.contactId = userProfile.Contact.Id;
                }
                var frameWindow = component.find("liveAgentProxyIframe").getElement().contentWindow;
//                console.log('Posting message');
//                console.log(frameWindow);
                frameWindow.postMessage({
                    'type': 'INIT_LIVEAGENT',
                    'attributes': liveagentattrs
                }, location.protocol + "//" + location.host);
            }
        });
    },
    startChat: function(component) {
        var frameWindow = component.find("liveAgentProxyIframe").getElement().contentWindow;
        frameWindow.postMessage({
            'type': 'START_LIVEAGENT_CHAT'
        }, location.protocol + "//" + location.host);
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
            } 
        });
        $A.enqueueAction(action);
    }
    // Helper method to initiate live agent.
 /*   initiateLiveAgent : function(cmp) {
        var buttonId = cmp.get('v.buttonId');
        var deploymentId = cmp.get('v.deploymentId');
        var orgId = cmp.get('v.orgId');
		var busyLabel = cmp.get('v.agentBusyLabel');
        var liveAgentInitUrl = cmp.get('v.liveagentInitUrl');
        
        // Button Callback functions.
        var buttonCallback = function(e){
            console.log(e);
            console.log('In Button CallBack');
            if (e == liveagent.BUTTON_EVENT.BUTTON_AVAILABLE) {
                console.log('Button Available');
                if (cmp.isValid()) {
                    cmp.set('v.buttonDisabled', false);
                    $A.util.removeClass(cmp.find('liveagent_btn'), 'isDisabled');
                    cmp.set('v.status_reason', null);
                }
            }
            if (e == liveagent.BUTTON_EVENT.BUTTON_UNAVAILABLE) {
                console.log('Button Unavailable');
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
        
        console.log(window);
        
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
       /* if(cmp.get('v.popupContact')){
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
            console.log('Init Live agent : ' + liveAgentInitUrl);
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
    }*/
})