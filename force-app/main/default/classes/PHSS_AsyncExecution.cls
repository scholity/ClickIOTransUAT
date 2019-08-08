public class PHSS_AsyncExecution implements Queueable {
	public List<Id> exGroupMemberIds;

	public Map<Id, Set<Id>> groupMemberships;

	public Set<Id> usersToDeactivate;
	public Map<Id, String> usersToUpdateUsername;

	public void execute(QueueableContext context) {

		if (exGroupMemberIds != null && !exGroupMemberIds.isEmpty()) {
			this.processGroupMembershipsToRemove();
		} else if (groupMemberships != null && !groupMemberships.isEmpty()) {
			this.processGroupMembershipsToCreate();
		} else if ((usersToDeactivate != null && !usersToDeactivate.isEmpty()) || (usersToUpdateUsername != null && !usersToUpdateUsername.isEmpty())) {
			this.processUsersUpdate();
		}
	}

	@TestVisible private Integer countMemberships(){
		List<Id> allMemberships = new List<Id>();
		for(Set<Id> value: this.groupMemberships.values()){
			allMemberships.addAll(value);
		}
		return allMemberships.size();
	}

	@TestVisible private Map<Id, Set<Id>> chunckMemberships(){
		Map<Id, Set<Id>> chunck = new Map<Id, Set<Id>>();
		Integer totalChunkSize = 0;
		for(Id key: this.groupMemberships.keySet()){
			Integer currentSize = totalChunkSize + this.groupMemberships.get(key).size();
			if(currentSize < Limits.getLimitDMLRows()){
				chunck.put(key, this.groupMemberships.remove(key));
				totalChunkSize = currentSize;
			} else {
				break;
			}
		}
		return chunck;
	}

	@TestVisible private Integer countUsers(){
		Set<Id> helpCollection = new Set<Id>();
    	helpCollection.addAll(this.usersToDeactivate);
    	helpCollection.addAll(this.usersToUpdateUsername.keySet());
    	return helpCollection.size();
	}

	@TestVisible private Set<Id> chunckDeactivationUsers(){
		Set<Id> chunck = new Set<Id>();
		for(Id value: this.usersToDeactivate){
			if(chunck.size() < Limits.getLimitDMLRows()){
				chunck.add(value);
			} else {
				break;
			}
		}
		this.usersToDeactivate.removeAll(chunck);
		return chunck;
	}

	@TestVisible private Map<Id, String> chunckUsersToUpdate(Set<Id> usersToDeactivate){
		Map<Id, String> chunck = new Map<Id, String>();
		Integer totalSize = usersToDeactivate.size();
		for(Id key: this.usersToUpdateUsername.keySet()){
			if(totalSize < Limits.getLimitDMLRows()){
				chunck.put(key, this.usersToUpdateUsername.remove(key));
				if(!usersToDeactivate.contains(key)){
					totalSize++;
				}
			}
		}
		return chunck;
	}

	@TestVisible private void processUsersUpdate(){
		if(this.countUsers() <= Limits.getLimitDMLRows()){
			PHSS_FutureActions.deactivateUsers(this.usersToDeactivate, this.usersToUpdateUsername);
			this.usersToDeactivate.clear();
			this.usersToUpdateUsername.clear();
		} else {
			Set<Id> userToDeactivateChunck = this.chunckDeactivationUsers();
			PHSS_FutureActions.deactivateUsers(userToDeactivateChunck, this.chunckUsersToUpdate(userToDeactivateChunck));
		}
		this.enqueueNextJob();
	}

	@TestVisible private void processGroupMembershipsToCreate() {
		if (this.countMemberships() <= Limits.getLimitDMLRows()) {
			PHSS_FutureActions.createGroupMembership(this.groupMemberships);
			this.groupMemberships.clear();
		} else {
			PHSS_FutureActions.createGroupMembership(this.chunckMemberships());
		}

		this.enqueueNextJob();
	}

	@TestVisible private void processGroupMembershipsToRemove() {
		if (this.exGroupMemberIds.size() <= Limits.getLimitDMLRows()) {
			PHSS_FutureActions.removeGroupMembership(this.exGroupMemberIds);
			this.exGroupMemberIds.clear();
		} else {
			List<Id> groupsToRemove = new List<Id>();
			while (groupsToRemove.size() < Limits.getLimitDMLRows() && this.exGroupMemberIds.size() != 0) {
				groupsToRemove.add(
				    this.exGroupMemberIds.remove(0)
				);
			}

			PHSS_FutureActions.removeGroupMembership(groupsToRemove);
		}

		this.enqueueNextJob();
	}

	public void enqueueJob(){
		System.enqueueJob(this);
	}

	private void enqueueNextJob() {
		if (Test.isRunningTest()) {
			return;
		}

		PHSS_AsyncExecution job = new PHSS_AsyncExecution();
		job.exGroupMemberIds = this.exGroupMemberIds;
		job.groupMemberships = this.groupMemberships;
		job.usersToDeactivate = this.usersToDeactivate;
		job.usersToUpdateUsername = this.usersToUpdateUsername;
		job.enqueueJob();
	}
}