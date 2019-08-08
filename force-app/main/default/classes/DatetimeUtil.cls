public class DatetimeUtil {

    public enum format { YYYY_MM_DDTHH_MM_SSZ }

    public static Datetime parse(String datetimeStr, DatetimeUtil.format format) {
        if (format == DatetimeUtil.format.YYYY_MM_DDTHH_MM_SSZ) {
            List<String> components = datetimeStr.split('T');
            if (components.size() == 2) {
                String dateStr = components[0];
                String timeStr = components[1].removeEnd('Z');
                Datetime dt = Datetime.valueOfGmt(dateStr + ' ' + timeStr);
                return dt;
            }
        }

        return null;
    }
}