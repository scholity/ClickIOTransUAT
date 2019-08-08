({
    getRecordsData: function(cmp) {
        var recordId = cmp.get('v.recordId');
        if($A.util.isEmpty(recordId)){
            var recordIdpattern = new RegExp("[?&]recordId=(([^&]*)&?|&|$)");
            var urlRecordId = recordIdpattern.exec(location.href);
            
            //var urlRecordId = /[?&]urlRecordId(=([^&]*)|&|$)/.exec(location.href);
            if (urlRecordId != null && urlRecordId.length > 2 && urlRecordId[2] != null && urlRecordId[2].length > 2) {
                recordId = urlRecordId[2];
            }
        }
        var itemId = cmp.get("v.itemId")
            ? cmp.get("v.itemId")
            : recordId;


        if (!$A.util.isEmpty(itemId)) {
            var getRecords = cmp.get("c.getRecords");

            getRecords.setParams({
                "itemId": itemId
            });

            cmp.find('templateMainCmp').doRequest(getRecords, function(result) {
                moment.locale(result.lang);
                var res = result.records;
                for(var i=0; i<res.length; i++){
                    res[i].startDate =  moment(res[i].startDate).format('L');
                }
                cmp.set("v.records", res);
            });
        }
    }
});