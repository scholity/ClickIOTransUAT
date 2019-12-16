global class AssignVouchersToBulkStudentBatch implements Database.Batchable<sObject>, Database.Stateful
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        string query = 'SELECT Id, ILT_Class_Id__c, Learning__c, Status__c, Student_First_Name__c,Student_Last_Name__c,Student_Phone_Number__c FROM Student_Bulk_Upload__c WHERE Status__c != \'No ILT Class Found\' AND Voucher__c = null AND Is_Processed__c = false';

        //Student_Bulk_Upload__c sbu = [SELECT Id, ILT_Class__c, Status__c, Student_First_Name__c,Student_Last_Name__c,Student_Phone_Number__c FROM Student_Bulk_Upload__c WHERE Status__c != 'Success'];
        
        return Database.getQueryLocator(query);

    }

    global void execute(Database.BatchableContext BC, List<Student_Bulk_Upload__c> scope)
    {
        system.debug('scope***'+scope);
        List<Student_Bulk_Upload__c> studentsToUpdate = new List<Student_Bulk_Upload__c> ();

        for(Student_Bulk_Upload__c s : scope)
        {
            
            if(s.ILT_Class_Id__c != null)
            {
                system.debug('Inside ILT');
                s.Voucher__c = AssignVouchersToBulkStudentBatch.getVoucher(s.ILT_Class_Id__c);
                studentsToUpdate.add(s);
            }

            if(s.Learning__c != null)
            {
                system.debug('Inside Learning');
                s.Voucher__c = AssignVouchersToBulkStudentBatch.getVoucherForOnlineClass(s.Learning__c);
                studentsToUpdate.add(s);
            }
        }

        if(studentsToUpdate.size() > 0)
        {
            update studentsToUpdate;
        }

    }

    global void finish(Database.BatchableContext BC)
    {

    }

    public static Id getVoucher (Id ILTClassId)
    {
        if(ILTClassId != null)
        {
            Id  voucherId = [SELECT Id, Name, Status__c FROM Voucher__c WHERE Status__c = 'Issued' AND ILT_Class__r.Id =: ILTClassId AND Is_Assigned__c = false LIMIT 1].Id;

            if(voucherId != null)
            {
                Voucher__c v = new Voucher__c();
                v.Id             = voucherId;
                v.Is_Assigned__c = true;
                v.Status__c		 = 'Reserved';

                update v;

                return voucherId;
            }
            else
            {
                return null;
            }
        }
        else
        {
            return null;
        }
    }

    public static Id getVoucherForOnlineClass (Id learningId)
    {
        system.Debug('learningId***'+learningId);
        
        if(learningId != null)
        {
            Id  voucherId = [SELECT Id, Name, Status__c, ILT_Class__r.Id FROM Voucher__c WHERE Status__c = 'Issued' AND Online_Class__c =: learningId AND Is_Assigned__c = false LIMIT 1].Id;
            
            system.debug('voucherId***'+voucherId);

            if(voucherId != null)
            {
                Voucher__c v = new Voucher__c();
                v.Id             = voucherId;
                v.Is_Assigned__c = true;
                v.Status__c		 = 'Reserved';

                update v;

                return voucherId;
            }
            else
            {
                return null;
            }
        }
        else
        {
            return null;
        }
    }

}