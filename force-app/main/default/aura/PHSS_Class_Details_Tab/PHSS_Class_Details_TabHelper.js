({
    getData : function(component) {
        var recordId = component.get("v.recordId");
        if($A.util.isEmpty(recordId)){
            var recordIdpattern = new RegExp("[?&]recordId=(([^&]*)&?|&|$)");
            var urlRecordId = recordIdpattern.exec(location.href);
            if (urlRecordId != null && urlRecordId.length > 2 && urlRecordId[2] != null && urlRecordId[2].length > 2) {
                recordId = urlRecordId[2];
                component.set("v.recordId",recordId);
            }
        }        
    }
 })