/*****************************************************************************************************
 
Class    :  TestGlobalUtil
Developer:  Krishna Kollu, Paras Bheda Blue Wolf Group LLC
Created  :  April 11, 2014
Modified :  April 11, 2014
Objective:  This class tests GlobalUtil
 
*****************************************************************************************************/
@isTest
private class TestGlobalUtil {
	static testMethod void testCastValue(){
		final String SAMPLE_STRING = 'ABC';
		final Date SAMPLE_DATE = Date.today()-1;
		final String SAMPLE_DATE_AS_STRING = SAMPLE_DATE.format();
		final Decimal SAMPLE_AMOUNT = 12.4;
		final String SAMPLE_AMOUNT_AS_STRING = SAMPLE_AMOUNT.toPlainString();
		final ID SAMPLE_ID='00B70000006d4pJ';
		final Integer SAMPLE_INTEGER = 4;
		final String SAMPLE_INTEGER_AS_STRING = SAMPLE_INTEGER.format();

		
		Map<String, Schema.SoapType> valueToSoapType = new Map<String, Schema.SoapType> {'TRUE'=>Schema.SoapType.Boolean,'FALSE'=>Schema.SoapType.Boolean,'true'=>Schema.SoapType.Boolean,
																						'false'=>Schema.SoapType.Boolean, SAMPLE_DATE_AS_STRING=>Schema.SoapType.Date,
																						SAMPLE_ID=>Schema.SoapType.ID,SAMPLE_STRING=>Schema.SoapType.String, 
																						SAMPLE_INTEGER_AS_STRING=>Schema.SoapType.Integer, SAMPLE_AMOUNT_AS_STRING=>Schema.SoapType.Double};
		Map<String, Object> valueToExpectedCastValue = new Map<String, Object> {'TRUE'=>true,'FALSE'=>false,'true'=>true,'false'=>false, SAMPLE_DATE_AS_STRING => SAMPLE_DATE,
																				SAMPLE_ID => SAMPLE_ID, SAMPLE_STRING => SAMPLE_STRING,
																				SAMPLE_INTEGER_AS_STRING => SAMPLE_INTEGER, SAMPLE_AMOUNT_AS_STRING => SAMPLE_AMOUNT};
				
		test.startTest();
			for(String valueString: valueToSoapType.keySet()){
				System.assertEquals(valueToExpectedCastValue.get(valueString), GlobalUtil.castValue(valueToSoapType.get(valueString), valueString), 'We expect to successfully cast any Date, Integers, Decimals, IDs and Booleans stored in a string format to the original format, when the original format is specified as a Schema.SOAPType');
			}
		test.stopTest();
	} 	
}