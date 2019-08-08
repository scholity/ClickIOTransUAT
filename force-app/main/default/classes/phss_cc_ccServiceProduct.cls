global with sharing class phss_cc_ccServiceProduct extends ccrz.ccServiceProduct {

    global virtual override Map<String, Object> getFieldsMap(Map<String, Object> inputData)
    {
        inputData = super.getFieldsMap(inputData);

        String objectFields = (String)inputData.get(ccrz.ccService.OBJECTFIELDS);

        objectFields += ',Course_Catalog__r.Number_of_Students__c' ;

        return new Map <String,Object> {ccrz.ccService.OBJECTFIELDS => objectFields};
    }


    global virtual override Map<String, Object> getSubQueryMap(Map<String, Object> inputData)
    {
        Map<String, Object> retData = super.getSubQueryMap(inputData);

        String compositeProductsQuery = String.valueOf(retData.get('CompositeProducts__r'));

        String newField = ', Student_Ratio__c ';

        compositeProductsQuery = compositeProductsQuery.replace('FROM', newField + ' FROM');

        retData.put('CompositeProducts__r', compositeProductsQuery);

        return retData;
    }
}