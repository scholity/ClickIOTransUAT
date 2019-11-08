global with sharing class cc_phss_ccLogicCartAddTo extends ccrz.ccLogicCartAddTo
{
	@TestVisible private static final String CLASS_UNIT_OF_MEASURE = 'Class';
	@TestVisible private static final String COMPONENT_KEY = 'component';
	@TestVisible private static final String COMPOSITE_PRODUCTS_KEY = 'compositeProductsS';
	@TestVisible private static final String FEE_INVENTORY_TYPE = 'FEE';
	@TestVisible private static final String ILT_CLASS_FIELD = 'ILT_Class__c';
	@TestVisible private static final String INSTRUCTOR_UNIT_OF_MEASURE = 'Instructor';
	@TestVisible private static final String PRODUCT_PRODUCT_TYPE = 'Product';
	@TestVisible private static final String MAJOR_CART_ITEM_TYPE = 'Major';
	@TestVisible private static final String MINOR_CART_ITEM_TYPE = 'Minor';
	@TestVisible private static final String STUDENT_RATIO_KEY = 'studentRatio';

	@TestVisible
	private static Map<String, Object> productStudentRatioMap = new Map<String, Object>();

	/**
	 * @description Performs logic that occurs after an item is added to a cart
	 *
	 * @param inputData
	 *
	 * @return
	 */
	global override Map<String, Object> concludeItemAdd(Map<String, Object> inputData) {

		Map<String, Object> retData = super.concludeItemAdd(inputData);
		Map<String, Map<String, Object>> productsMap = (Map<String, Map<String, Object>>) retData.get(ccrz.cc_hk_Pricing.PARAM_PRODUCT_MAP);

		ccrz__E_CartItem__c cartItem = (ccrz__E_CartItem__c) inputData.get(ccrz.ccApiCart.CURR_CARTITEM);

		if (cartItem.ccrz__CartItemType__c == MAJOR_CART_ITEM_TYPE) {
			for (String productId : productsMap.keySet()) {
				Map<String, Object> productMap = productsMap.get(productId);
				if (productMap.get(COMPOSITE_PRODUCTS_KEY) instanceof List<Map<String, Object>>) {
					List<Map<String, Object>> compositeProducts = (List<Map<String, Object>>) productMap.get(COMPOSITE_PRODUCTS_KEY);
					for (Map<String, Object> compositeProduct : compositeProducts) {
						String componentSfid = (String) compositeProduct.get(COMPONENT_KEY);
						Object studentRatioObject = compositeProduct.get(STUDENT_RATIO_KEY);
						if (studentRatioObject instanceof Decimal) {
							Decimal studentRatio = (Decimal) studentRatioObject;
							if (String.isNotBlank(componentSfid) && studentRatio != null) {
								productStudentRatioMap.put(componentSfid, studentRatio);
							}
						}
					}
				}
			}
		}

		if (cartItem.ccrz__cartItemType__c == MINOR_CART_ITEM_TYPE && cartItem.ccrz__ProductType__c == PRODUCT_PRODUCT_TYPE) {
			if (cartItem.ccrz__UnitOfMeasure__c == CLASS_UNIT_OF_MEASURE) {
				ccrz__E_Product__c product = getProduct((String) cartItem.ccrz__Product__c);
				if (product != null && product.ccrz__InventoryType__c == FEE_INVENTORY_TYPE) {
					cartItem.ccrz__Quantity__c = 1;
					cartItem.ccrz__SubAmount__c = cartItem.ccrz__Price__c;
				}

			} else if (cartItem.ccrz__UnitOfMeasure__c == INSTRUCTOR_UNIT_OF_MEASURE) {
				Object studentRatioObject = productStudentRatioMap.get(cartItem.ccrz__Product__c);
				if (studentRatioObject != null) {
					Decimal studentRatio = (Decimal) studentRatioObject;
					cartItem.ccrz__Quantity__c = calculateKitCartItemQuantity(cartItem.ccrz__Quantity__c, studentRatio);
					cartItem.ccrz__SubAmount__c = calculateSubAmount(cartItem.ccrz__Price__c, cartItem.ccrz__Quantity__c);
				}
			}
		}

        return retData;
	}

	/**
	 * @description Overrides the price if needed for community classes
	 *
	 * @param inputData
	 *
	 * @return
	 */
	global override Map<String, Object> handlePricing(Map<String, Object> inputData) {
		Map<String, Object> retData = super.handlePricing(inputData);

		Map<String, Object> currLine = (Map<String, Object>) inputData.get(ccrz.ccApiCart.CURR_LINE_DATA);
		String classId = (String) currLine.get(ILT_CLASS_FIELD);
		if (String.isNotBlank(classId)) {
			redwing__ILT_Class__c iltClass = getILTClass(classId);
			if (iltClass != null && iltClass.Price_Override__c != null) {
				ccrz__E_CartItem__c cartItem = (ccrz__E_CartItem__c) inputData.get(ccrz.ccApiCart.CURR_CARTITEM);
				cartItem.ccrz__Price__c = iltClass.Price_Override__c;
			}
		}

		return retData;
	}

	/**
	 * @description Fetches the product based on its ID
	 *
	 * @param productId
	 *
	 * @return
	 */
	private static ccrz__E_Product__c getProduct(String productId) {
		return [
				SELECT ccrz__InventoryType__c
				  FROM ccrz__E_Product__c
				 WHERE Id = :productId
		];
	}


	private static redwing__ILT_Class__c getILTClass(String classId) {
		return [
				SELECT Id,
					   Price_Override__c
				  FROM redwing__ILT_Class__c
				 WHERE Id = :classId
		];
	}


	/**
	 * @description Calculates the proper quantity of a Kit cart item
	 *
	 * @param quantity
	 * @param studentRatio
	 *
	 * @return
	 */
	private static Decimal calculateKitCartItemQuantity(Decimal quantity, Decimal studentRatio) {
		if (studentRatio == 0) {
			return quantity;
		}

		Decimal qty = quantity / studentRatio;
		if (qty < 0) {
			qty = Math.floor(qty);
		} else {
			qty = Math.ceil(qty);
		}

		return qty;
	}

	/**
	 * @description Calculates the sub amount from the price and quantity
	 *
	 * @param price
	 * @param quantity
	 *
	 * @return
	 */
	private static Decimal calculateSubAmount(Decimal price, Decimal quantity) {
		return (price * quantity).setScale(2, System.RoundingMode.HALF_EVEN);
	}


	/**
	 * @description Adds custom cart item fields to cart item data
	 *
	 * @param inputData
	 *
	 * @return
	 */
	global override Map<String, Object> setCartItemFields(Map<String, Object> inputData) 
	{
		Map<String, Object> outputData = super.setCartItemFields(inputData);
		
        ccrz__E_CartItem__c cartItem = (ccrz__E_CartItem__c) outputData.get(ccrz.ccApiCart.CURR_CARTITEM); 
		Map<String, Object> lineData = (Map<String, Object>) outputData.get(ccrz.ccApiCart.CURR_LINE_DATA);

		// If available, add the ILT Class ID
		if (lineData.containsKey(ILT_CLASS_FIELD)) {
			Id iltClassId = Id.valueOf((String) lineData.get(ILT_CLASS_FIELD));
			if (iltClassId != null) {
				cartItem.ILT_Class__c = iltClassId;
			}
		}

		return outputData; 
    }
}