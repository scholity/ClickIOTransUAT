trigger RcsPoCaseTrigger on Case(after insert, after update) 
{
    Map<id, Case> newCaseMap = Trigger.newMap;
    Map<id, Case> oldCaseMap = Trigger.oldMap;
    String accountId;
    String shippingContactId;
    String ShippingAddress1 = '';
    String ShippingAddress2 = '';
    String ShippingCity = '';
    String ShippingState = '';
    String ShippingZip = '';
    String ShippingCountryName = '';
    String ShippingCountryCode = '';
    
    String siteName = '';
    Id contactAddressDetail;
    Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RCS PO').getRecordTypeId();
    
    System.debug('Trigger IsInsert ::::'+Trigger.isInsert);
    try
    {
        If(!TrggrUtility.RunOnce) 
        {
            //Get profile Name and restrict for 'ARC / TSC Agent' And 'ARC / TSC Manager'
            Id profileId = userinfo.getProfileId();
            String profileName = [Select Id,Name from Profile where Id =: profileId].Name;
            
            if(profileName != 'ARC / TSC Agent' && profileName != 'ARC / TSC Manager')
            {
                //Added from Top 
                List<Case> toUpdate = [select id, AccountId, Case_Sub_Type__c, Sent_to_CFS__c, Account.Payment_Terms__c, Account.Invoice_Delivery_Type__c, Account.Invoice_delivery_Email__c, Invoice_Delivery__c, Invoice_delivery_Email__c, Terms__c, Account.Name, RecordTypeId, Site_Name1__c, Copy_Billing_to_Shipping__c, Current_Site_Name_Series__c, External_LOGIN_EMAIL__c, contactId, Created_From_Capo_Form__c, Account.Billing_Contact__c, Account.Billing_Contact__r.MailingStreet , Account.Billing_Contact__r.MailingCity , Account.Billing_Contact__r.MailingState , Account.Billing_Contact__r.MailingPostalCode, Account.Billing_Contact__r.MailingCountry, Account.Billing_Contact__r.firstName, Account.Billing_Contact__r.lastName, Account.Billing_Contact__r.Phone, Account.Billing_Contact__r.Email, Billing_Contact__c, Billing_Contact_First_Name__c, Billing_Contact_Last_Name__c, Billing_Contact_Email__c, Billing_Contact_Phone__c, Billing_Address_1__c, Billing_Address_2__c, Billing_City__c, Billing_State__c, Billing_Zip__c, Billing_Country_Name__c, Billing_Country_Code__c, Shipping_Contact__c, Shipping_Contact_First_Name__c, Shipping_Contact_Last_Name__c, Shipping_Contact_Email__c, Shipping_Contact_Phone__c, Shipping_Address_1__c, Shipping_Address_2__c, Shipping_City__c, Shipping_State__c, Shipping_Zip__c, Shipping_Country_Name__c, Shipping_Country_Code__c, Company_Name__c, Account.BillingStreet , Account.BillingCity , Account.BillingState , Account.BillingPostalCode, Account.BillingCountry from Case where id In : newCaseMap.keySet() And RecordTypeId =: recordTypeId];
                
                System.debug('Inside run Once::::'+Trigger.isInsert);
                if(toUpdate.size() == 1)
                {
                    //to Get shipping contact details
                    String caseShippingContactId = null;
                    if(toUpdate[0].Shipping_Contact__c != null)
                        caseShippingContactId = toUpdate[0].Shipping_Contact__c;
                    List<Contact> shippingContactDetails = new List<Contact>();
                    if(caseShippingContactId != null)
                        shippingContactDetails = [select id, Account.Id, FirstName, LastName, Email, Phone, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from Contact where Id =: caseShippingContactId];
                    
                    for(Case caseRec : toUpdate)
                    {
                        if(!caseRec.Sent_to_CFS__c)
                        {
                            if(caseRec.Billing_Contact__c == null && caseRec.Billing_Address_1__c == null && caseRec.Billing_City__c == null && caseRec.Billing_State__c == null && caseRec.Billing_Zip__c == null)
                            {
                                if((caseRec.AccountId != null && caseRec.Account.Billing_Contact__c != null))
                                {
                                    if(caseRec.Case_Sub_Type__c != 'RCS PO Inquiry')
                                        caseRec.Company_Name__c = caseRec.Account.Name;
                                    caseRec.Billing_Contact__c = caseRec.Account.Billing_Contact__c;
                                    caseRec.Billing_Contact_First_Name__c = caseRec.Account.Billing_Contact__r.firstName;
                                    caseRec.Billing_Contact_Last_Name__c = caseRec.Account.Billing_Contact__r.lastName;
                                    caseRec.Billing_Contact_Email__c = caseRec.Account.Billing_Contact__r.Email;
                                    caseRec.Billing_Contact_Phone__c = caseRec.Account.Billing_Contact__r.Phone;
                                }
                                if(caseRec.Account.BillingStreet !=  null)
                                {
                                    List<String> billingAddress = new List<String>();
                                    billingAddress = caseRec.Account.BillingStreet.split('\n');

                                    if(billingAddress.size() == 1)
                                    { 
                                        caseRec.Billing_Address_1__c = billingAddress[0];
                                        caseRec.Billing_Address_2__c = null;
                                    }
                                    else if(billingAddress.size() == 2)
                                    {
                                        caseRec.Billing_Address_1__c = billingAddress[0];
                                        caseRec.Billing_Address_2__c = billingAddress[1];
                                    }
                                }
                                if(caseRec.Account.BillingCity !=  null)
                                    caseRec.Billing_City__c = caseRec.Account.BillingCity;
                                if(caseRec.Account.BillingState !=  null)
                                {
                                    if(caseRec.Account.BillingState.length() == 2)
                                        caseRec.Billing_State__c = caseRec.Account.BillingState;
                                }
                                if(caseRec.Account.BillingPostalCode !=  null)
                                    caseRec.Billing_Zip__c = caseRec.Account.BillingPostalCode;
                                
                                 // Country code and Country Name
                                if(caseRec.Account.BillingCountry == 'USA' || caseRec.Account.BillingCountry == 'US' || caseRec.Account.BillingCountry == 'United States')
                                {
                                    caseRec.Billing_Country_Name__c = 'USA';
                                    caseRec.Billing_Country_Code__c = 'US';
                                }
                                else if(caseRec.Account.BillingCountry == 'PR' || caseRec.Account.BillingCountry == 'Puerto Rico')
                                {
                                    caseRec.Billing_Country_Name__c = 'Puerto Rico';
                                    caseRec.Billing_Country_Code__c = 'PR';
                                }
                                else if(caseRec.Account.BillingCountry == 'CA' || caseRec.Account.BillingCountry == 'Canada')
                                {
                                    caseRec.Billing_Country_Name__c = 'Canada';
                                    caseRec.Billing_Country_Code__c = 'CA';
                                }
                            }
                                
                            //copying Account invoice delivery email, Payment terms and invoice delivery type to Case
                            if(caseRec.Terms__c == null)
                                caseRec.Terms__c = caseRec.Account.Payment_Terms__c;
                            if(caseRec.Invoice_Delivery__c == null)
                                caseRec.Invoice_Delivery__c = caseRec.Account.Invoice_Delivery_Type__c;
                            if(caseRec.Invoice_delivery_Email__c == null)
                            {
                                if(caseRec.Account.Invoice_Delivery_Type__c == 'Email')
                                    caseRec.Invoice_delivery_Email__c = caseRec.Account.Invoice_delivery_Email__c;
                                else
                                    caseRec.Invoice_delivery_Email__c = null;
                            }
                            
                            //Copy Billing to Shipping
                            if(caseRec.Copy_Billing_to_Shipping__c)
                            {
                                caseRec.Shipping_Contact__c = caseRec.Billing_Contact__c;
                                caseRec.Shipping_Contact_First_Name__c = caseRec.Billing_Contact_First_Name__c;
                                caseRec.Shipping_Contact_Last_Name__c = caseRec.Billing_Contact_Last_Name__c;
                                caseRec.Shipping_Contact_Email__c = caseRec.Billing_Contact_Email__c;
                                caseRec.Shipping_Contact_Phone__c = caseRec.Billing_Contact_Phone__c;
                                caseRec.Shipping_Address_1__c = caseRec.Billing_Address_1__c;
                                caseRec.Shipping_Address_2__c = caseRec.Billing_Address_2__c;
                                caseRec.Shipping_City__c = caseRec.Billing_City__c;
                                caseRec.Shipping_State__c = caseRec.Billing_State__c;
                                caseRec.Shipping_Zip__c = caseRec.Billing_Zip__c;
                                caseRec.Shipping_Country_Name__c = caseRec.Billing_Country_Name__c;
                                caseRec.Shipping_Country_Code__c = caseRec.Billing_Country_Code__c;
                            }
                            else if(shippingContactDetails.size() > 0 && caseRec.Shipping_Contact__c != null && caseRec.Shipping_Address_1__c == null && caseRec.Shipping_City__c == null && caseRec.Shipping_State__c == null && caseRec.Shipping_Zip__c == null)
                            {
                                caseRec.Shipping_Contact_First_Name__c = shippingContactDetails[0].FirstName;
                                caseRec.Shipping_Contact_Last_Name__c = shippingContactDetails[0].LastName;
                                caseRec.Shipping_Contact_Email__c = shippingContactDetails[0].Email;
                                caseRec.Shipping_Contact_Phone__c = shippingContactDetails[0].Phone;
                                caseRec.Shipping_Address_1__c = shippingContactDetails[0].MailingStreet;
                                caseRec.Shipping_Address_2__c = null;                               
                                caseRec.Shipping_City__c = shippingContactDetails[0].MailingCity;
                                if(shippingContactDetails[0].MailingState != null && shippingContactDetails[0].MailingState.length() == 2)
                                    caseRec.Shipping_State__c = shippingContactDetails[0].MailingState;
                                caseRec.Shipping_Zip__c = shippingContactDetails[0].MailingPostalCode;  
                                // Country code and Country Name
                                if(shippingContactDetails[0].MailingCountry == 'USA' || shippingContactDetails[0].MailingCountry == 'US' || shippingContactDetails[0].MailingCountry == 'United States')
                                {
                                    caseRec.Shipping_Country_Name__c = 'USA';
                                    caseRec.Shipping_Country_Code__c = 'US';
                                }
                                else if(shippingContactDetails[0].MailingCountry == 'PR' || shippingContactDetails[0].MailingCountry == 'Puerto Rico')
                                {
                                    caseRec.Shipping_Country_Name__c = 'Puerto Rico';
                                    caseRec.Shipping_Country_Code__c = 'PR';
                                }
                                else if(shippingContactDetails[0].MailingCountry == 'CA' || shippingContactDetails[0].MailingCountry == 'Canada')
                                {
                                    caseRec.Shipping_Country_Name__c = 'Canada';
                                    caseRec.Shipping_Country_Code__c = 'CA';
                                }
                            }
                            
                            //to get Site Name 
                            accountId = caseRec.AccountId;
                            shippingContactId = caseRec.Shipping_Contact__c;
                            ShippingAddress1 = caseRec.Shipping_Address_1__c;
                            ShippingAddress2 = caseRec.Shipping_Address_2__c;
                            ShippingCity = caseRec.Shipping_City__c;
                            ShippingState = caseRec.Shipping_State__c;
                            ShippingZip = caseRec.Shipping_Zip__c;
                            ShippingCountryName = caseRec.Shipping_Country_Name__c;
                            ShippingCountryCode = caseRec.Shipping_Country_Code__c;
                            
                            //Remove new line character from String
                            if(ShippingAddress1 != null && ShippingAddress1 != '')
                            {
                                ShippingAddress1 = ShippingAddress1.replace('\r\n', ' ');
                                ShippingAddress1 = ShippingAddress1.replace('\n', ' ');
                                ShippingAddress1 = ShippingAddress1.replace('\r', ' ');
                            }
                            
                            //Billing Contact phone format
                            if(caseRec.Billing_Contact_Phone__c != null)
                            {
                                if(String.valueOf(caseRec.Billing_Contact_Phone__c).length() == 10 && !(String.valueOf(caseRec.Billing_Contact_Phone__c).contains('(')) && !(String.valueOf(caseRec.Billing_Contact_Phone__c).contains(')')))
                                {
                                    caseRec.Billing_Contact_Phone__c = '(' + String.valueOf(caseRec.Billing_Contact_Phone__c).substring(0,3) + ')' + ' ' + String.valueOf(caseRec.Billing_Contact_Phone__c).substring(3,6) + '-' + String.valueOf(caseRec.Billing_Contact_Phone__c).substring(6,10);
                                }
                            }
                            
                            //Shipping Contact phone format
                            if(caseRec.Shipping_Contact_Phone__c != null)
                            {
                                if(String.valueOf(caseRec.Shipping_Contact_Phone__c).length() == 10 && !(String.valueOf(caseRec.Shipping_Contact_Phone__c).contains('(')) && !(String.valueOf(caseRec.Shipping_Contact_Phone__c).contains(')')))
                                {
                                    caseRec.Shipping_Contact_Phone__c = '(' + String.valueOf(caseRec.Shipping_Contact_Phone__c).substring(0,3) + ')' + ' ' + String.valueOf(caseRec.Shipping_Contact_Phone__c).substring(3,6) + '-' + String.valueOf(caseRec.Shipping_Contact_Phone__c).substring(6,10);
                                }
                            }
                        }
                    }
                    
                    //Site Name logic
                    system.debug('accountId:::'+accountId);
                    system.debug('shippingContactId:::'+shippingContactId);
                    system.debug('ShippingAddress1:::'+ShippingAddress1);
                    system.debug('ShippingAddress2:::'+ShippingAddress2);
                    system.debug('ShippingCity:::'+ShippingCity);
                    system.debug('ShippingState:::'+ShippingState);
                    system.debug('ShippingZip:::'+ShippingZip);
                    system.debug('ShippingCountryName:::'+ShippingCountryName);
                    system.debug('ShippingCountryCode:::'+ShippingCountryCode);
                    
                    //Shipping contact details
                    List<Contact_Address_Detail__c> shippingContactDetailsSameAddressContact = new List<Contact_Address_Detail__c>();
                    List<Contact_Address_Detail__c> shippingContactDetailsSameAddress = new List<Contact_Address_Detail__c>();
                    List<Contact_Address_Detail__c> shippingContactDetailsSameCity = new List<Contact_Address_Detail__c>();
                    List<Contact_Address_Detail__c> shippingContactDetailsUpsert = new List<Contact_Address_Detail__c>();
                    
                    if(ShippingAddress1 != null && ShippingAddress1 != '' && ShippingCity != null && ShippingCity != '' && (ShippingState != null && ShippingState != '') &&  ShippingZip != null && ShippingZip != '' && shippingContactId != null && shippingContactId != '' && accountId != null && accountId != '' && ShippingCountryName != null && ShippingCountryName != '')
                    {
                        system.debug('Inside Logic:::');
                        Contact_Address_Detail__c cad = new Contact_Address_Detail__c();
                        shippingContactDetailsSameAddressContact = [select id, name,Current_Index__c from Contact_Address_Detail__c where Contact__c =: shippingContactId And Account__c =: accountId And Shipping_Address_1__c =: ShippingAddress1 And Shipping_Address_2__c =: ShippingAddress2 And Shipping_City__c =: ShippingCity And Shipping_Country_Code__c =: ShippingCountryCode And Shipping_Country_Name__c =: ShippingCountryName And Shipping_State__c =: ShippingState And Shipping_Zip__c =: ShippingZip order By Current_Index__c DESC LIMIT 1];
                        if(shippingContactDetailsSameAddressContact.size() == 0)
                        {
                            shippingContactDetailsSameAddress = [select id, name, Current_Index__c from Contact_Address_Detail__c where Account__c =: accountId And Shipping_Address_1__c =: ShippingAddress1 And Shipping_Address_2__c =: ShippingAddress2 And Shipping_City__c =: ShippingCity And Shipping_Country_Code__c =: ShippingCountryCode And Shipping_Country_Name__c =: ShippingCountryName And Shipping_State__c =: ShippingState And Shipping_Zip__c =: ShippingZip order By Current_Index__c DESC LIMIT 1];
                            if(shippingContactDetailsSameAddress.size() > 0)
                            {
                                system.debug('Inside Same Address:::');
                                cad.Account__c = accountId;
                                cad.Contact__c = shippingContactId;
                                cad.Shipping_Address_1__c = ShippingAddress1;
                                cad.Shipping_Address_2__c = ShippingAddress2;
                                cad.Shipping_City__c = ShippingCity;
                                cad.Shipping_State__c = ShippingState;
                                cad.Shipping_Zip__c = ShippingZip;
                                cad.Shipping_Country_Code__c = ShippingCountryCode;
                                cad.Shipping_Country_Name__c = ShippingCountryName;
                                cad.Current_Index__c = shippingContactDetailsSameAddress[0].Current_Index__c;
                                shippingContactDetailsUpsert.add(cad);
                                if(shippingContactDetailsSameAddress[0].Current_Index__c == 0)
                                    siteName = ShippingCity;
                                else
                                    siteName = ShippingCity + (shippingContactDetailsSameAddress[0].Current_Index__c);
                            }
                            else
                            {
                                shippingContactDetailsSameCity = [select id, name, Current_Index__c from Contact_Address_Detail__c where Account__c =: accountId And Shipping_City__c =: ShippingCity order By Current_Index__c DESC LIMIT 1];
                                if(shippingContactDetailsSameCity.size() > 0)
                                {
                                    system.debug('Inside Same City:::');
                                    system.debug('shippingContactDetailsSameCity:::'+shippingContactDetailsSameCity);
                                    cad.Account__c = accountId;
                                    cad.Contact__c = shippingContactId;
                                    cad.Shipping_Address_1__c = ShippingAddress1;
                                    cad.Shipping_Address_2__c = ShippingAddress2;
                                    cad.Shipping_City__c = ShippingCity;
                                    cad.Shipping_State__c = ShippingState;
                                    cad.Shipping_Zip__c = ShippingZip;
                                    cad.Shipping_Country_Code__c = ShippingCountryCode;
                                    cad.Shipping_Country_Name__c = ShippingCountryName;
                                    cad.Current_Index__c = (shippingContactDetailsSameCity[0].Current_Index__c + 1);
                                    shippingContactDetailsUpsert.add(cad);
                                    if(shippingContactDetailsSameCity[0].Current_Index__c == 0)
                                        siteName = ShippingCity + 1;
                                    else
                                        siteName = ShippingCity + (shippingContactDetailsSameCity[0].Current_Index__c + 1);
                                }
                                else
                                {
                                    system.debug('Inside Nothing:::');
                                    cad.Account__c = accountId;
                                    cad.Contact__c = shippingContactId;
                                    cad.Shipping_Address_1__c = ShippingAddress1;
                                    cad.Shipping_Address_2__c = ShippingAddress2;
                                    cad.Shipping_City__c = ShippingCity;
                                    cad.Shipping_State__c = ShippingState;
                                    cad.Shipping_Zip__c = ShippingZip;
                                    cad.Shipping_Country_Code__c = ShippingCountryCode;
                                    cad.Shipping_Country_Name__c = ShippingCountryName;
                                    cad.Current_Index__c = 0;
                                    shippingContactDetailsUpsert.add(cad);
                                    siteName = ShippingCity;
                                }
                            }
                        }
                        else
                        {
                            system.debug('Inside Existing:::');
                            if(shippingContactDetailsSameAddressContact[0].Current_Index__c == 0)
                                siteName = ShippingCity;
                            else
                                siteName = ShippingCity + shippingContactDetailsSameAddressContact[0].Current_Index__c;
                            contactAddressDetail = shippingContactDetailsSameAddressContact[0].Id;
                        }
                        if(shippingContactDetailsUpsert.size() > 0)
                        {
                            upsert shippingContactDetailsUpsert;
                            contactAddressDetail = shippingContactDetailsUpsert[0].Id;
                        }
                    }
                    //Till here
                    
                    //To assign site name and contact Address details in case
                    for(Case caseRec : toUpdate)
                    {
                        if(!caseRec.Sent_to_CFS__c)
                        {
                            //Site Name
                            caseRec.Site_Name1__c = siteName;
                            caseRec.Contact_Address_Detail__c = contactAddressDetail;
                            System.debug('siteName::::'+siteName);
                            System.debug('contactAddressDetail::::'+contactAddressDetail);
                        }
                    }
                }
                TrggrUtility.RunOnce = true;
                
                update toUpdate;
            }
        }
    }
    Catch(Exception ex)
    {
        System.debug('Exception in Upsert:'+ex);
        System.debug('Exception line number:'+ex.getLineNumber());
    } 
    try
    {
        //Create Activity History when Mail is sent
        if(Trigger.isInsert || Test.isRunningTest())
        {
            List<Case> caseList = [select id, Change_New_Status__c, AccountId, Shipping_City__c, RecordTypeId, Site_Name1__c, Current_Site_Name_Series__c, Billing_Contact_Phone__c, Shipping_Contact_Phone__c, External_LOGIN_EMAIL__c, Billing_Contact_Email__c, contactId, Billing_Contact__c, Billing_Contact__r.Email,Created_From_Capo_Form__c from Case where id In : newCaseMap.keySet() And RecordTypeId =: recordTypeId]; 
            List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
            List<EmailTemplate> templateList =  [SELECT Id, DeveloperName, FolderId, Folder.DeveloperName from EmailTemplate where DeveloperName = 'RCS_Web_to_case_Template_Case_Object_Updated'];
            for(Case caseRec : caseList)
            {
                if(caseRec.Created_From_Capo_Form__c)
                {
                    System.debug('Inside send mail:');
                    if(templateList.size() > 0)
                    {
                        if(caseRec.Billing_Contact__c != null && caseRec.Billing_Contact__r.Email != null)
                        {
                            Messaging.SingleEmailMessage theMessage = new Messaging.SingleEmailMessage();
        
                            theMessage.setTemplateId(templateList[0].Id);
        
                            theMessage.setTargetObjectId(caseRec.Billing_Contact__c);
        
                            List<String> toAddress = new List<String>();
                            if(caseRec.External_LOGIN_EMAIL__c != null)
                                toAddress.add(caseRec.External_LOGIN_EMAIL__c);
                            if(caseRec.Billing_Contact_Email__c != null)
                                toAddress.add(caseRec.Billing_Contact_Email__c);
                            theMessage.setToAddresses(toAddress);
                            theMessage.setWhatId(caseRec.Id); 
                            theMessage.setSaveAsActivity(true); 
                            messages.add(theMessage);   
                        }
                    }
                }
            }
            
            if(messages.size() > 0 && !Test.isRunningTest())
            {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            }
        }   
    }
    Catch(Exception ex)
    {
        System.debug('Exception in sending Mail:'+ex);
    } 
}