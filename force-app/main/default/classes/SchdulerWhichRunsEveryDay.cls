global class SchdulerWhichRunsEveryDay implements Schedulable 
{
   global void execute(SchedulableContext SC) 
   {
      CaseManagementCtrl cmq =  new CaseManagementCtrl();
       cmq.changeSelfPayToAutoCloseQueue();
   }
}