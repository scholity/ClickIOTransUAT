global class ILTClassRosterPDFController {

    private final redwing__ILT_Class__c currentClass;
    List<redwing__ILT_Roster__c> rosterList;

    public ILTClassRosterPDFController(ApexPages.StandardController controller) {
        currentClass = [SELECT Id, Name, redwing__Start_Date__c, redwing__End_Date__c, redwing__Start_Time__c, redwing__End_Time__c, redwing__Location__r.Name, Account__r.Name 
                        FROM redwing__ILT_Class__c 
                        WHERE Id = :ApexPages.currentPage().getParameters().get('id')];       
        rosterList = new List< redwing__ILT_Roster__c>([SELECT Id, Contact__r.FirstName, Contact__r.LastName, redwing__User__r.FirstName, redwing__User__r.LastName, redwing__Status__c, redwing__Attended__c, redwing__ILT_Session__r.Name
                                                        FROM redwing__ILT_Roster__c 
                                                        WHERE redwing__ILT_Class__c=: currentClass.Id]);
    }
    
    public redwing__ILT_Class__c getCurrentClass() {
        return currentClass;
    }
    
    public List<redwing__ILT_Roster__c> getRosterList() {
        return rosterList;
    }
}