public class PHSS_GeneratePDFController {
    public String PDFData {get; set;} 
    public List<jsonValues> jsonRows{get;set;}
    
    public class jsonValues{
                public String Id{get;set;}
                public String ClassId{get;set;}
        		public String ClassInstructor{get;set;}         
        		public String ClassDate{get;set;}
        		public String ClassTime{get;set;}
        		public String ClassName{get;set;}    
                public String Firstname{get;set;}
                public String Lastname{get;set;}
                public String Email{get;set;}
                public String Evaluation_Result{get;set;}
                public String Grade_Reason{get;set;}
                public String Grade_Additional_Info{get;set;} 
    }    
    
    public PHSS_GeneratePDFController(){
        PDFData = '';
        jsonRows = new List<jsonValues>();
    }
    
    public PageReference downloadPDF(){
        jsonRows = (List<jsonValues>) System.JSON.deserialize(PDFData , List<jsonValues>.class);    
        
        System.PageReference pageRef = new System.PageReference('/apex/PHSS_RenderPDF');
        pageRef.getHeaders().put('content-disposition', 'attachment; filename=PHSSDownloadPDF.pdf');
     
        return pageRef;
    }
}