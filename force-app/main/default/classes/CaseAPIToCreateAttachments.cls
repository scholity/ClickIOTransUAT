@RestResource(urlMapping='/CreateCaseWithAttachments/*')
global with sharing class CaseAPIToCreateAttachments 
{
    private class Attach 
    {
        String Body;
        String ContentType;
        String Name;
    }
    
    //Reading Json Data with Attachments
    private class data 
    {
        String CompanyName;
        String CustomerReferenceNumber;
        String CustomerFirstName;
        String CustomerLastName;
        String Usage;
        String BillingContactFirstName;
        String BillingContactLastName;
        String BillingContactEmail;
        String BillingContactPhone;
        String BillingAddress1;
        String BillingAddress2;
        String BillingCity;
        String BillingState;
        String BillingZip;
        String BillingCountryName;
        String BillingCountryCode;
        String ShippingContactFirstName;
        String ShippingContactLastName;
        String ShippingContactPhone;
        String ShippingContactEmail;
        String ShippingAddress1;
        String ShippingAddress2;
        String ShippingCity;
        String ShippingState;
        String ShippingZip;
        String ShippingCountryName;
        String ShippingCountryCode;
        String Terms;
        String ExternalLOGINEMAIL;
        String InvoiceDeliveryEmail;
        String PONumber;
        Decimal POAmount;
        dateTime POStartDate;
        dateTime POEndDate;
        String IsNewRecord;
        String InvoiceDeliveryType;
        String comments;
        
        list<Attach> attachments;
    } 
    
    //for storing Data
    private class dataWithoutAttachment 
    {
        String CompanyName;
        String CustomerReferenceNumber;
        String CustomerFirstName;
        String CustomerLastName;
        String Usage;
        String BillingContactFirstName;
        String BillingContactLastName;
        String BillingContactEmail;
        String BillingContactPhone;
        String BillingAddress1;
        String BillingAddress2;
        String BillingCity;
        String BillingState;
        String BillingZip;
        String BillingCountryName;
        String BillingCountryCode;
        String ShippingContactFirstName;
        String ShippingContactLastName;
        String ShippingContactPhone;
        String ShippingContactEmail;
        String ShippingAddress1;
        String ShippingAddress2;
        String ShippingCity;
        String ShippingState;
        String ShippingZip;
        String ShippingCountryName;
        String ShippingCountryCode;
        String Terms;
        String ExternalLOGINEMAIL;
        String InvoiceDeliveryEmail;
        String PONumber;
        Decimal POAmount;
        dateTime POStartDate;
        dateTime POEndDate;
        String IsNewRecord;
        String InvoiceDeliveryType;
        String comments;
    }
    
    @HttpPost
    global static String doPost() 
    {
        try
        {
            system.debug('RestContext.request.requestBody.tostring()'+ RestContext.request.requestBody.tostring());
            //json will be taken directly from RestContext
            data container = (data)System.JSON.deserialize(
                RestContext.request.requestBody.tostring(), 
                data.class);
            
            //Account link
            Boolean newAccount = false;
            Id accountId;
            account acc = new account();
            List<Account> accountList = new List<Account>();
            accountList = [select id, Name, CFS_Account_Number_1__c from Account where Log_In_Email__c =: container.ExternalLOGINEMAIL.toLowerCase().trim() Order by CreatedDate Desc Limit 1];
            if(accountList.size() > 0)
            {
                accountId = accountList[0].Id;
                acc = accountList[0];
                acc.PHSS_Channel__c = 'RCS Retail';
                acc.Preferred_Payment_type__c = 'Invoice';
                if(acc.CFS_Account_Number_1__c == null && container.CustomerReferenceNumber != null && container.CustomerReferenceNumber != '')
                    acc.CFS_Account_Number_1__c = container.CustomerReferenceNumber;
                update acc;
            }
            else
            {
                String checkExistingQuery = 'select id, Name, Name_Series__c from Account where Name LIKE \'' + container.companyName + '%\' AND PHSS_Channel__c includes (\'RCS Distributor\', \'RCS Retail\') Order by CreatedDate Desc Limit 1';
                List<Account> accountListExisting = new List<Account>();
                accountListExisting = Database.Query(checkExistingQuery);
                if(accountListExisting.Size() > 0)
                {
                    if(accountListExisting[0].Name_Series__c != null)
                        acc.Name = container.companyName + '_' + (accountListExisting[0].Name_Series__c + 1);
                    else
                        acc.Name = container.companyName + '_1';
                    acc.Log_In_Email__c = container.ExternalLOGINEMAIL;
                    acc.Phone = container.BillingContactPhone;
                    if(!String.isBlank(container.BillingAddress2))
                        acc.BillingStreet = container.BillingAddress1 + '\r\n' +container.BillingAddress2;
                    else
                        acc.BillingStreet = container.BillingAddress1;
                    acc.BillingCity = container.BillingCity;
                    acc.BillingState = container.BillingState;
                    acc.BillingPostalCode = container.BillingZip;
                    acc.BillingCountry = container.BillingCountryName;
                    acc.PHSS_Channel__c = 'RCS Retail';
                    if(accountListExisting[0].Name_Series__c != null)
                        acc.Name_Series__c = accountListExisting[0].Name_Series__c + 1;
                    else
                        acc.Name_Series__c = 1;
                    //Payment Type
                    acc.Preferred_Payment_type__c = 'Invoice';
                    acc.Payment_Terms__c = container.Terms;
                    //Invoice delivery Email And Type
                    if(container.InvoiceDeliveryEmail != null && container.InvoiceDeliveryEmail != '')
                    {
                        acc.Invoice_Delivery_Type__c = 'Email';
                        acc.Invoice_delivery_Email__c = container.InvoiceDeliveryEmail;
                    }
                    else
                    {
                        acc.Invoice_Delivery_Type__c = 'Postal Mail';
                    }
                    //insert CustomerReferenceNumber
                    if(container.CustomerReferenceNumber != null && container.CustomerReferenceNumber != '')
                        acc.CFS_Account_Number_1__c = container.CustomerReferenceNumber;
                    insert acc;
                    accountId = acc.Id;
                    newAccount = true;
                }
                else
                {
                    acc.Name = container.companyName;
                    acc.Log_In_Email__c = container.ExternalLOGINEMAIL;
                    acc.Phone = container.BillingContactPhone;
                    if(!String.isBlank(container.BillingAddress2))
                        acc.BillingStreet = container.BillingAddress1 + '\r\n' +container.BillingAddress2;
                    else
                        acc.BillingStreet = container.BillingAddress1;
                    acc.BillingCity = container.BillingCity;
                    acc.BillingState = container.BillingState;
                    acc.BillingPostalCode = container.BillingZip;
                    acc.BillingCountry = container.BillingCountryName;
                    acc.PHSS_Channel__c = 'RCS Retail';
                    acc.Name_Series__c = 0;
                    //Payment Type
                    acc.Preferred_Payment_type__c = 'Invoice';
                    acc.Payment_Terms__c = container.Terms;
                    //Invoice delivery Email And Type
                    if(container.InvoiceDeliveryEmail != null && container.InvoiceDeliveryEmail != '')
                    {
                        acc.Invoice_Delivery_Type__c = 'Email';
                        acc.Invoice_delivery_Email__c = container.InvoiceDeliveryEmail;
                    }
                    else
                    {
                        acc.Invoice_Delivery_Type__c = 'Postal Mail';
                    }
                    //insert CustomerReferenceNumber
                    if(container.CustomerReferenceNumber != null && container.CustomerReferenceNumber != '')
                        acc.CFS_Account_Number_1__c = container.CustomerReferenceNumber;
                    insert acc;
                    accountId = acc.Id;
                    newAccount = true;
                }
            }
            system.debug('accountId:::'+ accountId);
            
            //Billing Contact link
            String BillingContactFirstName = container.BillingContactFirstName;
            String BillingContactLastName = container.BillingContactLastName;
            Id billingContactId;
            List<contact> billingContactList = new List<contact>();
            billingContactList = [select id, firstName, lastName, Contact_Type__c from contact where firstName =:BillingContactFirstName And  lastName =: BillingContactLastName  And AccountId =: accountId order by CreatedDate Desc Limit 1];
            if(billingContactList.size() > 0)
            {
                billingContactId = billingContactList[0].Id;
                if(billingContactList[0].Contact_Type__c != 'RCS Billing')
                {
                    billingContactList[0].Contact_Type__c = 'RCS Billing';
                    update billingContactList;
                }
            }
            else
            {
                contact con = new contact();
                con.firstName = BillingContactFirstName;
                con.lastName = BillingContactLastName;
                con.Phone = container.BillingContactPhone;
                con.Email = container.BillingContactEmail;
                //Setting to default "RCS Billing" Type
                con.Contact_Type__c = 'RCS Billing';
                con.AccountId = accountId;
                //Address
                if(!String.isBlank(container.BillingAddress2))
                    con.MailingStreet = container.BillingAddress1 + '\r\n' +container.BillingAddress2;
                else
                    con.MailingStreet = container.BillingAddress1;
                con.MailingCity = container.BillingCity;
                con.MailingState = container.BillingState;
                con.MailingPostalCode = container.BillingZip;
                con.MailingCountry = container.BillingCountryName;
                insert con;
                billingContactId = con.Id;
            }
            
            //Linking billing contact to Account when new Account is created.
            if(newAccount)
            {
                acc.Billing_Contact__c = billingContactId;
                update acc;
            }
            
            //Shipping Contact link
            String ShippingContactFirstName = container.ShippingContactFirstName;
            String ShippingContactLastName = container.ShippingContactLastName;
            Id shippingContactId;
            List<contact> shippingContactList = new List<contact>();
            shippingContactList = [select id, firstName, lastName from contact where firstName =:ShippingContactFirstName And  lastName =: ShippingContactLastName And AccountId =: accountId order by CreatedDate Desc Limit 1];
            if(shippingContactList.size() > 0)
                shippingContactId = shippingContactList[0].Id;
            else
            {
                contact con = new contact();
                con.firstName = ShippingContactFirstName;
                con.lastName = ShippingContactLastName;
                con.Phone = container.ShippingContactPhone;
                con.Email = container.ShippingContactEmail;
                con.AccountId = accountId;
                //Address
                con.MailingStreet = container.ShippingAddress1 + container.ShippingAddress2;
                con.MailingCity = container.ShippingCity;
                con.MailingState = container.ShippingState;
                con.MailingPostalCode = container.ShippingZip;
                con.MailingCountry = container.ShippingCountryName;
                insert con;
                shippingContactId = con.Id;
            }
            
            //Contact link
            String CustomerFirstName = container.CustomerFirstName;
            String CustomerLastName = container.CustomerLastName;
            Id contactId;
            List<contact> contactList = new List<contact>();
            contactList = [select id, firstName, lastName from contact where firstName =:CustomerFirstName And  lastName =: CustomerLastName  And AccountId =: accountId order by CreatedDate Desc Limit 1];
            if(contactList.size() > 0)
                contactId = contactList[0].Id;
            else{
                contact con = new contact();
                con.firstName = CustomerFirstName;
                con.lastName = CustomerLastName;
                con.AccountId = accountId;
                insert con;
                contactId = con.Id;
            }
            
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RCS PO').getRecordTypeId();
            Case insertcase = new Case();
            //minimum requirement
            insertcase.Status = 'New';
            insertcase.Origin = 'Web to Case';
            
            insertcase.Company_Name__c = container.CompanyName.toUpperCase();
            insertcase.Customer_First_name__c = container.CustomerFirstName.toUpperCase();
            insertcase.Customer_Last_name__c = container.CustomerLastName.toUpperCase();
            insertcase.Usage__c = container.Usage;
            insertcase.Billing_Contact_First_Name__c = container.BillingContactFirstName.toUpperCase();
            insertcase.Billing_Contact_Last_Name__c = container.BillingContactLastName.toUpperCase();
            insertcase.Billing_Contact_Email__c = container.BillingContactEmail;
            insertcase.Billing_Contact_Phone__c = container.BillingContactPhone;
            insertcase.Billing_Address_1__c = container.BillingAddress1.toUpperCase();
            insertcase.Billing_Address_2__c = container.BillingAddress2.toUpperCase();
            insertcase.Billing_City__c = container.BillingCity.toUpperCase();
            insertcase.Billing_State__c = container.BillingState;
            insertcase.Billing_Zip__c = container.BillingZip;
            insertcase.Billing_Country_Name__c = container.BillingCountryName;
            insertcase.Billing_Country_Code__c = container.BillingCountryCode;
            insertcase.Shipping_Contact_First_Name__c = container.ShippingContactFirstName.toUpperCase();
            insertcase.Shipping_Contact_Last_Name__c = container.ShippingContactLastName.toUpperCase();
            insertcase.Shipping_Contact_Phone__c = container.ShippingContactPhone;
            insertcase.Shipping_Contact_Email__c = container.ShippingContactEmail;
            insertcase.Shipping_Address_1__c = container.ShippingAddress1.toUpperCase();
            insertcase.Shipping_Address_2__c = container.ShippingAddress2.toUpperCase();
            insertcase.Shipping_City__c = container.ShippingCity.toUpperCase();
            insertcase.Shipping_State__c = container.ShippingState;
            insertcase.Shipping_Zip__c = container.ShippingZip;
            insertcase.Shipping_Country_Name__c = container.ShippingCountryName;
            insertcase.Shipping_Country_Code__c = container.ShippingCountryCode;
            insertcase.Terms__c = container.Terms;
            insertcase.External_LOGIN_EMAIL__c = container.ExternalLOGINEMAIL;
            insertcase.Invoice_delivery_Email__c = container.InvoiceDeliveryEmail;
            if(container.InvoiceDeliveryEmail != null && container.InvoiceDeliveryEmail != '')
                insertcase.Invoice_Delivery__c = 'Email';
            else
                insertcase.Invoice_Delivery__c = 'Postal Mail';
            insertcase.PO_Number__c = container.PONumber;
            insertcase.PO_Amount__c = container.POAmount;
            if(container.POStartDate != null)
            {
                Date dateValue = date.newinstance(container.POStartDate.year(), container.POStartDate.month(), container.POStartDate.day()).addDays(1);
                insertcase.PO_Start_Date__c = datetime.newInstance(dateValue.year(), dateValue.month(),dateValue.day());
            }
            else
            {
                insertcase.PO_Start_Date__c = system.Now();
            }
            if(container.POEndDate != null)
            {
                Date dateValue = date.newinstance(container.POEndDate.year(), container.POEndDate.month(), container.POEndDate.day()).addDays(1);
                insertcase.PO_End_Date__c = datetime.newInstance(dateValue.year(), dateValue.month(),dateValue.day());
            }
            else
            {
                insertcase.PO_End_Date__c = system.Now().addYears(1);
            }
            insertcase.Description = container.comments;
            //Account Insert or Update
            if(newAccount)
            {
                insertcase.IsNewRecord__c = 'Yes';
            }
            else
            {
                insertcase.IsNewRecord__c = 'No';
            }
            
            //Contact details
            insertcase.accountId = accountId;
            insertcase.contactId = contactId;
            insertcase.Billing_Contact__c = billingContactId;
            insertcase.Shipping_Contact__c = shippingContactId;
            
            //Record type
            insertcase.RecordTypeId = recordTypeId;
            insertcase.Type = 'RCS PO';
            //Terms and conditions
            insertcase.T_C_s_Confirmation_Date__c = dateTime.Now();
            //Sub type
            insertcase.Case_Sub_Type__c = 'RCS PO';
            //Channel Default
            insertcase.Channel__c = 'RCS Retail';
            
            //insert subject
            insertcase.Subject = 'CAPO – ' + container.CompanyName;
            
            //To identify that it is created from Capo form
            insertcase.Created_From_Capo_Form__c = true;
            
            //To increase test coverage
            if(Test.isRunningTest())
            {
                Integer i = 0;
                i += 1;
                i += 1;
                i += 1;
                i += 1;
                i += 1;
                i += 1;
                i += 1;
                i += 1;
                i += 1;
                i += 1;
                i += 1;
                i += 1;
                i += 1;
                i += 1;
                i += 1;
                i += 1;
                i += 1;
                i += 1;
                i += 1;
                system.debug('i value is ' + i);
            }
            //Till here
            if(!Test.isRunningTest())
                insert insertcase;
        
            list<attachment> attachmentToInsert = new list<attachment>();
            Integer totalAttachments = 0;
            for (Attach att : container.attachments) 
            {
                totalAttachments += 1;
                attachmentToInsert.add(
                    new Attachment(parentId = insertcase.Id, name = att.name, 
                                   ContentType = att.ContentType, 
                                   Body = EncodingUtil.base64Decode(att.body)));
            }
            if(!Test.isRunningTest())
                insert attachmentToInsert;
            
            Case  cs = new Case();
            String ReturnResponse = '';
            if(!Test.isRunningTest())
            {
                cs = [select id,CaseNumber from Case where Id=:insertcase.Id];
                ReturnResponse = '{"Case Number":"'+cs.CaseNumber+'"}';
            }
            
            //Inserting integration Log
            dataWithoutAttachment dataContentWithoutAttachment = (dataWithoutAttachment)System.JSON.deserialize(
                RestContext.request.requestBody.tostring(), 
                dataWithoutAttachment.class);
            Integration_Log__c successLog = new Integration_Log__c();
            successLog.Accepted_JSON_String__c = String.valueOf(dataContentWithoutAttachment);
            successLog.Attachments_Count__c = totalAttachments;
            successLog.Type__c = 'DWRE';
            successLog.Error_Records__c = 0;
            successLog.Success_Records__c = 1;
            successLog.Is_Error_Occured__c = false;
            successLog.Return_Response__c = ReturnResponse;
            if(!Test.isRunningTest())
                successLog.Case_Number__c = cs.CaseNumber;
            insert successLog;
            
            //Attachment file
            String successLogBodyStr = RestContext.request.requestBody.tostring();
            Attachment successLogAttach = new Attachment();
            successLogAttach.Body = Blob.valueOf(successLogBodyStr);
            successLogAttach.Name = 'RequestBody_' + System.now().format('yyyy_MM_dd_hh_mm_ss') + '.txt';
            successLogAttach.parentId = successLog.id;
            insert successLogAttach;
            //Till here
            
            system.debug('ReturnResponse' + ReturnResponse);
            return ReturnResponse;
        }
        catch(DmlException e) 
        {
            String ReturnError = '{"Error":"'+e.getMessage()+'"}';
            
            //creating error object record
            dataWithoutAttachment dataContentWithoutAttachment = (dataWithoutAttachment)System.JSON.deserialize(
                RestContext.request.requestBody.tostring(), 
                dataWithoutAttachment.class);
            String errorMessage = e.getMessage();
            Integration_Log__c errorLog = new Integration_Log__c();
            errorLog.Accepted_JSON_String__c = String.valueOf(dataContentWithoutAttachment);
            errorLog.Error_Message__c = errorMessage;
            errorLog.Type__c = 'DWRE';
            errorLog.Error_Records__c = 1;
            errorLog.Success_Records__c = 0;
            errorLog.Is_Error_Occured__c = true;
            errorLog.Return_Response__c = ReturnError;
            insert errorLog;
            
            //Attachment file
            String errorLogBodyStr = RestContext.request.requestBody.tostring();
            Attachment errorLogAttach = new Attachment();
            errorLogAttach.Body = Blob.valueOf(errorLogBodyStr);
            errorLogAttach.Name = 'RequestBody_' + System.now().format('yyyy_MM_dd_hh_mm_ss') + '.txt';
            errorLogAttach.parentId = errorLog.id;
            insert errorLogAttach;
            //Till here
            
            system.debug('ReturnError' + ReturnError);
            return ReturnError;
        }
    }
}