@isTest
public class SS_CCUserProfileControllerTest {
	public static testMethod void testGetUserProfile() {
        User userProfile = SS_CCUserProfileController.getUserProfile(null);
        System.assertNotEquals(null, userProfile);
    }
}