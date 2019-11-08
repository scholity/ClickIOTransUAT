global class PHSS_GenerateCSVFileBatch implements Database.Batchable<sOBject>, Database.Stateful
{
    //global List<String> csvRowValues;
    //global String csvHeader;
    global List<Fulfillment_Item__c> fulfillmentItemList;
    global List<errorItem> errorItemList;
    global List<Integration_Error_Log__c> integrationErrorLogList;
    global String regExp;   
    global String documentName;
    global Integer sequenceNumber;
    global Integer recordsProcessed;   
    
    global PHSS_GenerateCSVFileBatch()
    { 
        //csvRowValues = new List<String>();
        
        fulfillmentItemList 	= new List<Fulfillment_Item__c>();
        errorItemList 			= new List<errorItem>();
        integrationErrorLogList	= new List<Integration_Error_Log__c>();
        sequenceNumber 			= 2;
        recordsProcessed 		= 0;
        
        // TODO: need to include in regExp soft hyphens and non-breaking space
        regExp = '[¡¢£¤¥¦§¨©ª«¬®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿŒœŠšŸƒ–—‘’‚“”„†‡•…‰€™]';
        
        String csvHeader =  'Transaction Date,' +
                            'Unit Code,' +
                            'FOCIS Category GL,' +
                            'Bill To Org Name,' +
                            'Bill To Org Address,' + 
                            'Bill To Org City,' +
                            'Bill To Org State,' + 
                            'Bill To Org Zip Code,' + 
                            'Bill To Org Country,' + 
                            'Bill To Org User Field3,' +
                            'Bill To Org Primary Phone,' +
                            'Course Num,' + 
                            'Course Name,' + 
                            'End Date,' +
                            'CRS Comments,' + 
                            'Order Num,' +
                            'Terms,' + 
                            'Transaction Amt,' + 
                            'Bill To Org Id,' + 
                            'Bill To Org Address 2,' +
                            'Bill To Org Bill Contact,' + 
                            'Payment Category GL,' +
                            'Customer PO Num,' + 
                            'Full Name Non CRS,' + 
                            'CRS/Offering ID,' + 
                            'Per Person Fee,' + 
                            'Number of Students,' + 
                            'Org Type,' +
                            'Nk Payment Id,' + 
                            'Nk Bill to Org Id,' +
                            'Max Instructor Full Name,' + 
                            'AP Code \n';
        
        // Document name format: ARCINVC_yyyy-mm-dd-hh-mm-ss.csv
        String todayMonth 	= String.valueOf(Date.today().month());
        String todayDay 	= String.valueOf(Date.today().day());
        String todayHour 	= String.valueOf(Datetime.now().hour());
        String todayMin 	= String.valueOf(Datetime.now().minute());
        String todaySec 	= String.valueOf(Datetime.now().second());
        
        if(todayMonth.length()<2)
        {
            todayMonth = '0'+ todayMonth;
        }
        
        if(todayDay.length()<2)
        {
            todayDay = '0'+ todayDay;
        }
        if(todayHour.length()<2)
        {
            todayHour = '0'+ todayHour;
        }
        if(todayMin.length()<2)
        {
            todayMin = '0'+ todayMin;
        }
        if(todaySec.length()<2)
        {
            todaySec = '0'+ todaySec;
        }
        
        documentName = 'ARCINVC_'+String.valueOf(Date.today().year())+'-'+todayMonth+'-'+todayDay+'-'+todayHour+'-'+todayMin+'-'+todaySec+'.csv';
        
        // Insert Header record
        try
        {   
            insert(new Integration_Files__c(File_Name__c		= documentName,
                                            Record_Data__c		= csvHeader,
                                            Sequence_Number__c	= 1,
                                            Target_System__c	= 'CFS'));
        }
        catch (exception e)
        {
          
        }        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT Name,Transaction_Date__c,' +
                              'Order_Item__r.Unit_Code__c,' +
                              'Order__r.FOCIS_Category__c,' +
                              'Order__r.ccrz__Account__r.Name,' +
                              'Order__r.ccrz__Account__r.BillingStreet,' +
                              'Order__r.ccrz__Account__r.BillingCity,' +
                              'Order__r.ccrz__Account__r.BillingState,' +
                              'Order__r.ccrz__Account__r.BillingPostalCode,' +
                              'Order__r.ccrz__Account__r.BillingCountry,' +
                              'Order__r.ccrz__Account__r.Special_Invoicing__c,' +
                              'Order__r.ccrz__Account__r.Billing_Contact_phone__c,' +
                              'CC_Product__r.ccrz__SKU__c,' +
                              'CC_Product__r.Name,CC_Product__r.ccrz__InventoryType__c,CC_Product__r.ccrz__ProductType__c,' +
                              'ILT_Class__r.redwing__End_Date__c,' +
                              'Supplemental_Information__c,' +
                              'Order__r.Name,' +
                              'Order__r.ccrz__Account__r.Payment_Terms__c,' +
                              'Fulfillment_Item_Total__c,' +
                              'Order__r.ccrz__Account__r.SABA_LMS_Code__c,' +
                              'Order__r.ccrz__Account__r.Billing_Contact__c,Order__r.ccrz__Account__r.Billing_Contact__r.FirstName,Order__r.ccrz__Account__r.Billing_Contact__r.LastName,' +
                              'Order_Item__r.Payment_Category__c,' +
                              'Order__r.ccrz__PONumber__c,' +
                              'Fulfillment_Date__c,' +
                              'Order_Item__r.Name,' +
                              // FUTURE - Full Name
                              'Fulfillment__r.Name,ILT_Class__r.Offering_ID__c,' +
                              'Order_Item__r.ccrz__Price__c,' +
            				  'Order_Item__r.Class_Setting__c,' +
                              'Quantity__c,Order__r.ccrz__Account__r.SABA_Org_Type__c,' +
                              // FUTURE/TBD - Org Type
                              'Id,' +
            				  'Order__r.Id,' +
                              'Order__r.ccrz__Account__r.SABA_Name__c,Order__r.ccrz__Account__r.Id,' +
                              'Order__r.ccrz__Account__r.nk_billto_org_id__c,' +
                              'ILT_Class__c,' +
            				  'AP_Code__c,' +
            				  'CC_Category_Name__c,' +
                              'CC_Product__r.AP_Code__c ' +
                        'FROM Fulfillment_Item__c WHERE Status__c=\'Ready\' AND Fulfillment__r.Type__c!=\'Receipt\' AND Fulfillment__r.Payment_Method__c =\'po\'';
        
        system.debug('Query: '+query);
        
        return Database.getQueryLocator(query);
    }
 
    global void execute(Database.BatchableContext BC, List<Fulfillment_Item__c> scope)
    {
        // QUERY INSTRUCTORS FOR ALL ILT CLASSES
        Set<Id> iltClassIds = new Set<Id>();
        Map<Id,redwing__ILT_Instructor__c> iltCIMap = new Map<Id,redwing__ILT_Instructor__c>();
        
        for(Fulfillment_Item__c fi: scope)
        {
            if(fi.ILT_Class__c!=null)
            {
                iltClassIds.add(fi.ILT_Class__c);
            }
        }
        
        List<redwing__ILT_Instructor__c > instructors = new List<redwing__ILT_Instructor__c >();
        if(!iltClassIds.isEmpty())
        {
            instructors = new List<redwing__ILT_Instructor__c >([SELECT Id,
                                                                 		redwing__ILT_Class__c,
                                                                 		redwing__Primary__c,
                                                                 		redwing__Instructor__r.FirstName,
                                                                 		redwing__Instructor__r.LastName 
                                                                   FROM redwing__ILT_Instructor__c 
                                                                  WHERE redwing__ILT_Class__c IN:iltClassIds]);
        }
        
        for(redwing__ILT_Instructor__c i: instructors)
        {
            if(iltCIMap.containsKey(i.redwing__ILT_Class__c))
            {               
                if(iltCIMap.get(i.redwing__ILT_Class__c).redwing__Primary__c)
                {
                    iltCIMap.put(i.redwing__ILT_Class__c, i);
                }
            }
            else
            {
                iltCIMap.put(i.redwing__ILT_Class__c, i);
            }
        }
        
        // CREATE ROW FOR EACH FULFILLMENT ITEM
        List<Integration_Files__c> integrationFiles = new List<Integration_Files__c>();
        Boolean isError;
        String errString;
        for(Fulfillment_Item__c fi: scope)
        {
            isError 				= false;
            errString 				= '';
            Datetime dt 			= fi.Transaction_Date__c;		// Transaction Date - Format 2017/03/21 00:00:00
            String transactionDate 	= '""';
            
            if(dt!=null)
            {
                String day 		= String.valueOf(dt.day());
                String month 	= String.valueOf(dt.month());
                if(day.length()<2)
                {
                    day='0'+day;
                }
                if(month.length()<2)
                {
                    month='0'+month;
                }
                transactionDate = '"' + dt.year()+'/'+month+'/'+day+' 00:00:00' + '"'; // DE1883 
                //transactionDate = dt.year()+'/'+month+'/'+day; // DE1824
            }
            
            // Unit Code
            String unitCode = '""';
            if(fi.Order_Item__r.Unit_Code__c!=null)
            {
                unitCode = '"' + fi.Order_Item__r.Unit_Code__c + '"';
            }
            
            // FOCIS Category GL
            String focis = '""';
            if(fi.Order__r.FOCIS_Category__c!=null && fi.CC_Product__r.AP_Code__c != '6243' && fi.CC_Product__r.AP_Code__c != '6244')
            {
                focis='"' + fi.Order__r.FOCIS_Category__c + '"';
            }
            else if (fi.CC_Product__r.AP_Code__c == '6243' || fi.CC_Product__r.AP_Code__c == '6244')
            {
                focis='"' + '41' + '"';
            }
            else
            {
                isError = true;
                if(errString!='') {errString=errString+';';}
                errString = errString + 'Order-FOCIS Category';
            }
            
            // Bill To Org Name - No more than 60 characters, check for special characters
            String accountName = '""';
            if(fi.Order__r.ccrz__Account__r.Name!=null)
            {
                accountName = fi.Order__r.ccrz__Account__r.Name;
                accountName = accountName.replaceAll(regExp, '');
                if(accountName.length()>60)
                {
                    accountName = accountName.left(60);
                }
                accountName = '"' + accountName + '"';
            }
            
            // Bill To Org Address - No more than 40 characters, check for special characters
            // Bill To Org Address 2 - No more than 40 characters, check for special characters
            
            String billingStreet = fi.Order__r.ccrz__Account__r.BillingStreet;
            String street1 		 = '""';
            String street2 		 = ''; 
            
            if(billingStreet!=null)
            {
                List<String> stringList = new List<String>();
                
                stringList				= String.valueOf(billingStreet).split('\n');
                system.debug('Billing Street String List: ' + stringList); 
                String street 			= stringList[0].replaceAll(regExp, '');
                street1 				= street.trim();
                if(stringList.size()==1)
                {
                    if(!String.isEmpty(street) && street.length()>40)
                    {
                        street1 = street.left(40);
                        if(street.length()>80)
                        {
                            street2 = street.substring(40, 80);
                        }
                        else
                        {
                            street2 = street.substring(40);
                        }                        
                    }                   
                }
                else if(stringList.size()>1)
                {
                    if(!String.isEmpty(street) && street.length()>41)
                    {
                        street1 = street.left(40);
                    }
                    if(!String.isEmpty(stringList[1]))
                    {
                        street2 = stringList[1].replaceAll(regExp, '');
                        if(street2.length()>40)
                        {
                            street2 = stringList[1].left(40);
                        }
                    }
                } 
                
                street1 = '"' + street1 + '"';
                
                if(street2!='')
                {
                    street2='"'+street2+'"'.trim();
                }
                else
                {
                    street2 = '""';
                }
                
            }
            else
            {
                isError = true;
                if(errString!='') {errString=errString+';';}
                errString = errString + 'Order-Account-Billing Street';
            }
            
            // Bill To Org City - No more than 30 characters, check for special characters
            String city = '""';
            
            if(fi.Order__r.ccrz__Account__r.BillingCity!=null)
            {
                city 	= fi.Order__r.ccrz__Account__r.BillingCity.replaceAll(regExp, '');
                
                if(city.length()>30)
                {
                    city=city.left(30);
                }
                
                city = '"' + city + '"';
            }
            else
            {
                isError 	= true;
                
                if(errString!='')
                {
                    errString=errString+';';
                }
                
                errString = errString + 'Order-Account-Billing City';
            }
            
            // TODO: Update to picklist fields when enabled 
            // Bill To Org State - No more than 2 characters
            String state = '""';
            if(fi.Order__r.ccrz__Account__r.BillingState!=null)
            {
                state = fi.Order__r.ccrz__Account__r.BillingState.replaceAll(regExp, '');
                
                if(state.length()>2)
                {
                    isError 	= true;
                    if(errString!='')
                    {
                        errString=errString+';';
                    }
                    errString 	= errString + 'Order-Account-Billing State';
                }
                else
                {
                    state = '"' + state + '"';
                } 
            }
            else
            {
                isError 	= true;
                
                if(errString!='')
                {
                    errString = errString+';';
                }
                errString = errString + 'Order-Account-Billing State';
            }
            
            // Bill To Org Zip Code - No more than 10 characters
            String postalCode = '""';
            if(fi.Order__r.ccrz__Account__r.BillingPostalCode!=null)
            {
                postalCode = fi.Order__r.ccrz__Account__r.BillingPostalCode;
                
                if(postalCode.length()>10)
                {
                    postalCode=postalCode.left(10);
                }
                
                postalCode = '"' + postalCode + '"';
            }
            else
            {
                isError = true;
                
                if(errString!='')
                {
                    errString=errString+';';
                }
                
                errString = errString + 'Order-Account-Billing Postal Code';
            }
            // TODO: Update to picklist fields when enabled 
            // Bill To Org Country - No more than 2 characters
            String country = '""';
            if(fi.Order__r.ccrz__Account__r.BillingCountry!=null)
            {
                country = fi.Order__r.ccrz__Account__r.BillingCountry.replaceAll(regExp, '');
                if(country.length()>2 || String.isBlank(country))
                {
                    isError = true;
                    if(errString!='') {errString=errString+';';}
                    errString = errString + 'Order-Account-Billing Country';
                }
                else
                {
                    country = '"' + country + '"';
                }
            }
            else
            {
                isError = true;
                
                if(errString != '')
                {
                    errString=errString+';';
                }
                
                errString = errString + 'Order-Account-Billing Country';
            }
            // Bill To Org User Field3
            String sInvoicing = '""';
            
            if(!String.isEmpty(fi.Order__r.ccrz__Account__r.Special_Invoicing__c))
            {
                sInvoicing = '"' + fi.Order__r.ccrz__Account__r.Special_Invoicing__c + '"';
            }
            
            // Bill To Org Primary Phone
            String phone = '""';
            
            if(fi.Order__r.ccrz__Account__r.Billing_Contact_phone__c!=null)
            {
                phone = '"' + fi.Order__r.ccrz__Account__r.Billing_Contact_phone__c + '"';
            }
            else
            {
                isError 	= true;
                if(errString!='')
                {
                    errString=errString+';';
                }
                errString 	= errString + 'Bill To Org Primary Phone';
            }
            // Course Num - No more than 40 characters
            String courseNum = '""';
            if(fi.CC_Product__r.ccrz__SKU__c!=null)
            {
                courseNum 	= fi.CC_Product__r.ccrz__SKU__c;
                if(courseNum.length()>40)
                {
                    courseNum=courseNum.left(40);
                }
                courseNum   = '"' + courseNum + '"';
            }
            else
            {
                isError = true;
                if(errString!='')
                {
                    errString=errString+';';
                }
                errString = errString + 'CC Product-SKU';
            }
            // Course Name, check for special characters
            String courseName = '""';
            if(fi.CC_Product__r.Name!=null)
            {
                courseName = '"' + fi.CC_Product__r.Name.replaceAll(regExp, '') + '"';
            } 
            
            // End Date - Format 2017/03/21 00:00:00
            
            Date eDate = date.today();//fi.ILT_Class__r.redwing__End_Date__c;
            
            system.debug('***eDate***'+eDate);
            
            if(fi.ILT_Class__r.redwing__End_Date__c != null)
            {
                eDate = fi.ILT_Class__r.redwing__End_Date__c;
                system.debug('***eDate1***'+eDate);
            }
            else if(fi.Fulfillment_Date__c != null)
            {
                eDate = fi.Fulfillment_Date__c;
                system.debug('***eDate2***'+eDate);
            }
            /*if(eDate == null){
                eDate = fi.Fulfillment_Date__c;
            }*/
            
            system.debug('***eDate3***'+eDate);
            
            String endDate = '""';
            
            if(eDate!=null)
            {
                system.debug('***eDate4***'+eDate);
                String day 		= String.valueOf(eDate.day());
                String month 	= String.valueOf(eDate.month());
                
                if(day.length()<2)
                {
                    day='0'+day;
                }
                
                if(month.length()<2)
                {
                    month='0'+month;
                }
                
                endDate = '"' + dt.year()+'/'+month+'/'+day+' 00:00:00' + '"';
            } 
            // CRS Comments - No more than 50 characters, check for special characters
            String crsComments = '""';
            
            if(fi.Supplemental_Information__c!=null && fi.CC_Category_Name__c != 'NAT Training' && fi.CC_Category_Name__c != 'NAT Testing')
            {
                system.debug('***Inside CRS Commnets***');
                
                crsComments 	= fi.Supplemental_Information__c.replaceAll(regExp, '');
                
                if(crsComments.length()>50)
                {
                    crsComments=crsComments.left(50);
                }
                
                crsComments = '"' + crsComments + '"';
            }
            // Order Num
            String orderNum = '""';
            
            //US1581 - change the Order Number to the CC Order.Name
            if(fi.Order__r.Name!=null)
            {
                orderNum = '"' + fi.Order__r.Name.replaceAll(regExp, '') + '"';
            }
            
            // Terms
            String terms = '""';
            if(!String.isEmpty(fi.Order__r.ccrz__Account__r.Payment_Terms__c))
            {
                terms = '"' + fi.Order__r.ccrz__Account__r.Payment_Terms__c + '"';
            }
            else
            {
                isError 	= true;
                if(errString!='')
                {
                    errString=errString+';';
                }
                errString = errString + 'Order-Account-Payment Terms';
            }
            
            // Transaction Amt  
            Decimal amt 		  = fi.Fulfillment_Item_Total__c;          
            String transactionAmt = String.valueOf(amt);
            
            if(amt.scale()==1)
            {
                transactionAmt=transactionAmt+'0';
            }
            
            transactionAmt = '"' + transactionAmt + '"';
            
            // Bill To Org Id - No more than 60 characters
            String billToOrgId = '""';
            if(fi.Order__r.ccrz__Account__r.SABA_LMS_Code__c!=null)
            { 
                billToOrgId	= fi.Order__r.ccrz__Account__r.SABA_LMS_Code__c;
                
                if(billToOrgId.length()>60)
                {
                    billToOrgId=billToOrgId.left(60);
                }
                
                billToOrgId = '"' + billToOrgId + '"'; 
            }
            
            // Bill To Org Bill Contact, check for special characters
            String contactFirstName = fi.Order__r.ccrz__Account__r.Billing_Contact__r.FirstName;
            String contactLastName 	= fi.Order__r.ccrz__Account__r.Billing_Contact__r.LastName;
            String contactName 		= '""';
            
            if(fi.Order__r.ccrz__Account__r.Billing_Contact__c!=null)
            {
                if(contactFirstName!=null && contactLastName!=null)
                { 
                    contactName = '"' + contactFirstName.replaceAll(regExp, '') + ' ' + contactLastName.replaceAll(regExp, '') + '"'; 
                }
                else if(contactFirstName==null)
                {
                    contactName = '"' + contactLastName.replaceAll(regExp, '') + '"';
                }
            }
            else
            {
                isError = true;
                if(errString!='') {errString=errString+';';}
                errString = errString + 'Order-Account-Billing Contact';
            }
            // Payment Category GL
            String paymentCategoryGL = '""';
            if(fi.Order_Item__r.Payment_Category__c!=null)
            {
                paymentCategoryGL = '"' + fi.Order_Item__r.Payment_Category__c + '"';
            }
            else
            {
                isError = true;
                if(errString!='') {errString=errString+';';}
                errString = errString + 'Order Item-Payment Category';
            } 
            
            // Customer PO Num, check for special characters
            String po = '""';
            
            if(fi.Order__r.ccrz__PONumber__c!=null)
            {
                po = '"' + fi.Order__r.ccrz__PONumber__c.replaceAll(regExp, '') + '"';
            }
            
            // CRS/Offering ID
            String offeringId;
            
            if((fi.CC_Product__r.ccrz__InventoryType__c == 'COURSE' ||
                fi.CC_Product__r.ccrz__InventoryType__c == 'COMMUNITY') &&
               fi.Order_Item__r.Class_Setting__c != 'Online')
            {
                offeringId = fi.ILT_Class__r.Offering_ID__c;
                if(String.isBlank(offeringId))
                {
                    isError = true;
                    if(errString!='') {errString=errString+';';}
                    errString = errString + 'ILT Class - offeringId';
                }
            }
            else if(fi.CC_Product__r.ccrz__InventoryType__c == 'FEE' && String.isNotBlank(fi.ILT_Class__r.Offering_ID__c))
            {
                offeringId = '"' + fi.ILT_Class__r.Offering_ID__c + '"';
            }
            else
            {
                    offeringId = '"' + fi.Order_Item__r.Name + '"';
            }
            
            // Per Person Fee
            Decimal ppFee 		= fi.Order_Item__r.ccrz__Price__c;  
            String perPersonFee = '""';
            
            if(ppFee!=null)
            {
                perPersonFee = String.valueOf(ppFee);
                if(ppFee.scale()==1)
                {
                    perPersonFee=perPersonFee+'0';
                }
                perPersonFee = '"' + perPersonFee + '"'; 
            }
            else
            {
                isError = true;
                if(errString!='') {errString=errString+';';}
                errString = errString + 'Order Item-Price';
            }  
            // Number of Students
            Decimal quantity 	= fi.Quantity__c;    
            String numStudents 	= '"0"';
            
            if(quantity!=null)
            {
                numStudents = '"' + String.valueOf(quantity.intValue()) + '"';
            }
            
            // Org Type
            String orgType = '""';
            if(!String.isEmpty(fi.Order__r.ccrz__Account__r.SABA_Org_Type__c))
            {
                orgType='"'+fi.Order__r.ccrz__Account__r.SABA_Org_Type__c+'"';
            }
            
            // Nk Payment Id
            String paymentId = '"' + fi.Id + '"';
            // DE1194 Return SABA name instead of Id
            // DE1568 return account id if saba name/NK Org is null
            String sabaName = '""';
            /*
             * DE1671 - replaced SABA_Name__c with nk_billto_org_id__c
            if (!String.isEmpty(fi.Order__r.ccrz__Account__r.SABA_Name__c)) {
                sabaName = '"' + fi.Order__r.ccrz__Account__r.SABA_Name__c + '"';*/
                
            if (!String.isEmpty(fi.Order__r.ccrz__Account__r.nk_billto_org_id__c))
            {
                sabaName = '"' + fi.Order__r.ccrz__Account__r.nk_billto_org_id__c + '"';
            }
            else
            {
                sabaName = '"' + fi.Order__r.ccrz__Account__r.Id + '"';
            }

            // AP Code
            String apCode = '""';
            if(!String.isEmpty(fi.AP_Code__c))
            {
                //apCode='"'+fi.CC_Product__r.AP_Code__c+'"';
                //DE1301
                apCode='"'+fi.AP_Code__c+'"';
            }
            
            String fullName = '""';
            // Max Instructor Full Name
            String instructorName = '""';
            // DE1194 For the following conditions, supply the student name (should be only one)
            if (('"6243"'.equals(apCode) || '"6244"'.equals(apCode)) && '"41"'.equals(focis))
            {
                List<redwing__ILT_Roster__c > rosters = new List<redwing__ILT_Roster__c >();

                List<String> inventoryTypes = new List<String>{'COMMUNITY', 'COURSE'};
                if ((fi.ILT_Class__c == null && fi.CC_Product__r.ccrz__InventoryType__c == 'FEE')
                        || (fi.ILT_Class__c != null && inventoryTypes.contains(fi.CC_Product__r.ccrz__InventoryType__c)))
                {
                    //DE1854
                    if(fi.CC_Category_Name__c == 'NAT Training' || fi.CC_Category_Name__c == 'NAT Testing')
                    {
                        if(String.isNotBlank(fi.Supplemental_Information__c))
                        {
                            instructorName 	= '"' + fi.Supplemental_Information__c.replaceAll(regExp, '') + '"';
                            fullName	 	= instructorName;
                        }
                        else
                        {
                            isError = true;
                            
                            if(errString!='')
                            {
                                errString=errString+';';
                            }
                            errString = errString + 'NAT Student Name';
                        }
                    }
                    else
                    {
                        // DE1932
                        if (fi.ILT_Class__c != null) {
                            instructorName = getNameOfInstructor(iltCIMap.get(fi.ILT_Class__c));
                            fullName = instructorName;
                        }

                        /*  // removed per DE1932

                    	rosters = new List<redwing__ILT_Roster__c>([SELECT redwing__User__r.Name
                    											  FROM redwing__ILT_Roster__c
                    											 WHERE redwing__ILT_Class__c =:fi.ILT_Class__c]);
                        if (rosters.size()> 0)
                        {
                            instructorName = '"' + rosters[0].redwing__User__r.Name.replaceAll(regExp, '') + '"';
                            fullName 	   = instructorName;
                        }
                        else
                        {
                            isError = true;
                            if(errString!='')
                            {
                                errString=errString+';';
                            }
                            errString = errString + 'ILT Class-Roster User Name';
                        }

                         */
                    }
                }
            }
            //DE1854 
            else if(fi.CC_Category_Name__c == 'NAT Training' || fi.CC_Category_Name__c == 'NAT Testing')
            {
                if(String.isNotBlank(fi.Supplemental_Information__c))
                {
                    instructorName 	= '"' + fi.Supplemental_Information__c.replaceAll(regExp, '') + '"';
                    fullName		= instructorName;
                }
                else
                {
                    isError = true;
                    
                    if(errString!='')
                    {
                        errString=errString+';';
                    }
                    errString = errString + 'NAT Student Name';
                }
                
            }
            else if (fi.ILT_Class__c!=null && iltCIMap.containsKey(fi.ILT_Class__c) && iltCIMap.get(fi.ILT_Class__c).redwing__Instructor__c!=null)
            {
                instructorName = getNameOfInstructor(iltCIMap.get(fi.ILT_Class__c));
            }
            if ('COURSE'.equals(fi.CC_Product__r.ccrz__InventoryType__c) && 'KIT'.equals(fi.CC_Product__r.ccrz__ProductType__c))
            {
                List<ccrz__E_Product__c > products = new List<ccrz__E_Product__c>();
                if (fi.CC_Product__r.AP_Code__c != null)
                {
                    products = new List<ccrz__E_Product__c>([SELECT AP_Code__c
                        									   FROM ccrz__E_Product__c
                                                              WHERE ccrz__ParentProduct__c =:fi.CC_Product__r.Id]);
                    for (ccrz__E_Product__c product : products)
                    {
                        product.AP_Code__c = fi.CC_Product__r.AP_Code__c;
                    }
                    update products;
                }
            }
            String transactionString =  transactionDate+','+unitCode+','+focis+','+accountName+','+street1+','+
                                        city+','+state+','+postalCode+','+country+','+sInvoicing+','+
                                        phone+','+courseNum+','+courseName+','+endDate+','+crsComments+','+
                                        orderNum+','+terms+','+transactionAmt+','+billToOrgId+','+street2+','+
                                        contactName+','+paymentCategoryGL+','+po+','+fullName+','+offeringId+','+
                                        perPersonFee+','+numStudents+','+orgType+','+paymentId+','+sabaName+','+
                                        instructorName+','+apCode;
            recordsProcessed = recordsProcessed + 1;
            // Add Row
            System.debug('Row: '+transactionString);
            if(isError) { 
                errorItem err = new errorItem();
                
                err.fiId 		 = fi.Id;
                err.fiName 		 = fi.Name;
                err.fiAmount 	 = fi.Fulfillment_Item_Total__c;
                err.errorDetails = errString;
                
                errorItemList.add(err);
                
                
                Integration_Error_Log__c iErrorLog = new Integration_Error_Log__c ();
                
                iErrorLog.Fulfillment_Item__c 	= fi.Id;
                iErrorLog.Account__c 			= fi.Order__r.ccrz__Account__r.Id;
                iErrorLog.Order__c 				= fi.Order__r.Id;
                iErrorLog.Error_Details__c		= errString;
                iErrorLog.Source__c				= 'CFS';
                iErrorLog.Status__c				= 'Open';
                
                integrationErrorLogList.add(iErrorLog);
                //errorItemList.add(new errorItem(fi.Id,fi.Name,fi.Fulfillment_Item_Total__c,errorDetails));
            }
            else
            {
                //csvRowValues.add(transactionString);
                if(!String.isBlank(transactionString))
                {
                    integrationFiles.add(new Integration_Files__c(File_Name__c=documentName, Record_Data__c=transactionString, Sequence_Number__c=sequenceNumber, Target_System__c='CFS'));
                    fulfillmentItemList.add(fi);
                    sequenceNumber++;
                }
            }  
        }
        try
        {
            for(Fulfillment_Item__c fi: fulfillmentItemList)
            {
                //DE1792/DE1809
                //fi.Status__c='Complete';
                fi.Status__c		= 'Invoiced';
                fi.CFS_File_Name__c	= documentName;
                fi.Invoiced_Date__c = System.today();
            }
            if(!integrationFiles.isEmpty() && !fulfillmentItemList.isEmpty())
            {
                insert integrationFiles;
                update fulfillmentItemList;
            }
        }
        catch (exception e)
        {
          
        }         
    }

    global String getNameOfInstructor(redwing__ILT_Instructor__c trainingInstructor) {
        String firstName;
        String lastName;

        if (trainingInstructor != null) {
            firstName = trainingInstructor.redwing__Instructor__r.FirstName;
            lastName = trainingInstructor.redwing__Instructor__r.LastName;
        }

        firstName = firstName == null ? '' : firstName.replaceAll(regExp, '');
        lastName = lastName == null ? '' : lastName.replaceAll(regExp, '');
        return '"' + (firstName + ' ' + lastName).trim() + '"';
    }
    
    global void finish(Database.BatchableContext BC)
    {
        System.debug(recordsProcessed + ' records processed.');
        
/*        AsyncApexJob job = [SELECT Id,Status,NumberOfErrors,JobItemsProcessed,TotalJobItems,CreatedBy.Email
                            FROM AsyncApexJob 
                            WHERE Id = :bc.getJobId()];
        
        // SAVE FILE TO FOLDER   
        // Create CSV file
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.VersionData = Blob.valueOf(csvHeader + String.join(csvRowValues,'\n'));
        cv.Title = documentName;
        cv.PathOnClient = documentName;
        insert cv; 
        // Get the content document Id from ContentVersion and Folder/Library Ids
        List<ContentDocument> cds = new List<ContentDocument>([SELECT Id FROM ContentDocument WHERE Title=:documentName]);
        List<ContentFolder> folders = new List<ContentFolder>([SELECT Id, Name, ParentContentFolderId FROM ContentFolder WHERE Name = 'CFS Daily Files']);
        List<ContentWorkspace> cws = new List<ContentWorkspace>([SELECT Id, Name FROM ContentWorkspace WHERE Name = 'PHSS Integrations']);
        if(!folders.isEmpty() && !cds.isEmpty() && !cws.isEmpty()) {
            // Create ContentDocumentLink and link to Library
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = cds[0].Id;
            cdl.LinkedEntityId = cws[0].Id; 
            cdl.ShareType = 'I';
            cdl.Visibility = 'AllUsers';
            insert cdl; 
            // Update to place file under the correct integrations folder
            List<ContentFolderMember> cfmList = new List<ContentFolderMember>([SELECT Id, ParentContentFolderId FROM ContentFolderMember WHERE ChildRecordId =:cds[0].Id LIMIT 1]);
            if(!cfmList.isEmpty()) {
                cfmList[0].ParentContentFolderId=folders[0].Id;
                update cfmList[0];
            }            
        }        
*/
        // TODO: Send an email to the User after your batch completes
        if(!errorItemList.isEmpty())
        {
            String csvFileString = 'Fulfillment Item Id,Fulfillment Item Name,Fulfillment Item Total,Error Details \n';
            for(errorItem e: errorItemList)
            {
                system.debug(e);
                csvFileString = csvFileString + e.fiId + ',' + e.fiName + ',' + e.fiAmount + ',' + e.errorDetails + '\n';
            }
            
            system.debug('***integrationErrorLogList***'+integrationErrorLogList);
            
            //DE1900
            map<Id,Id> fiMap = new map<Id,Id>();
            
            List<Integration_Error_Log__c> existingErrorLogList = [SELECT Id,
																		  Fulfillment_Item__c
                                                                     FROM Integration_Error_Log__c
                                                                    WHERE Status__c = 'Open'];
            
            for(Integration_Error_Log__c iel : existingErrorLogList)
            {
                fiMap.put(iel.Fulfillment_Item__c, iel.Id);
            }
            
            if(integrationErrorLogList.size() > 0)
            {
                if(existingErrorLogList.size() > 0)
                {
                    system.debug('***existingErrorLogList***'+existingErrorLogList);
                    for(Integration_Error_Log__c e : integrationErrorLogList)
                    {
                        system.debug('***Inside Error Log Loop***');
                        e.Parent_Integration_Error_Log__c = fiMap.get(e.Fulfillment_Item__c );
                    }
                }
                insert integrationErrorLogList;
            }
            
            String body = 'The batch job PHSS_GenerateCSVFileBatch has finished. \n' +
                          'Attached you will find a list of Fulfillment Item Ids that need data verified.';
            String subject = 'Apex Batch Result for PHSS_GenerateCSVFileBatch - Fulfillment Items Not Processed';
            // Create email attachment    
            Messaging.EmailFileAttachment[] emailAttList = new List<Messaging.EmailFileAttachment>();
            Messaging.EmailFileAttachment att = new Messaging.EmailFileAttachment();
            att.setFileName('Fulfillment Items to verify.csv');
            att.setBody(Blob.valueOf(csvFileString));
            emailAttList.add(att);
            // Create email
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject( subject );
            //email.setToAddresses( new String[] {'snehra@salesforce.com'} );
            email.setToAddresses( new String[] {'reportscoa@redcross.org'} );
            //email.setToAddresses( new String[] {'jatinkumar.acharya@redcross.org'} );
            email.setPlainTextBody( body );
            email.setFileAttachments(emailAttList);
            if (!Test.isRunningTest())
            {
                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
            }
        }
    }
    global class errorItem
    {
        public Id fiId {get; set;}
        public String fiName {get; set;}
        public Decimal fiAmount {get; set;}
        public String errorDetails {get; set;}
        public errorItem() {}
    }
}