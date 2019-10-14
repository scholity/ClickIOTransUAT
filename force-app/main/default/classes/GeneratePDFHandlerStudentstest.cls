@isTest
public class GeneratePDFHandlerStudentstest
{
    @isTest
    static void GeneratePDFHandlerStudentstest()
    {
        GeneratePDFHandlerStudents classRef = new GeneratePDFHandlerStudents();
        
        //Cover Wrapper class
        GeneratePDFHandlerStudents.ClassWrapper wrapperRef = new GeneratePDFHandlerStudents.ClassWrapper();
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
        
        wrapperRef.StudentFirstName = null;
        wrapperRef.StudentLastName = null;
        wrapperRef.StudentEmail = null;
        wrapperRef.StudentPhone = null;
        wrapperRef.AchievementName = null;
        wrapperRef.AcquisitionDate = null;
        wrapperRef.Status = null;
        wrapperRef.ILTClass = null;
        wrapperRef.ILTClassStartDate = null;
        wrapperRef.location = null;
        
        GeneratePDFHandlerStudents.locationWrapper locationWrapperRef = new GeneratePDFHandlerStudents.locationWrapper();
        locationWrapperRef.city = null;
        locationWrapperRef.address1 = null;
        locationWrapperRef.country = null;
        locationWrapperRef.province = null;
        locationWrapperRef.postalCode = null;
        
        String xlsReturn = classRef.xlsHeader;
        
        //For XLS
        classRef.PDFData = '[{"Email":"jhunter@hunter123.com","ExistAccount":true,"ExistUser":true,"expDate":"06/17/2021","Expireflag":false,"Key":"Jane Hunter","OrganizationName":"Army North East","Phonenumber":"555-123-1222","Valuess":"Adult and Pediatric First Aid/CPR/AED"},{"Email":"jhunter@hunter123.com","ExistAccount":false,"ExistUser":false,"expDate":"10/30/2022","Expireflag":false,"Key":"Jane Hunter","OrganizationName":"Army North East","Phonenumber":"555-123-1222","Valuess":"Lifeguarding/First Aid/CPR/AED"}]';
        classRef.downloadPDF();
        
        //For PDF
        classRef.Downloadtype = 'PDF';
        classRef.downloadPDF();
    }
}