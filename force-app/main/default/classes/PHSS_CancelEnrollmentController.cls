public without sharing class PHSS_CancelEnrollmentController {
    public Static String keyPrefixlrnas;
    public Static String keyPrefixroster;
	public Static String keyPrefixvoucher;

    @AuraEnabled
    public static String checkIfCancelled(String recId) {
    
      // Get the value of Learning Assignment prefix (for cancellation of Online Class from Learning Assignment)
        Schema.DescribeSObjectResult r = redwing__Learning_Assignment__c.sObjectType.getDescribe();
        keyPrefixlrnas = r.getKeyPrefix();
        System.debug('Value of roster id' + keyPrefixlrnas );
        
      // Get the value of Roster id prefix  (for cancellation of ILT and Blended Classes from a roster record)
        Schema.DescribeSObjectResult l = redwing__ILT_Roster__c.sObjectType.getDescribe();
        keyPrefixroster = l.getKeyPrefix();
        System.debug('Value of learning assignment id' + keyPrefixroster );
        

        if(recId.startsWith(keyPrefixroster)){
        List<redwing__ILT_Roster__c> rosterList = [Select Id,redwing__Status__c 
                                                   From redwing__ILT_Roster__c 
                                                   Where Id = :recId];
        
        return rosterList[0].redwing__Status__c;
         
         }

        else if(recId.startsWith(keyPrefixlrnas)){
             List<redwing__Learning_Assignment__c> assignList = [Select Id,redwing__Approval_Status__c 
                                                            From redwing__Learning_Assignment__c 
                                                            Where Id = :recId];
        
        return assignList[0].redwing__Approval_Status__c;
        }
        else
        {
            return 'testString';
        }
    }



	// This method invokes the student cancellation logic using a Roster Id
	// Student registration is cancelled in the LMS only; the financial side of the transaction is not managed here
    @AuraEnabled
    public static void cancelEnrollment(String recId, String cancelReason) {
        //fGet the value of learning assignment prefix
        Schema.DescribeSObjectResult l = redwing__Learning_Assignment__c.sObjectType.getDescribe();
        keyPrefixlrnas = l.getKeyPrefix();
        
        //Get the value of roster prefix
        Schema.DescribeSObjectResult r = redwing__ILT_Roster__c.sObjectType.getDescribe();
        keyPrefixroster = r.getKeyPrefix();

        if(recId.startsWith(keyPrefixroster)) {
            List<redwing__ILT_Roster__c> rosterList = [Select Id,redwing__User__c,redwing__Learning_Assignment__c,redwing__ILT_Class__c 
                                                   From redwing__ILT_Roster__c 
                                                   Where Id = :recId];
        
	        // DE822 - Prevent Learning Assignments from being deleted - these are master-detail on roster records
	        // which are required in order for an email to be generated to student
	        
	        List<redwing__Learning_Assignment__c> LearningAssignmentList = [Select Id,redwing__User__c,redwing__Training_Plan__c, redwing__Progress__c
	                                                            From redwing__Learning_Assignment__c 
	                                                            Where Id = :rosterList[0].redwing__Learning_Assignment__c];
	        
	        
	        // Remove Learning Plan Assignments
	        List<redwing__Training_Plan_Assignment__c> LearningPlanAssignmentList = [Select Id,redwing__User__c 
	                                                                     From redwing__Training_Plan_Assignment__c 
	                                                                     Where redwing__User__c = :rosterList[0].redwing__User__c AND 
	                                                                           redwing__Training_Plan__c = :LearningAssignmentList[0].redwing__Training_Plan__c];
	        
	        
	        // Remove Learning Plan Section Assignments
	        /*
	        List<redwing__Training_Plan_Section_Assignment__c> LearningPlanSectionAssignmentList = [SELECT Id,redwing__User__c 
	                                                                                              FROM redwing__Training_Plan_Section_Assignment__c
	                                                                                             WHERE redwing__User__c = :rosterList[0].redwing__User__c AND
	                                                                                             redwing__Training_Plan_Assignment__c =:LearningPlanAssignmentList[0].id];
	        */
	        
	        // Get Learning Plan Achievements
	        List<redwing__Training_Plan_Achievement__c> LearningPlanAchievementList = [Select Id,redwing__Training_Plan__c 
	                                                                            From redwing__Training_Plan_Achievement__c 
	                                                                            Where redwing__Training_Plan__c = :LearningAssignmentList[0].redwing__Training_Plan__c];
	        
	        // Remove Achievement assignments
	        List<redwing__Achievement_Assignment__c> AchievementAssignmentList = [Select Id,redwing__User__c 
	                                                                      From redwing__Achievement_Assignment__c 
	                                                                      Where redwing__User__c = :rosterList[0].redwing__User__c AND 
	                                                                            redwing__Training_Plan_Achievement__c IN :LearningPlanAchievementList];
	        
	        // Release voucher - empty student specific fields, status to 'issued'  
	        List<Voucher__c> voucherList = [Select Id From Voucher__c Where User__c = :rosterList[0].redwing__User__c AND 
	                                                                      Learning_Plan__c = :LearningAssignmentList[0].redwing__Training_Plan__c AND 
	                                                                      ILT_Class__c = :rosterList[0].redwing__ILT_Class__c];
	        if(!voucherList.isEmpty()) {
	            // Keep voucher on cancel to retain financial information
				Voucher__c updatedVoucher = new Voucher__c();
	            updatedVoucher.Id = voucherList[0].Id;
	            updatedVoucher.Status__c = 'Void';
	            
	            /*	           
	            vouch.User__c = null;
	            vouch.RCO_Order_Id__c = null;
	            vouch.RCO_Reservation_Timestamp__c = null;
	            vouch.CC_Order__c = null;
	            vouch.CC_Product__c = null;
	            vouch.Account__c = null;
	            vouch.CC_Order_Item__c = null;
	            vouch.CC_Cart_Item__c = null;
	            vouch.Opportunity__c = null;
				*/
				
	            update updatedVoucher;
	            
	            // Generate replacement voucher for seat that has just opened in class - this will keep inventory valid
	            Voucher__c newVoucher = new Voucher__c();
	            newVoucher.Status__c = 'Issued';
	            newVoucher.Learning_Plan__c = LearningAssignmentList[0].redwing__Training_Plan__c;
	            newVoucher.ILT_Class__c = rosterList[0].redwing__ILT_Class__c;
	            
	            insert newVoucher;
	        }
	        
	        // update roster record - status 'Cancelled' , status date (new fields)
	               
	        redwing__ILT_Roster__c roster = rosterList[0];
	
	        roster.redwing__Status__c = 'Cancelled';
	        roster.Cancellation_Date__c = System.today();
	        roster.Cancellation_Reason__c = cancelReason;
	        // Retain voucher relationship
			// roster.Voucher_Id__c = null;
	        
	        update roster; 
	        
	        // DE822 - Retain Learning Assignments since these are master-detail on roster records
	        // Note - this only applies to ILT/Blended Classes (Online classes do not have roster records)
	        //delete LearningAssignmentList;  
	              
	        delete LearningPlanAssignmentList;           
	        // Deleting the Learning Plan Assignment also results in the deletion of all Learning Plan Section Assignments   
	        //delete LearningPlanSectionAssignmentList;
	        delete AchievementAssignmentList;

			// US1555 - 'Cancelled' should appear on Roster (Student) list in the Online Work column is the enrollment was cancelled
			redwing__Learning_Assignment__c learningAssignment = LearningAssignmentList[0];
			learningAssignment.redwing__Progress__c = 'Cancelled';
			update learningAssignment;

        }
        
        //for Learning Assignment's record(a3E) - Online course
        else if(recId.startsWith(keyPrefixlrnas)) {
	
	        // Remove Learning Assignment
	        List<redwing__Learning_Assignment__c> LearningAssignmentList = [Select Id,redwing__User__c,redwing__Training_Plan__c 
	                                                            From redwing__Learning_Assignment__c 
	                                                            Where Id = :recId and Learning_Record_Type__c = 'Media'];
	        
	        If(LearningAssignmentList.size()>0) {
	            // Remove Learning Plan Assignments
	            List<redwing__Training_Plan_Assignment__c> LearningPlanAssignmentList = [Select Id,redwing__User__c 
	                                                                         From redwing__Training_Plan_Assignment__c 
	                                                                         Where redwing__User__c = :LearningAssignmentList[0].redwing__User__c AND 
	                                                                         redwing__Training_Plan__c = :LearningAssignmentList[0].redwing__Training_Plan__c];
		        // Remove Learning Plan Section Assignments
		        /*
		        List<redwing__Training_Plan_Section_Assignment__c> LearningPlanSectionAssignmentList = [SELECT Id,redwing__User__c 
		                                                                                              FROM redwing__Training_Plan_Section_Assignment__c
		                                                                                             WHERE redwing__User__c = :LearningAssignmentList[0].redwing__User__c AND
		                                                                                             redwing__Training_Plan_Assignment__c =:LearningPlanAssignmentList[0].id];	                                                                         
	            */
	            
	            // Get Learning Plan Achievements
	            List<redwing__Training_Plan_Achievement__c> LearningPlanAchivementList = [Select Id,redwing__Training_Plan__c 
	                                                                                From redwing__Training_Plan_Achievement__c 
	                                                                                Where redwing__Training_Plan__c = :LearningAssignmentList[0].redwing__Training_Plan__c];
	            
	            // Remove existing Achievement assignments
	            List<redwing__Achievement_Assignment__c> AchievementAssignmentList = [Select Id,redwing__User__c 
	                                                                          From redwing__Achievement_Assignment__c 
	                                                                          Where redwing__User__c = :LearningAssignmentList[0].redwing__User__c AND 
	                                                                          redwing__Training_Plan_Achievement__c IN :LearningPlanAchivementList];
	            
	            delete LearningAssignmentList;        
	            delete LearningPlanAssignmentList; 
	        	// Deleting the Learning Plan Assignment also results in the deletion of all Learning Plan Section Assignments 	            
	            //delete LearningPlanSectionAssignmentList;
	            delete AchievementAssignmentList;            
	        }      
        }       
    }
}