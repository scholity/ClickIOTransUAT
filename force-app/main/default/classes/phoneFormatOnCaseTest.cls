@istest
public class phoneFormatOnCaseTest 
{
    static testMethod void testTriggerOnCase()
    {   
        //Same Address case in Contact_Address_Detail__c.
        Test.startTest();
        
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
        
        Id AccrecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Bucket Account').getRecordTypeId();
            
        //Bucket Custom settings
        Bucket_Account_Settings__c bas = Bucket_Account_Settings__c.getOrgDefaults();
        bas.Bucket_Account_Owner_ID__c = UserInfo.getUserID();
        bas.Bucket_Account_RecordTypeID__c = AccrecordTypeId;
        bas.Default_Bucket_Name__c = 'Bucket Account';
        bas.Maximum_Size_of_Bucket__c = 5000;
        insert bas;
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Log_In_Email__c = 'corey.burke2@redcross.org';
        acc.PHSS_Channel__c = 'RCS Retail';
        acc.Preferred_Payment_type__c = 'Invoice';
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
        con.Contact_Type__c = 'RCS Billing';
        insert con;
        
        acc.Billing_Contact__c = con.Id;
        Update acc;
        
        Contact_Address_Detail__c cad = new Contact_Address_Detail__c();
        cad.Account__c = acc.Id;
        cad.Shipping_Address_1__c = 'P.O Box 690429';
        cad.Shipping_Address_2__c = 'FL 32869-0429';
        cad.Shipping_City__c = 'Orlando';
        cad.Shipping_State__c = 'FL';
        cad.Shipping_Zip__c = '69042';
        cad.Shipping_Country_Code__c = 'US';
        cad.Shipping_Country_Name__c = 'USA';
        cad.Current_Index__c = 0;
        insert cad;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RCS PO').getRecordTypeId();
        //First Case
        Case insertcase = new Case();
        //minimum requirement
        insertcase.Status = 'New';
        insertcase.Origin = 'Phone';
        insertcase.Channel__c = 'RCS Retail';
        
        insertcase.Company_Name__c = 'ABC Infotech';
        insertcase.Customer_First_name__c = 'Corey';
        insertcase.Customer_Last_name__c = 'Burke';
        insertcase.Usage__c = 'BILL TO';
        insertcase.ContactId = con.Id;
        insertcase.Billing_Contact_Phone__c = '9999999999';
        insertcase.Shipping_Contact__c = con.Id;
        insertcase.Shipping_Contact_First_Name__c = 'Corey';
        insertcase.Shipping_Contact_Last_Name__c = 'Burke';
        insertcase.Shipping_Contact_Phone__c = '9999999999';
        insertcase.Shipping_Contact_Email__c = 'corey.burke2@redcross.org';
        insertcase.Shipping_Address_1__c = 'P.O Box 690429';
        insertcase.Shipping_Address_2__c = 'Orlando FL 32869-0429 USA';
        insertcase.Shipping_City__c = 'Orlando';
        insertcase.Shipping_State__c = 'FL';
        insertcase.Shipping_Zip__c = '69042';
        insertcase.Shipping_Country_Name__c = 'USA';
        insertcase.Shipping_Country_Code__c = 'US';
        insertcase.Terms__c = 'NET 30';
        insertcase.External_LOGIN_EMAIL__c = 'corey.burke2@redcross.org';
        insertcase.Invoice_delivery_Email__c = 'corey.burke2@redcross.org';
        insertcase.PO_Number__c = 'po-654';
        insertcase.PO_Amount__c = 2500.00;
        insertcase.PO_Start_Date__c = dateTime.Now();
        insertcase.PO_End_Date__c = dateTime.Now();
        insertcase.IsNewRecord__c = 'Yes';
        insertcase.Created_From_Capo_Form__c  = false;
        //Record type
        insertcase.RecordTypeId = recordTypeId;
        insertcase.Type = 'RCS PO';
        //Terms and conditions
        insertcase.T_C_s_Confirmation_Date__c = dateTime.Now();
        //Sub type
        insertcase.Case_Sub_Type__c = 'RCS PO';
        
        //Account lookUp
        insertcase.AccountId = acc.Id;
        insertcase.Copy_Billing_to_Shipping__c = true;
        
        insertcase.Status = 'On Hold - Internal';
        
        insert insertcase;
    }
    
    static testMethod void testTriggerOnCase1()
    {   
        //Same City case in Contact_Address_Detail__c.
        Test.startTest();
        
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
        
        Id AccrecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Bucket Account').getRecordTypeId();
            
        //Bucket Custom settings
        Bucket_Account_Settings__c bas = Bucket_Account_Settings__c.getOrgDefaults();
        bas.Bucket_Account_Owner_ID__c = UserInfo.getUserID();
        bas.Bucket_Account_RecordTypeID__c = AccrecordTypeId;
        bas.Default_Bucket_Name__c = 'Bucket Account';
        bas.Maximum_Size_of_Bucket__c = 5000;
        insert bas;
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Log_In_Email__c = 'corey.burke2@redcross.org';
        acc.PHSS_Channel__c = 'RCS Retail';
        acc.Preferred_Payment_type__c = 'Invoice';
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
        con.Contact_Type__c = 'RCS Billing';
        insert con;
        
        acc.Billing_Contact__c = con.Id;
        Update acc;
        
        Contact_Address_Detail__c cad = new Contact_Address_Detail__c();
        cad.Account__c = acc.Id;
        cad.Shipping_Address_1__c = 'P.O Box 690429 123';
        cad.Shipping_Address_2__c = 'Orlando FL 32869-0429 USA';
        cad.Shipping_City__c = 'Orlando';
        cad.Shipping_State__c = 'FL';
        cad.Shipping_Zip__c = '69042';
        cad.Shipping_Country_Code__c = 'US';
        cad.Shipping_Country_Name__c = 'USA';
        cad.Current_Index__c = 0;
        insert cad;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RCS PO').getRecordTypeId();
        //First Case
        Case insertcase = new Case();
        //minimum requirement
        insertcase.Status = 'New';
        insertcase.Origin = 'Phone';
        insertcase.Channel__c = 'RCS Retail';
        
        insertcase.Company_Name__c = 'ABC Infotech';
        insertcase.Customer_First_name__c = 'Corey';
        insertcase.Customer_Last_name__c = 'Burke';
        insertcase.Usage__c = 'BILL TO';
        insertcase.ContactId = con.Id;
        insertcase.Billing_Contact_Phone__c = '9999999999';
        insertcase.Shipping_Contact__c = con.Id;
        insertcase.Shipping_Contact_First_Name__c = 'Corey';
        insertcase.Shipping_Contact_Last_Name__c = 'Burke';
        insertcase.Shipping_Contact_Phone__c = '9999999999';
        insertcase.Shipping_Contact_Email__c = 'corey.burke2@redcross.org';
        insertcase.Shipping_Address_1__c = 'P.O Box 690429';
        insertcase.Shipping_Address_2__c = 'Orlando FL 32869-0429 USA';
        insertcase.Shipping_City__c = 'Orlando';
        insertcase.Shipping_State__c = 'FL';
        insertcase.Shipping_Zip__c = '69042';
        insertcase.Shipping_Country_Name__c = 'USA';
        insertcase.Shipping_Country_Code__c = 'US';
        insertcase.Terms__c = 'NET 30';
        insertcase.External_LOGIN_EMAIL__c = 'corey.burke2@redcross.org';
        insertcase.Invoice_delivery_Email__c = 'corey.burke2@redcross.org';
        insertcase.PO_Number__c = 'po-654';
        insertcase.PO_Amount__c = 2500.00;
        insertcase.PO_Start_Date__c = dateTime.Now();
        insertcase.PO_End_Date__c = dateTime.Now();
        insertcase.IsNewRecord__c = 'Yes';
        insertcase.Created_From_Capo_Form__c  = false;
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
        insertcase.Copy_Billing_to_Shipping__c = false;
        
        insertcase.Status = 'On Hold - Internal';
        
        insert insertcase;
    }
    
    static testMethod void testTriggerOnCase2()
    {  
        //No data in Contact_Address_Detail__c.
        Test.startTest();
        
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
        
        Id AccrecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Bucket Account').getRecordTypeId();
            
        //Bucket Custom settings
        Bucket_Account_Settings__c bas = Bucket_Account_Settings__c.getOrgDefaults();
        bas.Bucket_Account_Owner_ID__c = UserInfo.getUserID();
        bas.Bucket_Account_RecordTypeID__c = AccrecordTypeId;
        bas.Default_Bucket_Name__c = 'Bucket Account';
        bas.Maximum_Size_of_Bucket__c = 5000;
        insert bas;
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Log_In_Email__c = 'corey.burke2@redcross.org';
        acc.PHSS_Channel__c = 'RCS Retail';
        acc.Preferred_Payment_type__c = 'Invoice';
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
        con.Contact_Type__c = 'RCS Billing';
        insert con;
        
        acc.Billing_Contact__c = con.Id;
        Update acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RCS PO').getRecordTypeId();
        //First Case
        Case insertcase = new Case();
        //minimum requirement
        insertcase.Status = 'New';
        insertcase.Origin = 'Phone';
        insertcase.Channel__c = 'RCS Retail';
        
        insertcase.Company_Name__c = 'ABC Infotech';
        insertcase.Customer_First_name__c = 'Corey';
        insertcase.Customer_Last_name__c = 'Burke';
        insertcase.Usage__c = 'BILL TO';
        insertcase.ContactId = con.Id;
        insertcase.Billing_Contact_Phone__c = '9999999999';
        insertcase.Shipping_Contact__c = con.Id;
        insertcase.Shipping_Contact_First_Name__c = 'Corey';
        insertcase.Shipping_Contact_Last_Name__c = 'Burke';
        insertcase.Shipping_Contact_Phone__c = '9999999999';
        insertcase.Shipping_Contact_Email__c = 'corey.burke2@redcross.org';
        insertcase.Shipping_Address_1__c = 'P.O Box 690429';
        insertcase.Shipping_Address_2__c = 'Orlando FL 32869-0429 USA';
        insertcase.Shipping_City__c = 'Orlando';
        insertcase.Shipping_State__c = 'FL';
        insertcase.Shipping_Zip__c = '69042';
        insertcase.Shipping_Country_Name__c = 'USA';
        insertcase.Shipping_Country_Code__c = 'US';
        insertcase.Terms__c = 'NET 30';
        insertcase.External_LOGIN_EMAIL__c = 'corey.burke2@redcross.org';
        insertcase.Invoice_delivery_Email__c = 'corey.burke2@redcross.org';
        insertcase.PO_Number__c = 'po-654';
        insertcase.PO_Amount__c = 2500.00;
        insertcase.PO_Start_Date__c = dateTime.Now();
        insertcase.PO_End_Date__c = dateTime.Now();
        insertcase.IsNewRecord__c = 'Yes';
        insertcase.Created_From_Capo_Form__c  = true;
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
        insertcase.Copy_Billing_to_Shipping__c = false;
        
        insertcase.Status = 'On Hold - Internal';
        
        insert insertcase;
    }
    
    static testMethod void testTriggerOnCase3()
    {  
        //Fill shipping details from Account
        Test.startTest();
        
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
        
        Id AccrecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Bucket Account').getRecordTypeId();
            
        //Bucket Custom settings
        Bucket_Account_Settings__c bas = Bucket_Account_Settings__c.getOrgDefaults();
        bas.Bucket_Account_Owner_ID__c = UserInfo.getUserID();
        bas.Bucket_Account_RecordTypeID__c = AccrecordTypeId;
        bas.Default_Bucket_Name__c = 'Bucket Account';
        bas.Maximum_Size_of_Bucket__c = 5000;
        insert bas;
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Log_In_Email__c = 'corey.burke2@redcross.org';
        acc.PHSS_Channel__c = 'RCS Retail';
        acc.Preferred_Payment_type__c = 'Invoice';
        acc.BillingStreet = 'P.O Box 690429';
        acc.BillingCity = 'Orlando';
        acc.BillingState = 'FL';
        acc.BillingPostalCode = '69042';
        acc.BillingCountry = 'CA';
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
        con.MailingCountry = 'CA';
        con.Contact_Type__c = 'RCS Billing';
        insert con;
        
        acc.Billing_Contact__c = con.Id;
        Update acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RCS PO').getRecordTypeId();
        //First Case
        Case insertcase = new Case();
        //minimum requirement
        insertcase.Status = 'New';
        insertcase.Origin = 'Phone';
        insertcase.Channel__c = 'RCS Retail';
        
        insertcase.Company_Name__c = 'ABC Infotech';
        insertcase.Customer_First_name__c = 'Corey';
        insertcase.Customer_Last_name__c = 'Burke';
        insertcase.Usage__c = 'BILL TO';
        insertcase.ContactId = con.Id;
        insertcase.Billing_Contact_Phone__c = '9999999999';
        insertcase.Terms__c = 'NET 30';
        insertcase.External_LOGIN_EMAIL__c = 'corey.burke2@redcross.org';
        insertcase.Invoice_delivery_Email__c = 'corey.burke2@redcross.org';
        insertcase.PO_Number__c = 'po-654';
        insertcase.PO_Amount__c = 2500.00;
        insertcase.PO_Start_Date__c = dateTime.Now();
        insertcase.PO_End_Date__c = dateTime.Now();
        insertcase.IsNewRecord__c = 'Yes';
        insertcase.Created_From_Capo_Form__c  = true;
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
        insertcase.Copy_Billing_to_Shipping__c = false;
        
        insertcase.Status = 'On Hold - Internal';
        
        insert insertcase;
    }
}