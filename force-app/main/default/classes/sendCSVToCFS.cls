@RestResource(urlMapping='/getRCSPOFile/*')
global with sharing class sendCSVToCFS 
{
    @HttpGet
    global static String generateCSV() 
    {
        List<Case> scope = new List<Case> ();
        try
        {
            String startDate;
            String endDate;
            if (!Test.isRunningTest()) {
                startDate = RestContext.request.params.get('StartDate');
                endDate = RestContext.request.params.get('EndDate');
            } else {
                startDate = String.valueOf(Date.Today().addDays(-1));
                endDate = String.valueOf(Date.Today().addDays(1));
            }
            system.debug('StartDate:::'+startDate);
            system.debug('endDate:::'+endDate);
            String csvColumnHeader;
            List<String> csvRowValues = new List<String>();
            
            integer recordCount = 0;
            
            //to insert events
            List<Event> eventList = new List<Event>();
            
            Set<Id> contactAddressSet = new Set<Id>();
        
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RCS PO').getRecordTypeId();
            system.debug('RecordTypeId:::'+recordTypeId);
            //String query = 'SELECT CaseNumber, Sent_to_CFS__c, Billing_Contact_Email__c, Billing_Contact_Phone__c, Billing_Address_1__c, Billing_Address_2__c, Billing_City__c, Billing_State__c, Billing_Zip__c, Billing_Country_Name__c, Billing_Country_Code__c, Billing_Contact_Last_Name__c, Billing_Contact_First_Name__c,Shipping_Contact_First_Name__c, Shipping_Contact_Last_Name__c,  Terms__c, IsNewRecord__c, Invoice_delivery_Email__c, Company_Name__c, Usage__c, Shipping_Address_1__c, Shipping_Address_2__c, Shipping_State__c, Shipping_City__c, Shipping_Zip__c, Shipping_Country_Name__c, Shipping_Country_Code__c, Customer_First_name__c, Customer_Last_name__c, Shipping_Contact_Phone__c, External_LOGIN_EMAIL__c, PO_Number__c, PO_Amount__c, PO_Start_Date__c, PO_End_Date__c from Case where Id In (\'50055000005uaVH\',\'50055000005uaVM\',\'50055000005uaVR\',\'50055000005uaVW\') And recordTypeId = \''+recordTypeId+'\' And Status = \'PO On-Hold CFS\'';
            String query = 'SELECT Id, Account.Name, Contact_Address_Detail__c, Account.SF_Account_Number__c, CaseNumber, Sent_to_CFS__c, Billing_Contact_Email__c, Billing_Contact_Phone__c, Billing_Address_1__c, Billing_Address_2__c, Billing_City__c, Billing_State__c, Billing_Zip__c, Billing_Country_Name__c, Billing_Country_Code__c, Billing_Contact_Last_Name__c, Billing_Contact_First_Name__c,Shipping_Contact_First_Name__c, Shipping_Contact_Last_Name__c,  Terms__c, IsNewRecord__c, Invoice_delivery_Email__c, Company_Name__c, Usage__c, Shipping_Address_1__c, Shipping_Address_2__c, Shipping_State__c, Shipping_City__c, Shipping_Zip__c, Shipping_Country_Name__c, Shipping_Country_Code__c, Customer_First_name__c, Customer_Last_name__c, Shipping_Contact_Phone__c, External_LOGIN_EMAIL__c, PO_Number__c, PO_Amount__c, PO_Start_Date__c, PO_End_Date__c, Site_Name1__c from Case where recordTypeId = \''+recordTypeId+'\' And Status = \'PO On-Hold CFS\' And Sent_to_CFS__c = false ';
            
            if(String.isBlank(startDate) && String.isBlank(endDate))
            {
                List<CFS_PO_File__c> POFile = new List<CFS_PO_File__c> ();
                POFile = [select Id, Generated_Date_Time__c from CFS_PO_File__c order By Generated_Date_Time__c DESC];
                if(POFile.Size() > 0)
                {
                    DateTime dt = POFile[0].Generated_Date_Time__c;
                    String formattedDate = dt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'','GMT');
                    system.debug('formattedDate:::'+formattedDate);
                    query += 'And LastModifiedDate  >='+ formattedDate +'';
                }
            }
            else if(!String.isBlank(startDate) && String.isBlank(endDate))
            {
                Date SDate = Date.valueOf(startDate);
                DateTime startDateTime = DateTime.newInstance(SDate.Year(), SDate.Month(), SDate.Day());
                String formattedStartDate = startDateTime.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'','GMT');
                query += 'And LastModifiedDate  >='+ formattedStartDate +'';
            }
            else if(!String.isBlank(startDate) && !String.isBlank(endDate))
            {
                Date SDate = Date.valueOf(startDate);
                DateTime startDateTime = DateTime.newInstance(SDate.Year(), SDate.Month(), SDate.Day());
                String formattedStartDate = startDateTime.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'','GMT');
                
                Date EDate = Date.valueOf(endDate);
                DateTime endDateTime = DateTime.newInstance(EDate.Year(), EDate.Month(), EDate.Day());
                String formattedendDate = endDateTime.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'','GMT');
                
                query += 'And LastModifiedDate  >='+ formattedStartDate +' And LastModifiedDate  <='+ formattedendDate +'';
            }
            
            scope = Database.Query(query);
            system.debug('scope:::'+scope);
            system.debug('query:::'+query);
            
            Map<String,List<Case>> accountIdCaseListing = new Map<String,List<Case>>();
            for(Case caserec : scope)
            {
                //to make sent to CFS in Contact Address detalis true
                contactAddressSet.add(caserec.Contact_Address_Detail__c);
                
                //to get Success Records Count
                recordCount++;
                
                if(accountIdCaseListing.containsKey(caserec.Account.SF_Account_Number__c))
                    accountIdCaseListing.get(caserec.Account.SF_Account_Number__c).add(caserec);
                else
                    accountIdCaseListing.put((caserec.Account.SF_Account_Number__c), new List<Case>{caserec});
                
                //Update Sent_to_CFS__c field and Date for each caserec
                caserec.Sent_to_CFS__c = true;
                caserec.Sent_to_CFS_Date__c = system.today();
                
                //Insert Activities(Event)
                Event E = new Event();
                E.Description = 'Case sent to CFS'; 
                E.WhatId = caserec.Id; 
                E.StartDateTime = DateTime.Now();
                E.EndDateTime = DateTime.Now().addminutes(5);
                E.Subject = 'Case sent to CFS';
                eventList.add(E);
                //till here
            }
            
            //creating CSV data contents
            for(String accid : accountIdCaseListing.keySet())
            {
                List<Case> caseListFromMap = new List<Case>();
                caseListFromMap = accountIdCaseListing.get(accid);
                //for billTo
                String billToCustomerRefNumber = caseListFromMap[0].Account.SF_Account_Number__c != null ? caseListFromMap[0].Account.SF_Account_Number__c.toUpperCase() : '';
                String billToCustomerName = caseListFromMap[0].Account.Name != null ? caseListFromMap[0].Account.Name.toUpperCase() : '';
                String billToAlias = caseListFromMap[0].billing_City__c != null ? caseListFromMap[0].billing_City__c.toUpperCase() : '';
                String billToUsage = 'BILL_TO';
                String billToBillToAlias = '';
                String billToAddress1 = caseListFromMap[0].billing_Address_1__c != null ? caseListFromMap[0].billing_Address_1__c.toUpperCase() : '';
                String billToAddress2 = caseListFromMap[0].billing_Address_2__c != null ? caseListFromMap[0].billing_Address_2__c.toUpperCase() : '';
                String billToCity = caseListFromMap[0].billing_City__c != null ? caseListFromMap[0].billing_City__c.toUpperCase() : '';
                String billToState = caseListFromMap[0].billing_State__c != null ? caseListFromMap[0].billing_State__c.toUpperCase() : '';
                String billToZip = caseListFromMap[0].billing_Zip__c != null ? caseListFromMap[0].billing_Zip__c.toUpperCase() : '';
                String billToCountryName = '';
                if(caseListFromMap[0].billing_Country_Name__c == 'USA')
                {
                    billToCountryName = 'UNITED STATES OF AMERICA';
                }
                else
                {
                    billToCountryName = caseListFromMap[0].billing_Country_Name__c != null ? caseListFromMap[0].billing_Country_Name__c.toUpperCase() : '';
                }
                String billToCountryCode = caseListFromMap[0].billing_Country_Code__c != null ? caseListFromMap[0].billing_Country_Code__c.toUpperCase() : '';
                String billToContactFirstName = caseListFromMap[0].billing_Contact_First_Name__c != null ? caseListFromMap[0].billing_Contact_First_Name__c.toUpperCase() : '';
                String billToContactLastName = caseListFromMap[0].billing_Contact_Last_Name__c != null ? caseListFromMap[0].billing_Contact_Last_Name__c.toUpperCase() : '';
                String billToContactPhone = caseListFromMap[0].Billing_Contact_Phone__c != null ? caseListFromMap[0].Billing_Contact_Phone__c.toUpperCase() : '';
                String billToTerms = caseListFromMap[0].Terms__c != null ? caseListFromMap[0].Terms__c.toUpperCase() : '';
                String billToLOGINEMAIL = caseListFromMap[0].External_LOGIN_EMAIL__c != null ? caseListFromMap[0].External_LOGIN_EMAIL__c.toUpperCase() : '';
                String billToInvoiceDeliveryEmail = caseListFromMap[0].Invoice_delivery_Email__c != null ? caseListFromMap[0].Invoice_delivery_Email__c.toUpperCase() : '';
                String billToPONUMBER = '';
                String billToPOAMOUNT = '';
                String billToPOSTARTDATE = '';
                String billToPOENDDATE = '';
                String billToInsert_update = 'I';
                if(caseListFromMap[0].IsNewRecord__c == 'No')
                {
                    billToInsert_update = 'U';
                }
                
                String billTorowStr = '"' + billToCustomerRefNumber + '","' + billToCustomerName + '","' + billToAlias + '","' + billToUsage + '","' + billToBillToAlias + '","' + billToAddress1 + '","' + billToAddress2 + '","' + billToCity + '","' + billToState + '","' + billToZip + '","' + billToCountryName + '","' + billToCountryCode + '","' + billToContactFirstName + '","' + billToContactLastName + '","' + billToContactPhone + '","' + billToTerms + '","' + billToLOGINEMAIL + '","' + billToInvoiceDeliveryEmail + '","' + billToPONUMBER + '","' + billToPOAMOUNT + '","' + billToPOSTARTDATE + '","' + billToPOENDDATE + '","' + billToInsert_update + '"' + ',""' + ',""' + ',""' + ',""' + ',""' + ',""' + ',""' + ',""' + ',""' + ',""';
                csvRowValues.add(billTorowStr);
               
                //for shipTo
                for(Case caserec : caseListFromMap)
                {
                    String shipToCustomerRefNumber = caserec.Account.SF_Account_Number__c != null ? caserec.Account.SF_Account_Number__c.toUpperCase() : '';
                    String shipToCustomerName = caserec.Account.Name != null ? caserec.Account.Name.toUpperCase() : '';
                    String shipToAlias = caserec.Site_Name1__c != null ? caserec.Site_Name1__c.toUpperCase() : '';
                    String shipToUsage = 'SHIP_TO';
                    String shipToBillToAlias = caserec.Billing_City__c != null ? caserec.Billing_City__c.toUpperCase() : '';
                    String shipToAddress1 = caserec.Shipping_Address_1__c != null ? caserec.Shipping_Address_1__c.toUpperCase() : '';
                    String shipToAddress2 = caserec.Shipping_Address_2__c != null ? caserec.Shipping_Address_2__c : '';
                    String shipToCity = caserec.Shipping_City__c != null ? caserec.Shipping_City__c.toUpperCase() : '';
                    String shipToState = caserec.Shipping_State__c != null ? caserec.Shipping_State__c.toUpperCase() : '';
                    String shipToZip = caserec.Shipping_Zip__c != null ? caserec.Shipping_Zip__c.toUpperCase() : '';
                    String shipToCountryName = '';
                    if(caserec.Shipping_Country_Name__c == 'USA')
                    {
                        shipToCountryName = 'UNITED STATES OF AMERICA';
                    }
                    else
                    {
                        shipToCountryName = caserec.Shipping_Country_Name__c != null ? caserec.Shipping_Country_Name__c.toUpperCase() : '';
                    }
                    String shipToCountryCode = caserec.Shipping_Country_Code__c != null ? caserec.Shipping_Country_Code__c.toUpperCase() : '';
                    String shipToContactFirstName = caserec.Shipping_Contact_First_Name__c != null ? caserec.Shipping_Contact_First_Name__c.toUpperCase() : '';
                    String shipToContactLastName = caserec.Shipping_Contact_Last_Name__c != null ? caserec.Shipping_Contact_Last_Name__c.toUpperCase() : '';
                    String shipToContactPhone = caserec.Shipping_Contact_Phone__c != null ? caserec.Shipping_Contact_Phone__c.toUpperCase() : '';
                    String shipToTerms = '';
                    String shipToLOGINEMAIL = '';
                    String shipToInvoiceDeliveryEmail = '';
                    String shipToPONUMBER = caserec.PO_Number__c != null ? caserec.PO_Number__c.toUpperCase() : '';
                    String shipToPOAMOUNT = caserec.PO_Amount__c != null ? String.valueOf(caserec.PO_Amount__c) : '';
                    
                    //for Start Date
                    String startYear = checkLength(String.valueOf(caserec.PO_Start_Date__c.year()));
                    String startMonth = checkLength(String.valueOf(caserec.PO_Start_Date__c.month()));
                    String startDay = checkLength(String.valueOf(caserec.PO_Start_Date__c.day()));
                    
                    String startHour = checkLength(String.valueOf(caserec.PO_Start_Date__c.hour()));
                    String startMinute = checkLength(String.valueOf(caserec.PO_Start_Date__c.minute()));
                    String startSecond = checkLength(String.valueOf(caserec.PO_Start_Date__c.second()));
                    
                    String shipToPOSTARTDATE = startYear + '/' + startMonth + '/' + startDay + ' ' + startHour + ':' + startMinute + ':' + startSecond;
                    
                    //for End Date
                    String endYear = checkLength(String.valueOf(caserec.PO_End_Date__c.year()));
                    String endMonth = checkLength(String.valueOf(caserec.PO_End_Date__c.month()));
                    String endDay = checkLength(String.valueOf(caserec.PO_End_Date__c.day()));
                    
                    String endHour = checkLength(String.valueOf(caserec.PO_End_Date__c.hour()));
                    String endMinute = checkLength(String.valueOf(caserec.PO_End_Date__c.minute()));
                    String endSecond = checkLength(String.valueOf(caserec.PO_End_Date__c.second()));
                    
                    String shipToPOENDDATE = endYear + '/' + endMonth + '/' + endDay + ' ' + endHour + ':' + endMinute + ':' + endSecond;
                    
                    String shipToInsert_update = 'I';
                    if(caserec.IsNewRecord__c == 'No')
                    {
                        shipToInsert_update = 'U';
                    }
                    
                    String shipTorowStr = '"' + shipToCustomerRefNumber + '","' + shipToCustomerName + '","' + shipToAlias + '","' + shipToUsage + '","' + shipToBillToAlias + '","' + shipToAddress1 + '","' + shipToAddress2 + '","' + shipToCity + '","' + shipToState + '","' + shipToZip + '","' + shipToCountryName + '","' + shipToCountryCode + '","' + shipToContactFirstName + '","' + shipToContactLastName + '","' + shipToContactPhone + '","' + shipToTerms + '","' + shipToLOGINEMAIL + '","' + shipToInvoiceDeliveryEmail + '","' + shipToPONUMBER + '","' + shipToPOAMOUNT + '","' + shipToPOSTARTDATE + '","' + shipToPOENDDATE + '","' + shipToInsert_update + '"'+ ',""' + ',""' + ',""' + ',""' + ',""' + ',""' + ',""' + ',""' + ',""' + ',""';
                    csvRowValues.add(shipTorowStr);
                }
            }
            
            //Update contact Address Details
            List<Contact_Address_Detail__c> contactAddressListToUpdate = new List<Contact_Address_Detail__c>();
            contactAddressListToUpdate = [select id, Sent_to_CFS__c from Contact_Address_Detail__c where Sent_to_CFS__c = false And id In : contactAddressSet];
            for(Contact_Address_Detail__c cad : contactAddressListToUpdate)
            {
                cad.Sent_to_CFS__c = true;
            }
            
            if(contactAddressListToUpdate.size() > 0)
                update contactAddressListToUpdate;
            
            //Header contents
            csvColumnHeader = '"Customer reference # from SF","Customer name","Alias","Usage","Bill to for Ship to","Address 1","Address 2","City","State","Zip","Country Name","Country Code","Contact First Name","Contact Last Name","Contact Phone","Terms","LOGIN EMAIL","Invoice delivery Email","PO NUMBER","PO AMOUNT","PO START DATE","PO END DATE","Insert_update","Custom Field 1","Custom Field 2","Custom Field 3","Custom Field 4","Custom Field 5","Custom Field 6","Custom Field 7","Custom Field 8","Custom Field 9","Custom Field 10"\n';
            String csvFileContent = csvColumnHeader + String.join(csvRowValues,'\n');
            system.debug('csvFileContent:::'+csvFileContent);
            Blob csvBlob = Blob.valueOf(csvFileContent);
            
            //Base 64 encoded contents
            String encodedData = EncodingUtil.base64Encode(csvBlob);
            
            Datetime dt = Datetime.NOW();
            String year = checkLength(String.valueOf(dt.year()));
            String month = checkLength(String.valueOf(dt.month()));
            String day = checkLength(String.valueOf(dt.day()));
            
            String hour = checkLength(String.valueOf(dt.hour()));
            String minute = checkLength(String.valueOf(dt.minute()));
            String second = checkLength(String.valueOf(dt.second()));
            String fileName = 'ARCCUSTECOM-'+ year + '-' + month + '-' + day + '-' + hour + '-' + minute + '-' + second + '.csv';
            
            //Json generation
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('fileName',fileName);
            gen.writeStringField('fileContent',encodedData);
            gen.writeEndObject();
            String response = gen.getAsString();
            system.debug('response:::'+response);
            system.debug('encodedData:::'+encodedData);
            
            // to Update list
            if(scope.size() > 0)
                update scope;
            
            //insert eventList
            if(eventList.size() > 0)
                insert eventList;
            
            //Insert CFS PO File
            CFS_PO_File__c CFSPOFile = new CFS_PO_File__c();
            if(!String.isBlank(startDate))
                CFSPOFile.Case_Start_Date__c = Date.ValueOf(startDate);
            if(!String.isBlank(endDate))
                CFSPOFile.Case_End_Date__c = Date.ValueOf(endDate);
            CFSPOFile.File_Name__c = fileName;
            CFSPOFile.File_Status__c = 'SUCCESS';
            CFSPOFile.Generated_Date_Time__c = DateTime.Now();
            CFSPOFile.Requested_By_CFS__c = true;
            insert CFSPOFile;
            
            attachment attach = new Attachment();
            attach.parentId = CFSPOFile.Id;
            attach.name = fileName;
            attach.Body = csvBlob;
            insert attach;
            system.debug('AttachmentId:::'+attach.Id);
            //Till here
            
            //Inserting integration Log
            Integration_Log__c successLog = new Integration_Log__c();
            successLog.Type__c = 'CFS';
            successLog.Error_Records__c = 0;
            successLog.Success_Records__c = recordCount;
            successLog.Is_Error_Occured__c = false;
            insert successLog;
            
            attachment Logattach = new Attachment();
            Logattach.parentId = successLog.Id;
            Logattach.name = fileName;
            Logattach.Body = csvBlob;
            insert Logattach;
            system.debug('Logattach:::'+Logattach.Id);
            //Till here
            
            return response;
        }
        catch(DmlException e) 
        {
            String ReturnError = '{"Error":"'+e.getMessage()+'"}';
            //Setting Error Code
            RestContext.response.statusCode = 500;
            integer recordCount = 0;
            String errorCaseRecords = '';
            //Error Handling
            for(Case caserec : scope)
            {
                recordCount++;
                errorCaseRecords += caserec.CaseNumber + ',';
            }
            errorCaseRecords = errorCaseRecords.removeEnd(',');
            //Till here
            
            //Error Log
            String errorMessage = e.getMessage();
            Integration_Log__c errorLog = new Integration_Log__c();
            errorLog.Error_Message__c = errorMessage;
            errorLog.Type__c = 'CFS';
            errorLog.Error_Records__c = recordCount;
            errorLog.Success_Records__c = 0;
            errorLog.Is_Error_Occured__c = true;
            errorLog.Error_Case_Records__c = errorCaseRecords;
            insert errorLog;
            //Till here
            
            return ReturnError;
        }
    }
    
    global static String checkLength(String val)
    {
        if(String.isNotBlank(val) && val.length() == 1)
        {
            val = '0' + val;
        }
        return val;
    }
}