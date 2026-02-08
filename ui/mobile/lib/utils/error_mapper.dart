import 'package:flutter/widgets.dart';
import '../l10n/l10n.dart';
import '../services/fitcity_api.dart';

String mapApiError(BuildContext context, Object error) {
  if (error is FitCityApiException) {
    return _mapMessage(context, error.message);
  }
  return context.l10n.errorsGeneric;
}

String _mapMessage(BuildContext context, String message) {
  switch (message) {
    case 'Something went wrong. Please try again later.':
      return context.l10n.errorsGeneric;
    case 'Network error. Please check your internet connection and try again.':
      return context.l10n.errorsNetwork;
    case 'Please check your input and try again.':
      return context.l10n.errorsValidation;
    case 'Invalid credentials.':
      return context.l10n.errorsInvalidCredentials;
    case 'Photo must be 5MB or smaller.':
      return context.l10n.profilePhotoTooLarge;
    case 'Only JPG, PNG, or WebP files are allowed.':
      return context.l10n.profilePhotoInvalidType;
    case 'Please select a photo to upload.':
      return context.l10n.profilePhotoRequired;
    case 'Authentication failed. Please try again.':
      return context.l10n.authAuthenticationFailed;
    case 'Login failed. Please try again.':
      return context.l10n.authLoginFailed;
    case 'User registration is currently disabled.':
      return context.l10n.errorRegistrationDisabled;
    case 'Adding new trainers is currently disabled.':
      return context.l10n.errorTrainerCreationDisabled;
    default:
      return context.l10n.errorsGeneric;
  }
}
