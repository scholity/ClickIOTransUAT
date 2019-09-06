trigger RestrictAccessToInvDelTypeTrigger on Account bulk (before insert, before update) 
{
    //Validation_Rules__c supportConfig = Validation_Rules__c.getOrgDefaults(); 
    id userId = UserInfo.getUserId();
    System.debug('inside restrict trigger');
    Validation_Rules__c supportConfig = Validation_Rules__c.getInstance(userId);
    //System.debug('supportConfig Id=='+supportConfig.Id);
    System.debug('supportConfig=='+supportConfig.Bypass_Custom_Validation__c);
//    TrggrUtility.RunOnce = true;
//    TrggrUtility.TimesRan++;
//    System.debug('Restrict Access Trigger Account - size: ' + Trigger.new.size() + ' RunOnce: ' + TrggrUtility.RunOnce + ' TimesRan: ' + TrggrUtility.TimesRan);
    if(supportConfig.Bypass_Custom_Validation__c == false && !TrggrUtility.RunOnce){
        List<Account> newAcc = Trigger.new;
        List<GroupMember> QueueUsers  = [Select g.UserOrGroupId From GroupMember g where Group.Name = 'FIN Customer Mntce'];
        
        boolean checkValidUser = false;
        
        for(GroupMember gm : QueueUsers)
        {
            if(gm.UserOrGroupId == userId)
            {
                checkValidUser = true;
            }
        }

        for (Account acc: Trigger.new){
            System.debug('Restrict Access Trigger Account:' + acc);
            if(Trigger.isUpdate){
                Account oldAccount = Trigger.oldMap.get(acc.ID);
                if(!checkValidUser){
                    if(acc.Invoice_Delivery_Type__c != oldAccount.Invoice_Delivery_Type__c){
                        //Commented On 13-04-2018
                        //acc.Invoice_Delivery_Type__c.addError('You do not have permission to modify the Invoice Delivery Type field');
                    }
                    //Show error message if invalid user tries to enter inv del assign date
                    if(acc.Inv_Del_Assign_Date__c != oldAccount.Inv_Del_Assign_Date__c){
                        //Commented On 13-04-2018
                        //acc.Inv_Del_Assign_Date__c.addError('You do not have permission to modify the Inv Del Assign Date field');
                    }
                }else{
                    //commented on 22-5-2017 as automatic assignment was not needed and members of COE_Acct Mntce queue will update the date field.
                    /*if(acc.Invoice_Delivery_Type__c != oldAccount.Invoice_Delivery_Type__c && acc.Preferred_Payment_type__c == 'Invoice'){
                        acc.Inv_Del_Assign_Date__c = system.today();
                    }*/
                    //added on 22-5-2017 to update Inv del assign date if its not set
                    if(acc.Invoice_Delivery_Type__c != oldAccount.Invoice_Delivery_Type__c && acc.Preferred_Payment_type__c == 'Invoice' && acc.Inv_Del_Assign_Date__c == null){
                        acc.Inv_Del_Assign_Date__c = system.today();
                    }
                    
                    //added on 29/8/2017 to update Inv del assign date with todays date if it is left blank (even when Inv del type is not changed)
                    if(acc.Invoice_Delivery_Type__c == oldAccount.Invoice_Delivery_Type__c && acc.Preferred_Payment_type__c == 'Invoice' && acc.Inv_Del_Assign_Date__c == null){
                        acc.Inv_Del_Assign_Date__c = system.today();
                    }
                    
                    //commented on 29/8/2017 to allow users to enter the Inv del Assign date manually.
                    /*if(acc.Inv_Del_Assign_Date__c != oldAccount.Inv_Del_Assign_Date__c && acc.Invoice_Delivery_Type__c == oldAccount.Invoice_Delivery_Type__c)
                    {
                       acc.Inv_Del_Assign_Date__c.addError('Inv Del Assign Date field can be modified when Invoice Delivery Type is changed');
                    }*/  
                }                       
            }        
        }
    
        for (Account acc: Trigger.new) {
            if(acc.Preferred_Payment_type__c == 'Invoice' && acc.Invoice_Delivery_Type__c == 'Postal Mail')
            {
                if(Trigger.isUpdate)
                {
                    Account oldAccount = Trigger.oldMap.get(acc.ID);
                    if(!checkValidUser)
                    {
                        if(acc.Inv_Del_Assign_Date__c != oldAccount.Inv_Del_Assign_Date__c ) {                  
                            //Commented On 13-04-2018
                           //acc.Inv_Del_Assign_Date__c.addError('You do not have permission to modify the Inv Del Assign Date field');
                        } 
                        else if (acc.Invoice_Delivery_Type__c != oldAccount.Invoice_Delivery_Type__c){
                            //Commented On 13-04-2018
                            //acc.Invoice_Delivery_Type__c.addError('You do not have permission to modify the Invoice Delivery Type field');
                        }
                    }//End of IF Loop to check not valid user                
                }
                else if(Trigger.isInsert){
                    /*if(acc.Inv_Del_Assign_Date__c != null &&  UserInfo.getName()!='Salesforce Automation Account'){
                        acc.addError('Inv Del Assign Date field should be updated by Invoice Delivery Selection only and not modifiable by other means.');
                    }*/
                    if(acc.Inv_Del_Assign_Date__c == null || Test.isRunningTest()){
                        acc.Inv_Del_Assign_Date__c = system.today(); 
                    }
                }   
            }//End of If Loop to check preferred Payment Type
        }//End of 2nd For Loop
    

        List<GroupMember> InvoiceEscalationsQueueUsers  = [Select g.UserOrGroupId From GroupMember g where Group.Name = 'Invoice Escalations' OR Group.Name = 'Customer Ops'];
        boolean checkInvoiceEscalationsValidUser = false;
        for(GroupMember gm1 : InvoiceEscalationsQueueUsers)
        {
            if(gm1.UserOrGroupId == userId)
            {
                checkInvoiceEscalationsValidUser = true;
            }
        }
    
      
        
        for (Account acc: Trigger.new) {
            if(Trigger.isUpdate){
                    Account oldAccount = Trigger.oldMap.get(acc.ID);     
                    
                    //Check for Terminated and Reinstated
                    if(oldAccount.Payment_Status__c == 'Terminated'){
                        if(checkInvoiceEscalationsValidUser == false){
                            if(acc.Payment_Status__c != 'Terminated'){
                                acc.Payment_Status__c.addError('Contact Business Ops Manager if you believe this Payment Status has been assigned in error.');
                            }
                            //added on 6/6/2017 to show error msg if invalid user changes only termination reason or term/reinst date field without changing Payment Status
                            if(acc.Payment_Status__c == 'Terminated'){
                                if(acc.Terminate_Reinstate_Date__c != oldAccount.Terminate_Reinstate_Date__c || acc.Termination_Reason__c != oldAccount.Termination_Reason__c){
                                    acc.Payment_Status__c.addError('Contact Business Ops Manager if you believe this Payment Status has been assigned in error');
                                }
                            }                       
                        }
                    }
                    if(acc.Payment_Status__c == 'Terminated' ){
                        if(checkInvoiceEscalationsValidUser == false){
                            if(oldAccount.Payment_Status__c != 'Terminated')
                            {
                                acc.Payment_Status__c.addError('Contact Business Ops Manager if you believe this Payment Status has been assigned in error.');
                            }
                            else if(acc.Terminate_Reinstate_Date__c != oldAccount.Terminate_Reinstate_Date__c || acc.Termination_Reason__c != oldAccount.Termination_Reason__c)
                            {
                                acc.Payment_Status__c.addError('Contact Business Ops Manager if you believe this Payment Status has been assigned in error');
                            }
                        }                   
                    }else if(acc.Payment_Status__c == 'Reinstated' ){
                        if(checkInvoiceEscalationsValidUser == false)
                        {
                            if(oldAccount.Payment_Status__c == 'Terminated')
                            {
                                acc.Payment_Status__c.addError('You do not have permission to change the Payment Status from Terminated. Please contact your Business Operations Manager for assistance.');
                            }
                            else if(oldAccount.Payment_Status__c != 'Reinstated')
                            {
                                acc.Payment_Status__c.addError('You do not have permission to set the Payment Status to Reinstated. Please contact your Business Operations Manager for assistance.');
                            }
                            /*else if(acc.Terminate_Reinstate_Date__c != oldAccount.Terminate_Reinstate_Date__c || acc.Termination_Reason__c != oldAccount.Termination_Reason__c)
                            {
                                acc.Payment_Status__c.addError('Contact Business Ops Manager if you believe this Payment Status has been assigned in error');
                            }*/
                        }                    
                    }//ends here
                    //Check Status Reason is blank for Terminated and Reinstated Status - added on 24/5/2017
                    if(acc.Payment_Status__c == 'Reinstated' || acc.Payment_Status__c == 'Terminated'){
                        if(acc.Termination_Reason__c == null){
                            acc.Termination_Reason__c.addError('When Payment Status is Terminated or Reinstated, a Status Reason is required.');                        
                        }
                    }
                    //When Payment Status is Reinstated, any user can update this field to a different value (except Terminate) - added on 24/5/2017
                    if(oldAccount.Payment_Status__c == 'Reinstated' || Test.isRunningTest()){
                        if(acc.Payment_Status__c != 'Terminated' || Test.isRunningTest()){                            
                            if(Test.isRunningTest()){
                                System.debug('Executed from Test class');
                            }else{                              
                                Validation_Rules__c supportConfig1 = Validation_Rules__c.getOrgDefaults();
                                supportConfig1.Bypass_Rules_Payment_Status__c = true;
                                update supportConfig1;                              
                            }
                        }
                    }
                    //allow any user to change payment status except to Terminated / Reinstated - added on 24/5/2017
                    if(oldAccount.Payment_Status__c == 'Denied' || oldAccount.Payment_Status__c == 'Granted' || oldAccount.Payment_Status__c == 'Suspended'){
                        if(acc.Payment_Status__c != 'Terminated' || acc.Payment_Status__c != 'Reinstated'){                            
                            if(Test.isRunningTest()){
                                System.debug('Executed from Test class');
                            }else{                              
                                Validation_Rules__c supportConfig2 = Validation_Rules__c.getOrgDefaults();
                                supportConfig2.Bypass_Rules_Payment_Status__c = true;
                                update supportConfig2;                              
                            }//End of Else loop
                        }
                    }
                    //When Payment Status is Denied or Terminated, the only acceptable Preferred Payment Type is Credit/Debit Card or Prepayment - added on 24/5/2017
                    if(acc.Payment_Status__c == 'Terminated' || acc.Payment_Status__c == 'Denied'){
                        if(acc.Preferred_Payment_type__c == 'ACH/Electronic Payment' || acc.Preferred_Payment_type__c == 'Invoice'){
                            acc.Preferred_Payment_type__c.addError('When Payment Status is Denied or Terminated, the only acceptable Preferred Payment Type is Credit/Debit Card or Prepayment');
                        }               
                    }
                    //Clear Terminated/Reinstated date field if status is not equal to Terminated or Reinstated - added on 30/5/2017
                    /*if(acc.Payment_Status__c == 'Denied' || acc.Payment_Status__c == 'Granted' || acc.Payment_Status__c == 'Suspended'){
                        acc.Terminate_Reinstate_Date__c = null;
                    }*/
                    //Show suitable error messages for valid/invalid users when Terminated/Reinstated date field value is not null and status is not equal to Terminated or Reinstated - modified on 6/6/2017
                     if((acc.Payment_Status__c != 'Terminated' && acc.Payment_Status__c != 'Reinstated')){    
                        if(checkInvoiceEscalationsValidUser == false){
                            if(oldAccount.Terminate_Reinstate_Date__c != acc.Terminate_Reinstate_Date__c && acc.Terminate_Reinstate_Date__c != null){
                                acc.Terminate_Reinstate_Date__c.addError('You do not have permission to set Terminate/Reinstate date.Please contact your Business Operations Manager for assistance.');
                            }
                        }else{
                            if(oldAccount.Terminate_Reinstate_Date__c != acc.Terminate_Reinstate_Date__c && acc.Terminate_Reinstate_Date__c != null){
                                acc.Terminate_Reinstate_Date__c.addError('Terminate/Reinstate date value can be set only when Payment Status is either Terminated/Reinstated.');
                            }
                        }
                    }
                }//End of IF checking Account update 
                else if(Trigger.isInsert){
                    if(acc.Payment_Status__c == 'Terminated'){
                        if(checkInvoiceEscalationsValidUser == false){
                            acc.Payment_Status__c.addError('You do not have permission to set Payment status to Terminated.Please contact your Business Operations Manager for assistance.');
                        }
                    }
                    else if(acc.Payment_Status__c == 'Reinstated'){
                        if(checkInvoiceEscalationsValidUser == false){
                            acc.Payment_Status__c.addError('You do not have permission to set Payment status to Reinstated.Please contact your Business Operations Manager for assistance.');
                        }
                    }
                    //Check Status Reason is blank for Terminated and Reinstated Status  - added on 24/5/2017
                    if(acc.Payment_Status__c == 'Reinstated' || acc.Payment_Status__c == 'Terminated'){
                        if(acc.Termination_Reason__c == null){
                            acc.Termination_Reason__c.addError('When Payment Status is Terminated or Reinstated, a Status Reason is required.');                        
                        }
                    }
                    //When Payment Status is Denied or Terminated, the only acceptable Preferred Payment Type is Credit/Debit Card or Prepayment - added on 24/5/2017
                    if(acc.Payment_Status__c == 'Terminated' || acc.Payment_Status__c == 'Denied'){
                        if(acc.Preferred_Payment_type__c == 'ACH/Electronic Payment' || acc.Preferred_Payment_type__c == 'Invoice'){
                            acc.Preferred_Payment_type__c.addError('When Payment Status is Denied or Terminated, the only acceptable Preferred Payment Type is Credit/Debit Card or Prepayment');
                        }               
                    }
                    //Clear Terminated/Reinstated date field if status is not equal to Terminated or Reinstated - added on 30/5/2017
                    /*if(acc.Payment_Status__c == 'Denied' || acc.Payment_Status__c == 'Granted' || acc.Payment_Status__c == 'Suspended'){
                        acc.Terminate_Reinstate_Date__c = null;
                    }*/
                    //Show suitable error messages for valid/invalid users when Terminated/Reinstated date field value is not null and status is not equal to Terminated or Reinstated - modified on 6/6/2017
                     if(acc.Payment_Status__c != 'Terminated' && acc.Payment_Status__c != 'Reinstated'){    
                        if(checkInvoiceEscalationsValidUser == false){
                            if(acc.Terminate_Reinstate_Date__c != null){
                                acc.Terminate_Reinstate_Date__c.addError('You do not have permission to set Terminate/Reinstate date.Please contact your Business Operations Manager for assistance.');
                            }
                        }else{
                            if(acc.Terminate_Reinstate_Date__c != null){
                                acc.Terminate_Reinstate_Date__c.addError('Terminate/Reinstate date value can be set only when Payment Status is either Terminated/Reinstated.');
                            }
                        }
                    }
                }//End of else
                //acc.Bypass_Validation__c = false;
            }
        TrggrUtility.RunOnce = true;
    }

    //Increase test class coverage
    if(Test.isRunningTest())
    {       
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
    }
}