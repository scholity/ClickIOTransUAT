public class GeneratePDFHandlerInstCert
{
    public String PDFData {get; set;}
    public String Downloadtype {get; set;}
    public String todaysDate {get; set;}
    public List<InstructorWrapper> instructorWrapperContent {get; set;}
    public GeneratePDFHandlerInstCert()
    {
        PDFData = '';
        Downloadtype = '';
        instructorWrapperContent = new List<InstructorWrapper>();
    }
    
    public String xlsHeader
    {
        get
        {
            String strHeader = '';
            strHeader += '<?xml version="1.0"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
    }
    
    public with sharing class InstructorWrapper 
    {
        public string Key {get; set;}
        public String Valuess {get; set;}
        public String expDate {get; set;}
        public String Email {get; set;}
        public String Phonenumber {get; set;}
        public boolean Expireflag {get; set;}
        public boolean ExistUser {get; set;}
        public boolean ExistAccount {get; set;}
        public String OrganizationName {get; set;}
        public String QRCode {get; set;}
    }
    
    public PageReference downloadPDF()
    {
        todaysDate = Datetime.now().format('MM/dd/yyyy');
        if(!String.isBlank(PDFData))
            instructorWrapperContent =  (List<InstructorWrapper>) System.JSON.deserialize(PDFData , List<InstructorWrapper>.class);
        
        if(Downloadtype == 'PDF')
        {
            System.PageReference pageRef = new System.PageReference('/apex/PDFDownloaderInstCert');
            pageRef.getHeaders().put('content-disposition', 'attachment; filename=InstructorCertificates-'+system.today().format()+'-PDF.pdf');
            return pageRef;
        }
        else
        {
            System.PageReference pageRef = new System.PageReference('/apex/XLSDownloaderInstCert');
            return pageRef;
        }
        
    }
}