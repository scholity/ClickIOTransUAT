/* START applesearch object */
        
if (!applesearch)    var applesearch = {};

applesearch.init = function ()
{
    // add applesearch css for non-safari, dom-capable browsers
    if ( navigator.userAgent.toLowerCase().indexOf('safari') < 0  && document.getElementById )
    {
        this.clearBtn = false;
        
        // add style sheet if not safari
        var dummy = document.getElementById("dummy_css");
        if (dummy)    dummy.href = "applesearch.css";
    }
}

// called when on user input - toggles clear fld btn
applesearch.onChange = function (fldID, btnID)
{
    // check whether to show delete button
    var fld = document.getElementById( fldID );
    var btn = document.getElementById( btnID );
    if (fld.value.length > 0 && !this.clearBtn)
    {
        btn.style.background = "white url('srch_r_f2.gif') no-repeat top left";
        btn.fldID = fldID; // btn remembers it's field
        btn.onclick = this.clearBtnClick;
        this.clearBtn = true;
    } else if (fld.value.length == 0 && this.clearBtn)
    {
        btn.style.background = "white url('srch_r.gif') no-repeat top left";
        btn.onclick = null;
        this.clearBtn = false;
    }
}


// clears field
applesearch.clearFld = function (fldID,btnID)
{
    var fld = document.getElementById( fldID );
    fld.value = "";
    this.onChange(fldID,btnID);
}

// called by btn.onclick event handler - calls clearFld for this button
applesearch.clearBtnClick = function ()
{
    applesearch.clearFld(this.fldID, this.id);
}

/* END applesearch object */

/* ikd what apple search is - michael */


$(function(){
    if ( $('#SearchString')) {
        Searcher.initialize();
        tabs.initialize();
    }
});


var Searcher = {
    initialize : function(){
        this.searchbox = $('#SearchString');
        this.searchbox.keyup(function() {
            Searcher.autocomplete();
        });
        this.searchbox.blur(function() {
            Searcher.hide();
        });
    },
    autocomplete: function(term){
        var loading = false;
        var sstr = this.searchbox.val();
        var divtarget = $('#Search_Suggestions');
        var ultarget = $('#search_results');
        var minchars = 2;
        if(sstr.length > minchars && loading != true) {
            loading = true;
            $.get("/search/", {'SearchString':sstr }, function(data){ ultarget.html(data); loading = false;}, 'html' );
            divtarget.show();
            Coords = this.searchbox.offset();
            var ycal = (Coords.top + 25)+"px";
            var xcal = (Coords.left - 1)+"px";
            divtarget.css({'top' : ycal, 'left' : xcal, 'position':'absolute'});
        }
    },
    hide: function(term){
        $("#Search_Suggestions").delay(800).fadeOut(200);
    }
}


var tabs = {
    initialize : function(){
	$(".tab_content").hide(); //Hide all content
	$("ul.tabs li:first").addClass("active").show(); //Activate first tab
	$(".tab_content:first").show(); //Show first tab content
        $("ul.tabs li").click( function() { //m-adds call to function on click same as bind
            tabs.tabclick(this); //m-references function in tabs that does the work 'this' is the tab getting clicked
            return false;
        });
    },
    tabclick: function(tab){ //m-tab is the 'this' from the line above we can use the word tab its more descriptive
	$("ul.tabs li").removeClass("active"); //Remove any "active" class
        $(tab).addClass("active"); //Add "active" class to selected tab
        $(".tab_content").hide(); //Hide all tab content
        var activeTab = $(tab).find("a").attr("href"); //Find the rel attribute value to identify the active tab + content
        $(activeTab).fadeIn(); //Fade in the active content
    }
}




function inputCheckIn(obj)
{
	
	if((obj.value == 'IC User Name' || obj.value == 'Password') || obj.value == 'Enter ZIP Code'){
		obj.value = ''
	}
	return true
}
