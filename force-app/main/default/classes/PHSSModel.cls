public class PHSSModel{
    // constituent search criteria model
    public class ConstituentSearchCriteria{
        public string FirstName {get; set;}
        public string LastName {get; set;}
        public string City {get; set;}
        public string State {get; set;}
        public string Zip {get; set;}
        public string Phone {get; set;}
        public string EmailAddress {get; set;}
    }
    
    // constituent search results wrapper
    public class ConstituentSearchResultWrapper{
        public List<ConstituentSearchResult> constituentSearchResults;
        public SortCriteria sortCriteria;
        public ConstituentSearchResultWrapper(  List<ConstituentSearchResult> cnsttntSearchResults,
                                                SortCriteria srtCriteria){
            constituentSearchResults = cnsttntSearchResults;
            sortCriteria = srtCriteria;
        }
    }
     
    // constituent search results model
    public class ConstituentSearchResult{
        public string Name {get; set;}
        public string FirstName {get; set;}
        public string LastName {get; set;}
        public string Phone {get; set;}
        public string Address {get; set;}
        public string AddressLine1 {get; set;}
        public string AddressLine2 {get; set;}
        public string City {get; set;}
        public string State {get; set;}
        public string Zip {get; set;}
        public string EmailAddress {get; set;}
        public string SabaPersonId {get; set;}
        public string InstructorFlag {get; set;}
        public string ManagedLearningContactFlag {get; set;}
        public string ConstituentId {get; set;}
        // added by MM
        public String SFContactId {get; set;}
    }
    
    // sort criteria model
    public class SortCriteria{
        public string strQuery {get; set;}
        public string strName {get; set;}
        public string strSortBy {
            get{
                return strSortBy;
            }
            set{
                if(strSortBy == null || strSortBy == '' || strSortBy != value){
                    // if no sort is performed or if a different column is sorted, set to ascending
                    strSortOrder = DW2PHSSMappingConstants.strSortOrder_ASC;
                }else{
                    // toggle if the same column is sorted
                    strSortOrder = (strSortOrder == DW2PHSSMappingConstants.strSortOrder_DESC
                                    ? DW2PHSSMappingConstants.strSortOrder_ASC
                                    : DW2PHSSMappingConstants.strSortOrder_DESC);
                }
                // set the sort by column
                strSortBy = value;
            }
        }
        public string strSortOrder {get; private set;}
        
        // parameterized constructor
        public SortCriteria(redcrossBiztalkIntegrationT2sfdc.QueryRequest queryRequest,
                            String strSrtBy){
            strQuery = queryRequest.query;
            strName = queryRequest.view;
            strSortBy = strSrtBy;
        }
    }
    
    // constituent details model
    public class ConstituentDetail{
        public string FirstName {get; set;}
        public string LastName {get; set;}
        public string Title {get; set;}
        public string Suffix {get; set;}
        public string ARCBestPhone {get; set;}
        public string ARCBestAddressLine1 {get; set;}
        public string ARCBestAddressLine2 {get; set;}
        public string ARCBestCity {get; set;}
        public string ARCBestState {get; set;}
        public string ARCBestZip {get; set;}
        public string ARCBestEmailAddress {get; set;}
        public string SabaPersonId {get; set;}
        public string InstructorFlag {get; set;}
        public string ManagedLearningContactFlag {get; set;}
        public string ConstituentId {get; set;}
         // added by MM
        public String SFContactId {get; set;}
    }
}