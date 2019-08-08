({
    doInit : function(component, event, helper) {       
        
        helper.getContext(component, helper, function() {
            var context = component.get('v.context');
            if (context.message != null) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
	                    "title": "Error!",
	                    "message": context.message
	            });
                toastEvent.fire();
            }
            helper.init(component, helper);
        });
        
    },
    doFetchCart : function(component, event, helper){
        if(!component.get("v.ignoreCartEvent")) {
          helper.getCartForCheckout(component, function() {helper.hideSpinner(component);});
        }
    },
    paymentSelected : function(component, event, helper){
        var selected = event.getSource().get('v.value');
        if (selected) {
        	var sfid = event.getSource().get('v.text');
        	var storedPayments = component.get("v.storedPayments");
            for (var idx = 0; idx < storedPayments.length; idx++) {
                if (storedPayments[idx].sfid != sfid) {
                    storedPayments[idx].selected = false;
                }
            }
            component.set("v.storedPayments", storedPayments);
    	}
    },
    removeCartItem : function(component, event, helper) {
        var item = event.getSource().get('v.value');
        // we have to use event.getsource and value since the lightningbutton doesn' support data- attributes
        if (item) {
            helper.clearMessage(component, "errorDiv");
            helper.showSpinner(component);
            helper.removeFromCart(component,
                item,
                function(data) {
                    component.set("v.ignoreCartEvent", true);
                    var appEvent = $A.get("e.c:cc_lx_CartUpdateEventV2");
                    appEvent.fire();
                    helper.getCartForCheckout(component, function() {
                      helper.calculateTotal(component);
                      component.set("v.ignoreCartEvent", false);
                      helper.hideSpinner(component);
                    });
                },
                function(err) {
                    component.set("v.ignoreCartEvent", false);
                    helper.displayMessage(component, "errorDiv", message, "error");
                    console.log(message);
                    helper.hideSpinner(component);
                },
                function() {
                }
            );
        }
    },
    doUpdateCart : function(component, event, helper) {
        helper.updateCart(component, true);
    },
    doPlaceOrder : function(component, event, helper) {
        // save the cart first
        component.set("v.ignoreCartEvent", true);
        helper.updateCart(component, false);
        var cart = component.get("v.cart");
        var deliveryDate = null;
        var deliveryDateControl = component.find("deliveryDate");
        if(deliveryDateControl) {
          deliveryDate = deliveryDateControl.get("v.value");
        }
		
		var storedPayments = component.get("v.storedPayments");

        var data = {
            paymentMethod : component.get("v.paymentMethod"),
            deliveryDate : deliveryDate,
            showDeliveryDate : component.get("v.showDeliveryDate"),
            agreeToTerms : component.get("v.agreeToTerms"),
            showTerms : component.get("v.showTerms"),
            selectedContract : component.get("v.selectedContract"),
			storedPayments: storedPayments,
            poNumber : component.get("v.poNumber"),
            originalPOAmount : component.get("v.originalPOAmount"),
            savePayment : component.get("v.savePayment"),
            cardNumber : component.get("v.cardNumber"),
            cardExpirationDate : component.get("v.cardExpirationDate"),
            cardCode : component.get("v.cardCode"),
            cardName : component.get("v.cardName")
        };
        var isValid = helper.validate(component, data);
        if (isValid) {
            component.set("v.ignoreCartEvent", false);
            helper.placeCartOrder(component, cart.encryptedId, data);
        } else {
          helper.hideSpinner(component);
        }
    },
    increment : function(component, event, helper) {
        var id = event.getSource().get("v.value");
        var cart = component.get("v.cart");
        var cartItem = _.filter(cart.ECartItemsS, function(item) {
            return item.product === id;
        })[0];
        if (cartItem) {
            cartItem.quantity++;
        }

        component.set("v.cart", cart);
    },
    decrement : function(component, event, helper) {
        var id = event.getSource().get("v.value");
        var cart = component.get("v.cart");
        var cartItem = _.filter(cart.ECartItemsS, function(item){
            return item.product === id;
        })[0];
        if (cartItem && cartItem.quantity > 0) {
            cartItem.quantity --;
        }

        component.set("v.cart", cart);
    },
    sortColumnString : function(component, event, helper) {
        var key = $(event.currentTarget).data("key");
        var cart = component.get("v.cart");
        var sortKey = component.get("v.sortKey");
        var reverse = component.get("v.sortReverse");
        reverse = (sortKey == key)&&!reverse;
        var multiplier = reverse ? -1 : 1;
        cart.ECartItemsS.sort(function(a, b) {
            return multiplier*((a[key] > b[key]) - (b[key] > a[key]));
        });
        component.set("v.cart", cart);
        component.set("v.sortKey", key);
        component.set("v.sortReverse", reverse);
    },
    sortColumnProductString : function(component, event, helper) {
        var key = $(event.currentTarget).data("key");
        var cart = component.get("v.cart");
        var sortKey = component.get("v.sortKey");
        var reverse = component.get("v.sortReverse");
        reverse = (sortKey == key)&&!reverse;
        var multiplier = reverse ? -1 : 1;
        cart.ECartItemsS.sort(function(a, b) {
            return multiplier*((a.productItem[key] > b.productItem[key]) - (b.productItem[key] > a.productItem[key]));
        });
        component.set("v.cart", cart);
        component.set("v.sortKey", key);
        component.set("v.sortReverse", reverse);
    },
    sortColumnNumber : function(component, event, helper) {
        var key = $(event.currentTarget).data("key");
        var cart = component.get("v.cart");
        var sortKey = component.get("v.sortKey");
        var reverse = component.get("v.sortReverse");
        reverse = (sortKey == key)&&!reverse;
        var multiplier = reverse ? -1 : 1;
        cart.ECartItemsS.sort(function(a, b) {
            return multiplier*(parseFloat(a[key]) - parseFloat(b[key]));
        });
        component.set("v.cart", cart);
        component.set("v.sortKey", key);
        component.set("v.sortReverse", reverse);
    },
    paymentSelection : function(component, event, helper) {
        var selectedItem = event.currentTarget;
        var selectedTab = selectedItem.dataset.id;
        component.set("v.paymentMethod", selectedTab);
        if (component.get("v.allowContract")) {
            helper.hide(component, 'contract');
        }
        if (component.get("v.allowPO")) {
            helper.hide(component, 'po');
        }
        if (component.get("v.allowCreditCard")) {
            helper.hide(component, 'cc');
        }
        helper.show(component, selectedTab);
    },
    selectContract : function(component, event, helper) {
        var element = event.getSource ? event.getSource().getElement() : event.target;
        var id = $(event.currentTarget).data("id");
        component.set("v.selectedContract", id);
        $(".cclx-checkbox").each(function() {
            var thisId = $(this).data("id");
            if (thisId != id) {
                this.checked = false;
            }
        });
    },
    shippingChanged : function(component, event, helper) {
        helper.totalShipping(component);
    },
    editAddress : function(component, event, helper) {
      var isEditing = component.get("v.editingAddress");
      if(isEditing) {
        helper.saveAddresses(component);
        component.find("editAddressButton").set("v.label", "EDIT");
        component.set("v.editingAddress", false);
      } else {
        component.find("editAddressButton").set("v.label", "UPDATE");
        component.set("v.editingAddress", true);
      }
    },
    onDateSelected : function(component, event, helper) {
      helper.validateDate(component, true);
    },
    goToRecord : function(component, event, helper){
        var id = $(event.currentTarget).data("id");
        helper.goToRecord(component, id);
    },
    showModal: function(component, event, helper) {
        var popupDiv = component.find("termsPopupDiv");
        $A.util.removeClass(popupDiv, 'slds-hide');
        $A.util.addClass(popupDiv, 'slds-show');
        var el = popupDiv.getElement();
        el.setAttribute('aria-hidden', 'false');

    },
    cancelModal: function(component, event, helper) {
        var popupDiv = component.find("termsPopupDiv");
        $A.util.removeClass(popupDiv, 'slds-show');
        $A.util.addClass(popupDiv, 'slds-hide');
        var el = popupDiv.getElement();
        el.setAttribute('aria-hidden', 'true');
    }
})