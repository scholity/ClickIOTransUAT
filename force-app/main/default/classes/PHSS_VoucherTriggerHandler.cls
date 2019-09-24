/************************************************************************************************************************************
** Author: Salesforce Services
** Description: This is the trigger handler class for the voucher trigger
************************************************************************************************************************************/
public class PHSS_VoucherTriggerHandler {
    public PHSS_VoucherTriggerHandler(){}
    // Static variables are local to the context of a Web request 
    // (or testMethod during a runTests call) 
    // Therefore, this variable will be initialized as false 
    // at the beginning of each Web request which accesses it.
    private static boolean alreadyUpdatedVouchers = false;
    public static boolean hasAlreadyUpdatedVouchers() {
        return alreadyUpdatedVouchers;
    }
    // By setting the variable to true, it maintains this 
    // new value throughout the duration of the request
    public static void setAlreadyUpdatedVouchers() {
        alreadyUpdatedVouchers = true;
    }
    /************************************************************************************************************************************
    ** Author: Salesforce Services
    ** Description: This method is used to insure there are a minimum number of open (Issued) vouchers for an online class
    ** It uses a floor and ceiling of 5 and 10 by default (insure that there are at least 10 open vouchers when the total drops below 5)
    ************************************************************************************************************************************/
    public void CheckTotalAvailableOnlineVouchers(list<Voucher__c> newVouchers, List<Voucher__c> oldVouchers, Map<ID,Voucher__c> newVoucherMap , Map<ID,Voucher__c> oldVoucherMap){
        Integer voucherFloor = 5;
        Integer voucherCeiling = 10;
        
        Set<id> onlineClasses = new Set<id>();
        Map<Id, Id> classLearningPlan = new Map<Id,Id>();
        Map<Id, Integer> classIssuedVouchers = new Map<Id, Integer>();
        List<Voucher__c> addVouchers = new List<Voucher__c>();
        
        //find out the vouchers which have a status change away from 'Issued'
        for(Voucher__c vcr : newVouchers){
            if (oldVouchers != null && !oldVouchers.isEmpty()) {
                //check the status in old map and new map to identify the change in voucher status
                if (oldVoucherMap.get(vcr.id).status__c == 'Issued' &&
                        newVoucherMap.get(vcr.id).status__c != oldVoucherMap.get(vcr.id).status__c) {
                    // Vouchers for Online Classes will have Online_Class__c lookup populated (ILT Class vouchers will not)
                    if (vcr.Online_Class__c != null) {
                        classLearningPlan.put(vcr.Online_Class__c, vcr.Learning_Plan__c);
                        onlineClasses.add(vcr.Online_Class__c);
                        classIssuedVouchers.put(vcr.Online_Class__c, 0); // Covers case in which no Issued vouchers remain
                    }
                }
            } else {
                // this handles insert of new voucher - insure number of Issued vouchers is at the high water mark
                if (vcr.Online_Class__c != null) {
                    classLearningPlan.put(vcr.Online_Class__c, vcr.Learning_Plan__c);
                    onlineClasses.add(vcr.Online_Class__c);
                    classIssuedVouchers.put(vcr.Online_Class__c, 0); // Covers case in which no Issued vouchers remain
                }
            }
        }
        System.debug('classLearningPlan='+classLearningPlan);
        System.debug('onlineClasses='+onlineClasses);
        
        if (!onlineClasses.isEmpty()) {
            // Determine the total number of available (Issued) vouchers for each online class impacted by voucher status changes
            List<AggregateResult> issuedVoucherCounts = [
                    Select Online_Class__c, Count(Id) vCount
                    From Voucher__c
                    Where Online_Class__c In :onlineClasses And Status__c = 'Issued'
                    Group by Online_Class__c
            ];
            System.debug('issuedVoucherCounts=' + issuedVoucherCounts);

            For (AggregateResult theCount : issuedVoucherCounts) {
                Integer classIssuedVoucherCount = (Integer) theCount.get('vCount');
                Id theOnlineClass = (Id) theCount.get('Online_Class__c');
                System.debug('classIssuedVoucherCount=' + classIssuedVoucherCount);

                classIssuedVouchers.put(theOnlineClass, classIssuedVoucherCount);
            }

            For (Id theOnlineClass : classIssuedVouchers.keySet()) {
                Integer classIssuedVoucherCount = classIssuedVouchers.get(theOnlineClass);
                // Determine if number of Issued vouchers for each online class is below lower limit
                if (classIssuedVoucherCount < voucherFloor) {
                    Id theLearningPlan = classLearningPlan.get(theOnlineClass);
                    // Generate additional vouchers to bring the total Issued vouchers up to the defined upper limit
                    addVouchers.addAll(createVouchers(theOnlineClass, theLearningPlan, voucherCeiling - classIssuedVoucherCount));
                }
            }

            if (!addVouchers.isEmpty()) {
                insert addVouchers;
            }
        }
    }
	
	private List<Voucher__c> createVouchers(Id onlineClassId, Id learningPlanId, Integer numberOfVouchers) {
		List<Voucher__c> newVouchers = new List<Voucher__c>();
		
		if (numberOfVouchers > 0) {
			for (Integer n=numberOfVouchers; n>0; n--) {
				Voucher__c theNewVoucher = new Voucher__c();
				theNewVoucher.Status__c = 'Issued';
				theNewVoucher.Online_Class__c = onlineClassId;
				theNewVoucher.Learning_Plan__c = learningPlanId;
				newVouchers.add(theNewVoucher);
			}
		}
		System.debug('newVouchers='+newVouchers);
		return newVouchers;
	}

    /************************************************************************************************************************************
    ** Author: Salesforce Services
    ** Description: This method to block the issued vouchers for load balancing and vice versa
    ************************************************************************************************************************************/
    public void BlockIssuedVouchersAndIssueBlockedVouchers(list<Voucher__c> newVouchers, List<Voucher__c> oldVouchers, Map<ID,Voucher__c> newVoucherMap , Map<ID,Voucher__c> oldVoucherMap){
        set<id> setUpdatedVoucherClassIds = new set<id>();
        // Determine which vouchers have a change in status
        for(Voucher__c vcr : newVouchers){
            // Check the status in old map and new map to identify the change in voucher status
            if(newVoucherMap.get(vcr.id).status__c != oldVoucherMap.get(vcr.id).status__c){
                // Vouchers for ILT Classes will have ILT_Class__c lookup populated (online vouchers will not)
                if (vcr.ILT_Class__c != null) setUpdatedVoucherClassIds.add(vcr.ILT_Class__c);   
            }
            
        } 
        
        // Continue with the trigger if is any change in voucher status
        if(!setUpdatedVoucherClassIds.isEmpty()){
            list<redwing__ILT_Class__c> lstStackedClasses = new list<redwing__ILT_Class__c>();
            set<id> setParentJobIds = new set<id>();
            set<id> setJobIds = new set<id>();
            // Collect the parent job ids for all the stacked classes for which a change in voucher status has been received
            // Note: Apex class SkedJobtoILTClass populates parent Skedulo job id field for the parent job with its own job Id
            // This is assumed and required in the logic below which determines group of related stacked classes which share a common parent job id
            for(redwing__ILT_Class__c iltClass : [select id,Skedulo_Parent_Job__c,Skedulo_Job_Id__c,Is_Stacked_Class__c from redwing__ILT_Class__c where Is_Stacked_Class__c=true and id IN: setUpdatedVoucherClassIds]){
                if (iltClass.Skedulo_Parent_Job__c != null) setParentJobIds.add(iltClass.Skedulo_Parent_Job__c); 
                if (iltClass.Skedulo_Job_Id__c != null) setJobIds.add(iltClass.Skedulo_Job_Id__c);    
            }
            System.debug('++setJobIds='+setJobIds);
            System.debug('++setParentJobIds='+setParentJobIds);
            
            // Obtain set of classes related to every parentid and put them in map
            if(!setParentJobIds.isEmpty()){
                map<id,list<redwing__ILT_Class__c>> mapStackedParentJobIdToListClasses = new map<id,list<redwing__ILT_Class__c>>();
                map<id,integer> mapStackedParentWithMinMaxNoOfStudents = new map<id,integer>();
                for(redwing__ILT_Class__c iltClass : [select id,Skedulo_Parent_Job__c,Skedulo_Job_Id__c,Is_Stacked_Class__c,redwing__Max_Seats__c,Cloud_Craze_Product__c,Cloud_Craze_Product__r.Course_Catalog__c,Cloud_Craze_Product__r.Course_Catalog__r.Number_of_Students__c from redwing__ILT_Class__c where Skedulo_Parent_Job__c IN: setParentJobIds]){
                    lstStackedClasses.add(iltClass);
                    if(mapStackedParentJobIdToListClasses.containsKey(iltClass.Skedulo_Parent_Job__c)){
                        list<redwing__ILT_Class__c> existinglstcls = mapStackedParentJobIdToListClasses.get(iltClass.Skedulo_Parent_Job__c);
                        existinglstcls.add(iltClass);    
                        mapStackedParentJobIdToListClasses.put(iltClass.Skedulo_Parent_Job__c,existinglstcls);
                    } else {
                        list<redwing__ILT_Class__c> lstcls = new list<redwing__ILT_Class__c>();
                        lstcls.add(iltClass);
                        mapStackedParentJobIdToListClasses.put(iltClass.Skedulo_Parent_Job__c,lstcls);
                    }
                } 
                System.debug('mapStackedParentJobIdToListClasses='+mapStackedParentJobIdToListClasses);
                
                map<id,integer> mapStackedParentIdWithNoOfClaimedVouchers = new map<id,integer>();
                map<id,integer> mapJobWithNoOfClaimedVouchers = new map<id,integer>();
                map<id,integer> mapStackedPArentIdWithMinNoOfStudents = new map<id,integer>();
                list<string> ClaimedStatuses = system.label.ClaimedVoucherTypes.split(';');
                
                // Count the number of claimed vouchers for every stacked job
                list<voucher__c> lstvchrs = [select id, status__c, User__c, ILT_Class__r.Skedulo_Job_Id__c, ILT_Class__r.Skedulo_Parent_Job__c from voucher__c where ILT_Class__r.Skedulo_Parent_Job__c IN :setParentJobIds];
                System.debug('+++lstvchrs='+lstvchrs);
                for(voucher__c ar : lstvchrs){
                    if(ClaimedStatuses.contains(ar.status__c)){
                    	if (ar.ILT_Class__r.Skedulo_Parent_Job__c != null) {
	                        if(mapStackedParentIdWithNoOfClaimedVouchers.containskey(ar.ILT_Class__r.Skedulo_Parent_Job__c)){
	                           integer i = mapStackedParentIdWithNoOfClaimedVouchers.get(ar.ILT_Class__r.Skedulo_Parent_Job__c)+1;
	                           mapStackedParentIdWithNoOfClaimedVouchers.put(ar.ILT_Class__r.Skedulo_Parent_Job__c,i);
	                        } else{
	                           mapStackedParentIdWithNoOfClaimedVouchers.put(ar.ILT_Class__r.Skedulo_Parent_Job__c,1); 
	                        }  
                    	}
                    }   
                }
                
                // Determine minimum maximum no of students for the stacked classes for every parent job id
                for(id theParentJobId : setParentJobIds){
                    for(redwing__ILT_Class__c iltClass : mapStackedParentJobIdToListClasses.get(theParentJobId)){
                    	if(iltClass.Skedulo_Parent_Job__c != null) {
	                        if(mapStackedParentIdWithMinNoOfStudents.containskey(iltClass.Skedulo_Parent_Job__c)){
	                            if(mapStackedParentIdWithMinNoOfStudents.get(iltClass.Skedulo_Parent_Job__c) > iltClass.redwing__Max_Seats__c){  
	                                mapStackedParentIdWithMinNoOfStudents.put(iltClass.Skedulo_Parent_Job__c,integer.valueOf(iltClass.redwing__Max_Seats__c));
	                            }
	                        }  else{
	                        	// Note: iltClass.redwing__Max_Seats__c *should* contain value of Cloud_Craze_Product__r.Course_Catalog__r.Number_of_Students__c when record is created
	                            mapStackedParentIdWithMinNoOfStudents.put(iltClass.Skedulo_Parent_Job__c,integer.valueOf(iltClass.redwing__Max_Seats__c));
	                        }  
                    	}
                    }
                }           
                
                set<id> OversoldParentJobIds = new set<id>();
                set<id> UndersoldParentJobIds = new set<id>();               
                map<id, integer> numberOfRemainingSeatsToSell = new map<id, integer>();    
                    
                // Calculate number of open seats per stacked class remaining to sell                             
                // Determine whether minimum no of maximum students is greater than number of claimed vouchers
                // Note: Insure that each class in stack has no more open vouchers than the current number of open seats 
                for(id theParentJobId : setParentJobIds){
                	Integer maxSizeOfClass = 0;
                	Integer numberOfSeatsSold = 0;
                	numberOfRemainingSeatsToSell.put(theParentJobId, 0);
                	
                	if (mapStackedParentIdWithMinNoOfStudents.containsKey(theParentJobId) &&
                		mapStackedParentIdWithNoOfClaimedVouchers.containsKey(theParentJobId)) { 
                			               	
	                	maxSizeOfClass = mapStackedParentIdWithMinNoOfStudents.get(theParentJobId);
	                	numberOfSeatsSold = mapStackedParentIdWithNoOfClaimedVouchers.get(theParentJobId);
	                	
	                	Integer numberOfSeatsOpen = maxSizeOfClass - numberOfSeatsSold;
	                	numberOfRemainingSeatsToSell.put(theParentJobId, numberOfSeatsOpen);
	                	
	                    if(maxSizeOfClass <= numberOfSeatsSold){
	 						// Class is oversold - block all remaining vouchers for all classes in stack                     	
	                        OversoldParentJobIds.add(theParentJobId); 
	                    } else {
	                    	// Class is undersold (open) - insure that the number of vouchers open (Issued) for each class in stack
	                    	// does not exceed number of seats left to sell
	                        UndersoldParentJobIds.add(theParentJobId);
	                    }
                	}
                }
                system.debug('Minimum Students = '+ mapStackedParentIdWithMinNoOfStudents );
                system.debug('Minimum Vouchers = '+ mapStackedParentIdWithNoOfClaimedVouchers );
                
                // Update ILT Class records for each member of stack with number of open seats in the stack
                list<redwing__ILT_Class__c> lstClassesToUpdate = new list<redwing__ILT_Class__c>();
                map<id, integer> lstClassOpenSeats = new map<id, integer>();
                
                for (redwing__ILT_Class__c theClass : lstStackedClasses) {
                	if (theClass.Skedulo_Parent_Job__c != null) {
	                	redwing__ILT_Class__c theUpdatedClass = new redwing__ILT_Class__c();
	                	theUpdatedClass.Id = theClass.Id;                		              		
                		theUpdatedClass.Available_Seats__c = numberOfRemainingSeatsToSell.get(theClass.Skedulo_Parent_Job__c);
                		lstClassesToUpdate.add(theUpdatedClass);  
                		
                		lstClassOpenSeats.put(theClass.Id, numberOfRemainingSeatsToSell.get(theClass.Skedulo_Parent_Job__c));                 		              		
                	}
                }
                
                list<voucher__c> lstVouchersToUpdate = new list<voucher__c>();
                for(voucher__c vcr : lstvchrs){	
                    if ((vcr.Status__c =='Issued' || vcr.Status__c =='Blocked' || vcr.Status__c == 'Void') && String.isBlank(vcr.User__c)) {
                    	if (vcr.ILT_Class__c != null && vcr.ILT_Class__r.Skedulo_Parent_Job__c != null) {
	                		// Block the remaining vouchers (Issued) for each oversold class in stack                     	
	                        if(OversoldParentJobIds.contains(vcr.ILT_Class__r.Skedulo_Parent_Job__c) && vcr.status__c =='Issued'){
			                	voucher__c theUpdatedVoucher = new voucher__c();
			                	theUpdatedVoucher.Id = vcr.Id;	                        	
//	                            theUpdatedVoucher.status__c = 'Blocked';
                                theUpdatedVoucher.status__c = 'Void';
	                            lstVouchersToUpdate.add(theUpdatedVoucher);
	                        }    
	                        // Open up vouchers to the max remaining number of seats to sell, block all others
	                        if(UndersoldParentJobIds.contains(vcr.ILT_Class__r.Skedulo_Parent_Job__c)) {  
	                        	// Get number of seats remaining to sell for this class (this will be decremented destructively)
	                        	Integer classOpenSeats = lstClassOpenSeats.get(vcr.ILT_Class__c);	 
                    	
	                        	// If at least one, and this voucher is blocked, then reset to issued (else leave in blocked status)
	                        	// If none, and this voucher is open (Issued), then reset to blocked (else leave in issued status)
	                        	if (classOpenSeats > 0 && (vcr.status__c =='Blocked' || vcr.status__c == 'Void')){
				                	voucher__c theUpdatedVoucher = new voucher__c();
				                	theUpdatedVoucher.Id = vcr.Id;	                        	
		                            theUpdatedVoucher.status__c = 'Issued'; 
		                            lstVouchersToUpdate.add(theUpdatedVoucher);		                        		                        		
	                        	} else if (classOpenSeats <= 0 && vcr.status__c =='Issued'){
				                	voucher__c theUpdatedVoucher = new voucher__c();
				                	theUpdatedVoucher.Id = vcr.Id;	 	                        		
//		                            theUpdatedVoucher.status__c = 'Blocked';
		                            theUpdatedVoucher.status__c = 'Void';
		                            lstVouchersToUpdate.add(theUpdatedVoucher);
	                        	}
		                        if (classOpenSeats > 0) lstClassOpenSeats.put(vcr.ILT_Class__c, --classOpenSeats);	                        	
	                        }   
                    	}
                    }  
                }
                //set the flag to true so that it will not call recursively
                PHSS_VoucherTriggerHandler.setAlreadyUpdatedVouchers();
                
                try {
	                if(!lstVouchersToUpdate.isEmpty()){
	                    update lstVouchersToUpdate; 
	                }
	                if(!lstClassesToUpdate.isEmpty()) {
	                	update lstClassesToUpdate;
	                }
                } catch (Exception e) {
                	
                }
            }
        }
    }

    /************************************************************************************************************************************
    ** Author: Salesforce Services
    ** Description: This method sets the max size and available seats for classes after vouchers are updated
    ************************************************************************************************************************************/
    public void adjustAvailableSeats(list<Voucher__c> newVouchers, List<Voucher__c> oldVouchers, Map<ID,Voucher__c> newVoucherMap , Map<ID,Voucher__c> oldVoucherMap) {
        system.debug('Adjusting available seats');
        set<id> ILT_classes = new set<id>();
        // Get the classes for each changed voucher
        for (Voucher__c vcr : newVouchers) {
            // Check the status in old map and new map to identify the change in voucher status
            if (newVoucherMap.get(vcr.id).status__c != oldVoucherMap.get(vcr.id).status__c) {
                // Filter changed classes so that we only have non-stacked classes
                if (vcr.ILT_Class__c != null && vcr.ILT_Class__r.Skedulo_Parent_Job__c == null) {
                    ILT_classes.add(vcr.ILT_Class__c);
                }
            }

        }
        system.debug('Set of changed classes: ' + ILT_classes);
        if (!ILT_classes.isEmpty()) {

            Map<Id,Integer> mapMaxClassSize = new map<Id,Integer>();
            // DE1755 - No need to calculate the max seats in a class; this is a static value set at class level
            List<Voucher__c> voucherList = [SELECT ILT_Class__c, ILT_Class__r.redwing__Max_Seats__c
                FROM Voucher__c
                WHERE ILT_Class__c IN: ILT_classes];
            //List<AggregateResult> iltAggregateResults = [select ILT_Class__c, count(Id) maxSize from Voucher__c where (Status__c = 'Claimed' or Status__c = 'Issued') and ILT_Class__c IN: ILT_classes group by ILT_Class__c];

            for (Voucher__c result : voucherList) {
            //for (AggregateResult result : iltAggregateResults) {
                mapMaxClassSize.put(result.ILT_Class__c, (Integer)result.ILT_Class__r.redwing__Max_Seats__c);
                //mapMaxClassSize.put((Id) result.get('ILT_Class__c'), (Integer) result.get('maxSize'));
                System.debug('Max size for '+ result.ILT_Class__c + ': ' + (Integer) result.ILT_Class__r.redwing__Max_Seats__c);
            }
            Map<Id,Integer> mapSeatsClaimed = new Map<Id,Integer>();
            List<AggregateResult> iltAggregateResults = [SELECT ILT_Class__c, COUNT(Id) claimedSeats
                FROM Voucher__c
                WHERE (Status__c = 'Claimed' or Status__c = 'Reserved' OR Status__c = 'Temp Hold')
                AND ILT_Class__c IN: ILT_classes GROUP BY ILT_Class__c];
            for (AggregateResult result : iltAggregateResults) {
                mapSeatsClaimed.put((Id) result.get('ILT_Class__c'), (Integer) result.get('claimedSeats'));
                System.debug('claimedSeats for '+ (Id) result.get('ILT_Class__c') + ': ' + (Integer) result.get('claimedSeats'));
            }
            List<redwing__ILT_Class__c> updateClasses = new List<redwing__ILT_Class__c>();
            for (Id id : ILT_classes) {
                Integer maxSize = mapMaxClassSize.get(id);
                if (maxSize != null && mapSeatsClaimed.get(id) != null) {
                    redwing__ILT_Class__c classUpdate = new redwing__ILT_Class__c();
                    classUpdate.Id = id;
                    // DE1755 - No need to update max seats; this is a static value set at class level
                    //classUpdate.redwing__Max_Seats__c = maxSize;
                    classUpdate.Available_Seats__c = maxSize - mapSeatsClaimed.get(id);
                    updateClasses.add(classUpdate);

                }
            }
            if(!updateClasses.isEmpty()){
                update updateClasses;
            }

        }
    }

    /**
     *@description Resets vouchers associated to abandoned cart items
     *
     * @param newVouchers
     * @param oldVouchers
     * @param newVoucherMap
     * @param oldVoucherMap
     */
    public void resetAbandonedVouchers(List<Voucher__c> newVouchers, List<Voucher__c> oldVouchers, Map<Id,Voucher__c> newVoucherMap , Map<Id,Voucher__c> oldVoucherMap) {
        List<Voucher__c> abandonedVouchers = new List<Voucher__c>();

        // Identify vouchers that are associated with abandoned carts
        for (Voucher__c newVoucher : newVouchers) {
            Voucher__c oldVoucher = oldVoucherMap.get(newVoucher.Id);
            if (oldVoucher != null) {
                if (oldVoucher.Status__c == phss_cc_VoucherUtil.TEMP_HOLD_STATUS && newVoucher.Status__c == phss_cc_VoucherUtil.ISSUED_STATUS) {
                    if (newVoucher.CC_Cart_Item__c != null) {
                        newVoucher.CC_Cart_Item__c = null;
                        abandonedVouchers.add(newVoucher);
                    }
                }
            }
        }

        try {
            if (!abandonedVouchers.isEmpty()){

                // Set the flag to true so that it will not call recursively
                PHSS_VoucherTriggerHandler.setAlreadyUpdatedVouchers();
                update abandonedVouchers;
            }
        } catch (Exception e) {
            System.debug('JASON: PHSS_VoucherTriggerHandler.resetAbandonedVouchers() exception caught: ' + e.getMessage() + ' lineNumber=' + e.getLineNumber() + ' stackTrace=' + e.getStackTraceString());
        }
    }
}