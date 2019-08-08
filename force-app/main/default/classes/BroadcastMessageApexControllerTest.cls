@isTest
public class BroadcastMessageApexControllerTest {

    @testSetup static void setup() {
        insert new List<Broadcast_Message__c> {
            createMessage(1, true),
            createMessage(2, true),
            createMessage(3, false)
        };
    }

    @isTest static void getBroadcastMessages_test() {
        Test.startTest();
        List<Broadcast_Message__c> messages = BroadcastMessageApexController.getBroadcastMessages();
        Test.stopTest();
        System.assertEquals(2, messages.size());
    }

    private static Broadcast_Message__c createMessage(Integer sequence, Boolean active) {
        Broadcast_Message__c message = new Broadcast_Message__c();
        message.Sequence__c = sequence;
        message.Message__c = 'test';
        message.Active__c = active;
        return message;
    }   
}