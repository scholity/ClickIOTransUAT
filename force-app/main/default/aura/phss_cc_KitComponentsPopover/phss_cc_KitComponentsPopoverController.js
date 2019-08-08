({
	showPopover : function (component, event, helper) {
		var popover = component.find("myPopover");
		$A.util.removeClass(popover,'slds-hide');
	},

	hidePopover : function (component, event, helper) {
		var popover = component.find("myPopover");
		$A.util.addClass(popover,'slds-hide');
	}
})