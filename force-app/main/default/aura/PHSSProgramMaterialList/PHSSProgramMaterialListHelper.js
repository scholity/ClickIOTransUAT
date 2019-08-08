({
	filterMaterials: function(component, event) {
		var searchString = component.find('searchInput').elements[0].value;
		var materials = component.get('v.materials');
		var filterField = component.get('v.filterField');
		var selectedFilter = component.find('filterSelect').elements[0].value;
		var currentDisplayNum = component.get('v.currentDisplayNum');

		//component.set('v.showMoreButton', false);

		var filteredMaterials = [];
		var re = null;
		if(searchString && searchString.length>0){
			re = new RegExp(searchString,'gi'); //case insensitive search
		}
		for(var i=0; i< materials.length; i++){
			if(materials[i].Material_Name__c && materials[i].Material_Name__c.length &&	//check if material name is present and non empty
				(
					(re == null || re.test(materials[i].Material_Name__c)) //check for search string
					&&
					(!(selectedFilter && selectedFilter.length) //if no filter selected skip this condition
						||
					materials[i][filterField] === selectedFilter) //check for filters if filter selected
				)) {
				filteredMaterials.push(materials[i]);
			}
		}
		// if(filteredMaterials.length>currentDisplayNum){
		// 	component.set('v.showMoreButton', true);
		// }else{
		// 	component.set('v.showMoreButton', false);
		// }
		component.set('v.showMoreButton', false);
		if(re || (selectedFilter && selectedFilter.length)){
			// component.set('v.filteredMaterials', filteredMaterials.slice(0,currentDisplayNum));
			component.set('v.filteredMaterials', filteredMaterials);
		}else{
			//if no search string and no filter selected display all results
			// component.set('v.filteredMaterials', materials.slice(0,currentDisplayNum));
			component.set('v.filteredMaterials', materials);
		}
	},
	formatModifiedDate: function(materials){
		var _this = this;
		materials.forEach(function(value) {
			if(!value.LastModifiedDate) {
				value.LastModifiedDate = '';
			} else {
				var lastModifiedDate = new Date(value.LastModifiedDate);
				value.LastModifiedDate = [
					_this.addZeroPrefix(String(lastModifiedDate.getMonth() + 1)),
					_this.addZeroPrefix(String(lastModifiedDate.getDate())),
					String(lastModifiedDate.getFullYear()).slice(2)
				].join('/');
			}
		});
	},
	addZeroPrefix: function(value){
		// return value.length === 2 ? value : ("0" + value);
		return value;
	},
	filterByTags: function(materials, tagCsv){
		if($A.util.isEmpty(tagCsv)){
			return materials;
		} else {
			var tags = [];
			tagCsv.split(',').forEach(function iterate(tag){
				tags.push(tag.trim().toLowerCase());
			});
			var filteredMaterials = [];
			materials.forEach(function iterage(material){
				if(!$A.util.isEmpty(material.Content_Tags__c)){
					var materialTags = material.Content_Tags__c.split(',');
					var found = false;
					for(var idx in materialTags){
						var materialTag = materialTags[idx].trim().toLowerCase();
						for(var mIdx in tags){
							if(tags[mIdx] === materialTag){
								filteredMaterials.push(material);
								found = true;
								break;
							}
						}
						if(found){
							break;
						}
					}
				}
			});
			return filteredMaterials;
		}
	},
	processMaterials: function(component, materials) {
		var category = component.get('v.category');
		var initalDisplayNum = parseInt(component.get('v.initalDisplayNum'), 10);
		if(isNaN(initalDisplayNum)){
			initalDisplayNum = 10;
		}

		component.set('v.initalDisplayNum',initalDisplayNum);
		component.set('v.currentDisplayNum',initalDisplayNum);

		var type = component.get('v.type');
		if(type && type.length && type !== 'All'){
			type = type.split('+');
		}else{
			type = null;
		}
		var myMaterials = [];
		var filtersObject = {};
		var filterField = component.get('v.filterField'); //can be changed later in .cmp (no subtype field for the time being)

		for(var i=0; i<materials.length; i++){
			if(category !== 'All' && materials[i].Category__c !== category){
				continue;
			}
			if((type === null || type.indexOf(materials[i].Type__c) >= 0)){
				myMaterials.push(materials[i]);
				filtersObject[materials[i][filterField]] = true; //adding filters to the list
			}
		}
		myMaterials = this.filterByTags(myMaterials, component.get('v.tags'));
		this.formatModifiedDate(myMaterials);
		if(myMaterials.length>initalDisplayNum){
			component.set('v.showMoreButton', true);
		}else{
			component.set('v.showMoreButton', false);
		}
		component.set('v.filtersList', Object.keys(filtersObject));
		component.set('v.materials', myMaterials);
		component.set('v.filteredMaterials', myMaterials.slice(0,initalDisplayNum));
	}
})