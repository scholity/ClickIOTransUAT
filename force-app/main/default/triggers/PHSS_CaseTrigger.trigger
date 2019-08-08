trigger PHSS_CaseTrigger on Case (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
        PHSS_TriggerDispatcher.run(new PHSS_CaseHandler());
}