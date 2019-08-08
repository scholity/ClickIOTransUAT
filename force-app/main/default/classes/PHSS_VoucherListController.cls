public without sharing class PHSS_VoucherListController {

    @AuraEnabled
    public static List<Voucher__c> getVoucherList(String recId) {
        List<Voucher__c> vouchList = [Select Id,Name,User__r.Name,Voucher_Claim__c,Status__c,ILT_Class__c,ILT_Class__r.Request_Type__c,User__c,QR_Code_Web_Address__c, ILT_Class__r.Class_Closed_Date__c From Voucher__c
                                      Where ILT_Class__c = :recId]; 
        return vouchList;
    }

    // This method invokes the student cancellation logic using a Voucher Id
    @AuraEnabled
    public static String cancelEnrollment(String recId) {
        String returnMessage = 'Not Performed';

        // For Voucher Object
        Schema.DescribeSObjectResult r = Voucher__c.sObjectType.getDescribe();
        String keyPrefixvoucher = r.getKeyPrefix();
        System.debug('Value of voucher id' + keyPrefixvoucher );

        // Confirm record represents a voucher
        if (recId.startsWith(keyPrefixvoucher)) {
            String voucherId = recId;
            String rosterId = '';

            // Determine if the voucher has been assigned to a student (that a roster record exists)
            redwing__ILT_Roster__c theRoster = [Select Id, redwing__Status__c From redwing__ILT_Roster__c Where Voucher_Id__c = :voucherId Limit 1];

            // Validate roster presence and status, pass to cancelEnrollment function
            if (theRoster != null) {
                if (theRoster.redwing__Status__c != 'Cancelled') {
                    rosterId = theRoster.Id;
                    PHSS_CancelEnrollmentController.cancelEnrollment(rosterId, 'Instructor Cancel');

                    returnMessage = 'Enrollment Cancelled';
                } else returnMessage = 'Student Already Cancelled';
            }  else returnMessage = 'Voucher Does Not Exist';
        } else returnMessage = 'Invalid Voucher Id';

        return returnMessage;
    }
}