({
	doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        component.set("v.selectedAction","");

        if($A.util.isEmpty(recordId)){
            var recordIdpattern = new RegExp("[?&]recordId=(([^&]*)&?|&|$)");
            var urlRecordId = recordIdpattern.exec(location.href);
            if (urlRecordId != null && urlRecordId.length > 2 && urlRecordId[2] != null && urlRecordId[2].length > 2) {
                recordId = urlRecordId[2];
                component.set("v.recordId",recordId);
            }
        }
        helper.getVouchers(component, event, helper); 
    },
            
    // enroll action
    enrollAction: function(component, event, helper) {
        var ctarget = event.currentTarget;
        var id_str = ctarget.dataset.value;
        component.set("v.selectedAction","enroll");
        component.set("v.voucherId",id_str);    
        component.set("v.showModal",true);        
    },

    // unenroll action
    unenrollAction: function(component, event, helper) {
        var ctarget = event.currentTarget;
        var selectedVoucher = ctarget.dataset.value;
        var voucherFields = selectedVoucher.split("::");
        component.set("v.selectedAction","cancel");
        component.set("v.voucherUser",voucherFields[0]);
        component.set("v.voucherId",voucherFields[1]);
        component.set("v.showModal",true);
    },

    // cancel student enrollment
    doUnenroll: function(component, event, helper) {
        helper.unenrollStudent(component, event, helper);
    },

    refreshVoucherList : function(component, event, helper) {
        component.set("v.showModal",false);
        component.set("v.selectedAction","");
    	helper.getVouchers(component, event, helper);        
    },
            
    closeModal : function(component, event, helper) {
 		component.set("v.showModal",false);
        component.set("v.selectedAction","");
    }
})