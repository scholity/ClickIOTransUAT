({
    doInit: function(component, event, helper) {
        var registerIframeEvent = (function (eventHandler) {
            var eventMethod = window.addEventListener ? 'addEventListener' : 'attachEvent'; 
            var eventer = window[eventMethod]; 
            
            var messageEvent = eventMethod == 'attachEvent' ? 'onmessage' : 'message'; 
            
            if (eventHandler) {
                helper.messageHandler = eventHandler;
                eventer(messageEvent, eventHandler, false); 
            }
        })(function (event) { 
            var data = event.data,
                message = data.message;
            
            if (message === 'cancel') {
                helper.closeModal();
            } else if (message === 'done') {
                helper.closeModal();
            } else if (message === 'loaded') {
                helper.hideModalLoading();
            }

            helper.showToast(message);
        });
    },
    doDestroy: function (component, event, helper) {
        var eventMethod = window.removeEventListener ? 'removeEventListener' : 'detachEvent'; 
        var eventer = window[eventMethod]; 
        
        var messageEvent = eventMethod == 'detachEvent' ? 'onmessage' : 'message'; 

        if (helper.messageHandler) {
            eventer(messageEvent, helper.messageHandler);
        }
        
    },
    openBookingGridModal: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var ifmsrc = '/apex/skedFullServiceBookingGrid?rootRecordId='+ recordId;
        
        helper.registerToastMessages({
            done: {
                type: 'success',
                message: 'Training event has been scheduled successfully.'
            }
        });

        helper.showModal(ifmsrc);
    },
    openAllocationModal: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var ifmsrc = '/apex/skedScheduleAllocation?rootRecordId='+ recordId;
        
        helper.registerToastMessages({
            done: {
                type: 'success',
                message: 'Resources have been allocated successfully.'
            }
        });

        helper.showModal(ifmsrc);
    },
    openJobsCancellationModal: function (component, event, helper) {
        var recordId = component.get("v.recordId");
        var ifmsrc = '/apex/skedTrainingEventCancellation?rootRecordId='+ recordId;

        helper.registerToastMessages({
            done: {
                type: 'success',
                message: 'Scheduled jobs for this Traning Event have been cancelled successfully.'
            }
        });
        
        helper.showModal(ifmsrc);
    }
})