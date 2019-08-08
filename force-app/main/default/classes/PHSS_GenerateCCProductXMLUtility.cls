public without sharing class PHSS_GenerateCCProductXMLUtility {
    String tabManufacturer = '';   
    String tabManufacturerPartNumber = '';  
    String brand = '';	
    String UPC = '';
    
    public String getProductXML(ccrz__E_Product__c obj_Product, List<ccrz__E_ProductSpec__c> productSpecList){
        XmlStreamWriter xmlW = new XmlStreamWriter();   
    
        CustomAttributes theCustomAttributes = new CustomAttributes(obj_Product, productSpecList); 
        for (String fieldName : theCustomAttributes.customAttributeValueMap.keySet()) {
        	if (fieldName == 'tabManufacturer' ) {
        		tabManufacturer = theCustomAttributes.customAttributeValueMap.get(fieldName);
        	} else if (fieldName == 'tabManufacturerPartNumber') {
        		tabManufacturerPartNumber = theCustomAttributes.customAttributeValueMap.get(fieldName);
        	}  else if (fieldName == 'brand') {
        		brand = theCustomAttributes.customAttributeValueMap.get(fieldName);
        	}   else if (fieldName == 'UPC') {
        		UPC = theCustomAttributes.customAttributeValueMap.get(fieldName);
        	}      	
        }      
        
        //start Product 
        xmlW.writeStartElement(null,'product', null);
            if(String.isNotBlank(obj_Product.ccrz__SKU__c))
            	xmlW.writeAttribute(null,null,'product-id',obj_Product.ccrz__SKU__c);
            xmlW.writeCharacters('\n');
                    
       		if (String.isNotBlank(UPC)) {        
	        	xmlW.writeStartElement(null,'upc', null);
	            xmlW.writeCharacters(UPC);
	            xmlW.writeEndElement(); 
	            xmlW.writeCharacters('\n');
       		}  
        	
        	/*
        	xmlW.writeStartElement(null,'ean', null);
            xmlW.writeCharacters('');
            xmlW.writeEndElement(); 
            xmlW.writeCharacters('\n');
        
        	xmlW.writeStartElement(null,'upc', null);
            xmlW.writeCharacters('');
            xmlW.writeEndElement(); 
            xmlW.writeCharacters('\n');
        
        	xmlW.writeStartElement(null,'unit', null);
            xmlW.writeCharacters('');
            xmlW.writeEndElement(); 
            xmlW.writeCharacters('\n');
        	*/
        	
        	xmlW.writeStartElement(null,'min-order-quantity', null);
            xmlW.writeCharacters('1');
            xmlW.writeEndElement(); 
            xmlW.writeCharacters('\n');
        
        	xmlW.writeStartElement(null,'step-quantity', null);
            xmlW.writeCharacters('1');
            xmlW.writeEndElement(); 
            xmlW.writeCharacters('\n');
        
        	if(String.isNotBlank(obj_Product.Name)) {
	        	xmlW.writeStartElement(null,'display-name', null);
	        		xmlW.writeAttribute(null,null,'xml:lang','x-default');
	        	xmlW.writeCharacters(obj_Product.Name);
	            xmlW.writeEndElement(); 
	            xmlW.writeCharacters('\n');
        	}
        
        	if (String.isNotBlank(obj_Product.ccrz__ShortDescRT__c)) {
        		xmlW.writeStartElement(null,'short-description', null);
	        	xmlW.writeAttribute(null,null,'xml:lang','x-default');
	        	//String shortDescription = obj_Product.ccrz__ShortDescRT__c.replaceAll('<[^>]+>','').replaceAll('[^\\x00-\\x7f]', ''); 
	        	String shortDescription = obj_Product.ccrz__ShortDescRT__c.replaceAll('[^\\x00-\\x7f]', ''); 
	        	xmlW.writeCharacters(shortDescription);
	            xmlW.writeEndElement(); 
	            xmlW.writeCharacters('\n');
        	}
        
        	if (String.isNotBlank(obj_Product.ccrz__LongDescRT__c)) {
	        	xmlW.writeStartElement(null,'long-description', null);
	        	xmlW.writeAttribute(null,null,'xml:lang','x-default');
	            //String longDescription = obj_Product.ccrz__LongDescRT__c.replaceAll('<[^>]+>','').replaceAll('[^\\x00-\\x7f]', ''); 
	            String longDescription = obj_Product.ccrz__LongDescRT__c.replaceAll('[^\\x00-\\x7f]', '');       	
	        	xmlW.writeCharacters(longDescription);
	            xmlW.writeEndElement(); 
	            xmlW.writeCharacters('\n');
        	}
        	
        	/*
        	xmlW.writeStartElement(null,'store-force-price-flag', null);
            xmlW.writeCharacters('false');
            xmlW.writeEndElement(); 
            xmlW.writeCharacters('\n');
        
        	xmlW.writeStartElement(null,'store-non-inventory-flag', null);
            xmlW.writeCharacters('false');
            xmlW.writeEndElement(); 
            xmlW.writeCharacters('\n');
        
        	xmlW.writeStartElement(null,'store-non-revenue-flag', null);
            xmlW.writeCharacters('false');
            xmlW.writeEndElement(); 
            xmlW.writeCharacters('\n');
        
        	xmlW.writeStartElement(null,'store-non-discountable-flag', null);
            xmlW.writeCharacters('false');
            xmlW.writeEndElement(); 
            xmlW.writeCharacters('\n');
        	*/
        	
        	if (String.isNotBlank(obj_Product.ccrz__ProductStatus__c)) { 
	        	xmlW.writeStartElement(null,'online-flag', null);
	        	String onlineFlag = (obj_Product.ccrz__ProductStatus__c == 'Released') ? 'true' : 'false';
	            xmlW.writeCharacters(onlineFlag);
	            xmlW.writeEndElement(); 
	            xmlW.writeCharacters('\n');
        	}
        
        	/* This is a duplicate of the attribute supplied above
        	xmlW.writeStartElement(null,'online-flag', null);
        	xmlW.writeAttribute(null,null,'site-id','RedCross');
            xmlW.writeCharacters('true');
            xmlW.writeEndElement(); 
            xmlW.writeCharacters('\n');
        	*/        	

        	if (obj_Product.ccrz__StartDate__c != NULL) {
	        	xmlW.writeStartElement(null,'online-from', null);
	           	String onlineFrom = String.valueOf(obj_Product.ccrz__StartDate__c)+'T07:00:00.000Z';
	            xmlW.writeCharacters(onlineFrom);
	            xmlW.writeEndElement(); 
	            xmlW.writeCharacters('\n');
        	}

        	if (obj_Product.ccrz__EndDate__c != NULL) {
	        	xmlW.writeStartElement(null,'online-to', null);
	           	String onlineTo = String.valueOf(obj_Product.ccrz__EndDate__c)+'T07:00:00.000Z';
	            xmlW.writeCharacters(onlineTo);
	            xmlW.writeEndElement(); 
	            xmlW.writeCharacters('\n');  
        	}             	
        	
        	/*
        	if (String.isNotBlank(obj_Product.ccrz__ProductStatus__c)) { 
	        	xmlW.writeStartElement(null,'available-flag', null);
	        	String available = (obj_Product.ccrz__ProductStatus__c == 'Released') ? 'true' : 'false';
	            xmlW.writeCharacters(available);
	            xmlW.writeEndElement(); 
	            xmlW.writeCharacters('\n');
        	}             
        	*/
        	
        	if (String.isNotBlank(obj_Product.ccrz__ProductStatus__c)) { 
	        	xmlW.writeStartElement(null,'searchable-flag', null);
	        	String searchable = (obj_Product.ccrz__ProductStatus__c == 'Released') ? 'true' : 'false';
	            xmlW.writeCharacters(searchable);
	            xmlW.writeEndElement(); 
	            xmlW.writeCharacters('\n');
        	}            
        	
        	/* This is a duplicate of the attribute supplied above
        	xmlW.writeStartElement(null,'searchable-flag', null);
        	xmlW.writeAttribute(null,null,'site-id','RedCross');
            xmlW.writeCharacters('true');
            xmlW.writeEndElement(); 
            xmlW.writeCharacters('\n');
        	*/     

        	xmlW.writeStartElement(null,'tax-class-id', null);
            xmlW.writeCharacters('E');
            xmlW.writeEndElement(); 
            xmlW.writeCharacters('\n');
        
       		if (String.isNotBlank(brand)) {        
	        	xmlW.writeStartElement(null,'brand', null);
	            xmlW.writeCharacters(brand);
	            xmlW.writeEndElement(); 
	            xmlW.writeCharacters('\n');
       		}     		
        
        	if (String.isNotBlank(tabManufacturer)) {
	        	xmlW.writeStartElement(null,'manufacturer-name', null);
	        	xmlW.writeCharacters(tabManufacturer);
	            xmlW.writeEndElement(); 
	            xmlW.writeCharacters('\n');
        	}

        	if (String.isNotBlank(tabManufacturerPartNumber)) {
	        	xmlW.writeStartElement(null,'manufacturer-sku', null);
	        	xmlW.writeCharacters(tabManufacturerPartNumber);
	            xmlW.writeEndElement(); 
	            xmlW.writeCharacters('\n');
        	}        	
        	
        	/* Default Site Map no longer exported - no value will result in -None- in Demandware product record
        	xmlW.writeStartElement(null,'sitemap-included-flag', null);
            xmlW.writeCharacters('true');
            xmlW.writeEndElement(); 
            xmlW.writeCharacters('\n');
        	*/
        	
        	xmlW.writeStartElement(null,'page-attributes', null);
            
        		xmlW.writeStartElement(null,'page-title', null);
        		xmlW.writeAttribute(null,null,'xml:lang','x-default');
                xmlW.writeCharacters('');
                xmlW.writeEndElement(); 
                xmlW.writeCharacters('\n');
        
        		xmlW.writeStartElement(null,'page-description', null);
        		xmlW.writeAttribute(null,null,'xml:lang','x-default');
                xmlW.writeCharacters('');
                xmlW.writeEndElement(); 
                xmlW.writeCharacters('\n');
        
        		xmlW.writeStartElement(null,'page-url', null);
        		xmlW.writeAttribute(null,null,'xml:lang','x-default');
                xmlW.writeCharacters('');
                xmlW.writeEndElement(); 
                xmlW.writeCharacters('\n');
        
            xmlW.writeEndElement(); 
            xmlW.writeCharacters('\n');

            xmlW = getCustomAttributesXML(xmlW,theCustomAttributes);
        
        	xmlW.writeStartElement(null,'pinterest-enabled-flag', null);
            xmlW.writeCharacters('false');
            xmlW.writeEndElement(); 
            xmlW.writeCharacters('\n');
        
        	xmlW.writeStartElement(null,'facebook-enabled-flag', null);
            xmlW.writeCharacters('false');
            xmlW.writeEndElement(); 
            xmlW.writeCharacters('\n');
        
        	xmlW.writeStartElement(null,'store-attributes', null);
            
        		xmlW.writeStartElement(null,'force-price-flag', null);
                xmlW.writeCharacters('false');
                xmlW.writeEndElement(); 
                xmlW.writeCharacters('\n');
        
        		xmlW.writeStartElement(null,'non-inventory-flag', null);
                xmlW.writeCharacters('false');
                xmlW.writeEndElement(); 
                xmlW.writeCharacters('\n');
        
        		xmlW.writeStartElement(null,'non-revenue-flag', null);
                xmlW.writeCharacters('false');
                xmlW.writeEndElement(); 
                xmlW.writeCharacters('\n');
        		
        		xmlW.writeStartElement(null,'non-discountable-flag', null);
                xmlW.writeCharacters('false');
                xmlW.writeEndElement(); 
                xmlW.writeCharacters('\n');
        
            xmlW.writeEndElement(); 
            xmlW.writeCharacters('\n');
        //add image, page attributes,  custom attributes ,store attributes
        
        xmlW.writeEndElement();
        xmlW.writeCharacters('\n');        
    	
    	return xmlW.getXmlString();
    }
    
     // Create XML header
    public String getProductXmlHeader() {
        XmlStreamWriter xmlW = new XmlStreamWriter();
		
        xmlW.writeStartDocument('UTF-8','1.0');
        xmlW.writeCharacters('\n');
		
		//start catalog
        xmlW.writeStartElement(null,'catalog', null);
        xmlW.writeAttribute(null,null,'catalog-id','PhysicalProductCatalog');
        xmlW.writeAttribute(null,null,'xmlns','http://www.demandware.com/xml/impex/catalog/2006-10-31');
        xmlW.writeCharacters('\n');
		
			//start header
			xmlW.writeStartElement(null,'header',null);
			xmlW.writeCharacters('\n');
			
				xmlW.writeStartElement(null,'image-settings',null);
				xmlW.writeCharacters('\n');
					xmlW.writeStartElement(null,'internal-location',null);                      
					xmlW.writeAttribute(null,null,'base-path','/');
					xmlW.writeEndElement(); // Close internal-location
					xmlW.writeCharacters('\n');
					
					xmlW.writeStartElement(null,'view-types',null);
					xmlW.writeCharacters('\n');
						xmlW.writeStartElement(null,'view-type',null);          
						xmlW.writeCharacters('large');
						xmlW.writeEndElement(); // Close view-type large
						xmlW.writeCharacters('\n');             
						xmlW.writeStartElement(null,'view-type',null);          
						xmlW.writeCharacters('medium');
						xmlW.writeEndElement(); // Close view-type medium
						xmlW.writeCharacters('\n');
						xmlW.writeStartElement(null,'view-type',null);          
						xmlW.writeCharacters('small');
						xmlW.writeEndElement(); // Close view-type small
						xmlW.writeCharacters('\n'); 
						xmlW.writeStartElement(null,'view-type',null);          
						xmlW.writeCharacters('swatch');
						xmlW.writeEndElement(); // Close view-type swatch
						xmlW.writeCharacters('\n'); 
						xmlW.writeStartElement(null,'view-type',null);          
						xmlW.writeCharacters('video');
						xmlW.writeEndElement(); // Close view-type video
						xmlW.writeCharacters('\n'); 
					xmlW.writeEndElement(); // Close view-types
					xmlW.writeCharacters('\n');
					
					xmlW.writeStartElement(null,'alt-pattern',null);                        
					xmlW.writeCharacters('${productname}');
					xmlW.writeEndElement(); // Close alt-pattern
					xmlW.writeCharacters('\n');   
					
					xmlW.writeStartElement(null,'title-pattern',null);                      
					xmlW.writeCharacters('${productname}');
					xmlW.writeEndElement(); // Close title-pattern
					xmlW.writeCharacters('\n');
				xmlW.writeEndElement(); // Close image-settings
				xmlW.writeCharacters('\n');
		
			// Close header	
			xmlW.writeEndElement();
			xmlW.writeCharacters('\n');
        
			//start category
			xmlW.writeStartElement(null,'category',null);  
			xmlW.writeAttribute(null,null,'category-id','root');  
			xmlW.writeCharacters('\n'); 
			
				xmlW.writeStartElement(null,'display-name',null);  
				xmlW.writeCharacters('Physical Product Master Catalog');   
				xmlW.writeEndElement(); // Close display-name
				xmlW.writeCharacters('\n'); 
							
				xmlW.writeStartElement(null,'online-flag',null);  
				xmlW.writeCharacters('true');   
				xmlW.writeEndElement(); // Close online-flag
				xmlW.writeCharacters('\n'); 
							
				xmlW.writeStartElement(null,'template',null);  
				xmlW.writeCharacters('');   
				xmlW.writeEndElement(); // Close template
				xmlW.writeCharacters('\n'); 
				
				xmlW.writeStartElement(null,'page-attributes',null);  
				xmlW.writeCharacters('');   
				xmlW.writeEndElement(); // Close page-attributes
				xmlW.writeCharacters('\n'); 
			
			// Close category
			xmlW.writeEndElement(); 
			xmlW.writeCharacters('\n');
                
        System.debug(xmlW.getXmlString());   
        return xmlW.getXmlString();
    }   
    
    public String getProductXmlTrailer() {   
        return '</catalog>';    
    } 
    
    public void generateCCProductXmlFile(String productXML) {
        
        // Save file to Folder   
        // Create xml file
        ContentVersion v = new ContentVersion();
        v.versionData = Blob.valueOf(productXML);
        v.title = 'Active CC Products '+String.valueOf(Date.today());
        v.PathOnClient = '/ActiveCCProducts.xml';
        insert v;
        
        // Get the content document Id from ContentVersion and Folder/Library Ids
        v = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :v.Id LIMIT 1];
        List<ContentWorkspace> ws = [SELECT Id, RootContentFolderId FROM ContentWorkspace WHERE Name = 'Asset Library' LIMIT 1];// Change the folder name to PHSS integration
        
        if(v.ContentDocumentId!=NULL && !ws.isEmpty()){ 
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = v.ContentDocumentId;
            cdl.ShareType = 'I';
            cdl.Visibility = 'AllUsers';
            cdl.LinkedEntityId = ws[0].Id; 
            insert cdl;
        }
    }
    
    XmlStreamWriter getCustomAttributesXML(XmlStreamWriter xmlW, CustomAttributes theCustomAttributes) {
        xmlW.writeStartElement(null,'custom-attributes', null);
        xmlW.writeCharacters('\n');
     
        for (String fieldName : theCustomAttributes.customAttributeValueMap.keySet()) {
            if ('brand,UPC'.contains(fieldName)) continue; // These are now exported as standard attributes     	
            String theFieldValue = theCustomAttributes.customAttributeValueMap.get(fieldName);
            if (String.isNotBlank(theFieldValue) || 'dropShipVendor,shippingCondition,stockingCode'.contains(fieldName)) {        	
            	xmlW.writeStartElement(null,'custom-attribute', null);
                	xmlW.writeAttribute(null,null,'attribute-id', fieldName);
	                xmlW.writeCharacters(theFieldValue);
	            xmlW.writeEndElement(); // Close custom-attribute   
	            xmlW.writeCharacters('\n');
            }
        }

        xmlW.writeEndElement(); // Close custom-attributes
        xmlW.writeCharacters('\n');
        
        return xmlW;
    } 
    
    public class CustomAttributes {
        String   IsCourse = '';
        String   OMSProductName = '';
        String   OMSGroupingCategory = '';
        String   backorderable = '';
        String   costPrice = '';
        String   countryOfOrigin = '';
        String   dropShipVendor = '';  
        String   isDistributor = ''; 
        String   BulkOrderThreshold = '';      
        String   productType = ''; 
        String   stockingCode = '';   
        String   tabDepth = '';  
        String   tabHeight = '';   
        String   tabManufacturerPartNumber = ''; 
        String   tabManufacturer = '';        
        String   tabWeight = '';       
        String   tabWidth = '';      
        String   tariffCode = '';   
        String   unitofMeasure = '';   
        String   whsePkgInst = ''; 
        String   isDigital = '';
        String   UPC = '';
        String   brand = '';
        String   ISBN = '';
        String   tabPublicationDate = '';
        String   shelfLife = '';
        String   shippingCondition = '';
        String   LotProcess = '';
        
        
        Map<String, String> customAttributeValueMap;
    
        CustomAttributes(ccrz__E_Product__c obj_product, List<ccrz__E_ProductSpec__c> productSpecList) { 
            
            if(obj_product.ccrz__InventoryType__c == 'COURSE' || obj_product.ccrz__InventoryType__c == 'COMMUNITY'){
                IsCourse = 'true';
                productType = 'course';
            }
            else{
                IsCourse = 'false';
                productType = 'physical';
            }
            
            if(obj_product.OMSProductName__c!=null){
                OMSProductName = obj_product.OMSProductName__c;
            }else{
                OMSProductName = '';
            }        
        
        	if(obj_Product.OMS_Grouping_Category__c != null) {
	        	OMSGroupingCategory = obj_Product.OMS_Grouping_Category__c;
        	}else{
        		OMSGroupingCategory = '';
        	}            
            
            if(obj_product.BackOrderable__c == 'Yes'){
                backorderable = 'true';
            }else{
                backorderable = 'false';
            }
                
            if(obj_product.Drop_Ship_Vendor__c !=Null){
                String CCdropShipVendor = obj_product.Drop_Ship_Vendor__c;
                if (CCdropShipVendor == 'Acme') dropShipVendor = 'acme';
                	else if (CCdropShipVendor =='Inkwell') dropShipVendor = 'inkwell';
                	else if (CCdropShipVendor == 'Tender') dropShipVendor = 'tender';
                	else if (CCdropShipVendor == 'Phillips') dropShipVendor = 'phillips';
                	else if (CCdropShipVendor == 'Heartsine') dropShipVendor = 'heartsine';
                	else if (CCdropShipVendor == 'Zoll') dropShipVendor = 'zoll';                	
                	else dropShipVendor = '';
            }else{
                dropShipVendor = '';
            }  
            
            if(obj_product.Stocking_Code__c != NULL){
                String CCstockingCode = obj_product.Stocking_Code__c;
                if (CCstockingCode == 'Stock') stockingCode = 'stock';
                	else if (CCstockingCode =='UseUP') stockingCode = 'useup';
                	else if (CCstockingCode == 'Obsolete') stockingCode = 'obsolete';
                	else stockingCode = '';
            }else{
                stockingCode = '';
            }            
            
            if(obj_product.Distributor_Only_Product__c == 'Yes'){
                isDistributor = 'true';
            }else{
                isDistributor = 'false';
            }
            
            if(obj_product.Bulk_Order_Threshold__c != NULL){
                BulkOrderThreshold = String.ValueOf(obj_product.Bulk_Order_Threshold__c);
            }else{
                BulkOrderThreshold = '';
            }
            
            /*
            if(obj_product.ccrz__ShippingWeight__c != NULL){
                tabWeight = String.ValueOf(obj_product.ccrz__ShippingWeight__c);
            }else{
                tabWeight = '';
            }
            */
                
            if(obj_product.Tariff_Code__c != NULL){
                tariffCode = obj_product.Tariff_Code__c;
            }else{
                tariffCode = '';
            }
                
            if(obj_product.ccrz__UnitOfMeasure__c != NULL){
                String CCunitofMeasure = obj_product.ccrz__UnitOfMeasure__c;
                if (CCunitofMeasure == 'Each') unitofMeasure = 'ea';
                else unitofMeasure = '';
            }else{
                unitofMeasure = '';
            }
                
            if(obj_product.WareHousePkgInstructions__c != NULL){
                whsePkgInst = obj_product.WareHousePkgInstructions__c;
            }else{
                whsePkgInst = '';
            }
            
            if(obj_product.Product_Cost__c != NULL){
            	costPrice = String.valueOf(obj_product.Product_Cost__c);
            }else{
            	costPrice = '';
            }     
            
            if(obj_product.Is_Digital__c != NULL){ 
				String CCisDigital = obj_product.Is_Digital__c;
                if (CCisDigital == 'Yes') isDigital = 'true';
                	else if (CCisDigital =='No') isDigital = 'false';
                	else if (CCisDigital == 'None') isDigital = 'false';
                	else isDigital = '';        					
			}else{
				isDigital = '';
			}            

			if (obj_product.Shipping_Condition__c != NULL) {
				String CCshippingCondition = obj_product.Shipping_Condition__c;
                if (CCshippingCondition == 'ORMD' || CCshippingCondition == 'Ormd') shippingCondition = 'ormd';
                	else if (CCshippingCondition =='Hazmat') shippingCondition = 'haz';
                	else if (CCshippingCondition == 'Fragile') shippingCondition = 'fgl';
                	else shippingCondition = '';        					
			}else{
				shippingCondition = '';
			}
			
			if (obj_product.Lot_Process__c != NULL) {
				String CCLotProcess = obj_product.Lot_Process__c;
                if (CCLotProcess == 'Yes') LotProcess = 'true';
                	else if (CCLotProcess =='No') LotProcess = 'false';
                	else LotProcess = '';        					
			}else{
				LotProcess = '';
			}    			
			
			if (obj_product.Shelf_Life__c != NULL) {
				shelfLife = obj_product.Shelf_Life__c;
			}else{
				shelfLife = '';
			} 					
            
            if (productSpecList != null) {
            	for (ccrz__E_ProductSpec__c theProductSpec : productSpecList) {
        			if (theProductSpec.ccrz__Spec__r.Name == 'UPC') {
        				if (theProductSpec.ccrz__SpecValue__c != NULL) {
        					UPC = theProductSpec.ccrz__SpecValue__c;
        				}else{
        					UPC = '';
        				}
        			}
        			if (theProductSpec.ccrz__Spec__r.Name.startsWith('Width')) {
        				if (theProductSpec.ccrz__SpecValue__c != NULL) {
        					tabWidth = theProductSpec.ccrz__SpecValue__c;
        				}else{
        					tabWidth = '';
        				}
        			}
        			if (theProductSpec.ccrz__Spec__r.Name.startsWith('Height')) {
        				if (theProductSpec.ccrz__SpecValue__c != NULL) {
        					tabHeight = theProductSpec.ccrz__SpecValue__c;
        				}else{
        					tabHeight = '';
        				}
        			}  
        			if (theProductSpec.ccrz__Spec__r.Name.startsWith('Depth')) {
        				if (theProductSpec.ccrz__SpecValue__c != NULL) {
        					tabDepth = theProductSpec.ccrz__SpecValue__c;
        				}else{
        					tabDepth = '';
        				}
        			}   
        			if (theProductSpec.ccrz__Spec__r.Name.startsWith('Weight')) {
        				if (theProductSpec.ccrz__SpecValue__c != NULL) {
        					tabWeight = theProductSpec.ccrz__SpecValue__c;
        				}else{
        					tabWeight = '';
        				}
        			}   
        			if (theProductSpec.ccrz__Spec__r.Name == 'Manufacturer') {
        				if (theProductSpec.ccrz__SpecValue__c != NULL) {
        					tabManufacturer = theProductSpec.ccrz__SpecValue__c;
        				}else{
        					tabManufacturer = '';
        				}
        			}   
        			if (theProductSpec.ccrz__Spec__r.Name == 'Brand') {
        				if (theProductSpec.ccrz__SpecValue__c != NULL) {
        					brand = theProductSpec.ccrz__SpecValue__c;
        				}else{
        					brand = '';
        				}
        			}    
        			if (theProductSpec.ccrz__Spec__r.Name == 'ISBN') {
        				if (theProductSpec.ccrz__SpecValue__c != NULL) {
        					ISBN = theProductSpec.ccrz__SpecValue__c;
        				}else{
        					ISBN = '';
        				}
        			}  
        			if (theProductSpec.ccrz__Spec__r.Name == 'Publication Date') {
        				if (theProductSpec.ccrz__SpecValue__c != NULL) {
        					tabPublicationDate = theProductSpec.ccrz__SpecValue__c;
        				}else{
        					tabPublicationDate = '';
        				}
        			}  
        			if (theProductSpec.ccrz__Spec__r.Name == 'Country of Origin') {
        				if (theProductSpec.ccrz__SpecValue__c != NULL) {
        					countryOfOrigin = theProductSpec.ccrz__SpecValue__c;
        				}else{
        					countryOfOrigin = '';
        				}
        			}
        			if (theProductSpec.ccrz__Spec__r.Name == 'Manufacturer Part No') {
        				if (theProductSpec.ccrz__SpecValue__c != NULL) {
        					tabManufacturerPartNumber = theProductSpec.ccrz__SpecValue__c;
        				}else{
        					tabManufacturerPartNumber = '';
        				}
        			}              			      			      			      			        			      			      			    			     			     			     			      			
            	}
            }
            
			customAttributeValueMap = new Map<String, String>{
                'IsCourse'					=>	IsCourse,
                'OMSProductName'			=>	OMSProductName,
                'OMSGroupingCategory'		=>  OMSGroupingCategory,
                'backorderable'				=>	backorderable,
                'costPrice'					=>	costPrice,
                'countryOfOrigin'			=>	countryOfOrigin,
                'dropShipVendor'  			=>	dropShipVendor,
                'isDistributor' 			=>	isDistributor,
                'BulkOrderThreshold' 		=>	BulkOrderThreshold,
                'productType' 				=>	productType,
                'stockingCode'				=>	stockingCode,
                'tabDepth'  				=>	tabDepth,
                'tabHeight'  				=>	tabHeight,
                'tabWidth'      			=>	tabWidth,  
                'tabWeight'       			=>	tabWeight,                              
                'tabManufacturerPartNumber' =>	tabManufacturerPartNumber,
                'tabManufacturer'			=>  tabManufacturer,  
                'tariffCode'   				=>	tariffCode,
                'unitofMeasure'  			=>	unitofMeasure,
                'whsePkgInst' 				=>	whsePkgInst,
                'isDigital'					=>  isDigital,
                'UPC'						=>  UPC,
                'brand'						=>  brand,
                'ISBN'						=>  ISBN,
                'tabPublicationDate'		=>  tabPublicationDate,
                'shelfLife'					=>  shelfLife,
                'shippingCondition'			=>  shippingCondition,
                'LotProcess'				=>  LotProcess
            };          
        }
    }
}