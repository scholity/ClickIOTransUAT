public with sharing class phss_cc_CommunityClassSearchController {

    public static final String COMMUNITY_INVENTORY_TYPE     = 'COMMUNITY';
    public static final String ILT_EVENT_RECORD_TYPE_NAME   = 'ILT EVENT';

    public static final String COURSES_KEY                  = 'courses';
    private static final String INVENTORY_TYPE_KEY          = 'inventoryType';
    private static final String DISTANCE_IN_MILES_KEY       = 'mi';
    private static final String PRODUCTS_KEY                = 'productMap';
    private static final String SFID_KEY                    = 'sfid';

    private static final Integer MINUTES_PER_DAY            = 1440;
    private static final Integer MINUTES_PER_HOUR           = 60;

    /* Class/Course Field Keys */
    private static final String ADDRESS_KEY                 = 'address';
    private static final String COURSE_KEY                  = 'course';
    private static final String DURATION_KEY                = 'duration';
    private static final String ID_KEY                      = 'id';
    private static final String ILT_CLASS_ID                = 'iltClassId';
    private static final String LOCATION_NAME_KEY           = 'locationName';
    private static final String NAME_KEY                    = 'name';
    private static final String PRICE_OVERRIDE_KEY          = 'priceOverride';
    private static final String SEATS_AVAILABLE_KEY         = 'seatsAvailable';
    private static final String START_DATETIME_KEY          = 'startDatetime';
    private static final String START_MONTH_KEY             = 'startMonth';
    private static final String START_DAY_KEY               = 'startDay';
    private static final String START_WEEKDAY_KEY           = 'startWeekday';
    private static final String START_WEEKDAY_ABBREV_KEY    = 'startWeekdayAbbreviation';
    private static final String START_TIME_KEY              = 'startTime';
    private static final String START_TIME_AM_PM_KEY        = 'startTimeAMPM';

    private static final String REQUIRES_DATE_ACKNOWLEDGEMENT_KEY   = 'requiresDateAcknowledgement';

    private static final String FAILED_TO_GET_AVAILABILITY_FOR_ILT_CLASSES  = 'Failed to get the availability for ILT classes.';
    private static final String FAILED_TO_GET_ILT_CLASSES = 'Failed to get the ILT classes';
    private static final String FAILED_TO_GET_ILT_EVENT_CLASSES = 'Failed to get the ILT event classes.';
    private static final String FAILED_TO_GET_LEARNING_OBJECTS = 'Failed to get the learning objects.';
    private static final String FAILED_TO_GET_LEARNING_PLANS = 'Failed to get the learning plans.';
    private static final String FAILED_TO_GET_LOCATION_COORDINATES = 'Failed to get the location coordinates';
    private static final String FAILED_TO_GET_SKEDULO_JOB_IDENTIFIERS = 'Failed to get the Skedulo job IDs.';
    private static final String FAILED_TO_GET_SKEDULO_JOBS = 'Failed to get the Skedulo jobs.';


    /**
     * @description Adds classes to the active cart associated with the specified opportunity
     *
     * @param opportunityId
     * @param items
     *
     * @return
     */
    @AuraEnabled
    public static Map<String, Object> addClassesToCart(String opportunityId, String items) {

        Map<String, Object> addToCartResult;
        Map<String, Object> classData = parseClassCourseQuantities(items);

        try {
            addToCartResult = phss_cc_ClassCartUtil.addClassesToCart(opportunityId, classData);
        } catch (Exception e) {
            addToCartResult = phss_cc_Exception.getErrorMessageMap(e.getMessage());
        }

        return addToCartResult;
    }

    /**
     * @description Searches for classes matching specified criteria
     *
     * @param searchTerm
     * @param opportunityId
     * @param startDateStr
     * @param endDateStr
     * @param city
     * @param state
     * @param postalCode
     * @param range
     *
     * @return
     */
    @AuraEnabled
    public static Map<String, Object> classSearch(String searchTerm, String opportunityId, String startDateStr, String endDateStr, String city, String state, String postalCode, Integer range) {

        if (String.isBlank(searchTerm)
                || searchTerm.length() < 3
                || String.isBlank(opportunityId)
                || String.isBlank(startDateStr)
                || String.isBlank(endDateStr)) {
            return null;
        }

        Map<String, Object> result = new Map<String, Object>();

        try {
            Date startDate = (Date) JSON.deserialize(startDateStr, Date.class);
            Date endDate = (Date) JSON.deserialize(endDateStr, Date.class);

            Map<String, Object> courses = searchCommunityCourses(opportunityId, searchTerm);
            Set<String> courseIdentifiers = courses.keySet();
            Map<Id, Id> jobCourses = getCoursesKeyedToJobs(courseIdentifiers);
            List<redwing__ILT_Class__c> classes = getILTClasses(jobCourses.keySet(), startDate, endDate);
            Map<Id, Integer> seatsAvailable = getAvailabilityForClasses(new Map<Id, redwing__ILT_Class__c>(classes).keySet());

            Map<Id, sked__Job__c> jobs = getSkeduloJobs(jobCourses.keySet());
            jobs = getNearbyJobs(jobs, city, state, postalCode, range);

            List<Object> classCourses = buildClassCourses(classes, jobs, courses, jobCourses, seatsAvailable);
            result.put(COURSES_KEY, classCourses);

        } catch (Exception e) {
            result.put('ERROR', e);
        }

        return result;
    }

    /**
     * @description Searches for courses matching the specified search term
     *
     * @param opportunityId
     * @param searchTerm
     *
     * @return
     */
    private static Map<String, Object> searchCommunityCourses(String opportunityId, String searchTerm) {

        Map<String, Object> searchResult = phss_cc_ProductUtil.productSearch(opportunityId, searchTerm);
        Map<String, Object> products = (Map<String, Object>) searchResult.get(PRODUCTS_KEY);
        Map<String, Object> courses = new Map<String, Object>();

        if (products != null) {
            for (String id : products.keySet()) {
                Map<String, Object> product = (Map<String, Object>) products.get(id);
                if (product.get(INVENTORY_TYPE_KEY) == COMMUNITY_INVENTORY_TYPE) {
                    courses.put((String) product.get(SFID_KEY), product);
                }
            }
        }

        return courses;
    }

    /**
     * @description Fetches the available vouchers for the specified ILT classes
     *
     * @param classIdentifiers
     *
     * @return
     */
    private static Map<Id, Integer> getAvailabilityForClasses(Set<Id> classIdentifiers) {

        Map<Id, Integer> availabilityMap = new Map<Id, Integer>();

        try {
            AggregateResult[] results = [
                    SELECT ILT_Class__c, COUNT(Id) seatsAvailable
                    FROM Voucher__c
                    WHERE ILT_Class__c IN :classIdentifiers
                    AND Status__c = 'Issued'
                    GROUP BY ILT_Class__c
            ];

            for (AggregateResult vouchers : results) {
                availabilityMap.put((Id) vouchers.get('ILT_Class__c'), (Integer) vouchers.get('seatsAvailable'));
            }

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_GET_AVAILABILITY_FOR_ILT_CLASSES, e);
        }

        return availabilityMap;
    }

    /**
     * @description Returns a map of ILT class IDs to course IDs
     *
     * @param courseIdentifiers
     *
     * @return
     */
    private static Map<Id, Id> getCoursesKeyedToJobs(Set<String> courseIdentifiers) {

        Map<String, Id> learningPlans = getLearningPlansKeyedToCourses(courseIdentifiers);
        Map<Id, Id> learningObjects = getLearningObjectsKeyedToPlans(learningPlans.values());
        Map<Id, Object> eventClasses = getILTEventClassesKeyedToLearning(learningObjects.values());
        Map<Id, Id> jobs = getJobsKeyedToLearning(eventClasses);

        Map<Id, Id> classCourseMap = new Map<Id, Id>();

        for (String courseId : learningPlans.keySet()) {
            Id learningPlanId = learningPlans.get(courseId);
            Id learningObjectId = learningObjects.get(learningPlanId);
            List<Id> eventClassList = (List<Id>) eventClasses.get(learningObjectId);
            if (eventClassList != null) {
                for (Id eventClassId : eventClassList) {
                    Id jobId = jobs.get(eventClassId);
                    if (jobId != null) {
                        classCourseMap.put(jobId, courseId);
                    }
                }
            }
        }

        return classCourseMap;
    }

    /**
     * @description Fetches learning plans for the specified courses
     *
     * @param courseIdentifiers
     *
     * @return
     */
    private static Map<String, Id> getLearningPlansKeyedToCourses(Set<String> courseIdentifiers) {

        Map<String, Id> learningPlanMap = new Map<String, Id>();

        try {
            List<ccrz__E_Product__c> courses = [
                    SELECT Id, LMS_Learning_Plan__c
                    FROM ccrz__E_Product__c
                    WHERE Id IN :courseIdentifiers
            ];

            for (ccrz__E_Product__c course : courses) {
                learningPlanMap.put(course.Id, course.LMS_Learning_Plan__c);
            }

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_GET_LEARNING_PLANS, e);
        }

        return learningPlanMap;
    }

    /**
     * @description Fetches learning objects for learning plans
     *
     * @param planIdentifiers
     *
     * @return
     */
    private static Map<Id, Id> getLearningObjectsKeyedToPlans(List<Id> planIdentifiers) {

        Map<Id, Id> learningObjectMap = new Map<Id, Id>();

        try {
            List<redwing__Training_Plan_Section_Item__c> items = [
                    SELECT redwing__Learning__c, redwing__Training_Plan_Section__r.redwing__Training_Plan__c
                    FROM redwing__Training_Plan_Section_Item__c
                    WHERE redwing__Training_Plan_Section__r.redwing__Training_Plan__c IN :planIdentifiers
                    AND redwing__Learning__r.RecordType.Name = :ILT_EVENT_RECORD_TYPE_NAME
            ];

            for (redwing__Training_Plan_Section_Item__c item : items) {
                learningObjectMap.put(item.redwing__Training_Plan_Section__r.redwing__Training_Plan__c, item.redwing__Learning__c);
            }

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_GET_LEARNING_OBJECTS, e);
        }

        return learningObjectMap;
    }

    /**
     * @description Fetches ILT event classes for learning objects
     *
     * @param learningIdentifiers
     *
     * @return
     */
    private static Map<Id, Object> getILTEventClassesKeyedToLearning(List<Id> learningIdentifiers) {

        Map<Id, Object> classMap = new Map<Id, Object>();

        try {
            List<redwing__ILT_Event_Class__c> classes = [
                    SELECT redwing__ILT_Event__r.redwing__Learning__c, redwing__Learning__c
                    FROM redwing__ILT_Event_Class__c
                    WHERE redwing__ILT_Event__r.redwing__Learning__c IN :learningIdentifiers
                    AND redwing__Learning__c != NULL
            ];

            for (redwing__ILT_Event_Class__c eClass : classes) {
                Id id = eClass.redwing__ILT_Event__r.redwing__Learning__c;
                List<Id> classList = (List<Id>) classMap.get(id);
                if (classList == null) {
                    classList = new List<Id>();
                    classMap.put(id, classList);
                }
                classList.add(eClass.redwing__Learning__c);
            }

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_GET_ILT_EVENT_CLASSES, e);
        }

        return classMap;
    }

    /**
     * @description Fetches jobs for learning objects
     *
     * @param learningObjects
     *
     * @return
     */
    private static Map<Id, Id> getJobsKeyedToLearning(Map<Id, Object> learningObjects) {

        Map<Id, Id> classMap = new Map<Id, Id>();

        try {
            Set<Id> learningIdentifiers = new Set<Id>();
            for (Id id : learningObjects.keySet()) {
                List<Id> identifiers = (List<Id>) learningObjects.get(id);
                learningIdentifiers.addAll(identifiers);
            }

            List<redwing__ILT_Class__c> classes = [
                    SELECT redwing__Learning__c, Skedulo_Job_Id_External__c
                    FROM redwing__ILT_Class__c
                    WHERE redwing__Learning__c IN :learningIdentifiers
            ];

            for (redwing__ILT_Class__c c : classes) {
                classMap.put(c.redwing__Learning__c, c.Skedulo_Job_Id_External__c);
            }

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_GET_SKEDULO_JOB_IDENTIFIERS, e);
        }

        return classMap;
    }

    /**
     * @description Fetches Skedulo jobs
     *
     * @param jobIdentifiers
     *
     * @return
     */
    private static Map<Id, sked__Job__c> getSkeduloJobs(Set<Id> jobIdentifiers) {

        Map<Id, sked__Job__c> jobMap = new Map<Id, sked__Job__c>();

        try {
            List<sked__Job__c> jobList = [
                    SELECT Id, Job_Month__c, Location_Name__c, Name, Number_of_Students__c, sked__Address__c, sked__Duration__c, sked__Location__r.sked__GeoLocation__c, sked__Start__c, sked__Timezone__c
                    FROM sked__Job__c
                    WHERE Id IN :jobIdentifiers];

            for (sked__Job__c job : jobList) {
                jobMap.put(job.Id, job);
            }
        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_GET_SKEDULO_JOBS, e);
        }

        return jobMap;
    }

    /**
     * @description Filters a list of jobs based on proximity to a location
     *
     * @param jobs
     * @param city
     * @param state
     * @param postalCode
     * @param range
     *
     * @return
     */
    private static Map<Id, sked__Job__c> getNearbyJobs(Map<Id, sked__Job__c> jobs, String city, String state, String postalCode, Integer range) {

        Map<Id, sked__Job__c> nearbyJobs = new Map<Id, sked__Job__c>();
        Set<Location> locations = getCoordinates(city, state, postalCode);

        for (Id id : jobs.keySet()) {
            sked__Job__c job = jobs.get(id);
            for (Location location : locations) {
                if (job.sked__Location__c != null && job.sked__Location__r.sked__GeoLocation__c != null) {
                    Double distance = job.sked__Location__r.sked__GeoLocation__c.getDistance(location, DISTANCE_IN_MILES_KEY);
                    if (distance <= range) {
                        nearbyJobs.put(id, job);
                        break;
                    }
                }
            }
        }

        return nearbyJobs;
    }

    /**
     * @description Returns a list of GeoLocations matching the specified city, state, and postal code.
     *
     * @param city
     * @param state
     * @param postalCode
     *
     * @return
     */
    private static Set<Location> getCoordinates(String city, String state, String postalCode) {

        Set<Location> coordinates = new Set<Location>();

        try {
            List<Geo_Location__c> locations = new List<Geo_Location__c>();
            if (String.isNotBlank(postalCode)) {
                if (String.isNotBlank(state)) {
                    if (String.isNotBlank(city)) {
                        locations = [
                                SELECT Id, Coordinates__c
                                FROM Geo_Location__c
                                WHERE City_UC__c = :city.toUpperCase()
                                AND State_Abbreviation__c = :state
                                AND Postal_Code__c = :postalCode
                        ];
                    }
                    else {
                        locations = [
                                SELECT Id, Coordinates__c
                                FROM Geo_Location__c
                                WHERE State_Abbreviation__c = :state
                                AND Postal_Code__c = :postalCode
                        ];
                    }
                }
                else {
                    locations = [
                            SELECT Id, Coordinates__c
                            FROM Geo_Location__c
                            WHERE Postal_Code__c = :postalCode
                    ];
                }
            }
            else if (String.isNotBlank(city) && String.isNotBlank(state)) {
                locations = [
                        SELECT Id, Coordinates__c
                        FROM Geo_Location__c
                        WHERE City_UC__c = :city.toUpperCase()
                        AND State_Abbreviation__c = :state
                ];
            }

            for (Geo_Location__c location : locations) {
                coordinates.add(location.Coordinates__c);
            }

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_GET_LOCATION_COORDINATES, e);
        }

        return coordinates;
    }

    /**
     * @description Fetches ILT classes
     *
     * @param jobIdentifiers
     *
     * @return
     */
    public static List<redwing__ILT_Class__c> getILTClasses(Set<Id> jobIdentifiers, Date startDate, Date endDate) {

        try {
            return [
                    SELECT Id,
                           redwing__End_Date__c,
                           redwing__End_Time__c,
                           redwing__Max_Seats__c,
                           redwing__Start_Date__c,
                           redwing__Start_Time__c,
                           Skedulo_Job_Id_External__c,
                           Price_Override__c
                      FROM redwing__ILT_Class__c
                     WHERE Skedulo_Job_Id_External__c IN :jobIdentifiers
                       AND redwing__Start_Date__c >= :startDate
                       AND redwing__Start_Date__c <= :endDate
                     ORDER BY redwing__Start_Date__c
            ];

        } catch (Exception e) {
            throw new phss_cc_Exception(FAILED_TO_GET_ILT_CLASSES, e);
        }
    }

    /**
     * @description Builds a map of ILT class- and course-related data
     *
     * @param classes
     * @param jobs
     * @param courses
     * @param jobCourses
     *
     * @return
     */
    public static List<Object> buildClassCourses(List<redwing__ILT_Class__c> classes, Map<Id, sked__Job__c> jobs, Map<String, Object> courses, Map<Id, Id> jobCourses, Map<Id, Integer> seatsAvailable) {

        List<Object> classCourses = new List<Object>();

        for (redwing__ILT_Class__c iClass : classes) {
            sked__Job__c job = jobs.get(iClass.Skedulo_Job_Id_External__c);
            if (job != null) {
                Map<String, Object> classMap = new Map<String, Object>();
                classMap.put(ILT_CLASS_ID, iClass.Id);

                Datetime startDate = getDatetime(iClass.redwing__Start_Date__c, iClass.redwing__Start_Time__c);
                Datetime endDate = getDatetime(iClass.redwing__End_Date__c, iClass.redwing__End_Time__c);
                if (startDate != null) {
                    classMap.put(START_DATETIME_KEY, startDate);
                    classMap.put(START_MONTH_KEY, startDate.format('MMM'));
                    classMap.put(START_DAY_KEY, startDate.format('d'));
                    classMap.put(START_WEEKDAY_KEY, startDate.format('EEEE'));
                    classMap.put(START_WEEKDAY_ABBREV_KEY, startDate.format('EEE.'));
                    classMap.put(START_TIME_KEY, startDate.format('H:mm'));
                    classMap.put(START_TIME_AM_PM_KEY, startDate.format('a'));

                    if (endDate != null) {
                        Long millisecondsElapsed = endDate.getTime() - startDate.getTime();
                        Long minutesElapsed = millisecondsElapsed / 1000 / 60;
                        classMap.put(DURATION_KEY, formatDuration(minutesElapsed.intValue()));
                    }

                    if (startDate < Datetime.now()) {
                        classMap.put(REQUIRES_DATE_ACKNOWLEDGEMENT_KEY, true);
                    }
                }

                if (String.isNotBlank(job.Id)) {
                    classMap.put(ID_KEY, job.Id);
                }
                if (String.isNotBlank(job.Location_Name__c)) {
                    classMap.put(LOCATION_NAME_KEY, job.Location_Name__c);
                }
                if (String.isNotBlank(job.sked__Address__c)) {
                    classMap.put(ADDRESS_KEY, job.sked__Address__c);
                }

                classMap.put(NAME_KEY, job.Name);

                Integer seatCount = seatsAvailable.get(iClass.Id);
                if (seatCount == null) {
                    seatCount = 0;
                }
                classMap.put(SEATS_AVAILABLE_KEY, seatCount);

                if (iClass.Price_Override__c != null) {
                    classMap.put(PRICE_OVERRIDE_KEY, iClass.Price_Override__c);
                }

                Id courseId = jobCourses.get(job.Id);
                if (courseId != null) {
                    Map<String, Object> course = (Map<String, Object>) courses.get(courseId);
                    if (course != null) {
                        classMap.put(COURSE_KEY, course);
                    }
                }

                classCourses.add(classMap);
            }
        }

        return classCourses;
    }

    /**
     * @description Returns a duration formatted as a String
     *
     * @param duration time in minutes
     *
     * @return
     */
    private static String formatDuration(Integer duration) {
        String result = '';

        if (duration >= MINUTES_PER_DAY) {
            Integer days = duration / MINUTES_PER_DAY;
            result += (days + 'd ');
            duration = Math.mod(duration, MINUTES_PER_DAY);
        }

        if (duration >= MINUTES_PER_HOUR) {
            Integer hours = duration / MINUTES_PER_HOUR;
            result += (hours + 'h ');
            duration = Math.mod(duration, MINUTES_PER_HOUR);
        }

        if (duration > 0) {
            result += (duration + 'm');
        }

        return result.trim();
    }

    /**
     * @description Creates a Datetime from a Date and a time String
     *
     * @param d
     * @param t
     *
     * @return
     */
    private static Datetime getDatetime(Date d, String timeStr) {
        Datetime dt;

        Time t;
        if (String.isNotBlank(timeStr)) {
            List<String> components = timeStr.split(':');
            if (components.size() == 2) {
                Integer hours = Integer.valueOf(components[0]);
                Integer minutes = Integer.valueOf(components[1]);
                t = Time.newInstance(hours, minutes, 0, 0);
            }
        }
        else {
            t = Time.newInstance(0, 0, 0, 0);
        }

        if (d != null && t != null) {
            dt = Datetime.newInstance(d, t);
        }

        return dt;
    }

    /**
     * @description Parses quantities of ILT classes and courses
     *
     * @param input
     *
     * @return
     */
    private static Map<String, Object> parseClassCourseQuantities(String input) {
        if (String.isBlank(input)) {
            return null;
        }

        List<Id> classList = new List<Id>();
        Map<String, String> classCourseMap = new Map<String, String>();
        Map<String, Integer> classQuantityMap = new Map<String, Integer>();

        List<Object> items = (List<Object>) JSON.deserializeUntyped(input);
        for (Object item : items) {
            if (item instanceof Map<String, Object>) {
                Map<String, Object> classMap = (Map<String, Object>) item;
                String classId = (String) classMap.get(phss_cc_ClassCartUtil.CLASS_ID_KEY);
                String courseId = (String) classMap.get(phss_cc_ClassCartUtil.COURSE_ID_KEY);
                Integer quantity = (Integer) classMap.get(phss_cc_ClassCartUtil.COUNT_KEY);

                if (classId != null && courseId != null && quantity != null) {
                    classList.add(classId);
                    classCourseMap.put(classId, courseId);
                    classQuantityMap.put(classId, quantity);
                }
            }
        }

        Map<String, Object> result = new Map<String, Object>{
                phss_cc_ClassCartUtil.CLASS_ID_LIST => classList,
                phss_cc_ClassCartUtil.CLASS_COURSE_MAP => classCourseMap,
                phss_cc_ClassCartUtil.CLASS_QUANTITY_MAP => classQuantityMap
        };

        return result;
    }


    public static void evaluateSearch(String searchStr, String iltClassId, String opportunityId) {
        System.debug('***  Community Class Search (searchStr=' + searchStr + ', iltClassId=' + iltClassId + ', opportunityId=' + opportunityId + ')  ***');

        try {
            Map<String, Object> searchResults = phss_cc_ProductUtil.productSearch(opportunityId, searchStr);
            Map<String, Object> products = (Map<String, Object>) searchResults.get(PRODUCTS_KEY);
            System.debug('Number of search results from CloudCraze Product Search API: ' + products.keySet().size());

            if (products.keySet().size() > 0) {
                Map<String, Object> communityProducts = new Map<String, Object>();
                for (String productId: products.keySet()) {
                    Map<String, Object> product = (Map<String, Object>) products.get(productId);
                    if (product.get(INVENTORY_TYPE_KEY) == COMMUNITY_INVENTORY_TYPE) {
                        communityProducts.put((String) product.get(SFID_KEY), product);
                    }
                }
                System.debug('Number of community courses: ' + communityProducts.keySet().size());

                if (communityProducts.keySet().size() > 0) {
                    Map<Id, Id> jobCourses = getCoursesKeyedToJobs(communityProducts.keySet());

                    Date today = Date.today();
                    Date startDate = today.addYears(-1);
                    Date endDate = today.addYears(1);

                    List<redwing__ILT_Class__c> classes = getILTClasses(jobCourses.keySet(), startDate, endDate);
                    System.debug('Number of ILT classes: ' + classes.size());

                    Map<Id, Integer> seatsAvailable = getAvailabilityForClasses(new Map<Id, redwing__ILT_Class__c>(classes).keySet());

                    Map<Id, sked__Job__c> jobs = getSkeduloJobs(jobCourses.keySet());
//                    jobs = getNearbyJobs(jobs, city, state, postalCode, range);

                    List<Object> classCourses = buildClassCourses(classes, jobs, communityProducts, jobCourses, seatsAvailable);
                    for (Object obj: classCourses) {
                        System.debug('class: ' + obj);
                    }
                }
            }

        } catch (Exception e) {
            System.debug('Community Class Search: exception caught: ' + e.getMessage());
        }
    }
}