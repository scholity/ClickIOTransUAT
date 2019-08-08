({
    showModal: function(ifmsrc) {
        var modalIframe;
        
        modalIframe = document.createElement('iframe');
        modalIframe.setAttribute('src', ifmsrc);
        modalIframe.setAttribute('id', 'ifmFullServiceBookingGrid');
        modalIframe.style.cssText = [
            'border: none',
            'transition: opacity .2s linear', 
            'opacity: 0',
            'background-image: url(/resource/sked_ARC_Vendors/slds/images/spinners/slds_spinner_brand.gif)',
            'background-color .2s linear',
            'background-color: rgba(43,40,38,.6)',
            'background-size: 64px',
            'background-repeat: no-repeat',
            'background-position: center',
            'position: fixed',
            'top: 0',
            'left: 0',
            'right: 0',
            'bottom: 0',
            'padding: 0',
            'margin: 0',
            'height: 100%',
            'width: 100%',
            'z-index: 7001'].join(';');
        document.body.appendChild(modalIframe);
        document.body.style.overflow = 'hidden';
        
        setTimeout(function () {
            modalIframe.style.opacity = 1;
        });
    },
    hideModalLoading: function() {
        var modalIframe = document.getElementById('ifmFullServiceBookingGrid');
        if (modalIframe) {
            modalIframe.style['background-image'] = '';            
        }
    },
    closeModal: function () {
        var modalIframe = document.getElementById('ifmFullServiceBookingGrid');
        if (modalIframe) {
            modalIframe.style.opacity = 0;
            setTimeout(function () {
                if (modalIframe) {
                    document.body.style.overflow = '';
                    //document.body.removeChild(modalIframe);
                    try {
                        modalIframe.parentNode.removeChild(modalIframe);
                    } catch (ex) {
                        modalIframe = document.getElementById('ifmFullServiceBookingGrid');

                        if (modalIframe && modalIframe.parentNode) {
                            modalIframe.parentNode.removeChild(modalIframe);
                        }
                    }
                    
                }
            }, 200);
        }
    },
    registerToastMessages: function (toastMessages) {
        this.toastMessages = toastMessages;
    },
    showToast: function (messageKey) {
        var toastMessage;
        var toastMesageParams;

        if (this.toastMessages) {
            toastMesageParams = this.toastMessages[messageKey];

            if (toastMesageParams) {
                toastMessage = $A.get('e.force:showToast');
                toastMessage.setParams(toastMesageParams);
                toastMessage.fire();
            }
        }
    }
})