import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../l10n/l10n.dart';
import '../../data/fitcity_models.dart';
import '../../services/fitcity_api.dart';
import '../../services/gym_selection.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_mapper.dart';
import '../../utils/date_time_formatter.dart';
import '../../widgets/common.dart';
import '../../widgets/current_gym_indicator.dart';
import '../../widgets/mobile_nav_bar.dart';
import '../../widgets/mobile_app_bar.dart';
import '../../widgets/role_gate.dart';
import 'mobile_active_membership_screen.dart';
import 'mobile_membership_screen.dart';
import 'mobile_notifications_screen.dart';
import 'mobile_auth_screen.dart';
import 'mobile_settings_screen.dart';
import 'mobile_schedule_screen.dart';
import 'mobile_requests_screen.dart';
import 'mobile_chat_screen.dart';
import 'mobile_gym_list_screen.dart';
import 'mobile_profile_edit_screen.dart';

class MobileProfileScreen extends StatefulWidget {
  const MobileProfileScreen({super.key});

  @override
  State<MobileProfileScreen> createState() => _MobileProfileScreenState();
}

class _MobileProfileScreenState extends State<MobileProfileScreen> {
  final FitCityApi _api = FitCityApi.instance;
  List<Membership> _memberships = [];
  String? _statusMessage;
  String? _photoError;
  bool _uploadingPhoto = false;
  Uint8List? _previewBytes;

  static const int _maxPhotoBytes = 5 * 1024 * 1024;
  static const List<String> _allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

  @override
  void initState() {
    super.initState();
    _loadMemberships();
  }

  Future<void> _loadMemberships() async {
    final session = _api.session.value;
    if (session == null || session.user.role != 'User') {
      setState(() => _memberships = []);
      return;
    }
    try {
      final memberships = await _api.memberships();
      setState(() => _memberships = memberships);
    } catch (error) {
      setState(() => _statusMessage = mapApiError(context, error));
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    final session = _api.session.value;
    if (session == null) {
      return;
    }

    final picked = await _pickImage();
    if (picked == null) {
      return;
    }

    if (picked.bytes.length > _maxPhotoBytes) {
      setState(() => _photoError = context.l10n.profilePhotoTooLarge);
      return;
    }

    final extension = _fileExtension(picked.fileName);
    if (extension == null || !_allowedExtensions.contains(extension)) {
      setState(() => _photoError = context.l10n.profilePhotoInvalidType);
      return;
    }

    setState(() {
      _uploadingPhoto = true;
      _photoError = null;
      _previewBytes = picked.bytes;
    });

    try {
      final updated = await _api.uploadProfilePhoto(bytes: picked.bytes, fileName: picked.fileName);
      final current = _api.session.value;
      if (current != null) {
        _api.session.value = AuthSession(auth: current.auth, user: updated);
      }
      setState(() => _previewBytes = null);
    } catch (error) {
      setState(() => _photoError = mapApiError(context, error));
    } finally {
      if (mounted) {
        setState(() => _uploadingPhoto = false);
      }
    }
  }

  Future<_PickedImage?> _pickImage() async {
    final platform = defaultTargetPlatform;
    final isDesktop = platform == TargetPlatform.windows ||
        platform == TargetPlatform.macOS ||
        platform == TargetPlatform.linux;

    if (isDesktop) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowedExtensions,
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        return null;
      }
      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes == null) {
        return null;
      }
      return _PickedImage(fileName: file.name, bytes: bytes);
    }

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: Text(context.l10n.profileChooseFromGallery),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: Text(context.l10n.profileTakePhoto),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
            ],
          ),
        );
      },
    );

    if (source == null) {
      return null;
    }

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 92,
      maxWidth: 1200,
      maxHeight: 1200,
    );
    if (picked == null) {
      return null;
    }
    final bytes = await picked.readAsBytes();
    return _PickedImage(fileName: picked.name, bytes: bytes);
  }

  String? _fileExtension(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot == -1 || dot == fileName.length - 1) {
      return null;
    }
    return fileName.substring(dot + 1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final session = _api.session.value;
    final role = session?.user.role;
    final isTrainer = role == 'Trainer';
    final photoUrl = session?.user.photoUrl;
    final canUploadPhoto = session != null;
    return Scaffold(
      appBar: buildMobileAppBar(context, title: context.l10n.profileTitle),
      bottomNavigationBar: const MobileNavBar(current: MobileNavItem.profile),
      body: RoleGate(
        allowedRoles: const {'User', 'Trainer'},
        allowAnonymous: true,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: canUploadPhoto && !_uploadingPhoto ? _pickAndUploadPhoto : null,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 42,
                              backgroundColor: AppColors.slate,
                              child: _previewBytes != null
                                  ? ClipOval(
                                      child: Image.memory(
                                        _previewBytes!,
                                        width: 84,
                                        height: 84,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : (photoUrl == null || photoUrl.isEmpty)
                                      ? const Icon(Icons.person, size: 36, color: AppColors.muted)
                                      : ClipOval(
                                          child: Image.network(
                                            photoUrl,
                                            width: 84,
                                            height: 84,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(Icons.person, size: 36, color: AppColors.muted),
                                          ),
                                        ),
                            ),
                            if (canUploadPhoto)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: AppColors.accent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt, size: 14, color: AppColors.ink),
                                ),
                              ),
                            if (_uploadingPhoto)
                              Container(
                                width: 84,
                                height: 84,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.35),
                                  shape: BoxShape.circle,
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(20),
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                        Text(session?.user.fullName ?? context.l10n.commonGuest,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(session?.user.email ?? context.l10n.commonNotSignedIn,
                            style: const TextStyle(color: AppColors.muted)),
                      if (_photoError != null) ...[
                        const SizedBox(height: 6),
                        Text(_photoError!, style: const TextStyle(color: AppColors.red)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (session == null)
                    AccentButton(
                      label: context.l10n.commonSignIn,
                      onPressed: () => Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) => const MobileAuthScreen())),
                    ),
                if (session == null) const SizedBox(height: 16),
                  Text(context.l10n.profileCurrentGym, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const CurrentGymIndicator(),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const MobileGymListScreen())),
                    child: Text(context.l10n.profileSwitchGym,
                        style: const TextStyle(color: AppColors.accentDeep)),
                  ),
                const SizedBox(height: 16),
                if (session != null && !isTrainer) ...[
                    Text(context.l10n.profileMemberships, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  if (_statusMessage != null) Text(_statusMessage!, style: const TextStyle(color: AppColors.red)),
                  if (_memberships.isEmpty)
                      Text(context.l10n.profileNoActiveMemberships, style: const TextStyle(color: AppColors.muted))
                  else
                    Column(
                      children: _memberships
                          .map(
                            (membership) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                '${membership.status} until ${AppDateTimeFormat.dateTime(membership.endDateUtc)}',
                                style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w700),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                        TextButton(
                          onPressed: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (_) => const MobileActiveMembershipScreen())),
                          child: Text(context.l10n.profileActivePass,
                              style: const TextStyle(color: AppColors.accentDeep)),
                        ),
                      const SizedBox(width: 8),
                        TextButton(
                          onPressed: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (_) => const MobileMembershipScreen())),
                          child: Text(context.l10n.profileAllMemberships,
                              style: const TextStyle(color: AppColors.accentDeep)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                if (session != null && isTrainer) ...[
                    Text(context.l10n.profileTrainerTools, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                        AccentButton(
                          label: context.l10n.profileSchedule,
                          onPressed: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (_) => const MobileScheduleScreen())),
                          width: 140,
                        ),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: () => Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) => const MobileRequestsScreen())),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accentDeep,
                          side: const BorderSide(color: AppColors.accentDeep),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                          child: Text(context.l10n.profileRequests),
                        ),
                      ],
                    ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => const MobileChatScreen())),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accentDeep,
                      side: const BorderSide(color: AppColors.accentDeep),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(context.l10n.profileTrainerChat),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(context.l10n.profilePreferences, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(context.l10n.profilePreferencesEmpty, style: const TextStyle(color: AppColors.muted)),
                const SizedBox(height: 16),
                  Text(context.l10n.profilePersonalInformation,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    AccentButton(
                      label: context.l10n.profileEdit,
                      onPressed: session == null
                          ? null
                          : () async {
                              final updated = await Navigator.of(context).push<CurrentUser>(
                                MaterialPageRoute(
                                  builder: (_) => MobileProfileEditScreen(user: session.user),
                                ),
                              );
                              if (updated != null) {
                                setState(() {});
                              }
                            },
                      width: 140,
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) => const MobileNotificationsScreen())),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accentDeep,
                        side: const BorderSide(color: AppColors.accentDeep),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    child: Text(context.l10n.profileNotifications),
                  ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const MobileSettingsScreen())),
                  child: Text(context.l10n.commonSettings, style: const TextStyle(color: AppColors.accentDeep)),
                ),
                if (session != null) ...[
                  const SizedBox(height: 20),
                  AccentButton(
                    label: context.l10n.commonSignOut,
                    onPressed: () {
                      _api.session.value = null;
                      GymSelectionStore.instance.clear();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const MobileAuthScreen()),
                        (_) => false,
                      );
                    },
                    width: double.infinity,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PickedImage {
  final String fileName;
  final Uint8List bytes;

  const _PickedImage({required this.fileName, required this.bytes});
}


