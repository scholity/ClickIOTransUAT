/**
 * Created by bjarmolinski on 2019-06-07.
 */
({
    doInit: function(component, event, helper) {

          var url_string = window.location.href;
          var url = new URL(url_string);
          var startUrl = url.searchParams.get('startURL');
          component.set('v.startUrl', startUrl);
          component.set('v.baseUrl', window.location.hostname);

    },

    handleForgotPassword: function(component, event, helper) {
        console.log('running handleForgotPassword');
        var email = component.find('email').get('v.value');
        console.log('running before initiate action');
        var action = component.get('c.forgotPasswordB2C');
        action.setParams({
           username: email,
           startUrl: component.get('v.startUrl'),
           baseUrl: component.get('v.baseUrl')
        });

        console.log('running before setCallback');
        action.setCallback(this, function(result) {

            var state = result.getState();
            console.log('state '+ state);
            if (state === 'SUCCESS') {
                component.set("v.showError", false);
                var returnVal = result.getReturnValue();
                console.log('returnVal: '+returnVal);
                if (returnVal === true) {
                    component.set("v.screen", 1);
                } else {
                    component.set("v.screen", 2);
                }
            } else {
                console.log('state: '+state);
                component.set("v.errorMessage","An error occurred. Contact your Salesforce Administrator");
                component.set("v.showError",true);
            }
        });
        $A.enqueueAction(action);
    },


    navigateToLoginScreen: function (component, event, helper) {

        var baseURL = window.location.href;
        var url = new URL(baseURL);
        var startURL = url.searchParams.get('startURL');
        var indx = baseURL.indexOf('/s/');
        baseURL = baseURL.substring(0,indx);

        window.location.href = baseURL + '/s/login?startURL=' + startURL;
    }
})