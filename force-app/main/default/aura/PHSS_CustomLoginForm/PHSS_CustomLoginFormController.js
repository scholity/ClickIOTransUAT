({
    initialize: function(component, event, helper) {
        var sPageURL = decodeURIComponent(window.location.search.substring(1)); //You get the whole decoded URL of the page.
        var indxB2C = sPageURL.indexOf('RemoteAccessAuthorizationPage');
        var indxStartUrl = sPageURL.indexOf('startURL');
        sPageURL = sPageURL.substring(indxStartUrl);
        console.log('sPageUrl '+sPageURL );
        component.set("v.startUrl",sPageURL);
        
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap}).fire();    
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap2}).fire();
        component.set('v.isUsernamePasswordEnabled', helper.getIsUsernamePasswordEnabled(component, event, helper));
        component.set("v.isSelfRegistrationEnabled", helper.getIsSelfRegistrationEnabled(component, event, helper));
        component.set("v.communityForgotPasswordUrl", helper.getCommunityForgotPasswordUrl(component, event, helper));
        component.set("v.communitySelfRegisterUrl", helper.getCommunitySelfRegisterUrl(component, event, helper));

        if (indxB2C >= 0) {
        //if (sPageURL) {
            component.set("v.b2c_origin", true);
        } else {
            component.set("v.b2c_origin", false);
        }

    },
    
    handleLogin: function (component, event, helper) {
        console.log('handle login running');
        helper.handleLogin(component, event, helper);
    },
    
    setStartUrl: function (component, event, helper) {
        var startUrl = event.getParam('startURL');
        if(startUrl) {
            component.set("v.startUrl", startUrl);
        }
    },
    
    setExpId: function (component, event, helper) {
        var expId = event.getParam('expid');
        if (expId) {
            component.set("v.expid", expId);
        }
        helper.setBrandingCookie(component, event, helper);
    },
    
    onKeyUp: function(component, event, helper){
        //checks for "enter" key
        if (event.getParam('keyCode')===13) {
            helper.handleLogin(component, event, helper);
        }
    },
    
    navigateToForgotPassword: function(cmp, event, helper) {
        var forgotPwdUrl = cmp.get("v.communityForgotPasswordUrl");
        if ($A.util.isUndefinedOrNull(forgotPwdUrl)) {
            forgotPwdUrl = cmp.get("v.forgotPasswordUrl");
        }
        var attributes = { url: forgotPwdUrl };
        $A.get("e.force:navigateToURL").setParams(attributes).fire();
    },
    
    navigateToSelfRegister: function(cmp, event, helper) {
        var selrRegUrl = cmp.get("v.communitySelfRegisterUrl");
        if (selrRegUrl == null) {
            selrRegUrl = cmp.get("v.selfRegisterUrl") + '?startURL=' + cmp.get('v.startUrl') + '&b2cOrigin=' + cmp.get('v.b2c_origin');
        }

        var attributes = { url: selrRegUrl };
        $A.get("e.force:navigateToURL").setParams(attributes).fire();
    },
    
    navigateToClaimVoucher: function(cmp, event, helper) {
        var baseURL = window.location.href;
        var indx = baseURL.indexOf('/s/');
        baseURL = baseURL.substring(0,indx);
        window.location.href = baseURL + '/s/ClaimVoucher';
    },

    navigateToNextStep: function(cmp, event, helper) {
        helper.verifyUserEmail(cmp, event);
    },

    navigateToForgottenPasswdB2C: function (component, event, helper) {

        var baseURL = window.location.href;
        var indx = baseURL.indexOf('/s/');
        baseURL = baseURL.substring(0,indx);

        window.location.href = baseURL + '/s/forgot-password-b2c?startURL=' + component.get("v.startUrl");

    },

    navigateToCreateAccount: function (component, event, helper) {

        var baseURL = window.location.href;
        var indx = baseURL.indexOf('/s/');
        baseURL = baseURL.substring(0,indx);

        window.location.href = baseURL + '/s/login/SelfRegister?startURL=' + component.get('v.startUrl') + '&b2cOrigin=true';

    }
})