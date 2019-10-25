public without sharing class PHSS_skedLocationtoILTlocation {

    public static void afterInsert(List<sked__Location__c> newRecords) {
        upsertILTLocation(newRecords);
    }
    public static void afterUpdate(List<sked__Location__c> newRecords, Map<Id, sked__Location__c> updatedRecords) {
        upsertILTLocation(newRecords);
    }
    public static void beforeDelete(Map<Id, sked__Location__c> deleteRecords) {
        deleteILTLocation(deleteRecords);
    }

    private static void upsertILTLocation(List<sked__Location__c> newRecords) {
        List<redwing__ILT_Location__c> rdILTList = new List<redwing__ILT_Location__c>();
        for(sked__Location__c skld:newRecords)
        {
             if(skld.id != null) {
                redwing__ILT_Location__c rl = new redwing__ILT_Location__c();
                rl.Skedulo_Location__c = skld.id;
                rl.Skedulo_Location_External__c = skld.id;
                rl.Skedulo_Address__c = skld.sked__Address__c; // Throw full address into catch-all field
                
                List<String> parsedAddress = parseAddress(skld.sked__Address__c);

                rl.redwing__Address_1__c = parsedAddress[0];
                rl.redwing__Address_2__c = parsedAddress[1];
                rl.redwing__City__c = parsedAddress[2];
                rl.redwing__State__c = parsedAddress[3];
                rl.redwing__Postal_Code__c = parsedAddress[4];
                rl.redwing__Country__c = parsedAddress[5];
                
                if (skld.sked__GeoLocation__Longitude__s != null && skld.sked__GeoLocation__Latitude__s != null) {
                   rl.redwing__Directions__c = String.ValueOf(skld.sked__GeoLocation__Longitude__s)+' '+String.ValueOf(skld.sked__GeoLocation__Latitude__s);
                } else rl.redwing__Directions__c = '';
                
                rl.Skedulo_Is_Active__c = skld.Is_Active__c;
                rl.Name = skld.Name;
                rl.redwing__Description__c = skld.Notes__c;
                rl.Skedulo_Region__c = skld.sked__Region__c;
                rl.Skedulo_Type__c = skld.sked__Type__c;
                rdILTList.add(rl);
            }
        }
          
        Schema.SObjectField f = redwing__ILT_Location__c.Fields.Skedulo_Location_External__c;                       
        if(rdILTList.size() > 0){             
            Database.upsert(rdILTList, f, false);
        }
    }
    
    private static void deleteILTLocation(Map<Id, sked__Location__c> deleteRecords) {
        list<redwing__ILT_Location__c> lstILTRecords = [Select Id, Skedulo_Is_Active__c from redwing__ILT_Location__c where Skedulo_Location__c IN: deleteRecords.keyset()];
        
        if(!lstILTRecords.isEmpty()){
            for(redwing__ILT_Location__c rid:lstILTRecords)
            {
             rid.Skedulo_Is_Active__c = false;
            }
            Database.update (lstILTRecords, false);
        }
    }

    public static List<String> parseAddress (String theAddress) {
        String theAddress1 = '';
        String theAddress2 = '';
        String theCity = '';
        String theState = '';
        String theZip = '';
        String theCountry = '';
        List<String> theParsedAddress = new List<String>{'','','','','',''};

        if(String.IsNotBlank(theAddress)) {
            // Handles Addr1, City, State Zip (optional Country)
            String theFourTokenRegEx = '^([^,]*),([^,]*),([^,]*)\\s+(\\d{5,})(([,\\s]*)(.*))?';

            // Handles Addr1, Addr2, City, State Zip
            String theFiveTokenRegEx = '^([^,]*),([^,]*),([^,]*),([^,]*)\\s+(\\d{5,})(([,\\s]*)(.*))?';

            Pattern myFourTokenPattern = Pattern.compile(theFourTokenRegEx);
            Pattern myFiveTokenPattern = Pattern.compile(theFiveTokenRegEx);

            Matcher myFourTokenMatcher = myFourTokenPattern.matcher(theAddress);

            if (myFourTokenMatcher.matches()) {
                theAddress1 = myFourTokenMatcher.group(1).trim();
                theCity = myFourTokenMatcher.group(2).trim();
                theState = myFourTokenMatcher.group(3).trim();
                theZip = MyFourTokenMatcher.group(4).trim();
                if (String.IsNotBlank(MyFourTokenMatcher.group(7))) {
                    theCountry = MyFourTokenMatcher.group(7).trim();
                } else {
                    theCountry = 'US';
                }
            } else {
                Matcher myFiveTokenMatcher = myFiveTokenPattern.matcher(theAddress);

                if (myFiveTokenMatcher.matches()) {
                    theAddress1 = myFiveTokenMatcher.group(1).trim();
                    theAddress2 = myFiveTokenMatcher.group(2).trim();
                    theCity = myFiveTokenMatcher.group(3).trim();
                    theState = myFiveTokenMatcher.group(4).trim();
                    theZip = MyFiveTokenMatcher.group(5).trim();
                    if (String.IsNotBlank(MyFiveTokenMatcher.group(8))) {
                        theCountry = MyFiveTokenMatcher.group(8).trim();
                    } else {
                        theCountry = 'US';
                    }
                }
            }
        }

        theParsedAddress[0] = theAddress1;
        theParsedAddress[1] = theAddress2;
        theParsedAddress[2] = theCity;
        theParsedAddress[3] = theState;
        theParsedAddress[4] = theZip;
        theParsedAddress[5] = (theCountry == 'USA') ? 'US' : theCountry; // Convert USA to US as found in many existing addresses

        return theParsedAddress;
    }
}