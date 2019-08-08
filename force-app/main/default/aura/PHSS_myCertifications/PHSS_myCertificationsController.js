({
    doInit : function(component, event, helper) {
        helper.fetchCert(component);
    },
    handleClick: function (component, event, helper) {
        var qrCodeWebAddress = event.target.getAttribute("data-recId")
        console.log('received Qr code web address>>>'+qrCodeWebAddress);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({"url": qrCodeWebAddress});
        urlEvent.fire();
    },
    showmore: function (component, event, helper) {
        var Pagelimit=component.get("v.Pagelimit");
        var TempListAA=component.get("v.TempListAA");
        var ListAchivementAssignment=component.get("v.ListAchivementAssignment");
        var moreElements= TempListAA.splice(0,Pagelimit);
        for(var i=0; i<moreElements.length;i++){
            ListAchivementAssignment.push(moreElements[i]);                                       
        }        
        component.set("v.ListAchivementAssignment",ListAchivementAssignment);
        
    },
    showfew: function (component, event, helper) {
        var Pagelimit=component.get("v.Pagelimit");
        var TempListAA=component.get("v.TempListAA");
        var ListAchivementAssignment=component.get("v.ListAchivementAssignment");
        if(ListAchivementAssignment.length>Pagelimit){
            var diff=ListAchivementAssignment.length-Pagelimit;
            if(diff>Pagelimit){
                var ElementstoRemove= ListAchivementAssignment.splice(-Pagelimit,Pagelimit);
            for(var i=0; i<ElementstoRemove.length;i++){
                TempListAA.unshift(ElementstoRemove[i]);                                       
            }        
            component.set("v.TempListAA",TempListAA);
            component.set("v.ListAchivementAssignment",ListAchivementAssignment);  
            }
            else{
                var ElementstoRemove= ListAchivementAssignment.splice(-diff,diff);
            for(var i=0; i<ElementstoRemove.length;i++){
                TempListAA.unshift(ElementstoRemove[i]);                                       
            }        
            component.set("v.TempListAA",TempListAA);
            component.set("v.ListAchivementAssignment",ListAchivementAssignment);  
            }
            
        }
    }
    
})