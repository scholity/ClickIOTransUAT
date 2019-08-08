/**
 * Created by dgajwani on 10/28/18.
 */

public with sharing class phss_cc_AddressBookUtil {

    private static final String ADDRESS_SFID_KEY = 'sfid';
    @TestVisible private static final String ADDRESS_TYPE = 'AddressType';
    @TestVisible private static final String ADDRESS_LIST = 'AddressList';
    @TestVisible private static final String ADDRESS_MAP = 'AddressMap';

    private static final String ADDRESS_CALLOUT_FAILED = 'Address Callout Failed.';
    private static final String FAILED_TO_FETCH_ADDRESSES = 'Failed to fetch addresses.';
    private static final String FAILED_TO_CREATE_A_ADDRESS_MAP = 'Failed to create a address Map';


    /**
     * @description Returns the result of ccAPIAddress.fetch().
     *
     * @param addressIds
     *
     * @return
     */
    public static List<Map<String, Object>> contactAddressFetch(Set<String> addressIds) {
        List<Map<String, Object>> contactAddressFetchResponse = new List<Map<String, Object>>();
        try {

            Map<String,Object> inputData = new Map<String,Object>{
                    ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                    ccrz.ccApiAddress.ADDRESSIDLIST => addressIds
            };

            Map<String, Object> outputData = ccrz.ccAPIAddress.fetch(inputData);
            if (outputData.get(ccrz.ccAPIAddress.ADDRESSLIST) != null) {
                contactAddressFetchResponse = (List<Map<String, Object>>)outputData.get(ccrz.ccAPIAddress.ADDRESSLIST);
            }
        } catch (Exception e) {
            throw new phss_cc_Exception(ADDRESS_CALLOUT_FAILED);
        }
        return contactAddressFetchResponse;
    }

    /**
     * @description Returns the result of ccAPIAddressBook.fetch().
     *
     * @param addressType
     *
     * @return
     */
    private static List<Map<String, Object>> addressBookFetch(String addressType) {
        List<Map<String, Object>> addressBookFetchResponse = new List<Map<String, Object>>();
        try {

            Map<String,Object> inputData = new Map<String,Object>{
                    ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                    ccrz.ccAPIAddressBook.ACCOUNTID => phss_cc_Context.currAccountId
            };

            if (addressType != ''){
                inputData.put(ccrz.ccAPIAddressBook.TYPE, addressType);
            }

            Map<String, Object> outputData = ccrz.ccAPIAddressBook.fetch(inputData);
            if (outputData.get(ccrz.ccAPIAddress.ADDRESSLIST) != null) {
                addressBookFetchResponse = (List<Map<String, Object>>)outputData.get(ccrz.ccAPIAddress.ADDRESSLIST);
            }
        } catch (Exception e) {
            throw new phss_cc_Exception(ADDRESS_CALLOUT_FAILED);
        }
        return addressBookFetchResponse;
    }

    /**
     * @description Creates a map of SFID->CC ContactAddress. This is done for easy rendering in Lightning component.
     *
     * @param fetchedAddresses
     *
     * @return
     */
    public static Map<String, Object> getAddressMapKeyedToSfidMap(List<Map<String, Object>> fetchedAddresses) {
        Map<String, Object> addressesById;
        try {
            addressesById = new Map<String, Object>();

            for (Object obj : fetchedAddresses) {
                Map<String, Object> currAddress = (Map<String, Object>) obj;
                String addressSfid = (String) currAddress.get(ADDRESS_SFID_KEY);
                addressesById.put(addressSfid, currAddress);
            }
        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_CREATE_A_ADDRESS_MAP);
        }
        return addressesById;
    }

    /**
     * @description Fetches and returns the addresses from the address book.
     *
     * @param opportunitySfid
     * @param addressType
     *
     * @return
     */
    public static Map<String, Object> fetchAddresses(String opportunitySfid, String addressType) {
        Map<String, Object> fetchAddressesResponse = new Map<String, Object> ();

        List<Map<String, Object>> fetchedAddresses = new List<Map<String, Object>>();
        Map<String, Object> addressMap = new Map<String, Object>();
        List<String> addressList = new List<String>();

        try {

            phss_cc_Context.setContext(opportunitySfid);
            fetchedAddresses = addressBookFetch(addressType);

            if (fetchedAddresses != null) {
                addressMap = getAddressMapKeyedToSfidMap(fetchedAddresses);
                addressList = new List<String>(addressMap.keySet());
            }
            fetchAddressesResponse = new Map<String, Object> {
                    ADDRESS_TYPE => addressType,
                    ADDRESS_LIST => addressList,
                    ADDRESS_MAP => addressMap
            };
        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_FETCH_ADDRESSES);
        }
        return fetchAddressesResponse;
    }
}