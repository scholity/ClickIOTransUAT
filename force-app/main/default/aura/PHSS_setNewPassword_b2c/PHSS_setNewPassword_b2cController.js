/**
 * Created by bjarmolinski on 2019-06-13.
 */
({
    handleSetPassword: function(component, event, helper) {
        var checkResult = helper.validatePassword(component);
        if (checkResult) {
            helper.setPassword(component);
        }
    }
})