global with sharing class cc_ContractPriceSelectorController
{   
    public String grid { get; private set; }
 
 
    global cc_ContractPriceSelectorController()
    {
        grid = ccrz.cc_CallContext.priceGroupId;
    }
 
    @RemoteAction
    global static ccrz.cc_RemoteActionResult fetchPriceGroupsForUserAccount(ccrz.cc_RemoteActionContext ctx)
    {
        ccrz.ccLog.log(LoggingLevel.DEBUG,'M:E','fetchPriceGroupsForUser');
        ccrz.cc_RemoteActionResult response = new ccrz.cc_RemoteActionResult();
        response.success                    = false;
        response.inputContext               = ctx;
 
        Map<String,Object> dataMap = new Map<String,Object>();
 
        try
        {
             //OOTB CCRZ code commented out to change call sequence to fix the
             //Contract Selector Bug
             //String effectiveAccountId = ccrz.cc_CallContext.effAccount.Id;
             //ccrz.cc_CallContext.initRemoteContext(ctx);


            
            // To fix the 'Contract Selector Bug'  
            // First Initialize the context            
            ccrz.cc_CallContext.initRemoteContext(ctx);
            
            //And then Read the accountid
            String effectiveAccountId = ccrz.cc_CallContext.effAccount.Id;
            
            
 
            List<ContractPriceData> contractPriceGroupList = new List<ContractPriceData>();
                                                                 
            for (ccrz__E_PriceGroupAccount__c priceGroupAccount : cc_CommonUtil.fetchPriceGroupAccounts(effectiveAccountId))
            {
                ContractPriceData contractPriceData = new ContractPriceData();
                contractPriceData.priceGroupId = priceGroupAccount.ccrz__PriceGroup__c;
                contractPriceData.priceGroupName = priceGroupAccount.ccrz__PriceGroup__r.ccrz__GroupName__c;
 
                contractPriceGroupList.add(contractPriceData);
            }
            dataMap.put('contractPriceGroups',contractPriceGroupList );
            response.data = dataMap;
            response.success = true;
        }
        catch (Exception ex)
        {
            response.success = false;
            ccrz.ccLog.log(LoggingLevel.ERROR,'message', ex.getMessage());
        }
        finally
        {
            ccrz.ccLog.log(System.LoggingLevel.INFO, 'M:X', 'fetchPriceGroupsForUser');
            ccrz.ccLog.close(response);
        }
        return response;
    }
 
 
    public with sharing class ContractPriceData
    {
        public String priceGroupId {get; set;}
        public String priceGroupName {get; set;}
    }
 
}