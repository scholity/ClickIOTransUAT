public class GeneratePDFHandler 
{
    public String PDFData {get; set;}
    public String Downloadtype {get; set;}
    public String Classtype {get; set;}
    public String todaysDate {get; set;}
    public List<ClassWrapper> classWrapperContent {get; set;}
    public GeneratePDFHandler()
    {
        PDFData = '';
        Downloadtype = '';
        Classtype = '';
        classWrapperContent = new List<ClassWrapper>();
    }
    
    public with sharing class ClassWrapper 
    {
        public String classId {get; set;}
        public String className {get; set;}
        public String classOfferingId {get; set;}
        public String lpName {get; set;}
        public String lplanId {get; set;}
        public Date startDate {get; set;}
        public Date endDate {get; set;}
        public String startTime {get; set;}
        public String endTime {get; set;}
        public Integer days {get; set;}
        public String instructorName {get; set;}
        public String company {get; set;}
        public locationWrapper location {get; set;}
        public String classSettings {get; set;}
        public String status {get; set;}
        public Integer numberOfStudents {get; set;}
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
            System.PageReference pageRef = new System.PageReference('/apex/PDFDownloader');
            if(Classtype == 'Current')
                pageRef.getHeaders().put('content-disposition', 'attachment; filename=CurrentClasses-'+System.today().format()+'-PDF.pdf');
            else if(Classtype == 'History')
                pageRef.getHeaders().put('content-disposition', 'attachment; filename=HistoryClasses-'+System.today().format()+'-PDF.pdf');
            return pageRef;
        }
        else
        {
            System.PageReference pageRef = new System.PageReference('/apex/XLSDownloader');
            return pageRef;
        }
    }
}