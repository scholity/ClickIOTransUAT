@isTest
private class PHSS_PriceListItemTriggerHandlerTest {

    @isTest
    private static void testPriceOverride() {
        Course_Catalog__c catalog = new Course_Catalog__c();
        catalog.Name = 'C12345';
        catalog.Number_of_Students__c = 5;
        catalog.Type__c = 'Community';
        insert catalog; 

        redwing__Training_Plan__c learningPlan = new redwing__Training_Plan__c();
        learningPlan.Classroom_Setting__c = 'Classroom';
        learningPlan.redwing__Status__c = 'Active';
        insert learningPlan;
        
        ccrz__E_Product__c product = new ccrz__E_Product__c();
        product.Name = 'TEST PRODUCT';
        product.ccrz__SKU__c = 'SKU123';
        product.ccrz__ProductStatus__c = 'Released';
        product.ccrz__ProductType__c = 'Product';
        product.ccrz__Storefront__c = 'GeneralStore';
        product.ccrz__ShortDesc__c = 'SKU123';
        product.ccrz__ShortDescRT__c = 'SKU123';
        product.ccrz__StartDate__c = System.today().addYears(-1);
        product.ccrz__EndDate__c = System.today().addYears(+1);
        product.AP_Code__c = '6200';
        product.FCC__c = '32620';
        product.OMSProductName__c = '1234';
        product.Course_Catalog__c = catalog.Id;
        product.LMS_Learning_Plan__c = learningPlan.Id;
		insert product;

        ccrz__E_PriceList__c priceList = new ccrz__E_PriceList__c();
        priceList.Name = 'ZIP-72206';
        priceList.ccrz__CurrencyISOCode__c = 'USD';
        priceList.ccrz__Enabled__c = true;
        priceList.ccrz__Storefront__c = 'GeneralStore';
        priceList.ccrz__StartDate__c = System.today().addYears(-1);
        priceList.ccrz__EndDate__c = System.today().addYears(+1);
        insert priceList;
            
        ccrz__E_PriceListItem__c priceListItem = new ccrz__E_PriceListItem__c();
        priceListItem.ccrz__Price__c = (Double)50;
        priceListItem.ccrz__Product__c = product.Id;
        priceListItem.ccrz__Pricelist__c = pricelist.Id;
        priceListItem.ccrz__StartDate__c = System.today().addYears(-1);
        priceListItem.ccrz__EndDate__c = System.today().addYears(+1);
        insert priceListItem;
            
        // create location record for class
        redwing__ILT_Location__c theLocation = new redwing__ILT_Location__c();
        theLocation.Name = 'Test Location';
        theLocation.redwing__Address_1__c   = '101 S Main';
        theLocation.redwing__Address_2__c   = '';
        theLocation.redwing__City__c        = 'Anywhere';
        theLocation.redwing__State__c       = 'NY';
        theLocation.redwing__Postal_Code__c = '72206';
        theLocation.redwing__Country__c     = 'US'; 
        insert theLocation;        
        
        redwing__Learning__c learning = new redwing__Learning__c(Name = 'TEST LEARNING');
        learning.RecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('ILT Class').getRecordTypeId();
        insert learning;        

        sked__Region__c region = new sked__Region__c();
        region.Name = 'Test Region';
        region.sked__Timezone__c = 'US/Eastern';
        insert region;
        
        sked__Location__c objLocation = new sked__Location__c();
        objLocation.Name = 'Test';
        objLocation.sked__Type__c = 'Community';
        objLocation.sked__Address__c = '401 S Monroe St, Little Rock, AR, 72206';
        objLocation.Is_Active__c = true;
        insert objLocation;
        
        sked__Job__c job = new sked__Job__c();
        job.sked__Region__c = region.id;
        job.Course_Catalog__c = catalog.id;
        job.Start_Time__c = '12:00';
        job.End_Time__c = '13:00';
        //job.sked__Timezone__c = 'US/Eastern';
        job.sked__Start__c = DateTime.Now();
        job.sked__Finish__c = DateTime.Now().addMinutes(60);
        job.sked__Duration__c = 60;
        job.Job_Month__c = System.Today();
        job.sked__Location__c = objLocation.Id;
        job.sked__Type__c = 'Community';
        job.Location_Confirmed__c = true; 
        job.Is_Master_Class__c=false;
        job.Is_Stacked_Class__c=false;
        job.Course_Code__c='C12345';
        job.sked__Job_Status__c = 'Dispatched';
		//job.sked__Recurring_Schedule__c = schedule.Id;          
        insert job;  
        
        System.debug('Job='+job);
        
        // Initial class creation via integration logic should result in $50 price applied to ILT Class record
        redwing__ILT_Class__c theUpdatedClass = new redwing__ILT_Class__c();
        List<redwing__ILT_Class__c> theClassList = [Select Id, Name, Price_Override__c From redwing__ILT_Class__c Where Skedulo_Job_Id__c = :job.Id];

        System.assert(theClassList.size()==1);
        theUpdatedClass = theClassList[0];        
        System.assertEquals(priceListItem.ccrz__Price__c, theUpdatedClass.Price_Override__c);     
        
		// Modify override price to force logic to scan for existing ILT classes with this zip and modify price in record
        priceListItem.ccrz__Price__c = (Double)100;
        update priceListItem;         
        
        theClassList = [Select Id, Name, Price_Override__c From redwing__ILT_Class__c Where Skedulo_Job_ID__c = :job.Id];

        // Update of price override value should result in same value being propagated to ILT Class record
        System.assert(theClassList.size()==1);
        theUpdatedClass = theClassList[0];        
        System.assertEquals(priceListItem.ccrz__Price__c, theUpdatedClass.Price_Override__c); 

    }
}