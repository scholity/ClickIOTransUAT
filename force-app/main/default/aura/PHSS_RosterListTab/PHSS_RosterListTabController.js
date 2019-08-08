({
	doInit : function(component, event, helper) {
        helper.getData(component);
    },

    printDiv : function(component, event, helper) {
        // printUtil.printDiv();
        
    },
    
    generatePDF : function(component, event, helper){
        
      var sendData = component.get("v.sendData");

      console.log('dataToSend='+component.get("v.rosters"));        
      var dataToSend = component.get("v.rosters");
 
      //invoke vf page js method
      sendData(dataToSend, function(){
                  //handle callback
      });
 	}   
})