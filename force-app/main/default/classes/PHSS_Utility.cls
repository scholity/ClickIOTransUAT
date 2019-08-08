public with sharing class PHSS_Utility {
    private static final String CHARS = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';

	public static String getRandomString(Integer size) {
        String randStr = '';
        while (randStr.length() < size) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), CHARS.length());
            randStr += CHARS.substring(idx, idx + 1);
        }
        return randStr;
    }

    public static String getRandomEmail() {
    	return getRandomString(10) + '@' + getRandomString(5) + '.' + getRandomString(3);
    }

    public static String getRandomUrl() {
        return getRandomString(10) + '.' + getRandomString(3);
    }

    private class MaterialWrapper implements Comparable {
        private Decimal sequence;
        private PHSS_Material__c material;

        public Decimal getSequence() {
            return this.sequence;
        }

        public PHSS_Material__c getMaterial() {
            return this.material;
        }

        public MaterialWrapper(PHSS_Material__c material) {
            this.material = material;
            this.sequence = material.Sequence__c;
        }

        public Integer compareTo(Object compareTo) {
            MaterialWrapper materialToCompare = (MaterialWrapper) compareTo;
            if (this.sequence == materialToCompare.getSequence()) {
                return 0;
            } else if (this.sequence > materialToCompare.getSequence()) {
                return 1;
            } else {
                return -1;
            }
        }
    }

    public static List<PHSS_Material__c> checkMaterialAccess(List<PHSS_Material__c> materials) {
        List<PHSS_Material__c> filtredMaterials = new List<PHSS_Material__c>();
        Set<Id> contentIds = new Set<Id>();
        Map<Id, PHSS_Material__c> contentToMaterials = new Map<Id, PHSS_Material__c>();
        for(PHSS_Material__c material: materials) {
            contentIds.add(material.ContentVersionID__c);
            contentToMaterials.put(material.ContentVersionID__c, material);
        }
        List<MaterialWrapper> materialWrappers = new List<MaterialWrapper>();
        for(ContentVersion cv: [SELECT Id FROM ContentVersion WHERE Id IN :contentIds]) {
            if(contentToMaterials.containsKey(cv.Id)) {
                materialWrappers.add(new MaterialWrapper(contentToMaterials.get(cv.Id)));
            }
        }
        materialWrappers.sort();
        for(MaterialWrapper mw: materialWrappers) {
            filtredMaterials.add(mw .getMaterial());
        }
        return filtredMaterials;
    }

    public static Set<String> tagsCsvToCollection(String tagsCsv){
        if(tagsCsv == null) {
            return null;
        }
        Set<String> tags = new Set<String>();
        for(String tag: prepareStringToMatching(tagsCsv).split(',')) {
            tags.add(tag.trim());
        }
        return tags;
    }

    public static Boolean matchTags(Set<String> tags, Set<String> searchTags){
        for(String searchTag: searchTags){
            if(matchTag(tags, searchTag)){
                return true;
            }
        }
        return false;
    }

    private static String prepareStringToMatching(String value) {
        return value.toLowerCase();
    }

    public static Boolean matchTag(Set<String> tags, String searchTag) {
        return tags.contains(prepareStringToMatching(searchTag));
    }
}