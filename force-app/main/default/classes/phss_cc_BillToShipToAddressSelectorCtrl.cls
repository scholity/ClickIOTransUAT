/**
 * Created by dgajwani on 10/28/18.
 */

public with sharing class phss_cc_BillToShipToAddressSelectorCtrl {

    @AuraEnabled
    public static Map<String, Object> fetchAddresses(String opportunitySfid, String addressType) {
        Map<String, Object> fetchAddressResponse;
        try {
            fetchAddressResponse = phss_cc_AddressBookUtil.fetchAddresses(opportunitySfid, addressType);
        } catch (Exception e) {
            fetchAddressResponse = phss_cc_Exception.getErrorMessageMap(e.getMessage());
        }
        return fetchAddressResponse;
    }

    @AuraEnabled
    public static Map<String, Object> addAddressToCart(String opportunitySfid, String addressType, String selectedContactAddressSfid) {
        Map<String, Object> addAddressToCartResponse;
        try {
            addAddressToCartResponse = phss_cc_CartUtil.addAddressToCart(opportunitySfid, addressType, selectedContactAddressSfid);
        } catch (Exception e) {
            addAddressToCartResponse = phss_cc_Exception.getErrorMessageMap(e.getMessage());
        }
        return addAddressToCartResponse;
    }

    @AuraEnabled
    public static Map<String, Object> getCurrentAddressesFromCart(String opportunitySfid) {
        Map<String, Object> getCurrentAddressesFromCartResponse;
        try {
            getCurrentAddressesFromCartResponse = phss_cc_CartUtil.getCurrentAddressesFromCart(opportunitySfid);
        } catch (Exception e) {
            getCurrentAddressesFromCartResponse = phss_cc_Exception.getErrorMessageMap(e.getMessage());
        }
        return getCurrentAddressesFromCartResponse;
    }

    @AuraEnabled
    public static PHSS_AddressFormWrapper initAddrFormWrapper() {
        PHSS_AddressFormWrapper addrWrap = new PHSS_AddressFormWrapper();
        return addrWrap;
    }

    @AuraEnabled
    public static ccrz__E_ContactAddr__c saveNewShippingAddr(String addrJson, String oppId) {
        PHSS_AddressFormWrapper addrWrap = (PHSS_AddressFormWrapper)JSON.deserialize(addrJson, PHSS_AddressFormWrapper.class);

        ccrz__E_ContactAddr__c conAddr = new ccrz__E_ContactAddr__c();
        conAddr.ccrz__FirstName__c = addrWrap.firstName;
        conAddr.ccrz__LastName__c = addrWrap.lastName;
        conAddr.ccrz__Email__c = addrWrap.email;
        conAddr.ccrz__DaytimePhone__c = addrWrap.phone;
        conAddr.ccrz__AddressFirstline__c = addrWrap.addressFirstLine;
        conAddr.ccrz__AddressSecondline__c = addrWrap.addressSecondLine;
        conAddr.ccrz__City__c = addrWrap.city;
        conAddr.ccrz__State__c = addrWrap.state;
        conAddr.ccrz__Country__c = addrWrap.country;
        conAddr.ccrz__PostalCode__c = addrWrap.postalCode;
        insert conAddr;

        List<Opportunity> opp = [Select Id, AccountId, Account.Name From Opportunity Where Id = :oppId];

        ccrz__E_AccountAddressBook__c accAddr = new ccrz__E_AccountAddressBook__c();
        accAddr.Name = opp[0].Account.Name;
        accAddr.ccrz__Account__c = opp[0].AccountId;
        accAddr.ccrz__AccountId__c = opp[0].AccountId;
        accAddr.ccrz__AddressType__c = 'Shipping';
        accAddr.ccrz__E_ContactAddress__c = conAddr.Id;
        accAddr.ccrz__Default__c = true;
        insert accAddr;

        // Remove defaults of other addresses
        List<ccrz__E_AccountAddressBook__c> defaultAddr = [Select Id,ccrz__Default__c, ccrz__AddressType__c From  ccrz__E_AccountAddressBook__c Where ccrz__Default__c = true And Id != :accAddr.Id And ccrz__AddressType__c = 'Shipping'];
        for(ccrz__E_AccountAddressBook__c addr : defaultAddr) {
            addr.ccrz__Default__c = false;
        }
        update defaultAddr;

        return conAddr;
    }

    @AuraEnabled
    public static Map<String, Object> fetchAddressFromAccount(String opportunitySfid) {
        Map<String, Object> fetchAddressResponse = new Map<String, Object>();
        try {
            List<Opportunity> opp = [Select Id, AccountId, Account.Name, Account.ShippingAddress, Account.ShippingStreet, Account.ShippingCity,
                    Account.ShippingState, Account.ShippingCountry,
                    Account.ShippingPostalCode,
                    Account.BillingAddress, Account.BillingStreet, Account.BillingCity,
                    Account.BillingState, Account.BillingCountry,
                    Account.BillingPostalCode
            From Opportunity Where Id = :opportunitySfid];

            if(opp[0].Account.ShippingAddress != null) {
                ccrz__E_ContactAddr__c conShipAddr = new ccrz__E_ContactAddr__c();
                conShipAddr.ccrz__FirstName__c = opp[0].Account.Name;
                conShipAddr.ccrz__LastName__c = 'Address';
                conShipAddr.ccrz__AddressFirstline__c = opp[0].Account.ShippingStreet;
                conShipAddr.ccrz__City__c = opp[0].Account.ShippingCity;
                conShipAddr.ccrz__State__c = opp[0].Account.ShippingState;
                conShipAddr.ccrz__Country__c = opp[0].Account.ShippingCountry;
                conShipAddr.ccrz__PostalCode__c = opp[0].Account.ShippingPostalCode;
                insert conShipAddr;

                ccrz__E_AccountAddressBook__c accShipAddr = new ccrz__E_AccountAddressBook__c();
                accShipAddr.Name = opp[0].Account.Name;
                accShipAddr.ccrz__Account__c = opp[0].AccountId;
                accShipAddr.ccrz__AccountId__c = opp[0].AccountId;
                accShipAddr.ccrz__AddressType__c = 'Shipping';
                accShipAddr.ccrz__E_ContactAddress__c = conShipAddr.Id;
                accShipAddr.ccrz__Default__c = true;
                insert accShipAddr;

                fetchAddressResponse.put('AddressType', 'Shipping');
                fetchAddressResponse.put('AddressList', conShipAddr.Id);
                Map<String,Object> conShipAddrMap = new Map<String,Object>();
                Map<String,Object> addrMap = new Map<String,Object>();

                addrMap.put('sfid',conShipAddr.Id);
                addrMap.put('firstName',conShipAddr.ccrz__FirstName__c);
                addrMap.put('ownerId',conShipAddr.OwnerId);
                addrMap.put('sfdcName',conShipAddr.Name);
                addrMap.put('addrReadOnly',false);
                addrMap.put('addressFirstline',conShipAddr.ccrz__AddressFirstline__c);
                addrMap.put('city',conShipAddr.ccrz__City__c);
                addrMap.put('state',conShipAddr.ccrz__State__c);
                addrMap.put('country',conShipAddr.ccrz__Country__c);
                addrMap.put('postalCode',conShipAddr.ccrz__PostalCode__c);
                conShipAddrMap.put(conShipAddr.Id,addrMap);
                fetchAddressResponse.put('AddressMap', conShipAddrMap);
            }

            if(opp[0].Account.BillingAddress != null) {
                ccrz__E_ContactAddr__c conBillAddr = new ccrz__E_ContactAddr__c();
                conBillAddr.ccrz__FirstName__c = opp[0].Account.Name;
                conBillAddr.ccrz__LastName__c = 'Address';
                conBillAddr.ccrz__AddressFirstline__c = opp[0].Account.BillingStreet;
                conBillAddr.ccrz__City__c = opp[0].Account.BillingCity;
                conBillAddr.ccrz__State__c = opp[0].Account.BillingState;
                conBillAddr.ccrz__Country__c = opp[0].Account.BillingCountry;
                conBillAddr.ccrz__PostalCode__c = opp[0].Account.BillingPostalCode;
                insert conBillAddr;

                ccrz__E_AccountAddressBook__c accBillAddr = new ccrz__E_AccountAddressBook__c();
                accBillAddr.Name = opp[0].Account.Name;
                accBillAddr.ccrz__Account__c = opp[0].AccountId;
                accBillAddr.ccrz__AccountId__c = opp[0].AccountId;
                accBillAddr.ccrz__AddressType__c = 'Billing';
                accBillAddr.ccrz__E_ContactAddress__c = conBillAddr.Id;
                accBillAddr.ccrz__Default__c = true;
                insert accBillAddr;

            }
        } catch (Exception e) {
            fetchAddressResponse = phss_cc_Exception.getErrorMessageMap(e.getMessage());
        }
        return fetchAddressResponse;
    }
}