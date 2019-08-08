@istest
public class sendCSVToCFSTest
{
    @testSetup
    static void createTestData() {

        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Bucket Account').getRecordTypeId();

        //Bucket Custom settings
        Bucket_Account_Settings__c bas = Bucket_Account_Settings__c.getOrgDefaults();
        bas.Bucket_Account_Owner_ID__c = UserInfo.getUserID();
        bas.Bucket_Account_RecordTypeID__c = accRecordTypeId;
        bas.Default_Bucket_Name__c = 'Bucket Account';
        bas.Maximum_Size_of_Bucket__c = 5000;
        insert bas;
    }

    static testMethod void testGetRestService()
    {


        //Switch Custom Settings
        Switch__c  sw = new Switch__c ();
        sw.Name = 'CaseOwnerHistorySwitch';
        sw.Switch__c = false;
        sw.Switch_Description__c = 'Test';
        insert sw;

        //Validation rule
        Validation_Rules__c valRule = Validation_Rules__c.getOrgDefaults();
        valRule.Bypass_Rules__c = true;
        insert valRule;

        Account acc = new Account();
        acc.Name = 'ABC Infotech';
        acc.Log_In_Email__c = 'corey.burke2@redcross.org';
        acc.PHSS_Channel__c = 'RCS Retail';
        acc.Preferred_Payment_type__c = 'Invoice';
        acc.BillingStreet = 'P.O Box 690429';
        acc.BillingCity = 'Orlando';
        acc.BillingState = 'FL';
        acc.BillingPostalCode = '69042';
        acc.BillingCountry = 'USA';
        acc.Invoice_delivery_Email__c = 'corey.burke2@redcross.org';
        acc.Invoice_Delivery_Type__c = 'Postal Mail';
        acc.Payment_Terms__c = 'NET 60';
        insert acc;

        contact con = new contact();
        con.firstName = 'suhas';
        con.lastName = 'mario';
        con.Phone = '(999) 999-9999';
        con.Email = 'suhas.mario@redcross.org';
        con.AccountId = acc.Id;
        //Address
        con.MailingStreet = 'P.O Box 690429, Orlando FL 32869-0429 USA';
        con.MailingCity = 'Orlando';
        con.MailingState = 'FL';
        con.MailingPostalCode = '69042';
        con.MailingCountry = 'USA';
        con.Contact_Type__c = 'RCS Billing';
        insert con;

        acc.Billing_Contact__c = con.Id;
        update acc;

        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RCS PO').getRecordTypeId();
        Case insertcase = new Case();
        //minimum requirement
        insertcase.Status = 'New';
        insertcase.Origin = 'Phone';
        insertcase.Channel__c = 'RCS Retail';

        insertcase.Company_Name__c = 'ABC Infotech';
        insertcase.Customer_First_name__c = 'Corey';
        insertcase.Customer_Last_name__c = 'Burke';
        insertcase.Usage__c = 'BILL TO';
        insertcase.billing_Contact__c = con.Id;
        insertcase.ContactId = con.Id;
        insertcase.Billing_Contact_First_Name__c = 'suhas';
        insertcase.Billing_Contact_Last_Name__c = 'mario';
        insertcase.Billing_Contact_Email__c = 'suhas.mario@redcross.org';
        insertcase.Billing_Contact_Phone__c = '(999) 999-9999';
        insertcase.Billing_Address_1__c = 'P.O Box 690429';
        insertcase.Billing_Address_2__c = null;
        insertcase.Billing_City__c = 'Orlando';
        insertcase.Billing_State__c = 'FL';
        insertcase.Billing_Zip__c = '69042';
        insertcase.Billing_Country_Name__c = 'USA';
        insertcase.Billing_Country_Code__c = 'US';
        insertcase.Shipping_Contact_First_Name__c = 'Corey';
        insertcase.Shipping_Contact_Last_Name__c = 'Burke';
        insertcase.Shipping_Contact_Phone__c = '(202)303-6779';
        insertcase.Shipping_Contact_Email__c = 'corey.burke2@redcross.org';
        insertcase.Shipping_Address_1__c = 'P.O Box 690429';
        insertcase.Shipping_Address_2__c = 'Orlando FL 32869-0429 USA';
        insertcase.Shipping_City__c = 'Orlando';
        insertcase.Shipping_State__c = 'FL';
        insertcase.Shipping_Zip__c = '69042';
        insertcase.Shipping_Country_Name__c = 'USA';
        insertcase.Shipping_Country_Code__c = 'US';
        insertcase.Terms__c = 'NET 60';
        insertcase.External_LOGIN_EMAIL__c = 'corey.burke2@redcross.org';
        //insertcase.Invoice_delivery_Email__c = 'corey.burke2@redcross.org';
        insertcase.PO_Number__c = 'po-654';
        insertcase.PO_Amount__c = 2500.00;
        insertcase.PO_Start_Date__c = dateTime.Now();
        insertcase.PO_End_Date__c = dateTime.Now().addMonths(10);
        insertcase.IsNewRecord__c = 'Yes';
        //Record type
        insertcase.RecordTypeId = recordTypeId;
        insertcase.Type = 'RCS PO';
        //Terms and conditions
        insertcase.T_C_s_Confirmation_Date__c = dateTime.Now();
        //Sub type
        insertcase.Case_Sub_Type__c = 'RCS PO';

        //Account lookUp
        insertcase.AccountId = acc.Id;
        insertcase.Shipping_Contact__c = con.Id;
        insertcase.Invoice_Delivery__c = 'Postal Mail';
        insert insertcase;

        Test.startTest();
        //Status change
        insertcase.Site_Name1__c = 'Orlando';
        insertcase.Status = 'PO On-Hold CFS';
        update insertcase;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/getRCSPOFile';
        req.addParameter('StartDate', '2017-01-01');
        req.addParameter('EndDate', '2018-01-01');
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;

        String response = sendCSVToCFS.generateCSV();
        Test.stopTest();
    }

    static testMethod void testGetRestService1()
    {


        //Switch Custom Settings
        Switch__c  sw = new Switch__c ();
        sw.Name = 'CaseOwnerHistorySwitch';
        sw.Switch__c = false;
        sw.Switch_Description__c = 'Test';
        insert sw;

        //Validation rule
        Validation_Rules__c valRule = Validation_Rules__c.getOrgDefaults();
        valRule.Bypass_Rules__c = true;
        insert valRule;

        Account acc = new Account();
        acc.Name = 'ABC Infotech';
        acc.Log_In_Email__c = 'corey.burke2@redcross.org';
        acc.PHSS_Channel__c = 'RCS Retail';
        acc.Preferred_Payment_type__c = 'Invoice';
        acc.BillingStreet = 'P.O Box 690429';
        acc.BillingCity = 'Orlando';
        acc.BillingState = 'FL';
        acc.BillingPostalCode = '69042';
        acc.BillingCountry = 'USA';
        acc.Invoice_delivery_Email__c = 'corey.burke2@redcross.org';
        acc.Invoice_Delivery_Type__c = 'Postal Mail';
        acc.Payment_Terms__c = 'NET 60';
        insert acc;

        contact con = new contact();
        con.firstName = 'suhas';
        con.lastName = 'mario';
        con.Phone = '(999) 999-9999';
        con.Email = 'suhas.mario@redcross.org';
        con.AccountId = acc.Id;
        //Address
        con.MailingStreet = 'P.O Box 690429, Orlando FL 32869-0429 USA';
        con.MailingCity = 'Orlando';
        con.MailingState = 'FL';
        con.MailingPostalCode = '69042';
        con.MailingCountry = 'USA';
        con.Contact_Type__c = 'RCS Billing';
        insert con;

        acc.Billing_Contact__c = con.Id;
        update acc;

        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RCS PO').getRecordTypeId();
        Case insertcase = new Case();
        //minimum requirement
        insertcase.Status = 'New';
        insertcase.Origin = 'Phone';
        insertcase.Channel__c = 'RCS Retail';

        insertcase.Company_Name__c = 'ABC Infotech';
        insertcase.Customer_First_name__c = 'Corey';
        insertcase.Customer_Last_name__c = 'Burke';
        insertcase.Usage__c = 'BILL TO';
        insertcase.Billing_Contact__c = con.Id;
        insertcase.ContactId = con.Id;
        insertcase.Billing_Contact_First_Name__c = 'suhas';
        insertcase.Billing_Contact_Last_Name__c = 'mario';
        insertcase.Billing_Contact_Email__c = 'suhas.mario@redcross.org';
        insertcase.Billing_Contact_Phone__c = '(999) 999-9999';
        insertcase.Billing_Address_1__c = 'P.O Box 690429';
        insertcase.Billing_Address_2__c = null;
        insertcase.Billing_City__c = 'Orlando';
        insertcase.Billing_State__c = 'FL';
        insertcase.Billing_Zip__c = '69042';
        insertcase.Billing_Country_Name__c = 'USA';
        insertcase.Billing_Country_Code__c = 'US';
        insertcase.Shipping_Contact_First_Name__c = 'Corey';
        insertcase.Shipping_Contact_Last_Name__c = 'Burke';
        insertcase.Shipping_Contact_Phone__c = '(202)303-6779';
        insertcase.Shipping_Contact_Email__c = 'corey.burke2@redcross.org';
        insertcase.Shipping_Address_1__c = 'P.O Box 690429';
        insertcase.Shipping_Address_2__c = 'Orlando FL 32869-0429 USA';
        insertcase.Shipping_City__c = 'Orlando';
        insertcase.Shipping_State__c = 'FL';
        insertcase.Shipping_Zip__c = '69042';
        insertcase.Shipping_Country_Name__c = 'USA';
        insertcase.Shipping_Country_Code__c = 'US';
        insertcase.Terms__c = 'NET 60';
        insertcase.External_LOGIN_EMAIL__c = 'corey.burke2@redcross.org';
        //insertcase.Invoice_delivery_Email__c = 'corey.burke2@redcross.org';
        insertcase.PO_Number__c = 'po-654';
        insertcase.PO_Amount__c = 2500.00;
        insertcase.PO_Start_Date__c = dateTime.Now();
        insertcase.PO_End_Date__c = dateTime.Now().addMonths(10);
        insertcase.IsNewRecord__c = 'Yes';
        //Record type
        insertcase.RecordTypeId = recordTypeId;
        insertcase.Type = 'RCS PO';
        //Terms and conditions
        insertcase.T_C_s_Confirmation_Date__c = dateTime.Now();
        //Sub type
        insertcase.Case_Sub_Type__c = 'RCS PO';

        //Account lookUp
        insertcase.AccountId = acc.Id;
        insertcase.Invoice_Delivery__c = 'Postal Mail';
        insertcase.Shipping_Contact__c = con.Id;
        insert insertcase;

        Test.startTest();
        //Status change
        insertcase.Site_Name1__c = 'Orlando';
        insertcase.Status = 'PO On-Hold CFS';
        update insertcase;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/getRCSPOFile';
        req.addParameter('StartDate', '2017-01-01');
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;

        String response = sendCSVToCFS.generateCSV();
        Test.stopTest();
    }
    
    @isTest
    static void testException() {
        
        try {
            sendCSVToCFS.generateCSV();
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        
    }
}