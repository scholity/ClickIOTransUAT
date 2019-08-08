@isTest
private class PHSS_Utility_TEST {
    private static final Integer SIZE = 10;


    @isTest static void getRandomString_test() {
        Test.startTest();
        String first = PHSS_Utility.getRandomString(SIZE);
        String second = PHSS_Utility.getRandomString(SIZE);
        Test.stopTest();
        System.assertEquals(first.length(), second.length(), 'String should have the same length');
        System.assertEquals(SIZE, first.length());
        System.assertEquals(SIZE, second.length());
        System.assertNotEquals(first, second);
    }

    @isTest static void getRandomEmail_test() {
        Test.startTest();
        String first = PHSS_Utility.getRandomEmail();
        String second = PHSS_Utility.getRandomEmail();
        Test.stopTest();
        System.assertNotEquals(first, second);
    }

    @isTest static void getRandomUrl_test() {
        Test.startTest();
        String first = PHSS_Utility.getRandomUrl();
        String second = PHSS_Utility.getRandomUrl();
        Test.stopTest();
        System.assertNotEquals(first, second);
    }

    @isTest static void tagsCsvToCollection_test() {
        List<String> elements = new List<String>();
        for(Integer i=0; i<SIZE; i++) {
            elements.add(PHSS_Utility.getRandomString(SIZE));
        }
        String tagCsv = String.join(elements, ',');
        Test.startTest();
        Set<String> results = PHSS_Utility.tagsCsvToCollection(tagCsv);
        System.assert(PHSS_Utility.matchTags(results, new Set<String>(elements)));
        System.assert(!PHSS_Utility.matchTags(results, new Set<String>{PHSS_Utility.getRandomString(SIZE)}));
        Test.stopTest();
        System.assertNotEquals(0, results.size());
    }

    @isTest static void matchTag_test() {
        List<String> elements = new List<String>();
        for(Integer i=0; i<SIZE; i++) {
            elements.add(PHSS_Utility.getRandomString(SIZE));
        }
        String tagToMatch = PHSS_Utility.getRandomString(SIZE);
        elements.add(tagToMatch);
        String tagCsv = String.join(elements, ',');
        Set<String> results = PHSS_Utility.tagsCsvToCollection(tagCsv);
        Test.startTest();
        System.assert(PHSS_Utility.matchTag(results, tagToMatch));
        Test.stopTest();
        System.assertNotEquals(0, results.size());
    }

    @isTest static void checkMaterialAccess_test() {
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        for(Integer i = 0; i <= SIZE; i++) {
            contentVersions.add(PHSS_TestUtility.createContent('test', i));
        }
        contentVersions.add(PHSS_TestUtility.createContent('test', SIZE));
        insert contentVersions;
        update contentVersions;
        List<PHSS_Material__c> data = [SELECT Id, Sequence__c, ContentVersionID__c FROM PHSS_Material__c];
        Test.startTest();
        List<PHSS_Material__c> results = PHSS_Utility.checkMaterialAccess(data);
        Test.stopTest();
        System.assertEquals(data.size(), results.size());
    }
}