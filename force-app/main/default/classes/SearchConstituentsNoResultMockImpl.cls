@isTest
global class SearchConstituentsNoResultMockImpl implements WebServiceMock {
	
	global void doInvoke(
               Object stub,
               Object request,
               Map<String, Object> response,
               String endpoint,
               String soapAction,
               String requestName,
               String responseNS,
               String responseName,
               String responseType) {
             
             
		redcrossBiztalkIntegrationT2sfdc.SearchConstituentsResponse_element responseElement = new redcrossBiztalkIntegrationT2sfdc.SearchConstituentsResponse_element();
        responseElement.part = new redcrossBiztalkIntegrationT2sfdc.QueryResponse();
           
        responseElement.part.Success = true;
        responseElement.part.Count = 0;
        
        redcrossBiztalkIntegrationT2sfdc.ArrayOfRecordType recordsArray = new redcrossBiztalkIntegrationT2sfdc.ArrayOfRecordType();
        
        responseElement.part.Record = recordsArray;
        
        response.put('response_x', responseElement);
            
             
	}
        
   
}