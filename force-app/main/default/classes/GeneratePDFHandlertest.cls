@isTest
public class GeneratePDFHandlertest
{
    @isTest
    static void  GeneratePDFHandlertest()
    {
        GeneratePDFHandler classRef = new GeneratePDFHandler();
        
        //Cover Wrapper class
        GeneratePDFHandler.locationWrapper locWrapperRef = new GeneratePDFHandler.locationWrapper();
        locWrapperRef.city = null;
        locWrapperRef.address1 = null;
        locWrapperRef.country = null;
        locWrapperRef.province = null;
        locWrapperRef.postalCode = null;
        
        GeneratePDFHandler.ClassWrapper wrapperRef = new GeneratePDFHandler.ClassWrapper();
        wrapperRef.classId = null;
        wrapperRef.className = null;
        wrapperRef.classOfferingId = null;
        wrapperRef.lpName = null;
        wrapperRef.lplanId = null;
        wrapperRef.startDate = null;
        wrapperRef.endDate = null;
        wrapperRef.startTime = null;
        wrapperRef.endTime = null;
        wrapperRef.days = null;
        wrapperRef.instructorName = null;
        wrapperRef.company = null;
        wrapperRef.location = locWrapperRef;
        wrapperRef.classSettings = null;
        wrapperRef.status = null;
        wrapperRef.numberOfStudents = null;
        
        String xlsReturn = classRef.xlsHeader;
        
        //For XLS
        classRef.PDFData = '[{"classId":"a315B000000t3yPQAQ","className":"Lifeguarding","classOfferingId":"00001596","classSettings":"Classroom","company":"Army West","days":6,"endDate":"2019-11-08","endTime":"01:00 PM","instructorName":"Jane Hunter","location":{"address1":"","city":"","country":"","postalCode":"","province":""},"lplanId":"a3r5B000000AfWdQAK","lpName":"Lifeguarding","numberOfStudents":2,"startDate":"2019-11-03","startTime":"12:00 PM","status":"Upcoming"},{"classId":"a315B000000xE1LQAU","className":"Lifeguarding1","classOfferingId":"CLS-00002300","classSettings":"Classroom","company":"Army West","days":6,"endDate":"2019-11-08","endTime":"01:00 PM","instructorName":"Jane Hunter","location":{"address1":"","city":"","country":"","postalCode":"","province":""},"lplanId":"a3r5B00000068AsQAI","lpName":"Adult and Child CPR","numberOfStudents":1,"startDate":"2019-11-03","startTime":"12:00 PM","status":"Upcoming"}]';
        classRef.downloadPDF();
        
        //For PDF Current
        classRef.Downloadtype = 'PDF';
        classRef.Classtype = 'Current';
        classRef.downloadPDF();
        
        //For PDF History
        classRef.Classtype = 'History';
        classRef.downloadPDF();
    }
}