/**
 * Created by bjarmolinski on 2019-06-03.
 */
({
    doInit: function(component, event, helper) {

        var url_string = window.location.href;
        var url = new URL(url_string);
        var encryptedEmail = url.searchParams.get('src');
        var sPageURL = url.searchParams.get('startURL');


        if (sPageURL || encryptedEmail) {
            component.set("v.b2cOrigin", true);
        } else {
            component.set("v.b2cOrigin", false);
        }

    },

    openMenu: function(component, event, helper) {

        var menu = component.find('menu_container');
        var isClosed = $A.util.hasClass(menu, 'slds-is-closed');
        console.log(isClosed);

        if (isClosed) {
            $A.util.removeClass(menu, 'slds-is-closed');
            $A.util.addClass(menu, 'slds-is-open');
        } else {
            $A.util.removeClass(menu, 'slds-is-open' );
            $A.util.addClass(menu, 'slds-is-closed');
        }
    }
})