trigger GetFeedbackSurveytrigger on redwing__ILT_Class__c (after update) {

    SET<Id> ILTId=new SET<Id>();
    System.debug('Trigger.new>'+Trigger.new);
    Map<id,redwing__ILT_Class__c> timeMap=Trigger.OldMap;
    
    for(redwing__ILT_Class__c ILTCl : Trigger.new)
    {
        System.debug('Class_Closed_Date__c> '+ILTCl.Class_Closed_Date__c);
        System.debug('datetime.now()> '+datetime.now().addSeconds(-10));
        if(timeMap.get(ILTCl.id).Class_Closed_Date__c != ILTCl.Class_Closed_Date__c &&  ILTCl.Class_Closed_Date__c >= datetime.now().addSeconds(-10))
        {
            ILTId.add(ILTCl.Cloud_Craze_Product__c);
        }
    }
    //List<ccrz__E_Product__c> ProdList=[Select id from ccrz__E_Product__c where id IN : ILTId];
    List<redwing__ILT_Roster__c> RosterList=[select id,Contact__r.Email,Contact__r.FirstName,redwing__ILT_Class__c,redwing__ILT_Class__r.name from redwing__ILT_Roster__c where redwing__ILT_Class__c IN : Trigger.new];
    List<ccrz__E_ProductSpec__c> ProdSpecList=[select id,ccrz__SpecValue__c,ccrz__Product__c from ccrz__E_ProductSpec__c where ccrz__Product__c IN :ILTId];
    List<String> sendTo = new List<String>();
    System.debug('RosterList>>'+RosterList);
    System.debug('ProdSpecList>>'+ProdSpecList);
    System.debug('ILTId>>'+ILTId);
    //EmailTemplate templateId = [Select id,Name from EmailTemplate where name = 'getFeedback Survey'];
    //Contact c = [select Id, Email from Contact where Email = 'sfdcsudhir1@gmail.com' limit 1];
    if(ILTId.size() >0)
    {
        for(redwing__ILT_Roster__c SendRoster: RosterList)
        {
            sendTo.add(SendRoster.Contact__r.Email);
        }
        System.debug('sendTo'+sendTo);
        for(redwing__ILT_Roster__c SendRoster: RosterList)
        {
            List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
            for(ccrz__E_ProductSpec__c Prosp : ProdSpecList)
            {
                if(Prosp.ccrz__SpecValue__c == 'Base')
                {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                    mail.setToAddresses(sendTo);
                    mail.setSenderDisplayName('Getfeedback Survey');
                    //mail.setTargetObjectId(c.Id);
                    //mail.setTemplateID(templateId.Id);
                    String body = 'Hi ' +SendRoster.Contact__r.FirstName+','+'<br /><br />'+'<br />'+'Your class '+SendRoster.redwing__ILT_Class__r.name+' is completed.'+'<br />'+
                                            'Please tell us what you think by completing this'+' '+ '<a href=\'https://www.getfeedback.com/r/XBRCEhS9?ILT_Roster_ID='+SendRoster.id+'\'>quick survey</a>'+'<br /> <br />' +'Thank you'+'<br />'+'Team Redcross';
                    mail.setHtmlBody(body);
                    allmsg.add(mail);
                    
                }
                else if(Prosp.ccrz__SpecValue__c == 'Instructor')
                {
                    
                }
                else if(Prosp.ccrz__SpecValue__c == 'Instructor Trainer')
                {
                    
                }
            }
            Messaging.sendEmail(allmsg);
        }
        
    }
    


}