({
    // Your renderer method overrides go here
    afterRender: function(component, helper) {
        window.addEventListener('message', function(event) {
            var data = event.data;
//            console.log(data);
            if (data != null && data.type==='LiveAgentEvent') {
            	if(data.status === 'LIVEAGENT_LOADED'){
            		helper.initLiveAgent(component);
            	}
                else if (data.status === 'LIVEAGENT_BUTTON_AVAILABLE') {
                    $A.util.removeClass(component.find('liveagent_btn'), 'isDisabled');
                    component.set('v.buttonDisabled', false);
                } else if (data.status === 'LIVEAGENT_BUTTON_UNAVAILABLE') {
                    $A.util.addClass(component.find('liveagent_btn'), 'isDisabled');
                    component.set('v.buttonDisabled', true);
                }
            }
//            console.log(event.data);
        });
        this.superAfterRender();
    }
})