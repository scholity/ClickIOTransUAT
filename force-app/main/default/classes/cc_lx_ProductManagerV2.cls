public with sharing class cc_lx_ProductManagerV2 {

    @TestVisible
    private static Integer API_VERSION = ccrz.ccApi.CURRENT_VERSION;

    public static final String SKU_KEY = 'SKU';
    public static final String PRODUCT_COMPOSITE_MEDIAS = 'productCompositeMedias';
    public static final String COMPOSITE_ID = 'compositeId';
    public static final String COMPOSITE_MEDIAS = 'compositeMedias';
    public static final String PRODUCT_NAME = 'sfdcName';
    public static final String RELATED_PRODUCTLIST = 'relatedProductList';
    public static final String PRODUCTLIST = 'productList';
    public static final String RELATED_UPSELL = 'UpSell';
    public static final String RELATED_CROSSSELL = 'CrossSell';
    public static final String RELATED_COMPLEMENTARY = 'Complementary';
    public static final String RELATED_ACCESSORIES = 'Accessories';
    public static final String RELATED_COMPETITIVE = 'Competitive';
    public static final String RELATED_RELATED = 'Related';

    public static List<Map<String, Object>> getProductsSearch(String text) {
        List<Map<String, Object>> data = null;
        
        Map<String, Object> request = new Map<String,Object>{
            ccrz.ccApi.API_VERSION => API_VERSION,
            ccrz.ccService.SEARCHSTRING => text,
             ccrz.ccApiPriceList.ALLWMIX => true
        };

        Map<String,Object> response = null;

        try {
            response = ccrz.ccAPIProduct.search(request);
            Boolean isSuccess = (Boolean) response.get(ccrz.ccAPI.SUCCESS);
            if (isSuccess) {
                Set<String> ids = (Set<String>) response.get(ccrz.ccService.SEARCHRESULTS);
                if (ids != null && !ids.isEmpty()) {
                    data = getProducts(new List<String>(ids));
                }
            }
        }
        catch(Exception e) {
            System.debug(System.LoggingLevel.ERROR, e.getMessage());
            throw new ProductManagerException(e.getMessage());
        }

        return data;
    }

    public static Map<String, Object> getProductsMap(List<String> ids) {
      List<Map<String, Object>> data = null;

      Map<String, Object> request = new Map<String,Object>{
          ccrz.ccApi.API_VERSION => API_VERSION,
          ccrz.ccApiProduct.PARAM_INCLUDE_PRICING => true,
          ccrz.ccAPIProduct.PRODUCTIDLIST => ids,
          ccrz.ccApi.SIZING => new Map<String, Object>{
            ccrz.ccAPIProduct.ENTITYNAME => new Map<String, Object>{
              ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_XL
            }
          }
      };

      Map<String,Object> response = null;
      Map<String, Object> returnData = new Map<String, Object>();

      try {
          response = ccrz.ccAPIProduct.fetch(request);
          Boolean isSuccess = (Boolean) response.get(ccrz.ccAPI.SUCCESS);
          if (isSuccess) { // this is just stripping out any extra stuff that might have come along
            returnData.put(ccrz.ccAPIProduct.PRODUCTLIST, response.get(ccrz.ccAPIProduct.PRODUCTLIST));
            returnData.put(ccrz.ccApiSpec.SPECLIST, response.get(ccrz.ccApiSpec.SPECLIST));
          }
      }
      catch(Exception e) {
          System.debug(System.LoggingLevel.ERROR, e.getMessage());
          throw new ProductManagerException(e.getMessage());
      }

      // get the composite products
      List<Map<String,Object>> products = (List<Map<String,Object>>)returnData.get(ccrz.ccAPIProduct.PRODUCTLIST);
      if(products != null) {
        List<String> compositeProductIds = new List<String>();
        for(Map<String, Object> product : products) {
          List<Map<String, Object>> compositeProducts = (List<Map<String,Object>>)product.get('compositeProductsS');
          if(compositeProducts != null) {
            for(Map<String, Object> compProduct : compositeProducts) {
              compositeProductIds.add((String)compProduct.get('component'));
            }
          }
        }

        if(compositeProductIds.size() > 0) {
          Map<String, Object> compRequest = new Map<String,Object>{
              ccrz.ccApi.API_VERSION => API_VERSION,
              ccrz.ccApiProduct.PARAM_INCLUDE_PRICING => true,
              ccrz.ccAPIProduct.PRODUCTIDLIST => compositeProductIds,
              ccrz.ccApi.SIZING => new Map<String, Object>{
                ccrz.ccAPIProduct.ENTITYNAME => new Map<String, Object>{
                  ccrz.ccAPI.SZ_DATA => ccrz.ccAPI.SZ_M
                }
              }
          };

          Map<String,Object> compResponse = null;

          try {
              compResponse = ccrz.ccAPIProduct.fetch(compRequest);
              Boolean isSuccess = (Boolean) compRequest.get(ccrz.ccAPI.SUCCESS);
              if (isSuccess) {
                List<Map<String,Object>> compositeMedias = new List<Map<String,Object>>();
                for(Map<String, Object> product : (List<Map<String,Object>>)compResponse.get(ccrz.ccAPIProduct.PRODUCTLIST)) {
                  Map<String, Object> compositeItem = new Map<String, Object>();
                  compositeItem.put(cc_lx_ProductManagerV2.COMPOSITE_ID, product.get('sfid'));
                  compositeItem.put(cc_lx_ProductManagerV2.PRODUCT_NAME, product.get(cc_lx_ProductManagerV2.PRODUCT_NAME));
                  compositeItem.put(cc_lx_ProductManagerV2.COMPOSITE_MEDIAS, product.get('EProductMediasS'));
                  compositeMedias.add(compositeItem);
                }
                returnData.put(cc_lx_ProductManagerV2.PRODUCT_COMPOSITE_MEDIAS, compositeMedias);
              }
          }
          catch(Exception e) {
              System.debug(System.LoggingLevel.ERROR, e.getMessage());
              throw new ProductManagerException(e.getMessage());
          }
        }
      }

      return returnData;
    }

    public static List<Map<String, Object>> getProducts(List<String> ids) {
        List<Map<String, Object>> data = null;

        Map<String, Object> request = new Map<String,Object>{
            ccrz.ccApi.API_VERSION => API_VERSION,
            ccrz.ccApiProduct.PARAM_INCLUDE_PRICING => true,
            ccrz.ccAPIProduct.PRODUCTIDLIST => ids
        };

        Map<String,Object> response = null;

        try {
            response = ccrz.ccAPIProduct.fetch(request);
            Boolean isSuccess = (Boolean) response.get(ccrz.ccAPI.SUCCESS);
            if (isSuccess) {
                data = (List<Map<String, Object>>) response.get(ccrz.ccAPIProduct.PRODUCTLIST);
            }
        }
        catch(Exception e) {
            System.debug(System.LoggingLevel.ERROR, e.getMessage());
            throw new ProductManagerException(e.getMessage());
        }
        return data;
    }

    public static Map<String, Object> getRelatedProducts(String productId, String type) {
      Map<String, Object> data = new Map<String, Object>();

      Map<String, Object> request = new Map<String, Object> {
        ccrz.ccApi.API_VERSION => API_VERSION,
        ccrz.ccApiRelatedProduct.PRODUCTID => productId,
        ccrz.ccApiRelatedProduct.RELATED_TYPE => new Set<String>{ type }
      };

      Map<String, Object> response = null;

      try {
        response = ccrz.ccApiRelatedProduct.fetch(request);
        Boolean isSuccess = (Boolean) response.get(ccrz.ccAPI.SUCCESS);
        if(isSuccess) {
          data.put(cc_lx_ProductManagerV2.RELATED_PRODUCTLIST, response.get(ccrz.ccApiRelatedProduct.RELATEDPRODUCTLIST));
          data.put(cc_lx_ProductManagerV2.PRODUCTLIST, response.get(ccrz.ccApiProduct.PRODUCTLIST));
        }
      }
      catch(Exception e) {
          System.debug(System.LoggingLevel.ERROR, e.getMessage());
          throw new ProductManagerException(e.getMessage());
      }

      return data;
    }

    public class ProductManagerException extends Exception {}
}