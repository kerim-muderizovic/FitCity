// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get commonSignIn => 'Anmelden';

  @override
  String get commonSignOut => 'Abmelden';

  @override
  String get commonSettings => 'Einstellungen';

  @override
  String commonRoleLabel(Object role) {
    return 'Rolle: $role';
  }

  @override
  String get commonGuest => 'Gast';

  @override
  String get commonNotSignedIn => 'Nicht angemeldet';

  @override
  String get commonTryAgain => 'Bitte versuchen Sie es erneut.';

  @override
  String get errorsGeneric =>
      'Etwas ist schiefgelaufen. Bitte versuchen Sie es später erneut.';

  @override
  String get errorsNetwork =>
      'Netzwerkfehler. Bitte prüfen Sie Ihre Internetverbindung und versuchen Sie es erneut.';

  @override
  String get errorsValidation =>
      'Bitte prüfen Sie Ihre Eingaben und versuchen Sie es erneut.';

  @override
  String get errorRegistrationDisabled =>
      'Neue Benutzerregistrierungen sind derzeit deaktiviert.';

  @override
  String get errorTrainerCreationDisabled =>
      'Das Hinzufügen neuer Trainer ist derzeit deaktiviert.';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profilePhotoTooLarge => 'Das Foto muss 5 MB oder kleiner sein.';

  @override
  String get profilePhotoInvalidType =>
      'Nur JPG-, PNG- oder WebP-Dateien sind erlaubt.';

  @override
  String get profileChooseFromGallery => 'Aus der Galerie wählen';

  @override
  String get profileTakePhoto => 'Foto aufnehmen';

  @override
  String get profilePhotoUploadFailed =>
      'Das Foto kann derzeit nicht hochgeladen werden. Bitte versuchen Sie es erneut.';

  @override
  String get profilePhotoUpdated => 'Foto aktualisiert.';

  @override
  String get profileCurrentGym => 'Aktuelles Fitnessstudio';

  @override
  String get profileSwitchGym => 'Fitnessstudio wechseln';

  @override
  String get profileMemberships => 'Mitgliedschaften';

  @override
  String get profileNoActiveMemberships => 'Keine aktiven Mitgliedschaften.';

  @override
  String get profileActivePass => 'Aktiver Pass';

  @override
  String get profileAllMemberships => 'Alle Mitgliedschaften';

  @override
  String get profileTrainerTools => 'Trainer-Tools';

  @override
  String get profileSchedule => 'Zeitplan';

  @override
  String get profileRequests => 'Anfragen';

  @override
  String get profileTrainerChat => 'Trainer-Chat';

  @override
  String get profilePreferences => 'Präferenzen';

  @override
  String get profilePreferencesEmpty => 'Noch keine Präferenzen gespeichert.';

  @override
  String get profilePersonalInformation => 'Persönliche Informationen';

  @override
  String get profileNotifications => 'Benachrichtigungen';

  @override
  String get profileEdit => 'Profil bearbeiten';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsPushNotifications => 'Push-Benachrichtigungen';

  @override
  String get settingsAutoRenew => 'Mitgliedschaft automatisch verlängern';

  @override
  String get settingsChangePassword => 'Passwort ändern';

  @override
  String get settingsTermsOfService => 'Nutzungsbedingungen';

  @override
  String get settingsTermsTodo =>
      'Nutzungsbedingungen sind derzeit nicht verfügbar.';

  @override
  String get settingsGeneral => 'Allgemein';

  @override
  String get settingsAllowGymRegistrations =>
      'Neue Fitnessstudio-Registrierungen zulassen';

  @override
  String get settingsAllowUserRegistrations =>
      'Neue Benutzerregistrierungen zulassen';

  @override
  String get settingsAllowTrainerCreation =>
      'Hinzufügen neuer Trainer zulassen';

  @override
  String get settingsSave => 'Einstellungen speichern';

  @override
  String get languageEnglish => 'Englisch';

  @override
  String get languageBosnian => 'Bosnisch';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get authLoginFailed =>
      'Anmeldung fehlgeschlagen. Bitte versuchen Sie es erneut.';

  @override
  String get authAuthenticationFailed =>
      'Authentifizierung fehlgeschlagen. Bitte versuchen Sie es erneut.';

  @override
  String get authDesktopWorkspace => 'Desktop-Arbeitsbereich';

  @override
  String get authAccessTitle => 'FitCity-Zugang';

  @override
  String get authLogin => 'Anmelden';

  @override
  String get authRegister => 'Registrieren';

  @override
  String get authEmailLabel => 'E-Mail';

  @override
  String get authPasswordLabel => 'Passwort';

  @override
  String get authConfirmPasswordLabel => 'Passwort bestätigen';

  @override
  String get authFullNameLabel => 'Vollständiger Name';

  @override
  String get authPhoneOptionalLabel => 'Telefonnummer (optional)';

  @override
  String get authPleaseWait => 'Bitte warten...';

  @override
  String get authCreateAccount => 'Konto erstellen';

  @override
  String get authNotAuthenticatedYet => 'Noch nicht angemeldet.';

  @override
  String get authCurrentUser => 'Aktueller Nutzer';

  @override
  String get authEmailRequired => 'E-Mail ist erforderlich.';

  @override
  String get authEmailInvalid =>
      'Bitte geben Sie eine gültige E-Mail-Adresse ein.';

  @override
  String get authPasswordRequired => 'Passwort ist erforderlich.';

  @override
  String get authPasswordTooShort =>
      'Das Passwort muss mindestens 8 Zeichen lang sein.';

  @override
  String get authConfirmPasswordRequired =>
      'Bitte bestätigen Sie Ihr Passwort.';

  @override
  String get authPasswordMismatch => 'Passwörter stimmen nicht überein.';

  @override
  String get authFullNameRequired => 'Vollständiger Name ist erforderlich.';

  @override
  String get authSuccessSnackbar => 'Erfolgreich angemeldet.';

  @override
  String get errorsInvalidCredentials => 'Ungültige Anmeldedaten.';

  @override
  String get profilePhotoRequired =>
      'Bitte wählen Sie ein Foto zum Hochladen aus.';

  @override
  String get adminLoginTitle => 'FitCity Admin';

  @override
  String adminLoginSubtitle(Object role) {
    return 'Melden Sie sich mit einem $role-Konto an, um fortzufahren.';
  }

  @override
  String get adminRoleCentral => 'Zentraler Administrator';

  @override
  String get adminRoleGym => 'Fitnessstudio-Administrator';

  @override
  String get adminRoleAdministrator => 'Administrator';

  @override
  String get adminAccessRequired =>
      'Administratorzugriff ist für diesen Bereich erforderlich.';

  @override
  String get adminSigningIn => 'Anmeldung läuft...';

  @override
  String get navGyms => 'Studios';

  @override
  String get navPass => 'Pass';

  @override
  String get navBookings => 'Buchungen';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfile => 'Profil';

  @override
  String get navAlerts => 'Hinweise';

  @override
  String get navSchedule => 'Zeitplan';

  @override
  String get navRequests => 'Anfragen';

  @override
  String get changePasswordTitle => 'Passwort ändern';

  @override
  String get changePasswordUpdateTitle => 'Passwort aktualisieren';

  @override
  String get changePasswordCurrent => 'Aktuelles Passwort';

  @override
  String get changePasswordNew => 'Neues Passwort';

  @override
  String get changePasswordConfirm => 'Neues Passwort bestätigen';

  @override
  String get changePasswordAllRequired => 'Alle Felder sind erforderlich.';

  @override
  String get changePasswordMismatch => 'Neue Passwörter stimmen nicht überein.';

  @override
  String get changePasswordTooShort =>
      'Das Passwort muss mindestens 6 Zeichen lang sein.';

  @override
  String get changePasswordSuccess => 'Passwort erfolgreich geändert.';

  @override
  String get changePasswordSaving => 'Speichern...';

  @override
  String get changePasswordSave => 'Ã„nderungen speichern';

  @override
  String get gymNoSelection => 'Kein Studio ausgewählt';

  @override
  String gymCurrentLabel(Object name) {
    return 'Aktuelles Studio: $name';
  }

  @override
  String get gymSwitch => 'Wechseln';

  @override
  String get gymGuardSelect =>
      'Bitte wählen Sie ein Studio aus, um fortzufahren.';

  @override
  String get gymGuardChooseList => 'Aus Liste wählen';

  @override
  String get gymGuardOpenMap => 'Karte öffnen';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonDelete => 'Löschen';

  @override
  String get commonClose => 'SchlieÃŸen';

  @override
  String get commonSave => 'Speichern';

  @override
  String get commonView => 'Ansehen';

  @override
  String get commonLater => 'Später';

  @override
  String get commonAll => 'Alle';

  @override
  String get commonPending => 'Ausstehend';

  @override
  String get commonApproved => 'Genehmigt';

  @override
  String get commonRejected => 'Abgelehnt';

  @override
  String get commonActive => 'Aktiv';

  @override
  String get commonInactive => 'Inaktiv';

  @override
  String get commonRefresh => 'Aktualisieren';

  @override
  String get commonBack => 'Zurück';

  @override
  String get commonMembers => 'Mitglieder';

  @override
  String get commonTrainers => 'Trainer';

  @override
  String get commonGyms => 'Studios';

  @override
  String get commonPayments => 'Zahlungen';

  @override
  String get commonDashboard => 'Dashboard';

  @override
  String get commonNotifications => 'Benachrichtigungen';

  @override
  String get commonAccessLogs => 'Zugangsprotokolle';

  @override
  String get commonMemberships => 'Mitgliedschaften';

  @override
  String get commonAnalytics => 'Analysen';

  @override
  String get commonNoResults => 'Noch keine Ergebnisse.';

  @override
  String get commonNoData => 'Noch keine Daten.';

  @override
  String get commonUnknown => 'Unbekannt';

  @override
  String get commonWorking => 'In Arbeit...';

  @override
  String get commonCreate => 'Erstellen';

  @override
  String get desktopAppTitle => 'FitCity';

  @override
  String get desktopUnableLoadAdmin =>
      'Admin-Daten konnten nicht geladen werden';

  @override
  String get adminNewMembershipRequestTitle => 'Neue Mitgliedschaftsanfrage';

  @override
  String adminNewMembershipRequestBody(Object count, Object suffix) {
    return 'Sie haben $count neue Benachrichtigung$suffix zur Mitgliedschaftsanfrage.';
  }

  @override
  String get adminViewRequests => 'Anfragen ansehen';

  @override
  String get adminGymListTitle => 'Studio-Liste';

  @override
  String get adminNoGymsFound => 'Keine Studios gefunden.';

  @override
  String get adminDeleteMemberTitle => 'Mitglied löschen';

  @override
  String get adminDeleteMemberConfirm =>
      'Dies löscht das Mitglied dauerhaft, sofern keine verbundenen Datensätze existieren. Fortfahren?';

  @override
  String get adminMemberDetails => 'Mitgliederdetails';

  @override
  String adminMembershipStatus(Object status) {
    return 'Status: $status';
  }

  @override
  String adminMembershipEnds(Object date) {
    return 'Endet: $date';
  }

  @override
  String get adminManageMembers => 'Mitglieder verwalten';

  @override
  String adminRecordsCount(Object count) {
    return '$count Einträge';
  }

  @override
  String get adminNoMembershipsFound => 'Keine Mitgliedschaften gefunden.';

  @override
  String get adminValidate => 'Validieren';

  @override
  String get adminRejectMembershipTitle => 'Mitgliedschaftsanfrage ablehnen';

  @override
  String get adminRejectionReason => 'Ablehnungsgrund';

  @override
  String get adminMembershipRequests => 'Mitgliedschaftsanfragen';

  @override
  String get adminNoMembershipRequests =>
      'Keine Mitgliedschaftsanfragen gefunden.';

  @override
  String get adminPaymentsTitle => 'Zahlungen';

  @override
  String get adminNoPaymentsFound => 'Keine Zahlungen gefunden.';

  @override
  String get adminAddMember => 'Mitglied hinzufügen';

  @override
  String get adminAddTrainer => 'Trainer hinzufügen';

  @override
  String get adminMembersTitle => 'Mitglieder';

  @override
  String get adminScanQr => 'QR-Code scannen';

  @override
  String get adminNoMembersFound => 'Keine Mitglieder gefunden.';

  @override
  String get adminAllGyms => 'Alle Studios';

  @override
  String get adminAllCities => 'Alle Städte';

  @override
  String get adminAllStatuses => 'Alle Status';

  @override
  String adminHoursLabel(Object hours) {
    return 'Ã–ffnungszeiten: $hours';
  }

  @override
  String adminMembersCount(Object count) {
    return '$count Mitglieder';
  }

  @override
  String adminTrainersCount(Object count) {
    return '$count Trainer';
  }

  @override
  String get adminNoMemberships => 'Keine Mitgliedschaften';

  @override
  String adminTrainerRate(Object rate) {
    return '$rate KM/Std.';
  }

  @override
  String adminTrainerUpcoming(Object count) {
    return '$count bevorstehend';
  }

  @override
  String get adminTrainersTitle => 'Trainer';

  @override
  String adminTrainersActive(Object count) {
    return '$count aktiv';
  }

  @override
  String get adminNoTrainersFound => 'Keine Trainer gefunden.';

  @override
  String get adminAccessLogsTitle => 'Zugangsprotokolle';

  @override
  String get adminAccessGranted => 'Gewährt';

  @override
  String get adminAccessDenied => 'Verweigert';

  @override
  String get adminNoAccessLogs => 'Keine Zugangsprotokolle gefunden.';

  @override
  String get adminAccessLogTitle => 'Zugangsprotokoll';

  @override
  String get adminNoNotifications => 'Noch keine Benachrichtigungen.';

  @override
  String get adminReferenceData => 'Referenzdaten';

  @override
  String get adminNoGymPlans => 'Keine Studio-Pläne gefunden.';

  @override
  String get adminEdit => 'Bearbeiten';

  @override
  String get adminDeleteGymPlanTitle => 'Studio-Plan löschen';

  @override
  String adminDeleteGymPlanConfirm(Object name) {
    return '\"$name\" löschen?';
  }

  @override
  String adminPlanLine(Object gym, Object months) {
    return '$gym â€¢ $months Monate';
  }

  @override
  String adminPlanPrice(Object price) {
    return '$price KM';
  }

  @override
  String get adminNoMembershipsYet => 'Noch keine Mitgliedschaften.';

  @override
  String get adminNoBookingsYet => 'Noch keine Buchungen.';

  @override
  String get adminNoGymAssociation => 'Noch keine Studio-Zuordnung.';

  @override
  String get adminNoScheduleEntries => 'Keine Zeitplaneinträge.';

  @override
  String get adminNoSessionsRecorded => 'Keine Sitzungen aufgezeichnet.';

  @override
  String get adminActiveGyms => 'Aktive Studios';

  @override
  String adminTotalGyms(Object count) {
    return '$count gesamt';
  }

  @override
  String get adminMemberLabel => 'Mitglied';

  @override
  String get adminMembershipRequestLabel => 'Mitgliedschaftsanfrage';

  @override
  String get adminNotificationsLabel => 'Benachrichtigungen';

  @override
  String adminCurrencyKm(Object amount) {
    return '$amount KM';
  }

  @override
  String get adminNoReportData => 'Noch keine Berichtsdaten.';

  @override
  String get adminNoRevenueData => 'Noch keine Umsatzdaten.';

  @override
  String get adminNoTrainerActivity => 'Noch keine Traineraktivität.';

  @override
  String adminReportLine(Object month, Object year, Object count) {
    return '$month/$year â€¢ $count neu';
  }

  @override
  String adminRevenueLine(Object month, Object year, Object amount) {
    return '$month/$year â€¢ $amount';
  }

  @override
  String adminTrainerActivityLine(Object name, Object count) {
    return '$name â€¢ $count Buchungen';
  }

  @override
  String adminDeleteMemberConfirmName(Object name) {
    return '$name löschen? Dies kann nicht rückgängig gemacht werden.';
  }

  @override
  String get adminMembershipLabel => 'Mitgliedschaft';

  @override
  String get adminNoMembershipData => 'Noch keine Mitgliedschaftsdaten.';

  @override
  String get desktopAppName => 'FitCity App';

  @override
  String get adminScanQrCode => 'QR-Code scannen';

  @override
  String get adminScanQrHint => 'Richte den Code im Rahmen aus.';

  @override
  String get adminAddMemberPlus => '+ Mitglied hinzufügen';

  @override
  String get adminAddGymTitle => 'Fitnessstudio hinzufügen';

  @override
  String get adminCreateGym => 'Fitnessstudio erstellen';

  @override
  String get adminGymCreated => 'Fitnessstudio erstellt.';

  @override
  String get adminGymNameLabel => 'Name des Fitnessstudios';

  @override
  String get adminGymNameRequired =>
      'Der Name des Fitnessstudios ist erforderlich.';

  @override
  String get adminGymAddressLabel => 'Adresse (optional)';

  @override
  String get adminGymCityLabel => 'Stadt (optional)';

  @override
  String get adminGymPhoneLabel => 'Kontakttelefon (optional)';

  @override
  String get adminGymDescriptionLabel => 'Beschreibung (optional)';

  @override
  String get adminGymWorkHoursLabel => 'Öffnungszeiten (optional)';

  @override
  String get adminGymLocationLabel => 'Standort';

  @override
  String get adminGymLocationHint =>
      'Klicken Sie auf die Karte, um den Standort festzulegen.';

  @override
  String adminGymLocationLatLng(Object lat, Object lng) {
    return 'Ausgewählt: $lat, $lng';
  }

  @override
  String get adminGymLocationRequired => 'Standort ist erforderlich.';

  @override
  String get adminGymLocationMissing => 'Standort nicht gesetzt';

  @override
  String get adminGymSearchAddressHint => 'Adresse suchen';

  @override
  String get adminGymSearchAddressAction => 'Suchen';

  @override
  String get adminGymAddressSearchFailed =>
      'Adresse kann derzeit nicht gesucht werden.';

  @override
  String get adminGymEntryQrTitle => 'QR-Code für Eintritt';

  @override
  String get adminGymEntryQrHint => 'Diesen Code am Eingang anzeigen.';

  @override
  String get adminScannerTitle => 'Scanner';

  @override
  String get adminScannerPause => 'Pause';

  @override
  String get adminScannerResume => 'Fortsetzen';

  @override
  String get adminScannerStatusIdle => 'Bereit';

  @override
  String get adminScannerStatusScanning => 'Scannen';

  @override
  String get adminScannerStatusPaused => 'Pausiert';

  @override
  String get adminScannerStatusSuccess => 'Erfolg';

  @override
  String get adminScannerStatusError => 'Fehler';

  @override
  String get adminScannerInvalidQr =>
      'Dieser QR-Code ist kein FitCity-Mitglieds-QR.';

  @override
  String get adminScannerEntryQr =>
      'Das ist ein Studio/Entry-QR. Bitte den Mitglieds-QR scannen.';

  @override
  String get adminScannerMemberTokenMissing => 'Mitglieds-QR-Token fehlt.';

  @override
  String get adminScannerDuplicate => 'Bereits gescannt. Bitte warten...';

  @override
  String get commonName => 'Name';

  @override
  String get commonEmail => 'E-Mail';

  @override
  String get commonMembership => 'Mitgliedschaft';

  @override
  String get membershipAnnual => 'Jährlich';

  @override
  String get membershipMonthly => 'Monatlich';

  @override
  String get sampleMemberName => 'John Doe';

  @override
  String get sampleMemberEmail => 'johndoe@gmail.com';

  @override
  String get notificationsTitle => 'Benachrichtigungen';

  @override
  String get notificationsMarkAllRead => 'Alle als gelesen markieren';

  @override
  String get notificationsEmpty => 'Noch keine Benachrichtigungen.';

  @override
  String get notificationRead => 'Gelesen';

  @override
  String get notificationNew => 'Neu';

  @override
  String get bookingsTitle => 'Buchungen';

  @override
  String get bookingsUpcomingTab => 'Bevorstehende Buchungen';

  @override
  String get bookingsEntryHistoryTab => 'Eintrittsverlauf';

  @override
  String get bookingsNoUpcoming => 'Keine bevorstehenden Termine.';

  @override
  String bookingsStatusLabel(Object status) {
    return 'Status: $status';
  }

  @override
  String bookingsTrainerLabel(Object name) {
    return 'Trainer: $name';
  }

  @override
  String bookingsGymLabel(Object name) {
    return 'Studio: $name';
  }

  @override
  String bookingsStartLabel(Object date) {
    return 'Start: $date';
  }

  @override
  String bookingsPaymentLabel(Object status) {
    return 'Zahlung: $status';
  }

  @override
  String get bookingsNoEntries =>
      'Noch keine Studioeintritte. Scannen Sie Ihren QR-Code im Studio, um den ersten Eintrag zu erstellen.';

  @override
  String get bookingsGymEntry => 'Studioeintritt';

  @override
  String get bookingsEntered => 'Eingetreten';

  @override
  String get bookingScreenTitle => 'Trainer buchen';

  @override
  String get bookingSelectGymMessage =>
      'Wählen Sie ein Studio, um einen Trainer zu buchen.';

  @override
  String get bookingLocationLabel => 'Standort';

  @override
  String get bookingTrainerLabel => 'Trainer';

  @override
  String bookingDateLabel(Object date) {
    return 'Datum: $date';
  }

  @override
  String get bookingPaymentCard => 'Karte';

  @override
  String get bookingPaymentPayPal => 'PayPal';

  @override
  String get bookingPaymentCash => 'Bar';

  @override
  String get bookingAvailableSlots => 'Verfügbare Zeiten';

  @override
  String get bookingSelectSlot => 'Zeit auswählen';

  @override
  String get bookingCreate => 'Buchung erstellen';

  @override
  String get bookingViewAll => 'Alle Buchungen ansehen';

  @override
  String get bookingTrainerNotFound => 'Trainer nicht gefunden.';

  @override
  String get bookingSelectSlotFirst =>
      'Bitte zuerst eine verfügbare Zeit auswählen.';

  @override
  String get bookingNoSlotsDate =>
      'Keine verfügbaren Zeiten für das ausgewählte Datum.';

  @override
  String get bookingNoSlotsRange =>
      'Keine verfügbaren Zeiten im ausgewählten Zeitraum.';

  @override
  String get bookingSlotAvailable => 'Verfügbar';

  @override
  String get bookingSlotBooked => 'Gebucht';

  @override
  String bookingTrainerRateLabel(Object name, Object rate) {
    return '$name - $rate KM/Std.';
  }

  @override
  String get bookingConfirmedTitle => 'Buchung bestätigt';

  @override
  String get bookingViewUpcoming => 'Bevorstehende Buchungen ansehen';

  @override
  String get bookingChatWithTrainer => 'Mit Trainer chatten';

  @override
  String bookingChatWithName(Object name) {
    return 'Chat mit $name';
  }

  @override
  String get bookingLabelTrainer => 'Trainer';

  @override
  String get bookingLabelGym => 'Studio';

  @override
  String get bookingLabelStart => 'Start';

  @override
  String get bookingLabelEnd => 'Ende';

  @override
  String get bookingLabelPayment => 'Zahlung';

  @override
  String get commonTrainer => 'Trainer';

  @override
  String get commonViewAll => 'Alle ansehen';

  @override
  String get membershipActivePassTitle => 'Aktiver Pass';

  @override
  String get membershipShowQrPass => 'QR-Pass anzeigen';

  @override
  String get membershipManageHint =>
      'Verwalten oder erneuern Sie Ihre Pläne in der Mitgliedschaftsliste.';

  @override
  String get membershipApprovedTitle => 'Mitgliedschaft genehmigt';

  @override
  String membershipPaymentStatus(Object status) {
    return 'Zahlungsstatus: $status';
  }

  @override
  String get membershipUnpaid => 'Unbezahlt';

  @override
  String membershipGymLabel(Object name) {
    return 'Studio: $name';
  }

  @override
  String get membershipPayAction => 'Mitgliedschaft bezahlen';

  @override
  String get membershipProcessing => 'Wird verarbeitet...';

  @override
  String get membershipPendingTitle => 'Mitgliedschaft ausstehend';

  @override
  String membershipStatusLabel(Object status) {
    return 'Status: $status';
  }

  @override
  String get membershipRejectedDefault =>
      'Ihre Mitgliedschaftsanfrage wurde abgelehnt.';

  @override
  String get membershipBrowseGyms => 'Studios durchsuchen';

  @override
  String get membershipExpiredTitle => 'Mitgliedschaft abgelaufen';

  @override
  String membershipExpiredOn(Object date) {
    return 'Abgelaufen am: $date';
  }

  @override
  String get membershipRenew => 'Mitgliedschaft erneuern';

  @override
  String get membershipNoActiveTitle => 'Keine aktive Mitgliedschaft';

  @override
  String get membershipBrowseHint =>
      'Durchsuchen Sie Studios, um mit einem Plan zu starten.';

  @override
  String get membershipNoData => 'Keine Mitgliedschaftsdaten gefunden.';

  @override
  String get membershipConfirmPaymentTitle => 'Zahlung bestätigen';

  @override
  String membershipConfirmPaymentBody(Object gymSuffix) {
    return 'Eine 30-tägige Mitgliedschaft$gymSuffix bezahlen? Ihr Pass wird sofort aktiviert.';
  }

  @override
  String get membershipPayNow => 'Jetzt bezahlen';

  @override
  String get membershipPaymentSuccessTitle => 'Zahlung erfolgreich';

  @override
  String get paymentOpenBrowser =>
      'Schließen Sie die Zahlung im Browser ab und kehren Sie dann zur App zurück.';

  @override
  String get paymentPendingConfirmation => 'Warten auf Zahlungsbestätigung...';

  @override
  String get paymentConfirmed => 'Zahlung bestätigt.';

  @override
  String get paymentInvalidCheckoutUrl => 'Ungültige Checkout-URL.';

  @override
  String get paymentLaunchFailed => 'Checkout kann nicht geöffnet werden.';

  @override
  String get paymentPayPalUnavailable =>
      'PayPal ist derzeit nicht verfügbar. Bitte Karte wählen.';

  @override
  String get paymentChooseMethod => 'Zahlungsmethode wählen';

  @override
  String get paymentUseStripe => 'Mit Karte zahlen (Stripe)';

  @override
  String get paymentMarkPaid => 'Als bezahlt markieren (lokal)';

  @override
  String get paymentManualDisabled => 'Lokale Zahlungen sind deaktiviert.';

  @override
  String membershipActiveUntil(Object date) {
    return 'Mitgliedschaft aktiv bis $date';
  }

  @override
  String get membershipShowQr => 'QR anzeigen';

  @override
  String get membershipPassLabel => 'Mitgliedschaftspass';

  @override
  String get membershipGymNameFallback => 'Studio';

  @override
  String membershipDaysLeft(Object count) {
    return '$count Tage übrig';
  }

  @override
  String membershipStartLabel(Object date) {
    return 'Start: $date';
  }

  @override
  String membershipEndLabel(Object date) {
    return 'Ende: $date';
  }

  @override
  String get commonSuccess => 'Erfolg';

  @override
  String get commonEntered => 'Eingetreten';

  @override
  String get chatTitle => 'Chat';

  @override
  String get chatNoConversations => 'Noch keine Unterhaltungen.';

  @override
  String get chatPaymentDetails => 'Zahlungsdetails';

  @override
  String get chatLoadEarlier => 'Ã„ltere Nachrichten laden';

  @override
  String get emailDemoTitle => 'E-Mail-Demo';

  @override
  String get gymDetailSignInToRequest =>
      'Bitte melden Sie sich an, um eine Mitgliedschaft zu beantragen.';

  @override
  String gymDetailMembershipRequest(Object status) {
    return 'Mitgliedschaftsanfrage: $status';
  }

  @override
  String get gymDetailChoosePayment => 'Zahlungsmethode wählen';

  @override
  String get gymDetailCard => 'Karte';

  @override
  String get gymDetailPayPal => 'PayPal';

  @override
  String gymDetailHoursLabel(Object hours) {
    return 'Ã–ffnungszeiten: $hours';
  }

  @override
  String get gymDetailTrainersTitle => 'Trainer';

  @override
  String get gymDetailNoTrainers => 'Noch keine Trainer zugewiesen.';

  @override
  String get gymDetailReviewsTitle => 'Bewertungen';

  @override
  String get gymDetailNoReviews => 'Noch keine Bewertungen.';

  @override
  String get gymDetailWaitingApproval => 'Warten auf Genehmigung';

  @override
  String get gymDetailApprovedPaymentRequired =>
      'Genehmigt - Zahlung erforderlich';

  @override
  String get gymDetailViewMemberships => 'Mitgliedschaften ansehen';

  @override
  String get gymDetailBookTrainer => 'Trainer buchen';

  @override
  String get gymDetailSwitchGym => 'Studio wechseln';

  @override
  String get gymDetailChat => 'Chat';

  @override
  String gymListTitle(Object city) {
    return 'Studios in $city';
  }

  @override
  String get gymListNoTrainerRecommendations =>
      'Noch keine Trainerempfehlungen.';

  @override
  String get gymListNoGymRecommendations => 'Noch keine Studioempfehlungen.';

  @override
  String get membershipListTitle => 'Mitgliedschaften';

  @override
  String membershipSignedInAs(Object email) {
    return 'Angemeldet als $email';
  }

  @override
  String get membershipSelectGym => 'Studio auswählen';

  @override
  String get membershipViewActivePass => 'Aktiven Pass anzeigen';

  @override
  String get membershipRequest => 'Mitgliedschaft beantragen';

  @override
  String membershipRequestStatus(Object status) {
    return 'Anfragestatus: $status';
  }

  @override
  String membershipQrToken(Object token) {
    return 'QR-Token: $token';
  }

  @override
  String get membershipActiveListTitle => 'Aktive Mitgliedschaften';

  @override
  String get membershipNoMemberships => 'Keine Mitgliedschaften gefunden.';

  @override
  String membershipStatusLine(Object status) {
    return 'Mitgliedschaft $status';
  }

  @override
  String membershipValidUntil(Object date) {
    return 'Gültig bis: $date';
  }

  @override
  String get membershipIssueQr => 'QR-Code ausstellen';

  @override
  String get mapTitle => 'FitCity-Karte';

  @override
  String get qrShowAtEntrance => 'Zeigen Sie diesen Code am Eingang';

  @override
  String get qrNotAvailable => 'QR nicht verfügbar';

  @override
  String qrExpiryDate(Object date) {
    return 'Ablaufdatum: $date';
  }

  @override
  String get qrDeniedTitle => 'Zutritt verweigert';

  @override
  String get qrDeniedWrongGym =>
      'Dieser QR-Code ist für dieses Studio ungültig.';

  @override
  String get qrDeniedExpired => 'Dieser QR-Code ist abgelaufen.';

  @override
  String get qrDeniedInactive => 'Mitgliedschaft ist inaktiv oder abgelaufen.';

  @override
  String get qrDeniedInvalid => 'Dieser QR-Code ist ungültig.';

  @override
  String get qrDeniedGeneric =>
      'Zutritt verweigert. Bitte versuchen Sie es erneut.';

  @override
  String qrTokenLabel(Object token) {
    return 'Token: $token';
  }

  @override
  String get reportsDesktopOnlyTitle =>
      'Adminberichte sind nur auf dem Desktop verfügbar.';

  @override
  String get reportsDesktopOnlyBody =>
      'Melden Sie sich in der Desktop-App an, um Analysen und Berichte zu sehen.';

  @override
  String get reportsTitle => 'Berichte';

  @override
  String get reportsBackHome => 'Zurück zur Startseite';

  @override
  String get recommendedTitle => 'Empfohlen';

  @override
  String get requestsOpenChats => 'Chats öffnen';

  @override
  String get requestsTitle => 'Trainingsanfragen';

  @override
  String get requestsEmpty => 'Derzeit keine ausstehenden Anfragen.';

  @override
  String get requestsDecline => 'Ablehnen';

  @override
  String get scheduleRequests => 'Trainingsanfragen';

  @override
  String get scheduleNoEntries => 'Noch keine Zeitplaneinträge.';

  @override
  String get trainerNotFound => 'Trainer nicht gefunden.';

  @override
  String get trainerTitle => 'Trainer';

  @override
  String get trainerWorkLocations => 'Arbeitsorte';

  @override
  String get trainerAbout => 'Ãœber';

  @override
  String get trainerCertifications => 'Zertifizierungen';

  @override
  String trainerRate(Object rate) {
    return '$rate KM/Std.';
  }

  @override
  String get emailDemoToLabel => 'An';

  @override
  String get emailDemoSubjectLabel => 'Betreff';

  @override
  String get emailDemoMessageLabel => 'Nachricht';

  @override
  String get emailDemoSend => 'Demo-E-Mail senden';

  @override
  String emailDemoQueued(Object email) {
    return 'Demo-E-Mail an $email in der Warteschlange.';
  }

  @override
  String get emailDemoDisclaimer =>
      'Dieser Bildschirm ist ein Mock. Echte E-Mails werden von FitCity.Notifications.Api über RabbitMQ gesendet.';

  @override
  String get profileEditTitle => 'Profil bearbeiten';

  @override
  String get profileFullNameLabel => 'Vollständiger Name';

  @override
  String get profileEmailLabel => 'E-Mail';

  @override
  String get profilePhoneLabel => 'Telefon';

  @override
  String get profileFullNameRequired => 'Vollständiger Name ist erforderlich.';

  @override
  String get commonSaving => 'Speichern...';

  @override
  String get commonSaveChanges => 'Ã„nderungen speichern';

  @override
  String get commonType => 'Typ';

  @override
  String get commonGym => 'Studio';

  @override
  String get commonCity => 'Stadt';

  @override
  String get commonStatus => 'Status';

  @override
  String get commonPriceKm => 'Preis (KM)';

  @override
  String get commonDurationMonths => 'Dauer (Monate)';

  @override
  String get commonDescription => 'Beschreibung';

  @override
  String get commonRetry => 'Erneut versuchen';

  @override
  String get commonSearch => 'Suchen';

  @override
  String get commonApprove => 'Genehmigen';

  @override
  String get commonDeleting => 'Löschen...';

  @override
  String get commonUpdating => 'Aktualisieren...';

  @override
  String get commonFromDate => 'Von Datum';

  @override
  String get commonToDate => 'Bis Datum';

  @override
  String get commonMember => 'Mitglied';

  @override
  String get commonPhone => 'Telefon';

  @override
  String get commonReason => 'Grund';

  @override
  String get commonTime => 'Zeit';

  @override
  String get commonRate => 'Satz';

  @override
  String get commonBio => 'Bio';

  @override
  String get commonSignedOut => 'Abgemeldet.';

  @override
  String get adminSectionManageGyms => 'Studios verwalten';

  @override
  String get adminSectionManageMembers => 'Mitglieder verwalten';

  @override
  String get adminSectionMembershipRequests => 'Mitgliedschaftsanfragen';

  @override
  String get adminSectionPayments => 'Zahlungen';

  @override
  String get adminSectionSettings => 'Einstellungen';

  @override
  String get adminDashboardCity => 'Sarajevo';

  @override
  String adminMapPinLabel(Object label) {
    return '$label';
  }

  @override
  String get adminAddGymPlus => '+ Studio hinzufügen';

  @override
  String get adminMembershipValid => 'Mitgliedschaft gültig.';

  @override
  String get adminMembershipInvalid => 'Mitgliedschaft ungültig.';

  @override
  String adminQrIssued(Object token) {
    return 'QR ausgegeben: $token';
  }

  @override
  String get adminMemberDeleted => 'Mitglied gelöscht.';

  @override
  String get adminMemberCreated => 'Mitglied erstellt.';

  @override
  String get adminTrainerAdded => 'Trainer hinzugefügt.';

  @override
  String get adminCreateRequiredFields =>
      'Name, E-Mail und Passwort sind erforderlich.';

  @override
  String adminPasswordMin(Object count) {
    return 'Das Passwort muss mindestens $count Zeichen lang sein.';
  }

  @override
  String get adminTrainerHourlyRateRequired => 'Stundensatz ist erforderlich.';

  @override
  String get adminTrainerPhotoUrlHint => 'Foto-URL (optional)';

  @override
  String get adminTrainerHourlyRateHint => 'Stundensatz';

  @override
  String get adminTrainerDescriptionHint => 'Beschreibung / Info (optional)';

  @override
  String get adminSearchMembersHint => 'Suche nach Name, E-Mail, Telefon';

  @override
  String get adminSearchMembershipsHint =>
      'Suche nach Benutzer, Studio, Status';

  @override
  String get adminSearchRequestsHint => 'Suche nach Mitglied, Studio, Status';

  @override
  String get adminSearchPaymentsHint => 'Suche Mitglied, Studio, Methode';

  @override
  String get adminSearchAllHint => 'Suche Studios, Mitglieder, Trainer';

  @override
  String get adminSearchTrainerHint => 'Trainer nach Name suchen';

  @override
  String get adminSearchGymsHint => 'Studios suchen';

  @override
  String get adminAccessLogSearchHint => 'Mitgliedersuche';

  @override
  String get adminSearchNotificationsHint => 'Benachrichtigungen suchen';

  @override
  String get adminSearchPlansHint => 'Studio-Pläne suchen';

  @override
  String get adminAddPlan => 'Plan hinzufügen';

  @override
  String get adminAddGymPlanTitle => 'Studio-Plan hinzufügen';

  @override
  String get adminEditGymPlanTitle => 'Studio-Plan bearbeiten';

  @override
  String get adminMembershipsPerMonthTitle => 'Mitgliedschaften pro Monat';

  @override
  String get adminRevenuePerMonthTitle => 'Umsatz pro Monat';

  @override
  String get adminTopTrainersTitle => 'Top-Trainer';

  @override
  String get adminMembershipGrowthTitle => 'Wachstum der Mitgliedschaften';

  @override
  String get adminRevenueTrendTitle => 'Umsatztrend';

  @override
  String get adminNoGyms => 'Keine Studios';

  @override
  String get adminNoCertifications => 'Keine Zertifikate';

  @override
  String get adminRequestApproved => 'Anfrage genehmigt.';

  @override
  String get adminRequestRejected => 'Anfrage abgelehnt.';

  @override
  String get adminDefaultRejectionReason =>
      'Leider sind wir derzeit ausgelastet. Bitte versuchen Sie es später erneut.';

  @override
  String get adminViewNotifications => 'Benachrichtigungen ansehen';

  @override
  String get adminMemberDetailNotFound => 'Mitgliedsdetails nicht gefunden.';

  @override
  String get adminTrainerDetailNotFound => 'Trainerdetails nicht gefunden.';

  @override
  String get adminMemberSince => 'Mitglied seit';

  @override
  String adminQrStatus(Object status) {
    return 'QR $status';
  }

  @override
  String get adminNoActiveQr => 'Kein aktiver QR-Pass';

  @override
  String adminQrExpires(Object date) {
    return 'Läuft ab $date';
  }

  @override
  String get adminNoAccessLogsYet => 'Noch keine Zutrittsprotokolle.';

  @override
  String adminLastAccess(Object date, Object gym) {
    return 'Letzter Zutritt: $date • $gym';
  }

  @override
  String get adminSessionsTitle => 'Sitzungen';

  @override
  String get locationServicesDisabled => 'Standortdienste sind deaktiviert.';

  @override
  String get locationPermissionDenied => 'Standortberechtigung verweigert.';

  @override
  String mapOpenGym(Object name) {
    return 'Öffnen $name';
  }

  @override
  String get qrPassTitle => 'QR-Pass';

  @override
  String get gymNameFallback => 'FitCity Studio';

  @override
  String trainerHourlyRate(Object rate) {
    return 'Stundensatz: $rate KM/Std.';
  }

  @override
  String get trainerHourlyRateNotSet => 'Stundensatz nicht festgelegt.';

  @override
  String get requestsTrainingSession => 'Trainingseinheit';

  @override
  String get commonAccept => 'Annehmen';

  @override
  String get bookingSlotBlocked => 'Blockiert';

  @override
  String get gymListRecommendedTrainersTitle => 'Empfohlene Trainer';

  @override
  String get gymListRecommendedGymsTitle => 'Empfohlene Studios';

  @override
  String get gymListSearchHint => 'Studios suchen';

  @override
  String get gymListLocating => 'Wird lokalisiert...';

  @override
  String get gymListSortDefault => 'Sortieren: Standard';

  @override
  String get gymListSortNearest => 'Sortieren: Nächste';

  @override
  String get gymListOpenMap => 'Karte öffnen';

  @override
  String gymListDistanceAway(Object distance) {
    return '$distance km entfernt';
  }
}
