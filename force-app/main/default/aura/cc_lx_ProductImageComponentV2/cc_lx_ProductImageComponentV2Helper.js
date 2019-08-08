({
    getStaticResource : function(media) {
        let srName = media.staticResourceName;
        // remove c__ if it exists
        if (media.staticResourceName.indexOf('c__') == 0) {
            srName = media.staticResourceName.substr(3);
        }

        let url = $A.get('$Resource.' + srName) + '/' + media.filePath;
        return url;
    },
    doesImageExist : function(image_url) {
        var http = new XMLHttpRequest();

        http.open('HEAD', image_url, false);
        http.send();
        return http.status != 404;
    }
})