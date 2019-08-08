public class DateUtil {
    
    public enum format { YYYY_MM_DD }

    public static Date parse(String dateStr, DateUtil.format format) {
        if (format ==  DateUtil.format.YYYY_MM_DD) {
            List<String> components = dateStr.split('-');
            if (components.size() == 3) {
                Integer year = Integer.valueOf(components.get(0));
                Integer month = Integer.valueOf(components.get(1));
                Integer day = Integer.valueOf(components.get(2));
                return Date.newInstance(year, month, day);
            }
        }
        
        return null;
    }
}