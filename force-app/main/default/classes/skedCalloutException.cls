public class skedCalloutException extends Exception {
    
    public integer statusCode {get;set;}
    public string status {get;set;}
    public string response {get;set;}
    
    public skedCalloutException(integer statusCode, string status, string response) {
        this.statusCode = statusCode;
        this.status = status;
        this.response = response;
    }

}