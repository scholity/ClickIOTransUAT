({
    goToDetail: function (cmp, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
            helper.goToDetail(params.itemId);
        }
    },
    goToURL: function (cmp, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
            helper.goToURL(params.path);
        }
    },
    showMe: function (cmp, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
            helper.showMessage(params.title, params.message, params.type);
        }
    },
    doRequest: function (cmp, event, helper) {
        var params = event.getParam('arguments');
        helper.doRequest(cmp, params.action, params.callBack, params.callBackFail);
    },
    getSearchParam: function (cmp, event, helper) {
        var params = event.getParam('arguments');
        helper.getSearchParam(params.cmpContext);
    },
    getRecordIdParam: function (cmp, event, helper) {
        var params = event.getParam('arguments');
        helper.getRecordIdParam(params.cmpContext);
    },
    getStatusParam: function (cmp, event, helper) {
        var params = event.getParam('arguments');
        helper.getStatusParam(params.cmpContext);
    },
    fadeColorHexToRgbA: function (cmp, event, helper) {
        var params = event.getParam('arguments');
        helper.fadeColorHexToRgbA(params.cmpContext);
    },
    goBack: function(cmp, event, helper) {
        window.history.back();
    }
})