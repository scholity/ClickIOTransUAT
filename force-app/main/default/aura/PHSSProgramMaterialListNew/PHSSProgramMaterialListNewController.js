({
    handleGlobalMaterials : function(component, event, helper) {
        if(component.get('v.isUsingGlobalEvent')){
            helper.processMaterials(component, event.getParam("materials"));
        }
    },
    filterMaterials: function(component, event, helper) {
        helper.filterMaterials(component, event);
    },
    handleSearch: function(component, event, helper) {
        helper.filterMaterials(component, event);
    },
    
    callcollapse : function(comp, event, helper) {
        //alert('inside controller');
        var heading_content = comp.find("heading_content");
        var heading_title=comp.find("heading_title");
        $A.util.toggleClass(heading_content, "slds-hide"); //toggle
        $A.util.toggleClass(heading_title, "slds-is-open");
    },
        
    showMore: function(component, event, helper) {
        var newDisplayNum = component.get('v.currentDisplayNum')+component.get('v.initalDisplayNum');
        var materials = component.get('v.filteredMaterials');
        if(materials.length>newDisplayNum){
            component.set('v.showMoreButton', true);
        }
        
        component.set('v.currentDisplayNum', newDisplayNum);
        helper.filterMaterials(component);
    },
    handleLocalMaterials: function(component, event, helper){
        if(!component.get('v.isUsingGlobalEvent')) {
            helper.processMaterials(component, component.get("v.materials"));
        }
    },
     sectionOne : function(component, event, helper) {
       helper.helperFun(component,event,'articleOne');
    },
})