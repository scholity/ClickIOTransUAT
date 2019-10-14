public class CreateOrderWrapper {
    public order order{get;set;}
    public String action{get;set;}

    public class transaction_dtls{
        public list<ccTransactionDtls> ccTransactionDtls{get;set;}
        public list<poTransactionDtls> poTransactionDtls{get;set;}
        public list<ppTransactionDtls> ppTransactionDtls{get;set;}
    }
    public class student_info{
        public String student_last_name{get;set;}
        public String student_first_name{get;set;}
        public String student_email{get;set;}
    }
    public class shipping_info{
        public String phone{get;set;}
        public String company_name{get;set;}
        public String city{get;set;}
        public String address2{get;set;}
        public String postal_code{get;set;}
        public String address1{get;set;}
        public String state_code{get;set;}
        public String last_name{get;set;}
        public String country_code{get;set;}
        public String first_name{get;set;}
    }
    public class products{
      //public Integer adjusted_tax{get;set;}
        public String product_name{get;set;}
        public String product_id{get;set;}
        public String product_type{get;set;}
        public String pricing_type{get;set;}
        public Decimal original_price{get;set;}
        public Integer quantity{get;set;}
        public Decimal adjustment_amount{get;set;}
        public String type{get;set;}
        public Decimal price{get;set;}
    }
    public class ppTransactionDtls{
        public String paypalAuthTransactionID{get;set;}
        public String paypalAvsCode{get;set;}
        public String paypalBillingAgreementAcceptedStatus{get;set;}
        public String payment_method{get;set;}
        public String paypalCorrelationId{get;set;}
        public Boolean isPaypalBillingAddressPresent{get;set;}
        public String paypalEcSetRequestID{get;set;}
        public String auth_request_amount{get;set;}
        public String paypalEcSetRequestToken{get;set;}
        public String auth_capture_amount{get;set;}
        public String paypalGetDetailsAddressStatus{get;set;}
        public String approvalStatus{get;set;}
        public String paypalGetDetailsCorrelationId{get;set;}
        public String paypalProtectionEligibility{get;set;}
        public String paypalProtectionEligibilityType{get;set;}
        public String paypalPayerStatus{get;set;}
        public String paypalSetRequestCorrelationID{get;set;}
        public String paypalPayerLastName{get;set;}
        public String paypalToken{get;set;}
        public String paypalPayerID{get;set;}
        public String paypalTransactionID{get;set;}
        public String paypalPayerFirstName{get;set;}
        public String requestId{get;set;}
        public String paypalPayerEmail{get;set;}
        public String requestToken{get;set;}
        public String paypalPayerCountry{get;set;}
        public String transaction_id{get;set;}
        public String paypalOrigination{get;set;}
        public String transaction_modification_time{get;set;}
        public String paypalGetDetailsTaxAmount{get;set;}
        public Datetime transaction_time{get;set;}
        public String paypalGetDetailsPayerStatus{get;set;}
    }
    public class poTransactionDtls{
        public String afsReasonCode{get;set;}
        public String approvalStatus{get;set;}
        public Decimal auth_capture_amount{get;set;}
        public String afsResult{get;set;}
        public String auth_request_amount{get;set;}
        public String afsFactorCode{get;set;}
    }
    public class order_transaction{
        public String paymentProcessorID{get;set;}
        public transaction_dtls transaction_dtls{get;set;}
        public String storefront{get;set;}
    }
    public class order_items{
        public list<products> products{get;set;}
    }
    public class order_header{
        //public Decimal shipping_total{get;set;}
        //public Decimal order_total{get;set;}
        //public String shipping_method{get;set;}
        public Decimal total_discount{get;set;}
        public String promotion_ids{get;set;}
        public String coupon_codes{get;set;}
        public String order_no{get;set;}
        public String tax_exempt_flag{get;set;}
        public String external_order_status{get;set;}
        public Integer tax_total{get;set;}
        public String currency_code{get;set;}
        public String payment_method{get;set;}
        public String creation_date{get;set;}
        public String created_by{get;set;}
    }
    public class order{
        public order_header order_header{get;set;}
        public order_transaction order_transaction{get;set;}
        public order_items order_items{get;set;}
        public shipping_info shipping_info{get;set;}
        public billing_info billing_info{get;set;}
        public student_info student_info{get;set;}
    }
    public class ccTransactionDtls{
        public Integer cc_exp_year{get;set;}
        public String avsCode{get;set;}
        public Integer cc_exp_month{get;set;}
        public String authCode{get;set;}
        public String cc_holder{get;set;}
        public String auth_request_amount{get;set;}
        public String cc_last_four{get;set;}
        public Decimal auth_capture_amount{get;set;}
        public String cc_num{get;set;}
        public String approvalStatus{get;set;}
        public String dmDecision{get;set;}
        public String afsResult{get;set;}
        public Boolean is_cc_expired{get;set;}
        public String afsReasonCode{get;set;}
        public String masked_cc_number{get;set;}
        public String afsFactorCode{get;set;}
        public String offeringTransactionID{get;set;}
        public String token{get;set;}
        public String transacrtion_type{get;set;}
        public String requestToken{get;set;}
        public String transaction_id{get;set;}
        public String requestId{get;set;}
        public String transaction_modification_time{get;set;}
        public String payment_type{get;set;}
        public Datetime transaction_time{get;set;}
        public String payment_method{get;set;}
    }
    public class billing_info{
        public String email{get;set;}
        public String company_name{get;set;}
        public String city{get;set;}
        public String postal_code{get;set;}
        public String address2{get;set;}
        public String state_code{get;set;}
        public String address1{get;set;}
        public String country_code{get;set;}
        public String last_name{get;set;}
        public String phone{get;set;}
        public String first_name{get;set;}
    }
}