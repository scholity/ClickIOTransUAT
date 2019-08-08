({
	initWCS : function(component, event, helper) {
        var windowOpts = 'width=375,height=600'
       	var url = component.get('v.url')
        
        //var staticUrl= 'https://arc-phss--partial--c.cs94.visual.force.com/apex/Virtual_Agent_Beta'
        window.open('/apex/Virtual_Agent_Beta', '', windowOpts)
	}
})