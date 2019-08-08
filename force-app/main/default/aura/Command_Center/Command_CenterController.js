({
    learningCenterClick : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        var openSubTab = false;
        
        var focusedTabURL;
        var focusedTabId;
        var focusedTabIsCaseTab = false;
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            focusedTabURL = response.url;
            if(typeof focusedTabURL != 'undefined')
            {
                if(focusedTabURL.includes("500"))
                {
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                        focusedTabId = response.tabId;
                        console.log(response);
                        //workspaceAPI.closeTab({tabId: focusedTabId});
                    }).then(function(response){
                        workspaceAPI.openSubtab({
                            parentTabId: focusedTabId,
                            url: 'https://classes.redcross.org/Saba/Web/Main',
                            focus: true
                        });
                    })
                    .catch(function(error) {
                        console.log(error);
                    });
                }
                else
                {
                    workspaceAPI.openTab({
                        url: 'https://classes.redcross.org/Saba/Web/Main',
                        focus: true
                    }).then(function(response){
                        workspaceAPI.setTabLabel({
                            tabId: response,
                            label: "Learning Center"
                        });
                    })
                    .catch(function(error){
                        console.log(error);
                    });
                }
            }
            else
            {
                workspaceAPI.openTab({
                    url: 'https://classes.redcross.org/Saba/Web/Main',
                    focus: true
                }).then(function(response){
                    workspaceAPI.setTabLabel({
                        tabId: response,
                        label: "Learning Center"
                    });
                })
                .catch(function(error){
                    console.log(error);
                });
            }
            console.log(response);
        }).catch(function(error) {
            console.log(error);
        });
        /*var focusedTabId = 'test';
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            focusedTabId = response.tabId;
            console.log(response);
            //workspaceAPI.closeTab({tabId: focusedTabId});
        }).catch(function(error) {
            console.log(error);
        });
        alert(focusedTabId);
        if(focusedTabId != '')
        {
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                focusedTabId = response.tabId;
                console.log(response);
                //workspaceAPI.closeTab({tabId: focusedTabId});
            }).then(function(response){
                workspaceAPI.openSubtab({
                    parentTabId: focusedTabId,
                    url: 'https://classes.redcross.org/Saba/Web/Main',
                    focus: true
                });
            })
            .catch(function(error) {
                console.log(error);
            });
        }
        else
        {
            workspaceAPI.openTab({
                url: 'https://classes.redcross.org/Saba/Web/Main',
                focus: true
            }).then(function(response){
                workspaceAPI.setTabLabel({
                    tabId: response,
                    label: "Learning Center"
                });
            })
            .catch(function(error){
                console.log(error);
            });
        }*/
    },
    informationStationClick : function(component, event, helper) {
        window.open("https://redcross.jiveon.com/community/american-red-cross/american-information-station");
    },
    webiClick : function(component, event, helper) {
        window.open("https://webi.redcross.org");
    },
    instructorscornerClick : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            url: 'http://www.instructorscorner.org',
            focus: true
        }).then(function(response){
            workspaceAPI.setTabLabel({
                tabId: response,
                label: "Instructors Corner"
            });
        })
        .catch(function(error){
            console.log(error);
        });
    },
    BusinessMan : function(component, event, helper) {
        window.open("https://production-shop-arc.demandware.net/on/demandware.store/Sites-Site/default/ViewApplication-DisplayWelcomePage?SelectedSiteID=2a491418c77a72e65cf91c59d2");
    },
    /*shopStayWellClick : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            url: 'https://www.shopstaywell.com',
            focus: true
        }).then(function(response){
            workspaceAPI.setTabLabel({
                tabId: response,
                label: "Shop Stay Well"
            });
        })
        .catch(function(error){
            console.log(error);
        });
    },*/
    redCrossClick : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            url: 'http://www.redcross.org',
            focus: true
        }).then(function(response){
            workspaceAPI.setTabLabel({
                tabId: response,
                label: "Red Cross"
            });
        })
        .catch(function(error){
            console.log(error);
        });
    },
    acceptCase: function(component, event, helper) 
    {
        var action = component.get('c.acceptNextCase');
        action.setCallback(this, function(response)	{
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Response'+JSON.stringify(response.getReturnValue()));
                component.set('v.wrapperContent', response.getReturnValue());
                if (response.getReturnValue().didCaseOwnershipChange && !response.getReturnValue().hasException) 
                {
                    var caseId = response.getReturnValue().caseId;
                    var redirectURL = '/' + caseId;
                    var caseNumber = response.getReturnValue().caseNumber;
                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.openTab({
                        url: '/lightning/r/Case/'+response.getReturnValue().caseId+'/view',
                        focus: true
                    }).then(function(response){
                        workspaceAPI.setTabLabel({
                            tabId: response
                        });
                    })
                    .catch(function(error){
                        console.log(error);
                    });
                }else if (response.getReturnValue().hasException) 
                {
                    alert('System Error, please contact your administrator providing the following error message: ' + result.exceptionMessage);
                }else 
                {             
                    alert('There are no Cases available.');
                }
            }
        });
        $A.enqueueAction(action);
    },
    globalGhostContactClick : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            url:'https://arc-phss.lightning.force.com/lightning/r/Contact/'+$A.get("$Label.c.Global_Ghost_Contacts")+'/view',
            //url: 'https://arc-phss.lightning.force.com/lightning/r/Contact/003d000001giA46AAE/view',
            //url: 'https://arc-phss--lightning.cs91.my.salesforce.com/0032F00000EmVED',
            focus: true
        }).then(function(response){
            workspaceAPI.setTabLabel({
                tabId: response,
                label: "Global Ghost Contact"
            });
        })
        .catch(function(error){
            console.log(error);
        });
    },
    customerDataSearchClick : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        /* workspaceAPI.openTab({
            pageReference: {
                "type": "standard__component",
                "attributes": {
                    "componentName": "c__Customer_Data_Search"  // c__<comp Name>
                },
                "state": {
                    "uid": "1"
                }
            },
            focus: true
        }).then((response) => {
            workspaceAPI.setTabLabel({
            tabId: response,
            label: "Customer Data Search"
        });
    }).catch(function(error) {
    console.log(error);
});*/
        workspaceAPI.openTab({
            url: '/apex/CTIScreenPop',
            focus: true
        }).then(function(response){
            workspaceAPI.setTabLabel({
                tabId: response,
                label: "Customer Data Search",
                icon: "action:contact",
                iconAlt: "contact"
            });
        })
        .catch(function(error){
            console.log(error);
        });
    }
}
)