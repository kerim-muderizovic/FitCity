import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bs.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('bs'),
    Locale('de'),
  ];

  /// No description provided for @commonSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get commonSignIn;

  /// No description provided for @commonSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get commonSignOut;

  /// No description provided for @commonSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get commonSettings;

  /// No description provided for @commonRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role: {role}'**
  String commonRoleLabel(Object role);

  /// No description provided for @commonGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get commonGuest;

  /// No description provided for @commonNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Not signed in'**
  String get commonNotSignedIn;

  /// No description provided for @commonTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please try again.'**
  String get commonTryAgain;

  /// No description provided for @errorsGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again later.'**
  String get errorsGeneric;

  /// No description provided for @errorsNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your internet connection and try again.'**
  String get errorsNetwork;

  /// No description provided for @errorsValidation.
  ///
  /// In en, this message translates to:
  /// **'Please check your input and try again.'**
  String get errorsValidation;

  /// No description provided for @errorRegistrationDisabled.
  ///
  /// In en, this message translates to:
  /// **'New user registration is currently disabled.'**
  String get errorRegistrationDisabled;

  /// No description provided for @errorTrainerCreationDisabled.
  ///
  /// In en, this message translates to:
  /// **'Adding new trainers is currently disabled.'**
  String get errorTrainerCreationDisabled;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profilePhotoTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Photo must be 5MB or smaller.'**
  String get profilePhotoTooLarge;

  /// No description provided for @profilePhotoInvalidType.
  ///
  /// In en, this message translates to:
  /// **'Only JPG, PNG, or WebP files are allowed.'**
  String get profilePhotoInvalidType;

  /// No description provided for @profileChooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get profileChooseFromGallery;

  /// No description provided for @profileTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get profileTakePhoto;

  /// No description provided for @profilePhotoUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to upload photo right now. Please try again.'**
  String get profilePhotoUploadFailed;

  /// No description provided for @profilePhotoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Photo updated.'**
  String get profilePhotoUpdated;

  /// No description provided for @profileCurrentGym.
  ///
  /// In en, this message translates to:
  /// **'Current gym'**
  String get profileCurrentGym;

  /// No description provided for @profileSwitchGym.
  ///
  /// In en, this message translates to:
  /// **'Switch gym'**
  String get profileSwitchGym;

  /// No description provided for @profileMemberships.
  ///
  /// In en, this message translates to:
  /// **'Memberships'**
  String get profileMemberships;

  /// No description provided for @profileNoActiveMemberships.
  ///
  /// In en, this message translates to:
  /// **'No active memberships.'**
  String get profileNoActiveMemberships;

  /// No description provided for @profileActivePass.
  ///
  /// In en, this message translates to:
  /// **'Active pass'**
  String get profileActivePass;

  /// No description provided for @profileAllMemberships.
  ///
  /// In en, this message translates to:
  /// **'All memberships'**
  String get profileAllMemberships;

  /// No description provided for @profileTrainerTools.
  ///
  /// In en, this message translates to:
  /// **'Trainer tools'**
  String get profileTrainerTools;

  /// No description provided for @profileSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get profileSchedule;

  /// No description provided for @profileRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get profileRequests;

  /// No description provided for @profileTrainerChat.
  ///
  /// In en, this message translates to:
  /// **'Trainer chat'**
  String get profileTrainerChat;

  /// No description provided for @profilePreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get profilePreferences;

  /// No description provided for @profilePreferencesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No preferences saved yet.'**
  String get profilePreferencesEmpty;

  /// No description provided for @profilePersonalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get profilePersonalInformation;

  /// No description provided for @profileNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotifications;

  /// No description provided for @profileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEdit;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsPushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get settingsPushNotifications;

  /// No description provided for @settingsAutoRenew.
  ///
  /// In en, this message translates to:
  /// **'Auto-renew membership'**
  String get settingsAutoRenew;

  /// No description provided for @settingsChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get settingsChangePassword;

  /// No description provided for @settingsTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get settingsTermsOfService;

  /// No description provided for @settingsTermsTodo.
  ///
  /// In en, this message translates to:
  /// **'Terms of service are not available yet.'**
  String get settingsTermsTodo;

  /// No description provided for @settingsGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneral;

  /// No description provided for @settingsAllowGymRegistrations.
  ///
  /// In en, this message translates to:
  /// **'Allow new gym registrations'**
  String get settingsAllowGymRegistrations;

  /// No description provided for @settingsAllowUserRegistrations.
  ///
  /// In en, this message translates to:
  /// **'Allow new user registration'**
  String get settingsAllowUserRegistrations;

  /// No description provided for @settingsAllowTrainerCreation.
  ///
  /// In en, this message translates to:
  /// **'Allow adding new trainers'**
  String get settingsAllowTrainerCreation;

  /// No description provided for @settingsSave.
  ///
  /// In en, this message translates to:
  /// **'Save settings'**
  String get settingsSave;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageBosnian.
  ///
  /// In en, this message translates to:
  /// **'Bosanski'**
  String get languageBosnian;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// No description provided for @authLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please try again.'**
  String get authLoginFailed;

  /// No description provided for @authAuthenticationFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Please try again.'**
  String get authAuthenticationFailed;

  /// No description provided for @authDesktopWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Desktop workspace'**
  String get authDesktopWorkspace;

  /// No description provided for @authAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'FitCity Access'**
  String get authAccessTitle;

  /// No description provided for @authLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authLogin;

  /// No description provided for @authRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegister;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPasswordLabel;

  /// No description provided for @authFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get authFullNameLabel;

  /// No description provided for @authPhoneOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number (optional)'**
  String get authPhoneOptionalLabel;

  /// No description provided for @authPleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get authPleaseWait;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccount;

  /// No description provided for @authNotAuthenticatedYet.
  ///
  /// In en, this message translates to:
  /// **'Not authenticated yet.'**
  String get authNotAuthenticatedYet;

  /// No description provided for @authCurrentUser.
  ///
  /// In en, this message translates to:
  /// **'Current user'**
  String get authCurrentUser;

  /// No description provided for @authEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required.'**
  String get authEmailRequired;

  /// No description provided for @authEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get authEmailInvalid;

  /// No description provided for @authPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required.'**
  String get authPasswordRequired;

  /// No description provided for @authPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters.'**
  String get authPasswordTooShort;

  /// No description provided for @authConfirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password.'**
  String get authConfirmPasswordRequired;

  /// No description provided for @authPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get authPasswordMismatch;

  /// No description provided for @authFullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name is required.'**
  String get authFullNameRequired;

  /// No description provided for @authSuccessSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Authenticated successfully.'**
  String get authSuccessSnackbar;

  /// No description provided for @errorsInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials.'**
  String get errorsInvalidCredentials;

  /// No description provided for @profilePhotoRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a photo to upload.'**
  String get profilePhotoRequired;

  /// No description provided for @adminLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'FitCity Admin'**
  String get adminLoginTitle;

  /// No description provided for @adminLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with a {role} account to continue.'**
  String adminLoginSubtitle(Object role);

  /// No description provided for @adminRoleCentral.
  ///
  /// In en, this message translates to:
  /// **'Central Administrator'**
  String get adminRoleCentral;

  /// No description provided for @adminRoleGym.
  ///
  /// In en, this message translates to:
  /// **'Gym Administrator'**
  String get adminRoleGym;

  /// No description provided for @adminRoleAdministrator.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get adminRoleAdministrator;

  /// No description provided for @adminAccessRequired.
  ///
  /// In en, this message translates to:
  /// **'Admin access required for this workspace.'**
  String get adminAccessRequired;

  /// No description provided for @adminSigningIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get adminSigningIn;

  /// No description provided for @navGyms.
  ///
  /// In en, this message translates to:
  /// **'Gyms'**
  String get navGyms;

  /// No description provided for @navPass.
  ///
  /// In en, this message translates to:
  /// **'Pass'**
  String get navPass;

  /// No description provided for @navBookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get navBookings;

  /// No description provided for @navChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get navAlerts;

  /// No description provided for @navSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get navSchedule;

  /// No description provided for @navRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get navRequests;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get changePasswordUpdateTitle;

  /// No description provided for @changePasswordCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get changePasswordCurrent;

  /// No description provided for @changePasswordNew.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get changePasswordNew;

  /// No description provided for @changePasswordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get changePasswordConfirm;

  /// No description provided for @changePasswordAllRequired.
  ///
  /// In en, this message translates to:
  /// **'All fields are required.'**
  String get changePasswordAllRequired;

  /// No description provided for @changePasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'New passwords do not match.'**
  String get changePasswordMismatch;

  /// No description provided for @changePasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get changePasswordTooShort;

  /// No description provided for @changePasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully.'**
  String get changePasswordSuccess;

  /// No description provided for @changePasswordSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get changePasswordSaving;

  /// No description provided for @changePasswordSave.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get changePasswordSave;

  /// No description provided for @gymNoSelection.
  ///
  /// In en, this message translates to:
  /// **'No gym selected'**
  String get gymNoSelection;

  /// No description provided for @gymCurrentLabel.
  ///
  /// In en, this message translates to:
  /// **'Current gym: {name}'**
  String gymCurrentLabel(Object name);

  /// No description provided for @gymSwitch.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get gymSwitch;

  /// No description provided for @gymGuardSelect.
  ///
  /// In en, this message translates to:
  /// **'Select a gym to continue.'**
  String get gymGuardSelect;

  /// No description provided for @gymGuardChooseList.
  ///
  /// In en, this message translates to:
  /// **'Choose from list'**
  String get gymGuardChooseList;

  /// No description provided for @gymGuardOpenMap.
  ///
  /// In en, this message translates to:
  /// **'Open map'**
  String get gymGuardOpenMap;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get commonView;

  /// No description provided for @commonLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get commonLater;

  /// No description provided for @commonAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get commonAll;

  /// No description provided for @commonPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get commonPending;

  /// No description provided for @commonApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get commonApproved;

  /// No description provided for @commonRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get commonRejected;

  /// No description provided for @commonActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get commonActive;

  /// No description provided for @commonInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get commonInactive;

  /// No description provided for @commonRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get commonRefresh;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get commonMembers;

  /// No description provided for @commonTrainers.
  ///
  /// In en, this message translates to:
  /// **'Trainers'**
  String get commonTrainers;

  /// No description provided for @commonGyms.
  ///
  /// In en, this message translates to:
  /// **'Gyms'**
  String get commonGyms;

  /// No description provided for @commonPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get commonPayments;

  /// No description provided for @commonDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get commonDashboard;

  /// No description provided for @commonNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get commonNotifications;

  /// No description provided for @commonAccessLogs.
  ///
  /// In en, this message translates to:
  /// **'Access logs'**
  String get commonAccessLogs;

  /// No description provided for @commonMemberships.
  ///
  /// In en, this message translates to:
  /// **'Memberships'**
  String get commonMemberships;

  /// No description provided for @commonAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get commonAnalytics;

  /// No description provided for @commonNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results yet.'**
  String get commonNoResults;

  /// No description provided for @commonNoData.
  ///
  /// In en, this message translates to:
  /// **'No data yet.'**
  String get commonNoData;

  /// No description provided for @commonUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get commonUnknown;

  /// No description provided for @commonWorking.
  ///
  /// In en, this message translates to:
  /// **'Working...'**
  String get commonWorking;

  /// No description provided for @commonCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get commonCreate;

  /// No description provided for @desktopAppTitle.
  ///
  /// In en, this message translates to:
  /// **'FitCity'**
  String get desktopAppTitle;

  /// No description provided for @desktopUnableLoadAdmin.
  ///
  /// In en, this message translates to:
  /// **'Unable to load admin data'**
  String get desktopUnableLoadAdmin;

  /// No description provided for @adminNewMembershipRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'New membership request'**
  String get adminNewMembershipRequestTitle;

  /// No description provided for @adminNewMembershipRequestBody.
  ///
  /// In en, this message translates to:
  /// **'You have {count} new membership request notification{suffix}.'**
  String adminNewMembershipRequestBody(Object count, Object suffix);

  /// No description provided for @adminViewRequests.
  ///
  /// In en, this message translates to:
  /// **'View requests'**
  String get adminViewRequests;

  /// No description provided for @adminGymListTitle.
  ///
  /// In en, this message translates to:
  /// **'Gym list'**
  String get adminGymListTitle;

  /// No description provided for @adminNoGymsFound.
  ///
  /// In en, this message translates to:
  /// **'No gyms found.'**
  String get adminNoGymsFound;

  /// No description provided for @adminDeleteMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete member'**
  String get adminDeleteMemberTitle;

  /// No description provided for @adminDeleteMemberConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete the member if no related records exist. Continue?'**
  String get adminDeleteMemberConfirm;

  /// No description provided for @adminMemberDetails.
  ///
  /// In en, this message translates to:
  /// **'Member Details'**
  String get adminMemberDetails;

  /// No description provided for @adminMembershipStatus.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String adminMembershipStatus(Object status);

  /// No description provided for @adminMembershipEnds.
  ///
  /// In en, this message translates to:
  /// **'Ends: {date}'**
  String adminMembershipEnds(Object date);

  /// No description provided for @adminManageMembers.
  ///
  /// In en, this message translates to:
  /// **'Manage members'**
  String get adminManageMembers;

  /// No description provided for @adminRecordsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} records'**
  String adminRecordsCount(Object count);

  /// No description provided for @adminNoMembershipsFound.
  ///
  /// In en, this message translates to:
  /// **'No memberships found.'**
  String get adminNoMembershipsFound;

  /// No description provided for @adminValidate.
  ///
  /// In en, this message translates to:
  /// **'Validate'**
  String get adminValidate;

  /// No description provided for @adminRejectMembershipTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject membership request'**
  String get adminRejectMembershipTitle;

  /// No description provided for @adminRejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Rejection reason'**
  String get adminRejectionReason;

  /// No description provided for @adminMembershipRequests.
  ///
  /// In en, this message translates to:
  /// **'Membership requests'**
  String get adminMembershipRequests;

  /// No description provided for @adminNoMembershipRequests.
  ///
  /// In en, this message translates to:
  /// **'No membership requests found.'**
  String get adminNoMembershipRequests;

  /// No description provided for @adminPaymentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get adminPaymentsTitle;

  /// No description provided for @adminNoPaymentsFound.
  ///
  /// In en, this message translates to:
  /// **'No payments found.'**
  String get adminNoPaymentsFound;

  /// No description provided for @adminAddMember.
  ///
  /// In en, this message translates to:
  /// **'Add member'**
  String get adminAddMember;

  /// No description provided for @adminAddTrainer.
  ///
  /// In en, this message translates to:
  /// **'Add trainer'**
  String get adminAddTrainer;

  /// No description provided for @adminMembersTitle.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get adminMembersTitle;

  /// No description provided for @adminScanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get adminScanQr;

  /// No description provided for @adminNoMembersFound.
  ///
  /// In en, this message translates to:
  /// **'No members found.'**
  String get adminNoMembersFound;

  /// No description provided for @adminAllGyms.
  ///
  /// In en, this message translates to:
  /// **'All gyms'**
  String get adminAllGyms;

  /// No description provided for @adminAllCities.
  ///
  /// In en, this message translates to:
  /// **'All cities'**
  String get adminAllCities;

  /// No description provided for @adminAllStatuses.
  ///
  /// In en, this message translates to:
  /// **'All statuses'**
  String get adminAllStatuses;

  /// No description provided for @adminHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Hours: {hours}'**
  String adminHoursLabel(Object hours);

  /// No description provided for @adminMembersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String adminMembersCount(Object count);

  /// No description provided for @adminTrainersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} trainers'**
  String adminTrainersCount(Object count);

  /// No description provided for @adminNoMemberships.
  ///
  /// In en, this message translates to:
  /// **'No memberships'**
  String get adminNoMemberships;

  /// No description provided for @adminTrainerRate.
  ///
  /// In en, this message translates to:
  /// **'{rate} KM/hr'**
  String adminTrainerRate(Object rate);

  /// No description provided for @adminTrainerUpcoming.
  ///
  /// In en, this message translates to:
  /// **'{count} upcoming'**
  String adminTrainerUpcoming(Object count);

  /// No description provided for @adminTrainersTitle.
  ///
  /// In en, this message translates to:
  /// **'Trainers'**
  String get adminTrainersTitle;

  /// No description provided for @adminTrainersActive.
  ///
  /// In en, this message translates to:
  /// **'{count} active'**
  String adminTrainersActive(Object count);

  /// No description provided for @adminNoTrainersFound.
  ///
  /// In en, this message translates to:
  /// **'No trainers found.'**
  String get adminNoTrainersFound;

  /// No description provided for @adminAccessLogsTitle.
  ///
  /// In en, this message translates to:
  /// **'Access Logs'**
  String get adminAccessLogsTitle;

  /// No description provided for @adminAccessGranted.
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get adminAccessGranted;

  /// No description provided for @adminAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'Denied'**
  String get adminAccessDenied;

  /// No description provided for @adminNoAccessLogs.
  ///
  /// In en, this message translates to:
  /// **'No access logs found.'**
  String get adminNoAccessLogs;

  /// No description provided for @adminAccessLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Access log'**
  String get adminAccessLogTitle;

  /// No description provided for @adminNoNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get adminNoNotifications;

  /// No description provided for @adminReferenceData.
  ///
  /// In en, this message translates to:
  /// **'Reference Data'**
  String get adminReferenceData;

  /// No description provided for @adminNoGymPlans.
  ///
  /// In en, this message translates to:
  /// **'No gym plans found.'**
  String get adminNoGymPlans;

  /// No description provided for @adminEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get adminEdit;

  /// No description provided for @adminDeleteGymPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete gym plan'**
  String get adminDeleteGymPlanTitle;

  /// No description provided for @adminDeleteGymPlanConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String adminDeleteGymPlanConfirm(Object name);

  /// No description provided for @adminPlanLine.
  ///
  /// In en, this message translates to:
  /// **'{gym} â€¢ {months} months'**
  String adminPlanLine(Object gym, Object months);

  /// No description provided for @adminPlanPrice.
  ///
  /// In en, this message translates to:
  /// **'{price} KM'**
  String adminPlanPrice(Object price);

  /// No description provided for @adminNoMembershipsYet.
  ///
  /// In en, this message translates to:
  /// **'No memberships yet.'**
  String get adminNoMembershipsYet;

  /// No description provided for @adminNoBookingsYet.
  ///
  /// In en, this message translates to:
  /// **'No bookings yet.'**
  String get adminNoBookingsYet;

  /// No description provided for @adminNoGymAssociation.
  ///
  /// In en, this message translates to:
  /// **'No gym association yet.'**
  String get adminNoGymAssociation;

  /// No description provided for @adminNoScheduleEntries.
  ///
  /// In en, this message translates to:
  /// **'No schedule entries.'**
  String get adminNoScheduleEntries;

  /// No description provided for @adminNoSessionsRecorded.
  ///
  /// In en, this message translates to:
  /// **'No sessions recorded.'**
  String get adminNoSessionsRecorded;

  /// No description provided for @adminActiveGyms.
  ///
  /// In en, this message translates to:
  /// **'Active gyms'**
  String get adminActiveGyms;

  /// No description provided for @adminTotalGyms.
  ///
  /// In en, this message translates to:
  /// **'{count} total'**
  String adminTotalGyms(Object count);

  /// No description provided for @adminMemberLabel.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get adminMemberLabel;

  /// No description provided for @adminMembershipRequestLabel.
  ///
  /// In en, this message translates to:
  /// **'Membership request'**
  String get adminMembershipRequestLabel;

  /// No description provided for @adminNotificationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get adminNotificationsLabel;

  /// No description provided for @adminCurrencyKm.
  ///
  /// In en, this message translates to:
  /// **'{amount} KM'**
  String adminCurrencyKm(Object amount);

  /// No description provided for @adminNoReportData.
  ///
  /// In en, this message translates to:
  /// **'No report data yet.'**
  String get adminNoReportData;

  /// No description provided for @adminNoRevenueData.
  ///
  /// In en, this message translates to:
  /// **'No revenue data yet.'**
  String get adminNoRevenueData;

  /// No description provided for @adminNoTrainerActivity.
  ///
  /// In en, this message translates to:
  /// **'No trainer activity yet.'**
  String get adminNoTrainerActivity;

  /// No description provided for @adminReportLine.
  ///
  /// In en, this message translates to:
  /// **'{month}/{year} â€¢ {count} new'**
  String adminReportLine(Object month, Object year, Object count);

  /// No description provided for @adminRevenueLine.
  ///
  /// In en, this message translates to:
  /// **'{month}/{year} â€¢ {amount}'**
  String adminRevenueLine(Object month, Object year, Object amount);

  /// No description provided for @adminTrainerActivityLine.
  ///
  /// In en, this message translates to:
  /// **'{name} â€¢ {count} bookings'**
  String adminTrainerActivityLine(Object name, Object count);

  /// No description provided for @adminDeleteMemberConfirmName.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}? This cannot be undone.'**
  String adminDeleteMemberConfirmName(Object name);

  /// No description provided for @adminMembershipLabel.
  ///
  /// In en, this message translates to:
  /// **'Membership'**
  String get adminMembershipLabel;

  /// No description provided for @adminNoMembershipData.
  ///
  /// In en, this message translates to:
  /// **'No membership data yet.'**
  String get adminNoMembershipData;

  /// No description provided for @desktopAppName.
  ///
  /// In en, this message translates to:
  /// **'FitCity App'**
  String get desktopAppName;

  /// No description provided for @adminScanQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get adminScanQrCode;

  /// No description provided for @adminScanQrHint.
  ///
  /// In en, this message translates to:
  /// **'Point the code inside the frame.'**
  String get adminScanQrHint;

  /// No description provided for @adminAddMemberPlus.
  ///
  /// In en, this message translates to:
  /// **'+ Add member'**
  String get adminAddMemberPlus;

  /// No description provided for @adminAddGymTitle.
  ///
  /// In en, this message translates to:
  /// **'Add gym'**
  String get adminAddGymTitle;

  /// No description provided for @adminCreateGym.
  ///
  /// In en, this message translates to:
  /// **'Create gym'**
  String get adminCreateGym;

  /// No description provided for @adminGymCreated.
  ///
  /// In en, this message translates to:
  /// **'Gym created.'**
  String get adminGymCreated;

  /// No description provided for @adminGymNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Gym name'**
  String get adminGymNameLabel;

  /// No description provided for @adminGymNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Gym name is required.'**
  String get adminGymNameRequired;

  /// No description provided for @adminGymAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address (optional)'**
  String get adminGymAddressLabel;

  /// No description provided for @adminGymCityLabel.
  ///
  /// In en, this message translates to:
  /// **'City (optional)'**
  String get adminGymCityLabel;

  /// No description provided for @adminGymPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact phone (optional)'**
  String get adminGymPhoneLabel;

  /// No description provided for @adminGymDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get adminGymDescriptionLabel;

  /// No description provided for @adminGymWorkHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Work hours (optional)'**
  String get adminGymWorkHoursLabel;

  /// No description provided for @adminGymLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get adminGymLocationLabel;

  /// No description provided for @adminGymLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Click the map to set the location.'**
  String get adminGymLocationHint;

  /// No description provided for @adminGymLocationLatLng.
  ///
  /// In en, this message translates to:
  /// **'Selected: {lat}, {lng}'**
  String adminGymLocationLatLng(Object lat, Object lng);

  /// No description provided for @adminGymLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'Location is required.'**
  String get adminGymLocationRequired;

  /// No description provided for @adminGymLocationMissing.
  ///
  /// In en, this message translates to:
  /// **'Location not set'**
  String get adminGymLocationMissing;

  /// No description provided for @adminGymSearchAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Search address'**
  String get adminGymSearchAddressHint;

  /// No description provided for @adminGymSearchAddressAction.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get adminGymSearchAddressAction;

  /// No description provided for @adminGymAddressSearchFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to search address right now.'**
  String get adminGymAddressSearchFailed;

  /// No description provided for @adminGymEntryQrTitle.
  ///
  /// In en, this message translates to:
  /// **'Gym entry QR'**
  String get adminGymEntryQrTitle;

  /// No description provided for @adminGymEntryQrHint.
  ///
  /// In en, this message translates to:
  /// **'Show this code at the gym entrance.'**
  String get adminGymEntryQrHint;

  /// No description provided for @adminScannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Scanner'**
  String get adminScannerTitle;

  /// No description provided for @adminScannerPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get adminScannerPause;

  /// No description provided for @adminScannerResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get adminScannerResume;

  /// No description provided for @adminScannerStatusIdle.
  ///
  /// In en, this message translates to:
  /// **'Idle'**
  String get adminScannerStatusIdle;

  /// No description provided for @adminScannerStatusScanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning'**
  String get adminScannerStatusScanning;

  /// No description provided for @adminScannerStatusPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get adminScannerStatusPaused;

  /// No description provided for @adminScannerStatusSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get adminScannerStatusSuccess;

  /// No description provided for @adminScannerStatusError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get adminScannerStatusError;

  /// No description provided for @adminScannerInvalidQr.
  ///
  /// In en, this message translates to:
  /// **'This QR code is not a FitCity membership QR.'**
  String get adminScannerInvalidQr;

  /// No description provided for @adminScannerEntryQr.
  ///
  /// In en, this message translates to:
  /// **'This is a gym/entry QR. Scan a member QR.'**
  String get adminScannerEntryQr;

  /// No description provided for @adminScannerMemberTokenMissing.
  ///
  /// In en, this message translates to:
  /// **'Member QR token missing.'**
  String get adminScannerMemberTokenMissing;

  /// No description provided for @adminScannerDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Already scanned. Please wait...'**
  String get adminScannerDuplicate;

  /// No description provided for @commonName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get commonName;

  /// No description provided for @commonEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get commonEmail;

  /// No description provided for @commonMembership.
  ///
  /// In en, this message translates to:
  /// **'Membership'**
  String get commonMembership;

  /// No description provided for @membershipAnnual.
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get membershipAnnual;

  /// No description provided for @membershipMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get membershipMonthly;

  /// No description provided for @sampleMemberName.
  ///
  /// In en, this message translates to:
  /// **'John Doe'**
  String get sampleMemberName;

  /// No description provided for @sampleMemberEmail.
  ///
  /// In en, this message translates to:
  /// **'johndoe@gmail.com'**
  String get sampleMemberEmail;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get notificationsEmpty;

  /// No description provided for @notificationRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get notificationRead;

  /// No description provided for @notificationNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get notificationNew;

  /// No description provided for @bookingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get bookingsTitle;

  /// No description provided for @bookingsUpcomingTab.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Bookings'**
  String get bookingsUpcomingTab;

  /// No description provided for @bookingsEntryHistoryTab.
  ///
  /// In en, this message translates to:
  /// **'Entry History'**
  String get bookingsEntryHistoryTab;

  /// No description provided for @bookingsNoUpcoming.
  ///
  /// In en, this message translates to:
  /// **'No upcoming sessions.'**
  String get bookingsNoUpcoming;

  /// No description provided for @bookingsStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String bookingsStatusLabel(Object status);

  /// No description provided for @bookingsTrainerLabel.
  ///
  /// In en, this message translates to:
  /// **'Trainer: {name}'**
  String bookingsTrainerLabel(Object name);

  /// No description provided for @bookingsGymLabel.
  ///
  /// In en, this message translates to:
  /// **'Gym: {name}'**
  String bookingsGymLabel(Object name);

  /// No description provided for @bookingsStartLabel.
  ///
  /// In en, this message translates to:
  /// **'Start: {date}'**
  String bookingsStartLabel(Object date);

  /// No description provided for @bookingsPaymentLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment: {status}'**
  String bookingsPaymentLabel(Object status);

  /// No description provided for @bookingsNoEntries.
  ///
  /// In en, this message translates to:
  /// **'No gym entries yet. Scan your QR code at the gym to create your first entry.'**
  String get bookingsNoEntries;

  /// No description provided for @bookingsGymEntry.
  ///
  /// In en, this message translates to:
  /// **'Gym entry'**
  String get bookingsGymEntry;

  /// No description provided for @bookingsEntered.
  ///
  /// In en, this message translates to:
  /// **'Entered'**
  String get bookingsEntered;

  /// No description provided for @bookingScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Book a trainer'**
  String get bookingScreenTitle;

  /// No description provided for @bookingSelectGymMessage.
  ///
  /// In en, this message translates to:
  /// **'Select a gym to book a trainer.'**
  String get bookingSelectGymMessage;

  /// No description provided for @bookingLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get bookingLocationLabel;

  /// No description provided for @bookingTrainerLabel.
  ///
  /// In en, this message translates to:
  /// **'Trainer'**
  String get bookingTrainerLabel;

  /// No description provided for @bookingDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String bookingDateLabel(Object date);

  /// No description provided for @bookingPaymentCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get bookingPaymentCard;

  /// No description provided for @bookingPaymentPayPal.
  ///
  /// In en, this message translates to:
  /// **'PayPal'**
  String get bookingPaymentPayPal;

  /// No description provided for @bookingPaymentCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get bookingPaymentCash;

  /// No description provided for @bookingAvailableSlots.
  ///
  /// In en, this message translates to:
  /// **'Available slots'**
  String get bookingAvailableSlots;

  /// No description provided for @bookingSelectSlot.
  ///
  /// In en, this message translates to:
  /// **'Select a slot'**
  String get bookingSelectSlot;

  /// No description provided for @bookingCreate.
  ///
  /// In en, this message translates to:
  /// **'Create booking'**
  String get bookingCreate;

  /// No description provided for @bookingViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all bookings'**
  String get bookingViewAll;

  /// No description provided for @bookingTrainerNotFound.
  ///
  /// In en, this message translates to:
  /// **'Trainer not found.'**
  String get bookingTrainerNotFound;

  /// No description provided for @bookingSelectSlotFirst.
  ///
  /// In en, this message translates to:
  /// **'Select an available slot first.'**
  String get bookingSelectSlotFirst;

  /// No description provided for @bookingNoSlotsDate.
  ///
  /// In en, this message translates to:
  /// **'No slots available for the selected date.'**
  String get bookingNoSlotsDate;

  /// No description provided for @bookingNoSlotsRange.
  ///
  /// In en, this message translates to:
  /// **'No slots available in the selected range.'**
  String get bookingNoSlotsRange;

  /// No description provided for @bookingSlotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get bookingSlotAvailable;

  /// No description provided for @bookingSlotBooked.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get bookingSlotBooked;

  /// No description provided for @bookingTrainerRateLabel.
  ///
  /// In en, this message translates to:
  /// **'{name} - {rate} KM/hr'**
  String bookingTrainerRateLabel(Object name, Object rate);

  /// No description provided for @bookingConfirmedTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking confirmed'**
  String get bookingConfirmedTitle;

  /// No description provided for @bookingViewUpcoming.
  ///
  /// In en, this message translates to:
  /// **'View upcoming bookings'**
  String get bookingViewUpcoming;

  /// No description provided for @bookingChatWithTrainer.
  ///
  /// In en, this message translates to:
  /// **'Chat with trainer'**
  String get bookingChatWithTrainer;

  /// No description provided for @bookingChatWithName.
  ///
  /// In en, this message translates to:
  /// **'Chat with {name}'**
  String bookingChatWithName(Object name);

  /// No description provided for @bookingLabelTrainer.
  ///
  /// In en, this message translates to:
  /// **'Trainer'**
  String get bookingLabelTrainer;

  /// No description provided for @bookingLabelGym.
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get bookingLabelGym;

  /// No description provided for @bookingLabelStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get bookingLabelStart;

  /// No description provided for @bookingLabelEnd.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get bookingLabelEnd;

  /// No description provided for @bookingLabelPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get bookingLabelPayment;

  /// No description provided for @commonTrainer.
  ///
  /// In en, this message translates to:
  /// **'Trainer'**
  String get commonTrainer;

  /// No description provided for @commonViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get commonViewAll;

  /// No description provided for @membershipActivePassTitle.
  ///
  /// In en, this message translates to:
  /// **'Active Pass'**
  String get membershipActivePassTitle;

  /// No description provided for @membershipShowQrPass.
  ///
  /// In en, this message translates to:
  /// **'Show QR pass'**
  String get membershipShowQrPass;

  /// No description provided for @membershipManageHint.
  ///
  /// In en, this message translates to:
  /// **'Manage or renew your plans in the memberships list.'**
  String get membershipManageHint;

  /// No description provided for @membershipApprovedTitle.
  ///
  /// In en, this message translates to:
  /// **'Membership approved'**
  String get membershipApprovedTitle;

  /// No description provided for @membershipPaymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Payment status: {status}'**
  String membershipPaymentStatus(Object status);

  /// No description provided for @membershipUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get membershipUnpaid;

  /// No description provided for @membershipGymLabel.
  ///
  /// In en, this message translates to:
  /// **'Gym: {name}'**
  String membershipGymLabel(Object name);

  /// No description provided for @membershipPayAction.
  ///
  /// In en, this message translates to:
  /// **'Pay membership'**
  String get membershipPayAction;

  /// No description provided for @membershipProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get membershipProcessing;

  /// No description provided for @membershipPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Membership pending'**
  String get membershipPendingTitle;

  /// No description provided for @membershipStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String membershipStatusLabel(Object status);

  /// No description provided for @membershipRejectedDefault.
  ///
  /// In en, this message translates to:
  /// **'Your membership request was rejected.'**
  String get membershipRejectedDefault;

  /// No description provided for @membershipBrowseGyms.
  ///
  /// In en, this message translates to:
  /// **'Browse gyms'**
  String get membershipBrowseGyms;

  /// No description provided for @membershipExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Membership expired'**
  String get membershipExpiredTitle;

  /// No description provided for @membershipExpiredOn.
  ///
  /// In en, this message translates to:
  /// **'Expired on: {date}'**
  String membershipExpiredOn(Object date);

  /// No description provided for @membershipRenew.
  ///
  /// In en, this message translates to:
  /// **'Renew membership'**
  String get membershipRenew;

  /// No description provided for @membershipNoActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'No active membership'**
  String get membershipNoActiveTitle;

  /// No description provided for @membershipBrowseHint.
  ///
  /// In en, this message translates to:
  /// **'Browse gyms to get started with a plan.'**
  String get membershipBrowseHint;

  /// No description provided for @membershipNoData.
  ///
  /// In en, this message translates to:
  /// **'No membership data found.'**
  String get membershipNoData;

  /// No description provided for @membershipConfirmPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm payment'**
  String get membershipConfirmPaymentTitle;

  /// No description provided for @membershipConfirmPaymentBody.
  ///
  /// In en, this message translates to:
  /// **'Pay for a 30-day membership{gymSuffix}? Your pass activates immediately.'**
  String membershipConfirmPaymentBody(Object gymSuffix);

  /// No description provided for @membershipPayNow.
  ///
  /// In en, this message translates to:
  /// **'Pay now'**
  String get membershipPayNow;

  /// No description provided for @membershipPaymentSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment successful'**
  String get membershipPaymentSuccessTitle;

  /// No description provided for @paymentOpenBrowser.
  ///
  /// In en, this message translates to:
  /// **'Complete payment in your browser, then return to the app.'**
  String get paymentOpenBrowser;

  /// No description provided for @paymentPendingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Waiting for payment confirmation...'**
  String get paymentPendingConfirmation;

  /// No description provided for @paymentConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Payment confirmed.'**
  String get paymentConfirmed;

  /// No description provided for @paymentInvalidCheckoutUrl.
  ///
  /// In en, this message translates to:
  /// **'Invalid checkout URL.'**
  String get paymentInvalidCheckoutUrl;

  /// No description provided for @paymentLaunchFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to open checkout.'**
  String get paymentLaunchFailed;

  /// No description provided for @paymentPayPalUnavailable.
  ///
  /// In en, this message translates to:
  /// **'PayPal is not available yet. Please choose Card.'**
  String get paymentPayPalUnavailable;

  /// No description provided for @paymentChooseMethod.
  ///
  /// In en, this message translates to:
  /// **'Choose payment method'**
  String get paymentChooseMethod;

  /// No description provided for @paymentUseStripe.
  ///
  /// In en, this message translates to:
  /// **'Pay with card (Stripe)'**
  String get paymentUseStripe;

  /// No description provided for @paymentMarkPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark as paid (local)'**
  String get paymentMarkPaid;

  /// No description provided for @paymentManualDisabled.
  ///
  /// In en, this message translates to:
  /// **'Manual payments are disabled.'**
  String get paymentManualDisabled;

  /// No description provided for @membershipActiveUntil.
  ///
  /// In en, this message translates to:
  /// **'Membership active until {date}'**
  String membershipActiveUntil(Object date);

  /// No description provided for @membershipShowQr.
  ///
  /// In en, this message translates to:
  /// **'Show QR'**
  String get membershipShowQr;

  /// No description provided for @membershipPassLabel.
  ///
  /// In en, this message translates to:
  /// **'Membership pass'**
  String get membershipPassLabel;

  /// No description provided for @membershipGymNameFallback.
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get membershipGymNameFallback;

  /// No description provided for @membershipDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} days left'**
  String membershipDaysLeft(Object count);

  /// No description provided for @membershipStartLabel.
  ///
  /// In en, this message translates to:
  /// **'Start: {date}'**
  String membershipStartLabel(Object date);

  /// No description provided for @membershipEndLabel.
  ///
  /// In en, this message translates to:
  /// **'End: {date}'**
  String membershipEndLabel(Object date);

  /// No description provided for @commonSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get commonSuccess;

  /// No description provided for @commonEntered.
  ///
  /// In en, this message translates to:
  /// **'Entered'**
  String get commonEntered;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatTitle;

  /// No description provided for @chatNoConversations.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet.'**
  String get chatNoConversations;

  /// No description provided for @chatPaymentDetails.
  ///
  /// In en, this message translates to:
  /// **'Payment details'**
  String get chatPaymentDetails;

  /// No description provided for @chatLoadEarlier.
  ///
  /// In en, this message translates to:
  /// **'Load earlier messages'**
  String get chatLoadEarlier;

  /// No description provided for @emailDemoTitle.
  ///
  /// In en, this message translates to:
  /// **'Email Demo'**
  String get emailDemoTitle;

  /// No description provided for @gymDetailSignInToRequest.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to request membership.'**
  String get gymDetailSignInToRequest;

  /// No description provided for @gymDetailMembershipRequest.
  ///
  /// In en, this message translates to:
  /// **'Membership request: {status}'**
  String gymDetailMembershipRequest(Object status);

  /// No description provided for @gymDetailChoosePayment.
  ///
  /// In en, this message translates to:
  /// **'Choose payment method'**
  String get gymDetailChoosePayment;

  /// No description provided for @gymDetailCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get gymDetailCard;

  /// No description provided for @gymDetailPayPal.
  ///
  /// In en, this message translates to:
  /// **'PayPal'**
  String get gymDetailPayPal;

  /// No description provided for @gymDetailHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Hours: {hours}'**
  String gymDetailHoursLabel(Object hours);

  /// No description provided for @gymDetailTrainersTitle.
  ///
  /// In en, this message translates to:
  /// **'Trainers'**
  String get gymDetailTrainersTitle;

  /// No description provided for @gymDetailNoTrainers.
  ///
  /// In en, this message translates to:
  /// **'No trainers assigned yet.'**
  String get gymDetailNoTrainers;

  /// No description provided for @gymDetailReviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get gymDetailReviewsTitle;

  /// No description provided for @gymDetailNoReviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet.'**
  String get gymDetailNoReviews;

  /// No description provided for @gymDetailWaitingApproval.
  ///
  /// In en, this message translates to:
  /// **'Waiting for approval'**
  String get gymDetailWaitingApproval;

  /// No description provided for @gymDetailApprovedPaymentRequired.
  ///
  /// In en, this message translates to:
  /// **'Approved - payment required'**
  String get gymDetailApprovedPaymentRequired;

  /// No description provided for @gymDetailViewMemberships.
  ///
  /// In en, this message translates to:
  /// **'View memberships'**
  String get gymDetailViewMemberships;

  /// No description provided for @gymDetailBookTrainer.
  ///
  /// In en, this message translates to:
  /// **'Book a trainer'**
  String get gymDetailBookTrainer;

  /// No description provided for @gymDetailSwitchGym.
  ///
  /// In en, this message translates to:
  /// **'Switch gym'**
  String get gymDetailSwitchGym;

  /// No description provided for @gymDetailChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get gymDetailChat;

  /// No description provided for @gymListTitle.
  ///
  /// In en, this message translates to:
  /// **'Gyms in {city}'**
  String gymListTitle(Object city);

  /// No description provided for @gymListNoTrainerRecommendations.
  ///
  /// In en, this message translates to:
  /// **'No trainer recommendations yet.'**
  String get gymListNoTrainerRecommendations;

  /// No description provided for @gymListNoGymRecommendations.
  ///
  /// In en, this message translates to:
  /// **'No gym recommendations yet.'**
  String get gymListNoGymRecommendations;

  /// No description provided for @membershipListTitle.
  ///
  /// In en, this message translates to:
  /// **'Memberships'**
  String get membershipListTitle;

  /// No description provided for @membershipSignedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {email}'**
  String membershipSignedInAs(Object email);

  /// No description provided for @membershipSelectGym.
  ///
  /// In en, this message translates to:
  /// **'Select gym'**
  String get membershipSelectGym;

  /// No description provided for @membershipViewActivePass.
  ///
  /// In en, this message translates to:
  /// **'View active pass'**
  String get membershipViewActivePass;

  /// No description provided for @membershipRequest.
  ///
  /// In en, this message translates to:
  /// **'Request membership'**
  String get membershipRequest;

  /// No description provided for @membershipRequestStatus.
  ///
  /// In en, this message translates to:
  /// **'Request status: {status}'**
  String membershipRequestStatus(Object status);

  /// No description provided for @membershipQrToken.
  ///
  /// In en, this message translates to:
  /// **'QR token: {token}'**
  String membershipQrToken(Object token);

  /// No description provided for @membershipActiveListTitle.
  ///
  /// In en, this message translates to:
  /// **'Active memberships'**
  String get membershipActiveListTitle;

  /// No description provided for @membershipNoMemberships.
  ///
  /// In en, this message translates to:
  /// **'No memberships found.'**
  String get membershipNoMemberships;

  /// No description provided for @membershipStatusLine.
  ///
  /// In en, this message translates to:
  /// **'Membership {status}'**
  String membershipStatusLine(Object status);

  /// No description provided for @membershipValidUntil.
  ///
  /// In en, this message translates to:
  /// **'Valid until: {date}'**
  String membershipValidUntil(Object date);

  /// No description provided for @membershipIssueQr.
  ///
  /// In en, this message translates to:
  /// **'Issue QR code'**
  String get membershipIssueQr;

  /// No description provided for @mapTitle.
  ///
  /// In en, this message translates to:
  /// **'FitCity Map'**
  String get mapTitle;

  /// No description provided for @qrShowAtEntrance.
  ///
  /// In en, this message translates to:
  /// **'Show this code at entrance'**
  String get qrShowAtEntrance;

  /// No description provided for @qrNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'QR not available'**
  String get qrNotAvailable;

  /// No description provided for @qrExpiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date: {date}'**
  String qrExpiryDate(Object date);

  /// No description provided for @qrDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Entry denied'**
  String get qrDeniedTitle;

  /// No description provided for @qrDeniedWrongGym.
  ///
  /// In en, this message translates to:
  /// **'This QR code is not valid for this gym.'**
  String get qrDeniedWrongGym;

  /// No description provided for @qrDeniedExpired.
  ///
  /// In en, this message translates to:
  /// **'This QR code has expired.'**
  String get qrDeniedExpired;

  /// No description provided for @qrDeniedInactive.
  ///
  /// In en, this message translates to:
  /// **'Membership is inactive or expired.'**
  String get qrDeniedInactive;

  /// No description provided for @qrDeniedInvalid.
  ///
  /// In en, this message translates to:
  /// **'This QR code is invalid.'**
  String get qrDeniedInvalid;

  /// No description provided for @qrDeniedGeneric.
  ///
  /// In en, this message translates to:
  /// **'Entry denied. Please try again.'**
  String get qrDeniedGeneric;

  /// No description provided for @qrTokenLabel.
  ///
  /// In en, this message translates to:
  /// **'Token: {token}'**
  String qrTokenLabel(Object token);

  /// No description provided for @reportsDesktopOnlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin reports are available on desktop only.'**
  String get reportsDesktopOnlyTitle;

  /// No description provided for @reportsDesktopOnlyBody.
  ///
  /// In en, this message translates to:
  /// **'Sign in on the desktop app to view analytics and reports.'**
  String get reportsDesktopOnlyBody;

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsTitle;

  /// No description provided for @reportsBackHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get reportsBackHome;

  /// No description provided for @recommendedTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommendedTitle;

  /// No description provided for @requestsOpenChats.
  ///
  /// In en, this message translates to:
  /// **'Open chats'**
  String get requestsOpenChats;

  /// No description provided for @requestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Training requests'**
  String get requestsTitle;

  /// No description provided for @requestsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No pending requests right now.'**
  String get requestsEmpty;

  /// No description provided for @requestsDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get requestsDecline;

  /// No description provided for @scheduleRequests.
  ///
  /// In en, this message translates to:
  /// **'Training requests'**
  String get scheduleRequests;

  /// No description provided for @scheduleNoEntries.
  ///
  /// In en, this message translates to:
  /// **'No schedule entries yet.'**
  String get scheduleNoEntries;

  /// No description provided for @trainerNotFound.
  ///
  /// In en, this message translates to:
  /// **'Trainer not found.'**
  String get trainerNotFound;

  /// No description provided for @trainerTitle.
  ///
  /// In en, this message translates to:
  /// **'Trainer'**
  String get trainerTitle;

  /// No description provided for @trainerWorkLocations.
  ///
  /// In en, this message translates to:
  /// **'Work locations'**
  String get trainerWorkLocations;

  /// No description provided for @trainerAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get trainerAbout;

  /// No description provided for @trainerCertifications.
  ///
  /// In en, this message translates to:
  /// **'Certifications'**
  String get trainerCertifications;

  /// No description provided for @trainerRate.
  ///
  /// In en, this message translates to:
  /// **'{rate} KM/hr'**
  String trainerRate(Object rate);

  /// No description provided for @emailDemoToLabel.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get emailDemoToLabel;

  /// No description provided for @emailDemoSubjectLabel.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get emailDemoSubjectLabel;

  /// No description provided for @emailDemoMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get emailDemoMessageLabel;

  /// No description provided for @emailDemoSend.
  ///
  /// In en, this message translates to:
  /// **'Send demo email'**
  String get emailDemoSend;

  /// No description provided for @emailDemoQueued.
  ///
  /// In en, this message translates to:
  /// **'Queued demo email to {email}.'**
  String emailDemoQueued(Object email);

  /// No description provided for @emailDemoDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This screen is a mock. Real emails are sent by FitCity.Notifications.Api via RabbitMQ.'**
  String get emailDemoDisclaimer;

  /// No description provided for @profileEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEditTitle;

  /// No description provided for @profileFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get profileFullNameLabel;

  /// No description provided for @profileEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmailLabel;

  /// No description provided for @profilePhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get profilePhoneLabel;

  /// No description provided for @profileFullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name is required.'**
  String get profileFullNameRequired;

  /// No description provided for @commonSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get commonSaving;

  /// No description provided for @commonSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get commonSaveChanges;

  /// No description provided for @commonType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get commonType;

  /// No description provided for @commonGym.
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get commonGym;

  /// No description provided for @commonCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get commonCity;

  /// No description provided for @commonStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get commonStatus;

  /// No description provided for @commonPriceKm.
  ///
  /// In en, this message translates to:
  /// **'Price (KM)'**
  String get commonPriceKm;

  /// No description provided for @commonDurationMonths.
  ///
  /// In en, this message translates to:
  /// **'Duration (months)'**
  String get commonDurationMonths;

  /// No description provided for @commonDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get commonDescription;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// No description provided for @commonApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get commonApprove;

  /// No description provided for @commonDeleting.
  ///
  /// In en, this message translates to:
  /// **'Deleting...'**
  String get commonDeleting;

  /// No description provided for @commonUpdating.
  ///
  /// In en, this message translates to:
  /// **'Updating...'**
  String get commonUpdating;

  /// No description provided for @commonFromDate.
  ///
  /// In en, this message translates to:
  /// **'From date'**
  String get commonFromDate;

  /// No description provided for @commonToDate.
  ///
  /// In en, this message translates to:
  /// **'To date'**
  String get commonToDate;

  /// No description provided for @commonMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get commonMember;

  /// No description provided for @commonPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get commonPhone;

  /// No description provided for @commonReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get commonReason;

  /// No description provided for @commonTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get commonTime;

  /// No description provided for @commonRate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get commonRate;

  /// No description provided for @commonBio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get commonBio;

  /// No description provided for @commonSignedOut.
  ///
  /// In en, this message translates to:
  /// **'Signed out.'**
  String get commonSignedOut;

  /// No description provided for @adminSectionManageGyms.
  ///
  /// In en, this message translates to:
  /// **'Manage gyms'**
  String get adminSectionManageGyms;

  /// No description provided for @adminSectionManageMembers.
  ///
  /// In en, this message translates to:
  /// **'Manage members'**
  String get adminSectionManageMembers;

  /// No description provided for @adminSectionMembershipRequests.
  ///
  /// In en, this message translates to:
  /// **'Membership requests'**
  String get adminSectionMembershipRequests;

  /// No description provided for @adminSectionPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get adminSectionPayments;

  /// No description provided for @adminSectionSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get adminSectionSettings;

  /// No description provided for @adminDashboardCity.
  ///
  /// In en, this message translates to:
  /// **'Sarajevo'**
  String get adminDashboardCity;

  /// No description provided for @adminMapPinLabel.
  ///
  /// In en, this message translates to:
  /// **'{label}'**
  String adminMapPinLabel(Object label);

  /// No description provided for @adminAddGymPlus.
  ///
  /// In en, this message translates to:
  /// **'+ Add gym'**
  String get adminAddGymPlus;

  /// No description provided for @adminMembershipValid.
  ///
  /// In en, this message translates to:
  /// **'Membership valid.'**
  String get adminMembershipValid;

  /// No description provided for @adminMembershipInvalid.
  ///
  /// In en, this message translates to:
  /// **'Membership invalid.'**
  String get adminMembershipInvalid;

  /// No description provided for @adminQrIssued.
  ///
  /// In en, this message translates to:
  /// **'QR issued: {token}'**
  String adminQrIssued(Object token);

  /// No description provided for @adminMemberDeleted.
  ///
  /// In en, this message translates to:
  /// **'Member deleted.'**
  String get adminMemberDeleted;

  /// No description provided for @adminMemberCreated.
  ///
  /// In en, this message translates to:
  /// **'Member created.'**
  String get adminMemberCreated;

  /// No description provided for @adminTrainerAdded.
  ///
  /// In en, this message translates to:
  /// **'Trainer added.'**
  String get adminTrainerAdded;

  /// No description provided for @adminCreateRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Name, email, and password are required.'**
  String get adminCreateRequiredFields;

  /// No description provided for @adminPasswordMin.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least {count} characters.'**
  String adminPasswordMin(Object count);

  /// No description provided for @adminTrainerHourlyRateRequired.
  ///
  /// In en, this message translates to:
  /// **'Hourly rate is required.'**
  String get adminTrainerHourlyRateRequired;

  /// No description provided for @adminTrainerPhotoUrlHint.
  ///
  /// In en, this message translates to:
  /// **'Photo URL (optional)'**
  String get adminTrainerPhotoUrlHint;

  /// No description provided for @adminTrainerHourlyRateHint.
  ///
  /// In en, this message translates to:
  /// **'Hourly rate'**
  String get adminTrainerHourlyRateHint;

  /// No description provided for @adminTrainerDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Description / info (optional)'**
  String get adminTrainerDescriptionHint;

  /// No description provided for @adminSearchMembersHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name, email, phone'**
  String get adminSearchMembersHint;

  /// No description provided for @adminSearchMembershipsHint.
  ///
  /// In en, this message translates to:
  /// **'Search by user, gym, status'**
  String get adminSearchMembershipsHint;

  /// No description provided for @adminSearchRequestsHint.
  ///
  /// In en, this message translates to:
  /// **'Search by member, gym, status'**
  String get adminSearchRequestsHint;

  /// No description provided for @adminSearchPaymentsHint.
  ///
  /// In en, this message translates to:
  /// **'Search member, gym, method'**
  String get adminSearchPaymentsHint;

  /// No description provided for @adminSearchAllHint.
  ///
  /// In en, this message translates to:
  /// **'Search gyms, members, trainers'**
  String get adminSearchAllHint;

  /// No description provided for @adminSearchTrainerHint.
  ///
  /// In en, this message translates to:
  /// **'Search trainer by name'**
  String get adminSearchTrainerHint;

  /// No description provided for @adminSearchGymsHint.
  ///
  /// In en, this message translates to:
  /// **'Search gyms'**
  String get adminSearchGymsHint;

  /// No description provided for @adminAccessLogSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Member search'**
  String get adminAccessLogSearchHint;

  /// No description provided for @adminSearchNotificationsHint.
  ///
  /// In en, this message translates to:
  /// **'Search notifications'**
  String get adminSearchNotificationsHint;

  /// No description provided for @adminSearchPlansHint.
  ///
  /// In en, this message translates to:
  /// **'Search gym plans'**
  String get adminSearchPlansHint;

  /// No description provided for @adminAddPlan.
  ///
  /// In en, this message translates to:
  /// **'Add plan'**
  String get adminAddPlan;

  /// No description provided for @adminAddGymPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Add gym plan'**
  String get adminAddGymPlanTitle;

  /// No description provided for @adminEditGymPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit gym plan'**
  String get adminEditGymPlanTitle;

  /// No description provided for @adminMembershipsPerMonthTitle.
  ///
  /// In en, this message translates to:
  /// **'Memberships per month'**
  String get adminMembershipsPerMonthTitle;

  /// No description provided for @adminRevenuePerMonthTitle.
  ///
  /// In en, this message translates to:
  /// **'Revenue per month'**
  String get adminRevenuePerMonthTitle;

  /// No description provided for @adminTopTrainersTitle.
  ///
  /// In en, this message translates to:
  /// **'Top trainers'**
  String get adminTopTrainersTitle;

  /// No description provided for @adminMembershipGrowthTitle.
  ///
  /// In en, this message translates to:
  /// **'Membership growth'**
  String get adminMembershipGrowthTitle;

  /// No description provided for @adminRevenueTrendTitle.
  ///
  /// In en, this message translates to:
  /// **'Revenue trend'**
  String get adminRevenueTrendTitle;

  /// No description provided for @adminNoGyms.
  ///
  /// In en, this message translates to:
  /// **'No gyms'**
  String get adminNoGyms;

  /// No description provided for @adminNoCertifications.
  ///
  /// In en, this message translates to:
  /// **'No certifications'**
  String get adminNoCertifications;

  /// No description provided for @adminRequestApproved.
  ///
  /// In en, this message translates to:
  /// **'Request approved.'**
  String get adminRequestApproved;

  /// No description provided for @adminRequestRejected.
  ///
  /// In en, this message translates to:
  /// **'Request rejected.'**
  String get adminRequestRejected;

  /// No description provided for @adminDefaultRejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Sorry, we have full capacity right now. Please try again sometime.'**
  String get adminDefaultRejectionReason;

  /// No description provided for @adminViewNotifications.
  ///
  /// In en, this message translates to:
  /// **'View notifications'**
  String get adminViewNotifications;

  /// No description provided for @adminMemberDetailNotFound.
  ///
  /// In en, this message translates to:
  /// **'Member detail not found.'**
  String get adminMemberDetailNotFound;

  /// No description provided for @adminTrainerDetailNotFound.
  ///
  /// In en, this message translates to:
  /// **'Trainer detail not found.'**
  String get adminTrainerDetailNotFound;

  /// No description provided for @adminMemberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since'**
  String get adminMemberSince;

  /// No description provided for @adminQrStatus.
  ///
  /// In en, this message translates to:
  /// **'QR {status}'**
  String adminQrStatus(Object status);

  /// No description provided for @adminNoActiveQr.
  ///
  /// In en, this message translates to:
  /// **'No active QR pass'**
  String get adminNoActiveQr;

  /// No description provided for @adminQrExpires.
  ///
  /// In en, this message translates to:
  /// **'Expires {date}'**
  String adminQrExpires(Object date);

  /// No description provided for @adminNoAccessLogsYet.
  ///
  /// In en, this message translates to:
  /// **'No access logs yet.'**
  String get adminNoAccessLogsYet;

  /// No description provided for @adminLastAccess.
  ///
  /// In en, this message translates to:
  /// **'Last access: {date} • {gym}'**
  String adminLastAccess(Object date, Object gym);

  /// No description provided for @adminSessionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get adminSessionsTitle;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled.'**
  String get locationServicesDisabled;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied.'**
  String get locationPermissionDenied;

  /// No description provided for @mapOpenGym.
  ///
  /// In en, this message translates to:
  /// **'Open {name}'**
  String mapOpenGym(Object name);

  /// No description provided for @qrPassTitle.
  ///
  /// In en, this message translates to:
  /// **'QR Code Pass'**
  String get qrPassTitle;

  /// No description provided for @gymNameFallback.
  ///
  /// In en, this message translates to:
  /// **'FitCity Gym'**
  String get gymNameFallback;

  /// No description provided for @trainerHourlyRate.
  ///
  /// In en, this message translates to:
  /// **'Hourly rate: {rate} KM/hr'**
  String trainerHourlyRate(Object rate);

  /// No description provided for @trainerHourlyRateNotSet.
  ///
  /// In en, this message translates to:
  /// **'Hourly rate not set.'**
  String get trainerHourlyRateNotSet;

  /// No description provided for @requestsTrainingSession.
  ///
  /// In en, this message translates to:
  /// **'Training session'**
  String get requestsTrainingSession;

  /// No description provided for @commonAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get commonAccept;

  /// No description provided for @bookingSlotBlocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get bookingSlotBlocked;

  /// No description provided for @gymListRecommendedTrainersTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended trainers'**
  String get gymListRecommendedTrainersTitle;

  /// No description provided for @gymListRecommendedGymsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended gyms'**
  String get gymListRecommendedGymsTitle;

  /// No description provided for @gymListSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search gyms'**
  String get gymListSearchHint;

  /// No description provided for @gymListLocating.
  ///
  /// In en, this message translates to:
  /// **'Locating...'**
  String get gymListLocating;

  /// No description provided for @gymListSortDefault.
  ///
  /// In en, this message translates to:
  /// **'Sort: Default'**
  String get gymListSortDefault;

  /// No description provided for @gymListSortNearest.
  ///
  /// In en, this message translates to:
  /// **'Sort: Nearest'**
  String get gymListSortNearest;

  /// No description provided for @gymListOpenMap.
  ///
  /// In en, this message translates to:
  /// **'Open map'**
  String get gymListOpenMap;

  /// No description provided for @gymListDistanceAway.
  ///
  /// In en, this message translates to:
  /// **'{distance} km away'**
  String gymListDistanceAway(Object distance);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bs', 'de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bs':
      return AppLocalizationsBs();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
