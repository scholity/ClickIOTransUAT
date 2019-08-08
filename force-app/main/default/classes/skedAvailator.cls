global class skedAvailator extends skedAvailatorBase {

    public skedAvailator(skedAvailatorParams inputParams) {
        super(inputParams);
    }

    public List<skedModels.jobAllocation> getAllAllocations() {
        return this.allAllocations;
    }
    
    public List<skedModels.jobAllocation> getAvailableAllocations() {
        List<skedModels.jobAllocation> result = new List<skedModels.jobAllocation>();
        for (skedModels.jobAllocation allocation : this.allAllocations) {
            if (allocation.isQualified && allocation.isAvailable) {
                result.add(allocation);
            }
        }
        return result;
    }

    protected override void initializeOtherResourceData() {
        
    }

    protected override void postProcessPossibleAllocations() {
        
    }
    
}