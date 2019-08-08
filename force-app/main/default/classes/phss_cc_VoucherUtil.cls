/**
 * Created by jbarker on 10/26/18.
 */

public with sharing class phss_cc_VoucherUtil {

    private static final String ISSUED_STATUS = 'Issued';
    private static final String TEMP_HOLD_STATUS = 'Temp Hold';
    private static final Integer RESERVATION_TIMESTAMP_OFFSET = -45;        // number of minutes to offset the reservation timestamp

    private static final String FAILED_TO_GET_REQUESTED_QUANTITY_OF_AVAILABLE_VOUCHERS = 'Failed to get the requested quantity of available vouchers.';
    private static final String FAILED_TO_MATCH_CART_ITEM_FOR_COURSE = 'Failed to match a cart item with a selected course.';
    private static final String FAILED_TO_MATCH_COURSE_FOR_CLASS = 'Failed to match course with selected class.';
    private static final String FAILED_TO_RESERVE_VOUCHERS = 'Failed to reserve vouchers.';


    /**
     * @description Requests vouchers for the specified ILT classes
     *
     * @param classQuantityMap
     *
     * @return
     */
    public static Map<String, List<Voucher__c>> requestVouchersForClasses(Map<String, Integer> classQuantityMap) {

        Map<String, List<Voucher__c>> voucherMap = new Map<String, List<Voucher__c>>();
        for (String classId : classQuantityMap.keySet()) {
            Integer quantity = classQuantityMap.get(classId);
            List<Voucher__c> vouchers = [
                    SELECT Id, ILT_Class__c, Status__c, CC_Cart_Item__c, Opportunity__c
                    FROM Voucher__c
                    WHERE ILT_Class__c = :classId
                    AND Status__c = :ISSUED_STATUS
                    LIMIT :quantity
                    FOR UPDATE
            ];
            if (vouchers.size() == quantity) {
                voucherMap.put(classId, vouchers);
            }
            else {
                throw new phss_cc_Exception(FAILED_TO_GET_REQUESTED_QUANTITY_OF_AVAILABLE_VOUCHERS);
            }
        }

        return voucherMap;
    }

    /**
     * @description Reserves vouchers for the specified ILT classes
     *
     * @param classVoucherMap
     * @param cartData
     */
    public static List<Voucher__c> reserveVouchersForCartItems(Map<String, List<Voucher__c>> classVoucherMap, Map<String, String> classCourseMap, Map<String, String> courseCartItemMap, String opportunityId) {

        List<Voucher__c> allVouchers = new List<Voucher__c>();
        if (classVoucherMap.keySet().size() > 0) {

            System.Savepoint sp =  Database.setSavepoint();

            try {
                for (String classId : classVoucherMap.keySet()) {
                    List<Voucher__c> vouchers = classVoucherMap.get(classId);
                    String courseId = classCourseMap.get(classId);
                    if (courseId == null) {
                        throw new phss_cc_Exception(FAILED_TO_MATCH_COURSE_FOR_CLASS);
                    }

                    String cartItemId = courseCartItemMap.get(courseId);
                    if (cartItemId == null) {
                        throw new phss_cc_Exception(FAILED_TO_MATCH_CART_ITEM_FOR_COURSE);
                    }

                    for (Voucher__c voucher : vouchers) {
                        voucher.Opportunity__c = opportunityId;
                        voucher.Status__c = TEMP_HOLD_STATUS;
                        voucher.RCO_Reservation_Timestamp__c = getReservationDatetime();
                        voucher.CC_Cart_Item__c = cartItemId;
                    }

                    allVouchers.addAll(vouchers);
                }

                update allVouchers;

            } catch (Exception e) {
                Database.rollback(sp);
                throw new phss_cc_Exception(FAILED_TO_RESERVE_VOUCHERS, e);
            }
        }

        return allVouchers;
    }

    /**
     * @description Gets the reservation Datetime
     *
     * @return
     */
    private static Datetime getReservationDatetime() {
        return Datetime.now().addMinutes(RESERVATION_TIMESTAMP_OFFSET);
    }
}