public with sharing class PHSS_CaseCommentsController {
	public class CaseCommentWrapper {
		@AuraEnabled public Id commentId;
		@AuraEnabled public Id ownerId;
		@AuraEnabled public String ownerNick;
		@AuraEnabled public String commentBody;
		@AuraEnabled public String createdDate;
		@AuraEnabled public Boolean isOwner;

		public CaseCommentWrapper(Id commentId, Id ownerId, String ownerNick, String commentBody, Datetime createdDate, Boolean isOwner){
			this.commentId = commentId;
			this.ownerId = ownerId;
			this.ownerNick = ownerNick;
			this.commentBody = commentBody;
			this.createdDate = createdDate.format();
			this.isOwner = isOwner;
		}
	}

	@AuraEnabled
	public static List<CaseCommentWrapper> getCaseComments(Id caseId, Integer numberOfElements){
		Integer castedNumberOfElements = Integer.valueOf(numberOfElements);
		List<CaseComment> caseComments = [SELECT Id, CreatedDate, CreatedById, CommentBody FROM CaseComment WHERE ParentId = :caseId AND IsPublished = true ORDER BY CreatedDate DESC LIMIT :castedNumberOfElements];
		return processCaseComments(caseComments);
	}

	private static List<CaseCommentWrapper> processCaseComments(List<CaseComment> caseComments){
		Set<Id> ownerIds = new Set<Id>();
		for(CaseComment comment: caseComments){
			ownerIds.add(comment.CreatedById);
		}
		Id currentUserId = UserInfo.getUserId();
		Map<Id, User> owners = new Map<Id, User>([SELECT Id, CommunityNickname FROM User WHERE Id IN :ownerIds]);
		List<CaseCommentWrapper> caseCommentWrappers = new List<CaseCommentWrapper>();
		for(CaseComment comment: caseComments){
			caseCommentWrappers.add(
				new CaseCommentWrapper(
					comment.Id,
					comment.CreatedById,
					owners.get(comment.CreatedById).CommunityNickname,
					comment.CommentBody,
					comment.CreatedDate,
					currentUserId == comment.CreatedById
				)
			);
		}
		return caseCommentWrappers;
	}

	@AuraEnabled
	public static List<CaseCommentWrapper> getAllCaseComments(Id caseId){
		List<CaseComment> caseComments = [SELECT Id, CreatedDate, CreatedById, CommentBody FROM CaseComment WHERE ParentId = :caseId AND IsPublished = true  ORDER BY CreatedDate DESC];
		return processCaseComments(caseComments);
	}

	@AuraEnabled
	public static Boolean deleteComment(Id commentId){
		List<CaseComment> caseComments = [SELECT Id FROM CaseComment WHERE Id = :commentId];
		Savepoint sp = Database.setSavepoint();
		try{
			delete caseComments;
			return true;
		} catch(DmlException e){
			Database.rollback(sp);
			System.debug(LoggingLevel.ERROR, e.getMessage());
			System.debug(LoggingLevel.ERROR, e.getStackTraceString());
			return false;
		}
	}

	@AuraEnabled
	public static Boolean updateComment(Id commentId, String newCommentBody){
		List<CaseComment> caseComments = [SELECT Id FROM CaseComment WHERE Id = :commentId];
		for(CaseComment comment: caseComments){
			comment.CommentBody = newCommentBody;
		}
		Savepoint sp = Database.setSavepoint();
		try{
			update caseComments;
			return true;
		} catch(DmlException e){
			Database.rollback(sp);
			System.debug(LoggingLevel.ERROR, e.getMessage());
			System.debug(LoggingLevel.ERROR, e.getStackTraceString());
			return false;
		}
	}

	@AuraEnabled
	public static Boolean createComment(String commentBody, Id caseId){
		CaseComment comment = new CaseComment();
		comment.CommentBody = commentBody;
		comment.ParentId = caseId;
		comment.IsPublished = true;
		Savepoint sp = Database.setSavepoint();
		try{
			insert comment;
			return true;
		} catch(DmlException e){
			Database.rollback(sp);
			System.debug(LoggingLevel.ERROR, e.getMessage());
			System.debug(LoggingLevel.ERROR, e.getStackTraceString());
			return false;
		}
	}
}