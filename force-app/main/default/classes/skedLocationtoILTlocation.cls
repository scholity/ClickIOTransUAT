public class skedLocationtoILTlocation {

    public static void afterInsert(List<sked__Location__c> newRecords) {
        upsertILTLocation(newRecords);
    }
    public static void afterUpdate(List<sked__Location__c> newRecords, Map<Id, sked__Location__c> updatedRecords) {
        //updateILTLocation(updatedRecords, newRecords);
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
                
                String theAddress1 = '';
                String theAddress2 = '';
                String theCity = '';
                String theState = '';
                String theZip = '';
                String theCountry = '';
                
                if(String.IsNotBlank(skld.sked__Address__c)) {
                    // Handles Addr1, City, State Zip (optional Country)
                    String theFourTokenRegEx = '^([^,]*),([^,]*),([^,]*)\\s+(\\d{5,})(([,\\s])(.*))?';//'^(.*),(.*),(.*)\\s+(\\d{5,})(([,\\s])(.*))?';
                    
                    // Handles Addr1, Addr2, City, State Zip
                    String theFiveTokenRegEx = '^([^,]*),([^,]*),([^,]*),([^,]*)\\s+(\\d{5,})(([,\\s])(.*))?';//'^(.*),(.*),(.*),(.*)\\s+(\\d{5,})(([,\\s])(.*))?';
                    
                    Pattern myFourTokenPattern = Pattern.compile(theFourTokenRegEx);
                    Pattern myFiveTokenPattern = Pattern.compile(theFiveTokenRegEx);
                    
                    Matcher myFourTokenMatcher = myFourTokenPattern.matcher(skld.sked__Address__c);
                    
                    if (myFourTokenMatcher.matches()) {
                        theAddress1 = myFourTokenMatcher.group(1).trim();
                        theCity = myFourTokenMatcher.group(2).trim();
                        theState = myFourTokenMatcher.group(3).trim();
                        theZip = MyFourTokenMatcher.group(4).trim();
                        if (String.IsNotBlank(MyFourTokenMatcher.group(7))) theCountry = MyFourTokenMatcher.group(7).trim();
                    } else {
                        Matcher myFiveTokenMatcher = myFiveTokenPattern.matcher(skld.sked__Address__c);
                        
                        if (myFiveTokenMatcher.matches()) {
                            theAddress1 = myFiveTokenMatcher.group(1).trim();
                            theAddress2 = myFiveTokenMatcher.group(2).trim();
                            theCity = myFiveTokenMatcher.group(3).trim();
                            theState = myFiveTokenMatcher.group(4).trim();
                            theZip = MyFiveTokenMatcher.group(5).trim();  
                            if (String.IsNotBlank(MyFiveTokenMatcher.group(8))) theCountry = MyFiveTokenMatcher.group(8).trim(); 
                        }                      
                    }
                }            
                    
                /*
                //Have to Split up the address string (skld.sked__Address__c)
                if(String.IsNotBlank(skld.sked__Address__c)){
                    list<String> addressSplits = skld.sked__Address__c.split(', ');
                    
                    if(addressSplits.size() > 0){
                        if(addressSplits.size() == 4){
                            rl.redwing__Address_1__c = addressSplits[0];
                            rl.redwing__City__c = addressSplits[1];
                            rl.redwing__State__c = addressSplits[2];
                            rl.redwing__Postal_Code__c = addressSplits[3];
                        }
                        else if(addressSplits.size() == 5){
                            if(addressSplits[3].isNumeric()){
                                rl.redwing__Address_1__c = addressSplits[0];
                                rl.redwing__City__c = addressSplits[1];
                                rl.redwing__State__c = addressSplits[2];
                                rl.redwing__Postal_Code__c = addressSplits[3];
                                rl.redwing__Country__c = addressSplits[4];
                            }
                            else if(addressSplits[4].isNumeric()){
                                rl.redwing__Address_1__c = addressSplits[0];
                                rl.redwing__Address_2__c = addressSplits[1];
                                rl.redwing__City__c = addressSplits[2];
                                rl.redwing__State__c = addressSplits[3];
                                rl.redwing__Postal_Code__c = addressSplits[4];
                            }
                            else {
                                rl.redwing__Address_1__c = skld.sked__Address__c;
                            }
                        }
                        else if(addressSplits.size() == 6){
                            rl.redwing__Address_1__c = addressSplits[0];
                            rl.redwing__Address_2__c = addressSplits[1];
                            rl.redwing__City__c = addressSplits[2];
                            rl.redwing__State__c = addressSplits[3];
                            rl.redwing__Postal_Code__c = addressSplits[4];
                            rl.redwing__Country__c = addressSplits[5];
                        }
                        else {
                            rl.redwing__Address_1__c = skld.sked__Address__c;
                        }
                    }
                    
                    
                    rl.redwing__Street__c= addressSplits[0];
                    rl.redwing__City__c= addressSplits[1];
                    rl.redwing__State__c= addressSplits[2].subStringBefore(' ');
                    rl.redwing__Postal_Code__c=addressSplits[2].subStringAfter(' ');
                    try {
                        rl.redwing__Country__c= addressSplits[3];
                    }catch(Exception e){}
                } */
                
                /*if(String.IsNotBlank(skld.sked__Address__c)){
                    list<String> addressSplits = skld.sked__Address__c.split(', ');
                    rl.redwing__Street__c= addressSplits[0];
                    rl.redwing__City__c= addressSplits[1];
                    rl.redwing__State__c= addressSplits[2].subStringBefore(' ');
                    rl.redwing__Postal_Code__c=addressSplits[2].subStringAfter(' ');
                    try {
                        rl.redwing__Country__c= addressSplits[3];
                    }catch(Exception e){}
                }*/
                
                rl.redwing__Address_1__c = theAddress1;
                rl.redwing__Address_2__c = theAddress2;
                rl.redwing__City__c = theCity;
                rl.redwing__State__c = theState;
                rl.redwing__Postal_Code__c = theZip;
                rl.redwing__Country__c = theCountry;
                
                if (skld.sked__GeoLocation__Longitude__s != null && skld.sked__GeoLocation__Latitude__s != null) {
                   rl.redwing__Directions__c = String.ValueOf(skld.sked__GeoLocation__Longitude__s)+' '+String.ValueOf(skld.sked__GeoLocation__Latitude__s);
                } else rl.redwing__Directions__c = '';
                
                rl.Skedulo_Is_Active__c = skld.Is_Active__c;
                rl.Name = skld.Name;
                rl.redwing__Description__c = skld.Notes__c;
                rl.Skedulo_Region__c = skld.sked__Region__c;
                rl.Skedulo_Type__c = skld.sked__Type__c;
                rdILTList.add(rl);
                
                //rl.redwing__Address = skld.sked__Address__c;
            }
        }
          
        Schema.SObjectField f = redwing__ILT_Location__c.Fields.Skedulo_Location_External__c;                       
        if(rdILTList.size() > 0){             
            Database.upsert(rdILTList, f, false);
            //database.insert(rdILTList, false);
        }

    }
/*    private static void updateILTLocation(Map<Id, sked__Location__c> updatedRecords, List<sked__Location__c> newRecords) {


        Map<Id, redwing__ILT_Location__c> locMapping = new Map<Id, redwing__ILT_Location__c>();
        List<redwing__ILT_Location__c> updaterdILTList = new List<redwing__ILT_Location__c>();
    
        updaterdILTLIst = [Select id,Skedulo_Location__c,redwing__Street__c,redwing__City__c,redwing__State__c,redwing__Postal_Code__c,
            redwing__Country__c,redwing__Directions__c,Skedulo_Is_Active__c,Name,redwing__Description__c,Skedulo_Region__c,Skedulo_Type__c
          from redwing__ILT_Location__c where Skedulo_Location__c IN: updatedRecords.keyset()];
        
        for(redwing__ILT_Location__c iltLocation : updaterdILTList){
            locMapping.put(iltLocation.Skedulo_Location__c, iltLocation);
        }
        list<redwing__ILT_Location__c> lstInsertLocation = new List<redwing__ILT_Location__c>();
        list<redwing__ILT_Location__c> lstUpdateLocation = new List<redwing__ILT_Location__c>();
        
        for(sked__Location__c skld : newRecords){
            redwing__ILT_Location__c rl = new redwing__ILT_Location__c();
                rl.Skedulo_Location__c = skld.id;
                rl.Sked_Address__c = skld.sked__Address__c;
                if(String.IsNotBlank(skld.sked__Address__c)){
                    list<String> addressSplits = skld.sked__Address__c.split(', ');
                    
                    if(addressSplits.size() > 0){
                        if(addressSplits.size() == 4){
                            rl.redwing__Address_1__c = addressSplits[0];
                            rl.redwing__City__c = addressSplits[1];
                            rl.redwing__State__c = addressSplits[2];
                            rl.redwing__Postal_Code__c = addressSplits[3];
                        }
                        else if(addressSplits.size() == 5){
                            if(addressSplits[3].isNumeric()){
                                rl.redwing__Address_1__c = addressSplits[0];
                                rl.redwing__City__c = addressSplits[1];
                                rl.redwing__State__c = addressSplits[2];
                                rl.redwing__Postal_Code__c = addressSplits[3];
                                rl.redwing__Country__c = addressSplits[4];
                            }
                            else if(addressSplits[4].isNumeric()){
                                rl.redwing__Address_1__c = addressSplits[0];
                                rl.redwing__Address_2__c = addressSplits[1];
                                rl.redwing__City__c = addressSplits[2];
                                rl.redwing__State__c = addressSplits[3];
                                rl.redwing__Postal_Code__c = addressSplits[4];
                            }
                            else {
                                rl.redwing__Address_1__c = skld.sked__Address__c;
                            }
                        }
                        else if(addressSplits.size() == 6){
                            rl.redwing__Address_1__c = addressSplits[0];
                            rl.redwing__Address_2__c = addressSplits[1];
                            rl.redwing__City__c = addressSplits[2];
                            rl.redwing__State__c = addressSplits[3];
                            rl.redwing__Postal_Code__c = addressSplits[4];
                            rl.redwing__Country__c = addressSplits[5];
                        }
                        else {
                            rl.redwing__Address_1__c = skld.sked__Address__c;
                        }
                    }

                    rl.redwing__Street__c= addressSplits[0];
                    rl.redwing__City__c= addressSplits[1];
                    rl.redwing__State__c= addressSplits[2].subStringBefore(' ');
                    rl.redwing__Postal_Code__c=addressSplits[2].subStringAfter(' ');
                    try {
                        rl.redwing__Country__c= addressSplits[3];
                    }catch(Exception e){}
                }
                rl.redwing__Directions__c = String.ValueOf(skld.sked__GeoLocation__Longitude__s)+' '+String.ValueOf(skld.sked__GeoLocation__Latitude__s);
                rl.Skedulo_Is_Active__c = skld.Is_Active__c;
                rl.Name = skld.Name;
                rl.redwing__Description__c = skld.Notes__c;
                rl.Skedulo_Region__c = skld.sked__Region__c;
                rl.Skedulo_Type__c = skld.sked__Type__c;
                
                if(locMapping.containsKey(skld.Id)){
                    rl.Id = locMapping.get(skld.Id).id;
                }
                lstUpdateLocation.add(rl);

        }
         if(!lstInsertLocation.isEmpty()){
         Database.upsert(lstUpdateLocation, false);
         }
    } */
    
    private static void deleteILTLocation(Map<Id, sked__Location__c> deleteRecords) {
        list<redwing__ILT_Location__c> lstILTRecords = [Select Id, Skedulo_Is_Active__c from redwing__ILT_Location__c where Skedulo_Location__c IN: deleteRecords.keyset()];
        
        if(!lstILTRecords.isEmpty()){
            //database.delete(lstILTRecords, false);
                 for(redwing__ILT_Location__c rid:lstILTRecords)
                 {
                  rid.Skedulo_Is_Active__c = false;
                 }
              Database.update (lstILTRecords, false);
        }
    }
}