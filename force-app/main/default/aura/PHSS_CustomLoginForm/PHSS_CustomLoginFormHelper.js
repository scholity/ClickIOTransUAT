({
    
    qsToEventMap: {
        'startURL'  : 'e.c:setStartUrl'
    },

    qsToEventMap2: {
        'expid'  : 'e.c:setExpId'
    },
    
    handleLogin: function (component, event, helper) {
        console.log(component.get("v.email"));
        
        var username;
        var password;
        
        if (component.get("v.email") && component.find("passwordb2c")) {
            username = component.get("v.email");
        	password = component.find("passwordb2c").get("v.value");
        } else {
            username = component.find("username").get("v.value");
        	password = component.find("password").get("v.value");
        }
        var action = component.get("c.login");
        var startUrl = component.get("v.startUrl");
        
        console.log('username '+username);
        console.log('password '+password);
        console.log('startUrl '+startUrl);
        
        startUrl = decodeURIComponent(startUrl);
        console.log('decoded: '+startUrl);
        
        action.setParams({username:username, password:password, startUrl:startUrl});
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set("v.errorMessage",rtnValue);
                component.set("v.showError",true);
            }
        });
        $A.enqueueAction(action);
    },
    
    getIsUsernamePasswordEnabled : function (component, event, helpler) {
        var action = component.get("c.getIsUsernamePasswordEnabled");
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.isUsernamePasswordEnabled',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getIsSelfRegistrationEnabled : function (component, event, helpler) {
        var action = component.get("c.getIsSelfRegistrationEnabled");
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.isSelfRegistrationEnabled',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getCommunityForgotPasswordUrl : function (component, event, helpler) {
        var action = component.get("c.getForgotPasswordUrl");
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.communityForgotPasswordUrl',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getCommunitySelfRegisterUrl : function (component, event, helpler) {
        var action = component.get("c.getSelfRegistrationUrl");
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.communitySelfRegisterUrl',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },

    setBrandingCookie: function (component, event, helpler) {
        var expId = component.get("v.expid");
        if (expId) {
            var action = component.get("c.setExperienceId");
            action.setParams({expId:expId});
            action.setCallback(this, function(a){ });
            $A.enqueueAction(action);
        }
    },

    verifyUserEmail: function (cmp, event) {
		var emailStr = cmp.find("usernameb2c").get("v.value");
        if (emailStr) {
            var action = cmp.get("c.checkUserEmail");
            action.setParams({ email : emailStr });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log("state: "+state);
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    console.log("result "+result);
                    if (result === true) {
                        console.log("assigning step 1");
                        cmp.set("v.b2c_step", 1);
                    } else {
                        console.log("running step 2");
                        cmp.set("v.b2c_step", 2);
                        this.redirectToSelfReg(cmp, event);
                    }
                } else if (state === "ERROR") {
                    cmp.set("v.errorMessage", response.getErrors()[0].message);
                } else {
                    cmp.set("v.errorMessage", "Unknown error");
                }
            });
            $A.enqueueAction(action);
        } 
        else {
            cmp.set("v.errorMessage", "Invalid email address");
        }
    },

    redirectToSelfReg: function(component, event) {

        console.log('in redirection method');
        if (component.get("v.b2c_step") === 2) {

            var email = component.get("v.email");
            var b2cOrigin = component.get("v.b2c_origin");

            var startURL = component.get("v.startUrl");
            var eurl = '/SelfRegister?startURL=' + startURL + '&email=' + email + '&b2cOrigin=' + b2cOrigin;
            console.log(eurl);
            var regUrl = $A.get("e.force:navigateToURL");
            regUrl.setParams({
                "url": eurl
            });
            regUrl.fire();
        }

    }
})