trigger caseAutoResponseTrigger on EmailMessage (after insert) 
{
    system.debug('Inside Trigger caseAutoResponseTrigger');
    if(trigger.newMap != null)
    {
        sendCaseAutoResponse.emailCase(trigger.newMap);
    }
}