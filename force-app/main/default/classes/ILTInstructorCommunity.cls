public without sharing class ILTInstructorCommunity{
    
    private Static Id classId;
    private Static Id sessionId;
    private Static Id learningPlanId;
    private Static Id learningId;
    private Static Id learningVersionId;
    private Static Id AccountId;
    private Static Id eventlearningId;
    private Static Id eventlearningplansection;
    public Static boolean blend = false;
    public Static boolean cre = false;
    public Static boolean other = false;
    public Static boolean onlineCourse = false;
    public Static String onlineOrderNumber = '';
    public Static boolean auraException = true;
    public static boolean isLearnToSwimProduct = false;
    public Static redwing__ILT_Session__c sessions;
    public Static list<redwing__ILT_Session__c> sessionlist;
    public Static Integer Studentvoccount;
    public Static id learningplansection;
    public Static id eventlearningobjid;
    public Static List<redwing__Training_Plan_Achievement__c> trpac;
    public Static Map<id, id> trpsec;
    public Static Map<id, id> rtpa;
    public Static Map<id, id> rtpaac;
    public Static Map<String, User> userMap;   
    public Static Map<String, Contact> contactMap;
    public Static Map<Id, Id> contactAccountMap;
    public Static Map<String, Contact> contactEmailphoneMap;
    public Static Map<String, Contact> ContactEmailMap;
    public Static Map<String, Contact> ContactphoneMap;
    public Static Map<String, Voucher__c> studentvoucherMap;
    public Static List<Id> vILTClasslist;
    public Static List<redwing__ILT_Class__c> vILTclasssessionlist;
    public Static Map<id,list<redwing__ILT_Session__c>> vILTClassSessionMap;
    public Static Map<String,redwing__Training_Plan_Section_Item__c> tpsiRecordTypeMap;
    public Static list<id> voucheridsrbc;
    public Static Set<Id> contactAccountIds;
    private Static Profile profileId;
    public Static RecordType rt;
    public Static Boolean errmsgvc = false;
    public Static list<redwing__Training_Plan_Assignment__c> assignmentList;
    public Static list<redwing__Learning_Assignment__c> learningAssignmentList;
    public Static list<redwing__Achievement_Assignment__c> AchievementAssignmentList;
    public Static list<redwing__ILT_Roster__c> rosterList;
    Public static List<account> accList;
    Public Static List<contact> conList;
    Public static List<User> lstUser;
    Public static List<id> uidlist; 
    Public static list<redwing__Training_Plan_Section__c> trpsclist;
    Public Static list<redwing__Training_Plan_Section_Assignment__c> lpsAssignmentList;
    Public Static list<redwing__Training_Plan_Section_Assignment__c> lpssecAsslist;
    Public static List<PermissionSetAssignment> permissionSetAssList;
    Public static Map<String, String> userNameEmailMap;

    // Error messages
    public static final String FAILED_TO_ADD_STUDENTS = 'Failed to add students.';
    public static final String FAILED_TO_IDENTIFY_LTS_CLASS = 'Failed to identify Learn-to-Swim class.';
    public static final String FAILED_TO_IDENTIFY_LTS_COURSE = 'Failed to identify Learn-to-Swim course.';
    public static final String FAILED_TO_POST_CLASS = 'Failed to post class.';
    
    
    @AuraEnabled
    public static Boolean UserExisting(String firstName, String LastName, String Email){
        List<User> u = [select id FROM User where FirstName =:firstName and LastName =:LastName and Email =:Email];
        if(!u.isEmpty()){
            return true;
        }
        return false;
    }

    @AuraEnabled
    public static RBCWrapper initWrapper() {
        RBCWrapper cpsWrap = new RBCWrapper();
        // Get Organization name
//        List<User> userList = [Select Id,Name,ContactId From User Where Id = :UserInfo.getUserId()];
//        if(!userList.isEmpty() && userList[0].ContactId != null) {
//            List<Contact> conList = [Select Id,Account.Name From Contact Where Id = :userList[0].ContactId];
//            cpsWrap.accId = conList[0].Account.Id;
//            cpsWrap.accName = conList[0].Account.Name;
//        }

        // Initialize Session list
        List<RBCWrapper.SessionWrapper> sessionWrapList = new List<RBCWrapper.SessionWrapper>();
        RBCWrapper.SessionWrapper sessionWrap = new RBCWrapper.SessionWrapper();
        sessionWrapList.add(sessionWrap);
        cpsWrap.sessionList = sessionWrapList;

//        // Class Formats
//        List<String> formatsList = new List<String>();
//        Schema.DescribeFieldResult fieldResult = redwing__ILT_Class__c.Classroom_Setting__c.getDescribe();
//        List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
//        for(Schema.PicklistEntry val : entries) {
//            if(val.getLabel() != 'Online') {
//                formatsList.add(val.getLabel());
//            }
//        }
//        cpsWrap.classFormatList = formatsList;

        // Timezone
        PHSS_skedJobtoILTClass localSkedJobtoILTClass = new PHSS_skedJobtoILTClass();
        cpsWrap.timeZoneList = localSkedJobtoILTClass.timeZoneMap;


        System.debug('cpsWrap '+cpsWrap);
        return cpsWrap;
    }

    @AuraEnabled
    public static ccrz__E_Product__c getLearningPlanAttributes(String ccProdId) {

        ccrz__E_Product__c  ccProd = [SELECT Id, LMS_Learning_Plan__c, LMS_Learning_Plan__r.Name, LMS_Learning_Plan__r.Classroom_Setting__c, LMS_Learning_Plan__r.redwing__Duration__c  FROM ccrz__E_Product__c WHERE Id =: ccProdId LIMIT 1];

        return ccProd;
    }

    // Method to create vouchers from post class method during RBC Creation
    @AuraEnabled
    public static list<Voucher__c> insertVouchers(Integer count, String classIds, Id Course){
        voucheridsrbc = new list<id>();
        list<Voucher__c> lstVoucher = new list<Voucher__c>();
        for(Integer i=0; i<count; i++){
            Voucher__c objVoucher = new Voucher__c();
            objVoucher.ILT_Class__c = classIds;
            objVoucher.Learning_Plan__c = Course;
            lstVoucher.add(objVoucher);
        }
        insert lstVoucher;
        System.debug('Student count'+Studentvoccount);
        for(Integer i=0; i<Studentvoccount; i++){
            voucheridsrbc.add(lstVoucher[i].id);
        }
        return lstVoucher;
    }
    
    // Method to send student details from server to RBC
    @AuraEnabled
    public static List<JSONWrapper.Students> saveChunk(String base64Data, String contentType, Boolean isCRE){
        
        CourseInfo objCourse = new CourseInfo();
        
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        blob testBlob = EncodingUtil.base64Decode(base64Data);
        
        string csvData = testBlob.toString();
        
        List<String> rowList = csvData.split('\n');
        
        //system.debug('***rowList***' +rowList);
        
        //return csvData;
        String[] csvFileLines=csvData.split('\n');   
        objCourse.lstStudents = new List<JSONWrapper.Students>();
        
        
        for(Integer i=1;i<csvFileLines.size();i++){
            JSONWrapper.Students stDetails = new JSONWrapper.Students();
            string[] csvRecordData = csvFileLines[i].split(',');
            if(csvRecordData.size()>0){
                if(csvRecordData[0]!=null && csvRecordData[0].trim()!=''){
                    stDetails.FirstName = csvRecordData[0];
                }
            }
            
            if(csvRecordData.size()>1){
                if(csvRecordData[1]!=null && csvRecordData[1].trim()!=''){
                    stDetails.LastName = csvRecordData[1];
                }
            }
            
            if(csvRecordData.size()>2){
                if(csvRecordData[2]!=null && csvRecordData[2].trim()!=''){
                    stDetails.Email = csvRecordData[2];
                }
            }
            
            if(csvRecordData.size()>3){
                if(csvRecordData[3]!=null && csvRecordData[3].trim()!=''){
                    stDetails.Phone = csvRecordData[3];
                }
            }
            
            
            if(isCRE)
            {   
                if(csvRecordData.size()>4){
                if(csvRecordData[4]!=null && csvRecordData[4].trim()!=''){
                    List<String> words = csvRecordData[4].trim().split(' ');
                    String result = '';
                    for (String word : words) {
                        word = word.trim();
                        if (word.length() > 1) {
                            result += word.substring(0, 1).toUpperCase() + word.substring(1, word.length()).toLowerCase() + ' '; //DE1215 Ensure first letter of all words capitilized
                        }
                    }
                    stDetails.Grade = result.trim();

                }
            }
                if(csvRecordData.size()>5){
                if(csvRecordData[5]!=null && csvRecordData[5].trim()!=''){
                    String result = csvRecordData[5].trim();
                    if (result.length() > 1) {
                        result = result.substring(0, 1).toUpperCase()
                                + result.substring(1, result.length()).toLowerCase(); //DE888 must ensure case matches fail reason picklist values
                    }
                    stDetails.Fail_Reason = result;
                }
            }
                if(csvRecordData.size()>6){
                if(csvRecordData[6]!=null && csvRecordData[6].trim()!=''){
                    stDetails.AdditionalInfo = csvRecordData[6];    
                }
            }
                
                
                
            }
            objCourse.lstStudents.add(stDetails);
        }
        System.debug('objCourse'+objCourse.lstStudents);
        return objCourse.lstStudents;
    }
    
    
    // Method to call Post class and add students method one after the another (Call from CRE & RBC - 2 Parameter identification)
    @AuraEnabled
    public static void invokeMethods(String JSON, String JSON1, RBCWrapper wrapper){
        Boolean boolState = true;

        System.debug('wrapper '+wrapper);

        if (blend) {
            cre = false;
        } else {
            cre=true;
        }

        if(String.IsNotBlank(JSON)){
            // try {
            System.debug('Blend Value'+blend);
            try {
                redwing__ILT_Class__c newClass = postClass(JSON, wrapper);

            } catch (Exception e) {
                System.debug('exception caught: ' + e.getMessage() + ' lineNumber=' + e.getLineNumber() + ' stackTrace=' + e.getStackTraceString());
                throw new phss_cc_Exception(FAILED_TO_POST_CLASS, e);
            }
            /* } catch (Exception e) {
            boolState = false;
            if(e.getMessage().contains('List index out of bounds: 0')){
            if (auraException) throw new AuraHandledException('Please make sure the course is a valid course'); else throw new enrollException('Invalid Voucher');
            }
            throw new AuraHandledException(e.getMessage());
            }*/
        }


        // learningPlanId = f(learning plan id is obtained from class created in call to postclass)
        // classLearningId = f(class Id created in call to postClass)

        // from addStudents (when there is a voucher)
        //learningPlanId = studentvoucherMap.get((student.voucherid)).Learning_Plan__c;
        //classLearningId = studentvoucherMap.get((student.voucherid)).ILT_Class__r.redwing__Learning__c;




        if(boolState && String.IsNotBlank(JSON1)){
            try {
                addStudents(JSON1);

            } catch (Exception e) {
                System.debug('exception caught: ' + e.getMessage() + ' lineNumber=' + e.getLineNumber() + ' stackTrace=' + e.getStackTraceString());
                throw new phss_cc_Exception(FAILED_TO_ADD_STUDENTS, e);
            }
            //try {
            /*} catch(Exception e){
            boolState = false;
            if(e.getMessage().contains('List index out of bounds: 0')){
            if (auraException) throw new AuraHandledException('Please make sure the course is a valid course'); else throw new enrollException('Invalid Voucher');
            }
            throw new AuraHandledException(e.getMessage());
            }*/
        }
    }
    
    // Method to call Post class and add students method one after the another (Call from RBC - 3 Parameter identification)
    @AuraEnabled
    public static void invokeMethodswithboolean(String JSON, String JSON1, Boolean blend1, RBCWrapper wrapper){
        blend = true;
        ILTInstructorCommunity.invokeMethods(JSON, JSON1, wrapper);
    }
    
    // Method to identify - Valid or invalid voucher (Self Enroll using voucher)
    @AuraEnabled
    public static String validateVourcher(Id idVoucher, String FirstName, String LastName){
        if(String.IsNotBlank(idVoucher)){
            try {
                String sObjName = idVoucher.getSObjectType().getDescribe().getName();
                if(sobjName != 'Voucher__c'){
                    return 'Invalid Voucher';
                }
            }catch(Exception e){
                return 'Invalid Voucher';
            }
            
            list<Voucher__c> objVoucher = [Select Id from Voucher__c where Status__c = 'Claimed' and Id=: idVoucher];
            if(objVoucher != null && objVoucher.size() > 0) {
                return 'Voucher already Claimed';
            }
            
            list<User> u = [Select id from user where FirstName=: FirstName and lastName =: LastName];
            if(u != null && u.size() > 0){
                return 'User Exists';
            }
            else 
                return 'User Does not Exist';
        }
        return 'Invalid Voucher';
    }
    
    @AuraEnabled
    public static list<JSONWrapper.Students> initializeStudents(Integer Count){
        List<JSONWrapper.Students> studentList = new list<JSONWrapper.Students>();
        for(Integer i=0; i<Count; i++){
            studentList.add(new JSONWrapper.Students());
        }
        
        return studentList;
    }
    
    // To retrieve the value of logged in user
    @AuraEnabled
    public static User fetchUser(){
        User u = [Select id, ContactId, Email, Name, Profile.Name, Profile.UserLicense.Name from user where id=: UserInfo.getUserId()];
        return u;    
    }

    @AuraEnabled
    public static ActiveCarts IsCartActive(id opptyId) {
        list<ccrz__E_Cart__c> lstCCarts = [select id,ccrz__CartStatus__c,ccrz__ActiveCart__c, CreatedDate from ccrz__E_Cart__c where Opportunity__c =:opptyId ORDER BY CreatedDate DESC];
        ActiveCarts acts = new ActiveCarts();
        Integer noOfInactiveCarts = 0;

        for(ccrz__E_Cart__c ccart : lstCCarts){

            if(ccart.ccrz__ActiveCart__c){
                acts.cartStatus = true;
                acts.cartid = ccart.Id;
                return acts;
            } else{
                noOfInactiveCarts++;
            }
        }
        if (noOfInactiveCarts > 0) {
            // activate a cart
            ccrz__E_Cart__c cart = lstCCarts[0];
            cart.ccrz__ActiveCart__c = true;
            update cart;

            acts.cartStatus = true;
            acts.cartid = cart.Id;

        } else {
            acts.cartStatus = false;
            acts.cartid = null;

        }
        return acts;
    }
    
    public class ActiveCarts{
        @AuraEnabled public id cartid;
        @AuraEnabled public boolean cartStatus;
    }
    //Added by Raju from Salesforce services to validate the voucher is in issued state or not so that will restrict students enrolling for the blocked or claimed vouchers
    @AuraEnabled
    public static boolean validateVoucher(id recordId){
        list<voucher__c> vchr = [Select id, status__c from voucher__c where id=: recordId];
        if(vchr !=null && !vchr.isEmpty()) {
            // DE1132 - Accept voucher if in Issued (default available) or Reserved (B2B order purchase) status
            if('Issued,Reserved'.contains(vchr[0].status__c)) {
                return true;   
            } else {
                return false;
            }
        }
        return false;
        
    }
    
    
    @AuraEnabled
    public static list<sObject> fetchLookupValues(String s1, String s2){
        user u = fetchUser();
        List<SObject> castRecords;
        if(s2 == 'Account') {
            castRecords = [select id, name from account where id in (Select AccountId from AccountContactRelation where ContactId =: u.ContactId) and name LIKE :s1+'%' order by name asc];
        }
        else if(s2 == 'Course'){
            castRecords = [select id, name from redwing__Training_Plan__c where name LIKE :s1+'%'];
        }
        return castRecords;
    }
    
    // method to enroll students to a class purchased via eCommerce (invocation from PHSS_RegistrationController)
    // note the use of auraException = true to avoid raising Aura exceptions
    
    public Static void enrollStudents(String JSON, Id theLearningPlan, String theClassroomSetting, String orderNumber) {
        auraException = false;
        
        if (theClassroomSetting == 'Online') onlineCourse = true;
        if (orderNumber != null) onlineOrderNumber = orderNumber;
        
        learningPlanId = theLearningPlan;
        //sessionId = ''; // this variable is never used
        classId = learningPlanId; // question this assignment - this value is used primarily for external Id assignments
        
        addStudents(JSON);
        return;
    } 
    
    public class enrollException extends Exception {} 
    
    // method to add students to the class and create rosters, learning assignments, learning plan assignments, learning plans 
    @AuraEnabled
    public Static void addStudents(String JSON){
        if(blend == false && cre ==false){
            other = true;
        }
        system.debug('$$'+learningPlanId);
        //system.debug('$$'+sessionId);
        system.debug('$$'+classId);
        Id classLearningId;
        
        Boolean boolErrorExists = false;
        List<JSONWrapper.Students> studentList = JSONWrapper.arrayOfStudents(System.JSON.createParser(json));
        Set<string> studentLastNames = new Set<string>();
        Set<String> studentFirstNames = new Set<String>();
        Set<String> studentEmails = new Set<String>();
        Set<string> voucherids = new Set<string>();
        List<voucher__c> voucherclaimset = new List<Voucher__c>();

        String ermsg;
        Set<String> exisVoucher = new set<String>();
        Set<String> Idvoucher = new set<String>();
        
        // DE512 - User email addresses as user names
        // If a user's email address is already being used for a user name, and this is a different
        // student (based on different first name and last name), use the email address local name as
        // a stem for the user name.  Example: localname@gmail.com is already assigned, create localname123@gmail.com
        // as user name.  Logic assumes email addresses are well-defined.

        Set<String>userNameFilters = new Set<String>();
        Pattern emailDomainPattern = Pattern.compile('^(.*?)(@.*)'); // Isolate email address domain (group 1)
        
        for(JSONWrapper.Students student : studentList){
            Idvoucher.add(student.voucherid);
            
            // Create list of email stem filters used to search for existing users with same/similar user names
            if (String.IsNotBlank(student.Email)) {
                Matcher emailMatcher = emailDomainPattern.matcher(student.Email);
                if (emailMatcher.matches() && emailMatcher.groupCount() >=2) {
                    userNameFilters.add(emailMatcher.group(1)+'%'+emailMatcher.group(2));               
                }
            }
        }
        
        // DE512 - Store user name by email address for use later in new user creation logic
        // These will be used to see if a new user has the same email address (user name) as an existing user
        // If so, a unique suffix will be created on the local name to insure the user name is unique

        List<User> userNameEmailList = [Select Id, UserName, Email From User Where UserName Like :userNameFilters];
        userNameEmailMap = new Map<String, String>();
        
        for (User theUser : userNameEmailList) {
            userNameEmailMap.put(theUser.UserName, theUser.Email);
        }
        
        set<String> allVoucher = new set<String>(); 
        
        List<Voucher__c> lstVoucher = [Select Id, Voucher_Claim__c, status__c from Voucher__c where Voucher_Claim__c IN: Idvoucher];
        system.debug(lstVoucher);
        
        for(Voucher__c objVoucher : lstVoucher){
            allVoucher.add(objVoucher.Voucher_Claim__c);
            if(objVoucher.Status__c == 'Claimed')
                exisVoucher.add(objVoucher.Voucher_Claim__c);
        }
        
        List<redwing__Training_Plan_Achievement__c> trpac = [select id, Name from redwing__Training_Plan_Achievement__c where redwing__Training_Plan__c=: learningPlanId];
        System.debug('trpaclist '+trpac);
        
        for(JSONWrapper.Students student : studentList){
            studentLastNames.add(student.LastName);
            studentFirstNames.add(student.FirstName);
            studentEmails.add(student.Email);
            
            //if (!onlineCourse) {
            if(String.IsNotBlank(student.voucherid)) {
                try {
                    if (allVoucher.IsEmpty() || !allVoucher.contains(student.VoucherId)) {
                        System.debug('Wrong voucher id');
                        boolErrorExists = true;
                        if (auraException) throw new AuraHandledException('Invalid Voucher'); else throw new enrollException('Invalid Voucher');
                    }
                } catch (Exception e) {
                    System.debug('Wrong voucher id');
                    boolErrorExists = true;  
                    if (auraException) throw new AuraHandledException('Invalid Voucher'); else throw new enrollException('Invalid Voucher');
                }
                
                if (!boolErrorExists && !exisVoucher.isEmpty() && exisVoucher.contains(student.voucherid)) {
                    System.debug('objVoucher');
                    ermsg = 'Voucher already Claimed';
                    boolErrorExists = true;
                    if (auraException) throw new AuraHandledException('Voucher already Claimed'); else throw new enrollException('Voucher already Claimed');
                } else {
                    System.debug('Voucher received');
                    voucherids.add(student.voucherid);
                }
            }
            //}
        }      
        
        if (!boolErrorExists) {
            userMap = new Map<String, User>();
            //contactMap = new Map<String, Contact>();
            contactEmailMap = new Map<String, Contact>();
            contactAccountMap = new Map<Id, Id>();
            studentvoucherMap = new Map<String, Voucher__c>();

            if (!CRE) {
                //User Map to check if the user already exists - Not required for CRE

                for (User u : [
                        Select Id, FirstName, LastName, DM_External_Id__c, Email
                        From User
                        Where LastName IN :studentLastNames And FirstName IN :studentFirstNames
                        And (Email = Null Or Email = '' Or Email In :studentEmails)
                    ]) {

                    if (String.isNotBlank(u.Email)) {
                        userMap.put((u.LastName + u.FirstName + u.Email).toLowerCase(), u);
                    } else {
                        userMap.put((u.LastName + u.FirstName).toLowerCase(), u);
                    }

                }

            
                // contactMap to check if student has existing contacts or not = Not required for CRE
                // Updated (SJC) - Contact matching rule is always LN+FN+Email

                for (Contact theContact : [
                        Select Id, AccountId, FirstName, LastName, Email, DM_External_Id__c, MobilePhone
                        From Contact
                        Where LastName IN :studentLastNames And FirstName IN :studentFirstNames
                        And (Email = Null Or Email = '' Or Email In :studentEmails)
                    ]) {

                    if (String.isNotBlank(theContact.Email)) {
                        contactEmailMap.put((theContact.LastName + theContact.FirstName + theContact.Email).toLowerCase(), theContact);
                    } else {
                        contactEmailMap.put((theContact.LastName + theContact.FirstName).toLowerCase(), theContact);
                    }

                    if (String.IsNotBlank(theContact.AccountId)) contactAccountMap.put(theContact.Id, theContact.AccountId);
                }


                // Retrieve voucher records by voucher Id - Not required for CRE

                for (Voucher__c v : [
                        Select Id, Name, ILT_Class__c, Online_Class__c, Voucher_Claim__c, RCO_Order_Id__c,
                                Learning_Plan__c, ILT_Class__r.redwing__Learning__c, ILT_Class__r.redwing__End_Date__c,
                                ILT_Class__r.redwing__Learning__r.redwing__Current_Published_Version__c, ILT_Class__r.Request_Type__c
                        From Voucher__c
                        Where Voucher_Claim__c IN :voucherids
                    ]) {
                    studentvoucherMap.put(v.Voucher_Claim__c, v);
                }
            }
            
            //Commented for multiple sessions
            /*vILTClasslist = new list<Id>();
            if(studentvoucherMap!=null){
            for(Voucher__c vclasslist:studentvoucherMap.values())
            {
            System.debug('ILTClasslist'+vclasslist.ILT_Class__c);
            vILTClasslist.add(vclasslist.ILT_Class__c);
            }
            
            vILTclasssessionlist = [Select id,(SELECT Id, Name FROM redwing__ILT_Sessions__r), Name from redwing__ILT_Class__c where Id IN:vILTClasslist];
            vILTClassSessionMap = new Map<Id,list<redwing__ILT_Session__c>>();
            for(redwing__ILT_Class__c r : vILTclasssessionlist)
            vILTClassSessionMap.put(r.id,r.redwing__ILT_Sessions__r);
            }*/

            //Get learning planid by differentiating from claim voucher and (RBC or CRE) Componenet
            for (JSONWrapper.Students student : studentList){
                if (studentvoucherMap.containskey(student.voucherid)) {
                    // Needs rework - this assumes same learning plan/class for each student!!
                    learningPlanId = studentvoucherMap.get((student.voucherid)).Learning_Plan__c;
                    classLearningId = studentvoucherMap.get((student.voucherid)).ILT_Class__r.redwing__Learning__c;
                    
                    System.debug('students voucher lp' + learningPlanId);
                    System.debug('students voucher learning' + classLearningId);
                    
                    If (learningPlanId==null)
                    {
                        if (auraException) throw new AuraHandledException('Learning Plan is Empty'); else throw new enrollException('Learning Plan is Empty');
                    }
                } else {

                }
            }
            //}
            System.debug('post class lp' +learningPlanId);
            
            Map<id,id> rtpa = new map<id,id>();// To retrieve Learning plan Achievement belonging to the current learning plan
            Map<id,id> rtpaac = new map<id, id>();// To retrieve Achievement belonging to the current learning plan Achievement
            
            List <redwing__Training_Plan_Section__c> trpseclst = [select id, redwing__Training_Plan__c, redwing__Order__c from redwing__Training_Plan_Section__c where redwing__Training_Plan__c=: learningPlanId];

            map<id,list<redwing__Training_Plan_Achievement__c>> mapTrainingPlanWithTrainingPlanAchievements = new map<id,list<redwing__Training_Plan_Achievement__c>>();
            for (redwing__Training_Plan_Achievement__c rtpalist:[select id, Name, redwing__Training_Plan__c, redwing__Achievement__c from redwing__Training_Plan_Achievement__c where redwing__Training_Plan__c=: learningPlanId]){
                rtpa.put(rtpalist.redwing__Training_Plan__c, rtpalist.id);
                rtpaac.put(rtpalist.redwing__Training_Plan__c, rtpalist.redwing__Achievement__c);
                if(mapTrainingPlanWithTrainingPlanAchievements.containskey(rtpalist.redwing__Training_Plan__c)){
                    mapTrainingPlanWithTrainingPlanAchievements.get(rtpalist.redwing__Training_Plan__c).add(rtpalist);
                } else{
                    list<redwing__Training_Plan_Achievement__c> lstRTPA = new list<redwing__Training_Plan_Achievement__c>();
                    lstRTPA.add(rtpalist);
                    mapTrainingPlanWithTrainingPlanAchievements.put(rtpalist.redwing__Training_Plan__c,lstRTPA);
                }
            }
            
            tpsiRecordTypeMap = new map<String,redwing__Training_Plan_Section_Item__c>();
            
            // To differentiate that the value comes from post class
            System.debug('Getting in>>>');
            
            redwing__Training_Plan_Section_Item__c[] learningPlanILTEventItem = [Select Id, redwing__Learning__c, redwing__Learning__r.recordtype.Name, redwing__Training_Plan_Section__r.redwing__Order__c,
                                                                                 redwing__Learning__r.redwing__Current_Published_Version__c, redwing__Training_Plan_Section__c
                                                                                 From redwing__Training_Plan_Section_Item__c Where redwing__Training_Plan_Section__r.redwing__Training_Plan__c =: learningPlanId 
                                                                                 And redwing__Learning__c != null And redwing__Learning__r.recordtype.Name != null
                                                                                 And redwing__Learning__r.redwing__Current_Published_Version__c != null];

            for (redwing__Training_Plan_Section_Item__c tpsi: learningPlanILTEventItem ){
                tpsiRecordTypeMap.put(tpsi.redwing__Learning__r.recordtype.Name,tpsi ); // Used while creating learning assignments with leaprnign plan section
            }
            
            profileId = [SELECT Id, Name FROM Profile WHERE Name = 'Learner Community Profile' LIMIT 1];//Can be changed based
            
            rosterList = new list<redwing__ILT_Roster__c>();
            accList = new list<account>();
            conList = new List<contact>();
            lstuser = new list<user>();
            
            assignmentList = new list<redwing__Training_Plan_Assignment__c>();            
            lpsAssignmentList = new list<redwing__Training_Plan_Section_Assignment__c>();
            learningAssignmentList = new list<redwing__Learning_Assignment__c>();            
            AchievementAssignmentList = new list<redwing__Achievement_Assignment__c>();  
            
            Integer countValue = -1 ;
            
            for (JSONWrapper.Students student : studentList) {
                countValue++;
                System.debug('student '+student.LastName+student.FirstName);
                System.debug('Incremented count'+countValue);
                redwing__Training_Plan_Assignment__c planAssignment = new redwing__Training_Plan_Assignment__c();
                if (blend == true || other==true || onlineCourse) {
                    /**************Create a learning plan assignment **************/
 
                    if (String.IsNotBlank(student.voucherid) && studentvoucherMap.containskey(student.voucherid)) {
                        
                        System.debug('Came here');
                        
                        planAssignment.redwing__Training_Plan__c=studentvoucherMap.get((student.voucherid)).Learning_Plan__c;
                        
                    } else {
                        System.debug('Not here');                
                        planAssignment.redwing__Training_Plan__c = learningPlanId; // Retrieved learning plan id based on the course selected in page 1
                    }
                    
                    // Contact matching logic is always LN+FN+Email
                    /*
                    if (String.IsBlank(student.Email) && contactMap.containsKey((student.LastName+student.FirstName).toLowerCase())){
                        planAssignment.redwing__Contact__c = contactMap.get((student.LastName+student.FirstName).toLowerCase()).Id;
                    }
                    
                    else 
                    */
                    
                    if (String.IsNotBlank(student.Email) && contactEmailMap.containsKey((student.LastName+student.FirstName+student.Email).toLowerCase())){
                        planAssignment.redwing__Contact__c = contactEmailMap.get((student.LastName+student.FirstName+student.Email).toLowerCase()).Id;
                    }
                    
                    else {
                        planAssignment.redwing__Contact__r = fetchContact(student, false);// Create new contact 
                    }
                    
                    if (userMap.containsKey((student.LastName+student.FirstName+student.Email).toLowerCase())){
                        planAssignment.redwing__User__c = userMap.get((student.LastName+student.FirstName+student.Email).toLowerCase()).Id;// Converting to lower case since map seems to be case sensitive
                    }
                    else {
                        planAssignment.redwing__User__r = fetchUser(student, false);// Create new user 
                    }
                    System.debug('Initial assignment of user:'+planAssignment.redwing__User__c);
                    
                    if (String.IsNotBlank(student.Voucherid) && studentvoucherMap.containskey(student.voucherid)) {
                        if (!onlineCourse) {
                            planAssignment.External_Id__c = student.Email+student.LastName+student.FirstName+studentvoucherMap.get((student.voucherid)).ILT_Class__c;
                        } else {
                            planAssignment.External_Id__c = student.Email+student.LastName+student.FirstName+studentvoucherMap.get((student.voucherid)).Online_Class__c;
                        }
                    } else { 
                        planAssignment.External_Id__c = student.Email+student.lastName+student.FirstName+classId;
                    }
                    
                    planAssignment.redwing__Status__c = 'Not Started';
                    
                    assignmentList.add(planAssignment);
                    
                    System.debug('Plan assignment record creation ='+planAssignment);
                    
                    if (!onlineCourse) {
                        /**************Create a learning assignment with ILT Class learning object ***********************/
                        
                        redwing__Learning_Assignment__c learningAssignment = new redwing__Learning_Assignment__c();
                    
                        // Contact matching logic is always LN+FN+Email 
                        /*                       
                        if (String.IsBlank(student.Email) && contactMap.containsKey((student.LastName+student.FirstName).toLowerCase())){
                            learningAssignment.redwing__Contact__c = contactMap.get((student.LastName+student.FirstName).toLowerCase()).Id;
                        }
                        
                        else 
                        */
                        
                        if (String.IsNotBlank(student.Email) && contactEmailMap.containsKey((student.LastName+student.FirstName+student.Email).toLowerCase())){
                            learningAssignment.redwing__Contact__c = contactEmailMap.get((student.LastName+student.FirstName+student.Email).toLowerCase()).Id;
                        }
                        
                        else {
                            learningAssignment.redwing__Contact__r = fetchContact(student, true);// Create new contact or use exisitng method called
                        }
                        system.debug('***studentvoucherMap***'+studentvoucherMap);
                        if ((String.IsNotBlank(student.Voucherid) && studentvoucherMap.containskey(student.voucherid)))
                        {
                            learningAssignment.External_Id__c               = student.Email+student.LastName+student.FirstName+studentvoucherMap.get((student.voucherid)).ILT_Class__c+studentvoucherMap.get((student.voucherid)).ILT_Class__r.redwing__Learning__c; //Can be chaged if needed
                            learningAssignment.redwing__Training_Plan__c    = studentvoucherMap.get((student.voucherid)).Learning_Plan__c;
                            learningAssignment.redwing__Learning__c         = studentvoucherMap.get((student.voucherid)).ILT_Class__r.redwing__Learning__c;
                            learningAssignment.redwing__Learning_Version__c = studentvoucherMap.get((student.voucherid)).ILT_Class__r.redwing__Learning__r.redwing__Current_Published_Version__c;                            
                            learningAssignment.RCO_Order_Id__c              = studentvoucherMap.get((student.voucherid)).RCO_Order_Id__c;
                        }
                        else
                        {
                            learningAssignment.External_Id__c               = student.Email+student.LastName+student.FirstName+classId+classLearningId; //Can be changed if needed
                            learningAssignment.redwing__Learning__c         = learningId; //classLearningId; // Retrieve learning id from page 1 //DE1466 // learningId is defined in PostClass
                            learningAssignment.redwing__Learning_Version__c = learningVersionId;//classLearningId.redwing__Current_Published_Version__c; // Need object?                        
                            learningAssignment.redwing__Training_Plan__c    = learningPlanId;
                        }
                        
                        /*if(userMap.containsKey((student.LastName+student.FirstName+student.Email).toLowerCase()))
                        {
                        learningAssignment.redwing__User__c = userMap.get((student.LastName+student.FirstName+student.Email).toLowerCase()).Id;// Converting to lower case since map seems to be case sensitive
                        }
                        else
                        {
                        learningAssignment.redwing__User__r = new User(DM_External_Id__c = student.FirstName+student.lastName+student.Email);// Create new user or use exisitng method called
                        }*/
                        
                        if (userMap.containsKey((student.LastName+student.FirstName+student.Email).toLowerCase())){
                            learningAssignment.redwing__User__c = planAssignment.redwing__User__c;// Converting to lower case since map seems to be case sensitive
                        } else {
                            learningAssignment.redwing__User__r = fetchUser(student, true);// Create new user or use exisitng method called         
                            //learningAssignment.redwing__User__r = new User(DM_External_Id__c = student.FirstName+student.lastName+student.Email);// Create new user or use exisitng method called
                        }
                        
                        learningAssignment.redwing__Evaluation_Result__c = student.Grade;
                        //learningAssignment.Grade_Reason__c = Student.Fail_Reason; 
                        learningAssignment.Grade_Additional_Info__c = student.AdditionalInfo; 
                        learningAssignment.redwing__Progress__c = 'Not Started';
                        learningAssignment.redwing__Progress_Percentage__c = 0;                        
                                                
                        learningAssignmentList.add(learningAssignment);
                    }
                    
                    /******************Create learning assignments for all learning objects defined in learning plan***********/
                    for (String learningRecordType:tpsiRecordTypeMap.keyset()) {
                        redwing__Learning_Assignment__c learningAssignment = new redwing__Learning_Assignment__c();
                        
                        // Contact matching logic is always LN+FN+Email 
                        /*                       
                        if (String.IsBlank(student.Email) && contactMap.containsKey((student.LastName+student.FirstName).toLowerCase())){
                            learningAssignment.redwing__Contact__c = contactMap.get((student.LastName+student.FirstName).toLowerCase()).Id;
                        }
                        
                        else 
                        */
                        
                        if(String.IsNotBlank(student.Email) && contactEmailMap.containsKey((student.LastName+student.FirstName+student.Email).toLowerCase())){
                            learningAssignment.redwing__Contact__c = contactEmailMap.get((student.LastName+student.FirstName+student.Email).toLowerCase()).Id;
                        } else {
                            learningAssignment.redwing__Contact__r = fetchContact(student, true);// Create new contact or use existing method called
                        }
                        
                        if (String.IsNotBlank(student.Voucherid) && studentvoucherMap.containskey(student.voucherid)) {
                            learningAssignment.RCO_Order_Id__c = studentvoucherMap.get((student.voucherid)).RCO_Order_Id__c;
                            if (!onlineCourse) {
                                learningAssignment.External_Id__c = student.Email+student.LastName+student.FirstName+studentvoucherMap.get((student.voucherid)).ILT_Class__c+learningRecordType; //Can be chaged if needed
                            } else {
                                learningAssignment.External_Id__c = student.Email+student.LastName+student.FirstName+studentvoucherMap.get((student.voucherid)).Online_Class__c+learningRecordType;
                            }
                        } else {                            
                            learningAssignment.External_Id__c = student.Email+student.LastName+student.FirstName+classId+learningRecordType; //Can be chaged if needed
                            System.debug('learning event id'+tpsiRecordTypeMap.get(learningRecordType).redwing__Learning__r.id);
                        }
                        System.debug('planAssignment='+planAssignment);
                        System.debug('redwing__User__c '+ planAssignment.redwing__User__c);
                        
                        if(userMap.containsKey((student.LastName+student.FirstName+student.Email).toLowerCase())){
                            learningAssignment.redwing__User__c = planAssignment.redwing__User__c;// Converting to lower case since map seems to be case sensitive
                        } else {
                            learningAssignment.redwing__User__r = fetchUser(student, true);// Create new user or use exisitng method called                                         
                            //learningAssignment.redwing__User__r = new User(DM_External_Id__c = student.FirstName+student.lastName+student.Email);// Create new user or use exisitng method called
                        }
                        
                        String lpsAssignmentExternalId = '';
                        if (String.IsNotBlank(student.Voucherid) && studentvoucherMap.containskey(student.voucherid)) {
                            if (!onlineCourse) {
                                lpsAssignmentExternalId = student.Email+student.LastName+student.FirstName+studentvoucherMap.get((student.voucherid)).ILT_Class__c+String.valueOf(tpsiRecordTypeMap.get(learningRecordType).redwing__Training_Plan_Section__r.redwing__Order__c);
                            } else {
                                lpsAssignmentExternalId = student.Email+student.LastName+student.FirstName+studentvoucherMap.get((student.voucherid)).Online_Class__c+String.valueOf(tpsiRecordTypeMap.get(learningRecordType).redwing__Training_Plan_Section__r.redwing__Order__c);
                            }
                        } else { 
                            lpsAssignmentExternalId = student.Email+student.LastName+student.FirstName+classId+String.valueOf(tpsiRecordTypeMap.get(learningRecordType).redwing__Training_Plan_Section__r.redwing__Order__c);
                        }                       
                                                
                        learningAssignment.RCO_Order_Id__c = onlineOrderNumber;
                        learningAssignment.redwing__Progress__c = 'Not Started';
                        learningAssignment.redwing__Progress_Percentage__c = 0;                          
                        learningAssignment.redwing__Learning__c = tpsiRecordTypeMap.get(learningRecordType).redwing__Learning__c;
                        learningAssignment.redwing__Training_Plan__c = learningPlanId;
                        learningAssignment.redwing__Training_Plan_Section__c = tpsiRecordTypeMap.get(learningRecordType).redwing__Training_Plan_Section__c;
                        learningAssignment.redwing__Training_Plan_Section_Item__c =  tpsiRecordTypeMap.get(learningRecordType).Id;  
                        learningAssignment.redwing__Training_Plan_Section_Assignment__r = new redwing__Training_Plan_Section_Assignment__c(External_Id__c = lpsAssignmentExternalId);                      
                        learningAssignment.redwing__Learning_Version__c = tpsiRecordTypeMap.get(learningRecordType).redwing__Learning__r.redwing__Current_Published_Version__c;

                        learningAssignmentList.add(learningAssignment);
                        System.debug('learning assignment record creation');
                    }
                    
                    /******************Create learning plan section assignments***********/
                    
                    for(redwing__Training_Plan_Section__c trpsec:trpseclst) {
                        //if (trpsec.containskey(learningPlanId)) {
                            redwing__Training_Plan_Section_Assignment__c lpsAssignment = new redwing__Training_Plan_Section_Assignment__c();
                            
                            if (userMap.containsKey((student.LastName+student.FirstName+student.Email).toLowerCase())) {
                                lpsAssignment.redwing__User__c = userMap.get((student.LastName+student.FirstName+student.Email).toLowerCase()).Id;// Converting to lower case since map seems to be case sensitive
                            } else {
                                lpsAssignment.redwing__User__r = fetchUser(student, true);// Create new user or use exisitng method called          
                                //lpsAssignment.redwing__User__r = new User(DM_External_Id__c = student.FirstName+student.lastName+student.Email);// Create new user or use exisitng method called
                            }
                            
                            if(String.IsNotBlank(student.Voucherid) && studentvoucherMap.containskey(student.voucherid)) {
                                if (!onlineCourse) {
                                    lpsAssignment.External_Id__c = student.Email+student.LastName+student.FirstName+studentvoucherMap.get((student.voucherid)).ILT_Class__c+String.valueOf(trpsec.redwing__Order__c);
                                } else {
                                    lpsAssignment.External_Id__c = student.Email+student.LastName+student.FirstName+studentvoucherMap.get((student.voucherid)).Online_Class__c+String.valueOf(trpsec.redwing__Order__c);
                                }
                            } else {
                                lpsAssignment.External_Id__c = student.Email+student.lastName+student.FirstName+classId+String.valueOf(trpsec.redwing__Order__c);
                            }
                            
                            lpsAssignment.redwing__Training_Plan_Section__c = trpsec.Id; // get(learningPlanId);
                            
                            String lpAssignmentExternalId = '';
                            if (String.IsNotBlank(student.Voucherid) && studentvoucherMap.containskey(student.voucherid)) {
                                if (!onlineCourse) {
                                    lpAssignmentExternalId = student.Email+student.LastName+student.FirstName+studentvoucherMap.get((student.voucherid)).ILT_Class__c;
                                } else {
                                    lpAssignmentExternalId = student.Email+student.LastName+student.FirstName+studentvoucherMap.get((student.voucherid)).Online_Class__c;
                                }
                            } else { 
                                lpAssignmentExternalId = student.Email+student.lastName+student.FirstName+classId;
                            }                        
                            lpsAssignment.redwing__Training_Plan_Assignment__r = new redwing__Training_Plan_Assignment__c(External_Id__c = lpAssignmentExternalId);
                            
                            lpsAssignmentList.add(lpsAssignment);
                            System.debug('lp section assignment record creation');
                            System.debug('lpsAssignmentList values:'+lpsAssignment.redwing__User__c+','+lpsAssignment.redwing__Training_Plan_Section__c+','+lpsAssignment.redwing__Training_Plan_Assignment__c);
                        }
                    //}
                    System.debug('lpsAssignmentList values'+lpsAssignmentList.size());
                }


                if (!isLearnToSwimProduct) {
                    if (blend == true || cre == true || other == true || onlineCourse) {
                        //if(student.Grade=='Successful'||student.Grade==''){
                        /**************Creating Achievemnt Assignment Records**************/
                        System.debug('Achievement assignment record creation');
                        //for(redwing__Training_Plan_Achievement__c rtpa:[select id, Name, redwing__Achievement__c from redwing__Training_Plan_Achievement__c where redwing__Training_Plan__c=: learningPlanId])

                        if (mapTrainingPlanWithTrainingPlanAchievements.containskey(learningPlanId)) {
                            for(redwing__Training_Plan_Achievement__c rtpalist : mapTrainingPlanWithTrainingPlanAchievements.get(learningPlanId)){
                                System.debug('Going to create Achievement assignment');

                                redwing__Achievement_Assignment__c rac = new redwing__Achievement_Assignment__c();
                                rac.redwing__Training_Plan_Achievement__c = rtpalist.id;

                                if (blend == true || other == true || onlineCourse) {
                                    if (userMap.containsKey((student.LastName+student.FirstName+student.Email).toLowerCase())) {
                                        rac.redwing__User__c = userMap.get((student.LastName+student.FirstName+student.Email).toLowerCase()).Id;// Converting to lower case since map seems to be case sensitive
                                    } else {
                                        rac.redwing__User__r = fetchUser(student, true);// Create new user or use existing method called
                                        //rac.redwing__User__r = new User(DM_External_Id__c = student.FirstName+student.lastName+student.Email);// Create new user or use exisitng method called
                                    }
                                    // Populate contact
                                    // Contact matching logic is always LN+FN+Email
                                    /*
                                    if (String.IsBlank(student.Email) && contactMap.containsKey((student.LastName+student.FirstName).toLowerCase())){
                                        rac.redwing__Contact__c = contactMap.get((student.LastName+student.FirstName).toLowerCase()).Id;
                                    }
                                    else
                                    */

                                    if(String.IsNotBlank(student.Email) && contactEmailMap.containsKey((student.LastName+student.FirstName+student.Email).toLowerCase())){
                                        rac.redwing__Contact__c = contactEmailMap.get((student.LastName+student.FirstName+student.Email).toLowerCase()).Id;
                                    } else {
                                        rac.redwing__Contact__r = fetchContact(student, true);// Create new contact or use exisitng method called
                                    }

                                }

                                rac.Firstname__c = student.FirstName;
                                rac.Lastname__c = student.LastName;
                                rac.Email__c = student.Email;
                                rac.Phone__c = student.Phone;
                                rac.Account__c = AccountId;
                                rac.redwing__Status__c='Eligible';

                                if (blend == false && other== false && !onlineCourse && cre == true) {
                                    rac.Evaluation_Result__c = student.Grade;
                                    rac.Grade_Reason__c = Student.Fail_Reason;
                                    rac.Grade_Additional_Info__c = Student.AdditionalInfo;

                                    if (student.Grade=='Successful') {
                                        rac.redwing__Status__c='OnHold';

                                        // DE851 - Achievement Assignment Date should be class end date, not system date
                                        if (studentvoucherMap.containskey(student.voucherid)) {
                                            if (studentvoucherMap.get(student.voucherid).ILT_Class__r.redwing__End_Date__c != null) {
                                                rac.redwing__Acquisition_Date__c=studentvoucherMap.get(student.voucherid).ILT_Class__r.redwing__End_Date__c;
                                            } else {
                                                rac.redwing__Acquisition_Date__c=System.today();
                                            }
                                        }
                                    }
                                }

                                if (String.IsNotBlank(student.Voucherid) && studentvoucherMap.containskey(student.voucherid)) {
                                    if (!onlineCourse) {
                                        rac.ILT_Class__c = studentvoucherMap.get((student.voucherid)).ILT_Class__c;
                                        rac.External_Id__c = student.Email+student.LastName+student.FirstName+studentvoucherMap.get((student.voucherid)).ILT_Class__c;
                                    } else {
                                        rac.Online_Class__c = studentvoucherMap.get((student.voucherid)).Online_Class__c;
                                        rac.External_Id__c = student.Email+student.LastName+student.FirstName+studentvoucherMap.get((student.voucherid)).Online_Class__c;
                                    }
                                } else {
                                    rac.ILT_Class__c = classId;
                                    rac.External_Id__c = student.lastName+student.FirstName+student.Email+classId;
                                }
                                rac.redwing__Achievement__c =  rtpalist.redwing__Achievement__c;

                                System.debug('Achievement Assignment created' +rac.redwing__Achievement__c);
                                AchievementAssignmentList.add(rac);


                                System.debug('AchievementAssignmentListvalue '+AchievementAssignmentList);
                            }
                        }
                        //}
                    }
                }

                /**************Creating Roster Record******************************/   
                if (!onlineCourse && (blend == true || other == true)) {
                    System.debug('Roster record creation');
                    // Create roster records base on the request
                    /* if(String.IsNotBlank(student.Voucherid) && studentvoucherMap.containsKey(student.voucherid))
                    {
                        if(vILTClassSessionMap.containsKey(studentvoucherMap.get(student.voucherid).ILT_Class__c))
                        {
                        sessionlist= new list<redwing__ILT_Session__c>();
                        sessionlist.addall(vILTClassSessionMap.get(studentvoucherMap.get(student.voucherid).ILT_Class__c));
                        }
                    }
                    */ 
                    //System.debug('Sessionlistvaluesss' +se);
                    //for(redwing__ILT_Session__c ris:sessionlist)
                    //{
                    redwing__ILT_Roster__c objRoster = new redwing__ILT_Roster__c();
                    
                    if (String.IsNotBlank(student.Voucherid) && studentvoucherMap.containskey(student.voucherid)) {
                        System.debug('Inside session creation with voucher ');
                        // Need to record RCO Order Id and Voucher Id for eCommerce audit purposes and to support cancellation
                        objRoster.Voucher_Id__c = student.voucherid;
                        objRoster.redwing__ILT_Class__c = studentvoucherMap.get((student.voucherid)).ILT_Class__c;
                        //objRoster.redwing__ILT_Session__c = sessions.id;
                        objRoster.RCO_Order_Id__c = studentvoucherMap.get((student.voucherid)).RCO_Order_Id__c;
                    } else {
                        System.debug('Inside session creation without voucher id in roster');
                        objRoster.Voucher_Id__c = voucheridsrbc[countValue];
                        objRoster.redwing__ILT_Class__c = classId;
                        //objRoster.redwing__ILT_Session__c = sessionId;
                    }
                    
                    // Populate voucher id of
                    
                    
                    if (userMap.containsKey((student.LastName+student.FirstName+student.Email).toLowerCase())) {
                        objRoster.redwing__User__c = userMap.get((student.LastName+student.FirstName+student.Email).toLowerCase()).Id;// Converting to lower case since map seems to be case sensitive
                    } else {
                        objRoster.redwing__User__r = fetchUser(student, true);// Create new user or use exisitng method called
                    }
                    
                    // objRoster.redwing__User__r = planAssignment.redwing__User__r;
                    if (String.IsNotBlank(student.Voucherid) && studentvoucherMap.containskey(student.voucherid)) {
                        objRoster.redwing__Learning_Assignment__r = new redwing__Learning_Assignment__c(External_Id__c = student.Email+student.LastName+student.FirstName+studentvoucherMap.get((student.voucherid)).ILT_Class__c+studentvoucherMap.get((student.voucherid)).ILT_Class__r.redwing__Learning__c); //Can be chaged if needed);
                    } else {
                        objRoster.redwing__Learning_Assignment__r = new redwing__Learning_Assignment__c(External_Id__c = student.Email+student.LastName+student.FirstName+classId+classLearningId);
                    }
                    
                    System.debug('Roster added');
                    rosterList.add(objRoster);         
                    System.debug('Roster session ids'+rosterList[0].redwing__ILT_Session__c);
                    //}
                }
                
                if (blend == true || other == true) {
                    /************Update voucher if its claimed***************/
                    if (String.IsNotBlank(student.voucherid) && studentvoucherMap.containskey(student.voucherid)||voucheridsrbc!=null) {
                        if (String.IsNotBlank(student.voucherid)) {
                            voucheridsrbc = new list<id>();
                            System.debug('Studentvouchermapcontainsvalues'+studentvoucherMap.get(student.Voucherid).id);
                            voucheridsrbc.add(studentvoucherMap.get(student.Voucherid).id);
                        }
                        
                        voucher__c claimvoucher = new voucher__c();
                        if (String.IsNotBlank(student.voucherid)) {
                            claimvoucher.id=studentvoucherMap.get(student.Voucherid).id;
                        } else {
                            claimvoucher.id=voucheridsrbc[countValue];
                        }
                        
                        if (claimVoucher.User__c == null) {
                            if (userMap.containsKey((student.LastName+student.FirstName+student.Email).toLowerCase())) {
                                claimvoucher.user__c = userMap.get((student.LastName+student.FirstName+student.Email).toLowerCase()).Id;            
                            } else {
                                claimvoucher.user__r = new User(DM_External_Id__c = (student.LastName+student.FirstName+student.Email).toLowerCase());
                            }
                        }
                        claimvoucher.Status__c = 'claimed';
                        voucherclaimset.add(claimvoucher);
                    }
                }
                system.debug('accList++++++++++++++++++++++++'+accList);
                system.debug('inserted user'+lstUser); 
            }
            
            
            // Insert Records for User contact and Account if it does not exist and learning assignment list and roster records   
            try {
                if (accList.size() > 0) {
                    system.debug('accList++++++++++++++++++++++++'+accList);
                    insert accList;
                    system.debug('conList++++++++++++'+conList);
                    insert conList;      
                }
            }
            catch (Exception e) {
                errmsgvc=true;
                if (e.getMessage().contains('Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, US Mobile numbers should be in this format: (999) 999-9999: [MobilePhone]'))
                {        
                    System.debug('phone number exception');
                    if (auraException) throw new AuraHandledException('Please provide a valid mobile number format-(999) 999-9999'); else throw new enrollException('Please provide a valid mobile number format-(999) 999-9999');
                }
                else if(e.getMessage().contains('Insert failed. First exception on row 0; first error: INVALID_EMAIL_ADDRESS, Email: invalid email address:'))
                {
                    System.debug('Email exception');
                    if (auraException) throw new AuraHandledException('Please provide a valid email address'); else throw new enrollException('Please provide a valid email address');
                }
                else
                {
                    System.debug('exception caught: ' + e.getMessage() + ' lineNumber=' + e.getLineNumber() + ' stackTrace=' + e.getStackTraceString());
                    if (auraException) throw new AuraHandledException(e.getMessage()); else throw new enrollException(e.getMessage());
                }
            }
            
            try {
                if(lstUser.size() > 0 && errmsgvc!=true ){
                    uidlist = new list<id>();
                    System.debug('PROFILE id'+lstUser);
                    insert lstUser;
                    system.debug('inserted user'+lstUser);  
                    for(user u:lstuser)
                    {
                        uidlist.add(u.id);
                    }
                    assignUserPermission(uidlist);
                }
            }
            catch(Exception e){
                errmsgvc=true;
                if(e.getMessage().contains('Insert failed. First exception on row 0; first error: INVALID_EMAIL_ADDRESS, Email: invalid email address:'))
                {
                    System.debug('phone number exception');
                    if (auraException) throw new AuraHandledException('Please provide a valid email address'); else throw new enrollException('Please provide a valid email address');
                }
                else
                {
                    if (auraException) throw new AuraHandledException(e.getMessage()); else throw new enrollException(e.getMessage());
                }
            }
            
            try {
                if(assignmentList.size() > 0 && errmsgvc!=true){
                    insert assignmentList;  
                    System.debug('Value of Contact and user'+assignmentList);      
                }  
            }
            catch(Exception e){
                errmsgvc=true;
                if(e.getMessage().contains('Insert failed. First exception on row 0; first error: DUPLICATE_VALUE, duplicate value found: External_Id__c duplicates value on record with id:'))
                { 
                    System.debug('this exception');
                    if (auraException) throw new AuraHandledException('You are already assigned to this class'); else throw new enrollException('You are already assigned to this class');
                }
                else
                {
                    if (auraException) throw new AuraHandledException(e.getMessage()); else throw new enrollException(e.getMessage());
                }
            }
            
            try{  
                if(lpsAssignmentList.size() > 0 && errmsgvc!=true){
                    //System.debug('lpsAssignmentList outside'+lpsAssignmentList);
                    System.debug('Going to insert lal');
                    insert lpsAssignmentList;
                    System.debug('lpsAssignmentList outside'+lpsAssignmentList.size());
                }
            }catch(Exception e){
                errmsgvc=true;
                if(e.getMessage().contains('Insert failed. First exception on row 0; first error: DUPLICATE_VALUE, duplicate value found: External_Id__c duplicates value on record with id:'))
                {
                    if (auraException) throw new AuraHandledException('You are already assigned to this class'); else throw new enrollException('You are already assigned to this class');
                }
                else
                {
                    if (auraException) throw new AuraHandledException(e.getMessage()); else throw new enrollException(e.getMessage());
                }
            }
                        
            try {  
                if(learningAssignmentList.size() > 0 && errmsgvc!=true){
                    System.debug('Going to insert lal');
                    
                    // DE822 - Allow reinstatement of cancelled registration - Learning Assignment is retained on cancel
                    Schema.SObjectField f = redwing__Learning_Assignment__c.Fields.External_Id__c;
                    Database.UpsertResult[] results = Database.upsert(learningAssignmentList, f, false);                    
                    //insert learningAssignmentList;
                    
                    //System.debug('Inserted learning assignment list' +learningAssignmentList);
                    System.debug('Inserted learning assignment list' +results);
                }
            } catch(Exception e){
                errmsgvc=true;
                if(e.getMessage().contains('Insert failed. First exception on row 0; first error: DUPLICATE_VALUE, duplicate value found: External_Id__c duplicates value on record with id:'))
                {
                    if (auraException) throw new AuraHandledException('You are already assigned to this class'); else throw new enrollException('You are already assigned to this class');
                }
                else
                {
                    if (auraException) throw new AuraHandledException(e.getMessage()); else throw new enrollException(e.getMessage());
                }
            }
            
            try{  
                if(AchievementAssignmentList.size() > 0 && errmsgvc!=true){
                    
                    System.debug('AchievementAssignmentListvaluee 1'+AchievementAssignmentList);
                    insert AchievementAssignmentList;
                    System.debug('Inserted Achievement list' +AchievementAssignmentList);
                }
            }catch(Exception e){
                System.debug('Exception As>>>> ');
                errmsgvc=true;
                if(e.getMessage().contains('Insert failed. First exception on row 0; first error: DUPLICATE_VALUE, duplicate value found: External_Id__c duplicates value on record with id:'))
                {
                    if (auraException) throw new AuraHandledException('You are already assigned to this Achievement assignment'); else throw new enrollException('You are already assigned to this class');
                }
                else
                {
                    if (auraException) throw new AuraHandledException(e.getMessage()); else throw new enrollException(e.getMessage());
                }
            }
            
            try{
                System.debug('Trying to create rosters>>>> ');
                if(rosterList.size() > 0 && errmsgvc!=true){                
                    insert rosterList;
                    System.debug('Inserted roster' +rosterList);
                }
            }
            catch(Exception e){
                System.debug('Exception rosters>>>> ');
                errmsgvc=true;
                if(e.getMessage().contains('Insert failed. First exception on row 0; first error: DUPLICATE_VALUE, duplicate value found: External_Id__c duplicates value on record with id:'))
                {
                    if (auraException) throw new AuraHandledException('You are already assigned to this class'); else throw new enrollException('You are already assigned to this class');
                }
                else
                {
                    if (auraException) throw new AuraHandledException(e.getMessage()); else throw new enrollException(e.getMessage());
                }
            }
            
            try {
                if(voucherclaimset.size() > 0 && errmsgvc!=true)
                {
                    System.debug('Created vouchers>>>> ');
                    update voucherclaimset;
                    System.debug('Inserted Voucher list' +voucherclaimset);
                }
            }
            catch(Exception e){
                System.debug('Exception vouchers>>>> ');
                errmsgvc=true;
                if(e.getMessage().contains('Insert failed. First exception on row 0; first error: DUPLICATE_VALUE, duplicate value found: External_Id__c duplicates value on record with id:'))
                {
                    if (auraException) throw new AuraHandledException('You are already assigned to this class'); else throw new enrollException('You are already assigned to this class');
                }
                else
                {
                    if (auraException) throw new AuraHandledException(e.getMessage()); else throw new enrollException(e.getMessage());
                }
            }
            
        }
        auraException = true; 
        onlineCourse = false;
    }
    
    // Updating Student Grades and Progress in all assignments of Learning plans
    @AuraEnabled
    public static void assignGrades(String JSON, String SupInfo, Boolean closeclass){
        List<JSONWrapper.Students> studentGradeList = JSONWrapper.arrayOfStudents(System.JSON.createParser(json));
        
        set<string> Rosterids= new set<string>();
        String grade;
        id learningplid;
        Map<id,id> Learnignassignmentmapids;
        Map<id, redwing__ILT_Roster__c> rosterMap;
        String iltClassid;
        redwing__ILT_Class__c rosterILTClass;
        List<redwing__Training_Plan_Assignment__c> lpalist;
        List<redwing__Training_Plan_Assignment__c> lpaliststaus;
        List<redwing__Training_Plan_Section_Assignment__c> statusLearningplansectionAsslist;
        List<redwing__Training_Plan_Section__c> Learningplansectionlist;
        List<redwing__Achievement_Assignment__c> statusAchAsslist;

        Set<Id> updatedOrderItemIds = new Set<Id>();
        Set<Id> updatedOrderIds = new Set<Id>();
        List<ccrz__E_OrderItem__c> updatedOrderItems = new List<ccrz__E_OrderItem__c>();
        List<ccrz__E_Order__c> updatedOrders = new List<ccrz__E_Order__c>();

        Map<id,id> rostermapusers;
        Map<id,list<id>> rtpsamap;
        Map<id,id> rtpamap;
        Map<id,list<id>> mapUserWithAchievementAssignmentList = new Map<id,list<id>>();

        learningAssignmentList = new list<redwing__Learning_Assignment__c>();
        statusLearningplansectionAsslist = new list<redwing__Training_Plan_Section_Assignment__c>();
        statusAchAsslist = new list<redwing__Achievement_Assignment__c>();
        rostermapusers = new map<id,id>();
        rtpsamap = new map<id,list<id>>();
        rtpamap = new map<id,id>();
        
        //Get the values of Rosterids
        for(JSONWrapper.Students student : studentGradeList){
            if(student.Roster!= null)
            {
                Rosterids.add(student.Roster);
            }  
        }
        
        Learnignassignmentmapids = new Map<id,id>();
        lpalist = new list<redwing__Training_Plan_Assignment__c>();
        Learningplansectionlist = new List<redwing__Training_Plan_Section__c>();
        lpaliststaus = new List<redwing__Training_Plan_Assignment__c>();
        rosterMap = new Map<id, redwing__ILT_Roster__c>();
        
        //Get the value of Learning assignments associated with each Roster record
        if (!Rosterids.isEmpty()) {
            for(redwing__ILT_Roster__c r : [Select Id, redwing__User__c, redwing__Learning_Assignment__c, redwing__ILT_Class__c, redwing__ILT_Class__r.redwing__End_Date__c, 
                redwing__Learning_Assignment__r.redwing__Training_Plan__c, redwing__ILT_Class__r.Request_Type__c from redwing__ILT_Roster__c where id IN: Rosterids]){
                rostermapusers.put(r.id,r.redwing__User__c);
                Learnignassignmentmapids.put(r.id,r.redwing__Learning_Assignment__c);
                iltClassid = r.redwing__ILT_Class__c;
                learningplid = r.redwing__Learning_Assignment__r.redwing__Training_Plan__c;
                rosterMap.put(r.id, r);
            }
            
            for(redwing__Training_Plan_Section_Assignment__c tpsa : [Select id, name, redwing__User__c, External_Id__c from redwing__Training_Plan_Section_Assignment__c where External_Id__c like :('%' + iltClassid + '%')]) {
                list<id> lstRTPSA = new list<id>();
                if(rtpsamap.containsKey(tpsa.redwing__User__c)) {
                    lstRTPSA = rtpsamap.get(tpsa.redwing__User__c);
                } 
                lstRTPSA.add(tpsa.id);   
                rtpsamap.put(tpsa.redwing__User__c,lstRTPSA);                  
            }            
          
            for(redwing__Training_Plan_Assignment__c rpa: [Select id, name, redwing__User__c, External_Id__c from redwing__Training_Plan_Assignment__c where External_Id__c like :('%' + iltClassid) ])
            {
                rtpamap.put(rpa.redwing__User__c,rpa.id);            
            }

            List<redwing__ILT_Class__c> theRosterILTClassList = [Select Id, Name, Opportunity__c, Request_Type__c From redwing__ILT_Class__c Where Id = :iltClassid Limit 1];
            rosterILTClass = theRosterILTClassList[0];
        }
        
        for(redwing__Achievement_Assignment__c aa: [Select id, name, redwing__User__c, External_Id__c from redwing__Achievement_Assignment__c where External_Id__c like :('%' + iltClassid) ])
        {         
            list<id> lstAAID = new list<id>();
            if(mapUserWithAchievementAssignmentList.containsKey(aa.redwing__User__c)){
                lstAAID = mapUserWithAchievementAssignmentList.get(aa.redwing__User__c);
            } 
            lstAAID.add(aa.id);
            mapUserWithAchievementAssignmentList.put(aa.redwing__User__c,lstAAID);
        }
        
            System.debug('rostermapusers'+rostermapusers);
            System.debug('Learnignassignmentmapids'+Learnignassignmentmapids);
            System.debug('mapUserWithAchievementAssignmentList'+mapUserWithAchievementAssignmentList);
            System.debug('rtpsamap'+rtpsamap);
            System.debug('rtpamap'+rtpamap);
            System.debug('rosterMap='+rosterMap);            

            
        // Update ILTClass with SuppInfo and Close Date
        if (String.isNotEmpty(iltClassid)) {
            redwing__ILT_Class__c iltclassupinfo = new redwing__ILT_Class__c(); 
            iltclassupinfo.id = iltClassid;
            iltclassupinfo.Class_Closed_Date__c = DateTime.Now();
            if (String.isNotEmpty(SupInfo)) {
                iltclassupinfo.Supplemental_Information__c = SupInfo;
            }
            update iltclassupinfo;
        }
        
        // Loop through each student details to assign grades for each student in Learning assignment
        for(JSONWrapper.Students student : studentGradeList){
            if(!Rosterids.isEmpty()){
                
                //Update a learning assignment 
                redwing__Learning_Assignment__c learningAssignment = new redwing__Learning_Assignment__c();
                learningAssignment.id=Learnignassignmentmapids.get(student.Roster);
                learningAssignment.redwing__Evaluation_Result__c = student.Grade;
                learningAssignment.Grade_Reason__c = Student.Fail_Reason; // Retrieve learning id from page 1
                grade = student.Grade;
                learningAssignment.Grade_Additional_Info__c = student.AdditionalInfo; //Can be chaged if needed
                
                if (grade == 'Successful') {
                    learningAssignment.redwing__Progress__c = 'Completed';
                    learningAssignment.redwing__Progress_Percentage__c = 100;
                }
                
                // DE851 - Completed On Date should be class end date, not system date                
                if (rosterMap.containskey(student.Roster)) {
                    if (rosterMap.get(student.Roster).redwing__ILT_Class__r.redwing__End_Date__c != null) {
                        learningAssignment.redwing__Completed_On__c=rosterMap.get(student.Roster).redwing__ILT_Class__r.redwing__End_Date__c;
                    } else {
                        learningAssignment.redwing__Completed_On__c=System.today();
                    }
                } 

                learningAssignmentList.add(learningAssignment);
                
                // Update learning plan Assignment as complete   
                if(rtpamap.containskey(rostermapusers.get(student.Roster)))
                { 
                    redwing__Training_Plan_Assignment__c lpa = new redwing__Training_Plan_Assignment__c();
                    lpa.id=rtpamap.get(rostermapusers.get(student.Roster));
                    if(grade == 'Successful')
                    {
                        lpa.redwing__Progress_Percentage__c = 100;
                        lpa.redwing__Status__c='completed';
                    }
                    
                    // DE851 - Completed On Date should be class end date, not system date
                    if (rosterMap.containskey(student.Roster)) {
                        if (rosterMap.get(student.Roster).redwing__ILT_Class__r.redwing__End_Date__c != null) {
                            lpa.redwing__Completed_On__c=rosterMap.get(student.Roster).redwing__ILT_Class__r.redwing__End_Date__c;
                        } else {
                            lpa.redwing__Completed_On__c=System.today();
                        }
                    }                     
                    
                    lpaliststaus.add(lpa);
                }
                
                // Update learning plan Section Assignment as complete
                if(rtpsamap.containskey(rostermapusers.get(student.Roster))){
                    for (Id theRTPSAid : rtpsamap.get(rostermapusers.get(student.Roster))) {
                        redwing__Training_Plan_Section_Assignment__c rt = new redwing__Training_Plan_Section_Assignment__c();
                        rt.id = theRTPSAid;
                    
                        if(grade == 'Successful'){
                            rt.redwing__Status__c='completed';
                        }
                    
                        // DE851 - Completed On Date should be class end date, not system date
                        if (rosterMap.containskey(student.Roster)) {
                            if (rosterMap.get(student.Roster).redwing__ILT_Class__r.redwing__End_Date__c != null) {
                                rt.redwing__Completed_On__c=rosterMap.get(student.Roster).redwing__ILT_Class__r.redwing__End_Date__c;
                            } else {
                                rt.redwing__Completed_On__c=System.today();
                            }
                        }  

                        statusLearningplansectionAsslist.add(rt);
                    }
                }
                
                //Update Achievement Assignment as complete
                if(rtpsamap.containskey(rostermapusers.get(student.Roster))){
                    if(mapUserWithAchievementAssignmentList.containsKey(rostermapusers.get(student.Roster))){
                        for(id aid : mapUserWithAchievementAssignmentList.get(rostermapusers.get(student.Roster))){
                            redwing__Achievement_Assignment__c aca = new redwing__Achievement_Assignment__c();
                            aca.id = aid;
                            aca.Evaluation_Result__c = grade;
                            
                            if(grade == 'Successful'){    
                                // US1521 - For non-Community and FS classes, set achievement assignment status
                                // to OnHold rather than Acquired.  This will be modified by downstream
                                // business processes once the account has been authorized                                                      
                                String classRequestType = rosterMap.get(student.Roster).redwing__ILT_Class__r.Request_Type__c;
                                if (classRequestType.contains('Community') || classRequestType.contains('Full Service')) {
                                    aca.redwing__Status__c='Acquired';
                                } else {
                                    aca.redwing__Status__c='OnHold';
                                }
                                
                                // DE851 - Completed On Date should be class end date, not system date
                                if (rosterMap.containskey(student.Roster)) {
                                    System.debug('rosterMap.get(student.Roster).redwing__ILT_Class__r.redwing__End_Date__c'+rosterMap.get(student.Roster).redwing__ILT_Class__r.redwing__End_Date__c);
                                    if (rosterMap.get(student.Roster).redwing__ILT_Class__r.redwing__End_Date__c != null) {
                                        aca.redwing__Acquisition_Date__c=rosterMap.get(student.Roster).redwing__ILT_Class__r.redwing__End_Date__c;
                                    } else {
                                        aca.redwing__Acquisition_Date__c=System.today();
                                    }
                                }   
                            }
                            if(aca.Id!=NULL){
                                statusAchAsslist.add(aca);
                            }
                        }
                    }
                }
            }
            System.debug('**** Close Class:'+closeClass);
            System.debug('**** rosterILTClass.Opp:'+rosterILTClass.Opportunity__c);

            if (closeClass) {
                // US1521 - Populate CC Cart Item Record(s) with ILT Class Id (if applicable)
                Id orderId;
                if (rosterILTClass != null && rosterILTCLass.Opportunity__c != null) {
                    // US1521 - For close class, Order Lines should already be created
                    // In this case, we need to write ILT Class Id on Order Item record(s)
                    // Skip for FS classes; assignment of ILT Class Id was performed when class was originally created
                    if (rosterILTCLass.Request_Type__c != 'Full Service') {
                        for (ccrz__E_OrderItem__c theOrderItem : [
                                Select Id, ccrz__Product__c, ILT_Class__c, ccrz__Order__c
                                From ccrz__E_OrderItem__c
                                Where ccrz__Order__r.ccrz__OriginatedCart__r.Opportunity__c = :rosterILTClass.Opportunity__c
                        ]) {
                            System.debug('*** non-FS orderItem:' + theOrderItem);
                            if (!updatedOrderItemIds.contains(theOrderItem.Id)) {
                                ccrz__E_OrderItem__c newOrderItem = new ccrz__E_OrderItem__c();
                                newOrderItem.Id = theOrderItem.Id;
                                newOrderItem.ILT_Class__c = rosterILTClass.Id;
                                updatedOrderItems.add(newOrderItem);
                                updatedOrderItemIds.add(theOrderItem.Id);
                                orderId = theOrderItem.ccrz__Order__c;
                                System.debug('*** non-FS updatedOrderItems:' + updatedOrderItems);
                            }
                        }

                        // Extension - provide linkage to external flows that order items were updated with ILT Class Id by updating
                        // boolean on order header record
                        if (!updatedOrderItems.isEmpty() && orderId != null) {
                            if (!updatedOrderIds.contains(orderId)) {
                                ccrz__E_Order__c newOrder = new ccrz__E_Order__c();
                                newOrder.Id = orderId;
                                newOrder.CRE_Request_Processed__c = true;
                                updatedOrders.add(newOrder);
                                updatedOrderIds.add(orderId);
                                System.debug('*** non-FS updatedOrders:' + updatedOrders);
                            }
                        }
                    }
                }
            }
        }
        
        // *** US1517 - Deactivate all remaining (unused) vouchers for this class
        
        // Generate list of unused vouchers for this class
        List<String> ClaimedStatuses = System.label.ClaimedVoucherTypes.split(';');   
        List<Voucher__c> lstVouchersToUpdate = new List<Voucher__c>();    
        
        if (iltClassid != null)
        { 
            List<Voucher__c> unclaimedVouchers = [SELECT Id,
                                                         Name,
                                                         Status__c,
                                                         ILT_Class__r.Request_Type__c
                                                    FROM Voucher__c
                                                   WHERE ILT_Class__c = :iltClassid
                                                     AND Status__c
                                                     NOT IN :ClaimedStatuses];
            
            for (Voucher__c theVoucher : unclaimedVouchers)
            {
                voucher__c theUpdatedVoucher = new voucher__c();
                
                theUpdatedVoucher.Id        = theVoucher.Id;
                theUpdatedVoucher.Status__c = 'Void'; 

                lstVouchersToUpdate.add(theUpdatedVoucher);
            }
            
            if(lstVouchersToUpdate.size() > 0)
            {
                update lstVouchersToUpdate;
            }
        }
        
        // *** End of US1517
                
        // Update the assignment records with the grade
        if(learningAssignmentList.size() > 0){
            update learningAssignmentList;
        }
        if(statusLearningplansectionAsslist.size() > 0){
            update statusLearningplansectionAsslist;
        }
        if(lpaliststaus.size() > 0){
            update lpaliststaus;
        }
        if(statusAchAsslist.size() > 0){
            upsert statusAchAsslist;
        }

        if (updatedOrderItems.size() > 0) {
            update updatedOrderItems;
        }

        if (updatedOrders.size() > 0) {
            update updatedOrders;
        }
    }
    
    
    // Creating a new user with the profile having the name as "Customer community User"
    // boolRetVal == true -> Returns an Id for a user record created earlier in this run having a given external Id
    // consisting of first name+last name+email address
    
    // Note: this function is overloaded (fetchUser() and fetchUser(JSONWrapper.Students, Boolean))
    
    public Static User fetchUser(JSONWrapper.Students student, Boolean boolRetVal){
        //String removespaces;
        //removespaces = (student.FirstName+student.lastName+student.Email).deleteWhitespace();
        if(boolRetVal){
            // Return existing user record Id, if one exists
            if (userMap.containsKey((student.LastName+student.FirstName+student.Email).toLowerCase())) {
                return userMap.get((student.LastName+student.FirstName+student.Email).toLowerCase());
            } else {
                // Else return pointer to new user record being created in this process     
                return new User(DM_External_Id__c = (student.LastName+student.FirstName+student.Email).toLowerCase());
            }
        }
        else {
            System.debug('fetchUser - creating new user');
            // Populate external Id only if user's contact is being created in this process
            //contactEmailMap.containsKey((student.LastName+student.FirstName+student.Email)            
            
            // DE512 - Base user name on user's email address.  Add a numeric suffix to make it unique
            String newUserName = fetchUserName(student);  // Retrieve username to be used for new user
            User usr;
            
            if (fetchContact(student, true).Id != null) {
                     usr = new User(LastName = student.LastName,
                                    FirstName = student.FirstName,
                                    Alias = 'Student',
                                    Email = student.Email,
                                    Username = newUserName,                                
                                    //Username = student.FirstName+student.lastName+student.Email,
                                    ProfileId = profileId.id,
                                    // Profile = profileId,
                                    contactId = fetchContact(student, true).Id,
                                    Phone = student.Phone,
                                    TimeZoneSidKey = 'GMT',
                                    LanguageLocaleKey = 'en_US',
                                    EmailEncodingKey = 'UTF-8',
                                    LocaleSidKey = 'en_US',
                                    DM_External_Id__c = (student.LastName+student.FirstName+student.Email).toLowerCase()
                                   );
            } else {
                     usr = new User(LastName = student.LastName,
                                    FirstName = student.FirstName,
                                    Alias = 'Student',
                                    Email = student.Email,
                                    Username = newUserName,                                
                                    //Username = student.FirstName+student.lastName+student.Email,
                                    ProfileId = profileId.id,
                                    // Profile = profileId,
                                    contact = fetchContact(student, true),
                                    Phone = student.Phone,
                                    TimeZoneSidKey = 'GMT',
                                    LanguageLocaleKey = 'en_US',
                                    EmailEncodingKey = 'UTF-8',
                                    LocaleSidKey = 'en_US',
                                    DM_External_Id__c = (student.LastName+student.FirstName+student.Email).toLowerCase()
                                   );               
            } 
            lstUser.add(usr);
            
            return new User(DM_External_Id__c = (student.LastName+student.FirstName+student.Email).toLowerCase());
        }
    }
    
    // DE512 - Base user name on user's email address.  Add a numeric suffix to make it unique    
    public static String fetchUserName(JSONWrapper.Students student) {
        String newUserName = '';
        
        // Check to see if a user name for this student's email address has already been assigned to a previous student
        // userNameEmailMap == {user name, email address}
        if (!userNameEmailMap.containsKey(student.Email)) {
            // email address has never been used as a user name, use this for new user          
            newUserName = student.Email; 
        } else {
            // email address has already been used as a user name, create unique suffix
            Pattern emailDomainPattern = Pattern.compile('^(.*?)(@.*)'); // Isolate email address domain (group 1)
            Matcher emailDomainMatcher = emailDomainPattern.matcher(student.Email);
            
            if (emailDomainMatcher.matches() && emailDomainMatcher.groupCount() >=2) {
                String newUserHandle = emailDomainMatcher.group(1);
                String newUserDomain = emailDomainMatcher.group(2);
                Integer newUserHandleSuffix = 1; // Start new handle suffix at 001
                System.debug('*** newUserHandle:'+newUserHandle);
                System.debug('*** newUserDomain:'+newUserDomain);
                
                Pattern handleSuffixPattern = Pattern.compile('^(.*?)([0-9]*)(\\@.*)');
                for (String theUserName : userNameEmailMap.keySet()) {
                    Matcher handleSuffixMatcher = handleSuffixPattern.matcher(theUserName);
                    if (handleSuffixMatcher.matches() && handleSuffixMatcher.groupCount() >= 3) {
                        System.debug('*** handleSuffixMatcher.group(1):'+handleSuffixMatcher.group(1));
                        System.debug('*** handleSuffixMatcher.group(2):'+handleSuffixMatcher.group(2));                     
                        
                        String existingUserHandle = handleSuffixMatcher.group(1);
                        if (existingUserHandle != newUserHandle) {
                            continue; // Throw out unrelated user name
                        } else {
                            Integer existingUserHandleSuffix = 0;
                            if (String.isNotBlank(handleSuffixMatcher.group(2))) {
                                existingUserHandleSuffix = Integer.valueOf(handleSuffixMatcher.group(2));
                                if (existingUserHandleSuffix >= newUserHandleSuffix) newUserHandleSuffix = existingUserHandleSuffix+1;
                            }
                        }
                    }
                }
                String newUserHandleSuffixStr = String.valueOf(newUserHandleSuffix);
                if (newUserHandleSuffixStr.length() < 3) {
                    if (newUserHandleSuffixStr.length() == 1)  newUserHandleSuffixStr = '00'+ newUserHandleSuffixStr;
                    if (newUserHandleSuffixStr.length() == 2)  newUserHandleSuffixStr = '0' + newUserHandleSuffixStr;                   
                }
                newUserName = newUserHandle + newUserHandleSuffixStr + newUserDomain;
            }
        }
        
        System.debug('newUserName' + newUserName);
        
        // For whatever reason if username was not assigned create a new name with a unique suffix
        if (String.isBlank(newUserName)) {
           newUserName = student.Email+String.valueOf(DateTime.Now().getTime()); // assign some random suffix (unix timestamp)
        }
      
        // DE866 - Issue enrolling students - add newly assigned username to validation map (userNameEmailMap)
        userNameEmailMap.put(newUserName, student.Email);   

        return newUserName;
    }
    
    // Assign Permission sets to users
    @future
    public static void assignUserPermission(List<id> lstUsere)
    {  
        try{
            /*********Get map of permission sets to assign to user*********/
            Map<String,id> permissionSetMap = new Map<String,id>();
            permissionSetAssList = new list<PermissionSetAssignment>();
            set<string> myString = new Set<String>{'LMS_External_User', 'LMS_Player_User', 'Player_User', 'ViewTrac_Lightning_UI_User'};
                for(PermissionSet p:[SELECT Id, Name FROM PermissionSet WHERE Name IN: myString])
            {
                System.debug('Map Valuessss'+p.name);
                permissionSetMap.put(p.name,p.id);
            }
            for(id u:lstUsere){
                if(permissionSetMap.containskey('LMS_External_User'))
                {
                    System.debug('Get in');
                    PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = permissionSetMap.get('LMS_External_User'), AssigneeId = u);
                    System.debug('id1 assigned'+psa.PermissionSetId );
                    permissionSetAssList.add(psa);
                }
                if(permissionSetMap.containskey('LMS_Player_User'))
                {
                    System.debug('Get in2');
                    PermissionSetAssignment psb = new PermissionSetAssignment(PermissionSetId = permissionSetMap.get('LMS_Player_User'), AssigneeId = u);
                    permissionSetAssList.add(psb);
                    System.debug('id2 assigned'+psb.PermissionSetId );
                }
                if(permissionSetMap.containskey('Player_User'))
                {
                    System.debug('Get in3');
                    PermissionSetAssignment psc = new PermissionSetAssignment(PermissionSetId = permissionSetMap.get('Player_User'), AssigneeId = u);
                    permissionSetAssList.add(psc);
                    System.debug('id3 assigned'+psc.PermissionSetId );
                }
                if(permissionSetMap.containskey('ViewTrac_Lightning_UI_User'))
                {
                    System.debug('Get in3');
                    PermissionSetAssignment psd = new PermissionSetAssignment(PermissionSetId = permissionSetMap.get('ViewTrac_Lightning_UI_User'), AssigneeId = u);
                    permissionSetAssList.add(psd);
                    System.debug('id4 assigned'+psd.PermissionSetId );
                }
            } 
            insert permissionSetAssList;
        }catch(Exception e){
            //errmsgvc=true;
            System.debug('msg..'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    
    
    // Creating Account and Contact if student does not exist or return if its already existing
    public Static Contact fetchContact(JSONWrapper.Students student, Boolean ret){
        
        if(ret){
            // Return user's existing contact Id, if one exists
            if(String.IsNotBlank(student.Email) && contactEmailMap.containsKey((student.LastName+student.FirstName+student.Email).toLowerCase())){
                return contactEmailMap.get((student.LastName+student.FirstName+student.Email).toLowerCase());
            } else { 
                // Else return internal pointer to new contact record being created in this process             
                return new Contact(DM_External_Id__c = (student.LastName+student.FirstName+student.Email).toLowerCase());
            }
        }
        else {
            id userId;
            if(Label.UserID == 'blank'){
                userId = [Select id from user where UserRoleId != null and profile.Name = 'System Administrator' and isActive=true limit 1].Id;    
            }
            else 
                userId = [Select id from user where Name =: Label.UserId limit 1].Id;
                
            Account acc = new Account();
            acc.DM_External_Id__c = (student.LastName+student.FirstName+student.Email).toLowerCase();
            acc.Name = student.FirstName +' '+ student.lastName;
            
            acc.OwnerId = userId;
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual Account').getRecordTypeId();
            accList.add(acc);
            
            Contact con = new Contact();
            con.LastName = student.lastName;
            con.FirstName = student.FirstName;
            con.Email=student.Email;
            con.MobilePhone=student.Phone;
            con.Account = new Account(DM_External_Id__c = (student.LastName+student.FirstName+student.Email).toLowerCase());
            con.DM_External_Id__c = (student.LastName+student.FirstName+student.Email).toLowerCase();
            conList.add(con);
            
            return new Contact(DM_External_Id__c = (student.LastName+student.FirstName+student.Email).toLowerCase());
        }
        
    }
    
    // Send values of specific class from server side (Close a class)
    @AuraEnabled
    public static CourseInfo courseInfo(Id ClassId){
        CourseInfo objCourse = new CourseInfo();
        objcourse.lsgralist= new List<String>();
        objcourse.lsrealist = new List<String>();
        list<Redwing__ILT_Class__c> lstClass = [Select Id, Skedulo_Account__c, Skedulo_Account__r.Name, redwing__End_Date__c, redwing__Learning__c, 
                                                redwing__Learning__r.Name,Request_Type__c, CC_Order_Number__c,  Skedulo_Training_Event__c,
                                                Class_Closed_Date__c,Opportunity__c,opportunity__r.CloseDate,Cloud_Craze_Product__c,Supplemental_Information__c,
                                                Site_Address_1__c,Site_Address_2__c,Site_City__c,State__c,Site_Postal_Code__c
                                                from Redwing__ILT_Class__c where id=:ClassId limit 1];
        if(!lstClass.IsEmpty()){
            list<redwing__ILT_Session__c> lstSession = [Select Id, redwing__Location__c, redwing__Location__r.Name from redwing__ILT_Session__c where redwing__ILT_Class__c =: ClassId limit 1];
            list<redwing__ILT_Instructor__c> lstInstructor = [Select Id, redwing__Instructor__c, redwing__Instructor__r.Name from redwing__ILT_Instructor__c where redwing__ILT_Class__c =: ClassId order by createddate asc];
            objCourse.CourseName = lstClass[0].redwing__Learning__c != null ? lstClass[0].redwing__Learning__r.Name : '';
            objCourse.EndDate = lstClass[0].redwing__End_Date__c.format();
            Date checkEnddate = Date.valueOf(lstClass[0].redwing__End_Date__c);
            if(checkEnddate>system.today()){
                objCourse.futureDate=true;
            }
            else
            {
                objCourse.futureDate=false;
            }
            if(!lstSession.IsEmpty())
                objCourse.SessionId = lstSession[0].id;
            //objCourse.Location = lstSession[0].redwing__Location__r.Name;
            if(lstClass[0].Site_Address_2__c!=NULL)
                objCourse.Location = lstClass[0].Site_Address_1__c + ','
                + lstClass[0].Site_Address_2__c+ ',' 
                + lstClass[0].Site_City__c + ','
                + lstClass[0].State__c + ','
                + lstClass[0].Site_Postal_Code__c  ;
            else
                objCourse.Location = lstClass[0].Site_Address_1__c + ','
                + lstClass[0].Site_City__c + ','
                + lstClass[0].State__c + ','
                + lstClass[0].Site_Postal_Code__c  ;
            objCourse.Account = lstClass[0].Skedulo_Account__c != null ? lstClass[0].Skedulo_Account__r.Name : '';
            if(!lstInstructor.isEmpty()){
                objCourse.Instructor1 = lstInstructor[0].redwing__Instructor__c != null ? lstInstructor[0].redwing__Instructor__r.Name : '';
                if(lstInstructor.size() > 1){
                    objCourse.Instructor2 = lstInstructor[1].redwing__Instructor__c != null ? lstInstructor[1].redwing__Instructor__r.Name : '';
                }
            }
            objCourse.lstStudents = new List<JSONWrapper.Students>();
            Set<id> Learnignassignmentmapids = new Set<id>(); 
            Map<Id,redwing__Learning_Assignment__c> map_LearningAssignments = new Map<Id,redwing__Learning_Assignment__c>();
            List<redwing__ILT_Roster__c> lst_rosters = new List<redwing__ILT_Roster__c>();
            
            lst_rosters = [Select Id, redwing__Learning_Assignment__r.Name, redwing__Learning_Assignment__r.redwing__Completed_On__c, redwing__User__r.FirstName, redwing__User__r.LastName, redwing__User__r.Email, redwing__User__r.Phone From redwing__ILT_Roster__c where redwing__ILT_Class__c =: ClassId AND redwing__Status__c!='Cancelled'];
            
            for(redwing__ILT_Roster__c r : lst_rosters){
                Learnignassignmentmapids.add(r.redwing__Learning_Assignment__c);
            }
            
            for(redwing__Learning_Assignment__c la : [Select Id,redwing__Evaluation_Result__c,redwing__Completed_On__c,Grade_Reason__c,Grade_Additional_Info__c From redwing__Learning_Assignment__c Where Id IN :Learnignassignmentmapids]){
                map_LearningAssignments.put(la.Id,la);
            }
            
            for(redwing__ILT_Roster__c objRoster : lst_rosters){ 
                JSONWrapper.Students stDetails = new JSONWrapper.Students();
                //stDetails.rosterList = objRoster;
                stDetails.Roster = objRoster.Id;
                stDetails.FirstName = objRoster.redwing__User__r.FirstName;
                stDetails.LastName = objRoster.redwing__User__r.LastName;
                stDetails.Email = objRoster.redwing__User__r.Email;
                if (!String.isBlank(objRoster.redwing__User__r.Phone)) {
                    stDetails.Phone = objRoster.redwing__User__r.Phone.replaceAll('[^0-9]',''); // Strip out all mark-up leaving numeric digits
                } else stDetails.Phone = '';
                redwing__Learning_Assignment__c learningAssignment = new redwing__Learning_Assignment__c();
                learningAssignment = map_LearningAssignments.get(objRoster.redwing__Learning_Assignment__c);
                stDetails.Grade = learningAssignment.redwing__Evaluation_Result__c;
                stDetails.Fail_Reason = learningAssignment.Grade_Reason__c;
                stDetails.AdditionalInfo = learningAssignment.Grade_Additional_Info__c;
                /*if(learningAssignment.redwing__Completed_On__c!=null){
                DateTime dt = learningAssignment.redwing__Completed_On__c;

                }*/
                objCourse.lstStudents.add(stDetails);
            }
            
            
            DateTime dt = lstClass[0].Class_Closed_Date__c;
            if(lstClass[0].Class_Closed_Date__c!=null){
                String closeddate = dt.format('MM/dd/yyyy');
                objCourse.closedDate=closeddate;
                objcourse.classclosed = true;
            }
            else
            {
                objCourse.closedDate=null;
                objcourse.classclosed = false;
            }
            
            //Sending Picklist values of Grade and Reason to Server
            
            //Grades
            Schema.DescribeFieldResult ErfieldResult = redwing__Learning_Assignment__c.redwing__Evaluation_Result__c.getDescribe();
            List<Schema.PicklistEntry> erple = ErfieldResult.getPicklistValues();
            for(Schema.PicklistEntry erpickListVal : erple){
                objcourse.lsgralist.add(erpickListVal.getLabel());
            }
            
            // Reason
            Schema.DescribeFieldResult fieldResult = redwing__Learning_Assignment__c.Grade_Reason__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                objcourse.lsrealist.add(pickListVal.getLabel());
            }
            objcourse.oppId = lstClass[0].Opportunity__c;
            objcourse.ccProdId = lstClass[0].Cloud_Craze_Product__c;
            objcourse.suppInfo = lstClass[0].Supplemental_Information__c;
            objcourse.RequestType = lstClass[0].Request_Type__c;
            objcourse.TrainingEventId = lstClass[0].Skedulo_Training_Event__c;
            
        }    
        return objCourse;
        
    }
    
    // Creating class and session for CRE and RBC
    @AuraEnabled
    public static redwing__ILT_Class__c postClass(String jsonStr, RBCWrapper wrapper) {

//        RBCWrapper cpsWrap = (RBCWrapper) JSON.deserialize(jsonStr, RBCWrapper.class);

//        System.debug('JSON: '+jsonStr);
//        System.debug('cpsWrap: '+ JSON.serialize(wrapper));

        CourseInfo objCourse = new CourseInfo();
        objcourse.lsgralist= new List<String>();
        objcourse.lsrealist = new List<String>();
        Integer noofdays;
        Integer totaldays;
        
        List<redwing__Learning__c> learninglistver = new List<redwing__Learning__c>();
        List<ccrz__E_CartItem__c> updatedCartItems = new List<ccrz__E_CartItem__c>();
        List<ccrz__E_OrderItem__c> updatedOrderItems = new List<ccrz__E_OrderItem__c>();
        List<ccrz__E_Order__c> updatedOrders = new List<ccrz__E_Order__c>();
        Set<Id> updatedOrderItemIds = new Set<Id>();
        Set<Id> updatedOrderIds = new Set<Id>();
        
        Map<id,id> insertedclassid = new Map<id,id>();
        Map<String,redwing__Learning_Version__c> lVersions = new Map<String,redwing__Learning_Version__c>();
        
        JSONWrapper.ClassDetails objClassDetails = new JSONWrapper.ClassDetails(System.JSON.createParser(jsonStr));
        Redwing__ILT_Class__c clsRecord = new Redwing__ILT_Class__c();
        String coursename;
        
        try {
            if(objClassDetails != null){       
                System.debug('***** Processing objClassDetails:'+objClassDetails);
                // Step 1 - Get Learning plan name 
                
                learningPlanId = objClassDetails.Course;                
                AccountId = objClassDetails.Account;
                List<redwing__Training_Plan__c> cList = [select id, name from redwing__Training_Plan__c where id =:learningPlanId];
                for(redwing__Training_Plan__c lp : cList )
                {
                    coursename = lp.name;
                }        
                
                // Step 2 - Create Learning object for the new ILT Class record
                
                redwing__Learning__c objLearning = new redwing__Learning__c();
                objLearning.RecordTypeId = Schema.SObjectType.redwing__Learning__c.getRecordTypeInfosByName().get('ILT Class').getRecordTypeId();
                objLearning.Name = coursename;
                // Do we need to create a Learning version record?
                // If so, need to populate version number here (version 1)
                insert objLearning;
                learninglistver.add(objLearning);
                System.debug('Created learning record id: '+objlearning.id);
                learningId = objLearning.Id;
                
                // Get the value of learning plan section and learning object to create the learning assignment in add students method
                // Get the value of event learning record to create ilt event class and associate the fields with event learning object  
                redwing__Training_Plan_Section_Item__c[] learningPlanILTEventItem = [Select Id, redwing__Learning__c,redwing__Learning__r.RecordType.id,redwing__Learning__r.id,redwing__Training_Plan_Section__r.id,redwing__Learning__r.recordtype.Name, redwing__Training_Plan_Section__c
                                                                                     from redwing__Training_Plan_Section_Item__c where redwing__Training_Plan_Section__r.redwing__Training_Plan__c =: learningPlanId and redwing__Learning__c != null
                                                                                     and redwing__Learning__r.recordtype.id != Null];
                tpsiRecordTypeMap = new map<String,redwing__Training_Plan_Section_Item__c>();
                for(redwing__Training_Plan_Section_Item__c tpsi: learningPlanILTEventItem ){
                    System.debug('Record type name of lp'+tpsi.redwing__Learning__r.recordtype.Name);
                    System.debug('learning plan section lp values'+tpsi);
                    
                    tpsiRecordTypeMap.put(tpsi.redwing__Learning__r.recordtype.Name,tpsi); // Used while creating learning assignments with learning plan section
                    System.debug('Map of learning plan section lp values'+tpsiRecordTypeMap);
                    
                }
                
                if(tpsiRecordTypeMap.containskey('ILT Event')) {
                    eventlearningplansection = tpsiRecordTypeMap.get('ILT Event').redwing__Training_Plan_Section__c;
                    eventlearningobjid = tpsiRecordTypeMap.get('ILT Event').redwing__Learning__c;
                }
                
                
                // Step 4 - Fetch the ILT Event record for this Learning Plan
                
                redwing__ILT_Event__c event = [Select Id, redwing__Learning__c from redwing__ILT_Event__c where redwing__Learning__c =: eventlearningobjid];
                //eventlearningId = eventlearningobjid; // Contains the value of learning object which has ILT Event record type
                
                // Step 5 - Create Event Class record, binding the ILT Class learning object to the ILT Event record
                
                redwing__ILT_Event_Class__c objEventClass = new redwing__ILT_Event_Class__C();
                objEventClass.redwing__ILT_Event__c = event.Id;
                objEventClass.redwing__Learning__c = learningId;
                insert objEventClass;

                
                // Step 6 - Create ILT Class record, bind to Learning object created above

                clsRecord.Skedulo_Account__c = objClassDetails.Account;
                clsRecord.redwing__End_Date__c = Date.Parse(objClassDetails.EndDate);
                //clsRecord.redwing__End_Time__c= '17:00';
                if(objClassDetails.StartDate!=null){
                    clsRecord.redwing__Start_Date__c = Date.Parse(objClassDetails.StartDate);// Assuming Start date = End date
                }else{
                    clsRecord.redwing__Start_Date__c = Date.Parse(objClassDetails.EndDate);
                }
                noofdays = Date.Parse(objClassDetails.StartDate).daysBetween(Date.Parse(objClassDetails.EndDate));
                
                // Totaldays is used for session record creation
                // DE1062 - For Learn-To-Swim, create only one session record (for last day of class)
                if (objClassDetails.IsLearnToSwimProduct != null && objClassDetails.IsLearnToSwimProduct) {
                    totaldays = 1;
                } else {
                    totaldays = noofdays + 1;
                }
                
                clsRecord.Learning_Plan__c = learningPlanId;
                //clsRecord.redwing__Start_Time__c = '00:00';
                clsRecord.Name = coursename;
                clsRecord.redwing__Learning__c = learningId;
                clsRecord.Class_Online__c = true;
                clsRecord.Supplemental_Information__c = objClassDetails.SupplementInfo;
                clsRecord.Request_Type__c = 'LTP/AP';
                clsRecord.redwing__Timezone__c = 'America/Panama';
                if(blend!=true)
                {
                    clsRecord.Class_Closed_Date__c = DateTime.Now();
                    clsRecord.Classroom_Setting__c = 'Classroom';
                }
                else
                {
                    clsRecord.Classroom_Setting__c = 'Online + Classroom';
                    clsRecord.Class_Online_From__c = Date.today()-1;                    
                }
                //clsRecord.Class_Online_From__c=date.newinstance(clsRecord.createdDate.year(),clsRecord.createdDate.month(),clsRecord.createdDate.day());
                clsRecord.Class_Searchable__c = false;
                // Address fields
                if(String.IsNotBlank(objClassDetails.SiteName)) {
                    clsRecord.Site_Name__c = objClassDetails.SiteName;
                }
                if(String.IsNotBlank(objClassDetails.Address1)) {
                    clsRecord.Site_Address_1__c = objClassDetails.Address1;
                }
                if(String.IsNotBlank(objClassDetails.Address2)) {
                    clsRecord.Site_Address_2__c = objClassDetails.Address2;
                }
                if(String.IsNotBlank(objClassDetails.City)) {
                    clsRecord.Site_City__c = objClassDetails.City;
                }    
                if(String.IsNotBlank(objClassDetails.State)) {
                    clsRecord.State__c = objClassDetails.State;
                }
                if(String.IsNotBlank(objClassDetails.Zip)) {
                    clsRecord.Site_Postal_Code__c = objClassDetails.Zip;
                } 
                if(String.IsNotBlank(objClassDetails.OpportunityId)) {
                    clsRecord.Opportunity__c = objClassDetails.OpportunityId;
                }
                if(String.IsNotBlank(objClassDetails.CloudCrazeProdId)) {
                    clsRecord.Cloud_Craze_Product__c = objClassDetails.CloudCrazeProdId;
                }
                clsRecord.redwing__Location__c = objClassDetails.Location;

                // Learn to Swim
                try {
                    if (objClassDetails.IsLearnToSwimProduct != null && objClassDetails.IsLearnToSwimProduct) {
                        isLearnToSwimProduct = true;
                        if (objClassDetails.SuccessfulEvals != null) {
                            clsRecord.Successful_Evaluations__c = Integer.valueOf(objClassDetails.SuccessfulEvals);
                        }
                        if (objClassDetails.UnsuccessfulEvals != null) {
                            clsRecord.Unsuccessful_Evaluations__c = Integer.valueOf(objClassDetails.UnsuccessfulEvals);
                        }
                        if (objClassDetails.NonEvals != null) {
                            clsRecord.Not_Evaluated__c = Integer.valueOf(objClassDetails.NonEvals);
                        }
                    }

                } catch (Exception e) {
                    System.debug('JASON: exception caught: ' + e.getMessage());
                    System.debug('exception details: line=' + e.getLineNumber() + ' stackTrace=' + e.getStackTraceString());
                }

                Database.SaveResult sr = Database.insert(clsRecord, false);
                if (sr.isSuccess()) {
                    classId = sr.getId();
                    insertedclassid.put(clsRecord.redwing__Learning__c, classId);
                    System.debug('Created class record id:'+classId);                   
                }

                if (wrapper != null) {
                    System.debug('Number of sessions to be created' +noofdays);
                    System.debug('sessWrap '+wrapper.sessionList);


//                List<redwing__ILT_Session__c> sessList = new List<redwing__ILT_Session__c>();
//                for(RBCWrapper.SessionWrapper sessWrap : wrapper.sessionList) {
//                    redwing__ILT_Session__c sess = new redwing__ILT_Session__c();
//                    sess.redwing__ILT_Class__c = clsRecord.Id;
//                    sess.redwing__Date__c = Date.valueOf(sessWrap.classDate);
//
//                    List<String> sessStartTimeList = wrapper.sessionList[0].startTime.split(':');
//                    Time sessStartTime = Time.newInstance(Integer.valueOf(sessStartTimeList[0]),Integer.valueOf(sessStartTimeList[1]),0,0);
//                    List<String> sessEndTimeList = wrapper.sessionList[0].endTime.split(':');
//                    Time sessEndTime = Time.newInstance(Integer.valueOf(sessEndTimeList[0]),Integer.valueOf(sessEndTimeList[1]),0,0);
//
//                    sess.redwing__Start_Time__c = String.valueOf(sessStartTime).subString(0,5);
//                    sess.redwing__End_Time__c = String.valueOf(sessEndTime).subString(0,5);
//                    sessList.add(sess);
//                }
//
//                System.debug('Inserting session list: ' + JSON.serialize(wrapper));
//                insert sessList;

                    List<redwing__ILT_Session__c> sessList = new List<redwing__ILT_Session__c>();
                    for(RBCWrapper.SessionWrapper sessWrap : wrapper.sessionList) {
                        redwing__ILT_Session__c sess = new redwing__ILT_Session__c();
                        sess.redwing__ILT_Class__c = clsRecord.Id;
                        sess.redwing__Date__c = Date.valueOf(sessWrap.classDate);

                        List<String> sessStartTimeList = sessWrap.startTime.split(':');
                        Time sessStartTime = Time.newInstance(Integer.valueOf(sessStartTimeList[0]),Integer.valueOf(sessStartTimeList[1]),0,0);
                        List<String> sessEndTimeList = sessWrap.endTime.split(':');
                        Time sessEndTime = Time.newInstance(Integer.valueOf(sessEndTimeList[0]),Integer.valueOf(sessEndTimeList[1]),0,0);

                        sess.redwing__Start_Time__c = String.valueOf(sessStartTime).subString(0,5);
                        sess.redwing__End_Time__c = String.valueOf(sessEndTime).subString(0,5);
                        sess.redwing__Location__c = objClassDetails.Location;
                        sessList.add(sess);
                    }

                    System.debug('Inserting session list: ' + JSON.serialize(wrapper));
                    System.debug('Inserting session list: ' + sessList);
                    insert sessList;
                    
                    //DE1576
                    redwing__ILT_Class__c rILTClass = new redwing__ILT_Class__c ();
                    rILTClass.Id = classId;
                    rILTClass.redwing__Start_Time__c = sessList[0].redwing__Start_Time__c;
                    rILTClass.redwing__End_Time__c  = sessList[0].redwing__End_Time__c;
                    update rILTClass;
                    
                    
                } else {
                    redwing__ILT_Session__c sess = new redwing__ILT_Session__c();
                    sess.redwing__ILT_Class__c = clsRecord.Id;
                    sess.redwing__Date__c = clsRecord.redwing__Start_Date__c;
                    sess.redwing__Location__c = objClassDetails.Location;
                    insert sess;
                    
                    
                    //DE1576
                    redwing__ILT_Class__c rILTClass = new redwing__ILT_Class__c ();
                    rILTClass.Id = classId;
                    rILTClass.redwing__Start_Time__c = '08:00';
                    rILTClass.redwing__End_Time__c  = '05:00';
                    update rILTClass;
                }


                // Rework this entire section!!!!!!!!!!!!!!!!
                /*
                if(blend==true)
                {
                    Redwing__ILT_Class__c riltc= [select id,CreatedDate from Redwing__ILT_Class__c where Id = :clsRecord.Id limit 1];
                    Redwing__ILT_Class__c clsRecordupd = new Redwing__ILT_Class__c();
                    clsRecordupd.id = riltc.Id;
                    clsRecordupd.Class_Online_From__c=date.newinstance(riltc.CreatedDate.year(),riltc.CreatedDate.month(),riltc.CreatedDate.day())-1;
                    update clsRecordupd;
                }
                */
                
                // US1521 - Populate CC Cart Item Record(s) with ILT Class Id (if applicable)

                if (clsRecord != null && clsRecord.Opportunity__c != null && classId != null) {
                    for (ccrz__E_CartItem__c theCartItem : [Select Id, ccrz__Product__c, ILT_Class__c From ccrz__E_CartItem__c
                        Where ccrz__Cart__r.Opportunity__c = :clsRecord.Opportunity__c]) {
                            
                        ccrz__E_CartItem__c newCartItem = new ccrz__E_CartItem__c();
                        newCartItem.Id = theCartItem.Id;    
                        newCartItem.ILT_Class__c = classId;
                        updatedCartItems.add(newCartItem);
                    }
                
                    // US1521 - If this is CRE, Order Lines will already be created
                    // In this case, we need to write ILT Class Id on Order Item record(s)
                    // Note: it is assumed that CRE/RBC orders are one-to-one opportunity-to-product(class)

                    for (ccrz__E_OrderItem__c theOrderItem : [Select Id, ccrz__Product__c, ILT_Class__c, ccrz__Order__c From ccrz__E_OrderItem__c
                        Where ccrz__Order__r.ccrz__OriginatedCart__r.Opportunity__c = :clsRecord.Opportunity__c]) {
                        if (!updatedOrderItemIds.contains(theOrderItem.Id)) {
                            ccrz__E_OrderItem__c newOrderItem = new ccrz__E_OrderItem__c();
                            newOrderItem.Id = theOrderItem.Id;
                            newOrderItem.ILT_Class__c = classId;
                            updatedOrderItems.add(newOrderItem);
                            updatedOrderItemIds.add(theOrderItem.Id);
                        }
                        // Extension - provide linkage to external flows that order items were updated with ILT Class Id by updating
                        // boolean on order header record
                        if (!updatedOrderIds.contains(theOrderItem.ccrz__Order__c)) {
                            ccrz__E_Order__c newOrder = new ccrz__E_Order__c();
                            newOrder.Id = theOrderItem.ccrz__Order__c;
                            newOrder.CRE_Request_Processed__c = true;
                            updatedOrders.add(newOrder);
                            updatedOrderIds.add(theOrderItem.ccrz__Order__c);
                        }
                    }
                }                
                
//                sessionlist = new list<redwing__ILT_Session__c>();
//
//                // Create ILT Session record(s) for each day of class delivery
//
//                for(Integer i=1;i<=totaldays;i++){
//                    //System.debug('session created number' +i);
//                    redwing__ILT_Session__c sessionRecord = new redwing__ILT_Session__c();
//                    sessionRecord.redwing__ILT_Class__c = classId;
//                    sessionRecord.Skedulo_Account__c = objClassDetails.Account;
//                    //sessionRecord.redwing__Location__c = objClassDetails.Location;
//                    sessionRecord.Skedulo_Address__c = objClassDetails.Location;
//                    //End Time is defaulted to "00:00"
//                    sessionRecord.redwing__End_Time__c = '17:00';
//
//                  // DE1062 - Exception: Create a single Session record for last day of Learn-To-Swim classes
//                  // Totaldays value for Learn to Swim classes is set in ILT Class block above (must be set to 1)
//                    if(objClassDetails.IsLearnToSwimProduct != null && objClassDetails.IsLearnToSwimProduct) {
//                      sessionRecord.redwing__Date__c = Date.Parse(objClassDetails.EndDate);
//                    } else if(i==1) {
//                        sessionRecord.redwing__Date__c = Date.Parse(objClassDetails.StartDate);
//                    } else {
//                        sessionRecord.redwing__Date__c = Date.Parse(objClassDetails.StartDate).adddays(i-1);
//                    }
//
//                    //Start Time is defaulted to "08:00" to avoid issues with date display/conversion in community
//                    sessionRecord.redwing__Start_Time__c = '08:00';
//                    // Added by SJC - 05-20-2019 - Assign user friendly name to ILT Session records
//                    if (clsRecord != null && clsRecord.Name != null) {
//                      // Insure that datetime is not converted to UTC
//                      Integer clsday   = sessionRecord.redwing__Date__c.day();
//                      Integer clsmonth = sessionRecord.redwing__Date__c.month();
//                      Integer clsyear  = sessionRecord.redwing__Date__c.year();
//                      DateTime sessionDateTime = DateTime.newInstance(clsyear, clsmonth, clsday, 12, 00, 00);
//
//                      Integer namePrefixLength = Math.min(clsRecord.Name.length(), 40);
//                        sessionRecord.Name = clsRecord.Name.substring(0,namePrefixLength) + ' ' + sessionDateTime.format('MM/dd/yyyy');
//                  }
//                    sessionlist.add(sessionRecord);
//                }
//
//                insert sessionlist;
//                //sessionId = sessionRecord.Id;
//                System.debug('Created session record id:'+sessionlist);
                
                //Create ILT Instructor Record
                redwing__ILT_Instructor__c theILTInstructor = new redwing__ILT_Instructor__c();
                theILTInstructor.redwing__Instructor__c = objClassDetails.Instructor1;
                theILTInstructor.redwing__ILT_Class__c = classId;
                theILTInstructor.redwing__Primary__c = true;
                insert theILTInstructor;
                
                //Logic for Additional instructor
                if(String.IsNotBlank(objClassDetails.Instructor2)){
                    theILTInstructor = new redwing__ILT_Instructor__c();
                    theILTInstructor.redwing__Instructor__c = objClassDetails.Instructor2;
                    theILTInstructor.redwing__ILT_Class__c = classId;
                    insert theILTInstructor;
                }
                
                System.debug('===objClassDetails.AdditionalInstructors==='+objClassDetails.AdditionalInstructors);
                if(String.IsNotBlank(objClassDetails.AdditionalInstructors)){
                    List<redwing__ILT_Instructor__c> lst_additionalInstructors = new List<redwing__ILT_Instructor__c>();
                    for(String obj_Instr : objClassDetails.AdditionalInstructors.split(';')){ 
                        theILTInstructor = new redwing__ILT_Instructor__c();
                        theILTInstructor.redwing__Instructor__c = obj_Instr;
                        theILTInstructor.redwing__ILT_Class__c = classId;
                        lst_additionalInstructors.add(theILTInstructor);
                    }
                    if(lst_additionalInstructors.size()>0)
                        insert lst_additionalInstructors;
                }
                
                //Create Vouchers
                if(blend==true){
                    System.debug('value of voucher and student'+objClassDetails.Students+objClassDetails.Voucher+blend);
                    if(Integer.Valueof(objClassDetails.Voucher)!=0 && objClassDetails.Students!=null )
                    {
                        Studentvoccount=Integer.Valueof(Integer.Valueof(objClassDetails.Students));
                        System.debug('Count of students and voucher'+(Integer.Valueof(objClassDetails.Voucher)+Integer.Valueof(objClassDetails.Students)));
                        ILTInstructorCommunity.insertVouchers((Integer.Valueof(objClassDetails.Voucher)+Integer.Valueof(objClassDetails.Students)),classId,learningPlanId);
                    }else{
                        System.debug('Inside Else'+Integer.Valueof(objClassDetails.Students));
                        Studentvoccount=Integer.Valueof(Integer.Valueof(objClassDetails.Students));
                        ILTInstructorCommunity.insertVouchers(Integer.Valueof(objClassDetails.Students),classId,learningPlanId);
                    }
                    
                }
                
                //Publishing Learning records
                
                for(redwing__Learning__c l : learninglistver){
                    redwing__Learning_Version__c lv = new redwing__Learning_Version__c();
                    lv.redwing__Learning__c = l.id;
                    lv.redwing__Version__c = 1;
                    lv.redwing__Type__c = 'Published';
                    lv.redwing__Version_selection_behavior__c = null;
                    //if(l.RecordType.DeveloperName == 'ILT'){
                    if(insertedclassid.containskey(l.id)){
                        lv.redwing__ILT__c = insertedclassid.get(l.id);
                    }
                    //}
                    else{
                        //TODO: Handle custom record types here
                    }
                    lVersions.put(l.id,lv);
                }
                
                if(lVersions.size() > 0)
                {
                    insert lVersions.values();
                    learningVersionId = lVersions.values().Id;
                }
                
                //Update header information
                for(redwing__Learning__c l : learninglistver){
                    l.redwing__Current_Published_Version__c = lVersions.get(l.id).Id;
                    l.redwing__Published__c = true;
                }
                
                if(learninglistver.size() > 0){
                    update learninglistver;
                }
                //redwing.LMS_API.publishLearning(learningId);
                
                if (updatedCartItems.size() > 0) {
                    update updatedCartItems;
                }
                
                if (updatedOrderItems.size() > 0) {
                    update updatedOrderItems;
                }

                if (updatedOrders.size() > 0) {
                    update updatedOrders;
                }

            }
        }catch (Exception e) {
            //throw new AuraHandledException('Invalid Attempt');
            System.debug('JASON: Exception caught: ' + e.getMessage());
            System.debug('LINE_NUMBER=' + e.getLineNumber() + ' CAUSE=' + e.getCause() + ' STACK_TRACE=' + e.getStackTraceString());
            System.debug('EXCEPTION: ' + e);
            throw new AuraHandledException(e.getMessage());
            
        }
        return clsRecord;
    }
    @AuraEnabled
    public static Account[] getAccountList() {
        User u = fetchUser();
        return [SELECT Id, Name FROM Account WHERE id in (SELECT AccountId FROM AccountContactRelation WHERE ContactId = : u.ContactId)]; //: u.ContactId
    }
    
    //Method to Skip payment page
    @AuraEnabled
    public static Boolean getDisplayPaymentInfo(String opportunityId) {
        User u = fetchUser();
        List<Opportunity> opp = [Select Id,AccountId From Opportunity WHERE Id = :opportunityId];
        System.debug('opportunity in getDisplayPaymentInfo: '+opp);
        if(!opp.isEmpty()) {
            List<AccountContactRelation> accConRel = [SELECT AccountId, Display_Payment_Info__c FROM AccountContactRelation WHERE ContactId = :u.ContactId and AccountId = :opp[0].AccountId];
            if (!accConRel.isEmpty()) {
                return accConRel[0].Display_Payment_Info__c;
            }
        }
        return true;
    }
    
    @AuraEnabled
    public static Id createOppForCC(String AccountId, String storeFront) {
        
        Opportunity o = new Opportunity();
        
        o.Name          = 'Community Opportunity';
        o.AccountId     = AccountId;
        o.StageName     = 'Approach';
        o.CloseDate     = date.today();
        o.Type          = 'New Business - FS';
        o.RecordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Order Opportunity').getRecordTypeId();
        o.Source_System__c = storeFront;
        
        insert o;
        
        return o.Id;
    }
    
    @AuraEnabled
    public static Id createOppForCCUpdate(String AccountId, String storeFront, string opptyId) {
        
        Opportunity o = new Opportunity();
        
        o.Name          = 'Community Opportunity';
        o.AccountId     = AccountId;
        o.StageName     = 'Approach';
        o.CloseDate     = date.today();
        o.Type          = 'New Business - FS';
        o.RecordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Order Opportunity').getRecordTypeId();
        o.Source_System__c = storeFront;
        
        insert o;
        if(opptyId !=null && opptyId !=''){
            list<ccrz__E_Cart__c> lstCarts = new list<ccrz__E_Cart__c>();
            for(ccrz__E_Cart__c ccart : [select id,Opportunity__c from ccrz__E_Cart__c where Opportunity__c=:opptyId]){
                ccart.Opportunity__c = o.id;
                lstCarts.add(ccart);
            }
            if(!lstCarts.isEmpty()){
                update lstCarts;  
               
            }
             delete [select id from opportunity where id =:opptyId];
        }
        return o.Id;
    }
    
    @AuraEnabled
    public static ccrz__E_Product__c getLearningPlanId(String ccProdId) {
        
        ccrz__E_Product__c  ccProd = [SELECT Id, LMS_Learning_Plan__c, LMS_Learning_Plan__r.Name, Course_Catalog__c, Course_Catalog__r.Ratio_to_Instructor__c, Ratio_to_Instructor__c  FROM ccrz__E_Product__c WHERE Id =: ccProdId LIMIT 1];
        System.debug('getting ccProd'+ccProd); 

        return ccProd;
    }
    
    // To check wthr the logged in instructor matches the prereqconditions
    @AuraEnabled
    public static boolean checkPrereq(String ccProdId)
    {
        map<ID,set<ID>> mapuserach = new map<ID,set<ID>>();
        list<ID> Prereqid= new list<ID>();
        set<ID> PreachSet= new set<ID>();
        boolean returnval;
        ccrz__E_Product__c  ccProd = [SELECT Id, LMS_Learning_Plan__c, LMS_Learning_Plan__r.Name,Course_Catalog__r.Ratio_to_Instructor__c  FROM ccrz__E_Product__c WHERE Id =: ccProdId LIMIT 1];
        // Logic to retrieve the prereqisite of the current course
        System.debug('LPId received'+ccProd.LMS_Learning_Plan__c);
        redwing__Training_Plan_Section_Item__c learningPlanILTEventItem = [Select Id, redwing__Learning__c, redwing__Learning__r.recordtype.Name, redwing__Training_Plan_Section__c
                                                                           from redwing__Training_Plan_Section_Item__c where redwing__Training_Plan_Section__r.redwing__Training_Plan__c =: ccProd.LMS_Learning_Plan__c and redwing__Learning__c != null
                                                                           and redwing__Learning__r.recordtype.Name = 'ILT Event' Limit 1];
        
        /*List<redwing__ILT_Event__c> event = [Select Name from redwing__ILT_Event__c where redwing__Learning__c =: learningPlanILTEventItem.redwing__Learning__c limit 1];*/
        List<redwing__Learning_Prerequisite__c> learningpreid = [Select Name, redwing__Training_Plan__c, redwing__Learning__c, redwing__Prerequisite__c from redwing__Learning_Prerequisite__c where redwing__Learning__c =:learningPlanILTEventItem.redwing__Learning__c limit 1];
        
        if(learningpreid.size() > 0){
            List<redwing__Prerequisite__c> Prereqlist = [SELECT ID FROM redwing__Prerequisite__c where ID =:learningpreid[0].redwing__Prerequisite__c];
            for(redwing__Prerequisite__c ObjPreq: Prereqlist)
            {
                Prereqid.add(ObjPreq.id);
                System.debug('Prereq'+Prereqid);
            }
            
            
            List<redwing__Prerequisite_Item__c> PrereitemAchv = [Select redwing__Achievement__c from redwing__Prerequisite_Item__c where redwing__Prerequisite__c in:Prereqid and redwing__Required_Status__c = 'Acquired'];
            for(redwing__Prerequisite_Item__c ObjPreItm:PrereitemAchv) {
                PreachSet.add(ObjPreItm.redwing__Achievement__c);
            } 
        }
        
        System.debug('PreachSetValues>>>>>>>>>'+PreachSet);
        // Get Achievement Assignment records
        List<redwing__Achievement_Assignment__c> InstructorAchv = [Select redwing__Achievement__c, redwing__User__c from redwing__Achievement_Assignment__c where redwing__User__c =:UserInfo.getUserId() and redwing__Status__c = 'Acquired'];
        system.debug('InstructorAchv  +++++++++++++++++++++++++'+InstructorAchv);
        
        for(redwing__Achievement_Assignment__c raa:InstructorAchv){
            if(mapuserach.containsKey(raa.redwing__User__c))
            {
                set<ID> AchvmntSet=mapuserach.get(raa.redwing__User__c);
                
                AchvmntSet.add(raa.redwing__Achievement__c);
                mapuserach.put(raa.redwing__User__c,AchvmntSet);
            }
            else{
                set<ID> AchvmntSet=new set<ID>{raa.redwing__Achievement__c};
                    mapuserach.put(raa.redwing__User__c,AchvmntSet);
                
            }
            System.debug('mapuserachValues>>>>>>>>>'+mapuserach);
        }
        
        if((PreachSet.size() > 0)){
            if(mapuserach.containskey(UserInfo.getUserId()))
            {
                System.debug('Contains respective user');
                if(mapuserach.get(UserInfo.getUserId()).containsAll(PreachSet))
                {                        
                    returnval=true;
                }   
                else
                {
                    returnval=false;
                }
            }
            
        }
        return returnval;
    }
    
    // Check if the given learning plan has learning plan section item associated with it
    @AuraEnabled
    public static Boolean isValidCourse(String learningPlanId) {
        redwing__Training_Plan_Section_Item__c[] SectionsItem = [Select Id, redwing__Learning__c,redwing__Learning__r.RecordType.id,redwing__Learning__r.id,redwing__Training_Plan_Section__r.id,redwing__Learning__r.recordtype.Name, redwing__Training_Plan_Section__c
                                                                 from redwing__Training_Plan_Section_Item__c where redwing__Training_Plan_Section__r.redwing__Training_Plan__c =: learningPlanId and redwing__Learning__c != null
                                                                 and redwing__Learning__r.recordtype.Name = 'ILT Event' limit 1];
        if(!SectionsItem.isEmpty() && SectionsItem.size() > 0) {
            return true;    
        }
        return false;
    }
    
    //Change cart owner after closing a class
    @AuraEnabled 
    public static ccrz__E_Cart__c Changecartowner(String opportunitySfid, String EncryptedId) {
        System.debug('Encrypted id'+EncryptedId);
        System.debug('Opportunitysfid id'+opportunitySfid);
        User Ucid = [Select id, ContactId from  user where Id=:UserInfo.getUserId()];
        if(opportunitySfid!=null){
            opportunity opty = [select id,ownerid from opportunity where id=:opportunitySfid];
            opty.ownerid =Ucid.id;
            update opty;    
        }
        if(EncryptedId!=null){
        ccrz__E_Cart__c fetchCarts = [
            SELECT Id,ccrz__Account__c, ccrz__EncryptedId__c
            FROM ccrz__E_Cart__c
            WHERE Opportunity__c = :opportunitySfid AND ccrz__ActiveCart__c = true AND ccrz__EncryptedId__c = :EncryptedId
            LIMIT 1
        ];
        
        
        fetchCarts.OwnerID = UserInfo.getUserId();
        fetchCarts.ccrz__Contact__c = Ucid.ContactId;
        fetchCarts.ccrz__User__c=Ucid.id;
        update  fetchCarts;
         
        System.debug('updated cart details'+fetchCarts);
        return fetchCarts;
        }
        else
        {
        return null;
        }
    }
    
    @AuraEnabled 
    public static Map<String, Object> updateCartProducts(String opportunitySfid, String CCProductId, String noOfStudents) {
        Map<String, Object> addToCartResult;
        Map<String, Object> productQuantityMap = new Map<String, Object> ();
        productQuantityMap.put(CCProductId,noOfStudents);
        
        // US1521 - Save ILT Class Id (if any) on Cart Items since cart is recreated in addProductsToCart
        Map<Id, Id> cartItemClassIdMap = new Map<Id, Id>();
        for (ccrz__E_CartItem__c theCartItem : [Select Id, ccrz__Cart__r.Opportunity__c, ccrz__Product__c, ILT_Class__c From ccrz__E_CartItem__c 
            Where ccrz__Cart__r.Opportunity__c = :opportunitySfid]) {
            cartItemClassIdMap.put(theCartItem.ccrz__Product__c, theCartItem.ILT_Class__c);
        }
        
        try {
            addToCartResult = phss_cc_CartUtil.addProductsToCart(opportunitySfid,productQuantityMap,true);
        } catch (Exception e) {
            addToCartResult = phss_cc_Exception.getErrorMessageMap(e.getMessage());
        }
        
        // US1521 - Restore ILT Class Ids (if any) to CartItems on newly created cart after call to addProductsToCart
        List<ccrz__E_CartItem__c> updateCartItemList = new List<ccrz__E_CartItem__c>();
        for (ccrz__E_CartItem__c theCartItem : [Select Id, ccrz__Cart__r.Opportunity__c, ccrz__Product__c, ILT_Class__c From ccrz__E_CartItem__c
            Where ccrz__Cart__r.Opportunity__c = :opportunitySfid]) {
            Id cartItemProductId = theCartItem.ccrz__Product__c;
            if (cartItemClassIdMap.containsKey(cartItemProductId)) {
                ccrz__E_CartItem__c updateCartItem = new ccrz__E_CartItem__c();
                updateCartItem.Id = theCartItem.Id;
                updateCartItem.ILT_Class__c = cartItemClassIdMap.get(cartItemProductId);
                updateCartItemList.add(updateCartItem);
            }
        } 
        if (updateCartItemList.size() > 0) {
            update updateCartItemList;
        }        
        
        return addToCartResult;
    }
    
    @AuraEnabled
    public static Boolean isCommunityClass(String classId) {
        // Get ILT Class
        redwing__ILT_Class__c cls = [Select Id, Request_Type__c From redwing__ILT_Class__c Where Id = :classId Limit 1];
        if(cls.Request_Type__c == 'Community' || cls.Request_Type__c == 'Full Service' 
            || cls.Request_Type__c == 'Nurse Assistant Testing' || cls.Request_Type__c == 'Nurse Assistant Training'
            || cls.Request_Type__c == 'Nurse Assistant Testing - Full Service' || cls.Request_Type__c == 'Nurse Assistant Training - Full Service') {
            return true;
        }
        return false;
    }
    
//
//    @AuraEnabled
//    public static void sendEmail()
//    {
//        Messaging.SendEmailResult[] results;
//        //try{
//        User u = fetchUser();
//        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
//        message.toAddresses = new String[] {u.Email};
//            message.subject = 'Payment Confirmation on Enrolling Students';
//        message.plainTextBody = 'Thank you for reporting to this course and your payment is successful';
//        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
//            results = Messaging.sendEmail(messages);
//            //System.debug('Mail sent>>>>'+ messages[0]);
//        // }
//        /*catch(Exception e) {
//System.debug('The email failed to send:results[0] ' + results[0].errors[0].message);
//}*/
//    }

    @AuraEnabled
    public static void sendEmail()
    {
        Messaging.SendEmailResult[] results;
        //try{
        User u = fetchUser();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] {u.Email};
        message.subject = 'Payment Confirmation on Enrolling Students';
        message.plainTextBody = 'Thank you for reporting to this course and your payment is successful';
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        if(!Test.isRunningTest()) {
            results = Messaging.sendEmail(messages);
            System.debug('Mail sent>>>>' + results);
        }
        // }
        /*catch(Exception e) {
System.debug('The email failed to send:results[0] ' + results[0].errors[0].message);
}*/
    }


    /**
     * @description Identifies whether a product has an associated Learn-to-Swim (LTS) product spec
     *
     * @param productId
     *
     * @return
     */
    @AuraEnabled
    public static Map<String, Object> isLTSProduct(String productId) {
        Map<String, Object> results = new Map<String, Object>();
        try {
            if (String.isNotEmpty(productId)) {
                Map<String, String> specsMap = new Map<String, String>{
                        phss_cc_ProductUtil.CLASS_SPEC_NAME => phss_cc_ProductUtil.LEARN_TO_SWIM_PRODUCT_SPEC
                };
                Set<String> products = new Set<String>{productId};
                Set<String> matches = phss_cc_ProductUtil.productsMatchingSpecs(products, specsMap);

                for (String match : matches) {
                    results.put(match, true);
                }
            }

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_IDENTIFY_LTS_COURSE, e);
        }

        return results;
    }
    

    @AuraEnabled
    public static Map<String, Object> isLTSClass(String classId) {
        Map<String, Object> results = new Map<String, Object>();
        try {
            if (String.isNotEmpty(classId)) {
                redwing__ILT_Class__c trainingClass = phss_cc_ILTrainingClassUtil.getILTrainingClass(classId);
                if (trainingClass != null) {
                    String productId = trainingClass.Cloud_Craze_Product__c;
                    Map<String, Object> ltsResults = isLTSProduct(productId);
                    if (ltsResults.containsKey(productId)) {
                        results.put(classId, true);
                    }
                }
            }

        } catch (Exception e) {
            System.debug('');
            throw new phss_cc_Exception(FAILED_TO_IDENTIFY_LTS_CLASS, e);
        }

        return results;
    }

    @AuraEnabled
    public static Id createIltLocation(String accountId, String name, String address1, String address2, String postcode, String state, String city) {

        // validate if the site is really new?
        List<redwing__ILT_Location__c> locations = [SELECT Id, Name, redwing__Address_1__c, redwing__Address_2__c, redwing__Postal_Code__c, redwing__State__c, redwing__City__c
                                                    FROM redwing__ILT_Location__c WHERE Account__c = :accountId];

        for (redwing__ILT_Location__c existingLoc : locations) {

            if (existingLoc.redwing__Address_1__c == address1 && existingLoc.redwing__Postal_Code__c == postcode && existingLoc.redwing__State__c == state && existingLoc.redwing__City__c == city &&
                    ( (String.isBlank(existingLoc.redwing__Address_2__c) && String.isBlank(address2)) || existingLoc.redwing__Address_2__c == address2 )) {

                return existingLoc.Id;
            }
        }

        // create if no match found to the existing ones
        redwing__ILT_Location__c loc = new redwing__ILT_Location__c();
        loc.Account__c = accountId;
        loc.Name = name;
        loc.redwing__Address_1__c = address1;
        loc.redwing__Street__c = address1;
        loc.redwing__Address_2__c = address2;
        loc.redwing__Postal_Code__c = postcode;
        loc.redwing__State__c = state;
        loc.redwing__City__c = city;

        insert loc;
        return loc.Id;
    }

//    @AuraEnabled
//    public static void handleFullServiceClass(String orderId, Integer studentCount) {
//
//        List<ccrz__E_OrderItem__c> orderItems = [SELECT Id, ccrz__Price__c, ccrz__SubAmount__c, ccrz__UnitOfMeasure__c, ccrz__Quantity__c, ccrz__ItemStatus__c FROM ccrz__E_OrderItem__c WHERE ccrz__Order__c =:orderId AND ccrz__UnitOfMeasure__c = 'Student'];
//
//        for (ccrz__E_OrderItem__c item : orderItems) {
//            item.ccrz__Quantity__c = studentCount;
//            item.ccrz__SubAmount__c = studentCount * item.ccrz__Price__c;
//            item.ccrz__OrderItemStatus__c = 'Shipped';
//        }
//
//        update orderItems;
//
//    }


    @AuraEnabled
    public static String handleFullServiceClass(String classId, Integer studentCount, String trainingEventId) {
        List<ccrz__E_OrderItem__c> updatedOrderItems = new List<ccrz__E_OrderItem__c>();
        List<ccrz__E_TransactionPayment__c> updatedTransactionPayments = new List<ccrz__E_TransactionPayment__c>();

        // query for opp with the same training event
        List<Training_Events__c> trainingEvents = [SELECT Id, CC_Order__c, CC_Order_Item__c FROM Training_Events__c WHERE Id = :trainingEventId];
        Training_Events__c te = trainingEvents[0];

        Set<String> unitsOfMeasure = new Set<String>{'Student', 'Each'};
        List<ccrz__E_OrderItem__c> orderItems = [SELECT Id, ccrz__Price__c, ccrz__SubAmount__c, ccrz__UnitOfMeasure__c, ccrz__Quantity__c, ccrz__ItemStatus__c FROM ccrz__E_OrderItem__c
                                                    WHERE (ccrz__Order__c = :te.CC_Order__c) AND (Id = :te.CC_Order_Item__c
                                                    OR (ccrz__ParentOrderItem__c = :te.CC_Order_Item__c AND ccrz__OrderLineType__c = 'Minor'))
                                                    AND ccrz__UnitOfMeasure__c IN :unitsOfMeasure ];

        for (ccrz__E_OrderItem__c item : orderItems) {
            ccrz__E_OrderItem__c updatedItem = new ccrz__E_OrderItem__c();
            updatedItem.Id = item.Id;
            updatedItem.ccrz__Quantity__c = studentCount;
            updatedItem.ccrz__SubAmount__c = studentCount * item.ccrz__Price__c;
            updatedOrderItems.add(updatedItem);
        }

        String resMessage;
        try {
            update updatedOrderItems;
            
            ccrz__E_Order__c ord = [SELECT Id, ccrz__TotalAmount__c, (SELECT Id, ccrz__Amount__c FROM ccrz__TransactionPayments__r) FROM ccrz__E_Order__c WHERE Id = :te.CC_Order__c LIMIT 1];

            // update transaction amount from order amount
            for (ccrz__E_TransactionPayment__c tp : ord.ccrz__TransactionPayments__r) {
                ccrz__E_TransactionPayment__c updatedPayment = new ccrz__E_TransactionPayment__c();
                updatedPayment.Id = tp.Id;
                updatedPayment.ccrz__Amount__c = ord.ccrz__TotalAmount__c;
                updatedTransactionPayments.add(updatedPayment);
            }
            update updatedTransactionPayments;

            List<ccrz__E_OrderItem__c> oItems = [SELECT Id, ccrz__OrderItemStatus__c, ILT_Class__c, ccrz__Order__c
                    FROM ccrz__E_OrderItem__c
                    WHERE (ccrz__Order__c = :te.CC_Order__c) AND (Id = :te.CC_Order_Item__c
                    OR (ccrz__ParentOrderItem__c = :te.CC_Order_Item__c AND ccrz__OrderLineType__c = 'Minor'))
                    //WHERE ccrz__Order__c = :te.CC_Order__c
                    //AND ILT_Class__c = :classId
                    AND ccrz__OrderItemStatus__c = 'Order Submitted'];
            system.debug('***oItems***'+oItems);

            updatedOrderItems.clear();
            for (ccrz__E_OrderItem__c oi : oItems)
            {
                ccrz__E_OrderItem__c updatedItem = new ccrz__E_OrderItem__c();
                updatedItem.Id = oi.Id;
                updatedItem.ccrz__OrderItemStatus__c = 'In Process';

                updatedOrderItems.add(updatedItem);
            }

            update updatedOrderItems;

            resMessage = 'Order items successfully updated to "In Process"';

        } catch (Exception e) {

            System.debug('lineNumber=' + e.getLineNumber());
            System.debug('stackTrace=' + e.getStackTraceString());
            System.debug('error message: '+ e.getMessage());

            resMessage = e.getMessage();
        }

        return resMessage;

    }

    
    public class CourseInfo{
        @AuraEnabled public String CourseName {get; set;}
        @AuraEnabled public String EndDate {get; set;}
        @AuraEnabled public String Instructor1 {get; set;}
        @AuraEnabled public String Instructor2 {get; set;}
        @AuraEnabled public String Account {get; set;}
        @AuraEnabled public String Location {get; set;}
        @AuraEnabled public String SessionId {get; set;}
        @AuraEnabled public String SuppInfo {get; set;}
        @AuraEnabled public Boolean classclosed {get; set;} 
        @AuraEnabled public Boolean futureDate{get;set;}
        @AuraEnabled public String closedDate {get; set;}
        @AuraEnabled public list<JSONWrapper.Students> lstStudents {get; set;} 
        @AuraEnabled public list<String> lsgralist{get; set;}
        @AuraEnabled public list<String> lsrealist{get; set;}
        @AuraEnabled public String oppId {get;set;}
        @AuraEnabled public String ccProdId {get;set;}
        @AuraEnabled public String RequestType {get; set;}
        @AuraEnabled public String CCOrderId {get; set;}
        @AuraEnabled public String TrainingEventId {get; set;}
    }
    
    
}