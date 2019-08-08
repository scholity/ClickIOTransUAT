function formatPhone(a){a.value=trim(a.value);var b=a.value,c="",d=-1;if(0<b.length&&"+"!=b.charAt(0)){var e=0;"1"==b.charAt(0)&&(b=b.substring(1,b.length));for(i=0;i<b.length;i++){var f=b.charAt(i);"0"<=f&&"9">=f&&(0==e?c+="(":3==e?c+=") ":6==e&&(c+="-"),c+=f,e++);if(!("0"<=f&&"9">=f)&&" "!=f&&"-"!=f&&"."!=f&&"("!=f&&")"!=f){d=i;break}}0<=d&&(c+=" "+b.substring(d,b.length));10==e&&40>=c.length&&(a.value=c)}return!0} 
  
function checkPhoneField() {
    if (j$('[id*=searchFieldPhone]').val().length ==0) {
        //disable ghost button disabled="disabled"
        j$('[id*=ghostButton]').attr('disabled', 'disabled');
        j$('[id*=ghostButton]').css('color', 'gray');
    } else {
        //enable ghost button
        j$('[id*=ghostButton]').removeAttr('disabled');
        j$('[id*=ghostButton]').css('color', '#333');
    }
}

function evtTabChanged(tabName) {	
	selectedTab = tabName;
	
	// if user clicked the Quick Create tab then copy
	//   values from the Search tab to the Quick Create tab
	j$('[id*=qcFieldFirstName]').val( j$('[id*=searchFieldFirstName]').val() );
	j$('[id*=qcFieldLastName]').val( j$('[id*=searchFieldLastName]').val() );
	j$('[id*=qcFieldPhone]').val( j$('[id*=searchFieldPhone]').val() );
	j$('[id*=qcFieldEmail]').val( j$('[id*=searchFieldEmail]').val() );
	j$('[id*=qcFieldCity]').val( j$('[id*=searchFieldCity]').val() );
	j$('[id*=qcFieldState]').val( j$('[id*=searchFieldState]').val() );
	j$('[id*=qcFieldZip]').val( j$('[id*=searchFieldZip]').val() );
	
	 
	
	
};
