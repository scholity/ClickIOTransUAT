trigger PHSSContentMaterialsTrigger on ContentVersion (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    PHSS_TriggerDispatcher.run(new PHSS_ContentVersionHandler());
}