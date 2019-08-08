({
    getRecordData: function(cmp) {
        var recordId = cmp.get('v.recordId');
        if($A.util.isEmpty(recordId)){
            var recordIdpattern = new RegExp("[?&]recordId=(([^&]*)&?|&|$)");
            var urlRecordId = recordIdpattern.exec(location.href);
            //var urlRecordId = /[?&]urlRecordId(=([^&]*)|&|$)/.exec(location.href);
            if (urlRecordId != null && urlRecordId.length > 2 && urlRecordId[2] != null && urlRecordId[2].length > 2) {
                recordId = urlRecordId[2];
            }            
            //var urlRecordId = /[?&]urlRecordId(=([^&]*)|&|$)/.exec(location.href);
        }
        var planId = '';
        var planIdpattern = new RegExp("[?&]pId=(([^&]*)&?|&|$)");
        var urlPlanId = planIdpattern.exec(location.href);        
        //var urlPlanId = /[&]pId(=([^&]*)|&|$)/.exec(location.href);
        if (urlPlanId != null && urlPlanId.length > 2 && urlPlanId[2] != null && urlPlanId[2].length > 2) {
            planId = urlPlanId[2];
        }
        //var urlPlanId = /[&]pId(=([^&]*)|&|$)/.exec(location.href);
        
        var itemId = cmp.get("v.itemId")
            ? cmp.get("v.itemId")
            : recordId;


        if (!$A.util.isEmpty(itemId)) {
            var getRecord = cmp.get("c.getRecord");

            getRecord.setParams({
                "itemId": itemId,
                "planId": planId
            });

            cmp.find('templateMainCmp').doRequest(getRecord, function(result) {
                moment.locale(result.lang);
                var res = result.record;
                res.formattedStartDate = moment(res.startDate).format('L');
                res.formattedEndDate = moment(res.endDate).format('L');
                cmp.set("v.record", res);               
            });
        }
    }
});