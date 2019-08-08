@isTest
public class PHSS_CancelEnrollmentControllerTest {
    static testmethod void cancelEnrollment() {
    	
        Account a = new Account();
        a.Name='SalesforcetestOrg';
        a.BillingStreet='24 Willie Mays Plaza';
        a.BillingCity='San Francisco';
        a.BillingState='California';
        a.BillingPostalCode='94017';
        a.BillingCountry='USA';
        a.Phone='9934200234'; 
        insert a;

        // Learning
        redwing__Learning__c learning = new redwing__Learning__c();
        learning.Name = 'Test learning';
        learning.redwing__Published__c = true;
        learning.RecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('ILT Event').getRecordTypeId();
        insert learning;
        
        // Object Location
        sked__Location__c objLocation = new sked__Location__c();
        objLocation.Name = 'Test';
        objLocation.sked__Type__c = 'Community';
        objLocation.sked__Address__c = '401 S Monroe St, Little Rock, AR, 72206';
        insert objLocation;

        // Learning Plan
        redwing__Training_Plan__c lPlan = new redwing__Training_Plan__c();
        lPlan.Name = 'Test Plan';
        insert lPlan;
        
        //Create ILT Class Record
        Redwing__ILT_Class__c clsRecord = new Redwing__ILT_Class__c();
        clsRecord.Skedulo_Account__c = a.id;
        clsRecord.redwing__End_Date__c = Date.Parse('12/19/2018');
        clsRecord.redwing__End_Time__c= '13:00';
        clsRecord.redwing__Start_Date__c = Date.Parse('12/19/2018');// Assuming Start date = End date
        clsRecord.redwing__Start_Time__c = '12:00';
        clsRecord.Name = 'Test';
        clsRecord.redwing__Learning__c = learning.Id;
        insert clsRecord;

        //Create ILT Session record
        redwing__ILT_Session__c sessionRecord = new redwing__ILT_Session__c();
        sessionRecord.redwing__ILT_Class__c = clsRecord.Id;
        sessionRecord.Skedulo_Account__c = a.id;
        sessionRecord.Skedulo_Address__c = objLocation.id;
        sessionRecord.redwing__End_Time__c = '20:00';
        sessionRecord.redwing__Date__c = Date.Parse('12/19/2018');
        sessionRecord.redwing__Start_Time__c = '08:00';
        insert sessionRecord; 

        // Learning Plan Assignment
        redwing__Training_Plan_Assignment__c planAssignment = new redwing__Training_Plan_Assignment__c();
        planAssignment.redwing__Training_Plan__c = lPlan.id; // Retrieved learning plan id based on the course selected in page 1
        planAssignment.redwing__User__c = UserInfo.getUserId();
        planAssignment.External_Id__c = 'priyalakshmi.pp@gmail.com';
        insert planAssignment;

        // Learning Assignment
        redwing__Learning_Assignment__c learningAssignment = new redwing__Learning_Assignment__c();
        learningAssignment.redwing__Learning__c = learning.id; // 
        learningAssignment.External_Id__c = 'priyalakshmi.pp@gmail.com'; 
        learningAssignment.redwing__Training_Plan__c = lPlan.Id;
        insert learningAssignment;
		
        redwing__Learning_Assignment__c learningAssignmentupdate = new redwing__Learning_Assignment__c();
        learningAssignmentupdate.id=learningAssignment.id;
        learningAssignmentupdate.redwing__Evaluation_Result__c = 'Passed';
        learningAssignmentupdate.Grade_Reason__c = 'Reason 2'; // Retrieve learning id from page 1
        learningAssignmentupdate.Grade_Additional_Info__c = 'Reason 2'; 
        update learningAssignmentupdate;
        
        // Achievement Category
        redwing__Achievement_Category__c rac = new redwing__Achievement_Category__c();
        rac.name = 'Skill';
        insert rac;
        
        // Achievement
        redwing__Achievement__c ra = new redwing__Achievement__c();
        ra.redwing__Achievement_Category__c = rac.id;
        insert ra;
        
        // Learning Plan Acheivement
        redwing__Training_Plan_Achievement__c  planAchievement = new redwing__Training_Plan_Achievement__c();
        planAchievement.redwing__Training_Plan__c = lplan.id;
        planAchievement.redwing__Achievement__c = ra.id;
        insert planAchievement;
            
        // Achievement Assignment
        redwing__Achievement_Assignment__c achieveAssign = new redwing__Achievement_Assignment__c();
        achieveAssign.redwing__User__c = UserInfo.getUserId();
        achieveAssign.redwing__Training_Plan_Achievement__c = planAchievement.Id;
        insert achieveAssign;
        
        //Creating Roster Record
        redwing__ILT_Roster__c objRoster = new redwing__ILT_Roster__c();
        objRoster.redwing__ILT_Class__c = clsRecord.id;
        objRoster.redwing__ILT_Session__c = sessionRecord.id;
        objRoster.redwing__User__c = planAssignment.redwing__User__c;
        objRoster.redwing__Learning_Assignment__c = learningAssignmentupdate.id;
        objRoster.redwing__Status__c = 'Passed';
        insert objRoster;
        
        Voucher__c  v = new Voucher__c();
        v.User__c = UserInfo.getUserId();
        v.ILT_Class__c = clsRecord.id;
        v.Learning_Plan__c = lPlan.Id;
        v.Status__c = 'Claimed';
        insert v;
		
        Test.startTest();
        String status = PHSS_CancelEnrollmentController.checkIfCancelled(objRoster.Id);
        System.assert(status != null);
        PHSS_CancelEnrollmentController.cancelEnrollment(objRoster.Id,'');
        Test.stopTest();
        
        // Assert voucher details
        List<Voucher__c> vouch = [Select Id,Status__c From Voucher__c Where Id = :v.id];
        if(!vouch.isEmpty()) {
        	System.assertEquals('Void', vouch[0].Status__c);
        }
        
        // Assert roster details
        // Modified SJC - Roster records are retained upon student cancellation from course

        List<redwing__ILT_Roster__c> roster = [Select Id,redwing__Status__c,Cancellation_Date__c From redwing__ILT_Roster__c];
        System.assert(!roster.isEmpty());

        
        // Assert if Learning Plan Assignments and Achievement Assignments are removed
        List<redwing__Training_Plan_Assignment__c> lpa = [Select Id From redwing__Training_Plan_Assignment__c];
        System.assert(lpa.isEmpty());
        List<redwing__Achievement_Assignment__c> aa = [Select Id From redwing__Achievement_Assignment__c];
        System.assert(aa.isEmpty());   
    }
    
    static testmethod void cancelEnrollmentLearningAssign() {
    	
        Account a = new Account();
        a.Name='SalesforcetestOrg';
        a.BillingStreet='24 Willie Mays Plaza';
        a.BillingCity='San Francisco';
        a.BillingState='California';
        a.BillingPostalCode='94017';
        a.BillingCountry='USA';
        a.Phone='9934200234'; 
        insert a;

        // Learning
        redwing__Learning__c learning = new redwing__Learning__c();
        learning.Name = 'Test learning';
        learning.redwing__Published__c = true;
        learning.RecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('Media').getRecordTypeId();
        insert learning;
        
        // Object Location
        sked__Location__c objLocation = new sked__Location__c();
        objLocation.Name = 'Test';
        objLocation.sked__Type__c = 'Community';
        objLocation.sked__Address__c = '401 S Monroe St, Little Rock, AR, 72206';
        insert objLocation;

        // Learning Plan
        redwing__Training_Plan__c lPlan = new redwing__Training_Plan__c();
        lPlan.Name = 'Test Plan';
        insert lPlan;
        
        //Create ILT Class Record
        Redwing__ILT_Class__c clsRecord = new Redwing__ILT_Class__c();
        clsRecord.Skedulo_Account__c = a.id;
        clsRecord.redwing__End_Date__c = Date.Parse('12/19/2018');
        clsRecord.redwing__End_Time__c= '13:00';
        clsRecord.redwing__Start_Date__c = Date.Parse('12/19/2018');// Assuming Start date = End date
        clsRecord.redwing__Start_Time__c = '12:00';
        clsRecord.Name = 'Test';
        clsRecord.redwing__Learning__c = learning.Id;
        insert clsRecord;

        //Create ILT Session record
        redwing__ILT_Session__c sessionRecord = new redwing__ILT_Session__c();
        sessionRecord.redwing__ILT_Class__c = clsRecord.Id;
        sessionRecord.Skedulo_Account__c = a.id;
        sessionRecord.Skedulo_Address__c = objLocation.id;
        sessionRecord.redwing__End_Time__c = '20:00';
        sessionRecord.redwing__Date__c = Date.Parse('12/19/2018');
        sessionRecord.redwing__Start_Time__c = '08:00';
        insert sessionRecord; 

        // Learning Plan Assignment
        redwing__Training_Plan_Assignment__c planAssignment = new redwing__Training_Plan_Assignment__c();
        planAssignment.redwing__Training_Plan__c = lPlan.id; // Retrieved learning plan id based on the course selected in page 1
        planAssignment.redwing__User__c = UserInfo.getUserId();
        planAssignment.External_Id__c = 'priyalakshmi.pp@gmail.com';
        insert planAssignment;

        // Learning Assignment
        redwing__Learning_Assignment__c learningAssignment = new redwing__Learning_Assignment__c();
        learningAssignment.redwing__Learning__c = learning.id; // 
        learningAssignment.External_Id__c = 'priyalakshmi.pp@gmail.com'; 
        learningAssignment.redwing__Training_Plan__c = lPlan.Id;
        insert learningAssignment;
		
        redwing__Learning_Assignment__c learningAssignmentupdate = new redwing__Learning_Assignment__c();
        learningAssignmentupdate.id=learningAssignment.id;
        learningAssignmentupdate.redwing__Evaluation_Result__c = 'Passed';
        learningAssignmentupdate.Grade_Reason__c = 'Reason 2'; // Retrieve learning id from page 1
        learningAssignmentupdate.Grade_Additional_Info__c = 'Reason 2'; 
        update learningAssignmentupdate;
        
        // Achievement Category
        redwing__Achievement_Category__c rac = new redwing__Achievement_Category__c();
        rac.name = 'Skill';
        insert rac;
        
        // Achievement
        redwing__Achievement__c ra = new redwing__Achievement__c();
        ra.redwing__Achievement_Category__c = rac.id;
        insert ra;
        
        // Learning Plan Acheivement
        redwing__Training_Plan_Achievement__c  planAchievement = new redwing__Training_Plan_Achievement__c();
        planAchievement.redwing__Training_Plan__c = lplan.id;
        planAchievement.redwing__Achievement__c = ra.id;
        insert planAchievement;
            
        // Achievement Assignment
        redwing__Achievement_Assignment__c achieveAssign = new redwing__Achievement_Assignment__c();
        achieveAssign.redwing__User__c = UserInfo.getUserId();
        achieveAssign.redwing__Training_Plan_Achievement__c = planAchievement.Id;
        insert achieveAssign;
        
        //Creating Roster Record
        redwing__ILT_Roster__c objRoster = new redwing__ILT_Roster__c();
        objRoster.redwing__ILT_Class__c = clsRecord.id;
        objRoster.redwing__ILT_Session__c = sessionRecord.id;
        objRoster.redwing__User__c = planAssignment.redwing__User__c;
        objRoster.redwing__Learning_Assignment__c = learningAssignmentupdate.id;
        insert objRoster;
        
        Voucher__c  v = new Voucher__c();
        v.User__c = UserInfo.getUserId();
        v.ILT_Class__c = clsRecord.id;
        v.Learning_Plan__c = lPlan.Id;
        v.Status__c = 'Claimed';
        insert v;
		
        Test.startTest();
        PHSS_CancelEnrollmentController.cancelEnrollment(learningAssignment.Id,'');
        Test.stopTest();

        // Assert if Learning Plan Assignments and Achievement Assignments are removed
        List<redwing__Training_Plan_Assignment__c> lpa = [Select Id From redwing__Training_Plan_Assignment__c];
        //System.assert(lpa.isEmpty());
        List<redwing__Achievement_Assignment__c> aa = [Select Id From redwing__Achievement_Assignment__c];
        //System.assert(aa.isEmpty());
    }
    
}