@isTest 
public class OpportunityTriggerHandlerTest {
	
	public static final Integer accountCount            = 1;
    public static final Integer oppsOnEachAccount       = 2;
    
    @testsetup 
    public static void initializeClassTestData()
    {
        CreateTestAccountsAndOpportunities(accountCount, oppsOnEachAccount);
    }

    static testMethod void testOpportunityTriggerHandlerWithNo()
    {
        List<Opportunity> testOpportunities     = [SELECT Id, AccountId FROM Opportunity];
        
        List<Opportunity> OpportunitiesToUpdate = new List<Opportunity>();
        
        for(Opportunity opp : testOpportunities )
        {
            opp.Pricing_Agreement__c    = 'No';
            opp.StageName               = 'Closed Won';
            
            OpportunitiesToUpdate.add(opp);         
        }
        
        Test.startTest();
            update OpportunitiesToUpdate;
        Test.stopTest();
        
        List<Account> accounts = [SELECT Id, Is_Pricing_Agreement__c FROM Account];
        
        for(Account a : accounts)
        {
        	System.assertEquals(a.Is_Pricing_Agreement__c, 'No');
        }
        
                 
    }
    
    static testMethod void testOpportunityTriggerHandlerWithYes()
    {
        List<Opportunity> testOpportunities1 = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        
        List<Opportunity> testOpportunities11 = [SELECT Id, AccountId FROM Opportunity WHERE Id NOT IN :testOpportunities1];
        
        List<Opportunity> OpportunitiesToUpdate1  = new List<Opportunity>();
        List<Opportunity> OpportunitiesToUpdate11 = new List<Opportunity>();
        
        for(Opportunity opp1 : testOpportunities1 )
        {
            opp1.Pricing_Agreement__c   = 'Yes';
            opp1.StageName              = 'Closed Won';
            
            OpportunitiesToUpdate1.add(opp1);           
        }
        
        for(Opportunity opp1 : testOpportunities11 )
        {
            opp1.Pricing_Agreement__c   = 'No';
            opp1.StageName              = 'Closed Won';
            
            OpportunitiesToUpdate11.add(opp1);           
        }
        
        Test.startTest();
            update OpportunitiesToUpdate1;
            update OpportunitiesToUpdate11;
        Test.stopTest();
        
        List<Account> accounts1 = [SELECT Id, Is_Pricing_Agreement__c FROM Account];
        
        for(Account a1 : accounts1)
        {
        	System.assertEquals(a1.Is_Pricing_Agreement__c, 'Yes');
        }
                 
    }
    
    static testMethod void testOpportunityTriggerHandlerWithYesAndLost()
    {
        List<Opportunity> testOpportunities2 = [SELECT Id, AccountId FROM Opportunity];
        
        List<Opportunity> OpportunitiesToUpdate2 = new List<Opportunity>();
        
        for(Opportunity opp2 : testOpportunities2 )
        {
            system.debug('Inside Yes - Lost');
            opp2.Pricing_Agreement__c       = 'Yes';
            opp2.StageName                  = 'Closed Won';
            opp2.Closed_Lost_Reason_New__c  = 'Budget Cycle';
            opp2.Closed_Lost_Details__c     = 'This is a test lost detail';
            
            OpportunitiesToUpdate2.add(opp2);           
        }
        
        update OpportunitiesToUpdate2;
        
        List<Opportunity> OpportunitiesToUpdateFinal = new List<Opportunity>();
        
        for(Opportunity o : OpportunitiesToUpdate2)
        {
        	o.StageName = 'Closed Lost';
        	OpportunitiesToUpdateFinal.add(o);
        }
        
        Test.startTest();
        	update OpportunitiesToUpdateFinal;
        Test.stopTest();
        
        List<Account> accounts2 = [SELECT Id, Is_Pricing_Agreement__c FROM Account];
        
        for(Account a2 : accounts2)
        {
        	System.assertEquals(a2.Is_Pricing_Agreement__c, 'No');
        }
                 
    }
    
    public static void CreateTestAccountsAndOpportunities(Integer accounts, Integer oppsPerAccount)
    {
        Database.DMLOptions dml = new Database.DMLOptions();        
        dml.DuplicateRuleHeader.allowSave = true;
        
        List<account> accountList = new List<Account>();
        
        for(Integer a = 0; a< accounts; a++)
        {
            accountList.add(new Account(Name='Testing Company'+ String.ValueOf(a)));
        }
        
        database.insert(accountList, dml);        
        
        //Insert cutom setting
        List<BGST_Profiles__c> ProfilesList = new List<BGST_Profiles__c>();
        
		BGST_Profiles__c indiv = new BGST_Profiles__c(	name 			= 'Owner Profile',
														Sales_User__c 	= 'ARC BGST Sales User');
		ProfilesList.add(indiv);
		
		insert ProfilesList;    
        
        List<Opportunity> opportunitiesList = new List<Opportunity>();
        
        for(Account act : accountList)
        {
            system.debug('Inside account');
            for(Integer o = 0; o< oppsPerAccount; o++)
            {
                opportunitiesList.add(new Opportunity(  Name                = 'Test'+ String.ValueOf(o),
                                                        AccountId           = act.id,
                                                        Type                = 'New Business - FS',
                                                        CloseDate           = Date.Today(),
                                                        StageName           = 'Approach',
                                                        Approval_Status__c  = 'Approved'));
            }
        }
        
        Database.insert(opportunitiesList, dml);
        
    }    
    
}