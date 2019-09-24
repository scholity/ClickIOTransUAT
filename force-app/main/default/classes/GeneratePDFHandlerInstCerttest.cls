@isTest
public class GeneratePDFHandlerInstCerttest
{
    @isTest
    static void  GeneratePDFHandlerInstCerttest()
    {
        GeneratePDFHandlerInstCert classRef = new GeneratePDFHandlerInstCert();
        
        //Cover Wrapper class
        GeneratePDFHandlerInstCert.InstructorWrapper wrapperRef = new GeneratePDFHandlerInstCert.InstructorWrapper();
        wrapperRef.Key = null;
        wrapperRef.Valuess = null;
        wrapperRef.expDate = null;
        wrapperRef.Email = null;
        wrapperRef.Phonenumber = null;
        wrapperRef.Expireflag = null;
        wrapperRef.ExistUser = false;
        wrapperRef.ExistAccount = false;
        wrapperRef.OrganizationName = null;
        wrapperRef.QRCode = null;
        
        String xlsReturn = classRef.xlsHeader;
        
        //For XLS
        classRef.PDFData = '[{"Email":"jhunter@hunter123.com","ExistAccount":true,"ExistUser":true,"expDate":"06/17/2021","Expireflag":false,"Key":"Jane Hunter","OrganizationName":"Army North East","Phonenumber":"555-123-1222","Valuess":"Adult and Pediatric First Aid/CPR/AED"},{"Email":"jhunter@hunter123.com","ExistAccount":false,"ExistUser":false,"expDate":"10/30/2022","Expireflag":false,"Key":"Jane Hunter","OrganizationName":"Army North East","Phonenumber":"555-123-1222","Valuess":"Lifeguarding/First Aid/CPR/AED"}]';
        classRef.downloadPDF();
        
        //For PDF
        classRef.Downloadtype = 'PDF';
        classRef.downloadPDF();
    }
}