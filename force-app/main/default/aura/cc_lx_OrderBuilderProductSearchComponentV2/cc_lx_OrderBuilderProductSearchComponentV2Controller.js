({
    doInit : function(component, event, helper) {
      component.set("v.productList", null);
      helper.setLength(component, component.get("v.resultsLength"));

      var mobileFSpan = component.get('v.mobileFootSpan');
  		if(component.get('v.showPrice')){
        mobileFSpan++;
  		}
      if(component.get('v.showCartControls')){
        mobileFSpan += 2;
      }
      component.set('v.mobileFootSpan', mobileFSpan);
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
        });
      
    },
    goToRecord : function(component, event, helper){
        var id = $(event.currentTarget).data("id");
        helper.goToRecord(component, id);
    },
    triggerSearch : function(component, event, helper) {
        if (event.keyCode == 13) {
            var query = component.find("seach-input").getElement().value;
        	//var query = $(component.find("seach-input").getElement()).val();
            //var query = component.get("v.searchQuery");
            helper.getProducts(component, query);
        }
    },
	doGoFirst : function( component,event,helper){
		helper.goFirst(component,event);
	},
	doGoPrev : function( component,event,helper){
		helper.goPrev(component,event);
	},
	doGoNext : function(component,event,helper){
		helper.goNext(component,event,helper);
	},
    // 1. method gets called when user press search
    executeSearch : function(component, event, helper) {
        var query = component.find("seach-input").getElement().value;
        //var query = $(component.find("seach-input").getElement()).val();
        //var query = component.get("v.searchQuery");
        helper.getProducts(component, query);
    },
    doAddToCart : function(component, event, helper) {
        var items = [];
        var productList = component.get("v.productList");
        var checkboxes = $(component.find("OB_ProductSearchTable").getElement()).find(".cclx-checkbox:checked");
        checkboxes.each(function() {
            var productId = $(this).data("id");
            var product = _.find(productList, function(item){
                return item.sfid === productId;
            });
            items.push({
                id : product.sfid,
                sku : product.SKU,
                quantity : product.quantity
            });
        });
        if (items.length > 0) {
            helper.addItemsToCart(component, items);
        }
    },
    increment : function(component, event, helper){
        var id = event.getSource().get("v.value");
        var productList = component.get("v.productList");
        var product = _.filter(productList, function(item){
            return item.sfid === id;
        })[0];
        if(product)
            product.quantity++;

        component.set("v.productList", productList);
    },
    decrement : function(component, event, helper){
        var id = event.getSource().get("v.value");
        var productList = component.get("v.productList");
        var product = _.filter(productList, function(item){
            return item.sfid === id;
        })[0];
        if(product && product.quantity > 1)
            product.quantity --;

        component.set("v.productList", productList);
    },
    selectAll : function(component, event, helper) {
        var element = event.getSource ? event.getSource().getElement() : event.target;
        var status = element.checked;
		var checkboxes = $(component.find("OB_ProductSearchTable").getElement()).find(".cclx-checkbox");
        checkboxes.each(function(){
            this.checked = status;
        });
    },
    sortColumnString : function(component, event, helper) {
        var key = $(event.currentTarget).data("key");
        var productList = component.get("v.productList");
        var sortKey = component.get("v.sortKey");
        var reverse = component.get("v.sortReverse");
        reverse = (sortKey == key)&&!reverse;
        var multiplier = reverse ? -1 : 1;
        productList.sort(function(a, b) {
            return multiplier*((a[key] > b[key]) - (b[key] > a[key]));
        });
        component.set("v.productList", productList);
        component.set("v.sortKey", key);
        component.set("v.sortReverse", reverse);
    },
    sortColumnNumber : function(component, event, helper) {
        var key = $(event.currentTarget).data("key");
        var productList = component.get("v.productList");
        var sortKey = component.get("v.sortKey");
        var reverse = component.get("v.sortReverse");
        reverse = (sortKey == key)&&!reverse;
        var multiplier = reverse ? -1 : 1;
        productList.sort(function(a, b) {
            return multiplier*(parseFloat(a[key]) - parseFloat(b[key]));
        });
        component.set("v.productList", productList);
        component.set("v.sortKey", key);
        component.set("v.sortReverse", reverse);
    }
})