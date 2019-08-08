trigger AssignmentRulesonCaseTrigger on Case (after insert) {
    if(trigger.IsAfter && trigger.isInsert){
        Set<Id>  caseIds = new Set<Id>();
        for (Case c: Trigger.new) {
            caseIds.add(c.Id);
        }
            
        List<Case> cases = new List<Case>();
        for(Case c : [Select Id from Case where Id in :caseIds])
        {
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            c.setOptions(dmo);
            cases.add(c);
        }
        update cases;
    }
}