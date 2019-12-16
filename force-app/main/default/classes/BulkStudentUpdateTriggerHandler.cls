public with sharing class BulkStudentUpdateTriggerHandler
{
    public static void updateILTClassLoookup (List<Student_Bulk_Upload__c> students)
    {
        Map<String,redwing__ILT_Class__c> iltClassMap = new Map<String,redwing__ILT_Class__c>();

        List<redwing__ILT_Class__c> iltClassList = [SELECT Skedulo_Job_Number__c,
                                                           Id
                                                      FROM redwing__ILT_Class__c
                                                     WHERE Class_Closed_Date__c = null];

        if(iltClassList.size() > 0)
        {
            for(redwing__ILT_Class__c c : iltClassList)
            {
                iltClassMap.put(c.Skedulo_Job_Number__c,c);
            }
        }

        
        for(Student_Bulk_Upload__c s : students)
        {
            redwing__ILT_Class__c iClass = iltClassMap.get(s.Appinium_Class_ID__c);

            if(iClass != null)
            {
                s.ILT_Class__c  = iClass.Id;
                s.Status__c     = 'Created';
            }
            else
            {
                s.ILT_Class__c  = null;
                s.Status__c     = 'No ILT Class Found';
            }

        }

    }

    public static void enrollLearner (List<Student_Bulk_Upload__c> students)
    {

        List<Student_Bulk_Upload__c> sbuList = [SELECT  Id,
                                                		Learning__c,
                                                		Learning__r.Id,
                                                        ILT_Class__c,
                                                        ILT_Class__r.Id,
                                                        Voucher__c,
                                                        Voucher__r.Id,
                                                        ILT_Class__r.Learning_Plan__r.Id,
                                                        Status__c,
                                                        Student_First_Name__c,
                                                        Student_Last_Name__c,
                                                        Student_Phone_Number__c,
                                                        Student_Email_Address__c,
                                                		Is_Processed__c 
                                                   FROM Student_Bulk_Upload__c
                                                  WHERE Is_Processed__c = False 
                                                    AND Id IN : students];

        List<JSONWrapper.Students> studentList = new List<JSONWrapper.Students>();

        Id theLearningPlanId = null;
        Id theOfferingId     = null;
        boolean IsOnline	 = false;
        
        system.debug('sbuList***'+sbuList);

        for(Student_Bulk_Upload__c b : sbuList)
        {
            system.debug('b.Is_Processed__c***'+b.Is_Processed__c);
            
                if(b.ILT_Class__c != null && b.Voucher__c != null)
                {   
                    JSONWrapper.Students student = new JSONWrapper.Students();
                            
                    student.FirstName   = b.Student_First_Name__c;
                    student.LastName    = b.Student_Last_Name__c;
                    student.Email       = b.Student_Email_Address__c;
                    student.Phone       = b.Student_Phone_Number__c;
                    student.voucherid   = String.valueOf(b.Voucher__c).substring(0, 15);
                    student.Rosterid    = '';
    
                    theLearningPlanId   = b.ILT_Class__r.Learning_Plan__r.Id;
    
                    theOfferingId       = b.ILT_Class__r.Id;
    
                    studentList.add(student);
                }
                
                if(b.Learning__c != null && b.Voucher__c != null)
                {
                    JSONWrapper.Students student = new JSONWrapper.Students();
                            
                    student.FirstName   = b.Student_First_Name__c;
                    student.LastName    = b.Student_Last_Name__c;
                    student.Email       = b.Student_Email_Address__c;
                    student.Phone       = b.Student_Phone_Number__c;
                    student.voucherid   = String.valueOf(b.Voucher__c).substring(0, 15);
                    student.Rosterid    = '';
                    
                    if(!Test.isRunningTest())
                    {
                    	theLearningPlanId   = [select redwing__training_plan_section__r.redwing__Training_Plan__c from redwing__training_plan_section_item__c where redwing__learning__c =: (b.Learning__r.Id)].redwing__training_plan_section__r.redwing__Training_Plan__c;
                    }
    
                    theOfferingId       = b.Learning__r.Id;
                    
                    IsOnline	 		= true;
    
                    studentList.add(student);
                }
            
        }

        String JSONStudentList = JSON.serialize(studentList);
        System.debug('=======JSONAddStudents:'+JSONStudentList);
        System.debug('**theLearningPlanId**'+theLearningPlanId);

        if (theLearningPlanId != null && !Test.isRunningTest() && !IsOnline)
        {
            system.debug('***ILT Class***');
            ILTInstructorCommunity.enrollStudents(JSONStudentList, theLearningPlanId, theOfferingId, '', null);
        }
        
        if (IsOnline && !Test.isRunningTest())
        {
            system.debug('***Online Class***');
            ILTInstructorCommunity.enrollStudents(JSONStudentList, theLearningPlanId, theOfferingId, 'Online', null);
        }

    }

}