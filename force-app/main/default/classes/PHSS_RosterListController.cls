public without sharing class PHSS_RosterListController {
    
    public class jsonValues{
        @AuraEnabled public String Id{get;set;}
        @AuraEnabled public String ClassId{get;set;}
        @AuraEnabled public String ClassInstructor{get;set;}         
        @AuraEnabled public String ClassDate{get;set;}
        @AuraEnabled public String ClassTime{get;set;}
        @AuraEnabled public String ClassName{get;set;}        
        @AuraEnabled public String Firstname{get;set;}
        @AuraEnabled public String Lastname{get;set;}
        @AuraEnabled public String Email{get;set;}
        @AuraEnabled public String Status{get;set;}
        @AuraEnabled public String Evaluation_Result{get;set;}
        @AuraEnabled public String Grade_Reason{get;set;}
        @AuraEnabled public String Grade_Additional_Info{get;set;} 
    } 
     
    @AuraEnabled
    //public static List<redwing__Achievement_Assignment__c> getRosterList(String recId) {    
    public static List<jsonValues> getRosterList(String recId) {
        List <redwing__ILT_Instructor__c> instructorList = [Select Id, Name, redwing__ILT_Class__c, redwing__Instructor__r.Name
            From redwing__ILT_Instructor__c Where redwing__ILT_Class__c = :recId];      
        
        List<redwing__Achievement_Assignment__c> assignList = [Select Id,
                                                                      ILT_Class__r.Name,
                                                                      ILT_Class__r.Offering_Id__c,
                                                                      ILT_Class__r.redwing__Start_Date__c,
                                                                      ILT_Class__r.redwing__Start_Time__c,
                                                                      Firstname__c,
                                                                      Lastname__c,
                                                                      Email__c,
                                                                      redwing__Status__c,
                                                                      Evaluation_Result__c,
                                                                      Grade_Reason__c,
                                                                      Grade_Additional_Info__c
                                                                 From redwing__Achievement_Assignment__c 
                                                                 Where ILT_Class__c = :recId 
                                                                 // DE 884 - Display all students in roster regardless of status
                                                                 //And redwing__Status__c = 'Acquired' 
                                                                 And Evaluation_Result__c != Null
                                                                 // End DE884
                                                                 And Achievement_Type__c = 'Certifications']; 
                                                                       
        
        String theInstructorName = '';  
        String theClassDate = '';
        String theClassTime = '';
        
        for (redwing__ILT_Instructor__c theInstructor : instructorList) {
            theInstructorName += theInstructor.redwing__Instructor__r.Name + ' ';
        }     
        if (assignList.size() > 0 && assignList[0] != null) {
            Date classDate = assignList[0].ILT_Class__r.redwing__Start_Date__c;
            theClassDate = classDate.format();      // MM/dd/yyyy - format for US locale
            theClassTime = String.valueOf(assignList[0].ILT_Class__r.redwing__Start_Time__c);           
        }    
                                                                                                                                                                             
                                                                       
        List<jsonValues> assignListValues = new List<jsonvalues>();
        for (redwing__Achievement_Assignment__c theAssignment : assignList) {
            jsonValues theJsonValue = new jsonValues();
            theJsonValue.Id = theAssignment.Id;
            theJsonValue.ClassId = theAssignment.ILT_Class__r.Offering_Id__c;
            theJsonvalue.ClassInstructor = theInstructorName; 
            theJsonValue.ClassDate = theClassDate;
            theJsonValue.ClassTime = theClassTime;
            theJsonValue.ClassName = theAssignment.ILT_Class__r.Name;
            theJsonValue.Firstname = theAssignment.Firstname__c;
            theJsonValue.Lastname = theAssignment.Lastname__c;
            theJsonValue.Email = theAssignment.Email__c;
            theJsonValue.Status = theAssignment.redwing__Status__c;
            theJsonValue.Evaluation_Result = theAssignment.Evaluation_Result__c;
            theJsonValue.Grade_Reason = theAssignment.Grade_Reason__c;            
            theJsonValue.Grade_Additional_Info = theAssignment.Grade_Additional_Info__c;  
                      
       
            assignListValues.add(theJsonValue);                                                                
        }
        System.debug('assignList='+assignList);        
        System.debug('assignListValues='+assignListValues);
        //return assignList;
        return assignListValues;
    }
}