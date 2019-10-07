({
   onfocus : function(component,event,helper){
       
       $A.util.addClass(component.find("mySpinner"), "slds-show");
        
       var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
        
         var getInputkeyWord = '';
         helper.searchHelper(component,event,getInputkeyWord);

       component.set("v.errorMessage", null);
   },
    
    doInit : function(component, event, helper){
        var selRec = component.get("v.selectedRecord");
        console.log(selRec);
        if(selRec != null && selRec != '' && JSON.stringify(selRec) != '{}') {
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        var lookUpTarget = component.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');
        
        }
    },
    
    onblur : function(component,event,helper){
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    
    keyPressController : function(component, event, helper) {
       
         var getInputkeyWord = component.get("v.SearchKeyWord");       
       
        if( getInputkeyWord.length > 0 ){
             var forOpen = component.find("searchRes");
               $A.util.addClass(forOpen, 'slds-is-open');
               $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{  
             component.set("v.listOfSearchRecords", null ); 
             var forclose = component.find("searchRes");
               $A.util.addClass(forclose, 'slds-is-close');
               $A.util.removeClass(forclose, 'slds-is-open');
          }
	},
    
  
    clear :function(component,event,heplper){
         var pillTarget = component.find("lookup-pill");
         var lookUpTarget = component.find("lookupField"); 
        
         $A.util.addClass(pillTarget, 'slds-hide');
         $A.util.removeClass(pillTarget, 'slds-show');
        
         $A.util.addClass(lookUpTarget, 'slds-show');
         $A.util.removeClass(lookUpTarget, 'slds-hide');
      
         component.set("v.SearchKeyWord",null);
         component.set("v.listOfSearchRecords", null );
         component.set("v.selectedRecord", {} );  
         var selectionEvent  =component.getEvent("selectionEvent");
        selectionEvent.setParams( {
            'instanceID' : component.get("v.instanceId"),
            'SelectedValue' : null,
            'isClear'  : true
        });
         if(component.get("v.instanceId") != '')
        	selectionEvent.fire();
    },
    
  
    handleComponentEvent : function(component, event, helper) {


       var selectedAccountGetFromEvent = event.getParam("recordByEvent");
	   component.set("v.selectedRecord" , selectedAccountGetFromEvent);

        var forclose = component.find("lookup-pill");
           $A.util.addClass(forclose, 'slds-show');
           $A.util.removeClass(forclose, 'slds-hide');
  
        var forclose = component.find("searchRes");
           $A.util.addClass(forclose, 'slds-is-close');
           $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show');
        
        var selectionEvent  =component.getEvent("selectionEvent");
        selectionEvent.setParams( {
            'instanceID' : component.get("v.instanceId"),
            'SelectedValue' : selectedAccountGetFromEvent,
            'isClear'  : false
        });
        if(component.get("v.instanceId") != '')
        	selectionEvent.fire();

        component.set("v.errorMessage", null);
	},

    handleErrorMessage: function(component, event, helper) {
       var errorMessage = component.get("v.errorMessage");
       if (errorMessage == null || errorMessage == "") {
           helper.clearErrorMessage(component);
       }
       else {
           helper.displayErrorMessage(component, errorMessage);
       }
    }
})