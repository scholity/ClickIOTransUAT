/* @RestResource is used to tell the apex that this class is exposing/consuming the Salesforce API.
    urlMapping - URL of the API that will be used to hit the APEX REST
*/

/* Configuration Required: In Site Public Access Settings, Apex Class Access, insure that this class (PHSS_CreateOrderRestService)
   is added as an allowed class.  
   
   The endpoint for this service is https://<mycommunitydomain>/learner/services/apexrest/PHSS/CreateOrderRestService/
*/

@RestResource(UrlMapping='/PHSS/createOrder')
Global without sharing class PHSS_CreateOrderRestService {
    
    @httpPost
    global static JsonResponse createOrder(){
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        //get request body
        String postBody = req.requestBody.toString();
        
        // Write request to log 
        Map<String, Object> mapJSONObjects = (Map<String, Object>)JSON.deserializeUntyped(postBody);        
        String action = (String)mapJSONObjects.get('action');
        
        //to store learning plan Id and prooduct id
        List<String> lst_clsId = new List<String>();
        List<String> lst_onlineclsId = new List<String>();
        List<String> lst_productId = new List<String>();
        List<String> lst_LPId = new List<String>();

        Map<String,String> map_clsIDtoLPId = new Map<String,String>();
        Map<String,String> map_LPIDtoProductId = new Map<String,String>();
        Map<String,String> map_onlineclsIDtoLPId = new Map<String,String>();
        Map<String,String> map_onlineLPIDtoProductId = new Map<String,String>();
        //Map<String,String> map_onlineclsIDtoLearning = new Map<String,String>();
        Map<String,String> map_productIdToOrderItem = new Map<String,String>();
        Map<String,String> map_physicalSKUToProductId = new Map<String, String>();
                
        Rest_Service_Calls__c serviceLog = new Rest_Service_Calls__c();
        serviceLog.Name = 'PHSS/createOrder';
        serviceLog.Request_Method__c = 'POST';
        serviceLog.Service_Action__c = action;
        serviceLog.Payload__c = postBody;
        insert serviceLog;    
                
        /*List<CreateOrderWrapper> lst_OrderWrapper = (List<CreateOrderWrapper>)System.JSON.deserialize(postBody, List<CreateOrderWrapper>.class);
        List<ccrz__E_Order__c> lst_Orders = new List<ccrz__E_Order__c>();
        List<ccrz__E_OrderItem__c> lst_OrderItems = new List<ccrz__E_OrderItem__c>();*/
        
        //deserialize request body (JSON)
        CreateOrderWrapper OrderWrapper = (CreateOrderWrapper)System.JSON.deserialize(postBody, CreateOrderWrapper.class);
        
        // Create a savepoint before inserting any record related to orders
        Savepoint sp = Database.setSavepoint();

        //data validation
                         
        Rest_Service_Calls__c responseLog = new Rest_Service_Calls__c();
        responseLog.Name = 'PHSS/createOrder';   
        responseLog.Request_Method__c = 'POST';
        responseLog.Service_Action__c = action;     
        // Order number cannot be blank
        if(OrderWrapper.order.Order_header.order_no == NULL || OrderWrapper.order.Order_header.order_no == ''){
            ResponseWrapper responseWrap = new ResponseWrapper('Failure',301,'order_no cannot be blank.','');
            Createccorder ccorder = new Createccorder(responseWrap);
            JSONResponse jsonResp = new JSONResponse(ccorder);    
            res.responseBody = Blob.valueOf(JSON.serializePretty(jsonResp));
            
            // Write response to log
            responseLog.Response__c = JSON.serialize(jsonResp); 
            insert responseLog; 
            System.debug('Obtained Response log'+responseLog);
            return jsonResp;
        }
        // Buyer's first name,last name & email cannot be blank
        else if((OrderWrapper.order.Billing_info.first_name == NULL || OrderWrapper.order.Billing_info.first_name == '') ||
                (OrderWrapper.order.Billing_info.last_name == NULL || OrderWrapper.order.Billing_info.last_name == '') ||
                (OrderWrapper.order.Billing_info.email == NULL || OrderWrapper.order.Billing_info.email == '')){
            ResponseWrapper responseWrap = new ResponseWrapper('Failure',302,'Purchaser first name,last name or email cannot be blank.','');
            Createccorder ccorder = new Createccorder(responseWrap);
            JSONResponse jsonResp = new JSONResponse(ccorder);    
            res.responseBody = Blob.valueOf(JSON.serializePretty(jsonResp));
            
            // Write response to log
            responseLog.Response__c = JSON.serialize(jsonResp); 
            insert responseLog; 
            System.debug('Obtained Response log else'+responseLog);
            return jsonResp;
        }
        
        else{
	 		String clsILTPrefix = Schema.getGlobalDescribe().get('redwing__ILT_Class__c').getDescribe().getKeyPrefix(); 
	 		String clsOnlinePrefix = Schema.getGlobalDescribe().get('redwing__Learning__c').getDescribe().getKeyPrefix(); 	 		

            System.debug('Obtained Response log else'+responseLog);
            //check if product_id is blank for any order item
            //System.debug('ship info'+OrderWrapper.Order.order_transaction);
             
	        for(CreateOrderWrapper.Products product :OrderWrapper.order.Order_items.products){ 
		           System.debug('Considers the product json'+OrderWrapper.order.Order_items.products);
		         
		           // lst_clsId ==> List of Product Ids from order items (can be a mixture of class and physical products)
		           if (product.product_id!=NULL && product.product_id!='') {
		           		if (product.product_id.length()>2) {
		           			if (product.product_id.substring(0,3).equals(clsILTPrefix)) {
		               			lst_clsId.add(product.product_id);
		           			} else if (product.product_id.substring(0,3).equals(clsOnlinePrefix)) {
		           				lst_onlineclsId.add(product.product_id);
		           			} else lst_productId.add(product.product_id);
		           		} else lst_productId.add(product.product_id);
		           }
		           System.debug('lstclsId'+lst_clsId);
		           System.debug('lstonlineclsId'+lst_onlineclsId);
		           System.debug('lstproductid'+lst_productId);
	        }
             
            // if any product_id is missing from order item list, return error
            if (OrderWrapper.order.Order_items.products.size() != lst_clsId.size() + lst_onlineclsId.size() + lst_productId.size()) {
                ResponseWrapper responseWrap = new ResponseWrapper('Failure',303,'At least one product Id is invalid','');
                Createccorder ccorder = new Createccorder(responseWrap);
                JSONResponse jsonResp = new JSONResponse(ccorder);    
                res.responseBody = Blob.valueOf(JSON.serializePretty(jsonResp));
                
                // Write response to log
                responseLog.Response__c = JSON.serialize(jsonResp); 
                insert responseLog; 
                
                return jsonResp;
            }
            
            // The following block manages the relationship of instructor led/blended classes to cloud craze products

            // map_clsIDtoLPId ==> map of product Id (ILT Class ID) to Learning Plan Id
            if (!lst_clsId.isEmpty()) {
                for (redwing__ILT_Class__c cls : [Select Id,Learning_Plan__c From redwing__ILT_Class__c Where Id In :lst_clsId]) {
                    System.debug('cls with learning plan --->>>>' + cls.Learning_Plan__c);
                    map_clsIDtoLPId.put(String.Valueof(cls.Id).substring(0, 15), String.Valueof(cls.Learning_Plan__c).substring(0, 15));
                }

                // map_LPIDtoProductId ==> map of Learning Plan Id to Cloud Craze Product Id
                for (ccrz__E_Product__c ccp : [Select Id,LMS_Learning_Plan__c From ccrz__E_Product__c Where LMS_Learning_Plan__c In :map_clsIDtoLPId.values()]) {
                    map_LPIDtoProductId.put(String.Valueof(ccp.LMS_Learning_Plan__c).substring(0, 15), String.Valueof(ccp.Id).substring(0, 15));
                }

                System.debug('map_clsIDtoLPId-->' + map_clsIDtoLPId);
                System.debug('map_LPIDtoProductId-->' + map_LPIDtoProductId);
            }
            
            // The following block manages the relationship of online classes to cloud craze products
            
            // map_onlineclsIDtoLearning ==> map of product Id (Learning object of type Media) to Learning object Id
            if (!lst_onlineclsId.isEmpty()) {
                for (redwing__Training_Plan_Section_Item__c theLPSI : [Select Id, redwing__Learning__c, redwing__Training_Plan_Section__r.redwing__Training_Plan__c
                    From redwing__Training_Plan_Section_Item__c Where redwing__Learning__c in :lst_onlineclsId]) {
                    //map_onlineclsIDtoLearning.put(String.valueOf(theLPSI.redwing__Learning__c).substring(0, 15), String.valueOf(theLPSI.redwing__Learning__c).substring(0, 15));
                    System.debug('onlinecls with learning plan --->>>>' + theLPSI.redwing__Training_Plan_Section__r.redwing__Training_Plan__c);
                    map_onlineclsIDtoLPId.put(String.Valueof(theLPSI.redwing__Learning__c).substring(0, 15), String.Valueof(theLPSI.redwing__Training_Plan_Section__r.redwing__Training_Plan__c).substring(0, 15));
                    //map_onlineLearningToClsId.put(theLPSI.redwing__Learning__c, theLPSI.redwing__Learning__c);
                }
                /*
                // map_onlineclsIDtoLPId ==> map of Learning Id to Learning Plan Id
                for (redwing__Training_Plan_Section_Item__c theLPSI : [
                        Select Id, redwing__Training_Plan_Section__r.redwing__Training_Plan__c
                        From redwing__Training_Plan_Section_Item__c
                        Where Id In :lst_onlineclsId
                        //Where Id In :map_onlineclsIdtoLearning.values()
                ]) {
                    System.debug('onlinecls with learning plan --->>>>' + theLPSI.redwing__Training_Plan_Section__r.redwing__Training_Plan__c);
                    map_onlineclsIDtoLPId.put(String.Valueof(map_onlineLearningToClsId.get(theLPSI.Id)).substring(0, 15), String.Valueof(theLPSI.redwing__Training_Plan_Section__r.redwing__Training_Plan__c).substring(0, 15));
                }
                */
                // map_onlineLPIDtoProductId ==> map of Learning Plan Id to Cloud Craze Product Id
                for (ccrz__E_Product__c ccp : [Select Id, LMS_Learning_Plan__c From ccrz__E_Product__c Where LMS_Learning_Plan__c In :map_onlineClsIDtoLPId.values()]) {
                    map_onlineLPIDtoProductId.put(String.Valueof(ccp.LMS_Learning_Plan__c).substring(0, 15), String.Valueof(ccp.Id).substring(0, 15));
                }
            }
            
            // The following block manages the relationship of physical products to cloud craze products
            
            // map_eCommIdtoProductId ==> map of eCommerce product Id to Cloud Craze Product Id
            if (!lst_productId.isEmpty()) {
                for (ccrz__E_Product__c ccp : [Select Id, ccrz__SKU__c from ccrz__E_Product__c Where ccrz__SKU__c In :lst_productId]) {
                    map_physicalSKUtoProductId.put(ccp.ccrz__SKU__c, String.Valueof(ccp.Id).substring(0, 15));
                }
            }

            System.debug('map_onlineclsIDtoLPId-->'+map_onlineclsIDtoLPId);
            System.debug('map_LPIDtoProductId-->'+map_LPIDtoProductId); 
            System.debug('map_physicalSKUtoProductId-->'+map_physicalSKUtoProductId);           
            
            //look for existing order record
            List<ccrz__E_Order__c> lst_exisOrder = [Select Id,ccrz__BillTo__c,(Select Id,ccrz__Product__c From ccrz__E_OrderItems__r),ccrz__ShipTo__c,
                                      (Select Id From ccrz__TransactionPayments__r)
                                      From ccrz__E_Order__c 
                                      Where NSSCCConnector_SFCC_Order_Number__c = :OrderWrapper.order.Order_header.order_no];
            ccrz__E_Order__c exisOrder = new ccrz__E_Order__c();
            System.debug('Exis Order alone'+lst_exisOrder);
            
            if(lst_exisOrder.size()>0){ 
                exisOrder = lst_exisOrder[0];
                System.debug('Exis Order item detals'+exisOrder.ccrz__E_OrderItems__r);
                
                // map_productIdToOrderItem ==> map of existing order item product Id to existing order item Id
                for(ccrz__E_OrderItem__c orderitem : exisOrder.ccrz__E_OrderItems__r){
                    map_productIdToOrderItem.put(String.valueOf(orderitem.ccrz__Product__c).substring(0,15),orderitem.Id);   
                }
            }
            
            System.debug('map_productIdToOrderItem-->'+map_productIdToOrderItem);
             
            
            //if learning plan don't have related product, return error
           /* if(OrderWrapper.order.Order_items.products.size() != map_LPIDtoProductId.keySet().size()){
                ResponseWrapper responseWrap = new ResponseWrapper('Failure',304,'No Valid Product found.','');
                Createccorder ccorder = new Createccorder(responseWrap);
                JSONResponse jsonResp = new JSONResponse(ccorder);    
                res.responseBody = Blob.valueOf(JSON.serializePretty(jsonResp));
                
                // Write response to log
                responseLog.Response__c = JSON.serialize(jsonResp); 
                insert responseLog; 
                
                return jsonResp;
            } */
            
            try{
                ccrz__E_ContactAddr__c obj_contactAddress = createContactAddress(OrderWrapper,exisOrder);
                if(obj_contactAddress!=NULL){
                    upsert obj_contactAddress;
                }
                
                ccrz__E_ContactAddr__c obj_contactShipAddress = createContactShipAddress(OrderWrapper,exisOrder);
                if(obj_contactShipAddress!=NULL){
                    upsert obj_contactShipAddress;
                }

                ccrz__E_Order__c obj_order  = createOrder(OrderWrapper,obj_contactAddress,obj_contactShipAddress,exisOrder);
                if(obj_order!=NULL){
                    upsert obj_order;
                }
               
                if(obj_order.Id != NULL){
                    System.debug(obj_order);
                    System.debug(exisOrder);
                    List<ccrz__E_OrderItem__c> lst_orderItems = createOrderItems(OrderWrapper, obj_order, exisOrder,
                                                                                 map_clsIDtoLPId, map_LPIDtoProductId,
                                                                                 map_onlineclsIDtoLPId, map_onlineLPIDtoProductId,
                                                                                 map_productIdToOrderItem, map_physicalSKUtoProductId);                                                                    
                    System.debug(lst_orderItems);
                    if(lst_orderItems.size()>0){
                        upsert lst_orderItems;
                    }

                    System.debug('obj_order.Id ' + obj_order.Id );
                    System.debug([Select Id, ccrz__Order__c, ILT_Class__c,
                                    ccrz__Order__r.NSSCCConnector_SFCC_Order_Number__c
                                    From ccrz__E_OrderItem__c Where ccrz__Order__c = :obj_order.Id]);
                    System.debug([Select Id, ccrz__Order__c, ILT_Class__c,
                                    ccrz__Order__r.NSSCCConnector_SFCC_Order_Number__c
                                    From ccrz__E_OrderItem__c]);

                    System.debug([SELECT Id FROM ccrz__E_Order__c]);

                    // Obtain record ids for new order line items
                    List<ccrz__E_OrderItem__c> lst_newOrderItems = [
                            Select Id, ccrz__Order__c, ILT_Class__c,
                        ccrz__Order__r.NSSCCConnector_SFCC_Order_Number__c
                        From ccrz__E_OrderItem__c
                        Where ccrz__E_OrderItem__c.ccrz__Order__c = :obj_order.Id];
                    Set<Id> orderItemClass = new Set<Id>();
                    Set<String> orderItemOrderNo = new Set<String>();
                    for (ccrz__E_OrderItem__c theOrderItem : lst_newOrderItems) {
                    	if (theOrderItem.ILT_Class__c == null) continue;
                        orderItemClass.add(theOrderItem.ILT_Class__c);
                        orderItemOrderNo.add(theOrderItem.ccrz__Order__r.NSSCCConnector_SFCC_Order_Number__c);
                    }
                
                    //  Retrieve vouchers that correspond to product(s) purchased in this order                 
                    List<Voucher__c> vouchList = [Select Id, ILT_Class__c, RCO_Order_Id__c From Voucher__c 
                        Where ILT_Class__c IN :orderItemClass And RCO_Order_Id__c IN :orderItemOrderNo];

                    if (vouchList != null && vouchList.size() > 0) {
                        Map<Id, Id> classToVoucherMap = new Map<Id, Id>();
                        for (Voucher__c theVoucher : vouchList) {
                            classToVoucherMap.put(theVoucher.ILT_Class__c, theVoucher.Id);
                        }

                        // Populate the order and order Id fields on the corresponding voucher record for this order/product (if applicable)
                        List<Voucher__c> updateVouchList = new List<Voucher__c>();
                        for (ccrz__E_OrderItem__c theOrderItem : lst_newOrderItems) {
                            if (theOrderItem.ILT_Class__c == null) continue;
                            String theProductId = theOrderItem.ILT_Class__c;
                            if (theProductId.length() > 15) theProductId = theProductId.substring(0, 15);

                            if (theProductId != null && classToVoucherMap.containsKey(theProductId)) {
                                Voucher__c vouch = new Voucher__c();
                                vouch.Id = classToVoucherMap.get(theProductId);
                                vouch.Account__c = obj_order.ccrz__Account__c;
                                vouch.CC_Order__c = obj_order.id;
                                vouch.CC_Order_Item__c = theOrderItem.id;

                                if (map_LPIDtoProductId.containsKey(map_clsIDtoLPId.get(theProductId))) {
                                    vouch.CC_Product__c = map_LPIDtoProductId.get(map_clsIDtoLPId.get(theProductId));
                                }

                                updateVouchList.add(vouch);
                            }
                        }

                        if (!updateVouchList.isEmpty()) {
                            update updateVouchList;
                        }
                    }
                    
                    // create payment transaction detail record
                    List<ccrz__E_TransactionPayment__c> lst_paymentDetail = createPaymentDetail(OrderWrapper,obj_order,exisOrder);
                    if(lst_paymentDetail.size()>0){
                        upsert lst_paymentDetail ccrz__TransactionPaymentId__c;
                    }
                }
                
                //set success message
                ResponseWrapper responseWrap = new ResponseWrapper('Success',100,'Cloud Craze Order Successful',obj_order.Id);
                Createccorder ccorder = new Createccorder(responseWrap);
                JSONResponse jsonResp = new JSONResponse(ccorder);    
                res.responseBody = Blob.valueOf(JSON.serializePretty(jsonResp));

                // Write response to log
                responseLog.Response__c = JSON.serialize(jsonResp); 
                insert responseLog; 
                                
                return jsonResp;
                
            }catch(Exception e){
                responseWrapper responseWrap = new ResponseWrapper('Failure',501,e.getMessage(),'');
                Createccorder ccorder = new Createccorder(responseWrap);
                JSONResponse jsonResp = new JSONResponse(ccorder);    
                res.responseBody = Blob.valueOf(JSON.serializePretty(jsonResp));
                Database.rollback(sp);
                
                // Write response to log                     
                responseLog.Response__c = JSON.serialize(jsonResp); 
                insert responseLog; 
                                
                return jsonResp;
            }
        }
    }
    
    public static ccrz__E_ContactAddr__c createContactAddress(CreateOrderWrapper OrderWrapper, ccrz__E_Order__c exisOrder){
        //create contact address record
        System.debug('===InCreateCOntactAddress== ');
        ccrz__E_ContactAddr__c obj_contactAddress = new ccrz__E_ContactAddr__c();
        if(exisOrder.ccrz__BillTo__c!=NULL)
            obj_contactAddress.Id =  exisOrder.ccrz__BillTo__c;  
        if(OrderWrapper.order.order_header.payment_method !='PayPal'){
            System.debug('Not Paypaalll');
        obj_contactAddress.ccrz__FirstName__c = OrderWrapper.order.Billing_info.first_name;
        obj_contactAddress.ccrz__LastName__c = OrderWrapper.order.Billing_info.last_name;
        obj_contactAddress.ccrz__AddressFirstline__c = OrderWrapper.order.Billing_info.address1;
        obj_contactAddress.ccrz__AddressSecondline__c = OrderWrapper.order.Billing_info.address2;
        obj_contactAddress.ccrz__City__c = OrderWrapper.order.Billing_info.city;
        obj_contactAddress.ccrz__PostalCode__c = OrderWrapper.order.Billing_info.postal_code;
        obj_contactAddress.ccrz__StateISOCode__c = OrderWrapper.order.Billing_info.state_code;
        obj_contactAddress.ccrz__CountryISOCode__c = OrderWrapper.order.Billing_info.country_code;
        obj_contactAddress.ccrz__HomePhone__c = OrderWrapper.order.Billing_info.phone;
        obj_contactAddress.ccrz__Email__c = OrderWrapper.order.Billing_info.email;
        }
        else
        {
        System.debug('Paypaalll fields>>');
            for(CreateOrderWrapper.ppTransactionDtls tpd : OrderWrapper.Order.order_transaction.transaction_dtls.ppTransactionDtls)
               {
                obj_contactAddress.ccrz__FirstName__c = tpd.paypalPayerFirstName;
                obj_contactAddress.ccrz__LastName__c = tpd.paypalPayerLastName;
                obj_contactAddress.ccrz__Email__c = tpd.paypalPayerEmail;
                obj_contactAddress.ccrz__CountryISOCode__c = tpd.paypalPayerCountry;
              }
        }
        System.debug('===obj_contactAddress=='+obj_contactAddress);
        return obj_contactAddress;
    }
    
    public static ccrz__E_ContactAddr__c createContactShipAddress(CreateOrderWrapper OrderWrapper, ccrz__E_Order__c exisOrder){
        //create contact address record
        System.debug('===InCreateCOntactAddress==');
        ccrz__E_ContactAddr__c obj_contactshipAddress = new ccrz__E_ContactAddr__c();
        if(exisOrder.ccrz__ShipTo__c!=NULL)
        obj_contactshipAddress.Id =  exisOrder.ccrz__ShipTo__c;  
        obj_contactshipAddress.ccrz__FirstName__c = OrderWrapper.order.shipping_info.first_name;
        obj_contactshipAddress.ccrz__LastName__c = OrderWrapper.order.shipping_info.last_name;
        obj_contactshipAddress.ccrz__AddressFirstline__c = OrderWrapper.order.shipping_info.address1;
        obj_contactshipAddress.ccrz__AddressSecondline__c = OrderWrapper.order.shipping_info.address2;
        obj_contactshipAddress.ccrz__City__c = OrderWrapper.order.shipping_info.city;
        obj_contactshipAddress.ccrz__PostalCode__c = OrderWrapper.order.shipping_info.postal_code;
        obj_contactshipAddress.ccrz__StateISOCode__c = OrderWrapper.order.shipping_info.state_code;
        obj_contactshipAddress.ccrz__CountryISOCode__c = OrderWrapper.order.shipping_info.country_code;
        obj_contactshipAddress.ccrz__HomePhone__c = OrderWrapper.order.shipping_info.phone;
        System.debug('===obj_contactAddress=='+obj_contactshipAddress);
        return obj_contactshipAddress;
    }
    
      public static ccrz__E_Order__c createOrder(CreateOrderWrapper OrderWrapper,ccrz__E_ContactAddr__c obj_contactAddress,ccrz__E_ContactAddr__c obj_contactshipAddress,ccrz__E_Order__c exisOrder){
    //public static ccrz__E_Order__c createOrder(CreateOrderWrapper OrderWrapper,ccrz__E_ContactAddr__c obj_contactAddress,ccrz__E_Order__c exisOrder){
        System.debug(exisOrder.Id);
         //create CC order record
        ccrz__E_Order__c obj_order = new ccrz__E_Order__c();
        
        String str_AccountId='';
        String str_ContactId='';
        String strAccountshipId='';
        String strContactshipId='';
       
        //look for Contact with matching buyer name and email
        List<Contact> lst_contact = [Select Id, AccountID From Contact 
                                    Where FirstName=:OrderWrapper.order.Billing_info.first_name AND
                                    LastName=:OrderWrapper.order.Billing_info.last_name AND
                                    Email=:OrderWrapper.order.Billing_info.email];
                                    
        //look for Contact with matching shipping address name and email
        List<Contact> lst_contactship = [Select Id, AccountID From Contact 
                                    Where FirstName=:OrderWrapper.order.shipping_info.first_name AND
                                    LastName=:OrderWrapper.order.shipping_info.last_name ];
                                                                
        if(lst_contact.size()>0){
            str_ContactId = lst_contact[0].id;
            str_AccountId = lst_contact[0].AccountID;   
        }
        else{
            Account acc = new Account();
            acc.Name = OrderWrapper.order.Billing_info.first_name + ' ' + OrderWrapper.order.Billing_info.last_name;
            acc.Email__c = OrderWrapper.order.Billing_info.email;
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual Account').getRecordTypeId();
            insert acc;
            
            Contact con = new Contact();
            con.FirstName = OrderWrapper.order.Billing_info.first_name;
            con.LastName = OrderWrapper.order.Billing_info.last_name;
            con.Email = OrderWrapper.order.Billing_info.email;
            con.AccountId = acc.id;
            insert con;
            
            str_AccountId = acc.id;
            str_ContactId = con.id; 
        }
        if(lst_contactship.size()>0){
          strAccountshipId = lst_contactship[0].id;
          strContactshipId = lst_contactship[0].AccountID;
        }
        else{
            Account accsh = new Account();
            accsh.Name = OrderWrapper.order.shipping_info.first_name + ' ' + OrderWrapper.order.shipping_info.last_name;
            accsh.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual Account').getRecordTypeId();
          //accsh.Email__c = OrderWrapper.order.shipping_info.email;
            insert accsh;
            
            Contact consh = new Contact();
            consh.FirstName = OrderWrapper.order.shipping_info.first_name;
            consh.LastName = OrderWrapper.order.shipping_info.last_name;
          //consh.Email = OrderWrapper.order.shipping_info.email;
            consh.AccountId = accsh.id;
            insert consh;
            
            str_AccountId = accsh.id;
            str_ContactId = consh.id; 
        }
        obj_order.ccrz__Account__c = str_AccountId;
        obj_order.ccrz__Contact__c = str_ContactId;
        
        obj_order.ccrz__BillTo__c = obj_contactAddress.id;
        obj_order.ccrz__ShipTo__c = obj_contactShipAddress.id;
        if (String.isNotBlank(OrderWrapper.order.shipping_info.company_name)) {
           obj_order.ccrz__BuyerCompanyName__c = OrderWrapper.order.shipping_info.company_name;
        } else if (String.isNotBlank(OrderWrapper.order.billing_info.company_name)) {
           obj_order.ccrz__BuyerCompanyName__c = OrderWrapper.order.billing_info.company_name;
        }
        //; depends on billing/shipping


        if(OrderWrapper.order.order_header.payment_method !='PayPal'){
        obj_order.ccrz__BuyerFirstName__c = OrderWrapper.order.Billing_info.first_name;
        obj_order.ccrz__BuyerLastName__c = OrderWrapper.order.Billing_info.last_name;
        obj_order.ccrz__BuyerEmail__c = OrderWrapper.order.Billing_info.email;
        }
        else
        for(CreateOrderWrapper.ppTransactionDtls tpd : OrderWrapper.Order.order_transaction.transaction_dtls.ppTransactionDtls)
        {
        obj_order.ccrz__BuyerFirstName__c = tpd.paypalPayerFirstName;
        obj_order.ccrz__BuyerLastName__c = tpd.paypalPayerLastName;
        obj_order.ccrz__BuyerEmail__c = tpd.paypalPayerEmail;
        }
        obj_order.ccrz__BuyerPhone__c = OrderWrapper.order.Billing_info.phone;
        if(exisOrder.Id!=NULL)
            obj_order.Id = exisOrder.Id;
        obj_order.NSSCCConnector_SFCC_Order_Number__c = OrderWrapper.order.Order_header.order_no;
        obj_order.ccrz__CurrencyISOCode__c = OrderWrapper.order.Order_header.currency_code;
        DateTime t = (DateTime)json.deserialize('"' + OrderWrapper.order.Order_header.creation_date +'"', datetime.class);
        obj_order.ccrz__OrderDate__c = t.date();
        obj_order.ccrz__OrderStatus__c = 'Shipped';
        obj_order.ccrz__Storefront__c = 'GeneralStore';
        if (OrderWrapper.order.Order_header.total_discount != null) {
           obj_order.ccrz__AdjustmentAmount__c = OrderWrapper.order.Order_header.total_discount;
           obj_order.ccrz__AdjustmentReason__c = OrderWrapper.order.Order_header.promotion_ids;
        }
        obj_order.Coupon_Codes__c = OrderWrapper.order.Order_header.coupon_codes;
        obj_order.ccrz__TaxAmount__c = OrderWrapper.order.Order_header.tax_total;
        //obj_order.ccrz__ShipAmount__c = OrderWrapper.order.Order_header.shipping_total;

        // Mark the flag to true to bypass PB - 'Order Status Controller'
        obj_order.NSSCCConnector_from_SFCC__c = true;
        //obj_order.ccrz__ShipMethod__c = OrderWrapper.order.Order_header.shipping_method; // As per new Json changes - newly added
        System.debug('obj_order--->'+obj_order);
        return obj_order;
    }

    public static List<ccrz__E_OrderItem__c> createOrderItems(CreateOrderWrapper OrderWrapper,ccrz__E_Order__c obj_order,ccrz__E_Order__c exisOrder,
    														  Map<String,String> map_clsIDtoLPId, Map<String,String> map_LPIDtoProductId, 
                                                              Map<String,String> map_onlineclsIDtoLPId, Map<String,String> map_onlineLPIDtoProductId, 
                                                              Map<String,String> map_productIdToOrderItem, Map<String,String> map_physicalSKUtoProductId){
        List<ccrz__E_OrderItem__c> lst_orderItems = new List<ccrz__E_OrderItem__c>();
        //getting values of order item
        for(CreateOrderWrapper.Products product :OrderWrapper.order.Order_items.products){ 
            	system.debug('product -->   '+product);

                System.debug(obj_order.Id);
                System.debug(exisOrder);
            	
                ccrz__E_OrderItem__c obj_orderitem = new ccrz__E_OrderItem__c();
                obj_orderitem.ccrz__Order__c = obj_order.id;
                obj_orderitem.ccrz__StoreId__c = OrderWrapper.order.Order_header.created_by;

                String theProductId = product.product_id;
                if (theProductId.length()>15) theProductId = theProductId.substring(0,15);
                String inventoryType = '';
                
                if (map_clsIDtoLPId.containsKey(theProductId)) {
                    obj_orderitem.ILT_Class__c = theProductId;
                } else if (map_onlineclsIDtoLPId.containsKey(theProductId)) {
                	// obj_orderitem.Online_Class__c = theProductId;  // can't load record Id of online learning object
                }
                
                System.debug('Product ID--->'+product.product_id);
                //System.debug('map_clsIDtoLPId--->'+map_clsIDtoLPId);
                //System.debug('map_LPIDtoProductId--->'+map_LPIDtoProductId);
                //System.debug('LPID--->'+map_clsIDtoLPId.get(theProductId));
                //System.debug('CCProductID--->'+map_LPIDtoProductId.get(map_clsIDtoLPId.get(theProductId)));
                
                // Ignore physical products except for shipping for now
                if (map_clsIDtoLPId.get(theProductId) == null &&
                	map_onlineclsIDtoLPId.get(theProductId) == null &&
                	map_physicalSKUtoProductId.get(theProductId) == null) continue;
                
                // Derive order item Id if product is an ILT Class
                if (map_clsIDtoLPId.get(theProductId) != null) {       	
	                if (map_LPIDtoProductId.containsKey(map_clsIDtoLPId.get(theProductId))) {
	                    obj_orderitem.ccrz__Product__c = map_LPIDtoProductId.get(map_clsIDtoLPId.get(theProductId));
                        inventoryType = 'COMMUNITY';

	                    if (map_productIdToOrderItem.containskey(obj_orderitem.ccrz__Product__c)) {
	                        if (map_productIdToOrderItem.get(obj_orderitem.ccrz__Product__c) != NULL) {
	                            obj_orderitem.Id = map_productIdToOrderItem.get(obj_orderitem.ccrz__Product__c);
	                            System.debug('ILT class orderItemId-->'+map_productIdToOrderItem.get(obj_orderitem.ccrz__Product__c));
	                        } 
	                    } 
	                } 
	            // Derive order item Id if product is an online class
                } else if (map_onlineclsIDtoLPId.get(theProductId) != null) {
	                if (map_onlineLPIDtoProductId.containsKey(map_onlineclsIDtoLPId.get(theProductId))) {
	                    obj_orderitem.ccrz__Product__c = map_onlineLPIDtoProductId.get(map_onlineclsIDtoLPId.get(theProductId));
                        inventoryType = 'COURSE';

	                    if (map_productIdToOrderItem.containskey(obj_orderitem.ccrz__Product__c)) {
	                        if (map_productIdToOrderItem.get(obj_orderitem.ccrz__Product__c) != NULL) {
	                            obj_orderitem.Id = map_productIdToOrderItem.get(obj_orderitem.ccrz__Product__c);
	                            System.debug('Online class orderItemId-->'+obj_orderitem.Id);
	                        } 
	                    } 
	                }   
	            // Derive order item Id if product is a physical product              		
                } else if (map_physicalSKUtoProductId.get(theProductId) != null) {
                	obj_orderitem.ccrz__Product__c = map_physicalSKUtoProductId.get(theProductId);
                    inventoryType = 'STANDARD';

                    if (map_productIdToOrderItem.containskey(theProductId)) {
                        obj_orderitem.Id = map_productIdToOrderItem.get(theProductId);
                        System.debug('Physical product orderItemId-->'+map_productIdToOrderItem.get(theProductId));
                	}
                }
                
                System.debug('obj_orderitem-->'+obj_orderitem);
                
                obj_orderitem.ccrz__ItemLabel__c = product.product_name;
                
                if(product.product_type == 'offering')
                    obj_orderitem.Inventory_Type__c = inventoryType; // COURSE or COMMUNITY as appropriate
                else if(product.product_type == 'physical')
                    obj_orderitem.Inventory_Type__c = 'STANDARD'; 
                else obj_orderitem.Inventory_Type__c = 'FEE'; // Treat all other product_type values as a Fee
 
                System.debug('Inventory Type--->'+obj_orderitem.Inventory_Type__c);
                System.debug(obj_orderitem);

                obj_orderitem.ccrz__Quantity__c = (product.quantity != null) ? product.quantity : 0;
                obj_orderitem.ccrz__OriginalQuantity__c = (product.quantity != null) ? product.quantity : 0;
                obj_orderitem.ccrz__Price__c = (product.price != null) ? product.price : 0.00;
                obj_orderitem.ccrz__AdjustmentAmount__c  =  (product.adjustment_amount != null) ? product.adjustment_amount : 0.00;
                obj_orderitem.ccrz__OriginalItemPrice__c = (product.original_price != null) ? product.original_price : 0.00;
                obj_orderitem.ccrz__SubAmount__c = (obj_orderitem.ccrz__Price__c * obj_orderitem.ccrz__Quantity__c) - obj_orderitem.ccrz__AdjustmentAmount__c;

                // Commented after validation rule on reason code deactivated
                //obj_orderitem.Adjustment_Types__c = 'Course Credit Adjustment';
                //obj_orderitem.Reason_Codes__c = 'Duplicate';
                //obj_orderitem.ccrz__OriginalItemPrice__c = product.base_price;
                //obj_orderitem.ccrz__TaxAmount__c = product.adjusted_tax;

                obj_orderitem.ccrz__OrderLineType__c = 'Major';
                obj_orderitem.ccrz__UnitOfMeasure__c = 'Each';
                obj_orderitem.ccrz__OrderItemStatus__c = 'Shipped';
                obj_orderitem.ccrz__ProductType__c = 'Product';
                obj_orderitem.ccrz__PricingType__c = 'external';
              
                System.debug('Sub Amount--->'+ obj_orderitem.ccrz__SubAmount__c);

                lst_orderItems.add(obj_orderitem);
                System.debug('lst_orderItems--->'+lst_orderItems);
        }
        System.debug('lst_orderItems--->'+lst_orderItems);
        return lst_orderItems;
    }
    
    public static List<ccrz__E_TransactionPayment__c> createPaymentDetail(CreateOrderWrapper OrderWrapper,ccrz__E_Order__c obj_order,ccrz__E_Order__c exisOrder){
        System.debug('Transaction Payment gettng inside>>>>>');
        ccrz__E_TransactionPayment__c obj_paymentDetails = new ccrz__E_TransactionPayment__c();
        List<ccrz__E_TransactionPayment__c> lst_paymentDetail = new List<ccrz__E_TransactionPayment__c>();
        //if(exisOrder!=null && exisOrder.Id != NULL && exisOrder.ccrz__TransactionPayments__r[0].id!=NULL)
        if(OrderWrapper.Order.order_transaction.transaction_dtls.ccTransactionDtls.size()>0){
        for(CreateOrderWrapper.ccTransactionDtls trd : OrderWrapper.Order.order_transaction.transaction_dtls.ccTransactionDtls)
        {
            System.debug('Transaction Payment issueee>>>>>');
            /*if(exisOrder!=null){
              System.debug('Transaction Payment Order present>>>>>');
                if(exisOrder.Id != NULL)
                {
                 if(exisOrder.ccrz__TransactionPayments__r.size()>0)
                 {
                 if(exisOrder.ccrz__TransactionPayments__r[0].id!=NULL)
                    System.debug('Transaction Payment Order failed>>>>>');
                    obj_paymentDetails.Id = exisOrder.ccrz__TransactionPayments__r[0].id;
                 }
                }
            }*/
            System.debug('Transaction Payment issueee2222>>>>>');
            obj_paymentDetails.ccrz__CCOrder__c = obj_order.id;
            obj_paymentDetails.ccrz__Account__c = obj_order.ccrz__Account__c;
            obj_paymentDetails.ccrz__Contact__c = obj_order.ccrz__Contact__c;
            obj_paymentDetails.ccrz__Address__c = obj_order.ccrz__BillTo__c;
            obj_paymentDetails.ccrz__CCOrder__c = obj_order.Id;
            obj_paymentDetails.ccrz__TransactionType__c = trd.transacrtion_type;
            obj_paymentDetails.ccrz__TransactionTS__c = trd.transaction_time;
            obj_paymentDetails.ccrz__TransactionPaymentId__c = trd.transaction_id;
            obj_paymentDetails.ccrz__RequestAmount__c = decimal.valueOf(trd.auth_request_amount);
            //obj_paymentDetails.ccrz__Storefront__c = trd.storefront;
            obj_paymentDetails.ccrz__PaymentType__c = trd.payment_type;
            obj_paymentDetails.ccrz__Token__c = trd.token;
            obj_paymentDetails.ccrz__ExpirationYear__c = trd.cc_exp_year;
            obj_paymentDetails.ccrz__ExpirationMonth__c = trd.cc_exp_month;
            //obj_paymentDetails.ccrz__VerificationCode__c = OrderWrapper.Order.order_transaction.authCode;
            lst_paymentDetail.add(obj_paymentDetails);
        }
        }
         List<String> exiscontactppFirstName = new list<String>();
         List<String> exiscontactppLastName = new list<String>();
         List<String> exiscontactppEmail = new list<String>();
        //Paypal transaction Fields
        if(OrderWrapper.Order.order_transaction.transaction_dtls.ppTransactionDtls.size()>0){

        for(CreateOrderWrapper.ppTransactionDtls tpd : OrderWrapper.Order.order_transaction.transaction_dtls.ppTransactionDtls)
           {
            obj_paymentDetails = new ccrz__E_TransactionPayment__c();
            obj_paymentDetails.ccrz__CCOrder__c = obj_order.id;
            obj_paymentDetails.ccrz__Account__c = obj_order.ccrz__Account__c;
            obj_paymentDetails.ccrz__Contact__c = obj_order.ccrz__Contact__c;
            obj_paymentDetails.ccrz__Address__c = obj_order.ccrz__BillTo__c;
            obj_paymentDetails.ccrz__TransactionTS__c = tpd.transaction_time;
            obj_paymentDetails.ccrz__TransactionPaymentId__c = tpd.paypalTransactionID;
            obj_paymentDetails.ccrz__Amount__c = decimal.Valueof(tpd.auth_capture_amount);
            obj_paymentDetails.ccrz__RequestAmount__c = decimal.valueOf(tpd.auth_request_amount);
            obj_paymentDetails.ccrz__Token__c = tpd.paypalToken;
            obj_paymentDetails.ccrz__PaymentType__c = 'PayPal';   
            lst_paymentDetail.add(obj_paymentDetails);
            }
        }
        System.debug('Paypal idsss'+lst_paymentDetail);
        //Find Existing Contact
        
        
        //Upsert order with contact and account details:
        //obj_paymentDetails.ccrz__TransactionSubcode__c = OrderWrapper.order.Order_header.approvalStatus;
        //obj_paymentDetails.ccrz__TransactionSubcode__c = OrderWrapper.order.Order_header.authorization_status;
        //obj_paymentDetails.ccrz__BillTo__c = obj_order.ccrz__Account__c;
        //obj_paymentDetails.ccrz__Contact__c = OrderWrapper.order.student_info.customer_no;
        //System.debug('lst_paymentDetail------>'+lst_paymentDetail);
            
        return lst_paymentDetail;
    }
    
    global class JsonResponse {
        Createccorder createccorder;
        
        JsonResponse(Createccorder ccOrder) {
            this.Createccorder = ccOrder;
        }
    }
    
    global class Createccorder {
        ResponseWrapper response;
        
        Createccorder(ResponseWrapper res) {
            this.response = res;
        }
      }
     global class ResponseWrapper{
        public String ErrorMessage;
        public Integer Errorcode;
        public String status;
        public String OrderId;
        
        ResponseWrapper(String status, Integer Errorcode,String ErrorMessage,String OrderId) {
            this.ErrorMessage = ErrorMessage;
            this.Errorcode = Errorcode;
            this.status = status;
            this.OrderId = OrderId;
        }
    }
    
}