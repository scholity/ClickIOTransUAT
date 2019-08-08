/*****************************************************************************************************
 
Class    :  GlobalUtil
Developer:  Krishna Kollu, Paras Bheda Blue Wolf Group LLC
Created  :  April 11, 2014
Modified :  April 11, 2014
Objective:  This class will include common functionality
 
*****************************************************************************************************/
public with sharing class GlobalUtil {
	/** Convert a string to an object type specified by the given soapType
	 *  @value the string to cast
	 * 	@soapType the specified soapType
	 *	@precondition soapType must be Id, String, Boolean, Date, Integer, or Double
	 */
	public static Object castValue(Schema.SoapType soapType, String value)
	{
		if(soapType == Schema.Soaptype.Id || soapType == Schema.Soaptype.String){
			return value;
		}
		else if(soapType == Schema.Soaptype.Boolean){
			return Boolean.valueOf(value);
		}
		else if(soapType == Schema.Soaptype.Date){
			return date.parse(value);
		}
		else if(soapType == Schema.Soaptype.Integer){
			return Integer.valueOf(value);
		}
		else if(soapType == Schema.Soaptype.Double){
			return Decimal.valueOf(value);
		}
		return null;
	}	
	
	public static Map<String, Schema.SObjectField> caseFields  {
		get {
			if(caseFields==null)
			{
				caseFields = Schema.SObjectType.Case.fields.getMap();
			}
			return caseFields;
		}
	}
	
	/*
	To get soap type:
	caseFields.get('fieldapiname').getDescribe().getSoapType()
	*/
}