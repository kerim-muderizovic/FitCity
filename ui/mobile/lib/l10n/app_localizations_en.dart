// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonSignIn => 'Sign in';

  @override
  String get commonSignOut => 'Sign out';

  @override
  String get commonSettings => 'Settings';

  @override
  String commonRoleLabel(Object role) {
    return 'Role: $role';
  }

  @override
  String get commonGuest => 'Guest';

  @override
  String get commonNotSignedIn => 'Not signed in';

  @override
  String get commonTryAgain => 'Please try again.';

  @override
  String get errorsGeneric => 'Something went wrong. Please try again later.';

  @override
  String get errorsNetwork =>
      'Network error. Please check your internet connection and try again.';

  @override
  String get errorsValidation => 'Please check your input and try again.';

  @override
  String get errorRegistrationDisabled =>
      'New user registration is currently disabled.';

  @override
  String get errorTrainerCreationDisabled =>
      'Adding new trainers is currently disabled.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profilePhotoTooLarge => 'Photo must be 5MB or smaller.';

  @override
  String get profilePhotoInvalidType =>
      'Only JPG, PNG, or WebP files are allowed.';

  @override
  String get profileChooseFromGallery => 'Choose from gallery';

  @override
  String get profileTakePhoto => 'Take a photo';

  @override
  String get profilePhotoUploadFailed =>
      'Unable to upload photo right now. Please try again.';

  @override
  String get profilePhotoUpdated => 'Photo updated.';

  @override
  String get profileCurrentGym => 'Current gym';

  @override
  String get profileSwitchGym => 'Switch gym';

  @override
  String get profileMemberships => 'Memberships';

  @override
  String get profileNoActiveMemberships => 'No active memberships.';

  @override
  String get profileActivePass => 'Active pass';

  @override
  String get profileAllMemberships => 'All memberships';

  @override
  String get profileTrainerTools => 'Trainer tools';

  @override
  String get profileSchedule => 'Schedule';

  @override
  String get profileRequests => 'Requests';

  @override
  String get profileTrainerChat => 'Trainer chat';

  @override
  String get profilePreferences => 'Preferences';

  @override
  String get profilePreferencesEmpty => 'No preferences saved yet.';

  @override
  String get profilePersonalInformation => 'Personal information';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profileEdit => 'Edit profile';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsPushNotifications => 'Push notifications';

  @override
  String get settingsAutoRenew => 'Auto-renew membership';

  @override
  String get settingsChangePassword => 'Change password';

  @override
  String get settingsTermsOfService => 'Terms of service';

  @override
  String get settingsTermsTodo => 'Terms of service are not available yet.';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsAllowGymRegistrations => 'Allow new gym registrations';

  @override
  String get settingsAllowUserRegistrations => 'Allow new user registration';

  @override
  String get settingsAllowTrainerCreation => 'Allow adding new trainers';

  @override
  String get settingsSave => 'Save settings';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageBosnian => 'Bosanski';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get authLoginFailed => 'Login failed. Please try again.';

  @override
  String get authAuthenticationFailed =>
      'Authentication failed. Please try again.';

  @override
  String get authDesktopWorkspace => 'Desktop workspace';

  @override
  String get authAccessTitle => 'FitCity Access';

  @override
  String get authLogin => 'Login';

  @override
  String get authRegister => 'Register';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authConfirmPasswordLabel => 'Confirm password';

  @override
  String get authFullNameLabel => 'Full name';

  @override
  String get authPhoneOptionalLabel => 'Phone number (optional)';

  @override
  String get authPleaseWait => 'Please wait...';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authNotAuthenticatedYet => 'Not authenticated yet.';

  @override
  String get authCurrentUser => 'Current user';

  @override
  String get authEmailRequired => 'Email is required.';

  @override
  String get authEmailInvalid => 'Enter a valid email address.';

  @override
  String get authPasswordRequired => 'Password is required.';

  @override
  String get authPasswordTooShort => 'Password must be at least 8 characters.';

  @override
  String get authConfirmPasswordRequired => 'Confirm your password.';

  @override
  String get authPasswordMismatch => 'Passwords do not match.';

  @override
  String get authFullNameRequired => 'Full name is required.';

  @override
  String get authSuccessSnackbar => 'Authenticated successfully.';

  @override
  String get errorsInvalidCredentials => 'Invalid credentials.';

  @override
  String get profilePhotoRequired => 'Please select a photo to upload.';

  @override
  String get adminLoginTitle => 'FitCity Admin';

  @override
  String adminLoginSubtitle(Object role) {
    return 'Sign in with a $role account to continue.';
  }

  @override
  String get adminRoleCentral => 'Central Administrator';

  @override
  String get adminRoleGym => 'Gym Administrator';

  @override
  String get adminRoleAdministrator => 'Administrator';

  @override
  String get adminAccessRequired => 'Admin access required for this workspace.';

  @override
  String get adminSigningIn => 'Signing in...';

  @override
  String get navGyms => 'Gyms';

  @override
  String get navPass => 'Pass';

  @override
  String get navBookings => 'Bookings';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfile => 'Profile';

  @override
  String get navAlerts => 'Alerts';

  @override
  String get navSchedule => 'Schedule';

  @override
  String get navRequests => 'Requests';

  @override
  String get changePasswordTitle => 'Change password';

  @override
  String get changePasswordUpdateTitle => 'Update password';

  @override
  String get changePasswordCurrent => 'Current password';

  @override
  String get changePasswordNew => 'New password';

  @override
  String get changePasswordConfirm => 'Confirm new password';

  @override
  String get changePasswordAllRequired => 'All fields are required.';

  @override
  String get changePasswordMismatch => 'New passwords do not match.';

  @override
  String get changePasswordTooShort =>
      'Password must be at least 6 characters.';

  @override
  String get changePasswordSuccess => 'Password changed successfully.';

  @override
  String get changePasswordSaving => 'Saving...';

  @override
  String get changePasswordSave => 'Save changes';

  @override
  String get gymNoSelection => 'No gym selected';

  @override
  String gymCurrentLabel(Object name) {
    return 'Current gym: $name';
  }

  @override
  String get gymSwitch => 'Switch';

  @override
  String get gymGuardSelect => 'Select a gym to continue.';

  @override
  String get gymGuardChooseList => 'Choose from list';

  @override
  String get gymGuardOpenMap => 'Open map';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonClose => 'Close';

  @override
  String get commonSave => 'Save';

  @override
  String get commonView => 'View';

  @override
  String get commonLater => 'Later';

  @override
  String get commonAll => 'All';

  @override
  String get commonPending => 'Pending';

  @override
  String get commonApproved => 'Approved';

  @override
  String get commonRejected => 'Rejected';

  @override
  String get commonActive => 'Active';

  @override
  String get commonInactive => 'Inactive';

  @override
  String get commonRefresh => 'Refresh';

  @override
  String get commonBack => 'Back';

  @override
  String get commonMembers => 'Members';

  @override
  String get commonTrainers => 'Trainers';

  @override
  String get commonGyms => 'Gyms';

  @override
  String get commonPayments => 'Payments';

  @override
  String get commonDashboard => 'Dashboard';

  @override
  String get commonNotifications => 'Notifications';

  @override
  String get commonAccessLogs => 'Access logs';

  @override
  String get commonMemberships => 'Memberships';

  @override
  String get commonAnalytics => 'Analytics';

  @override
  String get commonNoResults => 'No results yet.';

  @override
  String get commonNoData => 'No data yet.';

  @override
  String get commonUnknown => 'Unknown';

  @override
  String get commonWorking => 'Working...';

  @override
  String get commonCreate => 'Create';

  @override
  String get desktopAppTitle => 'FitCity';

  @override
  String get desktopUnableLoadAdmin => 'Unable to load admin data';

  @override
  String get adminNewMembershipRequestTitle => 'New membership request';

  @override
  String adminNewMembershipRequestBody(Object count, Object suffix) {
    return 'You have $count new membership request notification$suffix.';
  }

  @override
  String get adminViewRequests => 'View requests';

  @override
  String get adminGymListTitle => 'Gym list';

  @override
  String get adminNoGymsFound => 'No gyms found.';

  @override
  String get adminDeleteMemberTitle => 'Delete member';

  @override
  String get adminDeleteMemberConfirm =>
      'This will permanently delete the member if no related records exist. Continue?';

  @override
  String get adminMemberDetails => 'Member Details';

  @override
  String adminMembershipStatus(Object status) {
    return 'Status: $status';
  }

  @override
  String adminMembershipEnds(Object date) {
    return 'Ends: $date';
  }

  @override
  String get adminManageMembers => 'Manage members';

  @override
  String adminRecordsCount(Object count) {
    return '$count records';
  }

  @override
  String get adminNoMembershipsFound => 'No memberships found.';

  @override
  String get adminValidate => 'Validate';

  @override
  String get adminRejectMembershipTitle => 'Reject membership request';

  @override
  String get adminRejectionReason => 'Rejection reason';

  @override
  String get adminMembershipRequests => 'Membership requests';

  @override
  String get adminNoMembershipRequests => 'No membership requests found.';

  @override
  String get adminPaymentsTitle => 'Payments';

  @override
  String get adminNoPaymentsFound => 'No payments found.';

  @override
  String get adminAddMember => 'Add member';

  @override
  String get adminAddTrainer => 'Add trainer';

  @override
  String get adminMembersTitle => 'Members';

  @override
  String get adminScanQr => 'Scan QR code';

  @override
  String get adminNoMembersFound => 'No members found.';

  @override
  String get adminAllGyms => 'All gyms';

  @override
  String get adminAllCities => 'All cities';

  @override
  String get adminAllStatuses => 'All statuses';

  @override
  String adminHoursLabel(Object hours) {
    return 'Hours: $hours';
  }

  @override
  String adminMembersCount(Object count) {
    return '$count members';
  }

  @override
  String adminTrainersCount(Object count) {
    return '$count trainers';
  }

  @override
  String get adminNoMemberships => 'No memberships';

  @override
  String adminTrainerRate(Object rate) {
    return '$rate KM/hr';
  }

  @override
  String adminTrainerUpcoming(Object count) {
    return '$count upcoming';
  }

  @override
  String get adminTrainersTitle => 'Trainers';

  @override
  String adminTrainersActive(Object count) {
    return '$count active';
  }

  @override
  String get adminNoTrainersFound => 'No trainers found.';

  @override
  String get adminAccessLogsTitle => 'Access Logs';

  @override
  String get adminAccessGranted => 'Granted';

  @override
  String get adminAccessDenied => 'Denied';

  @override
  String get adminNoAccessLogs => 'No access logs found.';

  @override
  String get adminAccessLogTitle => 'Access log';

  @override
  String get adminNoNotifications => 'No notifications yet.';

  @override
  String get adminReferenceData => 'Reference Data';

  @override
  String get adminNoGymPlans => 'No gym plans found.';

  @override
  String get adminEdit => 'Edit';

  @override
  String get adminDeleteGymPlanTitle => 'Delete gym plan';

  @override
  String adminDeleteGymPlanConfirm(Object name) {
    return 'Delete \"$name\"?';
  }

  @override
  String adminPlanLine(Object gym, Object months) {
    return '$gym â€¢ $months months';
  }

  @override
  String adminPlanPrice(Object price) {
    return '$price KM';
  }

  @override
  String get adminNoMembershipsYet => 'No memberships yet.';

  @override
  String get adminNoBookingsYet => 'No bookings yet.';

  @override
  String get adminNoGymAssociation => 'No gym association yet.';

  @override
  String get adminNoScheduleEntries => 'No schedule entries.';

  @override
  String get adminNoSessionsRecorded => 'No sessions recorded.';

  @override
  String get adminActiveGyms => 'Active gyms';

  @override
  String adminTotalGyms(Object count) {
    return '$count total';
  }

  @override
  String get adminMemberLabel => 'Member';

  @override
  String get adminMembershipRequestLabel => 'Membership request';

  @override
  String get adminNotificationsLabel => 'Notifications';

  @override
  String adminCurrencyKm(Object amount) {
    return '$amount KM';
  }

  @override
  String get adminNoReportData => 'No report data yet.';

  @override
  String get adminNoRevenueData => 'No revenue data yet.';

  @override
  String get adminNoTrainerActivity => 'No trainer activity yet.';

  @override
  String adminReportLine(Object month, Object year, Object count) {
    return '$month/$year â€¢ $count new';
  }

  @override
  String adminRevenueLine(Object month, Object year, Object amount) {
    return '$month/$year â€¢ $amount';
  }

  @override
  String adminTrainerActivityLine(Object name, Object count) {
    return '$name â€¢ $count bookings';
  }

  @override
  String adminDeleteMemberConfirmName(Object name) {
    return 'Delete $name? This cannot be undone.';
  }

  @override
  String get adminMembershipLabel => 'Membership';

  @override
  String get adminNoMembershipData => 'No membership data yet.';

  @override
  String get desktopAppName => 'FitCity App';

  @override
  String get adminScanQrCode => 'Scan QR Code';

  @override
  String get adminScanQrHint => 'Point the code inside the frame.';

  @override
  String get adminAddMemberPlus => '+ Add member';

  @override
  String get adminAddGymTitle => 'Add gym';

  @override
  String get adminCreateGym => 'Create gym';

  @override
  String get adminGymCreated => 'Gym created.';

  @override
  String get adminGymNameLabel => 'Gym name';

  @override
  String get adminGymNameRequired => 'Gym name is required.';

  @override
  String get adminGymAddressLabel => 'Address (optional)';

  @override
  String get adminGymCityLabel => 'City (optional)';

  @override
  String get adminGymPhoneLabel => 'Contact phone (optional)';

  @override
  String get adminGymDescriptionLabel => 'Description (optional)';

  @override
  String get adminGymWorkHoursLabel => 'Work hours (optional)';

  @override
  String get adminGymLocationLabel => 'Location';

  @override
  String get adminGymLocationHint => 'Click the map to set the location.';

  @override
  String adminGymLocationLatLng(Object lat, Object lng) {
    return 'Selected: $lat, $lng';
  }

  @override
  String get adminGymLocationRequired => 'Location is required.';

  @override
  String get adminGymLocationMissing => 'Location not set';

  @override
  String get adminGymSearchAddressHint => 'Search address';

  @override
  String get adminGymSearchAddressAction => 'Search';

  @override
  String get adminGymAddressSearchFailed =>
      'Unable to search address right now.';

  @override
  String get adminGymEntryQrTitle => 'Gym entry QR';

  @override
  String get adminGymEntryQrHint => 'Show this code at the gym entrance.';

  @override
  String get adminScannerTitle => 'Scanner';

  @override
  String get adminScannerPause => 'Pause';

  @override
  String get adminScannerResume => 'Resume';

  @override
  String get adminScannerStatusIdle => 'Idle';

  @override
  String get adminScannerStatusScanning => 'Scanning';

  @override
  String get adminScannerStatusPaused => 'Paused';

  @override
  String get adminScannerStatusSuccess => 'Success';

  @override
  String get adminScannerStatusError => 'Error';

  @override
  String get adminScannerInvalidQr =>
      'This QR code is not a FitCity membership QR.';

  @override
  String get adminScannerEntryQr => 'This is a gym/entry QR. Scan a member QR.';

  @override
  String get adminScannerMemberTokenMissing => 'Member QR token missing.';

  @override
  String get adminScannerDuplicate => 'Already scanned. Please wait...';

  @override
  String get commonName => 'Name';

  @override
  String get commonEmail => 'Email';

  @override
  String get commonMembership => 'Membership';

  @override
  String get membershipAnnual => 'Annual';

  @override
  String get membershipMonthly => 'Monthly';

  @override
  String get sampleMemberName => 'John Doe';

  @override
  String get sampleMemberEmail => 'johndoe@gmail.com';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsMarkAllRead => 'Mark all read';

  @override
  String get notificationsEmpty => 'No notifications yet.';

  @override
  String get notificationRead => 'Read';

  @override
  String get notificationNew => 'New';

  @override
  String get bookingsTitle => 'Bookings';

  @override
  String get bookingsUpcomingTab => 'Upcoming Bookings';

  @override
  String get bookingsEntryHistoryTab => 'Entry History';

  @override
  String get bookingsNoUpcoming => 'No upcoming sessions.';

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
    return 'Gym: $name';
  }

  @override
  String bookingsStartLabel(Object date) {
    return 'Start: $date';
  }

  @override
  String bookingsPaymentLabel(Object status) {
    return 'Payment: $status';
  }

  @override
  String get bookingsNoEntries =>
      'No gym entries yet. Scan your QR code at the gym to create your first entry.';

  @override
  String get bookingsGymEntry => 'Gym entry';

  @override
  String get bookingsEntered => 'Entered';

  @override
  String get bookingScreenTitle => 'Book a trainer';

  @override
  String get bookingSelectGymMessage => 'Select a gym to book a trainer.';

  @override
  String get bookingLocationLabel => 'Location';

  @override
  String get bookingTrainerLabel => 'Trainer';

  @override
  String bookingDateLabel(Object date) {
    return 'Date: $date';
  }

  @override
  String get bookingPaymentCard => 'Card';

  @override
  String get bookingPaymentPayPal => 'PayPal';

  @override
  String get bookingPaymentCash => 'Cash';

  @override
  String get bookingAvailableSlots => 'Available slots';

  @override
  String get bookingSelectSlot => 'Select a slot';

  @override
  String get bookingCreate => 'Create booking';

  @override
  String get bookingViewAll => 'View all bookings';

  @override
  String get bookingTrainerNotFound => 'Trainer not found.';

  @override
  String get bookingSelectSlotFirst => 'Select an available slot first.';

  @override
  String get bookingNoSlotsDate => 'No slots available for the selected date.';

  @override
  String get bookingNoSlotsRange => 'No slots available in the selected range.';

  @override
  String get bookingSlotAvailable => 'Available';

  @override
  String get bookingSlotBooked => 'Booked';

  @override
  String bookingTrainerRateLabel(Object name, Object rate) {
    return '$name - $rate KM/hr';
  }

  @override
  String get bookingConfirmedTitle => 'Booking confirmed';

  @override
  String get bookingViewUpcoming => 'View upcoming bookings';

  @override
  String get bookingChatWithTrainer => 'Chat with trainer';

  @override
  String bookingChatWithName(Object name) {
    return 'Chat with $name';
  }

  @override
  String get bookingLabelTrainer => 'Trainer';

  @override
  String get bookingLabelGym => 'Gym';

  @override
  String get bookingLabelStart => 'Start';

  @override
  String get bookingLabelEnd => 'End';

  @override
  String get bookingLabelPayment => 'Payment';

  @override
  String get commonTrainer => 'Trainer';

  @override
  String get commonViewAll => 'View all';

  @override
  String get membershipActivePassTitle => 'Active Pass';

  @override
  String get membershipShowQrPass => 'Show QR pass';

  @override
  String get membershipManageHint =>
      'Manage or renew your plans in the memberships list.';

  @override
  String get membershipApprovedTitle => 'Membership approved';

  @override
  String membershipPaymentStatus(Object status) {
    return 'Payment status: $status';
  }

  @override
  String get membershipUnpaid => 'Unpaid';

  @override
  String membershipGymLabel(Object name) {
    return 'Gym: $name';
  }

  @override
  String get membershipPayAction => 'Pay membership';

  @override
  String get membershipProcessing => 'Processing...';

  @override
  String get membershipPendingTitle => 'Membership pending';

  @override
  String membershipStatusLabel(Object status) {
    return 'Status: $status';
  }

  @override
  String get membershipRejectedDefault =>
      'Your membership request was rejected.';

  @override
  String get membershipBrowseGyms => 'Browse gyms';

  @override
  String get membershipExpiredTitle => 'Membership expired';

  @override
  String membershipExpiredOn(Object date) {
    return 'Expired on: $date';
  }

  @override
  String get membershipRenew => 'Renew membership';

  @override
  String get membershipNoActiveTitle => 'No active membership';

  @override
  String get membershipBrowseHint => 'Browse gyms to get started with a plan.';

  @override
  String get membershipNoData => 'No membership data found.';

  @override
  String get membershipConfirmPaymentTitle => 'Confirm payment';

  @override
  String membershipConfirmPaymentBody(Object gymSuffix) {
    return 'Pay for a 30-day membership$gymSuffix? Your pass activates immediately.';
  }

  @override
  String get membershipPayNow => 'Pay now';

  @override
  String get membershipPaymentSuccessTitle => 'Payment successful';

  @override
  String get paymentOpenBrowser =>
      'Complete payment in your browser, then return to the app.';

  @override
  String get paymentPendingConfirmation =>
      'Waiting for payment confirmation...';

  @override
  String get paymentConfirmed => 'Payment confirmed.';

  @override
  String get paymentInvalidCheckoutUrl => 'Invalid checkout URL.';

  @override
  String get paymentLaunchFailed => 'Unable to open checkout.';

  @override
  String get paymentPayPalUnavailable =>
      'PayPal is not available yet. Please choose Card.';

  @override
  String get paymentChooseMethod => 'Choose payment method';

  @override
  String get paymentUseStripe => 'Pay with card (Stripe)';

  @override
  String get paymentMarkPaid => 'Mark as paid (local)';

  @override
  String get paymentManualDisabled => 'Manual payments are disabled.';

  @override
  String membershipActiveUntil(Object date) {
    return 'Membership active until $date';
  }

  @override
  String get membershipShowQr => 'Show QR';

  @override
  String get membershipPassLabel => 'Membership pass';

  @override
  String get membershipGymNameFallback => 'Gym';

  @override
  String membershipDaysLeft(Object count) {
    return '$count days left';
  }

  @override
  String membershipStartLabel(Object date) {
    return 'Start: $date';
  }

  @override
  String membershipEndLabel(Object date) {
    return 'End: $date';
  }

  @override
  String get commonSuccess => 'Success';

  @override
  String get commonEntered => 'Entered';

  @override
  String get chatTitle => 'Chat';

  @override
  String get chatNoConversations => 'No conversations yet.';

  @override
  String get chatPaymentDetails => 'Payment details';

  @override
  String get chatLoadEarlier => 'Load earlier messages';

  @override
  String get emailDemoTitle => 'Email Demo';

  @override
  String get gymDetailSignInToRequest =>
      'Please sign in to request membership.';

  @override
  String gymDetailMembershipRequest(Object status) {
    return 'Membership request: $status';
  }

  @override
  String get gymDetailChoosePayment => 'Choose payment method';

  @override
  String get gymDetailCard => 'Card';

  @override
  String get gymDetailPayPal => 'PayPal';

  @override
  String gymDetailHoursLabel(Object hours) {
    return 'Hours: $hours';
  }

  @override
  String get gymDetailTrainersTitle => 'Trainers';

  @override
  String get gymDetailNoTrainers => 'No trainers assigned yet.';

  @override
  String get gymDetailReviewsTitle => 'Reviews';

  @override
  String get gymDetailNoReviews => 'No reviews yet.';

  @override
  String get gymDetailWaitingApproval => 'Waiting for approval';

  @override
  String get gymDetailApprovedPaymentRequired => 'Approved - payment required';

  @override
  String get gymDetailViewMemberships => 'View memberships';

  @override
  String get gymDetailBookTrainer => 'Book a trainer';

  @override
  String get gymDetailSwitchGym => 'Switch gym';

  @override
  String get gymDetailChat => 'Chat';

  @override
  String gymListTitle(Object city) {
    return 'Gyms in $city';
  }

  @override
  String get gymListNoTrainerRecommendations =>
      'No trainer recommendations yet.';

  @override
  String get gymListNoGymRecommendations => 'No gym recommendations yet.';

  @override
  String get membershipListTitle => 'Memberships';

  @override
  String membershipSignedInAs(Object email) {
    return 'Signed in as $email';
  }

  @override
  String get membershipSelectGym => 'Select gym';

  @override
  String get membershipViewActivePass => 'View active pass';

  @override
  String get membershipRequest => 'Request membership';

  @override
  String membershipRequestStatus(Object status) {
    return 'Request status: $status';
  }

  @override
  String membershipQrToken(Object token) {
    return 'QR token: $token';
  }

  @override
  String get membershipActiveListTitle => 'Active memberships';

  @override
  String get membershipNoMemberships => 'No memberships found.';

  @override
  String membershipStatusLine(Object status) {
    return 'Membership $status';
  }

  @override
  String membershipValidUntil(Object date) {
    return 'Valid until: $date';
  }

  @override
  String get membershipIssueQr => 'Issue QR code';

  @override
  String get mapTitle => 'FitCity Map';

  @override
  String get qrShowAtEntrance => 'Show this code at entrance';

  @override
  String get qrNotAvailable => 'QR not available';

  @override
  String qrExpiryDate(Object date) {
    return 'Expiry Date: $date';
  }

  @override
  String get qrDeniedTitle => 'Entry denied';

  @override
  String get qrDeniedWrongGym => 'This QR code is not valid for this gym.';

  @override
  String get qrDeniedExpired => 'This QR code has expired.';

  @override
  String get qrDeniedInactive => 'Membership is inactive or expired.';

  @override
  String get qrDeniedInvalid => 'This QR code is invalid.';

  @override
  String get qrDeniedGeneric => 'Entry denied. Please try again.';

  @override
  String qrTokenLabel(Object token) {
    return 'Token: $token';
  }

  @override
  String get reportsDesktopOnlyTitle =>
      'Admin reports are available on desktop only.';

  @override
  String get reportsDesktopOnlyBody =>
      'Sign in on the desktop app to view analytics and reports.';

  @override
  String get reportsTitle => 'Reports';

  @override
  String get reportsBackHome => 'Back to home';

  @override
  String get recommendedTitle => 'Recommended';

  @override
  String get requestsOpenChats => 'Open chats';

  @override
  String get requestsTitle => 'Training requests';

  @override
  String get requestsEmpty => 'No pending requests right now.';

  @override
  String get requestsDecline => 'Decline';

  @override
  String get scheduleRequests => 'Training requests';

  @override
  String get scheduleNoEntries => 'No schedule entries yet.';

  @override
  String get trainerNotFound => 'Trainer not found.';

  @override
  String get trainerTitle => 'Trainer';

  @override
  String get trainerWorkLocations => 'Work locations';

  @override
  String get trainerAbout => 'About';

  @override
  String get trainerCertifications => 'Certifications';

  @override
  String trainerRate(Object rate) {
    return '$rate KM/hr';
  }

  @override
  String get emailDemoToLabel => 'To';

  @override
  String get emailDemoSubjectLabel => 'Subject';

  @override
  String get emailDemoMessageLabel => 'Message';

  @override
  String get emailDemoSend => 'Send demo email';

  @override
  String emailDemoQueued(Object email) {
    return 'Queued demo email to $email.';
  }

  @override
  String get emailDemoDisclaimer =>
      'This screen is a mock. Real emails are sent by FitCity.Notifications.Api via RabbitMQ.';

  @override
  String get profileEditTitle => 'Edit profile';

  @override
  String get profileFullNameLabel => 'Full name';

  @override
  String get profileEmailLabel => 'Email';

  @override
  String get profilePhoneLabel => 'Phone';

  @override
  String get profileFullNameRequired => 'Full name is required.';

  @override
  String get commonSaving => 'Saving...';

  @override
  String get commonSaveChanges => 'Save changes';

  @override
  String get commonType => 'Type';

  @override
  String get commonGym => 'Gym';

  @override
  String get commonCity => 'City';

  @override
  String get commonStatus => 'Status';

  @override
  String get commonPriceKm => 'Price (KM)';

  @override
  String get commonDurationMonths => 'Duration (months)';

  @override
  String get commonDescription => 'Description';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonApprove => 'Approve';

  @override
  String get commonDeleting => 'Deleting...';

  @override
  String get commonUpdating => 'Updating...';

  @override
  String get commonFromDate => 'From date';

  @override
  String get commonToDate => 'To date';

  @override
  String get commonMember => 'Member';

  @override
  String get commonPhone => 'Phone';

  @override
  String get commonReason => 'Reason';

  @override
  String get commonTime => 'Time';

  @override
  String get commonRate => 'Rate';

  @override
  String get commonBio => 'Bio';

  @override
  String get commonSignedOut => 'Signed out.';

  @override
  String get adminSectionManageGyms => 'Manage gyms';

  @override
  String get adminSectionManageMembers => 'Manage members';

  @override
  String get adminSectionMembershipRequests => 'Membership requests';

  @override
  String get adminSectionPayments => 'Payments';

  @override
  String get adminSectionSettings => 'Settings';

  @override
  String get adminDashboardCity => 'Sarajevo';

  @override
  String adminMapPinLabel(Object label) {
    return '$label';
  }

  @override
  String get adminAddGymPlus => '+ Add gym';

  @override
  String get adminMembershipValid => 'Membership valid.';

  @override
  String get adminMembershipInvalid => 'Membership invalid.';

  @override
  String adminQrIssued(Object token) {
    return 'QR issued: $token';
  }

  @override
  String get adminMemberDeleted => 'Member deleted.';

  @override
  String get adminMemberCreated => 'Member created.';

  @override
  String get adminTrainerAdded => 'Trainer added.';

  @override
  String get adminCreateRequiredFields =>
      'Name, email, and password are required.';

  @override
  String adminPasswordMin(Object count) {
    return 'Password must be at least $count characters.';
  }

  @override
  String get adminTrainerHourlyRateRequired => 'Hourly rate is required.';

  @override
  String get adminTrainerPhotoUrlHint => 'Photo URL (optional)';

  @override
  String get adminTrainerHourlyRateHint => 'Hourly rate';

  @override
  String get adminTrainerDescriptionHint => 'Description / info (optional)';

  @override
  String get adminSearchMembersHint => 'Search by name, email, phone';

  @override
  String get adminSearchMembershipsHint => 'Search by user, gym, status';

  @override
  String get adminSearchRequestsHint => 'Search by member, gym, status';

  @override
  String get adminSearchPaymentsHint => 'Search member, gym, method';

  @override
  String get adminSearchAllHint => 'Search gyms, members, trainers';

  @override
  String get adminSearchTrainerHint => 'Search trainer by name';

  @override
  String get adminSearchGymsHint => 'Search gyms';

  @override
  String get adminAccessLogSearchHint => 'Member search';

  @override
  String get adminSearchNotificationsHint => 'Search notifications';

  @override
  String get adminSearchPlansHint => 'Search gym plans';

  @override
  String get adminAddPlan => 'Add plan';

  @override
  String get adminAddGymPlanTitle => 'Add gym plan';

  @override
  String get adminEditGymPlanTitle => 'Edit gym plan';

  @override
  String get adminMembershipsPerMonthTitle => 'Memberships per month';

  @override
  String get adminRevenuePerMonthTitle => 'Revenue per month';

  @override
  String get adminTopTrainersTitle => 'Top trainers';

  @override
  String get adminMembershipGrowthTitle => 'Membership growth';

  @override
  String get adminRevenueTrendTitle => 'Revenue trend';

  @override
  String get adminNoGyms => 'No gyms';

  @override
  String get adminNoCertifications => 'No certifications';

  @override
  String get adminRequestApproved => 'Request approved.';

  @override
  String get adminRequestRejected => 'Request rejected.';

  @override
  String get adminDefaultRejectionReason =>
      'Sorry, we have full capacity right now. Please try again sometime.';

  @override
  String get adminViewNotifications => 'View notifications';

  @override
  String get adminMemberDetailNotFound => 'Member detail not found.';

  @override
  String get adminTrainerDetailNotFound => 'Trainer detail not found.';

  @override
  String get adminMemberSince => 'Member since';

  @override
  String adminQrStatus(Object status) {
    return 'QR $status';
  }

  @override
  String get adminNoActiveQr => 'No active QR pass';

  @override
  String adminQrExpires(Object date) {
    return 'Expires $date';
  }

  @override
  String get adminNoAccessLogsYet => 'No access logs yet.';

  @override
  String adminLastAccess(Object date, Object gym) {
    return 'Last access: $date • $gym';
  }

  @override
  String get adminSessionsTitle => 'Sessions';

  @override
  String get locationServicesDisabled => 'Location services are disabled.';

  @override
  String get locationPermissionDenied => 'Location permission denied.';

  @override
  String mapOpenGym(Object name) {
    return 'Open $name';
  }

  @override
  String get qrPassTitle => 'QR Code Pass';

  @override
  String get gymNameFallback => 'FitCity Gym';

  @override
  String trainerHourlyRate(Object rate) {
    return 'Hourly rate: $rate KM/hr';
  }

  @override
  String get trainerHourlyRateNotSet => 'Hourly rate not set.';

  @override
  String get requestsTrainingSession => 'Training session';

  @override
  String get commonAccept => 'Accept';

  @override
  String get bookingSlotBlocked => 'Blocked';

  @override
  String get gymListRecommendedTrainersTitle => 'Recommended trainers';

  @override
  String get gymListRecommendedGymsTitle => 'Recommended gyms';

  @override
  String get gymListSearchHint => 'Search gyms';

  @override
  String get gymListLocating => 'Locating...';

  @override
  String get gymListSortDefault => 'Sort: Default';

  @override
  String get gymListSortNearest => 'Sort: Nearest';

  @override
  String get gymListOpenMap => 'Open map';

  @override
  String gymListDistanceAway(Object distance) {
    return '$distance km away';
  }
}
