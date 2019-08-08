public with sharing class PHSS_CertificationProvisioningHandler implements PHSS_TriggerHandler {
	public static Boolean isDisabled = false;

	public Boolean isDisabled(){
        return isDisabled || PHSS_TriggerUtility.getSettings().CertificationProvisioningDisabled__c;
    }

    public void beforeInsert(List<SObject> newItems){}

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}

    public void beforeDelete(Map<Id, SObject> oldItems){}

    public void afterInsert(Map<Id, SObject> newItems){
        PHSS_ProcessUserProvisioning_BATCH.schedule();
    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}

    public void afterDelete(Map<Id, SObject> oldItems){}

    public void afterUndelete(Map<Id, SObject> oldItems){}
}