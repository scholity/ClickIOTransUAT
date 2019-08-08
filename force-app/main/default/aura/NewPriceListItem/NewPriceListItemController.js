({
	doInit : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Name', fieldName: 'Name', type: 'text'},
            {label: 'Description', fieldName: 'ccrz__Desc__c', type: 'text'}
        ]);
		var action = component.get("c.getAllPriceLists");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var listPriceListsSObj = response.getReturnValue();
                component.set('v.listPriceLists', listPriceListsSObj);
            }
        });
        
        // enqueue the server side action  
        $A.enqueueAction(action);
	},
	openForm : function(component, event, helper) {
		component.set("v.formVisible", "true");
		component.set("v.showPage1", "true");
		component.set("v.showPage2", "false");
        component.set("v.selectedPriceList", []);
	},
	closeForm : function(component, event, helper) {
		component.set("v.formVisible", "false");
	},
	onNext : function(component, event, helper) {
        event.preventDefault(); // Prevent default submit
        var fields = event.getParam("fields");
        component.set("v.fields", fields);
		component.set("v.showPage1", "false");
		component.set("v.showPage2", "true");
        console.log('fields:' + JSON.stringify(fields));
        console.log('fields:' + JSON.stringify(fields['ccrz__Pricelist__c']));
        console.log('mainPriceList:');
        console.log('mainPriceList:' + component.get("v.mainPriceList"));
        component.set("v.selectedPriceList", [component.get("v.mainPriceList")]);
	},
    onSave : function(component, event, helper) {
        var selectedPriceLists = [];
        var selectedRows = component.find('dtPriceLists').getSelectedRows();
        for (var i = 0; i < selectedRows.length; i++) {
        	selectedPriceLists[selectedPriceLists.length] = selectedRows[i].Id;
        }
        console.log('selected rows:' +component.find('dtPriceLists').getSelectedRows());
        var fields = component.get("v.fields");
        console.log('fields:' + JSON.stringify(fields));
        var action = component.get("c.createPriceListItems");
        action.setParams({
            priceList: component.get("v.mainPriceList"),
            startDate: fields['ccrz__StartDate__c'],
            endDate: fields['ccrz__EndDate__c'],
            subProdTermId: component.get("v.subProdTerm"),
            product: component.get("v.recordId"),
            price: fields['ccrz__Price__c'],
            maxQty: fields['ccrz__MaxQty__c'],
            minQty: fields['ccrz__MinQty__c'],
            recurringPrice: fields['ccrz__RecurringPrice__c'],
            selectPriceLists: selectedPriceLists
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.formVisible", "false");
            }
        });
        
        // enqueue the server side action  
        $A.enqueueAction(action);
	},
    priceListChanged : function(component, event, helper) {
        component.set("v.mainPriceList", event.getParam("value"));
    },
    subProdTermChanged : function(component, event, helper) {
        component.set("v.subProdTerm", event.getParam("value"));
    }
})