public class GeneratePDFHandlerCPS
{
    public String PDFData {get; set;}
    public String Downloadtype {get; set;}
    public String todaysDate {get; set;}
    public List<ClassWrapper> classWrapperContent {get; set;}
    public GeneratePDFHandlerCPS()
    {
        PDFData = '';
        Downloadtype = '';
        classWrapperContent = new List<ClassWrapper>();
    }
    
    public with sharing class ClassWrapper 
    {
        public String facilityName {get; set;}
        public String courseId {get; set;}
        public String courseName {get; set;}
        public String classId {get; set;}
        public String accountName {get; set;}
        public String orderNumber {get; set;}
        public String classOfferingId {get; set;}
        public String className {get; set;}
        public Date startDate {get; set;}
        public Date endDate {get; set;}
        public String startTime {get; set;}
        public String endTime  {get; set;}
        public locationWrapper location {get; set;}
        public String CPSRegistrationURL {get; set;}
        public String CPSRegistrationPhone {get; set;}
        public Decimal registrationFee {get; set;}
        public Date classOnlineFrom {get; set;}
        public Date classOnlineTo {get; set;}
        public String createdByName {get; set;}
        public DateTime createdDateandTime {get; set;}
        public String requestType {get; set;}
    }
    
    public with sharing class locationWrapper {
        public String city {get; set;}
        public String address1 {get; set;}
        public String country {get; set;}
        public String province {get; set;}
        public String postalCode {get; set;}
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
    
    public PageReference downloadPDF()
    {
        todaysDate = Datetime.now().format('MM/dd/yyyy');
        if(!String.isBlank(PDFData))
            classWrapperContent =  (List<ClassWrapper>) System.JSON.deserialize(PDFData , List<ClassWrapper>.class);
        if(Downloadtype == 'PDF')
        {
            System.PageReference pageRef = new System.PageReference('/apex/PDFDownloaderCPS');
            pageRef.getHeaders().put('content-disposition', 'attachment; filename=CPS CLasses-'+System.today().format()+'-PDF.pdf');
            return pageRef;
        }
        else
        {
            System.PageReference pageRef = new System.PageReference('/apex/XLSDownloaderCPS');
            return pageRef;
        }
    }
}