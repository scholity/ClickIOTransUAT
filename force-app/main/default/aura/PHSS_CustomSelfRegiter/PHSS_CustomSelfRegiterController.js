({
    initialize: function(component, event, helper) {

        var sPageURL = decodeURIComponent(window.location.search.substring(1)); //You get the whole decoded URL of the page.
        var paramsArray = sPageURL.split('&');
        console.log(paramsArray);

        var email;

        paramsArray.forEach(function(item) {
            var nameValPair = item.split('=');
            console.log('nameValPair: '+ nameValPair);
            if (nameValPair[0] === 'startURL') {
                nameValPair.splice(0,1);
                var val = nameValPair.join('');
                component.set("v.startUrl",val);
            } else if (nameValPair[0] === 'b2cOrigin') {
                component.set("v.b2cOrigin", nameValPair[1]);
            } else if (nameValPair[0] === 'email') {
                component.set("v.email", nameValPair[1]);
                email = nameValPair[1];
            }
        });

        console.log('email: '+ email);
        helper.checkExistingContact(component, email);
                
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap}).fire();
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap2}).fire();        
        component.set('v.extraFields', helper.getExtraFields(component, event, helper));
    },
    
    handleSelfRegister: function (component, event, helpler) {
        helpler.inputCheck(component, helpler);
        if (!component.get("v.hasErrors")) {
            helpler.handleSelfRegister(component, event, helpler);
        }


    },
    
    setStartUrl: function (component, event, helpler) {
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
    
    onKeyUp: function(component, event, helpler){
        //checks for "enter" key
        if (event.getParam('keyCode')===13) {
            helpler.handleSelfRegister(component, event, helpler);
        }
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