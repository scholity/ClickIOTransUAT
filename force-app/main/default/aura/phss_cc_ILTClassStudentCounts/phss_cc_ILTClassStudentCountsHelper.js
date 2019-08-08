({
	validateNumberOfEvaluations : function(component) {
		var validationError = null;
		var quantity = 0;

		var numberOfSuccessfulEvals = component.get("v.numberOfSuccessfulEvaluations");
		if (numberOfSuccessfulEvals == null || numberOfSuccessfulEvals == "" || isNaN(numberOfSuccessfulEvals)) {
			numberOfSuccessfulEvals = 0;
		} else {
			numberOfSuccessfulEvals = parseInt(numberOfSuccessfulEvals);
			if (numberOfSuccessfulEvals < 0) {
				validationError = "invalidQuantity";
			}
		}

		var numberOfUnsuccessfulEvals = component.get("v.numberOfUnsuccessfulEvaluations");
		if (numberOfUnsuccessfulEvals == null || numberOfUnsuccessfulEvals == "" || isNaN(numberOfUnsuccessfulEvals)) {
			numberOfUnsuccessfulEvals = 0;
		} else {
			numberOfUnsuccessfulEvals = parseInt(numberOfUnsuccessfulEvals);
			if (numberOfUnsuccessfulEvals < 0) {
				validationError = "invalidQuantity";
			}
		}

		var numberOfNonEvals = component.get("v.numberOfNonEvaluations");
		if (numberOfNonEvals == null || numberOfNonEvals == "" || isNaN(numberOfNonEvals)) {
			numberOfNonEvals = 0;
		} else {
			numberOfNonEvals = parseInt(numberOfNonEvals);
			if (numberOfNonEvals < 0) {
				validationError = "invalidQuantity";
			}
		}

		if (validationError == null) {
			var totalEvals = component.get("v.totalEvaluations");
			if (totalEvals == null || totalEvals == "" || isNaN(totalEvals)) {
				totalEvals = 0;
			}

			var count = parseInt(numberOfSuccessfulEvals) + parseInt(numberOfUnsuccessfulEvals) + parseInt(numberOfNonEvals);
			var total = parseInt(totalEvals);
			if (count < total) {
				validationError = "insufficientQuantity";
				quantity = total - count;
			} else if (count > total) {
				validationError = "excessiveQuantity";
				quantity = count - total;
			}
		}

		component.set("v.isValid", validationError == null);
		component.set("v.validationState", validationError);
		component.set("v.quantityOverOrUnder", quantity);
	}
})