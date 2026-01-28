import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../data/fitcity_models.dart';
import '../services/app_config.dart';

class FitCityApiException implements Exception {
  final String message;
  final int? statusCode;

  FitCityApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class FitCityApi {
  FitCityApi._();

  static final FitCityApi instance = FitCityApi._();

  static const String _tokenStorageKey = 'fitcity.accessToken';

  final ValueNotifier<AuthSession?> session = ValueNotifier<AuthSession?>(null);
  final http.Client _client = http.Client();
  String baseUrl = AppConfig.apiBaseUrl;
  bool _listenerAttached = false;

  Future<void> init() async {
    _logAuth('Init start');
    _attachSessionListener();
    await restoreSession();
    _logAuth('Init complete (session=${session.value?.user.role ?? 'none'})');
  }

  Future<void> restoreSession() async {
    _attachSessionListener();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenStorageKey);
    if (token == null || token.isEmpty) {
      _logAuth('No stored token');
      return;
    }
    try {
      final user = await me(token: token);
      session.value = AuthSession(auth: AuthResponse(accessToken: token, expiresAtUtc: DateTime.now().toUtc()), user: user);
      _logAuth('Session restored for ${user.role}');
    } catch (_) {
      _logAuth('Stored token invalid, clearing');
      await prefs.remove(_tokenStorageKey);
      session.value = null;
    }
  }

  Future<AuthSession> login({required String email, required String password}) async {
    return loginMobile(email: email, password: password);
  }

  Future<AuthSession> loginMobile({required String email, required String password}) async {
    _logAuth('Login (mobile) start');
    final auth = await _postObject('/api/auth/login', {
      'email': email,
      'password': password,
    }).then(AuthResponse.fromJson);
    final user = await me(token: auth.accessToken);
    final newSession = AuthSession(auth: auth, user: user);
    session.value = newSession;
    _logAuth('Login (mobile) success for ${user.role}');
    return newSession;
  }

  Future<AuthSession> loginCentralAdmin({required String email, required String password}) async {
    _logAuth('Login (central admin) start');
    final auth = await _postObject('/api/auth/admin/central/login', {
      'email': email,
      'password': password,
    }).then(AuthResponse.fromJson);
    final user = await me(token: auth.accessToken);
    final newSession = AuthSession(auth: auth, user: user);
    session.value = newSession;
    _logAuth('Login (central admin) success for ${user.role}');
    return newSession;
  }

  Future<AuthSession> loginGymAdmin({required String email, required String password}) async {
    _logAuth('Login (gym admin) start');
    final auth = await _postObject('/api/auth/admin/gym/login', {
      'email': email,
      'password': password,
    }).then(AuthResponse.fromJson);
    final user = await me(token: auth.accessToken);
    final newSession = AuthSession(auth: auth, user: user);
    session.value = newSession;
    _logAuth('Login (gym admin) success for ${user.role}');
    return newSession;
  }

  Future<AuthSession> register({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    _logAuth('Register start');
    final auth = await _postObject('/api/auth/register', {
      'email': email,
      'password': password,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
    }).then(AuthResponse.fromJson);
    final user = await me(token: auth.accessToken);
    final newSession = AuthSession(auth: auth, user: user);
    session.value = newSession;
    _logAuth('Register success for ${user.role}');
    return newSession;
  }

  Future<CurrentUser> me({String? token}) async {
    final json = await _getObject('/api/auth/me', auth: true, token: token);
    return CurrentUser.fromJson(json);
  }

  Future<List<Gym>> gyms({String? search}) async {
    final query = search == null || search.isEmpty ? '' : '?search=${Uri.encodeQueryComponent(search)}';
    final list = await _getList('/api/gyms$query');
    return list.map((item) => Gym.fromJson(item)).toList();
  }

  Future<Gym> gymById(String gymId) async {
    final json = await _getObject('/api/gyms/$gymId');
    return Gym.fromJson(json);
  }

  Future<List<Trainer>> trainersByGym(String gymId) async {
    final list = await _getList('/api/trainers/by-gym/$gymId');
    return list.map((item) => Trainer.fromJson(item)).toList();
  }

  Future<Trainer> trainerById(String trainerId) async {
    final json = await _getObject('/api/trainers/$trainerId');
    return Trainer.fromJson(json);
  }

  Future<List<RecommendedTrainer>> recommendedTrainers({int? limit}) async {
    final query = limit == null ? '' : '?limit=$limit';
    final list = await _getList('/api/me/recommendations/trainers$query', auth: true);
    return list.map((item) => RecommendedTrainer.fromJson(item)).toList();
  }

  Future<List<RecommendedGym>> recommendedGyms({int? limit}) async {
    final query = limit == null ? '' : '?limit=$limit';
    final list = await _getList('/api/me/recommendations/gyms$query', auth: true);
    return list.map((item) => RecommendedGym.fromJson(item)).toList();
  }

  Future<TrainerScheduleResponse> trainerSchedule() async {
    final json = await _getObject('/api/trainers/me/schedule', auth: true);
    return TrainerScheduleResponse.fromJson(json);
  }

  Future<TrainerScheduleResponse> trainerAvailability({
    required String trainerId,
    required DateTime fromUtc,
    required DateTime toUtc,
  }) async {
    final from = Uri.encodeQueryComponent(fromUtc.toIso8601String());
    final to = Uri.encodeQueryComponent(toUtc.toIso8601String());
    final json = await _getObject('/api/trainers/$trainerId/availability?fromUtc=$from&toUtc=$to', auth: true);
    return TrainerScheduleResponse.fromJson(json);
  }

  Future<TrainerDetail> trainerPublicDetail(String trainerId) async {
    final json = await _getObject('/api/trainers/$trainerId/detail', auth: true);
    return TrainerDetail.fromJson(json);
  }

  Future<List<Trainer>> trainers({String? search}) async {
    final query = search == null || search.isEmpty ? '' : '?search=${Uri.encodeQueryComponent(search)}';
    final list = await _getList('/api/trainers$query', auth: true);
    return list.map((item) => Trainer.fromJson(item)).toList();
  }

  Future<List<Review>> reviewsForTrainer(String trainerId) async {
    final list = await _getList('/api/reviews/trainer/$trainerId');
    return list.map((item) => Review.fromJson(item)).toList();
  }

  Future<MembershipRequest> requestMembership({required String gymId, String? gymPlanId}) async {
    final json = await _postObject('/api/memberships/requests', {
      'gymId': gymId,
      'gymPlanId': gymPlanId,
    }, auth: true);
    return MembershipRequest.fromJson(json);
  }

  Future<List<MembershipRequest>> membershipRequests({String? gymId, String? userId, String? status}) async {
    final params = <String, String>{};
    if (gymId != null && gymId.isNotEmpty) {
      params['gymId'] = gymId;
    }
    if (userId != null && userId.isNotEmpty) {
      params['userId'] = userId;
    }
    if (status != null && status.isNotEmpty) {
      params['status'] = status;
    }
    final queryString = params.isEmpty ? '' : '?${params.entries.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&')}';
    final list = await _getList('/api/memberships/requests$queryString', auth: true);
    return list.map((item) => MembershipRequest.fromJson(item)).toList();
  }

  Future<MembershipRequest> decideMembershipRequest({required String requestId, required bool approve}) async {
    final json = await _postObject('/api/memberships/requests/$requestId/decision', {
      'approve': approve,
    }, auth: true);
    return MembershipRequest.fromJson(json);
  }

  Future<MembershipPaymentResponse> payMembershipRequest({required String requestId, String? paymentMethod}) async {
    final json = await _postObject('/api/memberships/requests/$requestId/pay', {
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
    }, auth: true);
    return MembershipPaymentResponse.fromJson(json);
  }

  Future<List<Membership>> memberships({String? userId}) async {
    final query = userId == null || userId.isEmpty ? '' : '?userId=$userId';
    final list = await _getList('/api/memberships$query', auth: true);
    return list.map((item) => Membership.fromJson(item)).toList();
  }

  Future<bool> validateMembership(String membershipId) async {
    final json = await _getObject('/api/memberships/$membershipId/validate', auth: true);
    return readJsonValue<bool>(json, 'isValid') ?? false;
  }

  Future<ActiveMembership> activeMembership() async {
    final json = await _getObject('/api/memberships/active', auth: true);
    return ActiveMembership.fromJson(json);
  }

  Future<QrIssue> issueQr(String membershipId) async {
    final json = await _postObject('/api/qr/issue/$membershipId', {}, auth: true);
    return QrIssue.fromJson(json);
  }

  Future<bool> scanQr(String token, {String? gymId}) async {
    final json = await _postObject('/api/qr/scan', {
      'token': token,
      if (gymId != null) 'gymId': gymId,
    }, auth: true);
    return (readJsonValue<bool>(json, 'success') ?? false);
  }

  Future<QrScanResult> validateQr(String token, {String? gymId}) async {
    final json = await _postObject('/api/qr/validate', {
      'token': token,
      if (gymId != null) 'gymId': gymId,
    }, auth: true);
    return QrScanResult.fromJson(json);
  }

  Future<Booking> createBooking({
    required String trainerId,
    String? gymId,
    required DateTime startUtc,
    required DateTime endUtc,
    String? paymentMethod,
  }) async {
    final json = await _postObject('/api/bookings', {
      'trainerId': trainerId,
      'gymId': gymId,
      'startUtc': startUtc.toIso8601String(),
      'endUtc': endUtc.toIso8601String(),
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
    }, auth: true);
    return Booking.fromJson(json);
  }

  Future<Booking> payBooking(String bookingId) async {
    final json = await _postObject('/api/bookings/$bookingId/pay', {}, auth: true);
    return Booking.fromJson(json);
  }

  Future<List<Booking>> bookingHistory() async {
    final list = await _getList('/api/bookings/history', auth: true);
    return list.map((item) => Booking.fromJson(item)).toList();
  }

  Future<List<Booking>> bookings({required String status}) async {
    final list = await _getList('/api/bookings?status=$status', auth: true);
    return list.map((item) => Booking.fromJson(item)).toList();
  }

  Future<Conversation> createConversation({required String otherUserId, String? title}) async {
    final json = await _postObject('/api/chat/conversations', {
      'otherUserId': otherUserId,
      'title': title,
    }, auth: true);
    return Conversation.fromJson(json);
  }

  Future<Message> sendMessage({required String conversationId, required String content}) async {
    final json = await _postObject('/api/chat/conversations/$conversationId/messages', {
      'content': content,
    }, auth: true);
    return Message.fromJson(json);
  }

  Future<List<Message>> messages(String conversationId, {DateTime? beforeUtc, int take = 50}) async {
    final params = <String, String>{};
    if (beforeUtc != null) {
      params['before'] = beforeUtc.toIso8601String();
    }
    if (take > 0) {
      params['take'] = take.toString();
    }
    final queryString = params.isEmpty ? '' : '?${params.entries.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&')}';
    final list = await _getList('/api/chat/conversations/$conversationId/messages$queryString', auth: true);
    return list.map((item) => Message.fromJson(item)).toList();
  }

  Future<List<Conversation>> myConversations() async {
    final list = await _getList('/api/chat/me/conversations', auth: true);
    return list.map((item) => Conversation.fromJson(item)).toList();
  }

  Future<int> markConversationRead(String conversationId) async {
    final response = await _client.patch(
      _buildUri('/api/chat/conversations/$conversationId/read'),
      headers: _headers(auth: true),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw FitCityApiException(_errorMessage(response), statusCode: response.statusCode);
    }
    final data = jsonDecode(response.body);
    if (data is Map<String, dynamic>) {
      return readJsonValue<int>(data, 'updated') ?? 0;
    }
    return 0;
  }

  Future<List<MonthlyCount>> membershipsPerMonth() async {
    final list = await _getList('/api/reports/memberships-per-month', auth: true);
    return list.map((item) => MonthlyCount.fromJson(item)).toList();
  }

  Future<List<TopTrainer>> topTrainers() async {
    final list = await _getList('/api/reports/top-trainers', auth: true);
    return list.map((item) => TopTrainer.fromJson(item)).toList();
  }

  Future<List<MonthlyRevenue>> revenuePerMonth() async {
    final list = await _getList('/api/reports/revenue-per-month', auth: true);
    return list.map((item) => MonthlyRevenue.fromJson(item)).toList();
  }

  Future<List<Member>> members() async {
    final list = await _getList('/api/members', auth: true);
    return list.map((item) => Member.fromJson(item)).toList();
  }

  Future<MemberDetail> memberDetail(String memberId) async {
    final json = await _getObject('/api/admin/members/$memberId', auth: true);
    return MemberDetail.fromJson(json);
  }

  Future<Member> createMember({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    final json = await _postObject('/api/members', {
      'email': email,
      'password': password,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
    }, auth: true);
    return Member.fromJson(json);
  }

  Future<void> deleteMember(String memberId) async {
    final response = await _client.delete(
      _buildUri('/api/members/$memberId'),
      headers: _headers(auth: true),
    );
    if (response.statusCode == 204) {
      return;
    }
    throw FitCityApiException(_errorMessage(response), statusCode: response.statusCode);
  }

  Future<TrainerDetail> trainerDetail(String trainerId) async {
    final json = await _getObject('/api/admin/trainers/$trainerId', auth: true);
    return TrainerDetail.fromJson(json);
  }

  Future<List<AccessLog>> accessLogs({
    String? gymId,
    DateTime? fromUtc,
    DateTime? toUtc,
    String? status,
    String? query,
  }) async {
    final params = <String, String>{};
    if (gymId != null && gymId.isNotEmpty) {
      params['gymId'] = gymId;
    }
    if (fromUtc != null) {
      params['from'] = fromUtc.toIso8601String();
    }
    if (toUtc != null) {
      params['to'] = toUtc.toIso8601String();
    }
    if (status != null && status.isNotEmpty) {
      params['status'] = status;
    }
    if (query != null && query.isNotEmpty) {
      params['q'] = query;
    }
    final queryString = params.isEmpty ? '' : '?${params.entries.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&')}';
    final list = await _getList('/api/admin/access-logs$queryString', auth: true);
    return list.map((item) => AccessLog.fromJson(item)).toList();
  }

  Future<List<AccessLog>> entryHistory({DateTime? fromUtc, DateTime? toUtc}) async {
    final params = <String, String>{};
    if (fromUtc != null) {
      params['from'] = fromUtc.toIso8601String();
    }
    if (toUtc != null) {
      params['to'] = toUtc.toIso8601String();
    }
    final queryString = params.isEmpty ? '' : '?${params.entries.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&')}';
    final list = await _getList('/api/me/entry-history$queryString', auth: true);
    return list.map((item) => AccessLog.fromJson(item)).toList();
  }

  Future<List<AppNotification>> notifications() async {
    final list = await _getList('/api/notifications', auth: true);
    return list.map((item) => AppNotification.fromJson(item)).toList();
  }

  Future<AdminSearchResponse> adminSearch({
    String? query,
    String? type,
    String? gymId,
    String? city,
    String? status,
  }) async {
    final params = <String, String>{};
    if (query != null && query.isNotEmpty) {
      params['query'] = query;
    }
    if (type != null && type.isNotEmpty) {
      params['type'] = type;
    }
    if (gymId != null && gymId.isNotEmpty) {
      params['gymId'] = gymId;
    }
    if (city != null && city.isNotEmpty) {
      params['city'] = city;
    }
    if (status != null && status.isNotEmpty) {
      params['status'] = status;
    }
    final queryString = params.isEmpty ? '' : '?${params.entries.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&')}';
    final json = await _getObject('/api/admin/search$queryString', auth: true);
    return AdminSearchResponse.fromJson(json);
  }

  Future<List<GymPlan>> gymPlans({String? gymId, String? query}) async {
    final params = <String, String>{};
    if (gymId != null && gymId.isNotEmpty) {
      params['gymId'] = gymId;
    }
    if (query != null && query.isNotEmpty) {
      params['query'] = query;
    }
    final queryString = params.isEmpty ? '' : '?${params.entries.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&')}';
    final list = await _getList('/api/admin/gym-plans$queryString', auth: true);
    return list.map((item) => GymPlan.fromJson(item)).toList();
  }

  Future<GymPlan> createGymPlan({
    required String gymId,
    required String name,
    required double price,
    required int durationMonths,
    String? description,
    bool isActive = true,
  }) async {
    final json = await _postObject('/api/admin/gym-plans', {
      'gymId': gymId,
      'name': name,
      'price': price,
      'durationMonths': durationMonths,
      'description': description,
      'isActive': isActive,
    }, auth: true);
    return GymPlan.fromJson(json);
  }

  Future<GymPlan> updateGymPlan({
    required String id,
    required String gymId,
    required String name,
    required double price,
    required int durationMonths,
    String? description,
    bool isActive = true,
  }) async {
    final json = await _client.put(
      _buildUri('/api/admin/gym-plans/$id'),
      headers: _headers(auth: true),
      body: jsonEncode({
        'gymId': gymId,
        'name': name,
        'price': price,
        'durationMonths': durationMonths,
        'description': description,
        'isActive': isActive,
      }),
    );
    final data = _decodeObject(json);
    return GymPlan.fromJson(data);
  }

  Future<void> deleteGymPlan(String id) async {
    final response = await _client.delete(
      _buildUri('/api/admin/gym-plans/$id'),
      headers: _headers(auth: true),
    );
    if (response.statusCode == 204) {
      return;
    }
    throw FitCityApiException(_errorMessage(response), statusCode: response.statusCode);
  }

  Future<CurrentUser> updateProfile({
    required String fullName,
    String? phoneNumber,
    String? email,
  }) async {
    final json = await _client.put(
      _buildUri('/api/me/profile'),
      headers: _headers(auth: true),
      body: jsonEncode({
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        if (email != null) 'email': email,
      }),
    );
    final data = _decodeObject(json);
    return CurrentUser.fromJson(data);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _client.put(
      _buildUri('/api/auth/change-password'),
      headers: _headers(auth: true),
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    throw FitCityApiException(_errorMessage(response), statusCode: response.statusCode);
  }

  Future<void> markNotificationRead(String notificationId) async {
    final response = await _client.patch(
      _buildUri('/api/notifications/$notificationId/read'),
      headers: _headers(auth: true),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    throw FitCityApiException(_errorMessage(response), statusCode: response.statusCode);
  }

  Future<int> markAllNotificationsRead() async {
    final response = await _client.patch(
      _buildUri('/api/notifications/read-all'),
      headers: _headers(auth: true),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw FitCityApiException(_errorMessage(response), statusCode: response.statusCode);
    }
    final data = jsonDecode(response.body);
    if (data is Map<String, dynamic>) {
      return readJsonValue<int>(data, 'updated') ?? 0;
    }
    throw FitCityApiException('Unexpected response shape.', statusCode: response.statusCode);
  }

  Future<Map<String, dynamic>> _getObject(String path, {bool auth = false, String? token}) async {
    final response = await _client.get(_buildUri(path), headers: _headers(auth: auth, token: token));
    return _decodeObject(response);
  }

  Future<List<Map<String, dynamic>>> _getList(String path, {bool auth = false}) async {
    final response = await _client.get(_buildUri(path), headers: _headers(auth: auth));
    return _decodeList(response);
  }

  Future<Map<String, dynamic>> _postObject(String path, Map<String, dynamic> body, {bool auth = false}) async {
    final response = await _client.post(
      _buildUri(path),
      headers: _headers(auth: auth),
      body: jsonEncode(body),
    );
    return _decodeObject(response);
  }

  Uri _buildUri(String path) {
    final sanitized = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    return Uri.parse('$sanitized$path');
  }

  Map<String, String> _headers({bool auth = false, String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final accessToken = token ?? session.value?.auth.accessToken;
    if (auth && accessToken != null && accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    return headers;
  }

  Map<String, dynamic> _decodeObject(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw FitCityApiException(_errorMessage(response), statusCode: response.statusCode);
    }
    final data = jsonDecode(response.body);
    if (data is Map<String, dynamic>) {
      return data;
    }
    throw FitCityApiException('Unexpected response shape.', statusCode: response.statusCode);
  }

  List<Map<String, dynamic>> _decodeList(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw FitCityApiException(_errorMessage(response), statusCode: response.statusCode);
    }
    final data = jsonDecode(response.body);
    if (data is List) {
      return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
    }
    throw FitCityApiException('Unexpected response shape.', statusCode: response.statusCode);
  }

  String _errorMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        final errors = readJsonValue<Map<String, dynamic>>(data, 'errors');
        if (errors != null && errors.isNotEmpty) {
          final firstKey = errors.keys.first;
          final messages = errors[firstKey];
          if (messages is List && messages.isNotEmpty) {
            return messages.first.toString();
          }
        }
        return readJsonValue<String>(data, 'error') ??
            readJsonValue<String>(data, 'title') ??
            readJsonValue<String>(data, 'message') ??
            'Request failed (${response.statusCode}).';
      }
    } catch (_) {}
    return 'Request failed (${response.statusCode}).';
  }

  void _attachSessionListener() {
    if (_listenerAttached) {
      return;
    }
    _listenerAttached = true;
    session.addListener(() {
      final current = session.value;
      _logAuth('Session changed: ${current?.user.role ?? 'none'}');
      SharedPreferences.getInstance().then((prefs) {
        if (current == null) {
          prefs.remove(_tokenStorageKey);
          return;
        }
        prefs.setString(_tokenStorageKey, current.auth.accessToken);
      });
    });
  }

  void _logAuth(String message) {
    if (kDebugMode) {
      debugPrint('[FitCityApi] $message');
    }
  }
}
