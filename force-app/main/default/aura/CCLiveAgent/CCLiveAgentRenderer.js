({
	// Your renderer method overrides go here
	afterRender: function(cmp, helper){
        console.log('Calling After Render');
        helper.initiateLiveAgent(cmp);
    }
})