({
	init: function (component, helper) {
		var termsTextLabel = component.get("v.termsTextLabel");
		var termsText = "";
		if (!termsTextLabel || termsTextLabel == "cclxTerms") {
			termsText = $A.get("$Label.cclxrep.cclxTerms");
		} else {
			termsText = $A.getReference("$Label" + ".c." + termsTextLabel)
		}

		helper.getCartForCheckout(component, function () {
			helper.getAddresses(component, function () {
				component.set("v.editingAddress", false);
				component.set("v.termsText", termsText);
				if (component.get("v.showShipping")) {
					helper.getShippingMethods(component);
				}
				else {
					helper.totalShipping(component);
					helper.hideSpinner(component);
				}
			});
		});

		helper.getAccountContracts(component);
		helper.getMyStoredPayments(component);
		helper.getCyberPaymentTypes(component);
		if (component.get("v.allowContract")) {
			component.set("v.paymentMethod", 'contract');
		}
		else if (component.get("v.allowPO")) {
			component.set("v.paymentMethod", 'po');
		}
		else if (component.get("v.allowCreditCard")) {
			component.set("v.paymentMethod", 'cc');
		}
	},

	getCartForCheckout: function (component, callback) {
		var helper = this;
        // send the context to SF while making remote calls
        var context = component.get("v.context");
        //var callContext = {effAccountId: context.accountId, portalUserId: context.userId};
        
		this.clearMessage(component, "errorDiv");
		this.showSpinner(component);
		this.ccrzAction(component,
			'c.getCart',
			{cclxCtx: context},
			function (data) {
				component.set("v.cart", data);
				component.set("v.renderComplete",true);
				if (data != null) {
					component.set("v.note", data.note);
					component.set("v.deliveryDate", data.requestDate);
				}
				var mainCmp = component.find("mainCartBody");
				$A.util.addClass(mainCmp, 'chromeRerender');
				var footer = component.find("mainCartFooter");
				$A.util.addClass(footer, 'chromeRerender');
			},
			function (errors, message) {
				helper.displayMessage(component, "errorDiv", message, "error");
			},
			function () {
				if (callback) {
					callback();
				}
			}
		);
	},
	getShippingMethods: function (component) {
		var helper = this;
        // send the context to SF while making remote calls
        var context = component.get("v.context");
        //var callContext = {effAccountId: context.accountId, portalUserId: context.userId};
        
		var addresses = [component.get("v.addresses")];
		var cart = component.get("v.cart");
		var cartId = null;
		if (cart != 'undefined' && cart != null) {
			cartId = cart.sfid;
		}

		var shippingAddress = {
			'postalCode': addresses.ShippingPostalCode,
			'stateISOCode': addresses.ShippingStateISOCode,
			'countryISOCode': addresses.ShippingCountryISOCode,
		}

		if (cartId != null) {
			component.set("v.selectedShippingMethod", cart.shipMethod);
			component.set("v.selectedShippingPrice", cart.shipAmount);
			this.ccrzAction(component,
				'c.getShippingOptions',
				{
                    cclxCtx: context,
					cartId: cartId,
					shippingAddress: JSON.stringify(shippingAddress)
				},
				function (data) {
					var foundShipping = false;
					if (Array.isArray(data) && data.length > 0) {
						for (var i = 0; i < data.length; i++) {
							if (data[i].uniqueId == cart.shipMethod) {
								data[i].isSelected = true;
								foundShipping = true;
							}
						}
					}
					component.set("v.shippingOptions", data);
					if (foundShipping) {
						component.find("shippingSelect").set("v.value", cart.shipMethod);
					}
					if (data.length > 0) {
						helper.totalShipping(component);
					}
				},
				function (errors, message) {
					helper.displayMessage(component, "errorDiv", message, "error");
				},
				function () {
					helper.totalShipping(component);
					helper.hideSpinner(component);
				});
		}
	},

	totalShipping: function (component) {
		var helper = this;
		if (component.get("v.showShipping")) {
			var selectedShipping = component.find("shippingSelect");
			var selectedId = selectedShipping.get("v.value");
			component.set("v.selectedShippingMethod", selectedId);
			var shippingOptions = component.get("v.shippingOptions");
			var price = 0;
			if (Array.isArray(shippingOptions) && shippingOptions.length > 0) {
				price = shippingOptions[0].price; // default for before the first render
			}
			for (var i = 0; i < shippingOptions.length; i++) {
				if (shippingOptions[i].uniqueId == selectedId) {
					price = shippingOptions[i].price;
				}
			}
			component.set("v.selectedShippingPrice", price);
		} else {
			component.set("v.selectedShippingMethod", "");
			component.set("v.selectedShippingPrice", 0);
		}

		helper.calculateTotal(component);
	},

	calculateTotal: function (component) {
		var cart = component.get("v.cart");
		if (cart != null) {
			var cartTotal = cart.subtotalAmount;
			var shippingTotal = component.get("v.selectedShippingPrice");
			var total = cartTotal + shippingTotal;
			component.set("v.calculatedTotal", total);
		}
	},

	updateCart: function (component, refreshCart) {
		var items = [];
		var cart = component.get("v.cart");
		var cartId = cart.encryptedId;
		for (var i = 0; i < cart.ECartItemsS.length; i++) {
			var item = cart.ECartItemsS[i];
			items.push({
				sfid: item.sfid,
				id: item.product,
				sku: item.productItem.SKU,
				quantity: item.quantity
			})
		}
		var note = component.get("v.note");
		var shippingMethod = component.get("v.selectedShippingMethod");
		var shippingPrice = component.get("v.selectedShippingPrice");
		var deliveryDateStr = component.get("v.deliveryDate");
        var deliveryDate = null;
        if (deliveryDateStr) {
			var deliveryDateParts = deliveryDateStr.split(/\D/);
            var deliveryDateYear = deliveryDateParts[0];
            var deliveryDateMonth = deliveryDateParts[1];
            var deliveryDateDay = deliveryDateParts[2];
            var deliveryDate = new Date(deliveryDateStr);
            deliveryDate = {month: deliveryDateMonth, day: deliveryDateDay, year: deliveryDateYear};
    	}
		var data = {
			note: note,
			shippingAmount: shippingPrice,
			shippingMethod: shippingMethod,
			deliveryDate: deliveryDate
		};
		var helper = this;
        // send the context to SF while making remote calls
        var context = component.get("v.context");
        //var callContext = {effAccountId: context.accountId, portalUserId: context.userId};
        
		this.clearMessage(component, "errorDiv");
		this.showSpinner(component);
		this.ccrzAction(component,
			'c.modifyCart',
			{
                cclxCtx: context,
				cartId: cartId,
				itemsJson: JSON.stringify(items),
				dataJson: JSON.stringify(data)
			},
			function (data) {
				component.set("v.ignoreCartEvent", true);
				if (refreshCart) {
					helper.getCartForCheckout(component, function () {
						helper.calculateTotal(component);
						helper.hideSpinner(component);
					});
				} else {

				}
				var appEvent = $A.get("e.c:cc_lx_CartUpdateEventV2");
				appEvent.fire();
				component.set("v.ignoreCartEvent", false);
			},
			function (errors, message) {
				helper.displayMessage(component, "errorDiv", message, "error");
				console.log(message);
				helper.hideSpinner(component);
			},
			function () {

			}
		);
	},
	validate: function (component, data) {
		this.clearMessage(component, "errorDiv");
		var isValid = true;
		var errorMessage = "";
		var storedPaymentSelected = false;
		if (data.storedPayments) {
			for (var idx = 0; idx < data.storedPayments.length; idx++) {
				if (data.storedPayments[idx].selected) {
					storedPaymentSelected = true;
				}
			}
		}
		if (!storedPaymentSelected && data.paymentMethod == 'contract') {
			if (!data.selectedContract) {
				isValid = false;
				errorMessage = $A.get("$Label.cclxrep.cclxCheckoutNoContractSelectedError");
			}
		}
		if (!storedPaymentSelected && data.paymentMethod == 'po') {
			if (!data.poNumber) {
				if (!isValid) {
					errorMessage += "\n"
				}
				isValid = false;
				errorMessage += $A.get("$Label.cclxrep.cclxCheckoutNoPOError");
			}
			if (data.savePayment) {
				if (!data.originalPOAmount) {
					if (!isValid) {
						errorMessage += "\n"
					}
					isValid = false;
					errorMessage += "Please enter Original PO Amount.";
				}
				else if (data.originalPOAmount < component.get("v.calculatedTotal")) {
					if (!isValid) {
						errorMessage += "\n"
					}
					isValid = false;
					errorMessage += "Original PO Amount should be greater or equal to cart total.";
				}
			}
		}
		if (!storedPaymentSelected && data.paymentMethod == 'cc') {
			if (!data.cardNumber || !data.cardExpirationDate || !data.cardCode || !data.cardName) {
				if (!isValid) {
					errorMessage += "\n"
				}
				isValid = false;
				errorMessage += "Credit Card data is missing.";
			}
		}
		if (data.showTerms) {
			if (!data.agreeToTerms) {
				if (!isValid) {
					errorMessage += "\n"
				}
				isValid = false;
				errorMessage += $A.get("$Label.cclxrep.cclxCheckoutTermsNotSelectedError");

			}
		}
		if (data.showDeliveryDate) {
			if (!data.deliveryDate) {
				if (!isValid) {
					errorMessage += "\n"
				}
				isValid = false;
				errorMessage += $A.get("$Label.cclxrep.cclxCheckoutNoDeliveryDateSelectedError");
			}
			if (!this.validateDate(component, false)) {
				if (!isValid) {
					errorMessage += "\n"
				}
				isValid = false;
				errorMessage += $A.get("$Label.cclxrep.cclxCheckoutDeliveryDateRangeError");
			}
		}

		if (!isValid) {
			this.displayMessage(component, "errorDiv", errorMessage, "error");
		}
		return isValid;
	},
	placeCartOrder: function (component, cartId, data) {
		var helper = this;
        // send the context to SF while making remote calls
        var context = component.get("v.context");
        //var callContext = {effAccountId: context.accountId, portalUserId: context.userId};
        
		this.clearMessage(component, "errorDiv");
		this.showSpinner(component);
		this.saveAddresses(component, function () {
			helper.ccrzAction(component,
				'c.placeOrder',
				{
                    cclxCtx: context,
					cartId: cartId,
					data: JSON.stringify(data)
				},
				function (data) {
					var appEvent = $A.get("e.c:cc_lx_CartUpdateEventV2");
					appEvent.fire();
					helper.goToRecord(component, data);
				},
				function (errors, message) {
					helper.displayMessage(component, "errorDiv", message, "error");
					console.log(message);
					helper.hideSpinner(component);
				},
				function () {
				}
			);
		})
	},
	getAccountContracts: function (component) {
		var helper = this;
        // send the context to SF while making remote calls
        var context = component.get("v.context");
        //var callContext = {effAccountId: context.accountId, portalUserId: context.userId};
        
		this.ccrzAction(component,
			'c.getContracts',
			{cclxCtx: context},
			function (data) {
				component.set("v.contracts", data);
			},
			function (errors, message) {
				console.log(message);
			},
			function () {
			}
		);
	},
	getMyStoredPayments: function (component) {
		var helper = this;
        // send the context to SF while making remote calls
        var context = component.get("v.context");
        //var callContext = {effAccountId: context.accountId, portalUserId: context.userId};
        
		this.ccrzAction(component,
			'c.getStoredPayments',
			{cclxCtx: context},
			function (data) {
				component.set("v.storedPayments", data);
			},
			function (errors, message) {
				console.log(message);
			},
			function () {
			}
		);
	},
	getCyberPaymentTypes: function (component) {
		var helper = this;
        // send the context to SF while making remote calls
        var context = component.get("v.context");
        //var callContext = {effAccountId: context.accountId, portalUserId: context.userId};
        
		this.ccrzAction(component,
			'c.getCyberSourcePaymentTypes',
			{cclxCtx: context},
			function (data) {
				component.set("v.cyberSourcePaymentTypes", data);
			},
			function (errors, message) {
                console.log('In getCyberPaymentTypes:' + message);
			},
			function () {
			}
		);
	},
	getAddresses: function (component, callback) {
		var cart = component.get("v.cart");
		if (cart != null) {
			var cartId = cart.encryptedId;
			var helper = this;
            //added effective account and portaluserid in the context to set the account name instead of ccanonymous
        //var context = {effAccountId: '0015B00000TRhU5QAL', portalUserId: '0055B000001VGLOQA4'};
        //var context = {effAccountId: '0015B00000TRhU5QAL', portalUserId: '0055B000001V7xF'};
        	var context = component.get("v.context");
        	//var callContext = {effAccountId: context.accountId, portalUserId: context.userId};
			this.ccrzAction(component,
				'c.getAddresses',
				{
                    // send the context to apex class.
                    cclxCtx: context,
					billingId: cart.billTo,
					shippingId: cart.shipTo
				},
				function (data) {
					if (data) {
						component.set("v.addresses", data.addresses);
						component.set("v.accountName", data.accountName);
					}
				},
				function (errors, message) {
					console.log(message);
				},
				function () {
					if (callback) {
						callback();
					}
				}
			);
		} else {
			if (callback) {
				callback();
			}
		}
	},
	saveAddresses: function (component, callback) {
		var helper = this;
        var context = component.get("v.context");
        //var callContext = {effAccountId: context.accountId, portalUserId: context.userId};

		var addresses = component.get("v.addresses");
		var cart = component.get("v.cart");
		var cartId = cart.encryptedId;

		this.ccrzAction(component,
			'c.saveAddresses',
			{
                cclxCtx: context,
				addresses: addresses,
				cartId: cartId
			},
			function (data) {
				// success
			},
			function (errors, message) {
				console.log(message);
			},
			function () {
				if (callback) {
					callback(component);
				}
			}
		);

	},
	validateDate: function (component, showInlineError) {
		var helper = this;

		var dateElement = component.find("deliveryDate");
		var selectedDate = new Date(dateElement.get("v.value"));
		var todaysDate = new Date();

		if (selectedDate !== "Invalid Date" && !isNaN(selectedDate)) {
			if (selectedDate <= todaysDate) {
				var errMsg = $A.get("$Label.cclxrep.cclxCheckoutDeliveryDateRangeError");
				dateElement.set("v.errors", [errMsg]);
				if (showInlineError) {
					helper.displayMessage(component, "dateError", errMsg, "error");
				}
				return false;
			}
			else {
				dateElement.set("v.errors", null);
				helper.clearMessage(component, "dateError");
				return true;
			}
		}
	},
	show: function (component, name) {
		var content = component.find(name + "Content");
		$A.util.removeClass(content, 'slds-hide');
		$A.util.addClass(content, 'slds-show');
		var tab = component.find(name + "Tab");
		$A.util.addClass(tab, 'slds-active');
		var el = tab.getElement();
		el.setAttribute('aria-selected', 'true');
	},
	hide: function (component, name) {
		var content = component.find(name + "Content");
		$A.util.removeClass(content, 'slds-show');
		$A.util.addClass(content, 'slds-hide');
		var tab = component.find(name + "Tab");
		$A.util.removeClass(tab, 'slds-active');
		var el = tab.getElement();
		el.setAttribute('aria-selected', 'false');
	}
})