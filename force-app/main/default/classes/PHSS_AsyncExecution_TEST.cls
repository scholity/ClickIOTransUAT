@isTest
private class PHSS_AsyncExecution_TEST {
	@isTest static void countMemberships_test() {
		PHSS_AsyncExecution job = new PHSS_AsyncExecution();
		job.groupMemberships = new Map<Id, Set<Id>>();
		Integer results = job.countMemberships();
		System.assertEquals(0, results);
	}

	@isTest static void countUsers_test() {
		PHSS_AsyncExecution job = new PHSS_AsyncExecution();
		job.usersToDeactivate = new Set<Id>();
		job.usersToUpdateUsername = new Map<Id, String>();
		Integer results = job.countUsers();
		System.assertEquals(0, results);
	}

	@isTest static void chunckDeactivationUsers_test() {
		PHSS_AsyncExecution job = new PHSS_AsyncExecution();
		Account acc = new Account(Name = 'test');
		insert acc;
		job.usersToDeactivate = new Set<Id>{acc.Id};
		job.usersToUpdateUsername = new Map<Id, String>();
		job.chunckDeactivationUsers();
	}

	@isTest static void chunckUsersToUpdate_test() {
		PHSS_AsyncExecution job = new PHSS_AsyncExecution();
		Account acc = new Account(Name = 'test');
		insert acc;
		job.usersToDeactivate = new Set<Id>{acc.Id};
		job.usersToUpdateUsername = new Map<Id, String>{acc.Id => 'test'};
		job.chunckUsersToUpdate(new Set<Id>{acc.Id});
	}

	@isTest static void chunckMemberships_test() {
		PHSS_AsyncExecution job = new PHSS_AsyncExecution();
		Account acc = new Account(Name = 'test');
		insert acc;
		job.groupMemberships = new Map<Id, Set<Id>>{acc.Id => new Set<Id>{acc.Id}};
		job.chunckMemberships();
	}

	@isTest static void processGroupMembershipsToRemove_test(){
		PHSS_AsyncExecution job = new PHSS_AsyncExecution();
		job.exGroupMemberIds = new List<Id>();
		job.processGroupMembershipsToRemove();
	}
}