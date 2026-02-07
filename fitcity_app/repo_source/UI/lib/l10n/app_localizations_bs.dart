// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bosnian (`bs`).
class AppLocalizationsBs extends AppLocalizations {
  AppLocalizationsBs([String locale = 'bs']) : super(locale);

  @override
  String get commonSignIn => 'Prijava';

  @override
  String get commonSignOut => 'Odjava';

  @override
  String get commonSettings => 'Postavke';

  @override
  String commonRoleLabel(Object role) {
    return 'Uloga: $role';
  }

  @override
  String get commonGuest => 'Gost';

  @override
  String get commonNotSignedIn => 'Niste prijavljeni';

  @override
  String get commonTryAgain => 'Pokušajte ponovo.';

  @override
  String get errorsGeneric =>
      'Nešto je pošlo po zlu. Pokušajte ponovo kasnije.';

  @override
  String get errorsNetwork =>
      'Greška mreže. Provjerite internet vezu i pokušajte ponovo.';

  @override
  String get errorsValidation => 'Provjerite unos i pokušajte ponovo.';

  @override
  String get errorRegistrationDisabled =>
      'Registracija novih korisnika je trenutno onemogućena.';

  @override
  String get errorTrainerCreationDisabled =>
      'Dodavanje novih trenera je trenutno onemogućeno.';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profilePhotoTooLarge => 'Fotografija mora biti 5MB ili manja.';

  @override
  String get profilePhotoInvalidType =>
      'Dozvoljene su samo JPG, PNG ili WebP datoteke.';

  @override
  String get profileChooseFromGallery => 'Odaberi iz galerije';

  @override
  String get profileTakePhoto => 'Napravi fotografiju';

  @override
  String get profilePhotoUploadFailed =>
      'Trenutno nije moguće učitati fotografiju. Pokušajte ponovo.';

  @override
  String get profilePhotoUpdated => 'Fotografija je ažurirana.';

  @override
  String get profileCurrentGym => 'Trenutna teretana';

  @override
  String get profileSwitchGym => 'Promijeni teretanu';

  @override
  String get profileMemberships => 'Članarine';

  @override
  String get profileNoActiveMemberships => 'Nema aktivnih članarina.';

  @override
  String get profileActivePass => 'Aktivna karta';

  @override
  String get profileAllMemberships => 'Sve članarine';

  @override
  String get profileTrainerTools => 'Alati trenera';

  @override
  String get profileSchedule => 'Raspored';

  @override
  String get profileRequests => 'Zahtjevi';

  @override
  String get profileTrainerChat => 'Chat s trenerom';

  @override
  String get profilePreferences => 'Preferencije';

  @override
  String get profilePreferencesEmpty => 'Nema spremljenih preferencija.';

  @override
  String get profilePersonalInformation => 'Lični podaci';

  @override
  String get profileNotifications => 'Obavijesti';

  @override
  String get profileEdit => 'Uredi profil';

  @override
  String get settingsLanguage => 'Jezik';

  @override
  String get settingsTitle => 'Postavke';

  @override
  String get settingsPushNotifications => 'Push obavijesti';

  @override
  String get settingsAutoRenew => 'Automatsko obnavljanje članarine';

  @override
  String get settingsChangePassword => 'Promijeni lozinku';

  @override
  String get settingsTermsOfService => 'Uslovi korištenja';

  @override
  String get settingsTermsTodo => 'Uslovi korištenja trenutno nisu dostupni.';

  @override
  String get settingsGeneral => 'Općenito';

  @override
  String get settingsAllowGymRegistrations =>
      'Dozvoli nove registracije teretana';

  @override
  String get settingsAllowUserRegistrations =>
      'Dozvoli registraciju novih korisnika';

  @override
  String get settingsAllowTrainerCreation => 'Dozvoli dodavanje novih trenera';

  @override
  String get settingsSave => 'Spremi postavke';

  @override
  String get languageEnglish => 'Engleski';

  @override
  String get languageBosnian => 'Bosanski';

  @override
  String get languageGerman => 'Njemački';

  @override
  String get authLoginFailed => 'Prijava nije uspjela. Pokušajte ponovo.';

  @override
  String get authAuthenticationFailed =>
      'Autentikacija nije uspjela. Pokušajte ponovo.';

  @override
  String get authDesktopWorkspace => 'Desktop radni prostor';

  @override
  String get authAccessTitle => 'FitCity pristup';

  @override
  String get authLogin => 'Prijava';

  @override
  String get authRegister => 'Registracija';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Lozinka';

  @override
  String get authConfirmPasswordLabel => 'Potvrdite lozinku';

  @override
  String get authFullNameLabel => 'Ime i prezime';

  @override
  String get authPhoneOptionalLabel => 'Broj telefona (opcionalno)';

  @override
  String get authPleaseWait => 'Molimo sačekajte...';

  @override
  String get authCreateAccount => 'Kreiraj račun';

  @override
  String get authNotAuthenticatedYet => 'Još niste prijavljeni.';

  @override
  String get authCurrentUser => 'Trenutni korisnik';

  @override
  String get authEmailRequired => 'Email je obavezan.';

  @override
  String get authEmailInvalid => 'Unesite ispravnu email adresu.';

  @override
  String get authPasswordRequired => 'Lozinka je obavezna.';

  @override
  String get authPasswordTooShort => 'Lozinka mora imati najmanje 8 karaktera.';

  @override
  String get authConfirmPasswordRequired => 'Potvrdite lozinku.';

  @override
  String get authPasswordMismatch => 'Lozinke se ne podudaraju.';

  @override
  String get authFullNameRequired => 'Ime i prezime su obavezni.';

  @override
  String get authSuccessSnackbar => 'Uspješno ste prijavljeni.';

  @override
  String get errorsInvalidCredentials => 'Neispravni podaci za prijavu.';

  @override
  String get profilePhotoRequired => 'Odaberite fotografiju za upload.';

  @override
  String get adminLoginTitle => 'FitCity admin';

  @override
  String adminLoginSubtitle(Object role) {
    return 'Prijavite se s $role računom kako biste nastavili.';
  }

  @override
  String get adminRoleCentral => 'Centralni administrator';

  @override
  String get adminRoleGym => 'Administrator teretane';

  @override
  String get adminRoleAdministrator => 'Administrator';

  @override
  String get adminAccessRequired =>
      'Administrator pristup je potreban za ovaj prostor.';

  @override
  String get adminSigningIn => 'Prijava u toku...';

  @override
  String get navGyms => 'Teretane';

  @override
  String get navPass => 'Karta';

  @override
  String get navBookings => 'Rezervacije';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfile => 'Profil';

  @override
  String get navAlerts => 'Obavijesti';

  @override
  String get navSchedule => 'Raspored';

  @override
  String get navRequests => 'Zahtjevi';

  @override
  String get changePasswordTitle => 'Promijeni lozinku';

  @override
  String get changePasswordUpdateTitle => 'Ažuriraj lozinku';

  @override
  String get changePasswordCurrent => 'Trenutna lozinka';

  @override
  String get changePasswordNew => 'Nova lozinka';

  @override
  String get changePasswordConfirm => 'Potvrdite novu lozinku';

  @override
  String get changePasswordAllRequired => 'Sva polja su obavezna.';

  @override
  String get changePasswordMismatch => 'Nove lozinke se ne podudaraju.';

  @override
  String get changePasswordTooShort =>
      'Lozinka mora imati najmanje 6 karaktera.';

  @override
  String get changePasswordSuccess => 'Lozinka je uspješno promijenjena.';

  @override
  String get changePasswordSaving => 'Spremanje...';

  @override
  String get changePasswordSave => 'Sačuvaj promjene';

  @override
  String get gymNoSelection => 'Nema odabrane teretane';

  @override
  String gymCurrentLabel(Object name) {
    return 'Trenutna teretana: $name';
  }

  @override
  String get gymSwitch => 'Promijeni';

  @override
  String get gymGuardSelect => 'Odaberite teretanu za nastavak.';

  @override
  String get gymGuardChooseList => 'Odaberi s liste';

  @override
  String get gymGuardOpenMap => 'Otvori mapu';

  @override
  String get commonCancel => 'Otkaži';

  @override
  String get commonDelete => 'Obriši';

  @override
  String get commonClose => 'Zatvori';

  @override
  String get commonSave => 'Spremi';

  @override
  String get commonView => 'Prikaži';

  @override
  String get commonLater => 'Kasnije';

  @override
  String get commonAll => 'Sve';

  @override
  String get commonPending => 'Na čekanju';

  @override
  String get commonApproved => 'Odobreno';

  @override
  String get commonRejected => 'Odbijeno';

  @override
  String get commonActive => 'Aktivno';

  @override
  String get commonInactive => 'Neaktivno';

  @override
  String get commonRefresh => 'Osvježi';

  @override
  String get commonBack => 'Nazad';

  @override
  String get commonMembers => 'Članovi';

  @override
  String get commonTrainers => 'Treneri';

  @override
  String get commonGyms => 'Teretane';

  @override
  String get commonPayments => 'Plaćanja';

  @override
  String get commonDashboard => 'Kontrolna tabla';

  @override
  String get commonNotifications => 'Obavijesti';

  @override
  String get commonAccessLogs => 'Evidencija ulaza';

  @override
  String get commonMemberships => 'Članarine';

  @override
  String get commonAnalytics => 'Analitika';

  @override
  String get commonNoResults => 'Još nema rezultata.';

  @override
  String get commonNoData => 'Još nema podataka.';

  @override
  String get commonUnknown => 'Nepoznato';

  @override
  String get commonWorking => 'U toku...';

  @override
  String get commonCreate => 'Kreiraj';

  @override
  String get desktopAppTitle => 'FitCity';

  @override
  String get desktopUnableLoadAdmin =>
      'Nije moguće učitati administratorske podatke';

  @override
  String get adminNewMembershipRequestTitle => 'Novi zahtjev za članstvo';

  @override
  String adminNewMembershipRequestBody(Object count, Object suffix) {
    return 'Imate $count novih obavijesti o zahtjevu za članstvo$suffix.';
  }

  @override
  String get adminViewRequests => 'Pregledaj zahtjeve';

  @override
  String get adminGymListTitle => 'Lista teretana';

  @override
  String get adminNoGymsFound => 'Nema pronađenih teretana.';

  @override
  String get adminDeleteMemberTitle => 'Obriši člana';

  @override
  String get adminDeleteMemberConfirm =>
      'Ovo će trajno obrisati člana ako ne postoje povezani zapisi. Nastaviti?';

  @override
  String get adminMemberDetails => 'Detalji člana';

  @override
  String adminMembershipStatus(Object status) {
    return 'Status: $status';
  }

  @override
  String adminMembershipEnds(Object date) {
    return 'Ističe: $date';
  }

  @override
  String get adminManageMembers => 'Upravljanje članovima';

  @override
  String adminRecordsCount(Object count) {
    return '$count zapisa';
  }

  @override
  String get adminNoMembershipsFound => 'Nema pronađenih članarina.';

  @override
  String get adminValidate => 'Validiraj';

  @override
  String get adminRejectMembershipTitle => 'Odbij zahtjev za članstvo';

  @override
  String get adminRejectionReason => 'Razlog odbijanja';

  @override
  String get adminMembershipRequests => 'Zahtjevi za članstvo';

  @override
  String get adminNoMembershipRequests =>
      'Nema pronađenih zahtjeva za članstvo.';

  @override
  String get adminPaymentsTitle => 'Plaćanja';

  @override
  String get adminNoPaymentsFound => 'Nema pronađenih plaćanja.';

  @override
  String get adminAddMember => 'Dodaj člana';

  @override
  String get adminAddTrainer => 'Dodaj trenera';

  @override
  String get adminMembersTitle => 'Članovi';

  @override
  String get adminScanQr => 'Skeniraj QR kod';

  @override
  String get adminNoMembersFound => 'Nema pronađenih članova.';

  @override
  String get adminAllGyms => 'Sve teretane';

  @override
  String get adminAllCities => 'Svi gradovi';

  @override
  String get adminAllStatuses => 'Svi statusi';

  @override
  String adminHoursLabel(Object hours) {
    return 'Radno vrijeme: $hours';
  }

  @override
  String adminMembersCount(Object count) {
    return '$count članova';
  }

  @override
  String adminTrainersCount(Object count) {
    return '$count trenera';
  }

  @override
  String get adminNoMemberships => 'Nema članarina';

  @override
  String adminTrainerRate(Object rate) {
    return '$rate KM/sat';
  }

  @override
  String adminTrainerUpcoming(Object count) {
    return '$count nadolazećih';
  }

  @override
  String get adminTrainersTitle => 'Treneri';

  @override
  String adminTrainersActive(Object count) {
    return '$count aktivnih';
  }

  @override
  String get adminNoTrainersFound => 'Nema pronađenih trenera.';

  @override
  String get adminAccessLogsTitle => 'Evidencija ulaza';

  @override
  String get adminAccessGranted => 'Odobreno';

  @override
  String get adminAccessDenied => 'Odbijeno';

  @override
  String get adminNoAccessLogs => 'Nema evidencije ulaza.';

  @override
  String get adminAccessLogTitle => 'Evidencija ulaza';

  @override
  String get adminNoNotifications => 'Nema obavijesti.';

  @override
  String get adminReferenceData => 'Referentni podaci';

  @override
  String get adminNoGymPlans => 'Nema pronađenih planova.';

  @override
  String get adminEdit => 'Uredi';

  @override
  String get adminDeleteGymPlanTitle => 'Obriši plan teretane';

  @override
  String adminDeleteGymPlanConfirm(Object name) {
    return 'Obrisati \"$name\"?';
  }

  @override
  String adminPlanLine(Object gym, Object months) {
    return '$gym • $months mjeseci';
  }

  @override
  String adminPlanPrice(Object price) {
    return '$price KM';
  }

  @override
  String get adminNoMembershipsYet => 'Još nema članarina.';

  @override
  String get adminNoBookingsYet => 'Još nema rezervacija.';

  @override
  String get adminNoGymAssociation => 'Još nema povezanih teretana.';

  @override
  String get adminNoScheduleEntries => 'Nema unosa rasporeda.';

  @override
  String get adminNoSessionsRecorded => 'Nema zabilježenih sesija.';

  @override
  String get adminActiveGyms => 'Aktivne teretane';

  @override
  String adminTotalGyms(Object count) {
    return 'Ukupno $count';
  }

  @override
  String get adminMemberLabel => 'Član';

  @override
  String get adminMembershipRequestLabel => 'Zahtjev za članstvo';

  @override
  String get adminNotificationsLabel => 'Obavijesti';

  @override
  String adminCurrencyKm(Object amount) {
    return '$amount KM';
  }

  @override
  String get adminNoReportData => 'Još nema izvještaja.';

  @override
  String get adminNoRevenueData => 'Još nema podataka o prihodima.';

  @override
  String get adminNoTrainerActivity => 'Još nema aktivnosti trenera.';

  @override
  String adminReportLine(Object month, Object year, Object count) {
    return '$month/$year • $count novih';
  }

  @override
  String adminRevenueLine(Object month, Object year, Object amount) {
    return '$month/$year • $amount';
  }

  @override
  String adminTrainerActivityLine(Object name, Object count) {
    return '$name • $count rezervacija';
  }

  @override
  String adminDeleteMemberConfirmName(Object name) {
    return 'Obrisati $name? Ovo se ne može poništiti.';
  }

  @override
  String get adminMembershipLabel => 'Članarina';

  @override
  String get adminNoMembershipData => 'Još nema podataka o članarinama.';

  @override
  String get desktopAppName => 'FitCity aplikacija';

  @override
  String get adminScanQrCode => 'Skeniraj QR kod';

  @override
  String get adminScanQrHint => 'Usmjeri kod unutar okvira.';

  @override
  String get adminAddMemberPlus => '+ Dodaj člana';

  @override
  String get adminAddGymTitle => 'Dodaj teretanu';

  @override
  String get adminCreateGym => 'Kreiraj teretanu';

  @override
  String get adminGymCreated => 'Teretana kreirana.';

  @override
  String get adminGymNameLabel => 'Naziv teretane';

  @override
  String get adminGymNameRequired => 'Naziv teretane je obavezan.';

  @override
  String get adminGymAddressLabel => 'Adresa (opcionalno)';

  @override
  String get adminGymCityLabel => 'Grad (opcionalno)';

  @override
  String get adminGymPhoneLabel => 'Kontakt telefon (opcionalno)';

  @override
  String get adminGymDescriptionLabel => 'Opis (opcionalno)';

  @override
  String get adminGymWorkHoursLabel => 'Radno vrijeme (opcionalno)';

  @override
  String get adminGymLocationLabel => 'Lokacija';

  @override
  String get adminGymLocationHint => 'Kliknite na mapu da postavite lokaciju.';

  @override
  String adminGymLocationLatLng(Object lat, Object lng) {
    return 'Odabrano: $lat, $lng';
  }

  @override
  String get adminGymLocationRequired => 'Lokacija je obavezna.';

  @override
  String get adminGymLocationMissing => 'Lokacija nije postavljena';

  @override
  String get adminGymSearchAddressHint => 'Pretraži adresu';

  @override
  String get adminGymSearchAddressAction => 'Pretraži';

  @override
  String get adminGymAddressSearchFailed =>
      'Ne možemo pretražiti adresu trenutno.';

  @override
  String get adminGymEntryQrTitle => 'QR za ulaz';

  @override
  String get adminGymEntryQrHint => 'Prikaži ovaj kod na ulazu u teretanu.';

  @override
  String get adminScannerTitle => 'Skener';

  @override
  String get adminScannerPause => 'Pauza';

  @override
  String get adminScannerResume => 'Nastavi';

  @override
  String get adminScannerStatusIdle => 'Spreman';

  @override
  String get adminScannerStatusScanning => 'Skenira';

  @override
  String get adminScannerStatusPaused => 'Pauzirano';

  @override
  String get adminScannerStatusSuccess => 'Uspjeh';

  @override
  String get adminScannerStatusError => 'Greška';

  @override
  String get adminScannerInvalidQr => 'Ovaj QR kod nije FitCity članski QR.';

  @override
  String get adminScannerEntryQr =>
      'Ovo je QR za ulaz u teretanu. Skenirajte članski QR.';

  @override
  String get adminScannerMemberTokenMissing =>
      'Nedostaje token članskog QR koda.';

  @override
  String get adminScannerDuplicate => 'Već skenirano. Molimo sačekajte...';

  @override
  String get commonName => 'Ime';

  @override
  String get commonEmail => 'Email';

  @override
  String get commonMembership => 'Članarina';

  @override
  String get membershipAnnual => 'Godišnja';

  @override
  String get membershipMonthly => 'Mjesečna';

  @override
  String get sampleMemberName => 'John Doe';

  @override
  String get sampleMemberEmail => 'johndoe@gmail.com';

  @override
  String get notificationsTitle => 'Obavijesti';

  @override
  String get notificationsMarkAllRead => 'Označi sve kao pročitano';

  @override
  String get notificationsEmpty => 'Još nema obavijesti.';

  @override
  String get notificationRead => 'Pročitano';

  @override
  String get notificationNew => 'Novo';

  @override
  String get bookingsTitle => 'Rezervacije';

  @override
  String get bookingsUpcomingTab => 'Nadolazeće rezervacije';

  @override
  String get bookingsEntryHistoryTab => 'Historija ulaza';

  @override
  String get bookingsNoUpcoming => 'Nema nadolazećih termina.';

  @override
  String bookingsStatusLabel(Object status) {
    return 'Status: $status';
  }

  @override
  String bookingsTrainerLabel(Object name) {
    return 'Trener: $name';
  }

  @override
  String bookingsGymLabel(Object name) {
    return 'Teretana: $name';
  }

  @override
  String bookingsStartLabel(Object date) {
    return 'Početak: $date';
  }

  @override
  String bookingsPaymentLabel(Object status) {
    return 'Plaćanje: $status';
  }

  @override
  String get bookingsNoEntries =>
      'Još nema ulazaka u teretanu. Skenirajte QR kod u teretani da kreirate prvi ulaz.';

  @override
  String get bookingsGymEntry => 'Ulaz u teretanu';

  @override
  String get bookingsEntered => 'Ulazak';

  @override
  String get bookingScreenTitle => 'Rezerviši trenera';

  @override
  String get bookingSelectGymMessage =>
      'Odaberite teretanu da rezervišete trenera.';

  @override
  String get bookingLocationLabel => 'Lokacija';

  @override
  String get bookingTrainerLabel => 'Trener';

  @override
  String bookingDateLabel(Object date) {
    return 'Datum: $date';
  }

  @override
  String get bookingPaymentCard => 'Kartica';

  @override
  String get bookingPaymentPayPal => 'PayPal';

  @override
  String get bookingPaymentCash => 'Gotovina';

  @override
  String get bookingAvailableSlots => 'Dostupni termini';

  @override
  String get bookingSelectSlot => 'Odaberite termin';

  @override
  String get bookingCreate => 'Kreiraj rezervaciju';

  @override
  String get bookingViewAll => 'Prikaži sve rezervacije';

  @override
  String get bookingTrainerNotFound => 'Trener nije pronađen.';

  @override
  String get bookingSelectSlotFirst => 'Prvo odaberite dostupan termin.';

  @override
  String get bookingNoSlotsDate => 'Nema termina za odabrani datum.';

  @override
  String get bookingNoSlotsRange => 'Nema termina u odabranom periodu.';

  @override
  String get bookingSlotAvailable => 'Dostupno';

  @override
  String get bookingSlotBooked => 'Zauzeto';

  @override
  String bookingTrainerRateLabel(Object name, Object rate) {
    return '$name - $rate KM/sat';
  }

  @override
  String get bookingConfirmedTitle => 'Rezervacija potvrđena';

  @override
  String get bookingViewUpcoming => 'Prikaži nadolazeće rezervacije';

  @override
  String get bookingChatWithTrainer => 'Chat s trenerom';

  @override
  String bookingChatWithName(Object name) {
    return 'Chat s $name';
  }

  @override
  String get bookingLabelTrainer => 'Trener';

  @override
  String get bookingLabelGym => 'Teretana';

  @override
  String get bookingLabelStart => 'Početak';

  @override
  String get bookingLabelEnd => 'Kraj';

  @override
  String get bookingLabelPayment => 'Plaćanje';

  @override
  String get commonTrainer => 'Trener';

  @override
  String get commonViewAll => 'Pogledaj sve';

  @override
  String get membershipActivePassTitle => 'Aktivna karta';

  @override
  String get membershipShowQrPass => 'Prikaži QR kartu';

  @override
  String get membershipManageHint =>
      'Upravljajte ili obnovite planove u listi članarina.';

  @override
  String get membershipApprovedTitle => 'Članarina odobrena';

  @override
  String membershipPaymentStatus(Object status) {
    return 'Status plaćanja: $status';
  }

  @override
  String get membershipUnpaid => 'Neplaćeno';

  @override
  String membershipGymLabel(Object name) {
    return 'Teretana: $name';
  }

  @override
  String get membershipPayAction => 'Plati članarinu';

  @override
  String get membershipProcessing => 'Obrada...';

  @override
  String get membershipPendingTitle => 'Članarina na čekanju';

  @override
  String membershipStatusLabel(Object status) {
    return 'Status: $status';
  }

  @override
  String get membershipRejectedDefault => 'Vaš zahtjev za članstvo je odbijen.';

  @override
  String get membershipBrowseGyms => 'Pregledaj teretane';

  @override
  String get membershipExpiredTitle => 'Članarina istekla';

  @override
  String membershipExpiredOn(Object date) {
    return 'Isteklo: $date';
  }

  @override
  String get membershipRenew => 'Obnovi članarinu';

  @override
  String get membershipNoActiveTitle => 'Nema aktivne članarine';

  @override
  String get membershipBrowseHint => 'Pregledajte teretane da započnete plan.';

  @override
  String get membershipNoData => 'Nema podataka o članarini.';

  @override
  String get membershipConfirmPaymentTitle => 'Potvrdi plaćanje';

  @override
  String membershipConfirmPaymentBody(Object gymSuffix) {
    return 'Platiti 30-dnevnu članarinu$gymSuffix? Vaša karta se aktivira odmah.';
  }

  @override
  String get membershipPayNow => 'Plati sada';

  @override
  String get membershipPaymentSuccessTitle => 'Plaćanje uspješno';

  @override
  String get paymentOpenBrowser =>
      'Završite plaćanje u pregledniku, zatim se vratite u aplikaciju.';

  @override
  String get paymentPendingConfirmation => 'Čekanje potvrde plaćanja...';

  @override
  String get paymentConfirmed => 'Plaćanje potvrđeno.';

  @override
  String get paymentInvalidCheckoutUrl => 'Neispravan link za plaćanje.';

  @override
  String get paymentLaunchFailed => 'Nije moguće otvoriti plaćanje.';

  @override
  String get paymentPayPalUnavailable =>
      'PayPal trenutno nije dostupan. Izaberite Kartica.';

  @override
  String get paymentChooseMethod => 'Izaberite način plaćanja';

  @override
  String get paymentUseStripe => 'Plati karticom (Stripe)';

  @override
  String get paymentMarkPaid => 'Označi kao plaćeno (lokalno)';

  @override
  String get paymentManualDisabled => 'Lokalno plaćanje je onemogućeno.';

  @override
  String membershipActiveUntil(Object date) {
    return 'Članarina aktivna do $date';
  }

  @override
  String get membershipShowQr => 'Prikaži QR';

  @override
  String get membershipPassLabel => 'Članarina';

  @override
  String get membershipGymNameFallback => 'Teretana';

  @override
  String membershipDaysLeft(Object count) {
    return '$count dana preostalo';
  }

  @override
  String membershipStartLabel(Object date) {
    return 'Početak: $date';
  }

  @override
  String membershipEndLabel(Object date) {
    return 'Kraj: $date';
  }

  @override
  String get commonSuccess => 'Uspjeh';

  @override
  String get commonEntered => 'Ulazak';

  @override
  String get chatTitle => 'Chat';

  @override
  String get chatNoConversations => 'Još nema razgovora.';

  @override
  String get chatPaymentDetails => 'Detalji plaćanja';

  @override
  String get chatLoadEarlier => 'Učitaj ranije poruke';

  @override
  String get emailDemoTitle => 'Email demo';

  @override
  String get gymDetailSignInToRequest =>
      'Prijavite se da biste zatražili članstvo.';

  @override
  String gymDetailMembershipRequest(Object status) {
    return 'Zahtjev za članstvo: $status';
  }

  @override
  String get gymDetailChoosePayment => 'Odaberite način plaćanja';

  @override
  String get gymDetailCard => 'Kartica';

  @override
  String get gymDetailPayPal => 'PayPal';

  @override
  String gymDetailHoursLabel(Object hours) {
    return 'Radno vrijeme: $hours';
  }

  @override
  String get gymDetailTrainersTitle => 'Treneri';

  @override
  String get gymDetailNoTrainers => 'Još nema dodijeljenih trenera.';

  @override
  String get gymDetailReviewsTitle => 'Recenzije';

  @override
  String get gymDetailNoReviews => 'Još nema recenzija.';

  @override
  String get gymDetailWaitingApproval => 'Čeka odobrenje';

  @override
  String get gymDetailApprovedPaymentRequired => 'Odobreno - potrebno plaćanje';

  @override
  String get gymDetailViewMemberships => 'Pogledaj članarine';

  @override
  String get gymDetailBookTrainer => 'Rezerviši trenera';

  @override
  String get gymDetailSwitchGym => 'Promijeni teretanu';

  @override
  String get gymDetailChat => 'Chat';

  @override
  String gymListTitle(Object city) {
    return 'Teretane u $city';
  }

  @override
  String get gymListNoTrainerRecommendations => 'Još nema preporuka trenera.';

  @override
  String get gymListNoGymRecommendations => 'Još nema preporuka teretana.';

  @override
  String get membershipListTitle => 'Članarine';

  @override
  String membershipSignedInAs(Object email) {
    return 'Prijavljeni kao $email';
  }

  @override
  String get membershipSelectGym => 'Odaberite teretanu';

  @override
  String get membershipViewActivePass => 'Prikaži aktivnu kartu';

  @override
  String get membershipRequest => 'Zatraži članstvo';

  @override
  String membershipRequestStatus(Object status) {
    return 'Status zahtjeva: $status';
  }

  @override
  String membershipQrToken(Object token) {
    return 'QR token: $token';
  }

  @override
  String get membershipActiveListTitle => 'Aktivne članarine';

  @override
  String get membershipNoMemberships => 'Nema članarina.';

  @override
  String membershipStatusLine(Object status) {
    return 'Članarina $status';
  }

  @override
  String membershipValidUntil(Object date) {
    return 'Važi do: $date';
  }

  @override
  String get membershipIssueQr => 'Izdaj QR kod';

  @override
  String get mapTitle => 'FitCity mapa';

  @override
  String get qrShowAtEntrance => 'Pokažite ovaj kod na ulazu';

  @override
  String get qrNotAvailable => 'QR nije dostupan';

  @override
  String qrExpiryDate(Object date) {
    return 'Datum isteka: $date';
  }

  @override
  String get qrDeniedTitle => 'Ulaz odbijen';

  @override
  String get qrDeniedWrongGym => 'Ovaj QR kod nije važeći za ovu teretanu.';

  @override
  String get qrDeniedExpired => 'Ovaj QR kod je istekao.';

  @override
  String get qrDeniedInactive => 'Članarina je neaktivna ili istekla.';

  @override
  String get qrDeniedInvalid => 'Ovaj QR kod nije važeći.';

  @override
  String get qrDeniedGeneric => 'Ulaz odbijen. Pokušajte ponovo.';

  @override
  String qrTokenLabel(Object token) {
    return 'Token: $token';
  }

  @override
  String get reportsDesktopOnlyTitle =>
      'Administratorski izvještaji su dostupni samo na desktopu.';

  @override
  String get reportsDesktopOnlyBody =>
      'Prijavite se na desktop aplikaciju da biste vidjeli analitiku i izvještaje.';

  @override
  String get reportsTitle => 'Izvještaji';

  @override
  String get reportsBackHome => 'Nazad na početnu';

  @override
  String get recommendedTitle => 'Preporučeno';

  @override
  String get requestsOpenChats => 'Otvori chatove';

  @override
  String get requestsTitle => 'Zahtjevi za trening';

  @override
  String get requestsEmpty => 'Trenutno nema zahtjeva na čekanju.';

  @override
  String get requestsDecline => 'Odbij';

  @override
  String get scheduleRequests => 'Zahtjevi za trening';

  @override
  String get scheduleNoEntries => 'Još nema unosa rasporeda.';

  @override
  String get trainerNotFound => 'Trener nije pronađen.';

  @override
  String get trainerTitle => 'Trener';

  @override
  String get trainerWorkLocations => 'Lokacije rada';

  @override
  String get trainerAbout => 'O treneru';

  @override
  String get trainerCertifications => 'Certifikati';

  @override
  String trainerRate(Object rate) {
    return '$rate KM/sat';
  }

  @override
  String get emailDemoToLabel => 'Za';

  @override
  String get emailDemoSubjectLabel => 'Tema';

  @override
  String get emailDemoMessageLabel => 'Poruka';

  @override
  String get emailDemoSend => 'Pošalji demo email';

  @override
  String emailDemoQueued(Object email) {
    return 'Demo email na čekanju za $email.';
  }

  @override
  String get emailDemoDisclaimer =>
      'Ovaj ekran je mock. Pravi emailovi se šalju preko FitCity.Notifications.Api i RabbitMQ.';

  @override
  String get profileEditTitle => 'Uredi profil';

  @override
  String get profileFullNameLabel => 'Ime i prezime';

  @override
  String get profileEmailLabel => 'Email';

  @override
  String get profilePhoneLabel => 'Telefon';

  @override
  String get profileFullNameRequired => 'Ime i prezime su obavezni.';

  @override
  String get commonSaving => 'Spremanje...';

  @override
  String get commonSaveChanges => 'Sačuvaj promjene';

  @override
  String get commonType => 'Tip';

  @override
  String get commonGym => 'Teretana';

  @override
  String get commonCity => 'Grad';

  @override
  String get commonStatus => 'Status';

  @override
  String get commonPriceKm => 'Cijena (KM)';

  @override
  String get commonDurationMonths => 'Trajanje (mjeseci)';

  @override
  String get commonDescription => 'Opis';

  @override
  String get commonRetry => 'Pokušaj ponovo';

  @override
  String get commonSearch => 'Pretraga';

  @override
  String get commonApprove => 'Odobri';

  @override
  String get commonDeleting => 'Brisanje...';

  @override
  String get commonUpdating => 'Ažuriranje...';

  @override
  String get commonFromDate => 'Od datuma';

  @override
  String get commonToDate => 'Do datuma';

  @override
  String get commonMember => 'Član';

  @override
  String get commonPhone => 'Telefon';

  @override
  String get commonReason => 'Razlog';

  @override
  String get commonTime => 'Vrijeme';

  @override
  String get commonRate => 'Cijena';

  @override
  String get commonBio => 'Biografija';

  @override
  String get commonSignedOut => 'Odjavljeni ste.';

  @override
  String get adminSectionManageGyms => 'Upravljanje teretanama';

  @override
  String get adminSectionManageMembers => 'Upravljanje članovima';

  @override
  String get adminSectionMembershipRequests => 'Zahtjevi za članstvo';

  @override
  String get adminSectionPayments => 'Plaćanja';

  @override
  String get adminSectionSettings => 'Postavke';

  @override
  String get adminDashboardCity => 'Sarajevo';

  @override
  String adminMapPinLabel(Object label) {
    return '$label';
  }

  @override
  String get adminAddGymPlus => '+ Dodaj teretanu';

  @override
  String get adminMembershipValid => 'Članarina je validna.';

  @override
  String get adminMembershipInvalid => 'Članarina nije validna.';

  @override
  String adminQrIssued(Object token) {
    return 'QR izdan: $token';
  }

  @override
  String get adminMemberDeleted => 'Član obrisan.';

  @override
  String get adminMemberCreated => 'Član kreiran.';

  @override
  String get adminTrainerAdded => 'Trener dodan.';

  @override
  String get adminCreateRequiredFields => 'Ime, email i lozinka su obavezni.';

  @override
  String adminPasswordMin(Object count) {
    return 'Lozinka mora imati najmanje $count karaktera.';
  }

  @override
  String get adminTrainerHourlyRateRequired => 'Satnica je obavezna.';

  @override
  String get adminTrainerPhotoUrlHint => 'URL fotografije (opcionalno)';

  @override
  String get adminTrainerHourlyRateHint => 'Satnica';

  @override
  String get adminTrainerDescriptionHint => 'Opis / info (opcionalno)';

  @override
  String get adminSearchMembersHint => 'Pretraži po imenu, emailu, telefonu';

  @override
  String get adminSearchMembershipsHint =>
      'Pretraži po korisniku, teretani, statusu';

  @override
  String get adminSearchRequestsHint => 'Pretraži po članu, teretani, statusu';

  @override
  String get adminSearchPaymentsHint => 'Pretraži člana, teretanu, metodu';

  @override
  String get adminSearchAllHint => 'Pretraži teretane, članove, trenere';

  @override
  String get adminSearchTrainerHint => 'Pretraži trenera po imenu';

  @override
  String get adminSearchGymsHint => 'Pretraži teretane';

  @override
  String get adminAccessLogSearchHint => 'Pretraga članova';

  @override
  String get adminSearchNotificationsHint => 'Pretraži obavijesti';

  @override
  String get adminSearchPlansHint => 'Pretraži planove teretana';

  @override
  String get adminAddPlan => 'Dodaj plan';

  @override
  String get adminAddGymPlanTitle => 'Dodaj plan teretane';

  @override
  String get adminEditGymPlanTitle => 'Uredi plan teretane';

  @override
  String get adminMembershipsPerMonthTitle => 'Članarine po mjesecu';

  @override
  String get adminRevenuePerMonthTitle => 'Prihod po mjesecu';

  @override
  String get adminTopTrainersTitle => 'Top treneri';

  @override
  String get adminMembershipGrowthTitle => 'Rast članarina';

  @override
  String get adminRevenueTrendTitle => 'Trend prihoda';

  @override
  String get adminNoGyms => 'Nema teretana';

  @override
  String get adminNoCertifications => 'Nema certifikata';

  @override
  String get adminRequestApproved => 'Zahtjev odobren.';

  @override
  String get adminRequestRejected => 'Zahtjev odbijen.';

  @override
  String get adminDefaultRejectionReason =>
      'Žao nam je, trenutno smo puni. Pokušajte ponovo kasnije.';

  @override
  String get adminViewNotifications => 'Pogledaj obavijesti';

  @override
  String get adminMemberDetailNotFound => 'Detalji člana nisu pronađeni.';

  @override
  String get adminTrainerDetailNotFound => 'Detalji trenera nisu pronađeni.';

  @override
  String get adminMemberSince => 'Član od';

  @override
  String adminQrStatus(Object status) {
    return 'QR $status';
  }

  @override
  String get adminNoActiveQr => 'Nema aktivnog QR-a';

  @override
  String adminQrExpires(Object date) {
    return 'Ističe $date';
  }

  @override
  String get adminNoAccessLogsYet => 'Još nema evidencije ulaza.';

  @override
  String adminLastAccess(Object date, Object gym) {
    return 'Zadnji ulaz: $date • $gym';
  }

  @override
  String get adminSessionsTitle => 'Sesije';

  @override
  String get locationServicesDisabled => 'Lokacijske usluge su onemogućene.';

  @override
  String get locationPermissionDenied => 'Dozvola za lokaciju je odbijena.';

  @override
  String mapOpenGym(Object name) {
    return 'Otvori $name';
  }

  @override
  String get qrPassTitle => 'QR karta';

  @override
  String get gymNameFallback => 'FitCity teretana';

  @override
  String trainerHourlyRate(Object rate) {
    return 'Satnica: $rate KM/sat';
  }

  @override
  String get trainerHourlyRateNotSet => 'Satnica nije postavljena.';

  @override
  String get requestsTrainingSession => 'Trening';

  @override
  String get commonAccept => 'Prihvati';

  @override
  String get bookingSlotBlocked => 'Blokirano';

  @override
  String get gymListRecommendedTrainersTitle => 'Preporučeni treneri';

  @override
  String get gymListRecommendedGymsTitle => 'Preporučene teretane';

  @override
  String get gymListSearchHint => 'Pretraži teretane';

  @override
  String get gymListLocating => 'Lociranje...';

  @override
  String get gymListSortDefault => 'Sortiraj: zadano';

  @override
  String get gymListSortNearest => 'Sortiraj: najbliže';

  @override
  String get gymListOpenMap => 'Otvori mapu';

  @override
  String gymListDistanceAway(Object distance) {
    return '$distance km udaljeno';
  }
}
