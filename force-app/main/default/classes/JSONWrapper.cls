public class JSONWrapper {

    public List<Students> Students {get;set;} 
    public ClassDetails ClassDetails {get;set;} 

    public JSONWrapper(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    system.debug(text);
                    if (text == 'ClassDetails') {
                        ClassDetails = new ClassDetails(parser);
                    } 
                    else if (text == 'Students') {
                        Students = arrayOfStudents(parser);
                    }else {
                        System.debug(LoggingLevel.WARN, 'JSON2Apex consuming unrecognized property: '+text);
                    }
                }
            }
        }
    }
    
    public class Students {
        @AuraEnabled public String FirstName {get;set;} 
        @AuraEnabled public String LastName {get;set;} 
        @AuraEnabled public String Roster {get;set;} 
        @AuraEnabled public String Email {get;set;} 
        @AuraEnabled public String Phone {get;set;} 
        @AuraEnabled public String Grade {get;set;} 
        @AuraEnabled public String Fail_Reason {get;set;} 
        @AuraEnabled public Date closedDate{get;set;}
        @AuraEnabled public String Reason {get;set;}
        @AuraEnabled public String AdditionalInfo {get;set;} 
        @AuraEnabled public String voucherid{get;set;} 
        @AuraEnabled public String Rosterid{get;set;}


        public Students(){
            FirstName = '';
            LastName = '';
            Roster = '';
            Email = '';
            Phone = '';
            Grade = '';
            Fail_Reason = '';
            Reason = '';
            AdditionalInfo = '';
        
        }
        
        public Students(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'FirstName') {
                            FirstName = parser.getText().deleteWhitespace();
                        } else if (text == 'LastName') {
                            LastName = parser.getText().deleteWhitespace();
                        } else if (text == 'Email') {
                            Email = parser.getText().deleteWhitespace();
                        } else if (text == 'Phone') {
                            Phone = parser.getText().deleteWhitespace();
                        }else if (text == 'Roster') {
                            Roster = parser.getText();
                        }else if (text == 'Grade') {
                            Grade = parser.getText();
                        } else if (text == 'Fail_Reason') {
                            Fail_Reason = parser.getText();
                        } else if (text == 'AdditionalInfo') {
                            AdditionalInfo = parser.getText().trim();
                        }else if (text == 'Reason') {
                            Reason = parser.getText();
                        }else if (text == 'voucherid') {
                            voucherid = parser.getText();
                        } 
                        else if (text == 'Rosterid') {
                            Rosterid = parser.getText();
                        } 
                        else {
                            System.debug(LoggingLevel.WARN, 'Students consuming unrecognized property: '+text);
                        }
                    }
                }
            }
        }
    }
    
     
    
    public static List<Students> arrayOfStudents(System.JSONParser p) {
        List<Students> res = new List<Students>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Students(p));
        }
        return res;
    }
    
    public static List<ClassDetails> classdetails(System.JSONParser p) {
        List<ClassDetails> rescls = new List<ClassDetails>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            rescls.add(new ClassDetails(p));
        }
        return rescls;
    }
    
    
    
    public class ClassDetails {
        @AuraEnabled public String Account {get;set;} 
        @AuraEnabled public String Course {get;set;}
        @AuraEnabled public String StartDate {get;set;} 
        @AuraEnabled public String EndDate {get;set;} 
        @AuraEnabled public String Students {get;set;}
        @AuraEnabled public String SupplementInfo {get;set;} 
        @AuraEnabled public String Voucher {get;set;} 
        @AuraEnabled public String Instructor1 {get;set;} 
        @AuraEnabled public String Instructor2 {get;set;} 
        @AuraEnabled public String AdditionalInstructors {get;set;} 
        @AuraEnabled public String Location {get;set;}
        @AuraEnabled public String SiteName {get;set;}
        @AuraEnabled public String Address1 {get;set;}
        @AuraEnabled public String Address2 {get;set;}
        @AuraEnabled public String City {get;set;}
        @AuraEnabled public String State {get;set;}
        @AuraEnabled public String Zip {get;set;}
        @AuraEnabled public String OpportunityId {get;set;}
        @AuraEnabled public String CloudCrazeProdId {get;set;}
        @AuraEnabled public Boolean IsLearnToSwimProduct {get;set;}
        @AuraEnabled public String SuccessfulEvals {get;set;}
        @AuraEnabled public String UnsuccessfulEvals {get;set;}
        @AuraEnabled public String NonEvals {get;set;}
        
        public ClassDetails(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'Account') {
                            Account = parser.getText();
                        } else if (text == 'Course') {
                            Course = parser.getText();
                        } else if (text == 'StartDate') {
                            StartDate = parser.getText();
                        } else if (text == 'EndDate') {
                            EndDate = parser.getText();
                        } else if (text == 'Students') {
                            Students = parser.getText();
                        } else if (text == 'SupplementInfo') {
                            SupplementInfo = parser.getText();
                        } else if (text == 'Voucher') {
                            Voucher = parser.getText();
                        } else if (text == 'Instructor1') {
                            Instructor1 = parser.getText();
                        } else if (text == 'Instructor2') {
                            Instructor2 = parser.getText();
                        } else if (text == 'AdditionalInstructors') {
                            AdditionalInstructors = parser.getText();
                        } else if (text == 'Location') {
                            Location = parser.getText();
                        } else if (text == 'SiteName') {
                            SiteName = parser.getText();
                        } else if (text == 'Address1') {
                            Address1 = parser.getText();
                        } else if (text == 'Address2') {
                            Address2 = parser.getText();
                        } else if (text == 'City') {
                            City = parser.getText();
                        } else if (text == 'State') {
                            State = parser.getText();
                        } else if (text == 'Zip') {
                            Zip = parser.getText();
                        } else if(text == 'OpportunityId') {
                            OpportunityId = parser.getText();    
                        } else if(text == 'CloudCrazeProdId') {
                            CloudCrazeProdId = parser.getText();
                        } else if (text == 'IsLearnToSwimProduct') {
                            IsLearnToSwimProduct = parser.getBooleanValue();
                        } else if (text == 'SuccessfulEvals') {
                            SuccessfulEvals = parser.getText();
                        } else if (text == 'UnsuccessfulEvals') {
                            UnsuccessfulEvals = parser.getText();
                        } else if (text == 'NonEvals') {
                            NonEvals = parser.getText(); 
                        } else {
                            System.debug(LoggingLevel.WARN, 'ClassDetails consuming unrecognized property: '+text);
                        }
                    }
                }
            }
        }
    }
    
}