({
    doInit: function(component, event, helper) {
        helper.checkPreviewAvailabilty(component);
        component.set('v.PdfStatus', '');
        helper.checkDocumentType(component);
    },
    doCleanup:  function(component, event, helper) {
    	//cleanup in case of closing the pdf preview before the pdf loads
    	var pdfVars = component.get('v.pdfVars');
    	if(pdfVars && pdfVars.pdfLoadingPromise){
    		pdfVars.pdfLoadingPromise.destroy();
    	}
    },
    scriptsLoaded: function(component, event, helper) {
        var material = component.get('v.materialObject');
        if (!material.Disable_Community_Preview__c && material.ContentVersionFileType__c === 'PDF' && material.Type__c === 'Document' && helper.checkPreviewAvailabilty(component)) {
            var canvas = component.find('pdf-canvas').getElement();
            var pdfVars = {
                pdfDoc: null,
                pageNum: 1,
                pageRendering: false,
                pageNumPending: null,
                scale: 0.8,
                canvas: canvas,
                ctx: canvas.getContext('2d')
            };
            component.set('v.pdfVars', pdfVars);
            component.set('v.PdfStatus', 'Loading');
            var progress = 0;
            
            console.log("URL$$$"+component.get("v.url"));
            console.log(material.ContentVersionLink__c);
            
            var url 		 = component.get("v.url");
                        
            if(url === "")
            {
                url 		 = $A.get("$Label.c.PHSS_IC_Community_URL_Domain");
            }
            
            var Servlet 		 = $A.get("$Label.c.PHSS_IC_Community_URL_Content_Version_Servlet");
            var ContentVersionID = material.ContentVersionID__c;
            var finalURL 		 = url+Servlet+ContentVersionID;
            
            console.log(finalURL);

            //pdfVars.pdfLoadingPromise = PDFJS.getDocument(material.ContentVersionLink__c);
            pdfVars.pdfLoadingPromise = PDFJS.getDocument(finalURL);

            pdfVars.pdfLoadingPromise.onProgress = function(progressData) {
                var progressNew = Math.floor((progressData.loaded / progressData.total)*100);
                if(progress !== progressNew){
                    progress = progressNew;
                    component.set('v.PdfStatus', 'Loading: '+progress+'%');
                }
            };

            pdfVars.pdfLoadingPromise.then(function(pdfDoc_) {
    	    	if(!component.isValid()){
    	    		//in case of closing the pdf preview before the pdf loads
		    		return;
		    	}

                pdfVars.pdfDoc = pdfDoc_;
                pdfVars.pdfLoadingPromise = null;

                component.set('v.PdfStatus', 'Done');
		    	component.set('v.PdfPageNum', pdfVars.pageNum);
		    	component.set('v.PdfPages', pdfVars.pdfDoc.numPages);
                component.set('v.pdfVars', pdfVars);

                helper.renderPage(component,pdfVars.pageNum);
            },function(error){
            	//the only error I got this far is missing pdf (broken link)
            	component.set('v.PdfStatus', 'Load failed');
            });

            //component.set('v.pdfVars', pdfVars); //will it work ?
        }
    },
    nextPdfPage: function(component, event, helper) {
    	if(!component.isValid()){
    		return;
    	}
        helper.onNextPage(component);
    },
    prevPdfPage: function(component, event, helper) {
    	if(!component.isValid()){
    		return;
    	}
        helper.onPrevPage(component);
    }
})