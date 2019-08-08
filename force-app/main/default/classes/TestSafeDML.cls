/*****************************************************************************************************
 
Class    :  TestSafeDML
Developer:  Krishna Kollu, Joo Kang Blue Wolf Group LLC
Created  :  Feb 12, 2014
Modified :  March 14, 2014
Objective:  This class is used to test the class SafeDML
 
*****************************************************************************************************/ 
@isTest
public class TestSafeDML {
	public static List<Group> createGroups(String name, Integer howMany)
	{
		List<Group> groups = new List<Group>();
		for(Integer i = 0; i < howMany; i++)
		{
			groups.add(new Group(Name=name));
		}
		return groups;
	}
	
	public static void setNameOfGroups(List<Group> groups, String name)
	{
		for(Group g : groups)
		{
			g.Name=name;
		}
	}
	
	public class KeepTrackOfFailedItems implements ErrorHandling.ErrorHandler
	{
		public Integer howManyIdsValidated  = 0;
		public Integer howManyIdsForFailedObjects  = 0;
		
		public void validate(SObject record)
		{
			howManyIdsValidated++;
		}
		
		public void processError(SObject failedRecord, String errorMessage)
		{
			howManyIdsForFailedObjects++;
		}
		
		public Boolean areThereErrors()
		{
			return (howManyIdsForFailedObjects>0);
		}
	}
}