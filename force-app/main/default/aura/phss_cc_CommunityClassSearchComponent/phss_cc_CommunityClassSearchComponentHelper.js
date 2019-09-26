({
    /**
     * @description Adds a class to the cart
     * @param component
     */
    doAddToCart : function(component) {
        var result = this.isCartValid(component);
        if (result.success) {
            var action = component.get('c.addClassesToCart');
            action.setParams({
                opportunityId : component.get('v.recordId'),
                items         : JSON.stringify(result.cartItems)
            });
            action.setCallback(this, function(response) {
                if ('SUCCESS' === response.getState()) {
                    this.showToast('success', 'Classes added to cart', 'The community classes have been successfully added to your cart.');
                    component.set('v.classes', {});
                    component.set('v.cart', {});
                }
                else {
                    this.showToast('error', 'Failed to add item(s) to cart', '');
                }
                component.set('v.showSpinner', false);
            });
            $A.enqueueAction(action);
            component.set('v.showSpinner', true);
        }
        else {
            this.showToast('error', 'Cannot add to cart', result.error);
        }
    },

    fireProductSearchEvent : function(searchCriteria) {
        var searchTerm = searchCriteria.searchTerm;
        var searchEvent = $A.get('e.c:phss_cc_ProductSearchEvent');
        searchEvent.setParams({ 'searchTerm' : searchTerm });
        searchEvent.fire();
    },

    /**
     * @description Searches for classes matching the user's input
     * @param component
     */
	doSearch : function(component) {
		var result = this.isUserInputValid(component);
		if (result.success) {
		    var shouldWarnUser = this.needsDateWarning(result.startDate);
		    if (shouldWarnUser) {
                alert('HISTORICAL SEARCH\n\nYour search includes dates before today.');
            }

		    this.fireProductSearchEvent(result);

			var action = component.get('c.classSearch');

			action.setParams({
				opportunityId : component.get('v.recordId'),
				searchTerm    : result.searchTerm,
				startDateStr  : JSON.stringify(result.startDate),
				endDateStr    : JSON.stringify(result.endDate),
				city          : result.city,
				state         : result.state,
				postalCode    : result.postalCode,
				range         : result.range
			});

			action.setCallback(this, function (response) {
				if ('SUCCESS' === response.getState()) {
					var returnValue = response.getReturnValue();
					component.set('v.classes', returnValue.courses);
					component.set('v.cart', {});
				}
                else {
                    this.showToast('error', 'Failed to perform search', result.error);
                }
                component.set('v.showSpinner', false);
			});
			$A.enqueueAction(action);
			component.set('v.showSpinner', true);
		}
		else {
			this.showToast('error', 'Cannot perform search', result.error);
		}
	},

    getDateString : function(d) {
        var month = '' + (d.getMonth() + 1),
            day = '' + d.getDate(),
            year = d.getFullYear();
        if (month.length < 2) month = '0' + month;
        if (day.length < 2) day = '0' + day;
        var dateStr = [year, month, day].join('-');
        return dateStr;
    },

    /**
     * @description Validates the state of the cart
     * @param component
     * @returns {{success: boolean}}
     */
    isCartValid : function(component) {
        var result = { success: false };
        var cartItems = [];
        var cart = component.get('v.cart');

        Object.keys(cart).forEach(function(key) {
            var c = cart[key];
            if (typeof c.courseId !== 'undefined' && typeof c.classId !== 'undefined' && c.count > 0) {
                var item = {};
                item['courseId'] = c.courseId;
                item['classId'] = c.classId;
                item['count'] = c.count;
                cartItems.push(item);
            }
        });

        if (cartItems.length > 0) {
            result = {
                success : true,
                cartItems : cartItems
            };
        }
        else {
            result.error = 'There are no items to add to the cart.';
        }

        return result;
    },

    /**
     * @description Validates the user's input
     * @param component
     * @returns {*}
     */
	isUserInputValid : function(component) {
        var result = { success: false };

        var searchTerm = component.find('searchTermField').get('v.value');
        if (searchTerm === undefined || searchTerm == null || searchTerm.trim() === '') {
        	result.error = 'Please provide a search term before attempting to search.';
        	return result;
		}

        var searchStr = new String(searchTerm);
        if (searchStr.length < 3) {
            result.error = 'Please provide a search term that is at least 3 characters long.';
            return result;
        }

        var endDate = component.find('endDateField').get('v.value');
        var startDate = component.find('startDateField').get('v.value');
        if (!startDate || !endDate || endDate < startDate) {
            result.error = 'Please specify a start and end date before attempting to search.';
            return result;
        }

        var state = component.find('stateField').get('v.value');
        var city = component.find('cityField').get('v.value');
        var postalCode = component.find('postalCodeField').get('v.value');
        if (!(city && state) && !postalCode) {
            result.error = 'Please specify a city and state OR a zip code before attempting to search.';
            return result;
        }

        result = {
            success    : true,
            searchTerm : searchTerm.trim(),
            startDate  : startDate,
            endDate    : endDate,
            city       : city,
            state      : state,
            postalCode : postalCode,
			range      : component.find('range').get('v.value')
        };

		return result;
    },

    needsDateWarning : function(date) {
	    var now = new Date();
	    var today = this.getDateString(now);
        return (date < today);
    },

    /**
     * @description Shows a toast message
     * @param type
     * @param title
     * @param message
     */
	showToast : function(type, title, message) {
		var toastEvent = $A.get('e.force:showToast');
		if (toastEvent) {
            toastEvent.setParams({
                'message' : message,
                'mode'    : 'dismissible',
                'title'   : title,
                'type'    : type
            });
            toastEvent.fire();
        }
        else {
        	alert(title + '.\n' + message + ' [' + type + ']');
		}
	},

    /**
     * @description Updates the count for a class
     * @param component
     * @param classId
     * @param cartItem
     */
	updateCartWithItem : function(component, classId, cartItem) {
        var cart = component.get('v.cart');
        var count = cartItem.count;
        if (count == 0) {
			delete cart[classId];
		}
		else {
            cart[classId] = cartItem;
        }
        component.set('v.cart', cart);
	}

})