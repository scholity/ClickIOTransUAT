({
	getContext: function (component, helper, callback) {
    	var action = component.get("c.getInitialContext");
        action.setParams({
            "componentOnObject": component.get("v.componentOnObject"),
            "recordId": component.get("v.recordId"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {       
                // set thecontext so that we can send it in future apex calls
        		component.set("v.context", response.getReturnValue());
                if (callback) {
                    callback();
                }
            }
        });
        $A.enqueueAction(action);
	},
	ccrzAction: function(component, actionName, params, success, error, final) {
		var action = component.get(actionName);
		action.setParams(this.constructContext(params));
		var helper = this;

		action.setCallback(this, function(response) {
			var state = response.getState();
			if (component.isValid() && state === "SUCCESS") {
				if (success) {
					var data = response.getReturnValue();
					success(data);
				}
			} else if (state === "ERROR") {
				var errors = response.getError();
				var message = "Unknown error";
				if (errors) {
					if (errors[0] && errors[0].message) {
						message = errors[0].message;
					} else if (errors[0] && errors[0].pageErrors[0] && errors[0].pageErrors[0].message) {
						message = errors[0].pageErrors[0].message;
					} else if (errors[0] && errors[0].fieldErrors) {
						for (var prop in errors[0].fieldErrors) {
							if (errors[0].fieldErrors[prop][0].message) {
								console.message += errors[0].fieldErrors[prop][0].message + ' ';
							}
						}
					}
				}
				console.log("Error message: " + message);
				if (error) {
					error(errors, message);
				}
			}
			if (final) {
				final(response);
			}
		});
		$A.enqueueAction(action);
	},
	showError: function(error) {
		var toastEvent = $A.get("e.force:showToast");
		console.log(toastEvent);
		toastEvent.setParams({
			"title": "Error",
			"message": error
		});
		toastEvent.fire();
	},
	showMessage: function(message, title) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"title": title,
			"message": message
		});
		toastEvent.fire();
	},
	getActiveCart: function(component, success, error, final) {
		this.ccrzAction(component,
			'c.getCart', {},
			success,
			error,
			final
		);
	},
	addToCart: function(component, id, sku, qty, success, error, final) {
		var item = {
			id: id,
			sku: sku,
			quantity: qty
		};

		this.ccrzAction(component,
			'c.addToCart', {
				data: JSON.stringify(item)
			},
			success,
			error,
			final
		);
	},
	removeFromCart: function(component, item, success, error, final) {
		this.ccrzAction(component,
			'c.removeFromCart', {
				"item": item
			},
			success,
			error,
			final
		);
	},
	showSpinner: function(component, event, helper) {
		var spinner = component.find("spinner");
		$A.util.removeClass(spinner, 'slds-hide');
	},
	hideSpinner: function(component, event, helper) {
		var spinner = component.find("spinner");
		$A.util.addClass(spinner, 'slds-hide');
	},
	displayMessage: function(component, theDiv, message, severity) {
		$A.createComponents([
				["ui:message", {
					"severity": severity,
				}],
				["ui:outputText", {
					"value": message
				}]
			],
			function(components, status) {
				if (status === "SUCCESS") {
					var messageComp = components[0];
					var outputText = components[1];
					messageComp.set("v.body", outputText);
					var div1 = component.find(theDiv);
					div1.set("v.body", messageComp);
				}
			}
		);
	},
	clearMessage: function(component, theDiv) {
		var div1 = component.find(theDiv);
		if(div1){
		div1.set("v.body", []);
		}
	},
	goToRecord: function(component, id) {
		var params = component.get("v.queryString");
		var networkPrefix = component.get("v.networkUrlPrefix");
		// This is an unfortunate way we have to deal with this for now until navigateToSObject gets fixed.
        if (networkPrefix) {
			window.location = "/" + networkPrefix + "/" + id + params;
        }
        else{
			window.location = "/" + id + params;            
        }
	},
	constructContext : function(obj){
		var ctx = {};
		var copy = {};
	    if (null != obj && "object" == typeof obj){
			var copy = obj.constructor();
			for (var attr in obj) {
				if (obj.hasOwnProperty(attr)){
					if('cclxCtx' == attr){
						ctx = obj[attr];
					}else{
						copy[attr] = obj[attr];
					}
				}
		    }
		}

		this.copyQS(ctx,'userIsoCode','lxcurr');
		this.copyQS(ctx,'userLocale','lxlcl');
		this.copyQS(ctx,'portalUserId','lxpid');
		this.copyQS(ctx,'effAccountId','lxea');
		this.copyQS(ctx,'priceGroupId','lxpgid');
		this.copyQS(ctx,'currentCartId','lxcid');

		copy['ctx'] = JSON.stringify(ctx);
		return copy;
	},
	copyQS : function(ctx,p,q){
		if(!ctx[p])ctx[p]=this.getQSParameter(q);
	},
	getQSParameter: function(name) {
		return (window.location.search.match(new RegExp('[?&]' + name + '=([^&]+)')) || [, null])[1];
	},

	getNetworkInfo: function(component, helper) {
		this.ccrzAction(component,
			'c.getCommunityUrl', {
			},
			function(data) { component.set("v.networkUrlPrefix", data.networkUrlPrefix) },
			function(err) { console.log(err) },
			function() {}
		);
	},
	getQueryString: function(component, helper) {
		component.set("v.queryString", window.location.search);
	}
})