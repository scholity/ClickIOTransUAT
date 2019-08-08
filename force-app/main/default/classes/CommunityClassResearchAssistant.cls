public class CommunityClassResearchAssistant {

    public String opportunityID;
    public String searchTerm;
    public Date startDate;
    public Date endDate;
    public String city;
    public String state;
    
    String trainingClassID;
    
    Map<String, Object> productMap;							// maps a productId to a product
    Map<String, String> productLearningPlanMap;				// maps a productId to a learningPlanId
    Map<String, String> learningPlanObjectMap;				// maps a learningPlanId to a learningObjectId
    Map<String, List<String>> eventLearningMap;				// maps an event learningObjectId to a list of learningObjectIds
    Map<String, String> learningObjectJobMap;				// maps a learningObjectId to a Skedulo jobId
    Map<String, String> jobProductMap;						// maps a Skedulo jobId to a productId
    Map<String, redwing__ILT_Class__c> trainingClassMap;	// maps an iltClassId to an iltClass
    Map<String, sked__Job__c> skeduloJobMap;				// maps a Skedulo jobId to a job
    
    Set<String> searchedProductIdentifiers;					// a set of productIds
    
    public CommunityClassResearchAssistant(String oppId, String term, Date startD, Date endD, String c, String s) {
        opportunityID = oppId;
        searchTerm = term;
        startDate = startD;
        endDate = endD;
        city = c;
        state = s;
    }
    
    public void researchTrainingClass(String classID) {
        trainingClassID = classID;
        
        try {
            validateSearchCriteria();
	        
            searchProducts();
            getProductLearningPlans();
            getLearningPlanObjects();
            getEventLearningObjects();
            getLearningObjectJobs();
            buildJobProducts();
            
            getTrainingClasses();
            getSkeduloJobs();
            
            verifyStorefront();
            
            reportResults();

        } catch (Exception e) {
            System.debug('***  FAILED TO RESEARCH ILT CLASS: ' + e.getMessage());
        }
    }
    
    
    
    /*
     * 
	 */
    
    
    
    private void buildJobProducts() {
        if (productLearningPlanMap == null || productLearningPlanMap.size() == 0
            || learningPlanObjectMap == null || learningPlanObjectMap.size() == 0
            || eventLearningMap == null || eventLearningMap.size() == 0
            || learningObjectJobMap == null || learningObjectJobMap.size() == 0)
        { return; }
        
        jobProductMap = new Map<String, String>();
        for (String productId : productLearningPlanMap.keySet()) {
            Id learningPlanId = productLearningPlanMap.get(productId);
            Id learningObjectId = learningPlanObjectMap.get(learningPlanId);
            List<String> identifierList = (List<String>) eventLearningMap.get(learningObjectId);
            if (identifierList != null) {
                for (String learningId : identifierList) {
                    Id jobId = learningObjectJobMap.get(learningId);
                    if (jobId != null) {
                        jobProductMap.put(jobId, productId);
                    }
                }
            }
        }
    }
    
     private void fetchAndDisplayProducts(Set<String> productIdentifiers) {
        if (productIdentifiers == null || productIdentifiers.size() == 0) { return; }
        
        List<ccrz__E_Product__c> productList = [
            SELECT
            	Id,
            	Name,
            	ccrz__InventoryType__c,
            	ccrz__SKU__c,
            	ccrz__Storefront__c
            FROM ccrz__E_Product__c
            WHERE Id IN :productIdentifiers
            ORDER BY Name
        ];
        
        if (productList == null || productList.size() == 0) { return; }
        
        for (ccrz__E_Product__c product : productList) {
            System.debug('Id=' + product.Id + ' ' + product.Name + ' SKU=' + product.ccrz__SKU__c + ' inventoryType=' + product.ccrz__InventoryType__c + ' storefront=' + product.ccrz__Storefront__c);
        }
    }
    
   private void getEventLearningObjects() {
        if (learningPlanObjectMap == null || learningPlanObjectMap.size() == 0) { return; }
        
        List<redwing__ILT_Event_Class__c> classes = [
            SELECT
            	redwing__ILT_Event__r.redwing__Learning__c,
            	redwing__Learning__c
            FROM redwing__ILT_Event_Class__c
            WHERE redwing__ILT_Event__r.redwing__Learning__c IN :learningPlanObjectMap.values()
            AND redwing__Learning__c != NULL
        ];
        
        if (classes == null || classes.size() == 0) {
            System.debug('.   No ILT Event learning objects were found.');
            return;
        }
        
        eventLearningMap = new Map<String, List<String>>();
        for (redwing__ILT_Event_Class__c eClass : classes) {
            String learningID = eClass.redwing__ILT_Event__r.redwing__Learning__c;
            List<String> identifiers = (List<String>) eventLearningMap.get(learningID);
            if (identifiers == null) {
                identifiers = new List<String>();
                eventLearningMap.put(learningID, identifiers);
            }
            identifiers.add(eClass.redwing__Learning__c);
        }
        System.debug('.   Number of ILT Event learning objects found: ' + eventLearningMap.size());
    }
    
    private void getLearningObjectJobs() {
        if (eventLearningMap == null || eventLearningMap.size() == 0) { return; }
        
        Set<String> learningIdentifiers = new Set<String>();
        for (String learningID : eventLearningMap.keySet()) {
            List<String> identifiers = (List<String>) eventLearningMap.get(learningID);
            learningIdentifiers.addAll(identifiers);
        }
        
        List<redwing__ILT_Class__c> classList = [
            SELECT
            	redwing__Learning__c,
            	Skedulo_Job_Id_External__c
            FROM redwing__ILT_Class__c
            WHERE redwing__Learning__c IN :learningIdentifiers
        ];
        
        if (classList == null || classList.size() == 0) {
            System.debug('.   No ILT Classes were found.');
           	return;
        }
        
        learningObjectJobMap = new Map<String, String>();
        Boolean classWasFound = false;
        for (redwing__ILT_Class__c trainingClass : classList) {
            learningObjectJobMap.put(trainingClass.redwing__Learning__c, trainingClass.Skedulo_Job_Id_External__c);
            
            if (trainingClass.Skedulo_Job_Id_External__c == trainingClassId) {
                classWasFound = true;
            }
        }
        
        if (classWasFound) {
            System.debug('.   ILT CLASS WAS FOUND! [Id=' + trainingClassId + ']');
        } else {
            System.debug('.   ILT CLASS NOT FOUND!');
        }
    }
    
    private void getLearningPlanObjects() {
        if (productLearningPlanMap == null || productLearningPlanMap.size() == 0) { return; }
        
        List<redwing__Training_Plan_Section_Item__c> items = [
            SELECT
            	redwing__Learning__c,
            	redwing__Training_Plan_Section__r.redwing__Training_Plan__c
            FROM redwing__Training_Plan_Section_Item__c
            WHERE redwing__Training_Plan_Section__r.redwing__Training_Plan__c IN :productLearningPlanMap.values()
            AND redwing__Learning__r.RecordType.Name = 'ILT EVENT'
        ];
        
        if (items == null || items.size() == 0) {
            System.debug('.   No learning objects were found.');
            return;
        }
        
        learningPlanObjectMap = new Map<String, String>();
        for (redwing__Training_Plan_Section_Item__c item : items) {
            learningPlanObjectMap.put(item.redwing__Training_Plan_Section__r.redwing__Training_Plan__c, item.redwing__Learning__c);
        }
        System.debug('.   Number of learning objects found: ' + learningPlanObjectMap.size());
    }
    
    private void getProductLearningPlans() {
        if (productMap == null || productMap.keySet().size() == 0) { return; }
        
        List<ccrz__E_Product__c> productList = [
            SELECT
            	Id,
            	LMS_Learning_Plan__c
            FROM ccrz__E_Product__c
            WHERE Id IN :productMap.keySet()
        ];
        
        if (productList == null || productList.size() == 0) {
            throw new phss_cc_Exception('no learning plans were found');
        }
        
        productLearningPlanMap = new Map<String, String>();
        for (ccrz__E_Product__c product : productList) {
            productLearningPlanMap.put(product.Id, product.LMS_Learning_Plan__c);
        }
        
        Integer learningPlanCount = productLearningPlanMap.size();
        Integer productCount = productMap.size();
        if (learningPlanCount == productCount) {
            System.debug('.   Found ALL learning plans for products (' + learningPlanCount + ' of ' + productCount + ')');
        } else if (learningPlanCount < productCount) {
            System.debug('.   Not all products have an associated learning plan (missing ' + (productCount - learningPlanCount) + ' of ' + productCount + ').');
        }
    }
    
    private void getSkeduloJobs() {
        if (trainingClassMap == null || trainingClassMap.size() == 0) { return; }
        
        List<sked__Job__c> jobList = [
            SELECT
            	Id,
            	Job_Month__c,
            	Location_Name__c,
            	Name,
            	Number_of_Students__c,
            	sked__Address__c,
            	sked__Duration__c,
            	sked__Location__r.sked__GeoLocation__c,
            	sked__Start__c,
            	sked__Timezone__c
            FROM sked__Job__c
            WHERE Id IN :jobProductMap.keySet()
        ];
        
        if (jobList == null || jobList.size() == 0) {
            throw new phss_cc_Exception('no Skedulo jobs were found for the job IDs');
        }
        
        System.debug('.   Number of Skedulo jobs found: ' + jobList.size());
        skeduloJobMap = new Map<String, sked__Job__c>(jobList);
    }
    
    private void getTrainingClasses() {
        if (jobProductMap == null || jobProductMap.size() == 0) { return; }
        
        List<redwing__ILT_Class__c> classList = [
            SELECT
            	Id,
            	Name,
            	redwing__End_Date__c,
            	redwing__End_Time__c,
            	redwing__Max_Seats__c,
            	redwing__Start_Date__c,
            	redwing__Start_Time__c,
            	Skedulo_Job_Id_External__c,
            	Price_Override__c
            FROM redwing__ILT_Class__c
            WHERE Skedulo_Job_Id_External__c IN :jobProductMap.keySet()
            AND redwing__Start_Date__c >= :startDate
            AND redwing__Start_Date__c <= :endDate
            ORDER BY redwing__Start_Date__c
        ];
        
        if (classList == null || classList.size() == 0) {
            System.debug('.   No ILT classes found for Skedulo job IDs between ' + startDate + ' and ' + endDate);
            return;
        }
        
        System.debug('.   Number of ILT classes found for Skedulo job IDs (count=' + jobProductMap.size() + ') between ' + startDate + ' and ' + endDate + ': ' + classList.size());
        trainingClassMap = new Map<String, redwing__ILT_Class__c>(classList);
    }
    
    private void reportResults() {
        if (searchedProductIdentifiers != null) {
            System.debug('PRODUCTS FOUND FROM INITIAL SEARCH: ' + searchedProductIdentifiers.size());
            fetchAndDisplayProducts(searchedProductIdentifiers);
        }
        
        if (productMap != null) {
            System.debug('PRODUCTS FOUND: ' + productMap.size());
            for (String productId : productMap.keySet()) {
                Map<String, Object> product = (Map<String, Object>) productMap.get(productId);
                System.debug('Id=' + productId + ' Name=' + product.get('sfdcName') + ' (SKU=' + product.get('SKU') + ')');
//                for (String k : product.keySet()) {
//                    System.debug('k=' + k + ' v=' + product.get(k));
//                }
                System.debug(product);
                System.debug('- - - - - - - - - -');
            }
        }
        
        if (trainingClassMap != null) {
            System.debug('ILT CLASSES FOUND: ' + trainingClassMap.size());
            for (String classId : trainingClassMap.keySet()) {
                redwing__ILT_Class__c trainingClass = trainingClassMap.get(classId);
                System.debug('Id=' + classId + ' Name=' + trainingClass.Name);
                System.debug(trainingClass);
                System.debug('- - - - - - - - - -');
            }
        }
        
        if (skeduloJobMap != null) {
            System.debug('SKEDULO JOBS FOUND: ' + skeduloJobMap.size());
            for (String jobId : skeduloJobMap.keySet()) {
                sked__Job__c job = skeduloJobMap.get(jobId);
                System.debug('Id=' + jobId + ' Name=' + job.Name);
                System.debug(job);
                System.debug('- - - - - - - - - -');
            }
        }
    }
    
    private void searchProducts() {
        Map<String, Object> searchResult = phss_cc_ProductUtil.productSearch(opportunityID, searchTerm);
        if (searchResult == null || searchResult.get('productMap') == null) {
            System.debug('.   There were no products found that match the search term: ' + searchTerm);
            return;
        }
        
        Map<String, Object> products = (Map<String, Object>) searchResult.get('productMap');
        System.debug('.   Number of products that match the search term: ' + products.size());
        
        searchedProductIdentifiers = products.keySet();

        productMap = new Map<String, Object>();
        for (String id : products.keySet()) {
            Map<String, Object> product = (Map<String, Object>) products.get(id);
            if (product.get('inventoryType') == 'COMMUNITY') {
                productMap.put((String) product.get('sfid'), product);
            }
        }
        System.debug('.   Number of products with inventoryType=COMMUNITY: ' + productMap.size());
    }

    private void validateSearchCriteria() {
        if (String.isEmpty(opportunityID)) { throw new phss_cc_Exception('missing opportunity ID'); }
        if (String.isEmpty(searchTerm)) { throw new phss_cc_Exception('missing search term'); }
        if (startDate == null) { throw new phss_cc_Exception('missing start date'); }
        if (endDate == null) { throw new phss_cc_Exception('missing end date'); }
        if (startDate > endDate) { throw new phss_cc_Exception('startDate cannot occur after endDate'); }
        if (String.isEmpty(city)) { throw new phss_cc_Exception('missing city'); }
        if (String.isEmpty(state)) { throw new phss_cc_Exception('missing state'); }
    }
    
    private void verifyStorefront() {
        String opportunityStorefront = phss_cc_Context.getStoreFrontName(opportunityID);
        
        List<redwing__ILT_Class__c> classes = [
            SELECT
            	Id,
            	Name,
            	Cloud_Craze_Product__r.ccrz__Storefront__c
            FROM redwing__ILT_Class__c
            WHERE Id = :trainingClassID
        ];
        
        if (classes == null || classes.size() == 0) {
            throw new phss_cc_Exception('Failed to fetch ILT Class for Id: ' + trainingClassID);
        }
        
        String productStorefront = classes[0].Cloud_Craze_Product__r.ccrz__Storefront__c;
        
        if (productStorefront.contains(opportunityStorefront)) {
            System.debug('The storefront name matches the opportunity\'s source system: ' + opportunityStorefront);
        } else {
            String errorMessage = 'The storefront name derived from the opportunity (' + opportunityStorefront + ') DOES NOT MATCH the product\'s storefront (' + productStorefront + ')';
            throw new phss_cc_Exception(errorMessage);
        }
    }
}