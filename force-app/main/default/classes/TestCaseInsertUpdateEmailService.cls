@isTest(seeAllData=true)
private class TestCaseInsertUpdateEmailService{
    
     public static testMethod void myUnitTest() {
     
         CaseInsertUpdateEmailService cues=new CaseInsertUpdateEmailService();
         
     
         // Create a new email, envelope object and Attachment
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        //cues.handleInboundEmail(email, envelope);
        
        email.subject = 'Test';
        email.plainTextBody = 'Hello, this a test email body. for testing purposes only. Bye';
        email.fromAddress ='test@test.com';
        envelope.fromAddress = 'maf@cloudsocius.com';
        //Messaging.InboundEmail.BinaryAttachment[] binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[2];
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.Filename = 'test.pdf';
        binaryAttachment.body = blob.valueOf('my attachment text');
        //binaryattachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binaryattachment };
        cues.handleInboundEmail(email, envelope);
        
        Messaging.InboundEmailResult result = cues.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true); 
     }
     
     public static testMethod void myUnitTest1() {
     
         CaseInsertUpdateEmailService cues=new CaseInsertUpdateEmailService();
         
     
         // Create a new email, envelope object and Attachment
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        //cues.handleInboundEmail(email, envelope);
        
        email.subject = 'Test';
        email.plainTextBody = 'Hello, this a test email body. for testing purposes only. Bye';
        email.fromAddress ='test@test.com';
        envelope.fromAddress = 'maf@cloudsocius.com';
        //Messaging.InboundEmail.BinaryAttachment[] binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[2];
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.Filename = 'test.csv';
        String body='Case ID,Correct Org ID,Status,Primary Close Reason,Action Taken,Closed By,Closed by ID\n'+
                    '500d000000KSfkj,NA,Closed - Invoicing,Credit Processed,Credit Memo,Jacqueline Raikevitch,005d0000001WGrg\n'+
                    '500d000000KSfQf,NA,Closed - Invoicing,Credit Processed,Credit Memo,Jacqueline Raikevitch,005d0000001WGrg';
        binaryAttachment.body = blob.valueOf(body);
        //binaryattachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binaryattachment };
        cues.handleInboundEmail(email, envelope);
        
        Messaging.InboundEmailResult result = cues.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true); 
     }
     
     public static testMethod void myUnitTest2() {
     
         CaseInsertUpdateEmailService cues=new CaseInsertUpdateEmailService();
         
     
         // Create a new email, envelope object and Attachment
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        //cues.handleInboundEmail(email, envelope);
        
        email.subject = 'Test';
        email.plainTextBody = 'Hello, this a test email body. for testing purposes only. Bye';
        email.fromAddress ='test@test.com';
        envelope.fromAddress = 'maf@cloudsocius.com';
        
        cues.handleInboundEmail(email, envelope);
        
        Messaging.InboundEmailResult result = cues.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true); 
     }
     
     public static testMethod void myUnitTest4() {
     
         CaseInsertUpdateEmailService cues=new CaseInsertUpdateEmailService();
         
     
         // Create a new email, envelope object and Attachment
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        //cues.handleInboundEmail(email, envelope);
        
        email.subject = 'Test';
        email.plainTextBody = 'Hello, this a test email body. for testing purposes only. Bye';
        email.fromAddress ='test@test.com';
        envelope.fromAddress = 'maf@cloudsocius.com';
        //Messaging.InboundEmail.BinaryAttachment[] binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[2];
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.Filename = 'test.csv';
        String body='Case ID,Correct Org ID,Status,Primary Close Reason,Action Taken,Closed By,Closed by ID\n';
                   
        binaryAttachment.body = blob.valueOf(body);
        //binaryattachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binaryattachment };
        cues.handleInboundEmail(email, envelope);
        
        Messaging.InboundEmailResult result = cues.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true); 
     }
     
      public static testMethod void myUnitTest5() {
     
         CaseInsertUpdateEmailService cues=new CaseInsertUpdateEmailService();
         
     
         // Create a new email, envelope object and Attachment
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        //cues.handleInboundEmail(email, envelope);
        
        email.subject = 'Test';
        email.plainTextBody = 'Hello, this a test email body. for testing purposes only. Bye';
        email.fromAddress ='test@test.com';
        envelope.fromAddress = 'maf@cloudsocius.com';
        //Messaging.InboundEmail.BinaryAttachment[] binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[2];
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.Filename = 'test.csv';
        String body='Case ID,Correct Org ID,Status,Primary Close Reason,Action Taken,Closed By\n'+
                    '500d000000KSfkj,NA,Closed - Invoicing,Credit Processed,Credit Memo,Jacqueline Raikevitch\n'+
                    '500d000000KSfQf,NA,Closed - Invoicing,Credit Processed,Credit Memo,Jacqueline Raikevitch';
        binaryAttachment.body = blob.valueOf(body);
        //binaryattachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binaryattachment };
        cues.handleInboundEmail(email, envelope);
        
        Messaging.InboundEmailResult result = cues.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true); 
     }



}