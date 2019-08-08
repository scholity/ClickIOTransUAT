/**
 * Created by bjarmolinski on 2019-06-14.
 */
({
    setPassword: function (component) {

        var url_string = window.location.href;
        var url = new URL(url_string);
        var encryptedEmail = url.searchParams.get('src');
        var startUrl = url.searchParams.get('startURL');

        var password = component.get('v.password');
        var confirm = component.get('v.confirm');

        if (password === confirm) {
            var action = component.get('c.resetPassword');
            action.setParams({
                password: password,
                encryptedEmail: encryptedEmail,
                startUrl: startUrl
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    component.set('v.result', response.getReturnValue());
                } else {
                    component.set('v.result', 'Password reset failed. Please contact Technical Support.');
                }
            });
            $A.enqueueAction(action);
        }
    },

    validatePassword: function (component) {
        var passwd = component.find("password");
        var passwdvalue = passwd.get("v.value");
        var passwdconf = component.find("confirmpassword");
        var passwdconfvalue = passwdconf.get("v.value");

        var passwdDiv = component.find('password_div');
        var confirmDiv = component.find('confirmPassword_div');

        // validate if password meets min requirements
        var passwdRegex = new RegExp('(?=.*[a-zA-Z])(?=.*[0-9])(?=.{8,})'); // regex pattern to validate password already in JS
        // at least one lower- OR uppercase character, at least one number, at least 8 characters long
        var result = passwdRegex.test(passwdvalue);

        if (!result) {
            passwd.set("v.errors", [{message: "Password does not meet criteria. Please try again."}]);
            $A.util.removeClass(passwd, 'inputfield');
            $A.util.addClass(passwd, 'inputred');
            return false;

        } else {
            $A.util.removeClass(passwd, 'inputred');
            $A.util.addClass(passwd, 'inputfield');
            passwd.set("v.errors", [{}]);
        }

        // validate if password and the confirm password values match
        if (passwdvalue !== passwdconfvalue ) {
            passwdconf.set("v.errors", [{message: "Passwords don't match. Please try again."}]);
            $A.util.removeClass(confirm, 'inputfield');
            $A.util.addClass(confirm, 'inputred');
            return false;

        } else {
            $A.util.removeClass(confirm, 'inputred');
            $A.util.addClass(confirm, 'inputfield');
            passwdconf.set("v.errors", [{}]);
        }

        return true;
    }
})