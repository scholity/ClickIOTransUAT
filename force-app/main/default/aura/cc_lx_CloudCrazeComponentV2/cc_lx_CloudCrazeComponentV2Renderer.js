({
  afterRender : function(component, helper){
  },
  rerender : function(component, helper){
    this.superRerender();
    setTimeout(
      $A.getCallback(function(){
          
      }), 500
    );
  }
})