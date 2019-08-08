({
    doInit : function(component, event, helper) {
//        helper.getFilteredCerts(component);
		helper.getFilteredSortedCerts(component);
        helper.getAllCerts(component);
	}
})