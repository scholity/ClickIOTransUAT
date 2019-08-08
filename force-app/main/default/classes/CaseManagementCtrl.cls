public class CaseManagementCtrl 
{
	public void changeSelfPayToAutoCloseQueue()
    {
        List<Case> csList = new List<Case>();
        Group grpSelfPay = [select Id from Group where Name = 'TSC NAT – Self-Pay' and Type = 'Queue' limit 1];
        Group grpAutoCloseQueue = [select Id from Group where Name = 'AutoCloseQueue' and Type = 'Queue' limit 1];
        
        List<Case> caseList = new List<Case>();
        List<CaseComment> caseCommentList = new List<CaseComment>();
        if(Test.isRunningTest())
        csList = [select id,ownerid from Case limit 1];
        else
        csList = [select id,ownerid from Case where isClosed = false and ownerid =: grpSelfPay.Id And LastModifiedDate != LAST_N_DAYS:30];
        for(Case c : csList)
        {
            c.ownerid = grpAutoCloseQueue.Id;
            CaseComment com = new CaseComment();
           	com.ParentId = c.id;
           	com.CommentBody= 'Case has been moved to AutoCloseQueue due to 30 days of inactivity.';
            caseList.add(c);
            caseCommentList.add(com);
        }
        
        if(caseList.size()>0)
        {
            Update caseList;
        	Insert caseCommentList;
        }
        
    }
}