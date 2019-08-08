public class DW2PHSSMappingConstants{
    // schema to query from
    public static String strSchema = 'arc_mdm_vws';

    // views used for phone and general search 
    // public static String strPhoneSearch = strSchema + '.' + 'TSC_CONST_CTI_PHONE_SEARCH_VW'; 
    // public static String strGeneralSearch = strSchema + '.' + 'TSC_CONST_GENERAL_SEARCH_VW';

    public static String strPhoneSearch = strSchema + '.' + 'TSC_CNST_CTI_PH_SEARCH'; 
    //public static String strGeneralSearch = strSchema + '.' + 'TSC_CNST_GEN_SEARCH';
	public static String strGeneralSearch = strSchema + '.' + 'tsc_cnst_gen_search';


    //csv for Constituent details  
    //public static String strConstituentDetailsQuery ='TSC_CNST_DETAILS_VW';
    
    public static String strConstituentDetailsQuery ='TSC_CNST_DETAILS';



    // standard web service parameter names
    public static String strViewName_ParamName = 'View_Name';
    public static String strNumberOfRecords_ParamName = 'Max_Number_Of_Rows';
    
    public static String strPartitionCriteria_ParamName = 'Partition_Criteria';
    
    public static String strAllowOrderBy_ParamName = 'Allow_Order_By';
    public static String strDefaultOrderBy_ParamName = 'Default_Order_By';

    // sort order constants
    public static String strSortOrder_ASC = 'ASC';
    public static String strSortOrder_DESC = 'DESC';
    
    // allowed filters for search
    public static String strQueryFilter_Like = 'Like';
    public static String strQueryFilter_Equals = 'Equals';

    // maximum number of records to be displayed
    public static String strMaxNumberOfSearchRecords = '25';

    // view column names
    public static String strPhoneNumber_ColumnName = 'PHONE_NUMBER';
    public static String strMasterConstituentId_ColumnName = 'Constituent_Id';
    public static String strContactFirstName_ColumnName = 'CONTACT_FIRST_NAME';
    public static String strContactLastName_ColumnName = 'CONTACT_LAST_NAME';
    public static String strContactFullName_ColumnName = 'CONTACT_FULL_NAME';
    public static String strContactTitle_ColumnName = 'CONTACT_TITLE';
    public static String strContactNameSuffix_ColumnName = 'CONTACT_NAME_SUFFIX';
    public static String strAddress_ColumnName = 'ADDRESS'; 
    public static String strAddressLine1_ColumnName = 'ADDRESS_LINE_1';
    public static String strAddressLine2_ColumnName = 'ADDRESS_LINE_2';
    public static String strCity_ColumnName = 'CITY';
    public static String strState_ColumnName = 'STATE';
    public static String strZip_ColumnName = 'ZIP';
    public static String strEmailAddress_ColumnName = 'EMAIL_ADDRESS';
    public static String strMngdLrngFlg_ColumnName = 'MNGD_LRNG_CNTC_FLG';
    public static String strInstrctrFlg_ColumnName = 'INSTRCTR_FLG';
    public static String strSabaPersonId_ColumnName = 'SABA_PERSON_ID';
    
    // added by MM on 5/16/2013
    public static String strFullAddress_ColumnName = 'FULL_ADDRESS';
   
   
   
    public static String strARCBESTAddressLine1_ColumnName = 'ARC_ADDRESS_LINE_1';
    public static String strARCBESTAddressLine2_ColumnName = 'ARC_ADDRESS_LINE_2';
    public static String strARCBESTCity_ColumnName = 'ARC_CITY';
    public static String strARCBESTState_ColumnName = 'ARC_STATE';
    public static String strARCBESTZip_ColumnName = 'ARC_ZIP';
    public static String strARCBESTEmailAddress_ColumnName = 'ARC_EMAIL_ADDRESS';
    public static String strARCBESTPhoneNumber_ColumnName = 'ARC_PHONE_NUMBER';
    
    // added by MM 
    public static String strSFId_ColumnName = 'SFDC_ID';
    
    
    // added by MM on 5/16/2013
    public static String strARCBESTContactFirstName_ColumnName = 'ARC_CONTACT_FIRST_NAME';
    public static String strARCBESTContactLastName_ColumnName = 'ARC_CONTACT_LAST_NAME';
    public static String strARCBESTContactFullName_ColumnName = 'ARC_CONTACT_FULL_NAME';
    public static String strARCBESTFullAddress_ColumnName = 'ARC_FULL_ADDRESS';
   
     
    
    
    // the default order by for the phone and general search
    public static String strConstSearchDefaultOrderBy = 'ORDER BY ' + strContactLastName_ColumnName;
    
    // added by MM on 5/17/2013
    public static String strGeneralSearchDefaultOrderBy = 'ORDER BY ' + strARCBESTContactLastName_ColumnName;
    
    
    // changed by MM on 5/16/2013
    // partition criteria for general search
    /*public static String strGeneralSearch_PartitionCriteria =   'partition by cnst_prsn_nm.cnst_mstr_id '
                                                                + 'order by cnst_email.cnst_best_email_ind desc, '
                                                                + 'cnst_phn.cnst_phn_best_ind desc, cnst_addr.cnst_addr_prefd_ind desc';
	*/
	 public static String strGeneralSearch_PartitionCriteria =   'PARTITION BY constituent_id '
                                                                + 'ORDER BY constituent_id  ';
	
}