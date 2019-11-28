public without sharing class ConvertLearnerToInstructorController
{
    
    private final AccountContactRelation  acr;
    
    public ConvertLearnerToInstructorController()
    {
        acr = [SELECT Id,
               		  ContactId,
                      Roles
                 FROM AccountContactRelation
                WHERE Id =: ApexPages.currentPage().getParameters().get('id')
                LIMIT 1];
    }

    public PageReference redirect()
    {
        if(acr != null)
        {
            User u = [SELECT Id,
                      		 ContactID,
							 FirstName,
                      		 LastName,
                      		 ProfileId
                        FROM User
                       WHERE ContactId =: acr.ContactId
                       LIMIT 1];
            
            Id ProfileId 	 	  = [SELECT Id FROM Profile WHERE Name = 'SB PHSS-IC-Community Plus Login'].Id;
            String remoteURL 	  = System.Label.ProfileUpdateURL + '/services/apexrest/ProfileUpdate?_HttpMethod=PATCH';
            String userId 		  = u.Id;
            String commProfileId  = ProfileId;
            
            HTTPRequest httpRequest = new HTTPRequest();
            httpRequest.setMethod('POST');
            httpRequest.setHeader('Authorization', 'OAuth '+UserInfo.getSessionId());
            httpRequest.setHeader('Content-Type', 'application/json');
            httpRequest.setBody('{"userId":"'+userId+'","profileId":"'+commProfileId+'"}');
            httpRequest.setEndpoint(remoteURL);
            
            HTTPResponse res = new Http().send(httpRequest);
            while (res.getStatusCode() == 302)
            {
                httpRequest.setEndpoint(res.getHeader('Location'));
                res = new Http().send(httpRequest);
            }
            System.debug('BODY: '+res.getBody());
            System.debug('STATUS:'+res.getStatus());
            System.debug('STATUS_CODE:'+res.getStatusCode());
        }
        
        PageReference redirectSuccess = new PageReference('/lightning/r/AccountContactRelation/'+acr.Id+'/view');
        redirectSuccess.setRedirect(true);
        return redirectSuccess;
    }
}