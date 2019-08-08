public with sharing class cc_lx_CartManagerV2 {

    @TestVisible
    private static Integer API_VERSION = 4;

    public static final String ENCRYPTED_ID_KEY = 'encryptedId';
    public static final String CART_ITEMS_KEY = 'ECartItemsS';
    public static final String PRODUCT_KEY = 'product';
    public static final String SFID_KEY = 'sfid';
    public static final String PRODUCT_ITEM_KEY = 'productItem';
    public static final String QUANTITY_KEY = 'quantity';
    public static final String SKU_KEY = 'sku';
    public static final String PRODUCT_ID_KEY = 'id';
    public static final string CARTSTATUS_CLOSED = 'Closed';
    public static final string ORDERSTATUS_ORDERSUBMITTED = 'Order Submitted';


    public static String createCart() {
        String data = null;

        Map<String, Object> request = new Map<String, Object>{
                ccrz.ccApi.API_VERSION => API_VERSION
        };

        Map<String, Object> response = null;

        try {
            response = ccrz.ccAPICart.create(request);
            Boolean isSuccess = (Boolean) response.get(ccrz.ccAPI.SUCCESS);
            if (isSuccess) {
                data = (String) response.get(ccrz.ccApiCart.CART_ENCID);
                
                // change the account on the newly created  cart using the account passed fromlightning cpmponent
                ccrz__E_Cart__c cart = getCartObject(data);
                cart.ccrz__Account__c = cc_lx_AccountManagerV2.currentContext.effAccountId;
                update cart;
            }
        } catch (Exception e) {
            System.debug(e);
            System.debug(System.LoggingLevel.ERROR, e.getMessage());
            throw new CartManagerException(e.getMessage());
        }
        return data;
    }

    public static void addToCart(String cartId, String theId, String sku, Integer qty) {
        addToCart(cartId, new List<Object>{
                new Map<String, Object>{
                        PRODUCT_ID_KEY => theId, SKU_KEY => sku, QUANTITY_KEY => qty
                }
        });
    }

    public static void addToCart(String cartId, List<Object> items) {
        String errorMessage = null;

        List<ccrz.ccApiCart.LineData> newLines = new List<ccrz.ccApiCart.LineData>();
        for (Object o : items) {
            Map<String, Object> item = (Map<String, Object>) o;
            ccrz.ccApiCart.LineData newLine = new ccrz.ccApiCart.LineData();
            newLine.productId = (String) item.get(PRODUCT_ID_KEY);
            newLine.sku = (String) item.get(SKU_KEY);
            newLine.quantity = (Integer) item.get(QUANTITY_KEY);
            newLines.add(newLine);
        }

        Map<String, Object> request = new Map<String, Object>{
                ccrz.ccApi.API_VERSION => API_VERSION,
                ccrz.ccApiCart.CART_ENCID => cartId,
                ccrz.ccApiCart.LINE_DATA => newLines
        };

        Map<String, Object> response = null;

        Savepoint sp = Database.setSavepoint();//Start transaction scope
        try {
            response = ccrz.ccAPICart.addTo(request);
            Boolean isSuccess = (Boolean) response.get(ccrz.ccAPI.SUCCESS);
            if (!isSuccess) {
                Database.rollback(sp);
                List<ccrz.cc_bean_Message> messageList = (List<ccrz.cc_bean_Message>) response.get(ccrz.ccApi.MESSAGES);
                String message = 'Add to cart failed.';
                if (messageList != null && !messageList.isEmpty()) {
                    for (ccrz.cc_bean_Message m : messageList) {
                        message += ' ' + m.message;
                    }
                }
                errorMessage = message;
            }
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug(System.LoggingLevel.ERROR, e.getMessage());
            throw new CartManagerException(e.getMessage());
        }

        if (errorMessage != null) {
            System.debug(System.LoggingLevel.ERROR, errorMessage);
            throw new CartManagerException(errorMessage);
        }

    }

    public static void removeFromCart(String cartId, String item) {
        removeFromCart(cartId, new Set<String>{
                item
        });
    }

    public static void removeFromCart(String cartId, Set<String> items) {
        String errorMessage = null;

        List<ccrz.ccApiCart.LineData> removedLines = new List<ccrz.ccApiCart.LineData>();
        for (String i : items) {
            ccrz.ccApiCart.LineData removeLine = new ccrz.ccApiCart.LineData();
            removeLine.sfid = i;
            removedLines.add(removeLine);
        }

        Map<String, Object> request = new Map<String, Object>{
                ccrz.ccApi.API_VERSION => API_VERSION,
                ccrz.ccApiCart.CART_ENCID => cartId,
                ccrz.ccApiCart.LINE_DATA => removedLines
        };

        Map<String, Object> response = null;

        Savepoint sp = Database.setSavepoint();//Start transaction scope
        try {
            response = ccrz.ccAPICart.removeFrom(request);
            Boolean isSuccess = (Boolean) response.get(ccrz.ccAPI.SUCCESS);
            if (!isSuccess) {
                Database.rollback(sp);
                List<ccrz.cc_bean_Message> messageList = (List<ccrz.cc_bean_Message>) response.get(ccrz.ccApi.MESSAGES);
                String message = 'Remove from cart failed.';
                if (messageList != null && !messageList.isEmpty()) {
                    for (ccrz.cc_bean_Message m : messageList) {
                        message += ' ' + m.message;
                    }
                }
                errorMessage = message;
            }
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug(System.LoggingLevel.ERROR, e.getMessage());
            throw new CartManagerException(e.getMessage());
        }

        if (errorMessage != null) {
            System.debug(System.LoggingLevel.ERROR, errorMessage);
            throw new CartManagerException(errorMessage);
        }
    }

    public static Map<String, Object> getActiveCart() {
        Map<String, Object> data = null;

        Map<String, Object> request = new Map<String, Object>{
                ccrz.ccApi.API_VERSION => API_VERSION,
                // Dlont use current user id to search cart.
                // use the userid sent by the lightning component which is the owner aof the account
                //ccrz.ccAPICart.BYOWNER => ccrz.cc_CallContext.currUserId,
                ccrz.ccAPICart.BYOWNER => cc_lx_AccountManagerV2.currentContext.portalUserId,
                ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_M,
                ccrz.ccAPICart.ACTIVECART => true
        };

        Map<String, Object> response = null;

        try {
            response = ccrz.ccAPICart.fetch(request);
            Boolean isSuccess = (Boolean) response.get(ccrz.ccAPI.SUCCESS);
            if (isSuccess) {
                List<Map<String, Object>> outputCartList = (List<Map<String, Object>>) response.get(ccrz.ccAPICart.CART_OBJLIST);
                if (outputCartList != null && !outputCartList.isEmpty()) {
                    data = outputCartList[0];
                    List<Map<String, Object>> productList = (List<Map<String, Object>>) response.get(ccrz.ccAPIProduct.PRODUCTLIST);
                    if (productList != null && !productList.isEmpty()) {
                        addProductToCart(data, productList);
                    }
                }
            }
        } catch (Exception e) {
            System.debug(System.LoggingLevel.ERROR, e.getMessage());
            throw new CartManagerException(e.getMessage());
        }
        return data;
    }

    public static String getActiveCartId() {
    /*
        String cartId = null;
        Map<String, Object> data = cc_lx_CartManagerV2.getActiveCart();
        if (data != null) {
            cartId = (String) data.get(cc_lx_CartManagerV2.ENCRYPTED_ID_KEY);
        } else {
            cartId = cc_lx_CartManagerV2.createCart();
        }
        return cartId;
        */
        return cc_lx_AccountManagerV2.currentContext.cartId;
    }

    public static Map<String, Object> getCart(String theId) {
        Map<String, Object> data = null;

        Map<String, Object> request = new Map<String, Object>{
                ccrz.ccApi.API_VERSION => API_VERSION,
                ccrz.ccAPICart.CART_ENCID => theId
        };

        Map<String, Object> response = null;

        try {
            response = ccrz.ccAPICart.fetch(request);
            Boolean isSuccess = (Boolean) response.get(ccrz.ccAPI.SUCCESS);
            if (isSuccess) {
                List<Map<String, Object>> outputCartList = (List<Map<String, Object>>) response.get(ccrz.ccAPICart.CART_OBJLIST);
                if (outputCartList != null && !outputCartList.isEmpty()) {
                    data = outputCartList[0];
                    List<Map<String, Object>> productList = (List<Map<String, Object>>) response.get(ccrz.ccAPIProduct.PRODUCTLIST);
                    if (productList != null && !productList.isEmpty()) {
                        addProductToCart(data, productList);
                    }
                }
            }
        } catch (Exception e) {
            System.debug(System.LoggingLevel.ERROR, e.getMessage());
            throw new CartManagerException(e.getMessage());
        }
        return data;
    }

    public static ccrz__E_Cart__c getCartObject(String theId) {
        ccrz__E_Cart__c data = null;

        Map<String, Object> request = new Map<String, Object>{
                ccrz.ccApi.API_VERSION => API_VERSION,
                ccrz.ccAPICart.CART_ENCID => theId,
                ccrz.ccApi.SIZING => new Map<String, Object>{
                        ccrz.ccAPICart.ENTITYNAME => new Map<String, Object>{
                                ccrz.ccAPI.SZ_SKIPTRZ => true,
                                ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_XL
                        }
                }
        };

        Map<String, Object> response = null;

        try {
            response = ccrz.ccAPICart.fetch(request);
            Boolean isSuccess = (Boolean) response.get(ccrz.ccAPI.SUCCESS);
            if (isSuccess) {
                List<ccrz__E_Cart__c> outputCartList = (List<ccrz__E_Cart__c>) response.get(ccrz.ccAPICart.CART_OBJLIST);
                if (outputCartList != null && !outputCartList.isEmpty()) {
                    data = outputCartList[0];
                    /*List<Map<String, Object>> productList = (List<Map<String, Object>>) response.get(ccrz.ccAPIProduct.PRODUCTLIST);
                    if (productList != null && !productList.isEmpty()) {
                        addProductToCart(data, productList);
                    }*/
                }
            }
        } catch (Exception e) {
            System.debug(System.LoggingLevel.ERROR, e.getMessage());
            throw new CartManagerException(e.getMessage());
        }
        return data;
    }

    public static Map<String, Object> getCartForCheckout(String theId) {
        Map<String, Object> data = null;

        Map<String, Object> request = new Map<String, Object>{
                ccrz.ccApi.API_VERSION => API_VERSION,
                ccrz.ccAPICart.CART_ENCID => theId,
                ccrz.ccAPI.SIZING => new Map<String, Object>{
                        ccrz.ccAPICart.ENTITYNAME => new Map<String, Object>{
                                ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_XL // we need this to get the note
                        }
                }
        };

        Map<String, Object> response = null;

        try {
            response = ccrz.ccAPICart.fetch(request);
            Boolean isSuccess = (Boolean) response.get(ccrz.ccAPI.SUCCESS);
            if (isSuccess) {
                List<Map<String, Object>> outputCartList = (List<Map<String, Object>>) response.get(ccrz.ccAPICart.CART_OBJLIST);
                if (outputCartList != null && !outputCartList.isEmpty()) {
                    data = outputCartList[0];
                    List<Map<String, Object>> productList = (List<Map<String, Object>>) response.get(ccrz.ccAPIProduct.PRODUCTLIST);
                    if (productList != null && !productList.isEmpty()) {
                        addProductToCart(data, productList);
                    }
                }
            }
        } catch (Exception e) {
            System.debug(System.LoggingLevel.ERROR, e.getMessage());
            throw new CartManagerException(e.getMessage());
        }
        return data;
    }

    private static void addProductToCart(Map<String, Object> cart, List<Map<String, Object>> productList) {
        Map<String, Map<String, Object>> productMap = new Map<String, Map<String, Object>>();
        for (Map<String, Object> m : productList) {
            String key = (String) m.get(SFID_KEY);
            productMap.put(key, m);
        }
        List<Map<String, Object>> items = (List<Map<String, Object>>) cart.get(CART_ITEMS_KEY);
        for (Map<String, Object> item : items) {
            String key = (String) item.get(PRODUCT_KEY);
            Map<String, Object> productItem = productMap.get(key);
            item.put(PRODUCT_ITEM_KEY, productItem);
        }
    }

    public static Id placeOrder(String cartId, String paymentData) {
        Id orderID = null;
        try {
            if (cartId != null) {
                ccrz__E_TransactionPayment__c transactionPayment = null;
                //create the payment hook
                ccrz.cc_hk_Payment paymentHook = ccrz.cc_hk_Payment.getInstance(null);
                ccrz.cc_hk_Order orderHook = ccrz.cc_hk_Order.getInstance(null);
                ccrz__E_Cart__c cart = getCartObject(cartId);

                Map<string, object> paymentResult = paymentHook.processPayment(new Map<String, Object>{
                        ccrz.cc_hk_Payment.PARAM_TRANSACTION_DATA => paymentData
                        , ccrz.cc_hk_Payment.PARAM_CART => cart
                        , ccrz.cc_hk_Payment.PARAM_PAYMENT_CTX => ccrz.cc_hk_Payment.PARAM_PAYMENT_CTX_CHECKOUT
                });

                // "Fixing" cart issue.
                // TODO: Do this right, this is a workaround. Will require a change in CCRZ code.
                cart.ccrz__ValidationStatus__c = 'CartAuthUserValidated';
                update cart;

                final String payAccountType = (String) paymentResult.get(ccrz.cc_hk_Payment.PARAM_ACCOUNT_TYPE);
                final ccrz.ccPaymentProcessor payProcessor = (ccrz.ccPaymentProcessor) paymentResult.get(ccrz.cc_hk_Payment.PARAM_PAYMENT_PROCESSOR);

                boolean isPlaceException = false;

                Object transactionPaymentData = null;
                Savepoint sp = Database.setSavepoint();

                try {
                    //get return data out of map from above hook call
                    transactionPaymentData = paymentResult.get(ccrz.cc_hk_Payment.PARAM_TRANSACTION_PROCESSED_DATA);

                    Map<String, Object> placeRes = ccrz.ccApiCart.place(new Map<String, Object>{
                            ccrz.ccApi.API_VERSION => API_VERSION
                            , ccrz.ccApiCart.CART_ID => cartId
                            , ccrz.ccApiCart.CARTSTATUS => CARTSTATUS_CLOSED
                            , ccrz.ccApiOrder.PARAM_ORDER_STATUS => ORDERSTATUS_ORDERSUBMITTED
                            , ccrz.ccApiCart.ACTIVECART => false
                            , ccrz.ccApiCart.PAYMENTDATA => paymentData
                            , ccrz.ccApiCart.TRANSPAYMENTDATA => transactionPaymentData
                            , ccrz.ccApiCart.PAYMENTRESULT => paymentResult
                    });

                    orderId = (String) placeRes.get(ccrz.ccApiCart.ORDER_ID);

                    Map<String, Object> createTransactionResults = (Map<String, Object>) placeRes.get(ccrz.ccApiCart.TRANSACTIONRESULT);
                    Map<String, Object> subRes = (Map<String, Object>) placeRes.get(ccrz.ccApiCart.SUBCRESULT);


                    if (null != payProcessor) {
                        payProcessor.postProcess(new Map<String, Object>{
                                ccrz.cc_hk_Payment.PARAM_TRANSACTION_DATA => paymentData
                                , ccrz.cc_hk_Payment.PARAM_ORDER_ID => orderId
                                , ccrz.cc_hk_Payment.PARAM_TRANSACTION_PROCESSED_DATA => transactionPaymentData
                                , ccrz.cc_hk_Payment.PARAM_PRIMARY_TRANSACTION_RESULTS => createTransactionResults
                                , ccrz.cc_hk_Payment.PARAM_SUBS_RESULTS => subRes
                                , ccrz.cc_hk_Payment.PARAM_ACCOUNT_TYPE => payAccountType
                                , ccrz.cc_hk_Payment.PARAM_PAYMENT_CTX => ccrz.cc_hk_Payment.PARAM_PAYMENT_CTX_CHECKOUT
                                , ccrz.cc_hk_Payment.PARAM_SUCCESS => true
                        });
                    }

                    // we need to manually do this because the transaction payment doesn't save through
                    Map<String, Object> paymentDataObj = (Map<String, Object>) JSON.deserializeUntyped(paymentData);
                    String contractID = (String) paymentDataObj.get('contract');
                    if (contractID != null && contractID != '') {
                        ccrz__E_TransactionPayment__c tPayment = (ccrz__E_TransactionPayment__c) createTransactionResults.get(ccrz.cc_hk_Payment.PARAM_TRANSACTION_CREATED);
                        tPayment.cclxrep__Contract__c = contractID;
                        update tPayment;
                    }

                } catch (Exception e) {
                    System.debug('EXCEPTION');
                    System.debug(e.getLineNumber() + ' ' + e.getMessage());
                    System.debug(e.getStackTraceString());
                    isPlaceException = true;
                    orderID = null;
                    Database.rollback(sp);

                    if (null != payProcessor) {
                        payProcessor.postProcess(new Map<String, Object>{
                                ccrz.cc_hk_Payment.PARAM_ERROR => e
                                , ccrz.cc_hk_Payment.PARAM_TRANSACTION_DATA => paymentData
                                , ccrz.cc_hk_Payment.PARAM_TRANSACTION_PROCESSED_DATA => transactionPaymentData
                                , ccrz.cc_hk_Payment.PARAM_CART => cart
                                , ccrz.cc_hk_Payment.PARAM_PAYMENT_CTX => ccrz.cc_hk_Payment.PARAM_PAYMENT_CTX_CHECKOUT
                                , ccrz.cc_hk_Payment.PARAM_SUCCESS => false
                        });
                    }
                }

                if (orderID != null) {
                    //update order item status to RESERVATION fot Kit and COURSE
                    List<ccrz__E_OrderItem__c> listOrderItems = [SELECT Id FROM ccrz__E_OrderItem__c WHERE ccrz__Order__c = :orderID AND ccrz__Product__r.ccrz__ProductType__c = 'Kit' AND ccrz__Product__r.ccrz__InventoryType__c = 'COURSE'];
                    for (ccrz__E_OrderItem__c oi : listOrderItems) {
                        oi.ccrz__OrderItemStatus__c = 'Reservation';
                    }
                    if (listOrderItems.size() > 0) {
                        update listOrderItems;
                    }
                    // TODO: Add email support back in when storefront support is added
                    /*ccrz__E_Order__c order = cc_dao_Order.getOrder(orderID, true, true);
                    try {
                        E_StorefrontSettings__c storefront = cc_util_CloudCraze.getStorefrontSettings(ctx.storefront); // ccrz__E_StorefrontSettings__c fails, but this does too
                        ccLog.log(LoggingLevel.DEBUG,'D:storefront.SendConfirmationEmail__c',storefront.SendConfirmationEmail__c);
                        if (storefront.SendConfirmationEmail__c)
                            cc_util_OrderConfirmationEmail.sendOrderConfirmationEmail( order,
                                                                                       cc_api_User.getCurrentUser.Id,
                                                                                       storefront.OrderConfirmationEmailTemplate__c,
                                                                                       storefront.OrderconfirmationCCAddress__c,
                                                                                       storefront.orderFromEmail__c);
                    }
                    catch (Exception emailError) {
                        //ccLog.log(System.LoggingLevel.ERROR, 'ERR',emailError);
                    }*/
                } else {
                    ccrz.cc_bean_Message msg = new ccrz.cc_bean_Message();
                    msg.type = ccrz.cc_bean_Message.MessageType.CUSTOM;
                    msg.classToAppend = 'messagingSection-Error';
                    msg.labelId = isPlaceException ? 'Checkout_OrderPlaceError' : 'ERROR_INVALID_CLOSED_CART';
                    msg.severity = ccrz.cc_bean_Message.MessageSeverity.ERROR;
                    //res.messages.add(msg);
                }
            }
        } catch (Exception e) {
            System.debug(System.LoggingLevel.ERROR, e.getMessage());
            System.debug(System.LoggingLevel.ERROR, e.getStackTraceString());
        }
        return orderId;
    }

    public static void saveCartDetails(String cartId, String note, String shippingMethod, Decimal shippingAmount, Date requestDate) {
        Map<String, Object> cartData = ccrz.ccApiCart.fetch(new Map<String, Object>{
                ccrz.ccAPI.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                ccrz.ccApiCart.CART_ENCID => cartId,
                ccrz.ccAPI.SIZING => new Map<String, Object>{
                        ccrz.ccAPICart.ENTITYNAME => new Map<String, Object>{
                                ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_XL
                        }
                }
        });

        List<Map<String, Object>> toChange = (List<Map<String, Object>>) cartData.get(ccrz.ccApiCart.CART_OBJLIST);

        if (toChange.size() == 1) {
            toChange.get(0).put('note', note);
            toChange.get(0).put('shipMethod', shippingMethod);
            toChange.get(0).put('shipAmount', shippingAmount);
            toChange.get(0).put('requestDate', requestDate);
        }

        ccrz.ccApiCart.revise(new Map<String, Object>{
                ccrz.ccAPI.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                ccrz.ccApiCart.CART_OBJLIST => toChange
        });

        ccrz__E_Cart__c cart = getCartObject(cartId);

        // Revise wasn't catching the shipMethod
        cart.ccrz__ShipMethod__c = shippingMethod;
        // Revise also won't get the requested date
        cart.ccrz__RequestDate__c = requestDate;
        update cart;
    }

    public static List<Map<String, Object>> getCarts() {
        return (List<Map<String, Object>>) ccrz.ccApiCart.fetch(new Map<String, Object>{
                ccrz.ccAPI.API_VERSION => API_VERSION,
                ccrz.ccAPICart.BYOWNER => ccrz.cc_CallContext.currUserId,
                ccrz.ccAPI.SIZING => new Map<String, Object>{
                        ccrz.ccAPICart.ENTITYNAME => new Map<String, Object>{
                                ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_XL,
                                ccrz.ccAPI.SZ_ASSC => false,
                                ccrz.ccAPI.SZ_REL => new List<String>()
                        }
                }
        }).get(ccrz.ccApiCart.CART_OBJLIST);
    }

    public static List<Map<String, Object>> getOpenCarts() {
        return (List<Map<String, Object>>) ccrz.ccApiCart.fetch(new Map<String, Object>{
                ccrz.ccAPI.API_VERSION => API_VERSION,
                ccrz.ccAPICart.BYOWNER => ccrz.cc_CallContext.currUserId,
                ccrz.ccAPICart.CARTSTATUS => 'Open',
                ccrz.ccAPI.SIZING => new Map<String, Object>{
                        ccrz.ccAPICart.ENTITYNAME => new Map<String, Object>{
                                ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_XL,
                                ccrz.ccAPI.SZ_ASSC => false,
                                ccrz.ccAPI.SZ_REL => new List<String>()
                        }
                }
        }).get(ccrz.ccApiCart.CART_OBJLIST);
    }

    public static Boolean deleteCart(String cartId) {
        Map<String, Object> cartData = ccrz.ccApiCart.removeCart(new Map<String, Object>{
                ccrz.ccAPI.API_VERSION => API_VERSION,
                ccrz.ccAPICart.BYOWNER => ccrz.cc_CallContext.currUserId,
                ccrz.ccApiCart.CART_ID => cartId
        });
        return (Boolean) cartData.get(ccrz.ccApi.SUCCESS);
    }

    public static Boolean renameCart(String cartId, String newName) {
        Map<String, Object> cartData = ccrz.ccApiCart.fetch(new Map<String, Object>{
                ccrz.ccAPI.API_VERSION => API_VERSION,
                ccrz.ccApiCart.CART_ID => cartId,
                ccrz.ccAPICart.BYOWNER => ccrz.cc_CallContext.currUserId,
                ccrz.ccAPI.SIZING => new Map<String, Object>{
                        ccrz.ccAPICart.ENTITYNAME => new Map<String, Object>{
                                ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_S,
                                ccrz.ccAPI.SZ_ASSC => false
                        }
                }
        });

        List<Map<String, Object>> toRename = (List<Map<String, Object>>) cartData.get(ccrz.ccApiCart.CART_OBJLIST);

        if (!ccrz.ccUtil.isEmpty(toRename)) {
            for (Map<String, Object> theCart : toRename) {
                if (cartId.equalsIgnoreCase((String) theCart.get('sfid'))) {
                    theCart.put('name', newName);
                }
            }
        }

        ccrz.ccApiCart.revise(new Map<String, Object>{
                ccrz.ccAPI.API_VERSION => API_VERSION,
                ccrz.ccApiCart.CART_OBJLIST => toRename
        });

        return true;
    }

    public static String cloneCart(String cartId) {
        Map<String, Object> cartData = ccrz.ccApiCart.cloneCart(new Map<String, Object>{
                ccrz.ccAPI.API_VERSION => API_VERSION,
                ccrz.ccAPICart.BYOWNER => ccrz.cc_CallContext.currUserId,
                ccrz.ccApiCart.CART_ID => cartId
        });
        String newCartId = (String) cartData.get(ccrz.ccApiCart.CART_ID);

        ccrz.ccApiCart.price(new Map<String, Object>{
                ccrz.ccAPI.API_VERSION => API_VERSION,
                ccrz.ccApiCart.CART_ID => newCartId
        });

        setAsActive(newCartId);
        return newCartId;
    }

    public static void setAsActive(String cartId) {
        Map<String, Object> cartData = ccrz.ccApiCart.fetch(new Map<String, Object>{
                ccrz.ccAPI.API_VERSION => API_VERSION,
                ccrz.ccApiCart.ACTIVECART => true,
                ccrz.ccAPI.SIZING => new Map<String, Object>{
                        ccrz.ccAPICart.ENTITYNAME => new Map<String, Object>{
                                ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_S,
                                ccrz.ccAPI.SZ_ASSC => false,
                                ccrz.ccAPI.SZ_REL => new List<String>()
                        }
                }
        });

        List<Map<String, Object>> activeCarts = (List<Map<String, Object>>) cartData.get(ccrz.ccApiCart.CART_OBJLIST);

        if (!ccrz.ccUtil.isEmpty(activeCarts)) {
            for (Map<String, Object> actCart : activeCarts) {
                if (!cartId.equalsIgnoreCase((String) actCart.get('sfid'))) {
                    actCart.put('activeCart', false);
                }
            }
        }

        ccrz.ccApiCart.revise(new Map<String, Object>{
                ccrz.ccAPI.API_VERSION => API_VERSION,
                ccrz.ccApiCart.CART_OBJLIST => activeCarts
        });


        Map<String, Object> toMakeActive = ccrz.ccApiCart.fetch(new Map<String, Object>{
                ccrz.ccAPI.API_VERSION => API_VERSION,
                ccrz.ccApiCart.CART_ID => cartId,
                ccrz.ccApiCart.ACTIVECART => false,
                ccrz.ccAPI.SIZING => new Map<String, Object>{
                        ccrz.ccAPICart.ENTITYNAME => new Map<String, Object>{
                                ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_S,
                                ccrz.ccAPI.SZ_ASSC => false,
                                ccrz.ccAPI.SZ_REL => new List<String>()
                        }
                }
        });


        List<Map<String, Object>> toMakeActiveCarts = (List<Map<String, Object>>) toMakeActive.get(ccrz.ccApiCart.CART_OBJLIST);

        if (!ccrz.ccUtil.isEmpty(toMakeActiveCarts)) {
            for (Map<String, Object> actCart : toMakeActiveCarts) {
                if (cartId.equalsIgnoreCase((String) actCart.get('sfid'))) {
                    actCart.put('activeCart', true);
                }
            }
        }

        ccrz.ccApiCart.revise(new Map<String, Object>{
                ccrz.ccAPI.API_VERSION => API_VERSION,
                ccrz.ccApiCart.CART_OBJLIST => toMakeActiveCarts
        });
    }

    public static List<Map<String, Object>> getShippingOptions(String cartId, String shippingAddress) {
        List<Map<String, Object>> returnVal = new List<Map<String, Object>>();

        Map<String, Object> data = ccrz.ccApiCart.getShippingOptions(new Map<String, Object>{
                ccrz.ccAPI.API_VERSION => API_VERSION,
                ccrz.ccApiCart.CART_ID => cartId,
                ccrz.ccApiCart.SHIPPING_ADDR => (Map<String, Object>) JSON.deserializeUntyped(shippingAddress)
        });

        List<Object> options = (List<Object>) data.get(ccrz.ccApiCart.SHIPPING_OPTIONS);

        for (Object option : options) {
            Map<String, Object> obj = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(option));
            returnVal.add(obj);
        }

        return returnVal;
    }

    public static Map<String, Object> repriceCart(String cartId) {
        Map<String, Object> inputData = new Map<String, Object>{
                ccrz.ccAPI.API_VERSION => API_VERSION,
                ccrz.ccAPICart.CART_ENCID => cartId
        };
        return ccrz.ccApiCart.price(inputData);
    }

    public class CartManagerException extends Exception {

    }
}