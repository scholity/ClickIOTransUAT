global class PHSS_GenerateCCProductXMLBatch implements Database.Batchable<sObject>, Database.Stateful {
   public PHSS_GenerateCCProductXMLBatch(Boolean exportAll) {
      exportAllProducts = exportAll;
   }	

   public Boolean exportAllProducts = false;
   public DateTime RunTime = DateTime.Now();
	
   String str_xml = '';
   Boolean isHeaderSet = false;
   List<Integration_Files__c> integFiles = new List<Integration_Files__c>(); 
   String exportFileName = 'ARC_Physical_Master_' + DateTime.Now().format('MMddyyyyhhmma') + '.xml';
   String targetSystem = 'RCO';
   Integer theSequenceNumber = 0;   
          
   global Database.QueryLocator start(Database.BatchableContext BC){    
	   DateTime lastRunDate = DateTime.Now();
	   String incrementalExport = '';
	   
	   if (!exportAllProducts) {
    	// Get last run date/time from integration files object 	    	
    		List<Integration_Files__c> integrationFiles = [Select Id, CreatedDate From Integration_Files__c Where File_Name__c Like 'ARC_Physical_Master%'
	    		Order By CreatedDate Desc Limit 1];        
    		if (integrationFiles.size() != null && integrationFiles.size() > 0) {
    			lastRunDate = integrationFiles[0].CreatedDate;
	    		incrementalExport = 'And LastModifiedDate > :lastRunDate ';
	    	}
	    }    	
  
       if(isHeaderSet==false){
       	  PHSS_GenerateCCProductXMLUtility phssGenerateCCProductXMLUtility = new PHSS_GenerateCCProductXMLUtility();
          str_xml = phssGenerateCCProductXMLUtility.getProductXmlHeader();

          // Write export record header to Integration Files object
	      try {        
	          Integration_Files__c integrationFileHeader = new Integration_Files__c();
	          integrationFileHeader.Record_Data__c = str_xml; 
              integrationFileHeader.File_Name__c = exportFileName;
	          integrationFileHeader.Sequence_Number__c = ++theSequenceNumber;
	          integrationFileHeader.Target_System__c = targetSystem;
	          insert(integrationFileHeader);        
	      } catch (exception e) {
	            
	      }              
          isHeaderSet = true;
       }
       
       // Enhancement - US1242 - Trigger incremental export on updated product specs as well as updated product master records
       
       if (!exportAllProducts) {
	       String productIds = '';
	       List<ccrz__E_ProductSpec__c> lst_ProductSpec = new List<ccrz__E_ProductSpec__c>(); 
	             	
	       String specQuery = 'Select Id, ccrz__Product__c, ccrz__Product__r.ccrz__InventoryType__c ';
	       specQuery += 'From ccrz__E_ProductSpec__c Where ccrz__Product__r.ccrz__InventoryType__c = \'STANDARD\' ';
	       specQuery += incrementalExport;
	       
	       lst_ProductSpec = Database.query(specQuery);      
	       for (ccrz__E_ProductSpec__c theProductSpec : lst_ProductSpec) {
	       		if (productIds.length()==0) {
	       			productIds = '\''+theProductSpec.ccrz__Product__c+'\'';
	       		} else {
	       			productIds += ',\''+theProductSpec.ccrz__Product__c+'\'';
	       		}
	       }
			
		   if (productIds.length() > 0) {
	   	   		incrementalExport = 'And ((LastModifiedDate > :lastRunDate) Or Id In ('+productIds+'))';
		   }
       }
       
       String productQuery = 'Select Id,Name,ccrz__SKU__c,ccrz__ShortDescRT__c,ccrz__LongDescRT__c,ccrz__InventoryType__c, ';
       productQuery += 'OMSProductName__c,BackOrderable__c,Drop_Ship_Vendor__c,Distributor_Only_Product__c,Bulk_Order_Threshold__c, ';
       productQuery += 'Stocking_Code__c,Manufacturer_Product_ID__c,ccrz__ShippingWeight__c,Tariff_Code__c,ccrz__UnitOfMeasure__c, ';
       productQuery += 'WareHousePkgInstructions__c,OMS_Grouping_Category__c,ccrz__StartDate__c,ccrz__EndDate__c,Is_Digital__c, ';
       productQuery += 'Product_Cost__c,ccrz__ProductStatus__c,Shelf_Life__c,Shipping_Condition__c,Lot_Process__c ';
       productQuery += 'From ccrz__E_Product__c Where ccrz__InventoryType__c = \'STANDARD\' ';
       productQuery += incrementalExport;
       productQuery += 'Order By CreatedDate Desc';
       
       return Database.getQueryLocator(productQuery);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
      
       if (scope != null && scope.size() > 0) {          
	       List<ccrz__E_Product__c> lst_Product = new List<ccrz__E_Product__c>();
	       Set<Id> productIds = new Set<Id>();
	       
	       lst_Product.addAll((List<ccrz__E_Product__c>) scope); 
	       for (ccrz__E_Product__c theProduct : lst_Product) {
	       		productIds.add(theProduct.Id);
	       }
	       
	       List<ccrz__E_ProductSpec__c> lst_ProductSpec = new List<ccrz__E_ProductSpec__c>();
	       Map<Id, List<ccrz__E_ProductSpec__c>> productSpecMap = new Map<Id, List<ccrz__E_ProductSpec__c>>(); 
	       
	       lst_ProductSpec = [Select ccrz__Product__c, ccrz__Spec__r.Name, ccrz__SpecValue__c
	       		From ccrz__E_ProductSpec__c Where ccrz__Product__c In :productIds];
	       		//And ccrz__Spec__r.Name In ('UPC','Width','Height','Depth','Weight',
	       		//'Manufacturer','Brand','ISBN','Publication Date','Country of Origin','Manufacturer Part No')];  	       		
	       		
	       if (lst_ProductSpec != null) {
		       for (ccrz__E_ProductSpec__c theProductSpec : lst_ProductSpec) {
		       		List<ccrz__E_ProductSpec__c> productSpecList = new List<ccrz__E_ProductSpec__c>();
	
		       		if (productSpecMap.get(theProductSpec.ccrz__Product__c) == null) {
		       			productSpecList.add(theProductSpec);
		       		} else {
		       			productSpecList = productSpecMap.get(theProductSpec.ccrz__Product__c);
	       				productSpecList.add(theProductSpec);		       			
		       		}
	       			productSpecMap.put(theProductSpec.ccrz__Product__c, productSpecList);	       		
		       }  
	       }
            
           PHSS_GenerateCCProductXMLUtility phssGenerateCCProductXMLUtility = new PHSS_GenerateCCProductXMLUtility();
	       for(ccrz__E_Product__c obj_product : lst_Product){
	          String strProductXML = phssGenerateCCProductXMLUtility.getProductXML(obj_product, productSpecMap.get(obj_product.Id));
	     	  str_xml = str_xml + strProductXML;
	     	 
	          // Write product export record to Integration Files object
		      try {        
		          Integration_Files__c integrationFileProductXML = new Integration_Files__c();
		          integrationFileProductXML.Record_Data__c = strProductXML; 
	              integrationFileProductXML.File_Name__c = exportFileName;
		          integrationFileProductXML.Sequence_Number__c = ++theSequenceNumber;
		          integrationFileProductXML.Target_System__c = targetSystem;
		          insert(integrationFileProductXML);        
		      } catch (exception e) {
		            
		      }      	 
	       }
       }
       System.debug('---Execute--->'+str_xml);
    }

   global void finish(Database.BatchableContext BC){
       PHSS_GenerateCCProductXMLUtility phssGenerateCCProductXMLUtility = new PHSS_GenerateCCProductXMLUtility();   	
   	   String strProductTrailer = phssGenerateCCProductXMLUtility.getProductXmlTrailer();
       str_xml = str_xml + strProductTrailer;
       
       phssGenerateCCProductXMLUtility.generateCCProductXmlFile(str_xml);
       
       // Write export record header to Integration Files object
       try {        
	       Integration_Files__c integrationFileTrailer = new Integration_Files__c();
	       integrationFileTrailer.Record_Data__c = strProductTrailer; 
           integrationFileTrailer.File_Name__c = exportFileName;
	       integrationFileTrailer.Sequence_Number__c = ++theSequenceNumber;
	       integrationFileTrailer.Target_System__c = targetSystem;
	       insert(integrationFileTrailer);        
	   } catch (exception e) {
	            
	   }          
       
       System.debug('---Finish--->'+str_xml);
   }
}