({
    checkPreviewAvailabilty: function(component) {
        // var isSafari = /^((?!chrome|android).)*safari/i.test(navigator.userAgent);
        var isSafari = new RegExp('^((?!chrome|android).)*safari', 'i').test(navigator.userAgent);
        var materialType = component.get('v.materialObject.Type__c');
        var previewAvailable = false;
        switch (materialType) {
            case 'Video':
                if (isSafari) {
                	//safari uses problematic quicktime player for video tags, so we don't show preview
                    previewAvailable = false;
                } else {
                    previewAvailable = true;
                }
                break;
            case 'Document':
                //TODO: need a way of telling if the document is pdf or another type then we should disable the preview
                previewAvailable = true;
                break;
            default:
        }
        component.set('v.previewAvailable', previewAvailable);
        return previewAvailable;
    },
    renderPage: function(component, num) {//pdf rendering
    	if(!component.isValid()){
    		//in case of closing the pdf preview before the pdf loads
    		return;
    	}
    	var pdfVars = component.get('v.pdfVars');
        pdfVars.pageRendering = true;
        // Using promise to fetch the page
        pdfVars.pdfDoc.getPage(num).then(function(page) {
            var viewport = page.getViewport(pdfVars.scale);
            pdfVars.canvas.height = viewport.height;
            pdfVars.canvas.width = viewport.width;
            // Render PDF page into canvas context
            var renderContext = {
                canvasContext: pdfVars.ctx,
                viewport: viewport
            };
            var renderTask = page.render(renderContext);
            // Wait for rendering to finish
            renderTask.promise.then(function() {
                pdfVars.pageRendering = false;
                if (pdfVars.pageNumPending !== null) {
                    // New page rendering is pending
                    this.renderPage(component,pdfVars.pageNumPending);
                    pdfVars.pageNumPending = null;
                }
            });
        });
    },
    queueRenderPage: function(component, num) {//pdf page queuing 
    	if(!component.isValid()){
    		//in case of closing the pdf preview before the pdf loads
    		return;
    	}
    	var pdfVars = component.get('v.pdfVars');
        if (pdfVars.pageRendering) {
            pdfVars.pageNumPending = num;
        } else {
            this.renderPage(component,num);
        }
    },
    onPrevPage: function(component) {
    	if(!component.isValid()){
    		//in case of closing the pdf preview before the pdf loads
    		return;
    	}
    	var pdfVars = component.get('v.pdfVars');
        if (pdfVars.pageNum <= 1) {
            return;
        }
        pdfVars.pageNum--;
        component.set('v.PdfPageNum', pdfVars.pageNum);
        this.queueRenderPage(component,pdfVars.pageNum);
    },
    onNextPage: function(component) {
    	if(!component.isValid()){
    		//in case of closing the pdf preview before the pdf loads
    		return;
    	}    	
    	var pdfVars = component.get('v.pdfVars');
        if (pdfVars.pageNum >= pdfVars.pdfDoc.numPages) {
            return;
        }
        pdfVars.pageNum++;
        component.set('v.PdfPageNum', pdfVars.pageNum);
        this.queueRenderPage(component,pdfVars.pageNum);
    },
    checkDocumentType: function(component){
        var materialObject = component.get('v.materialObject');
        if(materialObject.ContentVersionFileType__c === 'WORD' || materialObject.ContentVersionFileType__c === 'WORD_X'){
            component.set('v.iconName', 'word');
        } else if (materialObject.ContentVersionFileType__c === 'POWER_POINT' || materialObject.ContentVersionFileType__c === 'POWER_POINT_X'){
            component.set('v.iconName', 'ppt');
        } else {
            component.set('v.iconName', 'unknown');
        }
    }
})