/**
 * Created by jbarker on 10/18/18.
 */

public with sharing class phss_cc_ClassCartUtil {

    public static final String ILT_CLASS_FIELD = 'ILT_Class__c';

    private static final String CART_ITEM_PRODUCT_SFID_KEY = 'product';
    private static final String CART_ITEM_QUANTITY_KEY = 'quantity';
    private static final String CART_ITEM_SFID_KEY = 'sfid';
    private static final String CART_ITEM_TYPE = 'cartItemType';
    private static final String CART_ITEM_TYPE_MAJOR = 'Major';

    private static final String CART_ITEMS_KEY = 'ECartItemsS';

    public static final String CLASS_ID_LIST = 'CLASS_ID_LIST';
    public static final String CLASS_COURSE_MAP = 'CLASS_COURSE_MAP';
    public static final String CLASS_QUANTITY_MAP = 'CLASS_QUANTITY_MAP';

    public static final String CART_TOTAL_AMOUNT_KEY = 'totalAmount';
    public static final String CLASS_ID_KEY = 'classId';
    public static final String COUNT_KEY = 'count';
    public static final String COURSE_ID_KEY = 'courseId';

    private static final String CART_ENCRYPTED_ID_KEY = 'encryptedCartId';
    private static final String CART_TOTAL_KEY = 'CartTotal';
    private static final String PRODUCT_LIST_KEY = 'productList';
    private static final String PRODUCT_MAP_KEY = 'productMap';
    private static final String PRODUCT_QUANTITY_MAP_KEY = 'productQuantityMap';
    private static final String VOUCHERS_KEY = 'vouchers';

    private static final String FAILED_TO_ADD_ITEMS_TO_CART = 'Failed to add items to the cart.';
    private static final String FAILED_TO_CREATE_CART = 'Failed to create a cart.';
    private static final String FAILED_TO_CREATE_LINE_ITEMS = 'Failed to create the cart line items.';
    private static final String FAILED_TO_CREATE_PRODUCT_QUANTITY_MAP = 'Failed to create Product Quantities Map.';
    private static final String FAILED_TO_PARSE_DETAILS_FROM_CART = 'Failed to parse details from the cart.';

    /**
     * @description Adds classes to the cart
     *
     * @param opportunityId
     * @param classQuantityMap
     *
     * @return
     */
    public static Map<String, Object> addClassesToCart(String opportunityId, Map<String, Object> classData) {

        Map<String, Object> addClassesToCartResponse;
        try {
            phss_cc_Context.setContext(opportunityId);

            String encryptedCartId;
            if (phss_cc_Context.currCart == null) {
                encryptedCartId = phss_cc_CartUtil.createNewCart();
            } else {
                encryptedCartId = phss_cc_Context.currCart.ccrz__EncryptedId__c;
            }

            Map<String, Integer> classQuantityMap = (Map<String, Integer>) classData.get(CLASS_QUANTITY_MAP);
            Map<String, String> classCourseMap = (Map<String, String>) classData.get(CLASS_COURSE_MAP);

            // Request available vouchers BEFORE creating cart line items.
            Map<String, List<Voucher__c>> classVoucherMap = phss_cc_VoucherUtil.requestVouchersForClasses(classQuantityMap);

            List<Map<String, Object>> lineData = createLineItems(classData);
            Map<String, Object> addToResult = phss_cc_CartUtil.cartAddTo(lineData, encryptedCartId);
            addClassesToCartResponse = phss_cc_CartUtil.retrieveLineItemsAndTotalAmountFromCart(addToResult, true);


            Map<String, String> classCartItemMap = getClassCartItemMap();

            // AFTER the cart line items are created, associate them to the requested vouchers
            List<Voucher__c> vouchers = phss_cc_VoucherUtil.reserveVouchersForCartItems(classVoucherMap, classCourseMap, classCartItemMap, opportunityId);
            addClassesToCartResponse.put(VOUCHERS_KEY, vouchers);

        } catch (Exception e) {
            throw new phss_cc_Exception(e.getMessage());
        }

        return addClassesToCartResponse;
    }

    /**
     * @description Creates cart line items
     *
     * @param classQuantityMap
     *
     * @return
     */
    private static List<Map<String, Object>> createLineItems(Map<String, Object> classData) {

        List<Map<String, Object>> lineItems = new List<Map<String, Object>>();
        List<String> classIdList = (List<String>) classData.get(CLASS_ID_LIST);
        Map<String, String> classCourseMap = (Map<String, String>) classData.get(CLASS_COURSE_MAP);
        Map<String, Integer> classQuantityMap = (Map<String, Integer>) classData.get(CLASS_QUANTITY_MAP);

        try {
            for (String classId : classIdList) {
                String courseId = classCourseMap.get(classId);
                Integer count = classQuantityMap.get(classId);

                Map<String, Object> lineItem = new Map<String, Object>{
                        ccrz.ccApiCart.LINE_DATA_QUANTITY => count,
                        ccrz.ccApiCart.LINE_DATA_PRODUCT_SFID => courseId,
                        ILT_CLASS_FIELD => classId
                };
                lineItems.add(lineItem);
            }
        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_CREATE_LINE_ITEMS);
        }

        return lineItems;
    }

    private static Map<String, String> getClassCartItemMap() {

        Map<String, String> classCartItemMap = new Map<String, String>();

        Map<String, Object> cartItemInfo = phss_cc_CartUtil.fetchCartItems(phss_cc_Context.currCart.Id);
        Map<String, Object> cartItemMap = (Map<String, Object>) cartItemInfo.get(phss_cc_CartUtil.CART_ITEM_MAP);

        for (String cartItemId : cartItemMap.keySet()) {
            Map<String, Object> cartItem = (Map<String, Object>) cartItemMap.get(cartItemId);
            String iltClass = (String) cartItem.get('ILT_Class__c');
            classCartItemMap.put(iltClass, cartItemId);
        }

        return classCartItemMap;
    }

//    /**
//     * @description Maps courses to cart items
//     *
//     * @param cartDetails
//     *
//     * @return
//     */
//    private static Map<String, String> getCourseCartItemMap(Map<String, Object> cartDetails, List<Map<String, Object>> lineData) {
//
//        System.debug('cartDetails');
//        System.debug(cartDetails);
//        System.debug('lineData');
//        System.debug(lineData);
//
//
//        Map<String, String> courseCartItemMap = new Map<String, String>();
//
//        if (cartDetails.get(ccrz.ccApiCart.CART_OBJLIST) != null) {
//            List<Map<String, Object>> carts = (List<Map<String, Object>>) cartDetails.get(ccrz.ccApiCart.CART_OBJLIST);
//            if (carts.size() > 0) {
//                Map<String, Object> currentCart = (Map<String, Object>) carts[0];
//                if (currentCart.containsKey(CART_ITEMS_KEY)) {
//                    List<Map<String, Object>> cartItems = (List<Map<String, Object>>) currentCart.get(CART_ITEMS_KEY);
//                    for (Map<String, Object> cartItem : cartItems) {
//                        if (cartItem.get(CART_ITEM_TYPE) == CART_ITEM_TYPE_MAJOR) {
//                            String courseId = (String) cartItem.get(CART_ITEM_PRODUCT_SFID_KEY);
//                            String cartItemId = (String) cartItem.get(CART_ITEM_SFID_KEY);
//                            if (courseId != null && cartItemId != null) {
//                                courseCartItemMap.put(courseId, cartItemId);
//                            }
//                        }
//                    }
//                }
//            }
//        }
//
//        return courseCartItemMap;
//    }
}