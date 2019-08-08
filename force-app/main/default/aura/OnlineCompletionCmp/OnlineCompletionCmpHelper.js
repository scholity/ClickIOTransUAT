({
    getData : function(component, event, helper){
        var recordId = component.get('v.recordId');
        if($A.util.isEmpty(recordId)){
            var urlRecordId = /[?&]urlRecordId(=([^&]*)|&|$)/.exec(location.href);
            if (urlRecordId != null && urlRecordId.length > 2 && urlRecordId[2] != null) {
                recordId = urlRecordId[2];
            }
        }
        var planId = '';
        var urlPlanId = /[&]pId(=([^&]*)|&|$)/.exec(location.href);
        if (urlPlanId != null && urlPlanId.length > 2 && urlPlanId[2] != null) {
            planId = urlPlanId[2];
        }
        var action = component.get('c.getData');
        action.setParams({
            "classId" : recordId,
            "planId" : planId
        });
        component.find("templateMainCmp").doRequest(action, function(result){
            if(result.allRosters){
                component.set('v.allRosters', result.allRosters);
            }
            if(result.completedRosters){
                component.set('v.completedRosters', result.completedRosters);
            }
            component.set('v.isInstructor', result.isInstructor);
            helper.drawPie(component, helper);
        });
    },
    drawPie : function(component, helper) {
        var svgContainer = component.find('pie-container');
        if(svgContainer && svgContainer.getElement() && component.get('v.isDataLoaded')){
            component.set('v.isPieLoaded', true);
            svgContainer = svgContainer.getElement();
            var allRosters = component.get('v.allRosters');
            var completedRosters = component.get('v.completedRosters');
            var notCompletedRoster = completedRosters + '/' + allRosters;
            if(allRosters == 0){
                allRosters = 1;
            }
            var pie = new d3pie(svgContainer, {
                "size": {
                    "canvasHeight": 190,
                    "canvasWidth": 190,
                    "pieInnerRadius": "80%",
                    "pieOuterRadius": "100%"
                },
                "data": {
                    "sortOrder": "label-asc",
                    "content": [
                        {
                            "label": "Completed",
                            "value": completedRosters,
                            "color": "#8dc16c"
                        },
                        {
                            "label": "No Completed",
                            "value": allRosters-completedRosters,
                            "color": "#d6d6d7"
                        }
                    ]
                },
                "labels": {
                    "outer": {
                        "format": "none",
                        "pieDistance": 20
                    },
                    "inner": {
                        "format": "none"
                    },
                    "mainLabel": {
                        "fontSize": 11
                    },
                    "percentage": {
                        "color": "#999999",
                        "fontSize": 11,
                        "decimalPlaces": 0
                    },
                    "value": {
                        "color": "#cccc43",
                        "fontSize": 11
                    },
                    "lines": {
                        "enabled": true,
                        "color": "#777777"
                    },
                    "truncation": {
                        "enabled": true
                    }
                },
                "effects": {
                    "pullOutSegmentOnClick": {
                        "effect": "none",
                        "speed": 400,
                        "size": 8
                    },
                    "highlightSegmentOnMouseover": false,
                    "highlightLuminosity": 0.01
                },
                "misc": {
                    "colors": {
                        "segmentStroke": "#000000"
                    }
                },
                "callbacks": {
                    "onMouseoverSegment": null,
                    "onMouseoutSegment": null,
                    "onClickSegment": null
                }
            });


        } else{
            window.setTimeout($A.getCallback(function(){
                if(component.isValid()){
                    helper.drawPie(component, helper);
                }
            }), 300);
        }

    }
})