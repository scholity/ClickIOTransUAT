/************************************************************************************************************************************
** Author: Salesforce Services
** Description: The purpose of this class is to populate the QR code
************************************************************************************************************************************/
public class PHSS_initQRCodeIdentifierTriggerHandler {
    public PHSS_initQRCodeIdentifierTriggerHandler(){}
    
    // QR code identifier now exclusively assigned when achievement assignment record is updated as 'Acquired'
    public void PHSS_initQRCodeIdentifierafterInsert(list<redwing__Achievement_Assignment__c> newAchievementAssignments){
        List<redwing__Achievement_Assignment__c> updatedAssignments = new List<redwing__Achievement_Assignment__c>();
        for(redwing__Achievement_Assignment__c theAssignment : newAchievementAssignments) {
            if (theAssignment.Achievement_Type__c == 'Certifications' && theAssignment.redwing__Status__c == 'Acquired') {
                redwing__Achievement_Assignment__c updatedAssignment = new redwing__Achievement_Assignment__c();
                updatedAssignment.Id = theAssignment.Id;
                if (theAssignment.Name != null && theAssignment.Name.length() > 4) {
                    // Special Adjustment for Production Org
                    Decimal nQROffset = Decimal.valueOf(2000000000);
                    updatedAssignment.QR_Code_Identifier__c = base10To32(Decimal.valueOf(theAssignment.Name.substring(4))+nQROffset);
                } else updatedAssignment.QR_Code_Identifier__c = '';
                updatedAssignments.add(updatedAssignment); 
            }
        }    
        if(!updatedAssignments.isEmpty()){
            update updatedAssignments;    
        }
            
    }
    
    
    public void PHSS_initQRCodeIdentifierBeforeUpdate(list<redwing__Achievement_Assignment__c> updatedAchievementAssignments){
        for(redwing__Achievement_Assignment__c theAssignment : updatedAchievementAssignments) {
            if (theAssignment.Achievement_Type__c == 'Certifications' && theAssignment.redwing__Status__c == 'Acquired') {            
                if (String.isBlank(theAssignment.QR_Code_Identifier__c)){
                    theAssignment.QR_Code_Identifier__c = base10To32(Decimal.valueOf(theAssignment.Name.substring(4)));   
                }
            }  
        }
    }
    
    private static string base10To32(Decimal inputValue) {
        Integer outputLength = 7;
        Integer inputBase = 10;
        Integer outputBase = 32;
        Decimal DecimalValue = inputValue;
        String outputValue = ''; 
        String numericBaseData = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        Integer x;
        Integer maxBase = NumericBaseData.length();
        if(DecimalValue == 0) return '0000000';
        try {
            while(DecimalValue > 0) {
                X = (Integer)(((DecimalValue/outputBase) - (Integer)(DecimalValue/OutputBase))* OutputBase + 1.5);
                OutputValue = NumericBaseData.subString(X - 1,X)+OutputValue;
                DecimalValue = Integer.valueOf(DecimalValue/OutputBase);
            }
            // Left Pad with '0' to length <outputlength>
            while(OutputValue.length() < outputLength) {
                OutputValue = '0' + OutputValue;
            }
        } catch(Exception e) {
            System.debug(e);
        }
        return outputValue;
    } 
}