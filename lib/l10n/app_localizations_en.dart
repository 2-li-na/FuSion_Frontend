// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get overview => 'Overview';

  @override
  String hello(String name) {
    return 'Hello $name!';
  }

  @override
  String get yourActivity => 'Your Activity';

  @override
  String get healthConnectConnected => 'Health Connect connected - Automatic step tracking active';

  @override
  String get healthConnectNotConnected => 'Health Connect not connected - Test data is used';

  @override
  String get refreshSteps => 'Refresh steps';

  @override
  String get todaysSteps => 'Today\'s Steps';

  @override
  String get weeklyAverage => 'Weekly Average';

  @override
  String get points => 'Points';

  @override
  String get testMode => 'Test Mode';

  @override
  String get automaticallySynchronized => 'Automatically Synchronized';

  @override
  String get departmentStrength => 'Department Strength';

  @override
  String get registeredUsersPerDepartment => 'Registered Users per Department';

  @override
  String totalRegisteredUsers(int count) {
    return 'Total: $count registered users';
  }

  @override
  String get rewards => 'Rewards Catalog';

  @override
  String get faq => 'FAQ';

  @override
  String get imprint => 'Imprint';

  @override
  String get privacy => 'Privacy';

  @override
  String get feedback => 'Feedback';

  @override
  String get redeemReward => 'Redeem Reward';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get german => 'German';

  @override
  String get logout => 'Logout';

  @override
  String get noEmailAvailable => 'No email available';

  @override
  String get stepTrackerDebug => 'Step Tracker Debug';

  @override
  String get synchronizeSteps => 'Synchronize Steps';

  @override
  String get ok => 'OK';

  @override
  String get profile => 'Profile';

  @override
  String get profilePictureUpdated => 'Profile picture updated!';

  @override
  String get uploadFailed => 'Upload failed';

  @override
  String errorMessage(String error) {
    return 'Error: $error';
  }

  @override
  String get changePassword => 'Change Password';

  @override
  String get oldPassword => 'Old Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get cancel => 'Cancel';

  @override
  String get change => 'Change';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordChangedSuccessfully => 'Password changed successfully';

  @override
  String get errorChangingPassword => 'Error changing password';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountConfirmation => 'Are you sure you want to delete your account? This action cannot be undone.';

  @override
  String get delete => 'Delete';

  @override
  String get errorDeletingAccount => 'Error deleting account';

  @override
  String get changeAvatar => 'Change Avatar';

  @override
  String get totalSteps => 'Total\nSteps';

  @override
  String get redeemedRewards => 'Redeemed Rewards';

  @override
  String get noRedeemedRewards => 'No redeemed rewards';

  @override
  String get yourActivities => 'Your Activities';

  @override
  String get forOneYear => 'For a year';

  @override
  String get lastSevenDays => 'Last 7 Days';

  @override
  String get forEntireMonth => 'For the entire month';

  @override
  String get changePasswordButton => 'Change Password';

  @override
  String get deleteAccountButton => 'Delete Account';

  @override
  String get yearlyActivityTitle => 'Your Activity for a Year';

  @override
  String get steps => 'Steps';

  @override
  String get noData => 'No Data';

  @override
  String get total => 'Total';

  @override
  String get average => 'Average';

  @override
  String get highest => 'Highest';

  @override
  String get monthlyOverview => 'Monthly Overview';

  @override
  String get january => 'January';

  @override
  String get february => 'February';

  @override
  String get march => 'March';

  @override
  String get april => 'April';

  @override
  String get may => 'May';

  @override
  String get june => 'June';

  @override
  String get july => 'July';

  @override
  String get august => 'August';

  @override
  String get september => 'September';

  @override
  String get october => 'October';

  @override
  String get november => 'November';

  @override
  String get december => 'December';

  @override
  String get januaryShort => 'Jan';

  @override
  String get februaryShort => 'Feb';

  @override
  String get marchShort => 'Mar';

  @override
  String get aprilShort => 'Apr';

  @override
  String get mayShort => 'May';

  @override
  String get juneShort => 'Jun';

  @override
  String get julyShort => 'Jul';

  @override
  String get augustShort => 'Aug';

  @override
  String get septemberShort => 'Sep';

  @override
  String get octoberShort => 'Oct';

  @override
  String get novemberShort => 'Nov';

  @override
  String get decemberShort => 'Dec';

  @override
  String get sevenDayActivityTitle => 'Your Activity for the Last 7 Days';

  @override
  String get dailyOverview => 'Daily Overview';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get mondayShort => 'Mon';

  @override
  String get tuesdayShort => 'Tue';

  @override
  String get wednesdayShort => 'Wed';

  @override
  String get thursdayShort => 'Thu';

  @override
  String get fridayShort => 'Fri';

  @override
  String get saturdayShort => 'Sat';

  @override
  String get sundayShort => 'Sun';

  @override
  String get monthlyActivityTitle => 'Your Activity for the Month';

  @override
  String get date => 'Date';

  @override
  String get faqQuestion1 => 'Where does FuSion come from?';

  @override
  String get faqAnswer1 => 'FuSion was developed as part of the university project \'Bewegt studieren-Studieren bewegt 2.0\' by the General German University Sports Association and the health insurance provider Techniker Krankenkassen to motivate students at Fulda University of Applied Sciences to be more active in everyday life.\nFulda University of Applied Sciences\' Sports Centre received active support for the development from a project of the e-health study programme and a Master\'s thesis and is being further developed and operated by a team of students under the direction of the Sports Centre.';

  @override
  String get faqQuestion2 => 'What was that department challenge again?';

  @override
  String get faqAnswer2 => 'Note: This is planned for the future. The department challenge is a competition in which departments compete against each other. When you log in for the first time, you will be asked for the department in which you work or study. The team for administration employees is called \'Administration\'. \nIn this competition, all steps of the respective department are taken into account and a step average is calculated. The departments are ranked on the basis of this average. You can view this ranking in the app under the menu item Ranking. The teams/departments at the top of the ranking receive extra bonus points.';

  @override
  String get faqQuestion3 => 'I have read that i can receive bonuses for my social sevices?';

  @override
  String get faqAnswer3 => 'Yes, you read that right! Your personal daily average is calculated for each week. On Sunday evening, you will be credited with a certain number of points for your personal average. \nYou can see how many points you get for how many steps (weekly average) in the table below. After a week, your average is reset to zero and you start working on a new average every week on Monday. \nYou can then easily redeem the points you have earned for great rewards at Hochschulsport. \nyou can find a list of rewards below. \n2000 steps/day = 1 point\n3500 steps/day = 2 points\n5000 steps/day = 3 points\n6500 steps/day = 4 points\n8000 steps/day = 5 points\n10,000 steps/day = 6 points\n11,5000 steps/day = 7 points';

  @override
  String get faqQuestion4 => 'Can i give feedback?';

  @override
  String get faqAnswer4 => 'Please help us with the development with your feedback. Feel free to send us any comments, suggestions for improvement etc. by email to hochschulsport@hs-fulda.de.';

  @override
  String get faqQuestion5 => 'I have forgotten my password, what can I do?';

  @override
  String get faqAnswer5 => 'If you have forgotten your password, that\'s no problem. Please contact our support team at the email address fusion2024hsp@gmail.com and we will be happy to help you.';

  @override
  String get faqQuestion6 => 'I have technical questions, who can i contact?';

  @override
  String get faqAnswer6 => 'We have set up an extra email address for technical questions - please be patient if we don\'t reply immediately, we will definitely answer your email. \nfusion2024hsp@gmail.com';

  @override
  String get faqQuestion7 => 'How do I receive the reward?';

  @override
  String get faqAnswer7 => 'If you want to redeem a reward for your points, please send us an email. \nPlease include your name, the email address of your Fusion account, your username and the reward you would like in the email. \nWe will then send you with all further information, such as where you can pick up your reward. \n\nsamuel.rill@hs-fulda.de\n';

  @override
  String get faqQuestion8 => 'Can I receive extra points?';

  @override
  String get faqAnswer8 => 'Yes, you can. We\'ll give you five points if you help us a bit with the development.\nTo do this, go to the \'Feedback\' menu item in the app and participate in the survey there.\nPlease have your email address ready that you registered with in the app, so we can assign your questionnaire to your account and credit your well-earned point.';

  @override
  String get privacyText => 'Click here for the data protection statement:';

  @override
  String get privacyLink => 'https://www.hs-fulda.de/unsere-hochschule/a-z-alle-institutionen/hochschulsport/fusion';
}
