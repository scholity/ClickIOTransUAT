/**
 * Created by bjarmolinski on 2019-06-13.
 */
({
    handlepopover: function(component, event, helper) {
//        component.find('overlayLib').showCustomPopover({
//            body: "Popover text goes here",
//            referenceSelector: ".popover1"
//        });

        console.log('running handle popover');
        var popover = component.find('popover');
        var modalOn = component.get('v.modalOn');

        console.log('modalOn '+modalOn);
        if (!modalOn) {
            $A.util.removeClass(popover, 'slds-hide');
            component.set('v.modalOn', true);
        } else {
            $A.util.addClass(popover, 'slds-hide');
            component.set('v.modalOn', false);
        }
    },

    closepopover: function(component, event, helper) {
        console.log('running close popover');
        var popover = component.find('popover');
        $A.util.addClass(popover, 'slds-hide');
        component.set('v.modalOn', false);
    }
})