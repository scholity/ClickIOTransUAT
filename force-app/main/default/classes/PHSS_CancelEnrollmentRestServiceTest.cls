@isTest
public class PHSS_CancelEnrollmentRestServiceTest {
    static testmethod void cancelEnrollmentTest() {
        
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
        sessionRecord.redwing__End_Time__c = '13:00';
        sessionRecord.redwing__Date__c = Date.Parse('12/19/2018');
        sessionRecord.redwing__Start_Time__c = '12:00';
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
        objRoster.RCO_Order_Id__c = '0000001305';
        insert objRoster;
        
        redwing__ILT_Roster__c objRoster1 = new redwing__ILT_Roster__c();
        objRoster1.redwing__ILT_Class__c = clsRecord.id;
        objRoster1.redwing__ILT_Session__c = sessionRecord.id;
        objRoster1.redwing__User__c = planAssignment.redwing__User__c;
        objRoster1.redwing__Learning_Assignment__c = learningAssignmentupdate.id;
        objRoster1.RCO_Order_Id__c = '0000001306';
        objRoster1.redwing__Status__c = 'Cancelled';
        insert objRoster1;
        
        
        Voucher__c  v = new Voucher__c();
        v.User__c = UserInfo.getUserId();
        v.ILT_Class__c = clsRecord.id;
        v.Learning_Plan__c = lPlan.Id;
        v.Status__c = 'Claimed';
        v.RCO_Order_Id__c = '0000001305';
        insert v;
		
        String invalidJson = '{ "orderID" : "",'
				      		 + '"classID" : "a311k0000009HFO",'
				      		 + '"cancelReason" : "Sample Reason",' 
					  		 + '"action"  : "orderCancellationa311k0000009HFO"}';
        
        String validJson = '{ "orderID" : "0000001305",'
				      	   + '"classID" : "a311k0000009HFO",'
				      	   + '"cancelReason" : "Sample Reason",' 
					  	   + '"action"  : "orderCancellationa311k0000009HFO"}';
        
        String invalidJson1 = '{ "orderID" : "000000000",'
				      	   			+ '"classID" : "a311k0000009HFO",'
				      	   			+ '"cancelReason" : "Sample Reason",' 
					  	   			+ '"action"  : "orderCancellationa311k0000009HFO"}';
        
        String invalidJson2 = '{ "orderID" : "0000001306",'
				      	   			+ '"classID" : "a311k0000009HFO",'
				      	   			+ '"cancelReason" : "Sample Reason",' 
					  	   			+ '"action"  : "orderCancellationa311k0000009HFO"}';
        
        
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
                
        req.requestUri = '/services/apexrest/PHSS/cancelEnrollment';
        req.httpMethod = 'POST';
        
        req.requestBody = Blob.valueOf(invalidJson);
        RestContext.request = req;
        RestContext.response = res;
        PHSS_CancelEnrollmentRestService.cancel();
        
        req.requestBody = Blob.valueOf(validJson);
        RestContext.request = req;
        RestContext.response = res;
        PHSS_CancelEnrollmentRestService.cancel();
        
        req.requestBody = Blob.valueOf(invalidJson1);
        RestContext.request = req;
        RestContext.response = res;
        PHSS_CancelEnrollmentRestService.cancel();
        
        req.requestBody = Blob.valueOf(invalidJson2);
        RestContext.request = req;
        RestContext.response = res;
        PHSS_CancelEnrollmentRestService.cancel();
        
        Test.stopTest();
    }
}