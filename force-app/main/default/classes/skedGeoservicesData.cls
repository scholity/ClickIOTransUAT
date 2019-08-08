public class skedGeoservicesData {
    
    public virtual class baseResult {
        public boolean hasError {get;set;}
        public string errorMessage {get;set;}
        public string status {get;set;}
        
        public baseResult() {
            this.hasError = false;
        }
    }
    
    public class distanceMatrixResult extends baseResult {
        public Matrix result {get;set;}
        
        public distanceMatrixResult() {
            super();
        }
    }
    
    public class Matrix {
        public List<List<Element>> matrix {get;set;}
    }
    
    public class Distance {
        public integer distanceInMeters {get;set;}
    }
    
    public class Duration {
        public integer durationInSeconds {get;set;}
    }
    
    public class Element {
        public Distance distance {get;set;}
        public Duration duration {get;set;}
        public string status {get;set;}
    }

}