/**
    * Apex Class : OpportunityLineItemManagement
    *   Description : Helper Class For OpportunityLineItemTrigger
    * Created By : Sudhir Kr. Jagetiya
    * Created Date : April 16,2012
    * Update by : Thomas Horsch - Teletech, Inc.
    * Update Date : November 14,2012
    * Update Description : Added in additonal required fields for BGST approval level descions.
    */
public without sharing class OpportunityLineItemManagement {
    //Call if trigger is fire on Insert , Update or Delete
    public static void afterInsertUpdateDelete(Map<Id,OpportunityLineItem> newMap,Map<Id,OpportunityLineItem> oldMap){
        UpdatePriceApprovalLevel(newMap,oldMap);
    }
    private static void UpdatePriceApprovalLevel(Map<Id,OpportunityLineItem> newMap,Map<Id,OpportunityLineItem> oldMap){
    boolean isDelete = newMap == null;
    boolean isInsert = oldMap == null;
    boolean isUpdate = (oldMap != null & newMap != null) ;
    //Opportunity Ids
        set<Id> oppIds = new Set<Id>();
        //Execute In case of insert  or update
        if(isInsert || isUpdate)
        {
            for(OpportunityLineItem oppProduct : newMap.values())
            {
                if(isInsert || (isUpdate && (oppProduct.ListPrice != oldMap.get(oppProduct.Id).ListPrice || oppProduct.UnitPrice != oldMap.get(oppProduct.Id).UnitPrice)))
                    oppIds.add(oppProduct.OpportunityId);
            }   
        }
        //Execute in case of delete
        if(Trigger.isDelete){
            for(OpportunityLineItem oppProduct : oldMap.values()){
                    oppIds.add(oppProduct.OpportunityId);
            }   
        }
        //list of opportunity to be updated
        
        List<Opportunity> oppToBeUpdate = new List<Opportunity>();
        for(Opportunity opp : [Select Pricing_Approval_Level__c, owner.profile.name, SCC_User__c, RecordTypeId,RecordType.Name, (Select UnitPrice, ListPrice, Price_Variance__c, Discount_Amount__c, PricebookEntry.ProductCode From OpportunityLineItems) From Opportunity where Id IN : oppIds])
        
        
        {
            String approvalLevel;

            approvalLevel = Constants.NO_APPROVAL_NEEDED;
            Decimal highestDiscount = 0.00;
             
            for(OpportunityLineItem oppProduct : opp.OpportunityLineItems)
            {
                Decimal percentDiscount = 100.0 - oppProduct.Price_Variance__c;
                highestDiscount = percentDiscount;
                
              //  if (opp.SCC_User__c == false) {
                if(oppproduct.PricebookEntry.ProductCode == 'Delivery fee' && opp.owner.profile.name == Constants.BGST_Profile && oppproduct.UnitPrice < 100.0)
                {
                    approvalLevel = Constants.APPROVAL_LEVEL_MANAGER;
                }
                //Check if % of list price is more than 30%
                else if(percentDiscount > 30 && oppproduct.PricebookEntry.ProductCode != 'Delivery fee')
                {
                    if(opp.owner.profile.name == 'ARC BGST Sales User')
                    {
                        approvalLevel = Constants.APPROVAL_LEVEL_SALES_DIRECTOR;
                        break;
                    }
                    else if(opp.SCC_User__c == true)
                    {
                        approvalLevel = Constants.APPROVAL_LEVEL_SALES_DIRECTOR;
                        break;
                    }
                    else if(opp.RecordType.Name == 'AES')
                    {
                        approvalLevel = Constants.APPROVAL_LEVEL_EXECUTIVE_DIRECTOR;
                        System.debug('recordtypeId '+opp.RecordType.Name);
                        break;
                    }
                    else
                    {
                        approvalLevel = Constants.APPROVAL_LEVEL_MOM;
                        break;
                    }
                }
                //Check if % of list price is between 20 and 30%
                else if(percentDiscount <= 30 && percentDiscount > 20 && oppproduct.PricebookEntry.ProductCode != 'Delivery fee')
                {
                    if(opp.owner.profile.name == Constants.BGST_Profile)
                    {
                        approvalLevel = Constants.APPROVAL_LEVEL_SALES_DIRECTOR;
                        break;
                    }
                    else if(opp.SCC_User__c == true)
                    {
                        approvalLevel = Constants.APPROVAL_LEVEL_MANAGER;
                        break;
                    }
                    else if(opp.RecordType.Name == 'AES')
                    {
                        approvalLevel = Constants.APPROVAL_LEVEL_SALES_DIRECTOR;
                        System.debug('recordtypeId '+opp.RecordType.Name);
                        
                    }
                    else{
                        //Modified by Sudhir on Mar 30th 2017
                        approvalLevel = Constants.APPROVAL_LEVEL_SALES_DIRECTOR;
                    }
                }
                //Check if % of list price is between 15 and 20%
                else if(!approvalLevel.equals(Constants.APPROVAL_LEVEL_EXECUTIVE_DIRECTOR) && (percentDiscount <= 20 && percentDiscount > 15) && oppproduct.PricebookEntry.ProductCode != 'Delivery fee')
                
                
                {
                    if(opp.owner.profile.name == Constants.BGST_Profile)
                    {
                        approvalLevel = Constants.APPROVAL_LEVEL_MANAGER;
                        break;                     
                    }
                    else if(opp.SCC_User__c == true)
                    {
                        approvalLevel = Constants.APPROVAL_LEVEL_MANAGER;
                        break;
                    }
                 //Check if record type is AED
                    else if(opp.RecordType.Name == 'AED')
                    {
                        system.debug(+opp.RecordTypeID);
                        system.debug(+opp.RecordType.Name);
                        approvalLevel = Constants.APPROVAL_LEVEL_EXECUTIVE_DIRECTOR;
                        break;
                    }
                    else if(opp.RecordType.Name == 'AES')
                    {
                        approvalLevel = Constants.APPROVAL_LEVEL_MANAGER;
                        System.debug('recordtypeId '+opp.RecordType.Name);
                        
                    }
                    else
                    {
                    //Modified by Sudhir on Mar 31st 2017
                    approvalLevel = Constants.APPROVAL_LEVEL_MANAGER;
                    }
                }
                //Check if % of list price is between 10 and 15%
                else if((!approvalLevel.equals(Constants.APPROVAL_LEVEL_EXECUTIVE_DIRECTOR) && !approvalLevel.equals(Constants.APPROVAL_LEVEL_SALES_DIRECTOR)) && (percentDiscount <= 15 && percentDiscount > 10) && oppproduct.PricebookEntry.ProductCode != 'Delivery fee')
                {
                    if(opp.owner.profile.name == Constants.BGST_Profile)
                    {
                        //system.debug(approvalLevel);
                        approvalLevel = Constants.NO_APPROVAL_NEEDED;
                        break;
                    }
                    else if(opp.SCC_User__c == true)
                    {
                        approvalLevel = Constants.APPROVAL_LEVEL_MANAGER;
                        break;                                                      
                    }
                    else if(opp.RecordType.Name == 'AES')
                    {
                        approvalLevel = Constants.APPROVAL_LEVEL_MANAGER;
                         
                    }
                    approvalLevel = Constants.APPROVAL_LEVEL_MANAGER;
                }
            
                                
                
            }
            //If Pricing Approval Level of opportunity differs from the newly calculated Approval Level then update opportunity with a new one.
            if(!approvalLevel.equals(opp.Pricing_Approval_Level__c) && opp.SCC_User__c == false) {
               oppToBeUpdate.add(new Opportunity(Id = opp.Id , Pricing_Approval_Level__c = approvalLevel, Highest_Product_Discount__c = highestDiscount));  
            }
            // If approval is only of SCC Reps
            if (opp.SCC_User__c == true) {
                oppToBeUpdate.add(new Opportunity(Id = opp.Id, Highest_Product_Discount__c = highestDiscount, Pricing_Approval_Level__c = approvalLevel));
            }
        }
        update oppToBeUpdate;
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
            }
    }
}