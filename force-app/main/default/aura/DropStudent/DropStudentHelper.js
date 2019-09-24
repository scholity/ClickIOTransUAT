({
    getData : function(component)
    {
        var orderItemId = component.get("v.recordId");
        
        var action 		= component.get('c.getVouchers');
        
        action.setParams({ orderItemId : orderItemId });
        
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.voucherList', response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
    },
    
    checkCancellationPolicy: function(component, event, helper)
    {
        console.log("checkCancellationPolicy");
        //get ITL Class information
        var orderItemId = component.get("v.recordId");
        
        var action 		= component.get('c.getILTClassInfomation');
        
        action.setParams({ orderItemId : orderItemId });
        
        action.setCallback(this, $A.getCallback(function (response) {
            
            var state = response.getState();
            
            if (state === "SUCCESS")
            {
                console.log("***SUCCESS***" +response.getReturnValue());
                component.set('v.percentForCnclPlcy', response.getReturnValue());
                
                //new price value
                
                
            }
            else if (state === "ERROR")
            {
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
    },
    
    getPreviousCredit : function(component, event, helper)
    {
        var action = component.get('c.getCreditedOrderItemDetail');
        
        var orderItemId = component.get("v.recordId");
        
        action.setParams({ orderItemId : orderItemId });
        
        action.setCallback(this, function(response) 
		{
            var state = response.getState();
            if (state === "SUCCESS")
            {   
                var storeResponse = response.getReturnValue();
                
                console.log(storeResponse);  
                
                if (storeResponse != null)
                {
                    component.set("v.previousCredit",storeResponse);
                    component.set("v.hasPreviousDiscount",true);
                }
                           
            }
        });
        $A.enqueueAction(action);
    },
    
    onClickYes : function(component, event, helper)
    {
        component.set("v.spinner", 'true');
        
        var odrAdjTps = component.get("v.objDetail.Adjustment_Types__c");
        var rsnCods	  = component.get("v.objDetail.Reason_Codes__c");
        var explntn	  = component.get("v.explnation");
        var qty		  = component.get("v.qty");	
        var price	  = component.get("v.price");
		var orderId   = component.get("v.recordId");
        
        var action    = component.get("c.refundOI");
        
        action.setParams({'orderId' 			: orderId,
                          'orderAdjustmentType'	: odrAdjTps,
                          'reasonCodes' 		: rsnCods,
                          'explanation'		  	: explntn,
                          'qty'					: qty,
                          'price'				: price,
                          'isPartialReturn'		: true,
                          'isDropStdnt'			: true});
        
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
            else
            {
                console.log("Error in Refund");
            }
      
        });
        
        $A.enqueueAction(action);
	},
    
    processDropStudent : function(component, event, helper)
    {
        
        var lstVouchers		= component.get("v.voucherList");
        var action 			= component.get("c.dropSlectedStudents");
        
        var voucherRecords 	= JSON.stringify(lstVouchers);
        
        action.setParams({ voucherRecords : voucherRecords });
        
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS")
            {
                console.log("SUCCESS FROM DROP STUDENT");
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
                console.log("Error in Drop Student");
            }
        }));
        $A.enqueueAction(action);
        $A.get("e.force:refreshView").fire();
    },
    
    fetchPicklistValues: function(component,objDetails,controllerField, dependentField)
    {
 
        var action = component.get("c.getDependentMap");
        action.setParams({
            'objDetail' 		: objDetails,
            'contrfieldApiName'	: controllerField,
            'depfieldApiName'	: dependentField 
        });

        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS")
            {
                var StoreResponse = response.getReturnValue();
                
                component.set("v.depnedentFieldMap",StoreResponse);

                var listOfkeys 		= []; 
                var ControllerField = [];
                
                for (var singlekey in StoreResponse)
                {
                    listOfkeys.push(singlekey);
                }

                if (listOfkeys != undefined && listOfkeys.length > 0)
                {
                    ControllerField.push('--- None ---');
                }
                
                for (var i = 0; i < listOfkeys.length; i++)
                {
                    ControllerField.push(listOfkeys[i]);
                }  

                component.set("v.listControllingValues", ControllerField);
            }
            else
            {
                alert('Something went wrong..');
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchDepValues: function(component, ListOfDependentFields)
    {
 
        var dependentFields 	= [];
        
        dependentFields.push('--- None ---');
        
        for (var i = 0; i < ListOfDependentFields.length; i++)
        {
            dependentFields.push(ListOfDependentFields[i]);
        }

        component.set("v.listDependingValues", dependentFields);
        
    },
})