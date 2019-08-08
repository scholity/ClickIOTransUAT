/**
 * Created by jbarker on 10/4/18.
 */
({
    /**
     * @description Initializer for the component
     * @param component
     * @param event
     * @param helper
     */
    doInit: function (component, event, helper) {
        var cClass = component.get("v.class");
        if (cClass['requiresDateAcknowledgement'] === true) {
            component.set('v.isEnabled', false);
        }
    },

    /**
     * @description Increments the count for the ILT class
     * @param component
     * @param event
     * @param helper
     */
    incrementClassCount: function (component, event, helper) {
        var isEnabled = component.get('v.isEnabled');
        if (isEnabled) {
            var count = component.get('v.count');
            var inventory = component.get('v.inventory');
            var classId = component.get('v.class').iltClassId;
            var courseId = component.get('v.courseId');

            if (count < inventory) {
                count++;
                component.set('v.count', count);

                var update = component.getEvent('cartUpdate');
                update.setParams({
                    classId : classId,
                    courseId : courseId,
                    count : count
                });
                update.fire();
            }
        }
    },

    /**
     * @description Decrements the count for the ILT class
     * @param component
     * @param event
     * @param helper
     */
    decrementClassCount: function (component, event, helper) {
        var isEnabled = component.get('v.isEnabled');
        if (isEnabled) {
            var count = Number(component.get('v.count'));
            var classId = component.get('v.class').iltClassId;
            var courseId = component.get('v.courseId');

            if (count > 0) {
                count--;
                component.set('v.count', count);

                var update = component.getEvent('cartUpdate');
                update.setParams({
                    classId : classId,
                    courseId : courseId,
                    count : count
                });
                update.fire();
            }
        }
    },

    /**
     * @description Toggles the value for the acknowledgment checkbox
     * @param component
     * @param event
     * @param helper
     */
    toggleCheckbox : function(component, event, helper) {
        var isChecked = component.find("acknowledgmentCheckbox").get("v.checked");
        component.set("v.isEnabled", isChecked);

        if (isChecked == false) {
            component.set('v.count', 0);

            var classId = component.get('v.class').iltClassId;
            var courseId = component.get('v.courseId');
            var update = component.getEvent('cartUpdate');
            update.setParams({
                classId : classId,
                courseId : courseId,
                count : 0
            });
            update.fire();
        }
    }
})