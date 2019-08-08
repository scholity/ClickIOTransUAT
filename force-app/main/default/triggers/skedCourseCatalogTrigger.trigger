trigger skedCourseCatalogTrigger on Course_Catalog__c (before update) {
  if (Trigger.isBefore) {
        if (Trigger.isUpdate) {
            skedCourseCatalogHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}