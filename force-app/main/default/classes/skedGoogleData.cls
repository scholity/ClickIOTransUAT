global class skedGoogleData {
    
    public virtual class baseResult {
        public boolean hasError {get;set;}
        public string errorMessage {get;set;}
        public string status { get; set; }
        
        public baseResult() {
            this.hasError = false;
        }
    }
    
    /*GEOCODE*/    
    public class geocodeResult extends baseResult {
        public List<geocodeResultItem> results { get; set; }
        
        public geocodeResult() {
            super();
        }
    }
    
    public class geocodeResultItem {
        public Geometry geometry { get; set; }
    }
    
    public class Geometry {
        public GeoLocation location { get; set; }
    }
    
    public class GeoLocation {
        public double lat { get; set; }
        public double lng { get; set; }
    }

}