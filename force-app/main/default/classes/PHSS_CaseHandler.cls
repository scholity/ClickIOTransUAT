public with sharing class PHSS_CaseHandler implements PHSS_TriggerHandler {
    public static Boolean isDisabled = false;

    public void beforeInsert(List<SObject> newItems){}

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}

    public void beforeDelete(Map<Id, SObject> oldItems){}

    public void afterInsert(Map<Id, SObject> newItems){
        PHSS_CaseHandler.processAssignmentRulesForCommunityCases(newItems.keySet());
    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}

    public void afterDelete(Map<Id, SObject> oldItems){}

    public void afterUndelete(Map<Id, SObject> oldItems){}

    public Boolean isDisabled(){
        return isDisabled || PHSS_TriggerUtility.getSettings().CaseDisabled__c;
    }

    private static void processAssignmentRulesForCommunityCases(Set<Id> caseIds) {            
        List<Case> cases = new List<Case>();
        for(Case c : [SELECT Id FROM Case WHERE Id IN :caseIds AND Question_type__c != null]) {
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            c.setOptions(dmo);
            cases.add(c);
        }
        Savepoint sp = Database.setSavepoint();
        try {
            update cases;
        } catch(DmlException e) {
            Database.rollback(sp);
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }
    }
}