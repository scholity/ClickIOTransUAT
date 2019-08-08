global with sharing class cc_phss_ccLogicPLEntLists extends ccrz.ccLogicPLEntLists
{
    global override Map<String,Object> createPricingContext(Map<String,Object> inputData) 
    {
       Map<String,Object> outputData =  super.createPricingContext(inputData);

         // Enabling the contract pricing feature via apex
         if(!ccrz.ccUtil.isKeyValued(inputData, ccrz.ccApiPriceList.PRGRID) )
        {
             String priceGroupId = phss_cc_Context.fetchPriceGroupIdByAccount(ccrz.cc_CallContext.entAccountId ,ccrz.cc_CallContext.storefront);

              outputData.put(ccrz.ccApiPriceList.PRGRID, priceGroupId);
              outputData.put(ccrz.ccApiPriceList.ALLWMIX, true);
        } 

        return  outputData; 	
		}
   
}