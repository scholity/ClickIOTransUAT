({
    qsToEventMap: {
        'startURL'  : 'e.c:setStartUrl'
    },
    
    qsToEventMap2: {
        'expid'  : 'e.c:setExpId'
    },
    
    handleSelfRegister: function (component, event, helpler) {

        component.set("v.showSpinner", true);


        var objResult = component.get("v.objResult");
        var contactId = objResult.ContactId;
        var accountId = objResult.AccountId;

        var regConfirmUrl = component.get("v.regConfirmUrl");
        var firstname = component.find("firstname").get("v.value");
        var lastname = component.find("lastname").get("v.value");
        var email = component.find("email").get("v.value");
        var includePassword = component.get("v.includePasswordField");
        var password = component.find("password").get("v.value");
        var confirmPassword = component.find("confirmPassword").get("v.value");
        var action = component.get("c.selfRegister");
        var extraFields = JSON.stringify(component.get("v.extraFields"));   // somehow apex controllers refuse to deal with list of maps
        var startUrl = component.get("v.startUrl");
        
        startUrl = decodeURIComponent(startUrl);
        action.setParams({firstname:firstname,
                          lastname:lastname,
                          email:email,
                		  password:password, 
                          confirmPassword:confirmPassword, 
                          accountId:accountId,
                          contactId:contactId,
                          regConfirmUrl:regConfirmUrl, 
                          extraFields:extraFields, 
                          startUrl:startUrl, 
                          includePassword:includePassword});

          action.setCallback(this, function(a){

              var rtnValue = a.getReturnValue();
              if (rtnValue !== null) {
                 component.set("v.showSpinner", false);
                 component.set("v.errorMessage",rtnValue);
                 component.set("v.showError",true);
              }
           });
        $A.enqueueAction(action);
    },
    
    getExtraFields : function (component, event, helpler) {
        var action = component.get("c.getExtraFields");
        action.setParam("extraFieldsFieldSet", component.get("v.extraFieldsFieldSet"));
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.extraFields',rtnValue);
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
    inputCheck : function(component, helper) {
        console.log('running inputCheck in helper');

        var checkPassed = true;
        var fields = new Array("First Name", "Last Name", "Email");
        var self = this;

        fields.forEach(function(item) {
            console.log(item);
            if (!self.checkValidity(component, item)) {
                checkPassed = false;
            };
        });
        if (!this.checkPassword(component)) {
            checkPassed = false;
        };

        console.log('validity check ran');
        if (checkPassed) {
            component.set("v.hasErrors", false);
        } else {
            component.set("v.hasErrors", true);
        }

    },

    checkValidity : function(component, input1) {

        var input2 = input1;
        input1 = input1.replace(/\s/g, '').toLowerCase();

        console.log('validity check 1');
        var fieldName = component.find(input1);
        var fieldNameValue = fieldName.get("v.value");
        console.log('fieldNameValue '+fieldNameValue);
        console.log('validity check 2');

        var divName = component.find(input1 + '_div');
        console.log(divName);

        var emailCheck = true;
        if (input1.toLowerCase() === 'email') {
            emailCheck = this.checkEmail(fieldNameValue);
            console.log('emailCHeck '+ emailCheck);
        }

        if(!fieldName || fieldNameValue.trim().length < 2 || !emailCheck) {
            console.log('entered negative validation');
            fieldName.set("v.errors", [{message: "Please enter valid " + input2}]);

            component.set("v.hasErrors", true);
            $A.util.removeClass(divName, 'inputfield');
            $A.util.addClass(divName, 'inputred');
            return false;

        } else {
            fieldName.set("v.errors", [{}]);
            $A.util.removeClass(divName, 'inputred');
            $A.util.addClass(divName, 'inputfield' );
            return true;
        }
    },

    checkEmail: function(email) {
        console.log('running email validation')

        if (email.includes('@') && !email.endsWith('@') && !email.startsWith('@')) {
            return true;
        } else {
            return false;
        }
    },

    checkPassword: function(component) {

        var passwd = component.find("password");
        var passwdvalue = passwd.get("v.value");
        var passwdconf = component.find("confirmPassword");
        var passwdconfvalue = passwdconf.get("v.value");

        var passwdDiv = component.find('password_div');
        var confirmDiv = component.find('confirmPassword_div');

        // validate if password meets min requirements
        var passwdRegex = new RegExp('(?=.*[a-zA-Z])(?=.*[0-9])(?=.{8,})'); // regex pattern to validate password alerady in JS
        // at least one lower- OR uppercase character, at least one number, at least 8 characters long
        var result = passwdRegex.test(passwdvalue);

        if (!result) {
            passwd.set("v.errors", [{message: "Password does not meet criteria. Please try again."}]);
            $A.util.removeClass(passwdDiv, 'inputfield');
            $A.util.addClass(passwdDiv, 'inputred');
            return false;

        } else {

            $A.util.removeClass(passwdDiv, 'inputred');
            $A.util.addClass(passwdDiv, 'inputfield');
            passwd.set("v.errors", [{}]);
        }

        // validate if password and the confirm password values match
        if (passwdvalue !== passwdconfvalue ) {
            passwdconf.set("v.errors", [{message: "Passwords don't match. Please try again."}]);
            $A.util.removeClass(confirmDiv, 'inputfield');
            $A.util.addClass(confirmDiv, 'inputred');
            return false;

        } else {
            $A.util.removeClass(confirmDiv, 'inputred');
            $A.util.addClass(confirmDiv, 'inputfield');
            passwdconf.set("v.errors", [{}]);
        }

        return true;
    },

    showSpinner: function(component) {
        var showSpinner = component.get("v.showSpinner");
        component.set("v.showSpinner", !showSpinner );
    },

    checkExistingContact: function(component, email) {

        console.log('running checkExistingContact');
        console.log('email '+email);
        var action = component.get("c.checkExistingContact");

        action.setParams({ email: email });
        action.setCallback(this, function(res){
            var state = res.getState();
            if (state === "SUCCESS") {
                if (res.getReturnValue()) {
                    console.log("matching contact found");
                    // parse result
                    var objResult = JSON.parse(res.getReturnValue());

                    component.set("v.objResult", objResult);
                    component.set("v.firstname", objResult.FirstName);
                    component.set("v.lastname", objResult.LastName);
                    console.log('ended value assignment');

                } else {
                    // do nothing
                    console.log("matching contact not found");
                }
            }
        });
        $A.enqueueAction(action);
    }

})