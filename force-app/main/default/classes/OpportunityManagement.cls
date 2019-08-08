/**
    * Apex Class : OpportunityManagement
    *   Description : Helper Class For OpportunityTrigger
    * Created By : Sudhir Kr. Jagetiya
    * Created Date : April 16,2012
    * Update by : Thomas Horsch - Teletech, Inc.
    * Update Date : November 14,2012
    * Update Description :Added in additional logic for Opportunity approver fields for BGST.
    */
public without sharing class OpportunityManagement 
{
    //default User Id
    static Id defaultUserId;

    static 
    {
        for (User us : [Select Id from User where isActive = true AND Name like : System.Label.DefaultMOMApprover Order By LastLoginDate DESC limit 1]){
            defaultUserId =  us.Id;
        }
    }
    
    //Call this if trigger fires on before insert or update
    public static void beforeInsertUpdate(List<Opportunity> newList, Map<Id,Opportunity> oldMap)
    {
        updateApprover(newList, oldMap);
    }
    
    //A method to populate Approver 1, Approver 2, Approver 3, and Approver 4
    static void updateApprover(List<Opportunity> newList, Map<Id,Opportunity> oldMap)
    {
        System.debug('Inside UpdateApprover(): newList:'+newList); 
        
        Boolean isInsert = oldMap == null;
        Boolean isUpdate = oldMap != null;
        set<Id> ownerIds = new Set<Id>();
        Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity>();
        
        for(Opportunity opp : newList)
        {
            System.debug('Inside Opportunity Iteration:'+opp.Name); 
            
            //if((isInsert || (isUpdate && (opp.OwnerId != oldMap.get(opp.Id).OwnerId || opp.Pricing_Approval_Level__c != oldMap.get(opp.Id).Pricing_Approval_Level__c))) && opp.Approval_Status__c != 'Approved' && opp.Pricing_Approval_Level__c != 'No Approval Needed'){
            /*
                remove this check because we need the approvers to dynamically change
                once the record is approved the logic will ignore not update the approvers
            */
            //if((isInsert || (isUpdate && (opp.OwnerId != oldMap.get(opp.Id).OwnerId || opp.Pricing_Approval_Level__c != oldMap.get(opp.Id).Pricing_Approval_Level__c))) && opp.Approval_Status__c != Constants.APPROVED)
            //{
            if (isInsert || (opp.Approval_Status__c != 'Approved' && opp.Approval_Status__c != 'Submit for Approval')) {
                mapOpportunities.put(opp.Id, opp);
                ownerIds.add(opp.OwnerId);
            }
        }
        
        //Map of Users with manager Ids
        Map<Id, User> mapUsers = new Map<Id, User>([Select Name, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId, Manager.Manager.Manager.ManagerId From User where Id IN :ownerIds]);
        
        // Getting Profile and Approver values from Custom setting
        BGST_Approvers__c BGSTAprovers =BGST_Approvers__c.getValues('Approvers Id');
        BGST_Profiles__c  BGSTProfiles = BGST_Profiles__c.getValues('Owner Profile');
        AquaticSalesDirector__c approverForAES=AquaticSalesDirector__c.getvalues('AES Approvers ID');
        
        for(Id oppId : mapOpportunities.KeySet())
        {
            Opportunity opp = mapOpportunities.get(oppId);
            
            opp.Approver_1__c = null;
            opp.Approver_2__c = null;
            opp.Approver_3__c = null;
            opp.Approver_4__c = null;
            
            //Checks for BGST first, if found follows BGST specific approval process guidelines
           
            //if(opp.owner.profile.name == Constants.BGST_Profile) {if(opp.Pricing_Approval_Level__c == Constants.APPROVAL_LEVEL_SALES_DIRECTOR)
           System.debug('Profile Name1234:'+opp.owner.profile.name+':Owner Profile:'+opp.Owner_Profile__c); 
            if(opp.Owner_Profile__c == BGSTProfiles.Sales_User__c  || opp.Owner_Profile__c == BGSTProfiles.Sales_Admin__c || opp.Owner_Profile__c.contains('BGST') )
            // {if(opp.Pricing_Approval_Level__c == Constants.APPROVAL_LEVEL_SALES_DIRECTOR)
            {
                //System.debug('Approval level is ' + opp.Pricing_Approval_Level__c + ' , setting Approvals to Management chain');
                //Modified by Sudhir to change logic as per new requirement - Apr 3rd 2017
                //SW - System.debug('Highest Discount:'+opp.Highest_Product_Discount_Value__c); 
                
                System.debug('Highest Discount:'+opp.Highest_Discount__c);
                
                // SW - if(opp.Highest_Product_Discount_Value__c>= 15.01 && opp.Highest_Product_Discount_Value__c <= 20.00)
                if(opp.Highest_Discount__c>= 15.01 && opp.Highest_Discount__c <= 20.00)
                {
                    //Hard coded and needs to go into custom settings
                    //opp.Approver_1__c = '005d00000040ghi';
                    System.debug('1st level approval'); 
                    opp.Approver_1__c = BGSTAprovers.Approver_1__c; 
                    opp.Approver_2__c = NULL;
                    // opp.Approval_Status__c='Submit for Approval';
                    opp.Pricing_Approval_Level__c='Submit for Approval';
                }
                //else if (opp.Highest_Product_Discount_Value__c > 20.00)
                else if (opp.Highest_Discount__c > 20.00)
                {
                    //Hard coded and needs to go into custom settings
                    //opp.Approver_1__c = '005d00000040ghi';                     
                    // opp.Approver_2__c = '005d0000001V8x9';
                    System.debug('2nd level approval'); 
                    opp.Approver_1__c = BGSTAprovers.Approver_1__c;
                    opp.Approver_2__c = BGSTAprovers.Approver_2__c;
                    // opp.Approval_Status__c='Submit for Approval';
                    opp.Pricing_Approval_Level__c='Submit for Approval';

                }
                else
                {
                    System.debug('No Approval');
                    opp.Approver_1__c = NULL; 
                    opp.Approver_2__c = NULL;
                    opp.Pricing_Approval_Level__c='No Approval Needed';
                    // opp.Approval_Status__c='N/A';
                }
                System.debug('Approver1:'+opp.Approver_1__c+':Approver2:'+opp.Approver_2__c); 
                //  }
                //opp.Approver_1__c = mapUsers.get(opp.OwnerId).ManagerId != null ? mapUsers.get(opp.OwnerId).ManagerId : defaultUserId; opp.Approver_2__c = mapUsers.get(opp.OwnerId).Manager.ManagerId != null ? mapUsers.get(opp.OwnerId).Manager.ManagerId : defaultUserId;

                //Commented by Sudhir has not required - Apr 3rd 2017
                /*
                }else if (opp.Pricing_Approval_Level__c == Constants.APPROVAL_LEVEL_MANAGER)
                {
                opp.Approver_1__c = mapUsers.get(opp.OwnerId).ManagerId != null ? mapUsers.get(opp.OwnerId).ManagerId : defaultUserId;
                } 
                */
            }//End of IF checking for BGST Profile
            
            //SCC profile Update, if found followes BGST specific approval process guidelines
            else if(opp.SCC_User__c == true) 
            {
                if (opp.Pricing_Approval_Level__c == Constants.APPROVAL_LEVEL_SALES_DIRECTOR)
                {
                    opp.Approver_1__c = mapUsers.get(opp.OwnerId).ManagerId;
                    opp.Approver_2__c = mapUsers.get(opp.OwnerId).Manager.ManagerId != null ? mapUsers.get(opp.OwnerId).Manager.ManagerId : defaultUserId;
                } 
                else if (opp.Pricing_Approval_Level__c == Constants.APPROVAL_LEVEL_MANAGER)
                {
                    opp.Approver_1__c = mapUsers.get(opp.OwnerId).ManagerId != null ? mapUsers.get(opp.OwnerId).ManagerId : defaultUserId;                
                }              
            }
            // AED Record Type
            else if (opp.RecordType.Name == 'AED')
            {
                System.Debug('AED REcordType'+opp.RecordType.Name);
                if(opp.Pricing_Approval_Level__c == Constants.APPROVAL_LEVEL_EXECUTIVE_DIRECTOR)
                {
                    opp.Approver_1__c = mapUsers.get(opp.OwnerId).ManagerId;
                    opp.Approver_2__c = mapUsers.get(opp.OwnerId).Manager.ManagerId != null ? mapUsers.get(opp.OwnerId).Manager.ManagerId : defaultUserId;
                    opp.Approver_3__c = mapUsers.get(opp.OwnerId).Manager.Manager.ManagerId != null ? mapUsers.get(opp.OwnerId).Manager.Manager.ManagerId : defaultUserId;
                }
            }
            
            //Changes Made by Sudhir for AES record type
            else if(opp.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('AES').getRecordTypeId())
            {
                System.debug('Actual++'+ opp.RecordTypeId + 'coming'+Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('AES').getRecordTypeId());
                
                //if(opp.Highest_Product_Discount_Value__c > 10.01 &&opp.Highest_Product_Discount_Value__c <= 20.00)
                if(opp.Highest_Discount__c > 10.01 &&opp.Highest_Discount__c <= 20.00)
                {
                    opp.Approver_1__c = mapUsers.get(opp.OwnerId).ManagerId;
                    System.debug('inside approval1'+opp.Approver_1__c);
                }
                //else if (opp.Highest_Product_Discount_Value__c > 20.01 &&opp.Highest_Product_Discount_Value__c <= 30.00)
                else if (opp.Highest_Discount__c > 20.01 &&opp.Highest_Discount__c <= 30.00)
                {
                    opp.Approver_1__c = mapUsers.get(opp.OwnerId).ManagerId; 
                    //Assignning "Sara Symanski" the AQ Director as approver 2
                    opp.Approver_2__c =approverForAES.ID_of_Director__c;
                    System.debug('Approver 2 '+opp.Approver_2__c);
                }
                //else if(opp.Highest_Product_Discount_Value__c > 30.01)
                else if(opp.Highest_Discount__c > 30.01)
                {
                    opp.Approver_1__c = mapUsers.get(opp.OwnerId).ManagerId;
                    //Assignning "Sara Symanski" the AQ Director as approver 2
                    opp.Approver_2__c =approverForAES.ID_of_Director__c;
                    //Assignning "Timothy Archuleta" the AQ Director as approver 3
                    opp.Approver_3__c=approverForAES.Executive_Director_ID__c;
                    System.debug('Approver 3 '+opp.Approver_3__c);
                }
            } // Up to Here for AES Record type
            
            
            //If not BGST then follow remaining process
            else
            {
                if (opp.Pricing_Approval_Level__c == Constants.APPROVAL_LEVEL_MOM)
                {
                    //System.debug('Approval level is ' + opp.Pricing_Approval_Level__c + ' , setting Approvals to Management chain');
                    opp.Approver_1__c = mapUsers.get(opp.OwnerId).ManagerId != null ? mapUsers.get(opp.OwnerId).ManagerId : defaultUserId;
                    opp.Approver_2__c = mapUsers.get(opp.OwnerId).Manager.ManagerId != null ? mapUsers.get(opp.OwnerId).Manager.ManagerId : defaultUserId;
                    opp.Approver_3__c = mapUsers.get(opp.OwnerId).Manager.Manager.ManagerId != null ? mapUsers.get(opp.OwnerId).Manager.Manager.ManagerId : defaultUserId; 
                    opp.Approver_4__c = mapUsers.get(opp.OwnerId).Manager.Manager.Manager.ManagerId != null ? mapUsers.get(opp.OwnerId).Manager.Manager.Manager.ManagerId : defaultUserId;
                }
                else if (opp.Pricing_Approval_Level__c == Constants.APPROVAL_LEVEL_EXECUTIVE_DIRECTOR)
                {
                    opp.Approver_1__c = mapUsers.get(opp.OwnerId).ManagerId != null ? mapUsers.get(opp.OwnerId).ManagerId : defaultUserId;
                    opp.Approver_2__c = mapUsers.get(opp.OwnerId).Manager.ManagerId != null ? mapUsers.get(opp.OwnerId).Manager.ManagerId : defaultUserId;
                    opp.Approver_3__c = mapUsers.get(opp.OwnerId).Manager.Manager.ManagerId != null ? mapUsers.get(opp.OwnerId).Manager.Manager.ManagerId : defaultUserId;
                   
                }
                else if (opp.Pricing_Approval_Level__c == Constants.APPROVAL_LEVEL_SALES_DIRECTOR)
                {
                    opp.Approver_1__c = mapUsers.get(opp.OwnerId).ManagerId != null ? mapUsers.get(opp.OwnerId).ManagerId : defaultUserId;
                    opp.Approver_2__c = mapUsers.get(opp.OwnerId).Manager.ManagerId != null ? mapUsers.get(opp.OwnerId).Manager.ManagerId : defaultUserId;
                } 
                else if (opp.Pricing_Approval_Level__c == Constants.APPROVAL_LEVEL_MANAGER)
                {
                    opp.Approver_1__c = mapUsers.get(opp.OwnerId).ManagerId != null ? mapUsers.get(opp.OwnerId).ManagerId : defaultUserId;                
                }  
            }
        }        
    }
}