/*****************************************************************************************************
 
Class    :  cls_Channel_Compensation_Test
Developer:  Kiril Minev
Created  :  July 29, 2014
Modified :  
Objective:  
 
*****************************************************************************************************/ 
@isTest
private class cls_Channel_Compensation_Test {

    static testMethod void myUnitTest() {
        
        String strOrgId = 'ORG-ID-123';
        String strOrgType = 'LTP';
        Date strBatchId1 = Date.today();
        String strSalesModule2 = 'Sales Module123';
        String strTerritoryCode3 = 'CODE12';
        String strState4 = 'AB';        
        String strFiscalMonthAbr5 = 'ABC';
        String strFiscalYear6 = 'YYYY';
        String strFocisCategory7 = 'CAT123';
        String strFocisSubjectArea8 = 'SBJ123';
        String strFocisSubjectArea9 = 'SBJ124';
        String strFocisSubjectArea10 = 'SBJ125';
        String strPostal11 = '99999';
        
        Territory__c territoryA = new Territory__c(Name = strTerritoryCode3, Territory_Name__c = 'Test');
        insert territoryA;
        
        Geo_Location__c geoLocation = new Geo_Location__c(State_Abbreviation__c=strState4,Coordinates__latitude__s=1.1,Coordinates__longitude__s=1.1, State__c=strState4,Postal_Code__c=strPostal11,Country_Code__c='US',City__c='San Francisco',Land_Territory__c=strTerritoryCode3,AQ_Territory__c=strTerritoryCode3);
        insert geoLocation;
        
        Channel_Compensation__c c1 = new Channel_Compensation__c(Org_Id__c = strOrgId, Org_Type__c = strOrgType, BATCH_Id__c = strBatchId1, Sales_Module__c = strSalesModule2, Territory_Code__c = strTerritoryCode3,
                              State__c = strState4, Fiscal_Month_Abbr__c = strFiscalMonthAbr5, Fiscal_Year__c = strFiscalYear6, FOCIS_Category__c = strFocisCategory7,
                              FOCIS_Subject_Area__c = strFocisSubjectArea8, Focis_Location__c = strFocisSubjectArea9, User_Field__c = strFocisSubjectArea10,Zip_Code__c=strPostal11);

         insert c1;
         
         c1 = [SELECT Id, DWH_ID__c, Org_Id__c, Org_Type__c, BATCH_Id__c, Sales_Module__c, Territory_Code__c, Territory__c,
                              State__c, Fiscal_Month_Abbr__c, Fiscal_Year__c, FOCIS_Category__c,
                              FOCIS_Subject_Area__c, Focis_Location__c,User_Field__c  FROM Channel_Compensation__c WHERE Id = :c1.Id limit 1][0];
        
         System.assertEquals(c1.Territory__c, territoryA.Id);
          
         String dhw_id = c1.Org_Id__c + '_' + c1.Org_Type__c + '_' + c1.BATCH_Id__c + '_' + c1.Sales_Module__c + '_' + c1.Territory_Code__c + '_' +
                              c1.State__c + '_' + c1.Fiscal_Month_Abbr__c + '_' + c1.Fiscal_Year__c + '_' + c1.FOCIS_Category__c + '_' +
                              c1.FOCIS_Subject_Area__c + '_' + c1.Focis_Location__c + '_' + c1.User_Field__c;
         
         //check if DWH_ID__c was generated based on inserted fields
     //    System.assertEquals(c1.DWH_ID__c, dhw_id);
         
         List<Channel_Compensation__c> channelsToInsert = new List<Channel_Compensation__c>();
         
         for (Integer i=0; i < 200; i++) {
            channelsToInsert.add(new Channel_Compensation__c(Org_Id__c = strOrgId + i, Org_Type__c = strOrgType, BATCH_Id__c = Date.today().addDays(i), Sales_Module__c = 'AB' + i, Territory_Code__c = 'AB' + i,
                              State__c = 'AB', Fiscal_Month_Abbr__c = 'ABC', Fiscal_Year__c = 'YYYY', FOCIS_Category__c = 'CAT'+i,
                              FOCIS_Subject_Area__c = 'AB' + i, Focis_Location__c = 'AB', User_Field__c = 'AB' ));
         }
         
         insert channelsToInsert;
         
         Integer recordsInserted = [SELECT Count() FROM Channel_Compensation__c];
         
         System.assertEquals(201, recordsInserted);
         
         //test for duplicate entries
         Channel_Compensation__c c2 = new Channel_Compensation__c(Org_Id__c = strOrgId, Org_Type__c = strOrgType, BATCH_Id__c = strBatchId1, Sales_Module__c = strSalesModule2, Territory_Code__c = strTerritoryCode3,
                              State__c = strState4, Fiscal_Month_Abbr__c = strFiscalMonthAbr5, Fiscal_Year__c = strFiscalYear6, FOCIS_Category__c = strFocisCategory7,
                              FOCIS_Subject_Area__c = strFocisSubjectArea8, Focis_Location__c = strFocisSubjectArea9, User_Field__c= strFocisSubjectArea10  );
         
         Boolean recordFailed = false;
                      
          try {
            insert c2;
          }catch (System.DmlException dmlEx) {
            System.Debug('*** exception');
            recordFailed = true;
          }
          
          //System.assertEquals(recordFailed, true);//expect the above to fail
          
          Xactly_Integration__c customSetting = Xactly_Integration__c.getInstance();
          
          if (customSetting == null) {
            customSetting = new Xactly_Integration__c();
          }
          
          customSetting.Ignore_Unique_Constraint_Trigger__c = true;
          
          upsert customSetting;
          
          recordFailed = false;
          
          try {
            insert c2;
          }catch (System.DmlException dmlEx) {
            System.Debug('*** exception');
            recordFailed = true;
          }
          
          System.assertEquals(false, recordFailed);//expect the above to pass because we bypassed it with custom setting
          System.assertNotEquals(null, c2.Id);
          
          c1.Territory_Code__c = 'fake code';
          update c1;
          
          c1 = [SELECT Id, Territory__c FROM Channel_Compensation__c where Id = :c1.Id limit 1];
          
          System.assertEquals(null, c1.Territory__c);
    }
}