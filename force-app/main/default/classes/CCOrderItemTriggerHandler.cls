/************************************************************************************************************************************
** Author: Salesforce Services
** Description: The purpose of this class is to complete the trigger actions
************************************************************************************************************************************/

public without sharing class CCOrderItemTriggerHandler {
    
    public CCOrderItemTriggerHandler() { }
    
    public void OnBeforeInsert(List<ccrz__E_OrderItem__c> newCCOrderItems) {
        system.debug('CC Order Item Trigger On Before Insert');
        Set<Id> orderIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        Set<Id> classIds = new Set<Id>();
        for(ccrz__E_OrderItem__c  oi: newCCOrderItems) {
            orderIds.add(oi.ccrz__Order__c);
            if(oi.ccrz__Product__c!=null) { productIds.add(oi.ccrz__Product__c); }
            if(oi.ILT_Class__c!=null) { classIds.add(oi.ILT_Class__c); }
        }
        setUnitCodeAndLoc(newCCOrderItems, orderIds, productIds, classIds);

        populateILTClass(newCCOrderItems);
    }
    
    public void OnBeforeUpdate(List<ccrz__E_OrderItem__c > newCCOrderItems, List<ccrz__E_OrderItem__c> oldCCOrderItems, Map<ID, ccrz__E_OrderItem__c> newCCOrderItemMap, Map<ID, ccrz__E_OrderItem__c> oldCCOrderItemMap) {
        system.debug('CC Order Item Trigger On Before Update');		
        Set<Id> orderIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        Set<Id> classIds = new Set<Id>();
        for(ccrz__E_OrderItem__c  oi: newCCOrderItems) {
            orderIds.add(oi.ccrz__Order__c);
            if(oi.ccrz__Product__c!=null) { productIds.add(oi.ccrz__Product__c); }
            //if(oi.ILT_Class__c!=null && oi.ILT_Class__c!=oldCCOrderItemMap.get(oi.Id).ILT_Class__c) {
            if(oi.ILT_Class__c!=null) {  
                classIds.add(oi.ILT_Class__c); 
            }
        }
        setUnitCodeAndLoc(newCCOrderItems, orderIds, productIds, classIds);   

    }
    
    public void setUnitCodeAndLoc(List<ccrz__E_OrderItem__c > newCCOrderItems, Set<Id> orderIds, Set<Id> productIds, Set<Id> classIds) {
        Set<String> zipCodeSet = new Set<String>();
        Map<Id,ccrz__E_Order__c> orderMap = new Map<Id,ccrz__E_Order__c>();
        Map<Id,ccrz__E_Product__c> productMap = new Map<Id,ccrz__E_Product__c>();
        Map<Id,redwing__ILT_Class__c> classMap = new Map<Id,redwing__ILT_Class__c>();
        
        //Map<String,Geo_Location__c> glMap = new Map<String,Geo_Location__c>();
        
        if(!orderIds.isEmpty()) { orderMap = new Map<Id,ccrz__E_Order__c>([SELECT Id,ccrz__Account__c,ccrz__Account__r.BillingPostalCode,ccrz__ShipTo__c,ccrz__ShipTo__r.ccrz__PostalCode__c FROM ccrz__E_Order__c WHERE Id IN:orderIds]); }
        if(!productIds.isEmpty()) { productMap = new Map<Id,ccrz__E_Product__c>([SELECT Id,ccrz__InventoryType__c FROM ccrz__E_Product__c WHERE Id IN:productIds]); }
        if(!classIds.isEmpty()) { classMap = new Map<Id,redwing__ILT_Class__c>([SELECT Id,Skedulo_Training_Event__c,Skedulo_Training_Event__r.Training_Zip__c, Location_ZIP_Code__c FROM redwing__ILT_Class__c WHERE Id IN:classIds]); }  
        
        for(ccrz__E_OrderItem__c  oi: newCCOrderItems)
        {
            if(productMap.containsKey(oi.ccrz__Product__c) && 
              (productMap.get(oi.ccrz__Product__c).ccrz__InventoryType__c=='COURSE' || 
               productMap.get(oi.ccrz__Product__c).ccrz__InventoryType__c=='COMMUNITY' || 
               productMap.get(oi.ccrz__Product__c).ccrz__InventoryType__c=='FEE') && 
               classMap.containsKey(oi.ILT_Class__c) && 
               classMap.get(oi.ILT_Class__c).Location_ZIP_Code__c != null)
            {
                system.debug(classMap.get(oi.ILT_Class__c).Location_ZIP_Code__c);
                     
            	zipCodeSet.add(String.valueOf(classMap.get(oi.ILT_Class__c).Location_ZIP_Code__c));
                
                if(orderMap.get(oi.ccrz__Order__c).ccrz__Account__r.BillingPostalCode != null)
                {
                    zipCodeSet.add(String.valueOf(orderMap.get(oi.ccrz__Order__c).ccrz__Account__r.BillingPostalCode));
                }
                  
            } else if(productMap.containsKey(oi.ccrz__Product__c) && 
                      productMap.get(oi.ccrz__Product__c).ccrz__InventoryType__c=='STANDARD' &&
                      orderMap.containsKey(oi.ccrz__Order__c) &&
                      orderMap.get(oi.ccrz__Order__c).ccrz__ShipTo__c!=null &&
					  orderMap.get(oi.ccrz__Order__c).ccrz__ShipTo__r.ccrz__PostalCode__c!=null)
            {
            		  zipCodeSet.add(String.valueOf(orderMap.get(oi.ccrz__Order__c).ccrz__ShipTo__r.ccrz__PostalCode__c));
            } else if(orderMap.containsKey(oi.ccrz__Order__c) && 
                      orderMap.get(oi.ccrz__Order__c).ccrz__Account__c!=null && 
                      orderMap.get(oi.ccrz__Order__c).ccrz__Account__r.BillingPostalCode!=null)
            {
            		  zipCodeSet.add(String.valueOf(orderMap.get(oi.ccrz__Order__c).ccrz__Account__r.BillingPostalCode));
            }
            else
            {
                oi.Unit_Code__c='00000';
                oi.TS_LOC__c='0000';
            }
            system.debug(oi);
            system.debug(oi.ccrz__Order__c);
            system.debug(oi.ccrz__Order__r.ccrz__Account__c);
        }
        
        system.debug(zipCodeSet);
        if(!zipCodeSet.isEmpty())
        {   
            Set<String> zipCodeSetNew = new Set<String>();
            
            for(String zc : zipCodeSet)
            {
                //zc.substring(0,5);
                zipCodeSetNew.add(zc.substring(0,5));
            }
            
            system.debug('***zipCodeSetNew***'+zipCodeSetNew);
            
            List<Geo_Location__c> glList = new List<Geo_Location__c>([SELECT Id,
                                                                      		 Postal_Code__c,
                                                                      		 GL_Unit_Code__c,
                                                                      		 GL_Unit_Code__r.TS_LOC__c,
                                                                      		 GL_Unit_Code__r.Unit_Code__c
                                                                        FROM Geo_Location__c
                                                                       WHERE Postal_Code__c IN:zipCodeSetNew]);
            
            Map<String,Geo_Location__c> glMap = new Map<String,Geo_Location__c>();
            
            for(Geo_Location__c gl: glList)
            {
                glMap.put(gl.Postal_Code__c,gl);
            }
			
            for(ccrz__E_OrderItem__c  oi: newCCOrderItems)
            {
                String zip = '';
                if(productMap.containsKey(oi.ccrz__Product__c) && 
                  (productMap.get(oi.ccrz__Product__c).ccrz__InventoryType__c=='COURSE' || 
                   productMap.get(oi.ccrz__Product__c).ccrz__InventoryType__c=='COMMUNITY' || 
                   productMap.get(oi.ccrz__Product__c).ccrz__InventoryType__c=='FEE') && 
                   classMap.containsKey(oi.ILT_Class__c) &&
                   classMap.get(oi.ILT_Class__c).Location_ZIP_Code__c != null)
                {
                    zip = classMap.get(oi.ILT_Class__c).Location_ZIP_Code__c;
                    
                    Boolean containsZip = glMap.containsKey(zip);

                    // if zip code isn't the glMap, use Account billing postal code. 
                    if(!containsZip && orderMap.get(oi.ccrz__Order__c).ccrz__Account__r.BillingPostalCode != null)
                    {
                    	system.debug('***orderMap.get(oi.ccrz__Order__c).ccrz__Account__r.BillingPostalCode***'+orderMap.get(oi.ccrz__Order__c).ccrz__Account__r.BillingPostalCode);
                        zip = orderMap.get(oi.ccrz__Order__c).ccrz__Account__r.BillingPostalCode;
                    }
                }
                else if(productMap.containsKey(oi.ccrz__Product__c) && 
                      	productMap.get(oi.ccrz__Product__c).ccrz__InventoryType__c=='STANDARD' &&
                        orderMap.containsKey(oi.ccrz__Order__c) &&
                      	orderMap.get(oi.ccrz__Order__c).ccrz__ShipTo__c!=null &&
					  	orderMap.get(oi.ccrz__Order__c).ccrz__ShipTo__r.ccrz__PostalCode__c!=null)
                {
                    zip = orderMap.get(oi.ccrz__Order__c).ccrz__ShipTo__r.ccrz__PostalCode__c;
                }
                else if(orderMap.containsKey(oi.ccrz__Order__c) && 
                        orderMap.get(oi.ccrz__Order__c).ccrz__Account__c!=null && 
                        orderMap.get(oi.ccrz__Order__c).ccrz__Account__r.BillingPostalCode!=null)
                {
                    zip = orderMap.get(oi.ccrz__Order__c).ccrz__Account__r.BillingPostalCode;
                }

                if (String.isEmpty(zip)) {
                    zip = getPaymentPostalCodeForOrder(oi.ccrz__Order__c);
                }
                // all else fails
                if (String.isEmpty(zip)) {
                    zip = '00000';
                }
                system.debug('***zip0***'+zip);
                zip = zip.substring(0,5);
                system.debug('***zip1***'+zip);
                
                if(glMap.containsKey(zip) && glMap.get(zip).GL_Unit_Code__c!=null)
                {
                	oi.Unit_Code__c = glMap.get(zip).GL_Unit_Code__r.Unit_Code__c;
                    oi.TS_LOC__c 	= glMap.get(zip).GL_Unit_Code__r.TS_LOC__c;
                }
                else
                {
                    oi.Unit_Code__c	='00000';
                    oi.TS_LOC__c	='0000';
                }
        	}
        }  
    }

    /**
     * @description Obtains the payment postal code for an order
     *
     * @param orderId
     *
     * @return
     */
    @TestVisible
    private String getPaymentPostalCodeForOrder(String orderId) {
        String postalCode;
        ccrz__E_Order__c order = [
                SELECT
                        Id,
                        ccrz__OriginatedCart__r.Payment_Postal_Code__c
                FROM
                        ccrz__E_Order__c
                WHERE
                        Id = :orderId
                LIMIT
                        1
        ];
        if (order != null) {
            postalCode = order.ccrz__OriginatedCart__r.Payment_Postal_Code__c;
        }

        return postalCode;
    }
    
   public void populateILTClass (List<ccrz__E_OrderItem__c> orderItems) {
        // adjusted to beforeInsert

        Set<Id> orderIds = new Set<Id>();
        for (ccrz__E_OrderItem__c oi : orderItems) {
            orderIds.add(oi.ccrz__Order__c);
        }

        Map<Id, ccrz__E_Order__c> orderMap = new Map<Id, ccrz__E_Order__c>( [SELECT Id, ccrz__OriginatedCart__r.Opportunity__r.Source_System__c,
                                                                            ccrz__OriginatedCart__c FROM ccrz__E_Order__c WHERE Id IN:orderIds]);

        Set<Id> cartIds = new Set<Id>();
        for (Id i : orderMap.keySet()) {
            ccrz__E_Order__c o = orderMap.get(i);
            cartIds.add(o.ccrz__OriginatedCart__c);
        }

        Map<Id, Set<ccrz__E_CartItem__c>> cartItemsMap = new Map<Id, Set<ccrz__E_CartItem__c>>(); // cart Id as key, set of cart items as value

        List<ccrz__E_CartItem__c> cartItemList = [SELECT Id, ccrz__Product__c, ccrz__Cart__c, ILT_Class__c FROM ccrz__E_CartItem__c WHERE ccrz__Cart__c IN:cartIds];
        for (ccrz__E_CartItem__c ci : cartItemList) {
            if (cartItemsMap.keySet().contains(ci.ccrz__Cart__c)) {
                Set<ccrz__E_CartItem__c> items = cartItemsMap.get(ci.ccrz__Cart__c);
                items.add(ci);
            } else {
                Set<ccrz__E_CartItem__c> items = new Set<ccrz__E_CartItem__c>{ci};
                cartItemsMap.put(ci.ccrz__Cart__c, items);
            }
        }

		System.debug('orderItems='+orderItems);		
		System.debug('orderMap='+orderMap);       
		System.debug('cartItemsMap='+cartItemsMap);
		
        for (ccrz__E_OrderItem__c oi : orderItems) {

            ccrz__E_Order__c o = orderMap.get(oi.ccrz__Order__c);
            String sourceSystem = o.ccrz__OriginatedCart__r.Opportunity__r.Source_System__c;

            if (sourceSystem == 'CRE' || sourceSystem == 'RBC') {
                Set<ccrz__E_CartItem__c> cartItems = cartItemsMap.get(o.ccrz__OriginatedCart__c);
                for (ccrz__E_CartItem__c ci : cartItems) {
                    if (ci.ccrz__Product__c == oi.ccrz__Product__c) {
                        oi.ILT_Class__c = ci.ILT_Class__c;
                    }
                }
            }
        }
    }
    
/*    public void OnAfterInsert(List<ccrz__E_OrderItem__c > newCCOrderItems) {
        system.debug('CC Order Item Trigger On After Insert');
    } 
    public void OnAfterUpdate(List<ccrz__E_OrderItem__c > newCCOrderItems, List<ccrz__E_OrderItem__c> oldCCOrderItems, Map<ID, ccrz__E_OrderItem__c> newCCOrderItemMap, Map<ID, ccrz__E_OrderItem__c> oldCCOrderItemMap) {
		system.debug('CC Order Item Trigger On After Update');
    }
     */
}