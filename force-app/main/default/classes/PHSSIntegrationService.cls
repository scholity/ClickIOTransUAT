public class PHSSIntegrationService{
    // method to perform quick search using phone number
    public PHSSModel.ConstituentSearchResultWrapper doPhoneSearch (String strPhone){
        // list of params to be sent to the web service
        List<redcrossBiztalkIntegrationT2sfdc.ParamType> paramList = new List<redcrossBiztalkIntegrationT2sfdc.ParamType>();

        // the name of the DW view to query
        paramList.add(new redcrossBiztalkIntegrationT2sfdc.ParamType(   DW2PHSSMappingConstants.strViewName_ParamName, 
                                                                        DW2PHSSMappingConstants.strPhoneSearch, 
                                                                        '')); 
        // the maximum number of results to be returned
        paramList.add(new redcrossBiztalkIntegrationT2sfdc.ParamType(   DW2PHSSMappingConstants.strNumberOfRecords_ParamName, 
                                                                        DW2PHSSMappingConstants.strMaxNumberOfSearchRecords, 
                                                                        ''));
        // allow order by for the search
        paramList.add(new redcrossBiztalkIntegrationT2sfdc.ParamType(   DW2PHSSMappingConstants.strAllowOrderBy_ParamName, 
                                                                        'True', 
                                                                        ''));
        // default order by for the search
        paramList.add(new redcrossBiztalkIntegrationT2sfdc.ParamType(   DW2PHSSMappingConstants.strDefaultOrderBy_ParamName,
                                                                        DW2PHSSMappingConstants.strConstSearchDefaultOrderBy,
                                                                        ''));
        // added by MM
         paramList.add(new redcrossBiztalkIntegrationT2sfdc.ParamType(  DW2PHSSMappingConstants.strPhoneNumber_ColumnName,
                                                                        strPhone,
                                                                        DW2PHSSMappingConstants.strQueryFilter_Like));
        
      
        
        
        // add the params to the list and construct the request
        redcrossBiztalkIntegrationT2sfdc.ArrayOfParamType params = new redcrossBiztalkIntegrationT2sfdc.ArrayOfParamType(paramList);
        redcrossBiztalkIntegrationT2sfdc.ExternalQueryRequest searchConstituentsRequest = new redcrossBiztalkIntegrationT2sfdc.ExternalQueryRequest(params);
        
        // invoke the service and retrieve response
        redcrossBiztalkIntegrationT2sfdc.QueryResponse searchConstituentsResponse = createServiceStub().SearchConstituents(searchConstituentsRequest);
        
        if( searchConstituentsResponse.Success && searchConstituentsResponse.Record.RecordType != null){
            // if the service operation is successful and the search returns a response
            return new PHSSModel.ConstituentSearchResultWrapper(getConstituentSearchResults(searchConstituentsResponse.Record.RecordType),
                                                                searchConstituentsResponse.QueryRequest != null 
                                                                && searchConstituentsResponse.QueryRequest.QueryRequest != null
                                                                ? new PHSSModel.SortCriteria(   searchConstituentsResponse.QueryRequest.QueryRequest.get(0),
                                                                                                DW2PHSSMappingConstants.strContactFirstName_ColumnName)
                                                                : null);
        }else{
            // handle errors / no search results.
        }
        return null;
    }
    
    // method to perform general search using phone number
    public PHSSModel.ConstituentSearchResultWrapper doGeneralSearch (PHSSModel.ConstituentSearchCriteria constituentSearchCriteria){
        // list of params to be sent to the web service
        List<redcrossBiztalkIntegrationT2sfdc.ParamType> paramList = new List<redcrossBiztalkIntegrationT2sfdc.ParamType>();

        // the name of the DW view to query
        paramList.add(new redcrossBiztalkIntegrationT2sfdc.ParamType(   DW2PHSSMappingConstants.strViewName_ParamName, 
                                                                        DW2PHSSMappingConstants.strGeneralSearch, 
                                                                        '')); 
        // the maximum number of results to be returned
        paramList.add(new redcrossBiztalkIntegrationT2sfdc.ParamType(   DW2PHSSMappingConstants.strNumberOfRecords_ParamName, 
                                                                        DW2PHSSMappingConstants.strMaxNumberOfSearchRecords, 
                                                                        ''));
        // allow order by for the search
        paramList.add(new redcrossBiztalkIntegrationT2sfdc.ParamType(   DW2PHSSMappingConstants.strAllowOrderBy_ParamName, 
                                                                        'True', 
                                                                        ''));
       
      
        paramList.add(new redcrossBiztalkIntegrationT2sfdc.ParamType(   DW2PHSSMappingConstants.strDefaultOrderBy_ParamName,
                                                                        DW2PHSSMappingConstants.strGeneralSearchDefaultOrderBy,
                                                                        ''));
        
        
        /* 
        *	Changes block start
        *
        *	Code Modified On: 12/2/2014
        * 	Modified By: Kiril Minev
        *   Reason:
        */
        
        if (String.isNotBlank(constituentSearchCriteria.FirstName)) {
	        // the first name to query for
	        paramList.add(new redcrossBiztalkIntegrationT2sfdc.ParamType(   DW2PHSSMappingConstants.strContactFirstName_ColumnName,
	                                                                        constituentSearchCriteria.FirstName,
	                                                                        DW2PHSSMappingConstants.strQueryFilter_Like));
        
        }
        
        // the last name to query for
        if (String.isNotBlank(constituentSearchCriteria.LastName)) {
	        paramList.add(new redcrossBiztalkIntegrationT2sfdc.ParamType(   DW2PHSSMappingConstants.strContactLastName_ColumnName,
	                                                                        constituentSearchCriteria.LastName,
	                                                                        DW2PHSSMappingConstants.strQueryFilter_Like));
        }
        
        if (String.isNotBlank(constituentSearchCriteria.City)) {
	        // the city to query for
	        paramList.add(new redcrossBiztalkIntegrationT2sfdc.ParamType(   DW2PHSSMappingConstants.strCity_ColumnName,
	                                                                        constituentSearchCriteria.City,
	                                                                        DW2PHSSMappingConstants.strQueryFilter_Like));
        }
        
        if (String.isNotBlank(constituentSearchCriteria.State)) {
	        // the state to query for
	        paramList.add(new redcrossBiztalkIntegrationT2sfdc.ParamType(   DW2PHSSMappingConstants.strState_ColumnName,
	                                                                        constituentSearchCriteria.State,
	                                                                        DW2PHSSMappingConstants.strQueryFilter_Equals));
        }
        
        if (String.isNotBlank(constituentSearchCriteria.Zip)) {
        	// the zip to query for
	        paramList.add(new redcrossBiztalkIntegrationT2sfdc.ParamType(   DW2PHSSMappingConstants.strZip_ColumnName,
	                                                                        constituentSearchCriteria.Zip,
	                                                                        DW2PHSSMappingConstants.strQueryFilter_Like));
        }
        
        if (String.isNotBlank(constituentSearchCriteria.Phone)) {
	        // the phone number to query for
	        paramList.add(new redcrossBiztalkIntegrationT2sfdc.ParamType(   DW2PHSSMappingConstants.strPhoneNumber_ColumnName,
	                                                                        constituentSearchCriteria.Phone,
	                                                                        DW2PHSSMappingConstants.strQueryFilter_Like));
        }
        
        if (String.isNotBlank(constituentSearchCriteria.EmailAddress)) {
	        // the email address to query for
	        paramList.add(new redcrossBiztalkIntegrationT2sfdc.ParamType(   DW2PHSSMappingConstants.strEmailAddress_ColumnName,
	                                                                        constituentSearchCriteria.EmailAddress,
	                                                                     DW2PHSSMappingConstants.strQueryFilter_Like));
        }
 		
 		
 		/* Changes block stop */
 		
 		// Uncommented by MM 5/16/2013   
        // the partition criteria for the query
        paramList.add(new redcrossBiztalkIntegrationT2sfdc.ParamType( DW2PHSSMappingConstants.strPartitionCriteria_ParamName,
                                                                      DW2PHSSMappingConstants.strGeneralSearch_PartitionCriteria,
                                                                      ''));
     
  
                                                                        
        // add the params to the list and construct the request
        redcrossBiztalkIntegrationT2sfdc.ArrayOfParamType params = new redcrossBiztalkIntegrationT2sfdc.ArrayOfParamType(paramList);
        redcrossBiztalkIntegrationT2sfdc.ExternalQueryRequest searchConstituentsRequest = new redcrossBiztalkIntegrationT2sfdc.ExternalQueryRequest(params);
        
        
        // invoke the service and retrieve response
        redcrossBiztalkIntegrationT2sfdc.QueryResponse searchConstituentsResponse = createServiceStub().SearchConstituents(searchConstituentsRequest);
        
        System.debug('***** search cconstituents response: ' +searchConstituentsResponse );
        if(searchConstituentsResponse.Success && searchConstituentsResponse.Record.RecordType != null){
            // if the service operation is successful and the search returns a response
            return new PHSSModel.ConstituentSearchResultWrapper(getConstituentSearchResults(searchConstituentsResponse.Record.RecordType),
                                                                searchConstituentsResponse.QueryRequest != null 
                                                                && searchConstituentsResponse.QueryRequest.QueryRequest != null
                                                                ? new PHSSModel.SortCriteria(   searchConstituentsResponse.QueryRequest.QueryRequest.get(0),
                                                                                                DW2PHSSMappingConstants.strContactFirstName_ColumnName)
                                                                : null);
        }else{
            // handle errors / no search results.
        }
        return null;
    }
    
    
    
    // method to retrieve the details of a selected constituent
    public PHSSModel.ConstituentDetail doConstituentDetails(String strConstituentId){
        // list of params to be sent to the web service
        List<redcrossBiztalkIntegrationT2sfdc.ParamType> paramList = new List<redcrossBiztalkIntegrationT2sfdc.ParamType>();
        for(String strConstituentQuery: DW2PHSSMappingConstants.strConstituentDetailsQuery.split(',')){
            paramList.add(new redcrossBiztalkIntegrationT2sfdc.ParamType(   DW2PHSSMappingConstants.strSchema + '.' + strConstituentQuery, 
                                                                            strConstituentId, 
                                                                            ''));
        }
		
		System.Debug('*** PHSSIntegrationService, PARAMS: ' + paramList);
		
        // add the params to the list and construct the request
        redcrossBiztalkIntegrationT2sfdc.ArrayOfParamType params = new redcrossBiztalkIntegrationT2sfdc.ArrayOfParamType(paramList);
        redcrossBiztalkIntegrationT2sfdc.ExternalQueryRequest constituentDetailsRequest = new redcrossBiztalkIntegrationT2sfdc.ExternalQueryRequest(params);
        
        // invoke the service and retrieve response
        redcrossBiztalkIntegrationT2sfdc.QueryResponse constituentDetailsResponse = createServiceStub().GetConstituentDetails(constituentDetailsRequest);
        
        System.debug('**** queryResponse: ' + constituentDetailsResponse );
        
        if(constituentDetailsResponse.Success && constituentDetailsResponse.Record.RecordType != null){
            // if the service operation is successful and the search returns a response
            return getConstituentDetails(constituentDetailsResponse.Record.RecordType);
        }else{
            // handle errors / no search results.
        }
        return null;
    }
    
    private List<PHSSModel.ConstituentSearchResult> getConstituentSearchResults(redcrossBiztalkIntegrationT2sfdc.RecordType[] listRecords){
        // list of search results to be returned
        List<PHSSModel.ConstituentSearchResult> listConstituentSearchResults = new List<PHSSModel.ConstituentSearchResult>();
        
        // iterate over the records obtained from the web service results   
        for (redcrossBiztalkIntegrationT2sfdc.RecordType record: listRecords){
            // create an instance of the search results model and assign corresponding values
          
      		PHSSModel.ConstituentSearchResult constituentSearchResult = new PHSSModel.ConstituentSearchResult();
          
  
            
            constituentSearchResult.SabaPersonId = getFieldValue(record, DW2PHSSMappingConstants.strSabaPersonId_ColumnName);
            
            
            // added by MM on 5/16/2013
            constituentSearchResult.Name =  getFieldValue(record, DW2PHSSMappingConstants.strARCBESTContactFullName_ColumnName) != ''
                                ? getFieldValue(record, DW2PHSSMappingConstants.strARCBESTContactFullName_ColumnName)
		                        : getFieldValue(record, DW2PHSSMappingConstants.strContactFullName_ColumnName);
            
            constituentSearchResult.FirstName = getFieldValue(record, DW2PHSSMappingConstants.strARCBESTContactFirstName_ColumnName) != ''
								? getFieldValue(record, DW2PHSSMappingConstants.strARCBESTContactFirstName_ColumnName)
								: getFieldValue(record, DW2PHSSMappingConstants.strContactFirstName_ColumnName);            
            
			constituentSearchResult.LastName =  getFieldValue(record, DW2PHSSMappingConstants.strARCBESTContactLastName_ColumnName) != ''
								? getFieldValue(record, DW2PHSSMappingConstants.strARCBESTContactLastName_ColumnName)
								: getFieldValue(record, DW2PHSSMappingConstants.strContactLastName_ColumnName);
			
			constituentSearchResult.Phone = getFieldValue(record, DW2PHSSMappingConstants.strARCBESTPhoneNumber_ColumnName) != ''
								? getFieldValue(record, DW2PHSSMappingConstants.strARCBESTPhoneNumber_ColumnName)
								: getFieldValue(record, DW2PHSSMappingConstants.strPhoneNumber_ColumnName);
			
			constituentSearchResult.Address =   getFieldValue(record, DW2PHSSMappingConstants.strARCBESTFullAddress_ColumnName) != ''
								? getFieldValue(record, DW2PHSSMappingConstants.strARCBESTFullAddress_ColumnName)
								: getFieldValue(record, DW2PHSSMappingConstants.strFullAddress_ColumnName);
			
			constituentSearchResult.AddressLine1 =  getFieldValue(record, DW2PHSSMappingConstants.strARCBESTAddressLine1_ColumnName) != ''
								? getFieldValue(record, DW2PHSSMappingConstants.strARCBESTAddressLine1_ColumnName)
								: getFieldValue(record, DW2PHSSMappingConstants.strAddressLine1_ColumnName);
			            
			constituentSearchResult.AddressLine2 =  getFieldValue(record, DW2PHSSMappingConstants.strARCBESTAddressLine2_ColumnName) != ''
								? getFieldValue(record, DW2PHSSMappingConstants.strARCBESTAddressLine2_ColumnName)
								: getFieldValue(record, DW2PHSSMappingConstants.strAddressLine2_ColumnName);
			 
            constituentSearchResult.City =  getFieldValue(record, DW2PHSSMappingConstants.strARCBESTCity_ColumnName) != ''
								? getFieldValue(record, DW2PHSSMappingConstants.strARCBESTCity_ColumnName)
								: getFieldValue(record, DW2PHSSMappingConstants.strCity_ColumnName);
            
            constituentSearchResult.State = getFieldValue(record, DW2PHSSMappingConstants.strARCBESTState_ColumnName) != ''
								? getFieldValue(record, DW2PHSSMappingConstants.strARCBESTState_ColumnName)
								: getFieldValue(record, DW2PHSSMappingConstants.strState_ColumnName);

			constituentSearchResult.Zip =   getFieldValue(record, DW2PHSSMappingConstants.strARCBESTZip_ColumnName) != ''
								? getFieldValue(record, DW2PHSSMappingConstants.strARCBESTZip_ColumnName)
								: getFieldValue(record, DW2PHSSMappingConstants.strZip_ColumnName);
            
            constituentSearchResult.EmailAddress =  getFieldValue(record, DW2PHSSMappingConstants.strARCBESTEmailAddress_ColumnName) != ''
                                ? getFieldValue(record, DW2PHSSMappingConstants.strARCBESTEmailAddress_ColumnName)
                                : getFieldValue(record, DW2PHSSMappingConstants.strEmailAddress_ColumnName);            
            
            
            // changed by MM
            //constituentSearchResult.InstructorFlag = getFieldValue(record, DW2PHSSMappingConstants.strInstrctrFlg_ColumnName) == '1' ? 'Yes' : 'No';
            constituentSearchResult.InstructorFlag = getFieldValue(record, DW2PHSSMappingConstants.strInstrctrFlg_ColumnName) == 'Y' ? 'Yes' : 'No';
            
            // changed by MM
            //constituentSearchResult.ManagedLearningContactFlag = getFieldValue(record, DW2PHSSMappingConstants.strMngdLrngFlg_ColumnName) == '1' ? 'Yes' : 'No';
            constituentSearchResult.ManagedLearningContactFlag = getFieldValue(record, DW2PHSSMappingConstants.strMngdLrngFlg_ColumnName) == 'Y' ? 'Yes' : 'No';
            
            constituentSearchResult.ConstituentId = getFieldValue(record, DW2PHSSMappingConstants.strMasterConstituentId_ColumnName);
           
            // added by MM
            constituentSearchResult.SFContactId = getFieldValue(record, DW2PHSSMappingConstants.strSFId_ColumnName);
             
            
            listConstituentSearchResults.add(constituentSearchResult);
        }
        
        // return the results
        return listConstituentSearchResults;
    }
    
    private PHSSModel.ConstituentDetail getConstituentDetails(redcrossBiztalkIntegrationT2sfdc.RecordType[] listRecords){
        // list of search results to be returned
        PHSSModel.ConstituentDetail constituentDetail = new PHSSModel.ConstituentDetail();
        
        // get the first record returned by the service
        redcrossBiztalkIntegrationT2sfdc.RecordType record = listRecords.get(0);
        // update the constituent detail instance
        constituentDetail.FirstName = getFieldValue(record, DW2PHSSMappingConstants.strContactFirstName_ColumnName);
        constituentDetail.LastName = getFieldValue(record, DW2PHSSMappingConstants.strContactLastName_ColumnName);
        constituentDetail.Title = getFieldValue(record, DW2PHSSMappingConstants.strContactTitle_ColumnName);
        constituentDetail.Suffix = getFieldValue(record, DW2PHSSMappingConstants.strContactNameSuffix_ColumnName);
        constituentDetail.ARCBestPhone = getFieldValue(record, DW2PHSSMappingConstants.strARCBESTPhoneNumber_ColumnName);
        constituentDetail.ARCBestAddressLine1 = getFieldValue(record, DW2PHSSMappingConstants.strARCBESTAddressLine1_ColumnName);
        constituentDetail.ARCBestAddressLine2 = getFieldValue(record, DW2PHSSMappingConstants.strARCBESTAddressLine2_ColumnName);
        constituentDetail.ARCBestCity = getFieldValue(record, DW2PHSSMappingConstants.strARCBESTCity_ColumnName);
        constituentDetail.ARCBestState = getFieldValue(record, DW2PHSSMappingConstants.strARCBESTState_ColumnName);
        constituentDetail.ARCBestZip = getFieldValue(record, DW2PHSSMappingConstants.strARCBESTZip_ColumnName);
        constituentDetail.ARCBestEmailAddress = getFieldValue(record, DW2PHSSMappingConstants.strARCBESTEmailAddress_ColumnName);
        constituentDetail.SabaPersonId = getFieldValue(record, DW2PHSSMappingConstants.strSabaPersonId_ColumnName);
        
        // changed by MM
        //constituentDetail.InstructorFlag = getFieldValue(record, DW2PHSSMappingConstants.strInstrctrFlg_ColumnName) == '1' ? 'Yes' : 'No';
        constituentDetail.InstructorFlag = getFieldValue(record, DW2PHSSMappingConstants.strInstrctrFlg_ColumnName) == 'Y' ? 'Yes' : 'No';
        
        
        // changed by MM
        //constituentDetail.ManagedLearningContactFlag = getFieldValue(record, DW2PHSSMappingConstants.strMngdLrngFlg_ColumnName) == '1' ? 'Yes' : 'No';
        constituentDetail.ManagedLearningContactFlag = getFieldValue(record, DW2PHSSMappingConstants.strMngdLrngFlg_ColumnName) == 'Y' ? 'Yes' : 'No';
        
        
        constituentDetail.ConstituentId = getFieldValue(record, DW2PHSSMappingConstants.strMasterConstituentId_ColumnName);
        
        // added by MM
        constituentDetail.SFContactId = getFieldValue(record, DW2PHSSMappingConstants.strSFId_ColumnName);
           
        // return the detail
        return constituentDetail;
    }
    
    private redcrossBiztalkIntegrationT2sfdc.RedCross_BizTalk_Integration_T2SFDC_Orc_TSFDC_FRQ_prt_FRF_GenericSoap createServiceStub(){
        // create an instance of the service and invoke the search
        redcrossBiztalkIntegrationT2sfdc.RedCross_BizTalk_Integration_T2SFDC_Orc_TSFDC_FRQ_prt_FRF_GenericSoap stub = new redcrossBiztalkIntegrationT2sfdc.RedCross_BizTalk_Integration_T2SFDC_Orc_TSFDC_FRQ_prt_FRF_GenericSoap();             
        stub.timeout_x = 60000 ;  
        // uncomment once certificate is setup
        
       //stub.clientCertName_x = 'BizTalk_Constituent_Search';
       stub.clientCertName_x = 'BizTalk_Constituent_Search_Prod';
        
        return stub;
    }
    
    // method to retrieve the field value from input record type corresponding to a field name
    private String getFieldValue(redcrossBiztalkIntegrationT2sfdc.RecordType record, String strfieldName){
        String strFieldValue = '';
        for(redcrossBiztalkIntegrationT2sfdc.FieldType field: record.Fields.FieldType){
            if(field.Name == strFieldName){
                strFieldValue = field.Value;
            }
        }
        return strFieldValue;
    }

}