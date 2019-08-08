global class CaseInsertUpdateEmailService implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,Messaging.Inboundenvelope envelope){
         Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();         
         result.success = true;      
        System.Debug('*** IN CaseInsertUpdateEmailService : ' + email.fromAddress);
        try {
          System.debug('email '+email);
          Messaging.InboundEmail.BinaryAttachment[] bAttachments = email.binaryAttachments;
          Messaging.InboundEmail.TextAttachment[] tAttachments = email.textAttachments;
          String csvbody='';
          System.debug('bAttachments '+bAttachments );
          Set<String> fileSet=new Set<String>();
          if(bAttachments !=null){
                         
            for(Messaging.InboundEmail.BinaryAttachment btt : bAttachments){                
              if(btt.filename.endsWith('.csv')){
                fileSet.add('csv');
                csvbody = btt.body.tostring();
                System.Debug('*** csvBody: ' + csvBody);
                
                List<Case> cases = parseFile(csvBody);
                
                try {
                    if(cases!=null && cases.size()>0){
                      Database.SaveResult[] srs=Database.update(cases,true);
                      sendEmail(email.subject,'The cases have been successfully updated. \n ',btt,email.fromAddress);
                    }else{
                      sendEmail(email.subject,'No records were found to be updated. Please review the data and the format of the attached file \n ',btt,email.fromAddress);  
                    }
                }catch (System.Dmlexception dmlEx) {
                  System.Debug('*** Failed to insert cases., Message: ' + dmlEx.getMessage());
                  sendEmail(email.subject,'There was an error while updating the file \n '+dmlEx.getMessage(),btt,email.fromAddress);
                  ExLog.log(dmlEx);
                }
              }else{
                  fileSet.add('Email'); 
                  
              }
            }
                       
          }
          /*if(fileSet!=null && fileSet.size()==0){
                sendEmail(email.subject,'There is no attachment found Please send csv file as an attachment.',null,email.fromAddress);        
          }else*/
          
          if((fileSet!=null && fileSet.size()==0) || (fileSet!=null && fileSet.size()>0 && !fileSet.contains('csv'))){
              sendEmail(email.subject,'No CSV file found as an attachment. Please resend the email with a CSV attachment.',null,email.fromAddress);        
          }
          return result;
          
        }catch (System.Exception ex) {
          System.Debug('*** Exception while processing inboundEmail, Message: ' + ex.getMessage());//todo: handle exception
          ExLog.log(ex);
          result.success = false;
          sendEmail('Error','There some error while updating file \n ',email.binaryAttachments[0],email.fromAddress);
          return result;
        }
        
        return result;
    }
    
    public List<Case> parseFile(String fileString) {
    
    if (String.isEmpty(fileString)) {
      System.Debug('*** fileString empty return null');
      ExLog.log('File String Cannot be null!', 'cls_Payment_Automation_Service');
      return null;
    }
    
    
    try {
      
      
        
      List<Case> cases = new List<Case>();
      
      String[] arrLines= fileString.split('\n');
      
      Integer linesProcessed = 0;

      for (Integer i = 1; i < arrLines.size(); i++) {
        
        System.Debug('      *** line: ' + arrLines[i]);
        
        String[] arrColumns = arrLines[i].split(',');
        
            
        Case caseTemp = new Case(id= arrColumns[0],Correct_Organization__c=arrColumns[1],Status=arrColumns[2],Primary_Close_Reason__c=arrColumns[3],Action_Taken__c=arrColumns[4],ownerId=Id.valueOf(arrColumns[6].trim()));
        cases.add(caseTemp);
        
        linesProcessed++;
      }
      
      return cases;
      
    }catch (System.Exception ex) {
      System.Debug('*** '+ex.getMessage());//todo: exp handling
      ExLog.log(ex);
    }
    
    return null;
  }
  
  public void sendEmail(String subject,String body,Messaging.InboundEmail.BinaryAttachment att,String fromEmail){
      
                  List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                  Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                  
                  String emailAddressString = Label.CaseInsertUpdateEmail;
                  List<String> toEmailAddresses = emailAddressString.split(';');   
                  // Step 2: Set list of people who should get the email
                  List<String> sendTo = new List<String>();
                  toEmailAddresses.add(fromEmail);
                  //sendTo.add(Label.CaseInsertUpdateEmail);
                  mail.setToAddresses(toEmailAddresses);    
    
                 // Step 4. Set email contents - you can use variables!
                 mail.setSubject(subject);                 
                 mail.setHtmlBody(body);
                 
                 // Create the email attachment
                if(att!=null){
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(att.fileName);
                efa.setBody(att.body);
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                } 
                 // Step 5. Add your email to the master list
                 mails.add(mail);
   
                 // Step 6: Send all emails in the master list
                Messaging.sendEmail(mails);    
  }
    
}