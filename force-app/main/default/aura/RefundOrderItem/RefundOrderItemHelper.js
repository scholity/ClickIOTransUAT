({
	fetchPicklistValues: function(component,objDetails,controllerField, dependentField) {
         
        var action = component.get("c.getDependentMap");
        
        action.setParams({
            'objDetail' : objDetails,
            'contrfieldApiName': controllerField,
            'depfieldApiName': dependentField 
        });
        
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {

                var StoreResponse = response.getReturnValue();                

                component.set("v.depnedentFieldMap",StoreResponse);
                

                var listOfkeys = [];
                var ControllerField = [];
                
                for (var singlekey in StoreResponse) {
                    listOfkeys.push(singlekey);
                }
                
                if (listOfkeys != undefined && listOfkeys.length > 0) {
                    ControllerField.push('--- None ---');
                }
                
                for (var i = 0; i < listOfkeys.length; i++) {
                    ControllerField.push(listOfkeys[i]);
                }  

                component.set("v.listControllingValues", ControllerField);
            }else{
                alert('Something went wrong..');
            }
        });
        $A.enqueueAction(action);
    },
    
    onButtonClick : function(component, event, helper)
    {
        var orderId = component.get("v.recordId");
        
        console.log("***orderId%%%"+orderId);
        
        var action = component.get('c.getOrderItemDetail');
        action.setParams({ orderId : orderId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS")
            {   
                var storeResponse = response.getReturnValue();
                
                component.set("v.orderItemList", storeResponse);
                
                var newPrice 	 = storeResponse[0].ccrz__Price__c * -1;
                var newSubAmount = storeResponse[0].ccrz__SubAmount__c  * -1;
                var itemTotal	 = storeResponse[0].ccrz__ItemTotal__c;
                
                component.set("v.price",newPrice);
                component.set("v.itemTotal",itemTotal);
                //component.set("v.subAmount",newSubAmount);
                
                //component.set("v.qty",storeResponse[0].ccrz__Quantity__c);
                
                component.set("v.originalQty", storeResponse[0].ccrz__Quantity__c);
                
                console.log("***storeResponse[0].Inventory_Type__c***"+storeResponse[0].Inventory_Type__c)
                
                if(storeResponse[0].Inventory_Type__c === "COURSE" || storeResponse[0].Inventory_Type__c === "COMMUNITY")
                {
                    component.set("v.isCourse",true);
                }
                
            }
        });
        $A.enqueueAction(action);
        
    },
    
    fetchDepValues: function(component, ListOfDependentFields)
    {

        var dependentFields = [];
        dependentFields.push('--- None ---');
        for (var i = 0; i < ListOfDependentFields.length; i++)
        {
            dependentFields.push(ListOfDependentFields[i]);
        }

        component.set("v.listDependingValues", dependentFields);
        
    },
    
    getPreviousCredit : function(component, event, helper)
    {
        var action = component.get('c.getCreditedOrderItemDetail');
        
        var orderItemId = component.get("v.recordId");
        
        component.set("v.oId",orderItemId);
        
        action.setParams({ orderItemId : orderItemId });
        
        action.setCallback(this, function(response) 
		{
            var state = response.getState();
            if (state === "SUCCESS")
            {   
                var storeResponse = response.getReturnValue();
                
                console.log("getPreviousCredit***"+storeResponse);  
                
                if (storeResponse != null)
                {
                    component.set("v.previousCredit",storeResponse);
                    component.set("v.hasPreviousDiscount",true);
                }
                           
            }
        });
        $A.enqueueAction(action);
    },
    
    getCreditedOrderItemCount: function(component, event, helper)
    {
        var action = component.get('c.getCreditedOrderItemCount');
        
        var orderItemId = component.get("v.recordId");
        
        
        action.setParams({ orderItemId : orderItemId });
        
        action.setCallback(this, function(response) 
		{
            var state = response.getState();
            if (state === "SUCCESS")
            {   
                var storeResponse = response.getReturnValue();
                
                console.log("getPreviousCreditCount***"+storeResponse);  
                
                if (storeResponse != null)
                {
                    component.set("v.previousCreditCount",storeResponse);
                }
                           
            }
        });
        $A.enqueueAction(action);
    },
    
    onClickYes : function(component, event, helper)
    {
        component.set("v.spinner", 'true');
        
        var odrAdjTps   = component.get("v.objDetail.Adjustment_Types__c");
        var rsnCods	    = component.get("v.objDetail.Reason_Codes__c");
        var explntn	    = component.get("v.explnation");
        var qty		    = component.get("v.qty");
        var originalQty = component.get("v.originalQty");
        var crdtQty 	= component.get("v.previousCreditCount");
        var price	    = component.get("v.price");
        var isPartial	= false;
        
        if (crdtQty !== undefined)
        {
            var total		= qty + crdtQty;
            
        }
        else
        {
            var total		= qty;
        }
        
        if(total === originalQty)
        {
            isPartial = false;
        }
        else
        {
            isPartial = true;
        }
        
		var orderId   = component.get("v.recordId");
        var action    = component.get("c.refundOI");
        
        action.setParams({'orderId' 			: orderId,
                          'orderAdjustmentType'	: odrAdjTps,
                          'reasonCodes' 		: rsnCods,
                          'explanation'		  	: explntn,
                          'qty'					: qty,
                          'price'				: price,
                          'isPartialReturn'		: isPartial,
                          'isDropStdnt'			: false});
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
           
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title"   : "Success!",
                    "message" : "Order Item Refunded Successfully.",
                    "type"    : "success"
                });
                toastEvent.fire();
                $A.get("e.force:refreshView").fire();
                component.set("v.stepNumber", "Zero");
            }
      
        });
        
        $A.enqueueAction(action);
	} 
})