trigger GetFeedbackSurveytrigger on redwing__ILT_Class__c (after update) {
    
    SET<Id> ILTId=new SET<Id>();
    System.debug('Trigger.new>'+Trigger.new);
    System.debug('Trigger.new>'+Trigger.old);
    Map<id,redwing__ILT_Class__c> timeMap=Trigger.OldMap;
    
    for(redwing__ILT_Class__c ILTCl : Trigger.new)
    {
        System.debug('Class_Closed_Date__c> '+ILTCl.Class_Closed_Date__c);
        System.debug('datetime.now()> '+datetime.now().addSeconds(-10));
        System.debug('OldMap'+timeMap.get(ILTCl.id).Class_Closed_Date__c);
        System.debug('Datetimenow'+datetime.now().addSeconds(-10));
        if(timeMap.get(ILTCl.id).Class_Closed_Date__c != ILTCl.Class_Closed_Date__c &&  ILTCl.Class_Closed_Date__c >= datetime.now().addSeconds(-10))
        {
            ILTId.add(ILTCl.Cloud_Craze_Product__c);
        }
    }
    //List<ccrz__E_Product__c> ProdList=[Select id from ccrz__E_Product__c where id IN : ILTId];
    List<redwing__ILT_Roster__c> RosterList= new List<redwing__ILT_Roster__c>();
	RosterList=[select id,Contact__r.Email,Contact__r.FirstName,redwing__ILT_Class__c,redwing__ILT_Class__r.name from redwing__ILT_Roster__c where redwing__ILT_Class__c IN : Trigger.new];
    List<ccrz__E_ProductSpec__c> ProdSpecList;
    ProdSpecList =[select id,ccrz__SpecValue__c,ccrz__Product__c from ccrz__E_ProductSpec__c where ccrz__Product__c IN :ILTId];
	List<String> sendTo = new List<String>();
    Map<String,String> EmailTemps= new Map<String,String>();
    System.debug('RosterList>>'+RosterList);
    System.debug('ProdSpecList>>'+ProdSpecList);
    System.debug('ILTId>>'+ILTId);
    for(EmailTemplate ETempms: [Select id,Name,Folder.Name from EmailTemplate where Folder.Name = 'Survey Templates'])
    {
        EmailTemps.put(ETempms.Name,ETempms.id);
    }
    List<Contact> c =new List<Contact>();
    try
    {
        c=[select Id, Email from Contact where Email = 'sfdcsudhir1@gmail.com' limit 1];
    }
    catch(exception e)
    {
        System.debug('inside Catch');
    }
    if(c.size() ==0)
    {
        Contact con=new Contact();
        con.FirstName = 'Sudhir';
        con.LastName = 'D';
        con.Email = 'sfdcsudhir1@gmail.com';
        insert con;
        c.add(con); 
    }
    if(ILTId.size() >0 && RosterList.size() > 0)
    {
        for(redwing__ILT_Roster__c SendRoster: RosterList)
        {
            if(SendRoster.Contact__r.Email != null)
                sendTo.add(SendRoster.Contact__r.Email);
        }
        if(sendTo.size() >0)
        {
            System.debug('sendTo'+sendTo);
            for(redwing__ILT_Roster__c SendRoster: RosterList)
            {
                List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
                if(ProdSpecList.size() > 0)
                {
                    for(ccrz__E_ProductSpec__c Prosp : ProdSpecList)
                    {
                        if(Prosp.ccrz__SpecValue__c == 'Base')
                        {
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.setToAddresses(sendTo);
                            mail.setSenderDisplayName('Getfeedback Survey');
                            mail.setTargetObjectId(c[0].id);
                            // mail.setTargetObjectId(SendRoster.Contact__c);
                            mail.setTemplateID(EmailTemps.get('getFeedback for Base'));
                            mail.setWhatId(SendRoster.id);
                            /*String body = 'Hi ' +SendRoster.Contact__r.FirstName+','+'<br /><br />'+'<br />'+'Your class '+SendRoster.redwing__ILT_Class__r.name+' is completed.'+'<br />'+
'Please tell us what you think by completing this'+' '+ '<a href=\'https://www.getfeedback.com/r/XBRCEhS9?ILT_Roster_ID='+SendRoster.id+'\'>quick survey</a>'+'<br /> <br />' +'Thank you'+'<br />'+'Team Redcross';
mail.setHtmlBody(body);*/
                            allmsg.add(mail);
                            
                        }
                        else if(Prosp.ccrz__SpecValue__c == 'Instructor')
                        {
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.setToAddresses(sendTo);
                            mail.setSenderDisplayName('Getfeedback Survey');
                            mail.setTargetObjectId(c[0].id);
                            //mail.setTargetObjectId(SendRoster.Contact__c);
                            mail.setTemplateID(EmailTemps.get('getFeedback for Instructor'));
                            mail.setWhatId(SendRoster.id);
                            /* String body = 'Hi ' +SendRoster.Contact__r.FirstName+','+'<br /><br />'+'<br />'+'Your class '+SendRoster.redwing__ILT_Class__r.name+' is completed.'+'<br />'+
'Please tell us what you think by completing this'+' '+ '<a href=\'https://www.getfeedback.com/r/XBRCEhS9?ILT_Roster_ID='+SendRoster.id+'\'>quick survey</a>'+'<br /> <br />' +'Thank you'+'<br />'+'Team Redcross';
mail.setHtmlBody(body);*/
                            allmsg.add(mail);
                        }
                        else if(Prosp.ccrz__SpecValue__c == 'Instructor Trainer')
                        {
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.setToAddresses(sendTo);
                            mail.setSenderDisplayName('Getfeedback Survey');
                            // mail.setTargetObjectId(SendRoster.Contact__c);
                            mail.setTargetObjectId(c[0].id);
                            mail.setTemplateID(EmailTemps.get('getFeedback for Instructor Trainer'));
                            mail.setWhatId(SendRoster.id);
                            /*String body = 'Hi ' +SendRoster.Contact__r.FirstName+','+'<br /><br />'+'<br />'+'Your class '+SendRoster.redwing__ILT_Class__r.name+' is completed.'+'<br />'+
'Please tell us what you think by completing this'+' '+ '<a href=\'https://www.getfeedback.com/r/XBRCEhS9?ILT_Roster_ID='+SendRoster.id+'\'>quick survey</a>'+'<br /> <br />' +'Thank you'+'<br />'+'Team Redcross';
mail.setHtmlBody(body);*/
                            allmsg.add(mail);
                        }
                    }
                }
                Messaging.sendEmail(allmsg);
            } 
        }
        
    }
}