@istest
public class CaseAPIToCreateAttachmentsTest 
{
    static testMethod void testPostRestService()
    {
        //No Account No Contact Scenario
        System.runAs(new user(ID = UserInfo.getUserID()))
        {
            //Switch Custom Settings
            Switch__c  sw = new Switch__c ();
            sw.Name = 'CaseOwnerHistorySwitch';
            sw.Switch__c = false;
            sw.Switch_Description__c = 'Test';
            insert sw;
            
            //Validation rule
            Validation_Rules__c valRule = Validation_Rules__c.getOrgDefaults();
            valRule.Bypass_Rules__c = false;
            insert valRule; 
            
            //json generator
            JSONGenerator gen = JSON.createGenerator(true);
            
            gen.writeStartObject();
            
                gen.writeStringField('CompanyName', 'ABC Infotech');
                gen.writeStringField('CustomerFirstName', 'Corey');
                gen.writeStringField('CustomerLastName', 'Burke');
                gen.writeStringField('Usage', 'BILL TO');
                gen.writeStringField('BillingContactFirstName', 'suhas');
                gen.writeStringField('BillingContactLastName', 'mario');
                gen.writeStringField('BillingContactEmail', 'suhas.mario@redcross.org');
                gen.writeStringField('BillingContactPhone', '(999) 999-9999');
                gen.writeStringField('BillingAddress1', 'P.O Box 690429');
                gen.writeStringField('BillingAddress2', 'FL 32869-0429');
                gen.writeStringField('BillingCity', 'Orlando');
                gen.writeStringField('BillingState', 'FL');
                gen.writeStringField('BillingZip', '69042');
                gen.writeStringField('BillingCountryName', 'USA');
                gen.writeStringField('BillingCountryCode', 'US');
                gen.writeStringField('ShippingContactFirstName', 'Corey');
                gen.writeStringField('ShippingContactLastName', 'Burke');
                gen.writeStringField('ShippingContactPhone', '(202)303-6779');
                gen.writeStringField('ShippingContactEmail', 'corey.burke2@redcross.org');
                gen.writeStringField('ShippingAddress1', 'P.O Box 690429');
                gen.writeStringField('ShippingAddress2', 'Orlando FL 32869-0429 USA');
                gen.writeStringField('ShippingCity', 'Orlando');
                gen.writeStringField('ShippingState', 'FL');
                gen.writeStringField('ShippingZip', '69042');
                gen.writeStringField('ShippingCountryName', 'USA');
                gen.writeStringField('ShippingCountryCode', 'US');
                gen.writeStringField('Terms', 'NET 30');
                gen.writeStringField('ExternalLOGINEMAIL', 'corey.burke2@redcross.org');
                gen.writeStringField('InvoiceDeliveryEmail', 'corey.burke2@redcross.org');
                gen.writeStringField('PONumber', 'po-654');
                gen.writeNumberField('POAmount', 2500.00);
                gen.writeStringField('POStartDate', '2012-07-02T15:50:31.000+0000');
                gen.writeStringField('POEndDate', '2015-08-09T11:50:31.000+0000');
                
                gen.writeFieldName('attachments');
            
                    gen.writeStartArray();
            
                        gen.writeStartObject();
                        
                            gen.writeStringField('Body', 'd29ybGQ=');
                            gen.writeStringField('ContentType', 'text/plain');
                            gen.writeStringField('Name', 'hello.txt');
                        
                        gen.writeEndObject();
                        
                        gen.writeStartObject();
                        
                            gen.writeStringField('Body', 'd29ybGQ=');
                            gen.writeStringField('ContentType', 'text/plain');
                            gen.writeStringField('Name', 'hello1.txt');
                        
                        gen.writeEndObject();
            
                    gen.writeEndArray();
            
            gen.writeEndObject();
            
            //get string from JSON
            string bodyContent = gen.getAsString();
            system.debug('bodyContent:::'+bodyContent);
            String JsonMsg = JSON.serialize(bodyContent);
            
            system.debug('JsonMsg:::'+JsonMsg);
            Test.startTest();
            
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
                 
            req.requestURI = '/services/apexrest/CreateCaseWithAttachments';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(bodyContent);
            RestContext.request = req;
            RestContext.response= res;

            String response = CaseAPIToCreateAttachments.doPost();
            
            Test.stopTest();
        }
    }
    
    static testMethod void testPostRestService1()
    {
        //Account Existing and contact Existing Scenario with Same Address in Contact_Address_Detail__c.
        System.runAs(new user(ID = UserInfo.getUserID()))
        {
            //Switch Custom Settings
            Switch__c  sw = new Switch__c ();
            sw.Name = 'CaseOwnerHistorySwitch';
            sw.Switch__c = false;
            sw.Switch_Description__c = 'Test';
            insert sw;
            
            //Validation rule
            Validation_Rules__c valRule = Validation_Rules__c.getOrgDefaults();
            valRule.Bypass_Rules__c = false;
            insert valRule;
            
            Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Bucket Account').getRecordTypeId();
            
            //Bucket Custom settings
            Bucket_Account_Settings__c bas = Bucket_Account_Settings__c.getOrgDefaults();
            bas.Bucket_Account_Owner_ID__c = UserInfo.getUserID();
            bas.Bucket_Account_RecordTypeID__c = recordTypeId;
            bas.Default_Bucket_Name__c = 'Bucket Account';
            bas.Maximum_Size_of_Bucket__c = 5000;
            insert bas;
            
            Account acc = new Account();
            acc.Name = 'ABC Infotech';
            acc.Log_In_Email__c = 'corey.burke2@redcross.org';
            acc.PHSS_Channel__c = 'RCS Retail';
            acc.Preferred_Payment_type__c = 'Invoice';
            //Billing Address
            acc.BillingStreet = 'P.O Box 690429';
            acc.BillingCity = 'Orlando';
            acc.BillingState = 'FL';
            acc.BillingPostalCode = '69042';
            acc.BillingCountry = 'USA';
            acc.Invoice_Delivery_Type__c = 'Postal Mail';
            insert acc;
            
            contact con = new contact();
            con.firstName = 'Corey';
            con.lastName = 'Burke';
            con.Phone = '(999) 999-9999';
            con.Email = 'corey.burke2@redcross.org';
            con.AccountId = acc.Id;
            //Address
            con.MailingStreet = 'P.O Box 690429, Orlando FL 32869-0429 USA';
            con.MailingCity = 'Orlando';
            con.MailingState = 'FL';
            con.MailingPostalCode = '69042';
            con.MailingCountry = 'USA';
            insert con;
            
            //json generator
            JSONGenerator gen = JSON.createGenerator(true);
            
            gen.writeStartObject();
            
                gen.writeStringField('CompanyName', 'ABC Infotech');
                gen.writeStringField('CustomerFirstName', 'Corey');
                gen.writeStringField('CustomerLastName', 'Burke');
                gen.writeStringField('Usage', 'BILL TO');
                gen.writeStringField('BillingContactFirstName', 'suhas');
                gen.writeStringField('BillingContactLastName', 'mario');
                gen.writeStringField('BillingContactEmail', 'suhas.mario@redcross.org');
                gen.writeStringField('BillingContactPhone', '(999) 999-9999');
                gen.writeStringField('BillingAddress1', 'P.O Box 690429');
                gen.writeStringField('BillingAddress2', 'FL 32869-0429');
                gen.writeStringField('BillingCity', 'Orlando');
                gen.writeStringField('BillingState', 'FL');
                gen.writeStringField('BillingZip', '69042');
                gen.writeStringField('BillingCountryName', 'USA');
                gen.writeStringField('BillingCountryCode', 'US');
                gen.writeStringField('ShippingContactFirstName', 'Corey');
                gen.writeStringField('ShippingContactLastName', 'Burke');
                gen.writeStringField('ShippingContactPhone', '(202)303-6779');
                gen.writeStringField('ShippingContactEmail', 'corey.burke2@redcross.org');
                gen.writeStringField('ShippingAddress1', 'P.O Box 690429');
                gen.writeStringField('ShippingAddress2', 'Orlando FL 32869-0429 USA');
                gen.writeStringField('ShippingCity', 'Orlando');
                gen.writeStringField('ShippingState', 'FL');
                gen.writeStringField('ShippingZip', '69042');
                gen.writeStringField('ShippingCountryName', 'USA');
                gen.writeStringField('ShippingCountryCode', 'US');
                gen.writeStringField('Terms', 'NET 30');
                gen.writeStringField('ExternalLOGINEMAIL', 'corey.burke2@redcross.org');
                gen.writeStringField('InvoiceDeliveryEmail', 'corey.burke2@redcross.org');
                gen.writeStringField('PONumber', 'po-654');
                gen.writeNumberField('POAmount', 2500.00);
                gen.writeStringField('POStartDate', '2012-07-02T15:50:31.000+0000');
                gen.writeStringField('POEndDate', '2015-08-09T11:50:31.000+0000');
                gen.writeStringField('comments', 'Test comments');
                
                gen.writeFieldName('attachments');
            
                    gen.writeStartArray();
            
                        gen.writeStartObject();
                        
                            gen.writeStringField('Body', 'd29ybGQ=');
                            gen.writeStringField('ContentType', 'text/plain');
                            gen.writeStringField('Name', 'hello.txt');
                        
                        gen.writeEndObject();
                        
                        gen.writeStartObject();
                        
                            gen.writeStringField('Body', 'd29ybGQ=');
                            gen.writeStringField('ContentType', 'text/plain');
                            gen.writeStringField('Name', 'hello1.txt');
                        
                        gen.writeEndObject();
            
                    gen.writeEndArray();
            
            gen.writeEndObject();
            
            //get string from JSON
            string bodyContent = gen.getAsString();
            system.debug('bodyContent:::'+bodyContent);
            String JsonMsg = JSON.serialize(bodyContent);
            
            system.debug('JsonMsg:::'+JsonMsg);
            Test.startTest();
            
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
                 
            req.requestURI = '/services/apexrest/CreateCaseWithAttachments';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(bodyContent);
            RestContext.request = req;
            RestContext.response= res;

            String response = CaseAPIToCreateAttachments.doPost();
            
            Test.stopTest();
        }
    }
    
    static testMethod void testPostRestService2()
    {
        //Account And contact Existing Scenario with Same city name in Contact_Address_Detail__c.
        System.runAs(new user(ID = UserInfo.getUserID()))
        {
            //Switch Custom Settings
            Switch__c  sw = new Switch__c ();
            sw.Name = 'CaseOwnerHistorySwitch';
            sw.Switch__c = false;
            sw.Switch_Description__c = 'Test';
            insert sw;
            
            //Validation rule
            Validation_Rules__c valRule = Validation_Rules__c.getOrgDefaults();
            valRule.Bypass_Rules__c = false;
            insert valRule;
            
            Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Bucket Account').getRecordTypeId();
            
            //Bucket Custom settings
            Bucket_Account_Settings__c bas = Bucket_Account_Settings__c.getOrgDefaults();
            bas.Bucket_Account_Owner_ID__c = UserInfo.getUserID();
            bas.Bucket_Account_RecordTypeID__c = recordTypeId;
            bas.Default_Bucket_Name__c = 'Bucket Account';
            bas.Maximum_Size_of_Bucket__c = 5000;
            insert bas;
            
            Account acc = new Account();
            acc.Name = 'ABC Infotech';
            acc.Log_In_Email__c = 'corey.burke2@redcross.org';
            acc.PHSS_Channel__c = 'RCS Retail';
            acc.Preferred_Payment_type__c = 'Invoice';
            //Billing Address
            acc.BillingStreet = 'P.O Box 690429';
            acc.BillingCity = 'Orlando';
            acc.BillingState = 'FL';
            acc.BillingPostalCode = '69042';
            acc.BillingCountry = 'USA';
            acc.Invoice_Delivery_Type__c = 'Postal Mail';
            insert acc;
            
            contact con = new contact();
            con.firstName = 'Corey';
            con.lastName = 'Burke';
            con.Phone = '(999) 999-9999';
            con.Email = 'corey.burke2@redcross.org';
            con.AccountId = acc.Id;
            //Address
            con.MailingStreet = 'P.O Box 690429, Orlando FL 32869-0429 USA';
            con.MailingCity = 'Orlando';
            con.MailingState = 'FL';
            con.MailingPostalCode = '69042';
            con.MailingCountry = 'USA';
            insert con;
            
            //json generator
            JSONGenerator gen = JSON.createGenerator(true);
            
            gen.writeStartObject();
            
                gen.writeStringField('CompanyName', 'ABC Infotech');
                gen.writeStringField('CustomerFirstName', 'Mario');
                gen.writeStringField('CustomerLastName', 'Chethan');
                gen.writeStringField('Usage', 'BILL TO');
                gen.writeStringField('BillingContactFirstName', 'suhas');
                gen.writeStringField('BillingContactLastName', 'mario');
                gen.writeStringField('BillingContactEmail', 'suhas.mario@redcross.org');
                gen.writeStringField('BillingContactPhone', '(999) 999-9999');
                gen.writeStringField('BillingAddress1', 'P.O Box 690429');
                gen.writeStringField('BillingAddress2', 'FL 32869-0429');
                gen.writeStringField('BillingCity', 'Orlando');
                gen.writeStringField('BillingState', 'FL');
                gen.writeStringField('BillingZip', '69042');
                gen.writeStringField('BillingCountryName', 'USA');
                gen.writeStringField('BillingCountryCode', 'US');
                gen.writeStringField('ShippingContactFirstName', 'Corey');
                gen.writeStringField('ShippingContactLastName', 'Burke');
                gen.writeStringField('ShippingContactPhone', '(202)303-6779');
                gen.writeStringField('ShippingContactEmail', 'corey.burke2@redcross.org');
                gen.writeStringField('ShippingAddress1', 'P.O Box 690429');
                gen.writeStringField('ShippingAddress2', 'Orlando FL 32869-0429 USA');
                gen.writeStringField('ShippingCity', 'Orlando');
                gen.writeStringField('ShippingState', 'FL');
                gen.writeStringField('ShippingZip', '69042');
                gen.writeStringField('ShippingCountryName', 'USA');
                gen.writeStringField('ShippingCountryCode', 'US');
                gen.writeStringField('Terms', 'NET 30');
                gen.writeStringField('ExternalLOGINEMAIL', 'corey.burke2@redcross.org');
                gen.writeStringField('InvoiceDeliveryEmail', 'corey.burke2@redcross.org');
                gen.writeStringField('PONumber', 'po-654');
                gen.writeNumberField('POAmount', 2500.00);
                gen.writeStringField('POStartDate', '2012-07-02T15:50:31.000+0000');
                gen.writeStringField('POEndDate', '2015-08-09T11:50:31.000+0000');
                gen.writeStringField('comments', 'Test comments');
                
                gen.writeFieldName('attachments');
            
                    gen.writeStartArray();
            
                        gen.writeStartObject();
                        
                            gen.writeStringField('Body', 'd29ybGQ=');
                            gen.writeStringField('ContentType', 'text/plain');
                            gen.writeStringField('Name', 'hello.txt');
                        
                        gen.writeEndObject();
                        
                        gen.writeStartObject();
                        
                            gen.writeStringField('Body', 'd29ybGQ=');
                            gen.writeStringField('ContentType', 'text/plain');
                            gen.writeStringField('Name', 'hello1.txt');
                        
                        gen.writeEndObject();
            
                    gen.writeEndArray();
            
            gen.writeEndObject();
            
            //get string from JSON
            string bodyContent = gen.getAsString();
            system.debug('bodyContent:::'+bodyContent);
            String JsonMsg = JSON.serialize(bodyContent);
            
            system.debug('JsonMsg:::'+JsonMsg);
            Test.startTest();
            
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
                 
            req.requestURI = '/services/apexrest/CreateCaseWithAttachments';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(bodyContent);
            RestContext.request = req;
            RestContext.response= res;

            String response = CaseAPIToCreateAttachments.doPost();
            
            Test.stopTest();
        }
    }
    
    static testMethod void testPostRestService3()
    {
        //Account and contact existed And no data in Contact_Address_Detail__c.
        System.runAs(new user(ID = UserInfo.getUserID()))
        {
            //Switch Custom Settings
            Switch__c  sw = new Switch__c ();
            sw.Name = 'CaseOwnerHistorySwitch';
            sw.Switch__c = false;
            sw.Switch_Description__c = 'Test';
            insert sw;
            
            //Validation rule
            Validation_Rules__c valRule = Validation_Rules__c.getOrgDefaults();
            valRule.Bypass_Rules__c = false;
            insert valRule;
            
            Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Bucket Account').getRecordTypeId();
            
            //Bucket Custom settings
            Bucket_Account_Settings__c bas = Bucket_Account_Settings__c.getOrgDefaults();
            bas.Bucket_Account_Owner_ID__c = UserInfo.getUserID();
            bas.Bucket_Account_RecordTypeID__c = recordTypeId;
            bas.Default_Bucket_Name__c = 'Bucket Account';
            bas.Maximum_Size_of_Bucket__c = 5000;
            insert bas;
            
            Account acc = new Account();
            acc.Name = 'ABC Infotech';
            acc.Log_In_Email__c = 'corey.burke2@redcross.org';
            acc.PHSS_Channel__c = 'RCS Retail';
            acc.Preferred_Payment_type__c = 'Invoice';
            //Billing Address
            acc.BillingStreet = 'P.O Box 690429';
            acc.BillingCity = 'Orlando';
            acc.BillingState = 'FL';
            acc.BillingPostalCode = '69042';
            acc.BillingCountry = 'USA';
            acc.Invoice_Delivery_Type__c = 'Postal Mail';
            insert acc;
            
            contact con = new contact();
            con.firstName = 'Corey';
            con.lastName = 'Burke';
            con.Phone = '(999) 999-9999';
            con.Email = 'corey.burke2@redcross.org';
            con.AccountId = acc.Id;
            //Address
            con.MailingStreet = 'P.O Box 690429, Orlando FL 32869-0429 USA';
            con.MailingCity = 'Orlando';
            con.MailingState = 'FL';
            con.MailingPostalCode = '69042';
            con.MailingCountry = 'USA';
            insert con;
            
            //json generator
            JSONGenerator gen = JSON.createGenerator(true);
            
            gen.writeStartObject();
            
                gen.writeStringField('CompanyName', 'ABC Infotech');
                gen.writeStringField('CustomerFirstName', 'Corey');
                gen.writeStringField('CustomerLastName', 'Burke');
                gen.writeStringField('Usage', 'BILL TO');
                gen.writeStringField('BillingContactFirstName', 'suhas');
                gen.writeStringField('BillingContactLastName', 'mario');
                gen.writeStringField('BillingContactEmail', 'suhas.mario@redcross.org');
                gen.writeStringField('BillingContactPhone', '(999) 999-9999');
                gen.writeStringField('BillingAddress1', 'P.O Box 690429');
                gen.writeStringField('BillingAddress2', 'FL 32869-0429');
                gen.writeStringField('BillingCity', 'Orlando');
                gen.writeStringField('BillingState', 'FL');
                gen.writeStringField('BillingZip', '69042');
                gen.writeStringField('BillingCountryName', 'USA');
                gen.writeStringField('BillingCountryCode', 'US');
                gen.writeStringField('ShippingContactFirstName', 'Corey');
                gen.writeStringField('ShippingContactLastName', 'Burke');
                gen.writeStringField('ShippingContactPhone', '(202)303-6779');
                gen.writeStringField('ShippingContactEmail', 'corey.burke2@redcross.org');
                gen.writeStringField('ShippingAddress1', 'P.O Box 690429');
                gen.writeStringField('ShippingAddress2', 'Orlando FL 32869-0429 USA');
                gen.writeStringField('ShippingCity', 'Orlando');
                gen.writeStringField('ShippingState', 'FL');
                gen.writeStringField('ShippingZip', '69042');
                gen.writeStringField('ShippingCountryName', 'USA');
                gen.writeStringField('ShippingCountryCode', 'US');
                gen.writeStringField('Terms', 'NET 30');
                gen.writeStringField('ExternalLOGINEMAIL', 'corey.burke2@redcross.org');
                gen.writeStringField('InvoiceDeliveryEmail', 'corey.burke2@redcross.org');
                gen.writeStringField('PONumber', 'po-654');
                gen.writeNumberField('POAmount', 2500.00);
                gen.writeStringField('POStartDate', '2012-07-02T15:50:31.000+0000');
                gen.writeStringField('POEndDate', '2015-08-09T11:50:31.000+0000');
                gen.writeStringField('comments', 'Test comments');
                
                gen.writeFieldName('attachments');
            
                    gen.writeStartArray();
            
                        gen.writeStartObject();
                        
                            gen.writeStringField('Body', 'd29ybGQ=');
                            gen.writeStringField('ContentType', 'text/plain');
                            gen.writeStringField('Name', 'hello.txt');
                        
                        gen.writeEndObject();
                        
                        gen.writeStartObject();
                        
                            gen.writeStringField('Body', 'd29ybGQ=');
                            gen.writeStringField('ContentType', 'text/plain');
                            gen.writeStringField('Name', 'hello1.txt');
                        
                        gen.writeEndObject();
            
                    gen.writeEndArray();
            
            gen.writeEndObject();
            
            //get string from JSON
            string bodyContent = gen.getAsString();
            system.debug('bodyContent:::'+bodyContent);
            String JsonMsg = JSON.serialize(bodyContent);
            
            system.debug('JsonMsg:::'+JsonMsg);
            Test.startTest();
            
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
                 
            req.requestURI = '/services/apexrest/CreateCaseWithAttachments';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(bodyContent);
            RestContext.request = req;
            RestContext.response= res;

            String response = CaseAPIToCreateAttachments.doPost();
            
            Test.stopTest();
        }
    }
    
    static testMethod void testPostRestService4()
    {
        //Account with same name existed Senario And Contact_Address_Detail__c details with same city.
        System.runAs(new user(ID = UserInfo.getUserID()))
        {
            //Switch Custom Settings
            Switch__c  sw = new Switch__c ();
            sw.Name = 'CaseOwnerHistorySwitch';
            sw.Switch__c = false;
            sw.Switch_Description__c = 'Test';
            insert sw;
            
            //Validation rule
            Validation_Rules__c valRule = Validation_Rules__c.getOrgDefaults();
            valRule.Bypass_Rules__c = false;
            insert valRule;
            
            Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Bucket Account').getRecordTypeId();
            
            //Bucket Custom settings
            Bucket_Account_Settings__c bas = Bucket_Account_Settings__c.getOrgDefaults();
            bas.Bucket_Account_Owner_ID__c = UserInfo.getUserID();
            bas.Bucket_Account_RecordTypeID__c = recordTypeId;
            bas.Default_Bucket_Name__c = 'Bucket Account';
            bas.Maximum_Size_of_Bucket__c = 5000;
            insert bas;

            Account acc = new Account();
            acc.Name = 'ABC Infotech';
            acc.Log_In_Email__c = 'corey.burke2qaw@redcross.org';
            acc.PHSS_Channel__c = 'RCS Retail';
            acc.Preferred_Payment_type__c = 'Invoice';
            //Billing Address
            acc.BillingStreet = 'P.O Box 690429';
            acc.BillingCity = 'Orlando';
            acc.BillingState = 'FL';
            acc.BillingPostalCode = '69042';
            acc.BillingCountry = 'USA';
            acc.Invoice_Delivery_Type__c = 'Postal Mail';
            insert acc;
            
            //json generator
            JSONGenerator gen = JSON.createGenerator(true);
            
            gen.writeStartObject();
            
                gen.writeStringField('CompanyName', 'ABC Infotech');
                gen.writeStringField('CustomerFirstName', 'Corey');
                gen.writeStringField('CustomerLastName', 'Burke');
                gen.writeStringField('Usage', 'BILL TO');
                gen.writeStringField('BillingContactFirstName', 'suhas');
                gen.writeStringField('BillingContactLastName', 'mario');
                gen.writeStringField('BillingContactEmail', 'suhas.mario@redcross.org');
                gen.writeStringField('BillingContactPhone', '(999) 999-9999');
                gen.writeStringField('BillingAddress1', 'P.O Box 690429');
                gen.writeStringField('BillingAddress2', 'FL 32869-0429');
                gen.writeStringField('BillingCity', 'Orlando');
                gen.writeStringField('BillingState', 'FL');
                gen.writeStringField('BillingZip', '69042');
                gen.writeStringField('BillingCountryName', 'USA');
                gen.writeStringField('BillingCountryCode', 'US');
                gen.writeStringField('ShippingContactFirstName', 'Corey');
                gen.writeStringField('ShippingContactLastName', 'Burke');
                gen.writeStringField('ShippingContactPhone', '(202)303-6779');
                gen.writeStringField('ShippingContactEmail', 'corey.burke2@redcross.org');
                gen.writeStringField('ShippingAddress1', 'P.O Box 690429');
                gen.writeStringField('ShippingAddress2', 'Orlando FL 32869-0429 USA');
                gen.writeStringField('ShippingCity', 'Orlando');
                gen.writeStringField('ShippingState', 'FL');
                gen.writeStringField('ShippingZip', '69042');
                gen.writeStringField('ShippingCountryName', 'USA');
                gen.writeStringField('ShippingCountryCode', 'US');
                gen.writeStringField('Terms', 'NET 30');
                gen.writeStringField('ExternalLOGINEMAIL', 'corey.burke2@redcross.org');
                gen.writeStringField('InvoiceDeliveryEmail', 'corey.burke2@redcross.org');
                gen.writeStringField('PONumber', 'po-654');
                gen.writeNumberField('POAmount', 2500.00);
                gen.writeStringField('POStartDate', '2012-07-02T15:50:31.000+0000');
                gen.writeStringField('POEndDate', '2015-08-09T11:50:31.000+0000');
                gen.writeStringField('comments', 'Test comments');
                
                gen.writeFieldName('attachments');
            
                    gen.writeStartArray();
            
                        gen.writeStartObject();
                        
                            gen.writeStringField('Body', 'd29ybGQ=');
                            gen.writeStringField('ContentType', 'text/plain');
                            gen.writeStringField('Name', 'hello.txt');
                        
                        gen.writeEndObject();
                        
                        gen.writeStartObject();
                        
                            gen.writeStringField('Body', 'd29ybGQ=');
                            gen.writeStringField('ContentType', 'text/plain');
                            gen.writeStringField('Name', 'hello1.txt');
                        
                        gen.writeEndObject();
            
                    gen.writeEndArray();
            
            gen.writeEndObject();
            
            //get string from JSON
            string bodyContent = gen.getAsString();
            system.debug('bodyContent:::'+bodyContent);
            String JsonMsg = JSON.serialize(bodyContent);
            
            system.debug('JsonMsg:::'+JsonMsg);
            Test.startTest();
            
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
                 
            req.requestURI = '/services/apexrest/CreateCaseWithAttachments';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(bodyContent);
            RestContext.request = req;
            RestContext.response= res;

            String response = CaseAPIToCreateAttachments.doPost();
            
            Test.stopTest();
        }
    }
}