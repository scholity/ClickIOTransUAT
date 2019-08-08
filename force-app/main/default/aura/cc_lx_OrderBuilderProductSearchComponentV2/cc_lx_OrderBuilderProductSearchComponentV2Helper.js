({
    // SA 5 search button clicked
    getProducts : function(component, query) {
        var helper = this;
        // send the context to SF while making remote calls
        var context = component.get("v.context");
        //var callContext = {effAccountId: context.accountId, portalUserId: context.userId};
        
        this.clearMessage(component, "errorDiv");
        this.showSpinner(component);
        this.ccrzAction(component,
            'c.doProductSearch',
            {
                text: query,
                // SA 7 pass context
                cclxCtx: context
            },
            function(data) {
                if(data && data.length && data.length > 0) {
                    helper.setQuantity(component, data);
                    var pageLength = component.get("v.length");
                    component.set("v.pageStart",0);
                    component.set("v.pageEnd",pageLength);
                    component.set("v.productList", data);
                } else {
                    helper.displayMessage(component, "errorDiv", $A.get("$Label.cclxrep.cclxOBProdSrchNoResults"), "error");
                    component.set("v.pageStart",0);
                    component.set("v.pageEnd",0);
                    component.set("v.productList", null);
              }
              helper.setButtonStatus(component);
            },
            function(errors, message) {
                helper.displayMessage(component, "errorDiv", message, "error");
                console.log(message);
            },
            function() {
                helper.hideSpinner(component);
            }
        );
    },
	goFirst : function( component,event){
		var pageLength = component.get("v.length");
		component.set("v.pageStart",0);
		component.set("v.pageEnd",pageLength);
		this.setButtonStatus(component);
	},
	goPrev : function(component,event){
		var pageLength = component.get("v.length");
		var pStart = component.get("v.pageStart");
		var pEnd = component.get("v.pageEnd");
		pStart -= pageLength;
		pEnd -= pageLength;

		component.set("v.pageStart",pStart);
		component.set("v.pageEnd",pEnd);
		this.setButtonStatus(component);
	},
	goNext : function(component,event){
		var pageLength = component.get("v.length");
		var pStart = component.get("v.pageStart");
		var pEnd = component.get("v.pageEnd");
		pStart += pageLength;
		pEnd += pageLength;

		component.set("v.pageStart",pStart);
		component.set("v.pageEnd",pEnd);
		this.setButtonStatus(component);
	},
	setButtonStatus : function(component,event){
		var pageLength = component.get("v.length");
		var pStart = component.get("v.pageStart");
		var pEnd = component.get("v.pageEnd");
		var data = component.get("v.productList");


		if(0 == pStart){
			component.set("v.showFirst",false);
			component.set("v.showPrev",false);
			if(data && data.length > pageLength){
				component.set("v.showNext",true);
			}else{
				component.set("v.showNext",false);
			}
		}else{
			component.set("v.showFirst",true);
			component.set("v.showPrev",true);
			if(data && pEnd >= data.length){
				component.set("v.showNext",false);
			}else{
				component.set("v.showNext",true);
			}
		}
	},
    setQuantity : function(component, productList) {
        /*
        _.each(productList, function(item) {
            item['quantity'] = 1;
        });
        */
        productList.forEach(function(item) {
            item['quantity'] = 1;
        });
    },
    // SA 8 add item to cart
    addItemsToCart : function(component, items) {
        var helper = this;
        // send the context to SF while making remote calls
        var context = component.get("v.context");
        //var callContext = {effAccountId: context.accountId, portalUserId: context.userId};
        
        this.clearMessage(component, "errorDiv");
        this.showSpinner(component);
        this.ccrzAction(component,
            'c.addItemsToCart',
            {
                data : JSON.stringify(items),
                // SA 9 set call context
                cclxCtx: context
            },
            function(data) {
                var title = $A.get("$Label.cclxrep.cclxOBProdSrchProductsAddedTitle");
                var msg = $A.get("$Label.cclxrep.cclxOBProdSrchProductsAddedMessage");
                helper.showMessage(title, msg);
                var appEvent = $A.get("e.c:cc_lx_CartUpdateEventV2");
                appEvent.fire();
            },
            function(errors, message) {
                helper.displayMessage(component, "errorDiv", message, "error");
                console.log(message);
            },
            function() {
                helper.hideSpinner(component);
            }
        );
    },
    setLength : function(component, length) {
        if (length == 'All') {
            component.set("v.length", 200);
        }
        else if (length != null) {
            var value = parseInt(length);
            if (value) {
                component.set("v.length", value);
            }
        }
    }
})