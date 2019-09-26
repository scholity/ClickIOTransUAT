({
    doInit : function(component, event, helper) {
        component.set('v.ranges', [{'label':'5 miles',  'value':'5'},
            {'label':'10 miles', 'value':'10'},
            {'label':'15 miles', 'value':'15'},
            {'label':'25 miles', 'value':'25'},
            {'label':'50 miles', 'value':'50'}]);

        var d = new Date();
        var today = helper.getDateString(d);
        component.find('startDateField').set('v.value', today);

        d.setMonth(d.getMonth() + 1);
        var nextMonth = helper.getDateString(d);
        component.find('endDateField').set('v.value', nextMonth);
    },

    addToCartButtonPressed : function(component, event, helper) {
        helper.doAddToCart(component);
    },

    handleProductSearchIsReady: function(component, event, helper) {
        var result = helper.isUserInputValid(component);
        if (result.success) {
            helper.fireProductSearchEvent(result);
        }
    },

    searchButtonPressed : function(component, event, helper) {
        helper.doSearch(component);
    },

    updateCart : function(component, event, helper) {
        var courseId = event.getParam('courseId');
        var classId = event.getParam('classId');
        var count = event.getParam('count');
        var cartItem = { courseId: courseId, classId: classId, count: count };
        helper.updateCartWithItem(component, classId, cartItem);
    }
})