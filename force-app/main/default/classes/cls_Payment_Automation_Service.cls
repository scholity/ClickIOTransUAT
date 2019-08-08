/*****************************************************************************************************
 
Class    :  
Developer:  Kiril Minev
Created  :  
Modified :  
Objective:  
 
*****************************************************************************************************/
global class cls_Payment_Automation_Service implements Messaging.InboundEmailHandler{
	
	private CR_Automation__c settings = null;
	
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope envelope){
		
		
		Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
		result.success = true;
			
		System.Debug('*** IN cls_Payment_Automation_Service: ' + email.fromAddress);
		try {
			
			Messaging.InboundEmail.BinaryAttachment[] bAttachments = email.BinaryAttachments;
			String csvbody='';
			 
			if(bAttachments !=null){
			 	
				for(Messaging.InboundEmail.BinaryAttachment btt : bAttachments){
						
					if(btt.filename.endsWith('.csv')){
						csvbody = btt.body.toString();
						System.Debug('*** csvBody: ' + csvBody);
						
						List<Case> cases = parseFile(csvBody);
						
						try {
							insert cases;
						}catch (System.Dmlexception dmlEx) {
							System.Debug('*** Failed to insert cases., Message: ' + dmlEx.getMessage());
							ExLog.log(dmlEx);
						}
					}
				}
			}
			return result;
			
		}catch (System.Exception ex) {
			System.Debug('*** Exception while processing inboundEmail, Message: ' + ex.getMessage());//todo: handle exception
			ExLog.log(ex);
			result.success = false;
			return result;
		}
	}
	
	public List<Case> parseFile(String fileString) {
		
		if (String.isEmpty(fileString)) {
			System.Debug('*** fileString empty return null');
			ExLog.log('File String Cannot be null!', 'cls_Payment_Automation_Service');
			return null;
		}
		
		
		try {
			
			this.settings = CR_Automation__c.getInstance();
				
			List<Case> cases = new List<Case>();
			
			String[] arrLines= fileString.split('\n');
			
			Integer linesProcessed = 0;

			for (Integer i = 1; i < arrLines.size(); i++) {
				
				System.Debug('			*** line: ' + arrLines[i]);
				
				String[] arrColumns = arrLines[i].split(',');
				
				//Org ID:38360-DEBBY Course ID: HSSAQU402R OCR Submission: 3346677
				String caseSubject = 'Org ID: ' + arrColumns[2] + ' Course ID: ' + arrColumns[3] + ' ' + ' OCR Submission: ' + arrColumns[0] + ' ' + this.settings.Case_Subject_Append_Words__c;

				String caseDescription = 'The following Online Course Record is ready for review \r\n\n' +
										 'Course Record Number/Sheet Number: ' + arrColumns[0] + '\r\n\n' +
										 'Organization ID: ' + arrColumns[2] + '\r\n\n' +
										 'Organization Name: ' + arrColumns[2] + '\r\n\n' + 
										 'End Date: ' + arrColumns[10] + '\r\n\n' +
										 'Course ID: ' + arrColumns[3] + '\r\n\n';
				
				String strOwnerId = this.settings.Initial_Queue_Id__c;
				
				if (!String.isEmpty(arrColumns[2]) && (arrColumns[2].contains('NAN-') || arrColumns[2].contains('SI-'))) {
					strOwnerId = this.settings.Auto_Close_Queue__c;
				}
										 
				Case caseTemp = new Case(RecordTypeId = this.settings.Case_Record_Type_Id__c, Type = this.settings.Case_Type__c,
										 OwnerId = strOwnerId, Subject = caseSubject, Description = caseDescription,
										 Origin = this.settings.Case_Origin__c);
				cases.add(caseTemp);
				
				linesProcessed++;
			}
			
			return cases;
			
		}catch (System.Exception ex) {
			System.Debug('*** ');//todo: exp handling
			ExLog.log(ex);
		}
		
		return null;
	}

}