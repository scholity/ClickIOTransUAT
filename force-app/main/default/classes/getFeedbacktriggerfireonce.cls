public class getFeedbacktriggerfireonce {
// class is maintaining to run getfeedbacksurveytrigger once
private static boolean alreadyCreatedTasks = false;
public static boolean hasAlreadyCreatedFollowUpTasks() {
        return alreadyCreatedTasks;
    }

public static void setAlreadyCreatedFollowUpTasks() {
        alreadyCreatedTasks = true;
    }

}