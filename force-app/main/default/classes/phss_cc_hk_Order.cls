/**
 * Created by jbarker on 10/24/18.
 */

global with sharing class phss_cc_hk_Order extends ccrz.cc_hk_Order {

    private static final String VOUCHER_RESERVED_STATUS     = 'Reserved';

    /*
    
    global override Map<String, Object> createTransaction(Map<String, Object> inputData) {
        System.debug('JASON:  phss_cc_hk_Order.createTransaction()');

        System.debug('inputData:');
        for (String key : inputData.keySet()) {
            Object value = inputData.get(key);
            System.debug(key + ': ' + value);

            if (value instanceof Map<String, Object>) {
                Map<String, Object> m = (Map<String, Object>) value;
                for (String k : m.keySet()) {
                    System.debug(key + '.' + k + ': ' + m.get(k));
                }
            }
        }
        System.debug('inputData [DONE]');

        Map<String, Object> result = super.createTransaction(inputData);

        System.debug('result:');
        for (String key : result.keySet()) {
            Object value = result.get(key);
            System.debug(key + ': ' + value);

            if (value instanceof Map<String, Object>) {
                Map<String, Object> m = (Map<String, Object>) value;
                for (String k : m.keySet()) {
                    System.debug(key + '.' + k + ': ' + m.get(k));
                }
            }

            if (value instanceof ccrz__E_TransactionPayment__c) {
                System.debug('TRANSACTION PAYMENT');
                ccrz__E_TransactionPayment__c transactionPayment = (ccrz__E_TransactionPayment__c) value;
                Map<String,Object> fields = transactionPayment.getPopulatedFieldsAsMap();
                for (String fieldName : fields.keySet()) {
                    System.debug(fieldName + ': ' + fields.get(fieldName));
                }
            }
        }
        System.debug('result [DONE]');

        return result;
    }

     */

    /**
     *
     *
     * @param inputData
     *
     * @return
     */
    global override Map<String,Object> place(Map<String,Object> inputData)
    {
        final String currentStep = (String) inputData.get(ccrz.cc_hk_Order.PARAM_PLACE_STEP);

        if (currentStep.equals(ccrz.cc_hk_Order.STEP_CREATE_ORDER_ITEMS_POST)) {
            createOrderItemsPost(inputData);
        }

        return inputData;
    }

    /**
     * Adds the ILT Class to the Order Item
     *
     * @param inputData
     */
    private void createOrderItemsPost(Map<String,Object> inputData) {

        ccrz__E_Order__c order = (ccrz__E_Order__c) inputData.get(ccrz.cc_hk_Order.PARAM_ORDER);

        // build set of Cart Item Ids
        final Set<String> cartItemIds = new Set<String>();
        for (ccrz__E_CartItem__c cartItem : (List<ccrz__E_CartItem__c>) inputData.get(ccrz.cc_hk_Order.PARAM_CART_ITEMS)) {
            cartItemIds.add(cartItem.Id);
        }

        // build map of SKU => Cart Item
        final Map<String,ccrz__E_CartItem__c> cartItemsMap = new Map<String, ccrz__E_CartItem__c>();
        List<ccrz__E_CartItem__c> cartItems = [
                SELECT ccrz__Product__r.ccrz__SKU__c, ILT_Class__c, Coupon__c
                  FROM ccrz__E_CartItem__c
                 WHERE Id IN :cartItemIds
        ];
        for (ccrz__E_CartItem__c cartItem : cartItems) {
            cartItemsMap.put(cartItem.ccrz__Product__r.ccrz__SKU__c, cartItem);
        }

        // build set of Order Item Ids
        final Set<String> orderItemIds = new Set<String>();
        List<ccrz__E_OrderItem__c> orderItems = (List<ccrz__E_OrderItem__c>) inputData.get(ccrz.cc_hk_Order.PARAM_ORDER_ITEMS);
        for (ccrz__E_OrderItem__c orderItem : orderItems) {
            orderItemIds.add(orderItem.Id);
        }

        orderItems = [
                SELECT ccrz__Product__r.ccrz__SKU__c, ILT_Class__c
                  FROM ccrz__E_OrderItem__c
                 WHERE Id IN :orderItemIds
        ];

        // build map of Cart Item Ids to Vouchers
        final Map<String, List<Voucher__c>> cartItemVouchersMap = new Map<String, List<Voucher__c>>();
        List<Voucher__c> allVouchers = [
                SELECT Id, ILT_Class__c, CC_Cart_Item__c, CC_Order__c, CC_Order_Item__c
                FROM Voucher__c
                WHERE CC_Cart_Item__c IN :cartItemIds
        ];
        for (Voucher__c voucher : allVouchers) {
            List<Voucher__c> cartItemVouchers = (List<Voucher__c>) cartItemVouchersMap.get(voucher.CC_Cart_Item__c);
            if (cartItemVouchers == null) {
                cartItemVouchers = new List<Voucher__c>();
                cartItemVouchersMap.put(voucher.CC_Cart_Item__c, cartItemVouchers);
            }
            cartItemVouchers.add(voucher);
        }

        for (ccrz__E_OrderItem__c orderItem : orderItems) {
            ccrz__E_CartItem__c cartItem = cartItemsMap.get(orderItem.ccrz__Product__r.ccrz__SKU__c);
            
            if (cartItem != null && cartItem.Coupon__c != null) {
            	orderItem.Coupon__c	     = cartItem.Coupon__c;
                orderItem.Coupon_Used__c = true;
            }
            
            if (cartItem != null && cartItem.ILT_Class__c != null) {
                orderItem.ILT_Class__c = cartItem.ILT_Class__c;

                List<Voucher__c> vouchers = cartItemVouchersMap.get(cartItem.Id);
                if (vouchers != null) {
                    for (Voucher__c voucher : vouchers) {
                        voucher.Status__c = VOUCHER_RESERVED_STATUS;
                        voucher.CC_Order__c = order.Id;
                        voucher.CC_Order_Item__c = orderItem.Id;
                    }
                }
            }
        }


        update orderItems;

        if (allVouchers.size() > 0) {
            update allVouchers;
        }
    }
}