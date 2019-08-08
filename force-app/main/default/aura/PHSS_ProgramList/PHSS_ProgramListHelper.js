({
	loadAll : function(component) {
		var action = component.get('c.getAllPrograms');
        action.setCallback(this, function(response) {
            var state = response.getState();
			if (component.isValid() && state === "SUCCESS") {
				component.set('v.programs', response.getReturnValue());
				component.set('v.isAll', true);
			}
        });
        $A.enqueueAction(action);
	},
	loadFeatured: function(component){
		var _this = this;
		var action = component.get('c.getFeaturedPrograms');
        action.setCallback(this, function(response) {
            var state = response.getState();
			if (component.isValid() && state === "SUCCESS") {
				var programs = response.getReturnValue();
				if(programs.length === 0){
					_this.loadAll(component);
				} else {
					component.set('v.programs', programs);
				}
			}
        });
        $A.enqueueAction(action);
	}
})