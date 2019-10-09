public class CancelOrderItemController {
    
    public Static String keyPrefixlrnas;
    public Static String keyPrefixroster;
    
    @AuraEnabled 
    public static List<ccrz__E_OrderItem__c> getOrderItemDetail(String orderId)
    {
    	List<ccrz__E_OrderItem__c> initOrderItem = [SELECT	Id,
		                                             		ccrz__Order__c,
		                                             		ccrz__Price__c,
		                                             		ccrz__Quantity__c,
                                                     		ccrz__ItemTotal__c,
		                                             		ccrz__SubAmount__c,
		                                             		ccrz__Product_Name__c,
		                                             		ccrz__Product__r.ccrz__SKU__c,
		                                             		Inventory_Type__c
		                                               FROM ccrz__E_OrderItem__c
		                                       		  WHERE Id =: orderId LIMIT 1];
        return initOrderItem;
    }
    
    @AuraEnabled 
    public static decimal getCreditedOrderItemDetail(String orderItemId)
    {
        List<AggregateResult> creditedOrderItem = [SELECT   ccrz__ParentOrderItem__c,
                                                   		    SUM(ccrz__ItemTotal__c)
                                                   FROM	    ccrz__E_OrderItem__c
                                                   WHERE    ccrz__ParentOrderItem__c =: orderItemId
                                                   AND 	    Is_Return__c = true
                                                   GROUP BY ccrz__ParentOrderItem__c];
        decimal totalSumAmount;
        
        if(creditedOrderItem.size() > 0)
        {
        	totalSumAmount = decimal.valueOf(creditedOrderItem[0].get('expr0') + '');
            
            system.debug('totalSumAmount***'+totalSumAmount);
        }
        
        return totalSumAmount;
    }
    
    @AuraEnabled 
    public static decimal getCreditedOrderItemCount(String orderItemId)
    {
        List<AggregateResult> previosCreditQty  = [SELECT   ccrz__ParentOrderItem__c,
                                                   			SUM(ccrz__Quantity__c)
                                                   FROM	 	ccrz__E_OrderItem__c
                                                   WHERE    ccrz__ParentOrderItem__c =: orderItemId
                                                   AND 	 	Is_Return__c = true
                                                   GROUP BY ccrz__ParentOrderItem__c];
        decimal totalCrdtQty;
        
        if(previosCreditQty.size() > 0)
        {
        	ccrz__E_OrderItem__c oItem = [SELECT ccrz__Quantity__c  FROM ccrz__E_OrderItem__c WHERE Id =: orderItemId LIMIT 1];
            
            totalCrdtQty = decimal.valueOf(previosCreditQty[0].get('expr0') + '');
            
            system.debug('totalCrdtQty***'+totalCrdtQty);

        }
        
        return totalCrdtQty;
    }
    
    @AuraEnabled 
    public static Map<String, List<String>> getDependentMap(sObject objDetail, string contrfieldApiName,string depfieldApiName)
	{
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField   = depfieldApiName.toLowerCase();
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        
        Schema.sObjectType objType = objDetail.getSObjectType();
        
        if (objType==null)
        {
            return objResults;
        }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField))
        {
            return objResults;     
        }
        
        Schema.SObjectField theField  = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        
        List<PicklistEntryWrapper> depEntries 	= wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries)
		{
            String label = ple.getLabel();
            
            objResults.put(label, new List<String>());
            
            controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew : depEntries)
		{
            String label 		= plew.label;
            String validForBits = base64ToBits(plew.validFor);
            
            for (Integer i = 0; i < validForBits.length(); i++)
            {
                String bit = validForBits.mid(i, 1);
                
                if (bit == '1')
                {
                    objResults.get(controllingValues.get(i)).add(label);
                }
                
            }
        }
        
        return objResults;
        
    }
    
    public static String decimalToBinary(Integer val)
    {
        String bits 	= '';
        
        while (val > 0)
        {
            Integer remainder 	= Math.mod(val, 2);
            val 				= Integer.valueOf(Math.floor(val / 2));
            bits				= String.valueOf(remainder) + bits;
        }
        
        return bits;
    }
    
    public static String base64ToBits(String validFor)
    {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++)
        {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs)
    {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    public class PicklistEntryWrapper
    {
        public String activ			{get;set;}
        public String defaultValue  {get;set;}
        public String label			{get;set;}
        public String value			{get;set;}
        public String validFor		{get;set;}
        public PicklistEntryWrapper(){}
    }
    
    
    @AuraEnabled
    public static void cancelOI(String orderId, String orderAdjustmentType, String reasonCodes, String explanation)
    {
        List<ccrz__E_OrderItem__c> oItm = [SELECT Id,
        										  ccrz__OrderItemStatus__c,
                                           		 (SELECT Id
                                                    FROM Training_Event__r),
                                                 (SELECT Id
													FROM Voucher__r),
                                                 (SELECT Id
													FROM Fulfillment_Items__r),
												 (SELECT Id
												    FROM ccrz__Order_Items__r)
                                            FROM ccrz__E_OrderItem__c
                                           WHERE Id =: orderId LIMIT 1];
                                                   
        system.debug('***oItm***'+oItm);
        
        List<Id> tEventIdList  = new List<Id>();
        List<Id> voucherIdList = new List<Id>();
        List<Id> flmtItmIdList = new List<Id>();
        List<Id> oItemIdList   = new List<Id>();
        
        if(oItm.size() > 0)
        {
        	for(ccrz__E_OrderItem__c oi : oItm)
	        {
	        	if( oi.ccrz__OrderItemStatus__c == 'Order Submitted' ||
		        	oi.ccrz__OrderItemStatus__c == 'In Process' 	 ||
		        	oi.ccrz__OrderItemStatus__c == 'Partial Shipped' ||
		        	oi.ccrz__OrderItemStatus__c == 'On Hold' 		 ||
		        	oi.ccrz__OrderItemStatus__c == 'Reservation'	 ||
		        	oi.ccrz__OrderItemStatus__c == 'Shipped')
        		{
		            if(oi.Training_Event__r.size() > 0)
		            {
		                for (Training_Events__c te : oi.Training_Event__r)
		                {
		                	tEventIdList.add(te.Id);
		                }
		            }
		            
		            if(oi.Voucher__r.size() > 0)
		            {
		                for (Voucher__c v : oi.Voucher__r)
		                {
		                	voucherIdList.add(v.Id);
		                }
		            }
		            
		            if(oi.Fulfillment_Items__r.size() > 0)
		            {
		            	for(Fulfillment_Item__c fli : oi.Fulfillment_Items__r)
		            	{
		            		flmtItmIdList.add(fli.Id);
		            	}
		            }
		            
		            if(oi.ccrz__Order_Items__r.size() > 0)
		            {
		            	for(ccrz__E_OrderItem__c fli : oi.ccrz__Order_Items__r)
		            	{
		            		oItemIdList.add(fli.Id);
		            	}
		            }
		            
		            oItemIdList.add(oi.Id);
        		}
	        }
        }
        
        List<Training_Events__c> tsToUpdate			= new List<Training_Events__c>();
        List<Voucher__c> vchrsToUpdate 				= new List<Voucher__c>();
        List<Fulfillment_Item__c> flmtItmsToUpdate 	= new List<Fulfillment_Item__c>();
        List<ccrz__E_OrderItem__c> oItemsToUpdate	= new List<ccrz__E_OrderItem__c>();
        
        if(tEventIdList.size() > 0)
        {
	        for(Id tId : tEventIdList)
	        {
	        	 tsToUpdate.add(new Training_Events__c(Id					= tId,
													   Scheduling_Status__c	= 'Void',
													   Void_Reason__c		= 'Customer Declined'));
	        }
        }
        
        if(voucherIdList.size() > 0)
        {
        	for(Id vId : voucherIdList)
        	{
        		vchrsToUpdate.add(new Voucher__c(Id		   = vId,
        										 Status__c = 'Claimed'));
        	}
        }
        
        if(flmtItmIdList.size() > 0)
        {
        	for(Id flmtId : flmtItmIdList)
        	{
        		flmtItmsToUpdate.add(new Fulfillment_Item__c(Id 		= flmtId,
        													 Status__c 	= 'Cancelled'));
        	}
        }
        
        if(oItemIdList.size() > 0)
        {
        	for(Id oId : oItemIdList)
        	{
        		oItemsToUpdate.add(new ccrz__E_OrderItem__c(Id 				 = oId,
													ccrz__OrderItemStatus__c = 'Cancelled',
													Adjustment_Types__c		 = orderAdjustmentType,
													Reason_Codes__c 		 = reasonCodes,
													Explanation__c			 = explanation));
        	}
        }
        
        if(tsToUpdate.size() > 0)
        {
        	update tsToUpdate;
        }
        
        if(vchrsToUpdate.size() > 0)
        {
        	update vchrsToUpdate; 
        }
        
        if(flmtItmsToUpdate.size() > 0)
        {
        	update flmtItmsToUpdate;
        }
        
        if(oItemsToUpdate.size() > 0)
        {
        	update oItemsToUpdate;
        }
    	
    }
    
    @AuraEnabled
    public static void refundOI(String orderId, String orderAdjustmentType, String reasonCodes, String explanation, decimal qty, String price, Boolean isPartialReturn, Boolean isDropStdnt)
    {
        system.debug('***qty***'+qty);
        system.debug('***price***'+Decimal.ValueOf(price));
        
        ccrz__E_OrderItem__c oItm = [SELECT  Id,
                                             ccrz__Order__c,
                                             ccrz__Price__c,
                                             ccrz__Quantity__c,
                                             ccrz__SubAmount__c,
                                             ccrz__Product_Name__c,
                                             ccrz__ItemTotal__c,
                                             ccrz__PricingType__c,
                                             ccrz__OrderLineType__c,
                                             ccrz__Product__c,
                                             ccrz__ProductType__c,
                                             ccrz__UnitOfMeasure__c,
                                             ccrz__OrderItemStatus__c,
                                             ccrz__StoreId__c,
                                             ccrz__ItemStatus__c,
                                             ccrz__OrderItemId__c,
                                             ccrz__OriginalQuantity__c,
                                             ccrz__OriginalItemPrice__c,
                                             Opportunity__c,
                                     		 ILT_Class__c, 
                                             Inventory_Type__c
                                        FROM ccrz__E_OrderItem__c
                                       WHERE Id =: orderId LIMIT 1];
        
        system.debug('***oItm***'+oItm);
        system.debug('***oItm.ccrz__Price__c***'+oItm.ccrz__Price__c);
        
        decimal oItemPrice 		= oItm.ccrz__Price__c * -1;
        decimal rtnOiPrice 		= Decimal.ValueOf(price);
        boolean createNewOrder 	= false;
        
        if(oItemPrice != rtnOiPrice)
        {
            createNewOrder = true;
        }
        
        if(oItm.ccrz__Order__c != null)
        {
        	ccrz__E_Order__c ccOrder = [SELECT  Id,
        										ccrz__Account__c,
												ccrz__Name__c,
												ccrz__OriginatedCart__c,
												Opportunity_Order__c,
												Error_Message__c,
												ccrz__OrderDate__c,
												ccrz__OrderStatus__c,
												ccrz__CurrencyISOCode__c,
												ccrz__Storefront__c,
												FOCIS_Category__c,
												
												(SELECT Id
												   FROM ccrz__E_Orders__r
                                                  WHERE	Is_Submitted__c  = false),
												(SELECT Id
												   FROM ccrz__TransactionPayments__r)
												   
										   FROM ccrz__E_Order__c
										  WHERE Id =: oItm.ccrz__Order__c];
	        
	        system.debug('**ccOrder**'+ccOrder);
	        
	        boolean hasChildOrder = false;
	        
	        if(ccOrder.ccrz__E_Orders__r.size() > 0)
	        {
	        	hasChildOrder = true;
	        }
	        
	        
		    ccrz__E_Order__c newOrder = ccOrder.clone(false,false,false);
		    
		    if (!hasChildOrder)
		    {
		        newOrder.ccrz__Order__c 		= ccOrder.Id;
		        newOrder.ccrz__OrderStatus__c	= 'Return Submitted';
		        newOrder.Is_Return_Order__c		= true;
		        insert newOrder;
	        }
	        
	        ccrz__E_OrderItem__c newOdrItm = oItm.clone(false,false,false);
	        
	        if (!hasChildOrder)
	        {
	        	newOdrItm.ccrz__Order__c 		= newOrder.Id;
	        }
	        else
	        {
	        	newOdrItm.ccrz__Order__c 		= ccOrder.ccrz__E_Orders__r[0].Id;
	        }
            
            newOdrItm.ccrz__Quantity__c 		= qty;
            
            if(isDropStdnt)
            {
                newOdrItm.ccrz__Price__c			= oItemPrice;
                newOdrItm.ccrz__SubAmount__c 		= qty * oItemPrice;
            }
            else
            {
                newOdrItm.ccrz__Price__c			= decimal.ValueOf(price);
                newOdrItm.ccrz__SubAmount__c 		= qty * decimal.ValueOf(price);
            }
	        newOdrItm.ccrz__OrderItemStatus__c 	= 'Return Submitted';
	        newOdrItm.ccrz__ParentOrderItem__c	= oItm.Id;
	        newOdrItm.Is_Return__c				= true;
            newOdrItm.Adjustment_Types__c	    = orderAdjustmentType;
			newOdrItm.Reason_Codes__c 		    = reasonCodes;
			newOdrItm.Explanation__c			= explanation;
            newOdrItm.Payment_Category__c		= '48150';
            
	        insert newOdrItm;
            
            if(createNewOrder && isDropStdnt)
            {
                ccrz__E_OrderItem__c newOdrItm1 = oItm.clone(false,false,false);
                
                ccrz__E_Product__c  ccProduct = [SELECT Id
                                                   FROM ccrz__E_Product__c
                                                  WHERE ccrz__SKU__c  = 'CMCANCELFEE'
                                                  LIMIT 1];
                
                if(ccProduct != null)
                {
                    if (!hasChildOrder)
                    {
                        newOdrItm1.ccrz__Order__c 		= newOrder.Id;
                    }
                    else
                    {
                        newOdrItm1.ccrz__Order__c 		= ccOrder.ccrz__E_Orders__r[0].Id;
                    }
                    newOdrItm1.ccrz__OrderLineType__c	= 'Minor'; 
                    newOdrItm1.ccrz__Price__c			= (oItemPrice - decimal.ValueOf(price)) * -1;
                    newOdrItm1.ccrz__Quantity__c 		= qty;
                    newOdrItm1.ccrz__SubAmount__c 		= qty * (oItemPrice - decimal.ValueOf(price)) * -1;
                    newOdrItm1.ccrz__OrderItemStatus__c = 'Return Submitted';
                    newOdrItm1.ccrz__ParentOrderItem__c	= newOdrItm.Id;
                    newOdrItm1.Is_Return__c				= true;
                    newOdrItm1.ccrz__Product__c			= ccProduct.Id;
                    newOdrItm1.Adjustment_Types__c	    = orderAdjustmentType;
                    newOdrItm1.Reason_Codes__c 		    = reasonCodes;
                    newOdrItm1.Explanation__c			= explanation;
                    newOdrItm1.Payment_Category__c		= '48130';
                    
                    insert newOdrItm1;
                }
            }
	        
	        system.debug('***newOrdItm***'+newOdrItm);
	        
	        system.debug('***isPartialReturn***'+isPartialReturn);
	        
	        //For DROP STUDENT it should be 
	        if (!isPartialReturn)
	        {
                oItm.Is_Return__c 	= true;
	        	//oItm.ccrz__OrderItemStatus__c = 'Partial Returned';
                //oItm.Is_Partial_Return_OI__c  = true;
	        }
	        /*else
	        {
	        	oItm.ccrz__OrderItemStatus__c = 'Returned';
	        }*/
	        
	        //oItm.Adjustment_Types__c	  = orderAdjustmentType;
			//oItm.Reason_Codes__c 		  = reasonCodes;
			//oItm.Explanation__c			  = explanation;
	        update oItm;
	        
	        ccOrder.ccrz__OrderStatus__c	= 'Returned';
	        update ccOrder;
        }
        
    }
    
    @AuraEnabled
    public static void replaceOI(String orderId, String orderAdjustmentType, String reasonCodes, String explanation, decimal qty){
    	
        
        ccrz__E_OrderItem__c oItm = [SELECT  Id,
                                             ccrz__Order__c,
                                             ccrz__Price__c,
                                             ccrz__Quantity__c,
                                             ccrz__SubAmount__c,
                                             ccrz__Product_Name__c,
                                             ccrz__ItemTotal__c,
                                             ccrz__PricingType__c,
                                             ccrz__OrderLineType__c,
                                             ccrz__Product__c,
                                             ccrz__ProductType__c,
                                             ccrz__UnitOfMeasure__c,
                                             ccrz__OrderItemStatus__c,
                                             ccrz__StoreId__c,
                                             ccrz__ItemStatus__c,
                                             ccrz__OrderItemId__c,
                                             ccrz__OriginalQuantity__c,
                                             ccrz__OriginalItemPrice__c,
                                             Opportunity__c,
                                             Inventory_Type__c
                                        FROM ccrz__E_OrderItem__c
                                       WHERE Id =: orderId LIMIT 1];
        
        system.debug('***oItm-ReplaceOI***'+oItm);
        
        if(oItm != null)
        {
        	ccrz__E_Order__c ccOrder = [SELECT  Id,
        										ccrz__Account__c,
												ccrz__Name__c,
												ccrz__OriginatedCart__c,
												Opportunity_Order__c,
												Error_Message__c,
												ccrz__OrderDate__c,
												ccrz__OrderStatus__c,
												ccrz__CurrencyISOCode__c,
												ccrz__Storefront__c,
												FOCIS_Category__c,
												
												(SELECT Id
												   FROM ccrz__E_Orders__r),
												(SELECT Id
												   FROM ccrz__TransactionPayments__r)
												   
										   FROM ccrz__E_Order__c
										  WHERE Id =: oItm.ccrz__Order__c];
	        
	        system.debug('**ccOrder-ReplaceOI**'+ccOrder);
	        
	        boolean hasChildOrder = false;
	        
	        if(ccOrder.ccrz__E_Orders__r.size() > 0)
	        {
	        	hasChildOrder = true;
	        }
	        
	        
		    ccrz__E_Order__c newOrder = ccOrder.clone(false,false,false);
		    
		    if (!hasChildOrder)
		    {
		        newOrder.ccrz__Order__c 		= ccOrder.Id;
		        newOrder.ccrz__OrderStatus__c	= 'Order Submitted';
		        insert newOrder;
	        }
	        
	        ccrz__E_OrderItem__c newOdrItm = oItm.clone(false,true,false,false);
	        
	        if (!hasChildOrder)
	        {
	        	newOdrItm.ccrz__Order__c 		= newOrder.Id;
	        }
	        else
	        {
	        	newOdrItm.ccrz__Order__c 		= ccOrder.ccrz__E_Orders__r[0].Id;
	        }
	        newOdrItm.ccrz__Price__c			= 0;
	        newOdrItm.ccrz__SubAmount__c 		= 0;
	        newOdrItm.ccrz__OrderItemStatus__c 	= 'Order Submitted';
	        newOdrItm.ccrz__ParentOrderItem__c	= oItm.Id;
	        
	        insert newOdrItm;
	        
	        system.debug('***newOrdItm***'+newOdrItm);
	        
	        oItm.ccrz__OrderItemStatus__c 	= 'Order Submitted';
	        oItm.Adjustment_Types__c	  	= orderAdjustmentType;
			oItm.Reason_Codes__c 		  	= reasonCodes;
			oItm.Explanation__c			  	= explanation;
	        update oItm;
	        
	        ccOrder.ccrz__OrderStatus__c	= 'Order Submitted';
	        update ccOrder;
	        
        }
        
    }
    
    @AuraEnabled
    public static List<voucherWrapper> getVouchers(String orderItemId)
    {
        
        List<voucherWrapper> voucherList = new List<voucherWrapper>();
        
        List<Voucher__c> vouchers = [SELECT Id, 
                                     		Name,
                                     		Voucher_Claim__c,
                                     		User__r.Name   
                                     FROM   Voucher__c
                                     WHERE  CC_Order_Item__c =: orderItemId
                                     AND	Status__c != 'Void'];
                                     
        if (vouchers.size() > 0)
        {
            for(Voucher__c v : vouchers)
            {
                VoucherWrapper vWrapper = new VoucherWrapper();
                
                vWrapper.voucherId		= v.Id;
                vWrapper.voucherName	= v.Name;
                vWrapper.voucherClaim	= v.Voucher_Claim__c;
                vWrapper.user			= v.User__r.Name;
                
                voucherList.add(vWrapper);
            }
        }
        system.debug('***voucherList***'+voucherList);
        return voucherList;
    }
    
    @AuraEnabled
    public static decimal getILTClassInfomation(string orderItemId)
    {
        system.debug('***orderItemId***'+orderItemId);
        decimal percentCharge = 0;
        
        ccrz__E_OrderItem__c oItm = [SELECT Id,
                                            ccrz__Order__c,
                                            ccrz__Price__c,
                                            ccrz__Quantity__c,
                                            ccrz__SubAmount__c,
                                      		CreatedDate,
                                      		ILT_Class__c,
                                      		ILT_Class__r.redwing__Start_Date__c,
                                      		ILT_Class__r.Classroom_Setting__c 
                                       FROM ccrz__E_OrderItem__c
                                      WHERE Id =: orderItemId LIMIT 1];
        
        system.debug('oItm'+oItm);
        
        if(oItm != null && oItm.ILT_Class__c != null)
        {
            system.debug('oItm ILT START DATE'+oItm.ILT_Class__r.redwing__Start_Date__c );
            
            //calculate days betwen today and start date
            Date todaysDay = date.today();
            
            Integer noOfDays = todaysDay.daysBetween(oItm.ILT_Class__r.redwing__Start_Date__c );
            
            system.debug('***noOfDays***'+noOfDays);
            
            string daysBlock  = '';
            system.debug('***oItm.ILT_Class__r.Classroom_Setting__c***'+oItm.ILT_Class__r.Classroom_Setting__c);
            if (oItm.ILT_Class__r.Classroom_Setting__c != 'Online')
            {
                if(noOfDays > 14)
                {
                    daysBlock = 'DayAny';
                }
                else if (noOfDays <= 14 && noOfDays > 7)
                {
                    daysBlock = 'Days14';
                }
                else if (noOfDays <= 7 && noOfDays > 2)
                {
                    daysBlock = 'Days7';
                }
                else if (noOfDays <= 2 && noOfDays > 0)
                {
                    daysBlock = 'Days2';
                }
                else
                {
                    daysBlock = 'Day0';
                }
                
                system.debug('***daysBlock***'+daysBlock);
                
                List<CommunityClassCancellationPolicy__mdt> mtd = [SELECT MasterLabel,
                                                                   Percent_Value__c
                                                                   FROM CommunityClassCancellationPolicy__mdt
                                                                   WHERE MasterLabel =: daysBlock];
                
                system.debug('***mtd[0].Percent_Value__c***'+mtd[0].Percent_Value__c);
                
                percentCharge = mtd[0].Percent_Value__c;
            }
            else
            {   
                DateTime dt  = oItm.CreatedDate;
                Date odrDate = dt.date();
    
                Integer noOfDaysForOnline = todaysDay.daysBetween(odrDate);
                
                system.debug('noOfDaysForOnline-->'+noOfDaysForOnline);
                
                if(noOfDaysForOnline >= 0 && noOfDaysForOnline <= 2)
                {
                    percentCharge = 0;
                }
                else
                {
                    percentCharge = 100;
                }
            }
    	}
        
        return percentCharge;
        
    }
    
    @AuraEnabled
    public static void dropSlectedStudents(string voucherRecords)
	{
        
        List<Id> 		 voucherListIds 	= new List<Id>();
        List<Voucher__c> vouchersToUpdate 	= new List<Voucher__c>();
        List<Voucher__c> vouchersToCreate 	= new List<Voucher__c>();
        
        if(!string.isBlank(voucherRecords))
        {   
            
			List<VoucherWrapper> lstVoucherRecords =  (List<VoucherWrapper>) System.JSON.deserialize(voucherRecords,List<VoucherWrapper>.class);
            
            system.debug('***lstVoucherRecords***'+lstVoucherRecords);
            
            for(VoucherWrapper vRecords : lstVoucherRecords)
            {
                if(vRecords.isSelected)
                {
                    system.debug('***vRecords***'+vRecords);
                    voucherListIds.add(vRecords.voucherId);
                }
            }
        }
        
        system.debug('voucherListIds***'+voucherListIds);
        
        //DE1496 
        
        //List<Voucher__c> vouchers = []
        if(voucherListIds.size() > 0)
        {
            for(Id vId : voucherListIds)
            {   
                Voucher__c v = new Voucher__c();
                
                v.Id				= vId;
                /*v.CC_Order__c		= null;
                v.CC_Order_Item__c	= null;
                v.CC_Cart_Item__c	= null;
                v.Opportunity__c	= null;
                v.RCO_Order_Id__c	= null;
                v.Online_Class__c	= null;
                v.CC_Product__c 	= null;
                v.Account__c		= null;
                v.User__c			= null;*/
                v.Status__c			= 'Void';
                
                vouchersToUpdate.add(v);
            }
        }
        
        List<Voucher__c > vouchersWithRosters = [SELECT Id,
														(SELECT Id FROM ILT_Rosters__r)
												 FROM   Voucher__c
												 WHERE 	Id
												 IN 	:voucherListIds];
        
        List<Voucher__c> vouchers = [SELECT Id, 
                                            Account__c,
                                            CC_Cart_Item__c,
                                            CC_Order__c,
                                            CC_Order_Item__c,
                                            CC_Product__c,
                                            ILT_Class__c,
                                            Learning_Plan__c,
                                            Online_Class__c,
                                            Opportunity__c,
                                            RCO_Order_Id__c,
                                            RCO_Reservation_Timestamp__c,
                                            Status__c,
                                            User__c 
                                     FROM   Voucher__c
									WHERE 	Id
									 IN 	:voucherListIds];
												 
		List<Id> rosterList = new List<Id>();
		
		for (Voucher__c vwr: vouchersWithRosters)
		{
			if(vwr.ILT_Rosters__r.size() > 0)
			{
				for(redwing__ILT_Roster__c r : vwr.ILT_Rosters__r)
				{
					rosterList.add(r.Id);
				}
			}
		}
		
		system.debug('***rosterList***'+rosterList);
		
		
		if(rosterList.size() > 0)
		{
			system.debug('***rosterList***'+rosterList);
			CancelOrderItemController.cancelEnrollment(rosterList);
		}										 
												 
        
        if (vouchersToUpdate.size() > 0)
        {
            update vouchersToUpdate;
        }
        
        if(vouchers.size() > 0)
        {
            for(Voucher__c v : vouchers)
            {   
                Voucher__c newVoucher = v.clone(false,false,false);
                
                newVoucher.CC_Order__c					= null;
                newVoucher.CC_Order_Item__c				= null;
                newVoucher.CC_Cart_Item__c				= null;
                newVoucher.Opportunity__c				= null;
                newVoucher.RCO_Order_Id__c				= null;
                newVoucher.Online_Class__c				= null;
                newVoucher.CC_Product__c 				= null;
                newVoucher.Account__c					= null;
                newVoucher.User__c						= null;
                newVoucher.RCO_Reservation_Timestamp__c = null;
                newVoucher.Status__c					= 'Issued';
                
                vouchersToCreate.add(newVoucher);
            } 
        }
        
        if(vouchersToCreate.size() > 0)
        {
            insert vouchersToCreate;
        }
    }
    
    public static void cancelEnrollment(List<Id> recId)
    {
        List<redwing__ILT_Roster__c> rostersToUpdate = new List<redwing__ILT_Roster__c>();
        List<Id> lAssignmentsIds = new List <Id>();
        List<Id> userIds = new List <Id>();
        
        List<redwing__ILT_Roster__c> rosterList = [SELECT Id,
                                                          redwing__User__c,
                                                          redwing__Status__c,
                                                          redwing__Learning_Assignment__c,
                                                          redwing__ILT_Class__c
                                                    FROM  redwing__ILT_Roster__c
                                                   WHERE  Id IN  :recId];
        
        for(redwing__ILT_Roster__c rlist : rosterList)
        {
            lAssignmentsIds.add(rlist.redwing__Learning_Assignment__c);
            userIds.add(rlist.redwing__User__c);
        }
        
        List<redwing__Learning_Assignment__c> LearningAssignmentList = [SELECT Id,
																			   redwing__User__c,
                                                                        	   redwing__Training_Plan__c,
                                                                               redwing__Progress__c
                                                                          FROM redwing__Learning_Assignment__c 
                                                                         WHERE Id IN :lAssignmentsIds];
        List<Id> trainingPlanIds = new List<Id>();
        
        for(redwing__Learning_Assignment__c l : LearningAssignmentList)
        {
            trainingPlanIds.add(l.redwing__Training_Plan__c);
        }
        
        // Remove Learning Plan Assignments
        List<redwing__Training_Plan_Assignment__c> LearningPlanAssignmentList = [SELECT Id,
                                                                                        redwing__User__c 
                                                                                   FROM redwing__Training_Plan_Assignment__c 
                                                                                  WHERE redwing__User__c IN :userIds
                                                                                    AND redwing__Training_Plan__c IN :trainingPlanIds];
             
        // Get Learning Plan Achievements
        List<redwing__Training_Plan_Achievement__c> LearningPlanAchievementList = [SELECT Id,
                                                                                   		  redwing__Training_Plan__c 
                                                                                     FROM redwing__Training_Plan_Achievement__c 
                                                                                    WHERE redwing__Training_Plan__c IN :trainingPlanIds];
        
        // Remove Achievement assignments
        List<redwing__Achievement_Assignment__c> AchievementAssignmentList = [SELECT Id,
                                                                                     redwing__User__c 
                                                                                FROM redwing__Achievement_Assignment__c 
                                                                               WHERE redwing__User__c IN :userIds
                                                                                 AND redwing__Training_Plan_Achievement__c IN :LearningPlanAchievementList];
        
        if(LearningPlanAssignmentList.size() > 0)
        {
            delete LearningPlanAssignmentList;
        }
        
        if(AchievementAssignmentList.size() > 0)
        {
            delete AchievementAssignmentList;
        }
        
        if(LearningAssignmentList.size() > 0)
        {
            for(redwing__Learning_Assignment__c learningAssignment : LearningAssignmentList)
            {
                learningAssignment.redwing__Progress__c = 'Cancelled';
            }
            
            update LearningAssignmentList;
        }
        
        
        for(redwing__ILT_Roster__c r : rosterList)
        {
            r.redwing__Status__c   = 'Cancelled';
            r.Cancellation_Date__c = System.today();
            
            rostersToUpdate.add(r);
        }
        
        if(rostersToUpdate.size() > 0)
        {
            update rostersToUpdate;
        }
    }
    
    public class VoucherWrapper
	{
        
        @AuraEnabled public boolean isSelected 	{get;set;}
        @AuraEnabled public string voucherId 	{get;set;}
        @AuraEnabled public string voucherName 	{get;set;}
        @AuraEnabled public string voucherClaim {get;set;}
        @AuraEnabled public string user 		{get;set;}

        
        public VoucherWrapper()
        {
            isSelected 		= false;
            voucherName 	= '';
            voucherClaim 	= '';
            user			= '';
        }
    }
}