({
    goToDetail: function (itemId) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": itemId,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
    goToURL: function(path) {
        var navEvt = $A.get("e.force:navigateToURL");
        navEvt.setParams({
            "url": path,
            "isredirect": false
        });
        navEvt.fire();
    },
    showMessage: function(title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        if (toastEvent) {
            toastEvent.setParams({
                "title":    title,
                "message":  message,
                "type":     $A.util.isEmpty(type) ? 'info' : type
            });
            toastEvent.fire();
        } else {
            alert(title + ': ' + message);
        }
    },
    doRequest: function (cmp, action, callBack, callBackFail) {
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();

                if (result.status === 'SUCCESS') {
                    callBack(result);

                    cmp.set("v.answerSuccess", true);

                } else if (result.status === 'ACCESS DENIED') {
                    this.showMessage($A.get("$Label.redwing.ALMS_Insufficient_Access"), result.message);
                    cmp.set("v.answerSuccess", true);

                } else if (result.status === 'CUSTOM ERROR') {
                    this.showMessage("", result.message);
                    cmp.set("v.answerSuccess", true);

                } else if (result.status === 'VALIDATION_ERROR') {
                    // TODO: Change to modalCmp
                    // this.showMessage("VALIDATION ERROR", result.message);
                    console.log('VALIDATION ERROR');
                    console.log(result.message);

                    if (callBackFail) {
                        callBackFail(result);
                    }

                    cmp.set("v.answerSuccess", true);
                } else {
                    if (callBackFail) {
                        callBackFail(result);
                        cmp.set("v.answerSuccess", true);
                    } else {
                        this.showMessage(cmp.get('v.unknown_error'), result.message);
                        cmp.set("v.answerSuccess", false);
                    }
                }

            } else {
                this.showMessage(cmp.get('v.unknown_error'), $A.get("$Label.redwing.ALMS_Generic_Error_Message"));
                cmp.set("v.answerSuccess", false);
                if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            }

            cmp.set('v.numberOfRequests', cmp.get('v.numberOfRequests') - 1);
        });

        cmp.set('v.numberOfRequests', cmp.get('v.numberOfRequests') + 1);
        $A.enqueueAction(action);
    },
    getSearchParam: function (cmp) {
        var searchString = cmp.get('v.searchString');
        if (searchString !== 'Disabled' && searchString !== 'Internal') {
            if ($A.util.isEmpty(searchString)) {
                cmp.set("v.searchStr", this.getUrlParam('searchString'));
            } else {
                cmp.set("v.searchStr", searchString);
            }
        }
    },
    getRecordIdParam: function (cmp) {
        var recordId    = cmp.get('v.recordId');
        var urlRecordId = this.getUrlParam('urlRecordId');
        var urlRedirect = this.getUrlParam('urlRedirect');
        if ($A.util.isEmpty(recordId) && !$A.util.isEmpty(urlRecordId) && recordId !== urlRecordId
            && ((window.location.pathname.indexOf(urlRedirect) !== -1) || (window.location.hash.indexOf(urlRedirect) !== -1))) {
            cmp.set("v.itemId", urlRecordId);
        } else {
            cmp.set("v.itemId", recordId);
        }
    },
    getStatusParam: function (cmp) {
        var status = cmp.get('v.learningStatus');
        var urlRedirect = this.getUrlParam('urlRedirect');
        if ((window.location.pathname.indexOf(urlRedirect) === -1) && (window.location.href.indexOf('/' + urlRedirect + '?') === -1)) {
            window.location.search = '';
        }
        if (status === 'all') {
            status = this.getUrlParam('lStatus');
            if (status !== '') {
                if (this.verifyStatus(status) && status !== 'all') {
                    cmp.set('v.learningStatus', status);
                }
            }
        } else {
            cmp.set('v.ignoreStatusEvents', true);
        }
    },
    getUrlParam: function (keyString) {
        var param = '';
        var parts = window.location.href.replace(
            /[?&]+([^?=&]+)=([^&]*)/gi,
            function(m, key, value) {
                if (key === keyString) {
                    param = value;
                }
            }
        );
        return encodeURIComponent(param);
    },
    fadeColorHexToRgbA: function(cmp) {
        var c;
        var hex = cmp.get("v.fadeColorHex");
        if (/^#([A-Fa-f0-9]{3}){1,2}$/.test(hex)) {
            c= hex.substring(1).split('');
            if(c.length === 3){
                c= [c[0], c[0], c[1], c[1], c[2], c[2]];
            }
            c= '0x'+c.join('');
            cmp.set("v.fadeColorRgba", 'rgba('+[(c>>16)&255, (c>>8)&255, c&255].join(',')+',0.7)');
        }
    },
    verifyStatus: function (status) {
        return (status === 'all' || status === 'notStarted' || status === 'inProgress' || status === 'completed' || status === 'notRegistered');
    }
})