public class GeneratePDFHandlerStudents
{
    public String PDFData {get; set;}
    public String Downloadtype {get; set;}
    public String todaysDate {get; set;}
    public String companyName {get; set;}
    public String expStartDate {get; set;}
    public String expEndDate {get; set;}
    public List<ClassWrapper> classWrapperContent {get; set;}
    public GeneratePDFHandlerStudents()
    {
        PDFData = '';
        Downloadtype = '';
        companyName = '';
        expStartDate = '';
        expEndDate = '';
        classWrapperContent = new List<ClassWrapper>();
    }
    
    public with sharing class ClassWrapper 
    {
        public string Key{get; set;}
        public String Valuess{get; set;}
        public String expDate{get; set;}
        public String Email{get; set;}
        public String Phonenumber{get; set;}
        public boolean Expireflag{get; set;}
        public boolean ExistUser{get; set;}
        public boolean ExistAccount{get; set;}
        public String OrganizationName{get; set;}
        public String QRCode{get; set;}
        public String StudentFirstName{get; set;}
        public String StudentLastName{get; set;}
        public String StudentEmail{get; set;}
        public String StudentPhone{get; set;}
        public String AchievementName{get; set;}
        public Date AcquisitionDate{get; set;}
        public String Status{get; set;}
        public String ILTClass{get; set;}
        public Date ILTClassStartDate{get; set;}
        public locationWrapper location{get; set;}
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
            System.PageReference pageRef = new System.PageReference('/apex/PDFDownloaderStudents');
            pageRef.getHeaders().put('content-disposition', 'attachment; filename='+companyName+'-Student History Report-'+expStartDate +' to '+expEndDate+'.pdf');
            return pageRef;
        }
        else
        {
            System.PageReference pageRef = new System.PageReference('/apex/XLSDownloaderStudents');
            return pageRef;
        }
    }
}