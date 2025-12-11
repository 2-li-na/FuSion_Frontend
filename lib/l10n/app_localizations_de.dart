// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get overview => 'Übersicht';

  @override
  String hello(String name) {
    return 'Hallo $name!';
  }

  @override
  String get yourActivity => 'Deine Aktivität';

  @override
  String get healthConnectConnected => 'Health Connect verbunden - Automatische Schrittverfolgung aktiv';

  @override
  String get healthConnectNotConnected => 'Health Connect nicht verbunden - Testdaten werden verwendet';

  @override
  String get refreshSteps => 'Schritte aktualisieren';

  @override
  String get todaysSteps => 'Heutige Schritte';

  @override
  String get weeklyAverage => 'Wochen-Durchschnitt';

  @override
  String get points => 'Punkte';

  @override
  String get testMode => 'Testmodus';

  @override
  String get automaticallySynchronized => 'Automatisch synchronisiert';

  @override
  String get departmentStrength => 'Die Stärke der Fachbereiche';

  @override
  String get registeredUsersPerDepartment => 'Registrierte Benutzer pro Fachbereich';

  @override
  String totalRegisteredUsers(int count) {
    return 'Gesamt: $count registrierte Benutzer';
  }

  @override
  String get rewards => 'Prämienkatalog';

  @override
  String get faq => 'FAQ';

  @override
  String get imprint => 'Impressum';

  @override
  String get privacy => 'Datenschutz';

  @override
  String get feedback => 'Feedback';

  @override
  String get redeemReward => 'Prämie Einlösen';

  @override
  String get language => 'Sprache';

  @override
  String get english => 'Englisch';

  @override
  String get german => 'Deutsch';

  @override
  String get logout => 'Abmelden';

  @override
  String get noEmailAvailable => 'Keine E-Mail verfügbar';

  @override
  String get stepTrackerDebug => 'Step Tracker Debug';

  @override
  String get synchronizeSteps => 'Schritte synchronisieren';

  @override
  String get ok => 'OK';

  @override
  String get profile => 'Profil';

  @override
  String get profilePictureUpdated => 'Profilbild aktualisiert!';

  @override
  String get uploadFailed => 'Upload fehlgeschlagen';

  @override
  String errorMessage(String error) {
    return 'Fehler: $error';
  }

  @override
  String get changePassword => 'Passwort ändern';

  @override
  String get oldPassword => 'Altes Passwort';

  @override
  String get newPassword => 'Neues Passwort';

  @override
  String get confirmPassword => 'Passwort bestätigen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get change => 'Ändern';

  @override
  String get passwordsDoNotMatch => 'Passwörter stimmen nicht überein';

  @override
  String get passwordChangedSuccessfully => 'Passwort erfolgreich geändert';

  @override
  String get errorChangingPassword => 'Fehler beim Ändern';

  @override
  String get deleteAccount => 'Account löschen';

  @override
  String get deleteAccountConfirmation => 'Sind Sie sicher, dass Sie Ihren Account löschen möchten? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get delete => 'Löschen';

  @override
  String get errorDeletingAccount => 'Fehler beim Löschen des Accounts';

  @override
  String get changeAvatar => 'Avatar Ändern';

  @override
  String get totalSteps => 'Gesamte\nSchritte';

  @override
  String get redeemedRewards => 'Eingelöschte Prämien';

  @override
  String get noRedeemedRewards => 'Keine eingelöschten Prämien';

  @override
  String get yourActivities => 'Deine Aktivitäten';

  @override
  String get forOneYear => 'Für ein Jahr';

  @override
  String get lastSevenDays => 'Der letzten 7 Tage';

  @override
  String get forEntireMonth => 'Für den ganzen Monat';

  @override
  String get changePasswordButton => 'Passwort Ändern';

  @override
  String get deleteAccountButton => 'Account Löschen';

  @override
  String get yearlyActivityTitle => 'Deine Aktivität für ein Jahr';

  @override
  String get steps => 'Schritte';

  @override
  String get noData => 'Keine Daten';

  @override
  String get total => 'Gesamt';

  @override
  String get average => 'Durchschnitt';

  @override
  String get highest => 'Höchstwert';

  @override
  String get monthlyOverview => 'Monatliche Übersicht';

  @override
  String get january => 'Januar';

  @override
  String get february => 'Februar';

  @override
  String get march => 'März';

  @override
  String get april => 'April';

  @override
  String get may => 'Mai';

  @override
  String get june => 'Juni';

  @override
  String get july => 'Juli';

  @override
  String get august => 'August';

  @override
  String get september => 'September';

  @override
  String get october => 'Oktober';

  @override
  String get november => 'November';

  @override
  String get december => 'Dezember';

  @override
  String get januaryShort => 'Jan';

  @override
  String get februaryShort => 'Feb';

  @override
  String get marchShort => 'Mär';

  @override
  String get aprilShort => 'Apr';

  @override
  String get mayShort => 'Mai';

  @override
  String get juneShort => 'Jun';

  @override
  String get julyShort => 'Jul';

  @override
  String get augustShort => 'Aug';

  @override
  String get septemberShort => 'Sep';

  @override
  String get octoberShort => 'Okt';

  @override
  String get novemberShort => 'Nov';

  @override
  String get decemberShort => 'Dez';

  @override
  String get sevenDayActivityTitle => 'Deine Aktivität der letzten 7 Tage';

  @override
  String get dailyOverview => 'Tägliche Übersicht';

  @override
  String get monday => 'Montag';

  @override
  String get tuesday => 'Dienstag';

  @override
  String get wednesday => 'Mittwoch';

  @override
  String get thursday => 'Donnerstag';

  @override
  String get friday => 'Freitag';

  @override
  String get saturday => 'Samstag';

  @override
  String get sunday => 'Sonntag';

  @override
  String get mondayShort => 'Mo';

  @override
  String get tuesdayShort => 'Di';

  @override
  String get wednesdayShort => 'Mi';

  @override
  String get thursdayShort => 'Do';

  @override
  String get fridayShort => 'Fr';

  @override
  String get saturdayShort => 'Sa';

  @override
  String get sundayShort => 'So';

  @override
  String get monthlyActivityTitle => 'Deine Aktivität für den Monat';

  @override
  String get date => 'Datum';

  @override
  String get faqQuestion1 => 'Woher kommt FuSion?';

  @override
  String get faqAnswer1 => 'FuSion wurde als Teil des Hochschulprojektes \'Bewegt studieren-Studieren bewegt 2.0\' des Allgemeinen Deutschen Hochschulsportverbandes und der Techniker Krankenkassen entwickelt, um die Studierenden der Hochschule Fulda zu mehr Bewegung im Alltag zu animieren.\nDer Hochschulsport der Hochschule Fulda hat sich für die Entwicklung tatkräftige Unterstützung aus einem Projekt des Studiengangs Gesundheitstechnik und einer Master-Arbeit geholt und wird nur von einem Team aus Studierenden unter der Regie des Hochschulsportes weiterentwickelt und betrieben.';

  @override
  String get faqQuestion2 => 'Was war denn nochmal diese Fachbereichs-Challenge?';

  @override
  String get faqAnswer2 => 'Dies ist zukünftig in Planung. Die Fachbereichs-Challenge ist ein Wettbewerb, bei dem die Fachbereiche gegeneinander antreten. Beim ersten Log-in wirst du nach deinem Fachbereich, an dem du arbeitest oder studierst, gefragt. Das Team für die Mitarbeiter*innen der Verwaltung heißt \'Administration\'. Bei diesem Wettbewerb werden alle Schritte des jeweiligen Fachbereichs berücksichtigt und ein Schrittdurchschnitt berechnet.\nAuf Basis dieses Durchschnitts gibt es ein Ranking der Fachbereiche. Dieses Ranking kannst du dir in der App unter dem Menüpunkt Ranking ansehen. Die Teams/die Fachbereiche, die ganz oben im Ranking stehen, bekommen noch einmal extra Prämien-Punkte.';

  @override
  String get faqQuestion3 => 'Ich habe gelesen, dass ich für meine Leistung Prämien erhalten kann?';

  @override
  String get faqAnswer3 => 'Ja, da hast du richtig gelesen! Für jede Woche wird dein persönlicher Tagesdurchschnitt berechnet. Am Sonntagabend werden dir dann für deinen persönlichen Durchschnitt eine bestimmte Anzahl an Punkten gutgeschrieben. \nWie viele Punkte du für wie viele Schritte (Wochendurchschnitt) bekommst, kannst du in der untenstehenden Tabelle sehen. Nach einer Woche wird dein Durchschnitt wieder auf null gesetzt und du beginnst jede Woche am Montag an einem neuen Durchschnitt zu arbeiten. Deine erarbeiteten Punkte kannst du dann ganz einfach beim Hochschulsport gegen tolle Prämien einlösen. Eine Liste der Prämien kannst du auch unten finden.\n\n2000 Schritte/Tag = 1 Punkt\n3500 Schritte/Tag = 2 Punkte\n5000 Schritte/Tag = 3 Punkte\n6500 Schritte/Tag = 4 Punkte\n8000 Schritte/Tag = 5 Punkte\n10.000 Schritte/Tag = 6 Punkte\n11.5000 Schritte/Tag = 7 Punkte';

  @override
  String get faqQuestion4 => 'Kann ich feedback geben?';

  @override
  String get faqAnswer4 => 'Bitte hilf uns bei der Entwicklung mit deinem Feedback weiter. Teile uns gerne  Hinweise, Verbesserungsvorschläge etc. per Mail an hochschulsport@hs-fulda.de mit.';

  @override
  String get faqQuestion5 => 'Ich habe mein Passwort vergessen, was kann ich tun?';

  @override
  String get faqAnswer5 => 'Wenn du dein Passwort vergessen hast, dann ist das nicht schlimm. Bitte kontaktiere unseren Support unter der E-Mail-Adresse fusion2024hsp@gmail.com, wir helfen dir gerne weiter.';

  @override
  String get faqQuestion6 => 'Ich habe Technische Fragen, an wen kann ich mich denn wenden?';

  @override
  String get faqAnswer6 => 'Für technische Fragen haben wir eine extra E-Mail-Adresse eingerichtet – bitte habe etwas Geduld, wenn wir nicht sofort antworten, wir werden deine E-Mail auf jeden Fall beantworten. \nfusion2024hsp@gmail.com';

  @override
  String get faqQuestion7 => 'Wie erhalte ich die Prämie?';

  @override
  String get faqAnswer7 => 'Willst du eine Prämie gegen deine Punkte einlösen, dann schreib uns eine Mail. \nBitte schreib in die Mail deinen Namen, deine E-mail Adresse deines Fusion-Kontos, deinen Benutzernamen und die Prämie, die du gerne möchtest. \nAlle weiteren Infos, wie zum Beispiel wo du dir deine Prämie abholen kannst, lassen wir die dann zukommen. \n\nsamuel.rill@hs-fulda.de\n';

  @override
  String get faqQuestion8 => 'Kann ich Extra-Punkte erhalten?';

  @override
  String get faqAnswer8 => 'Ja, dass kannst du. Wir schenken die fünf Punkte, wenn du uns bei der Entwicklung ein wenig weiterhilfst.\nGehe dafür in der App auf den Menüpunkt \'Feedback\' und nehme an der hinterlegten Befragung teil.\nBitte halte deine E-mail Adresse bereit, mit der du dich bei der App angemeldet hast, damit wird deinen Fragebogen deinem Account zuordnen und dir deinen wohlverdienten Punkt gutschreiben können.';

  @override
  String get privacyText => 'Hier geht es zur Datenschutzerklärung:';

  @override
  String get privacyLink => 'https://www.hs-fulda.de/unsere-hochschule/a-z-alle-institutionen/hochschulsport/fusion';
}
