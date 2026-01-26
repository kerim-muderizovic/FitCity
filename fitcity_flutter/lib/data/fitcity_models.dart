import 'dart:convert';

T? readJsonValue<T>(Map<String, dynamic> json, String key) {
  if (json.containsKey(key)) {
    return json[key] as T?;
  }
  final pascal = key.isEmpty ? key : '${key[0].toUpperCase()}${key.substring(1)}';
  return json[pascal] as T?;
}

DateTime? readJsonDate(Map<String, dynamic> json, String key) {
  final raw = readJsonValue<String>(json, key);
  if (raw == null || raw.isEmpty) {
    return null;
  }
  return DateTime.tryParse(raw);
}

class AuthResponse {
  final String accessToken;
  final DateTime expiresAtUtc;

  AuthResponse({required this.accessToken, required this.expiresAtUtc});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: readJsonValue<String>(json, 'accessToken') ?? '',
      expiresAtUtc: readJsonDate(json, 'expiresAtUtc') ?? DateTime.now().toUtc(),
    );
  }
}

class CurrentUser {
  final String id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String role;

  CurrentUser({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    required this.role,
  });

  factory CurrentUser.fromJson(Map<String, dynamic> json) {
    return CurrentUser(
      id: readJsonValue<String>(json, 'id') ?? '',
      email: readJsonValue<String>(json, 'email') ?? '',
      fullName: readJsonValue<String>(json, 'fullName') ?? '',
      phoneNumber: readJsonValue<String>(json, 'phoneNumber'),
      role: readJsonValue<String>(json, 'role') ?? '',
    );
  }
}

class AuthSession {
  final AuthResponse auth;
  final CurrentUser user;

  AuthSession({required this.auth, required this.user});
}

class Gym {
  final String id;
  final String name;
  final String address;
  final String city;
  final double? latitude;
  final double? longitude;
  final String? phoneNumber;
  final String? description;
  final String? photoUrl;
  final String? workHours;
  final List<String> photoUrls;
  final bool isActive;

  Gym({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    this.latitude,
    this.longitude,
    this.phoneNumber,
    this.description,
    this.photoUrl,
    this.workHours,
    this.photoUrls = const [],
    required this.isActive,
  });

  factory Gym.fromJson(Map<String, dynamic> json) {
    return Gym(
      id: readJsonValue<String>(json, 'id') ?? '',
      name: readJsonValue<String>(json, 'name') ?? '',
      address: readJsonValue<String>(json, 'address') ?? '',
      city: readJsonValue<String>(json, 'city') ?? '',
      latitude: readJsonValue<num>(json, 'latitude')?.toDouble(),
      longitude: readJsonValue<num>(json, 'longitude')?.toDouble(),
      phoneNumber: readJsonValue<String>(json, 'phoneNumber'),
      description: readJsonValue<String>(json, 'description'),
      photoUrl: readJsonValue<String>(json, 'photoUrl'),
      workHours: readJsonValue<String>(json, 'workHours'),
      photoUrls: (readJsonValue<List<dynamic>>(json, 'photoUrls') ?? [])
          .map((item) => item.toString())
          .toList(),
      isActive: readJsonValue<bool>(json, 'isActive') ?? true,
    );
  }
}

class Trainer {
  final String id;
  final String userId;
  final String userName;
  final String? bio;
  final String? certifications;
  final String? photoUrl;
  final double? hourlyRate;
  final bool isActive;

  Trainer({
    required this.id,
    required this.userId,
    required this.userName,
    this.bio,
    this.certifications,
    this.photoUrl,
    this.hourlyRate,
    required this.isActive,
  });

  factory Trainer.fromJson(Map<String, dynamic> json) {
    return Trainer(
      id: readJsonValue<String>(json, 'id') ?? '',
      userId: readJsonValue<String>(json, 'userId') ?? '',
      userName: readJsonValue<String>(json, 'userName') ?? '',
      bio: readJsonValue<String>(json, 'bio'),
      certifications: readJsonValue<String>(json, 'certifications'),
      photoUrl: readJsonValue<String>(json, 'photoUrl'),
      hourlyRate: readJsonValue<num>(json, 'hourlyRate')?.toDouble(),
      isActive: readJsonValue<bool>(json, 'isActive') ?? true,
    );
  }
}

class TrainerScheduleResponse {
  final List<TrainerSchedule> schedules;
  final List<Booking> sessions;
  final String? reason;
  final String? scheduleUsed;

  TrainerScheduleResponse({required this.schedules, required this.sessions, this.reason, this.scheduleUsed});

  factory TrainerScheduleResponse.fromJson(Map<String, dynamic> json) {
    final schedulesJson = readJsonValue<List<dynamic>>(json, 'schedules') ?? [];
    final sessionsJson = readJsonValue<List<dynamic>>(json, 'sessions') ?? [];
    return TrainerScheduleResponse(
      schedules: schedulesJson.map((item) => TrainerSchedule.fromJson(Map<String, dynamic>.from(item))).toList(),
      sessions: sessionsJson.map((item) => Booking.fromJson(Map<String, dynamic>.from(item))).toList(),
      reason: readJsonValue<String>(json, 'reason'),
      scheduleUsed: readJsonValue<String>(json, 'scheduleUsed'),
    );
  }
}

class Review {
  final String id;
  final String userId;
  final String trainerId;
  final String? gymId;
  final int rating;
  final String? comment;
  final DateTime? createdAtUtc;

  Review({
    required this.id,
    required this.userId,
    required this.trainerId,
    this.gymId,
    required this.rating,
    this.comment,
    this.createdAtUtc,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: readJsonValue<String>(json, 'id') ?? '',
      userId: readJsonValue<String>(json, 'userId') ?? '',
      trainerId: readJsonValue<String>(json, 'trainerId') ?? '',
      gymId: readJsonValue<String>(json, 'gymId'),
      rating: readJsonValue<int>(json, 'rating') ?? 0,
      comment: readJsonValue<String>(json, 'comment'),
      createdAtUtc: readJsonDate(json, 'createdAtUtc'),
    );
  }
}

class Membership {
  final String id;
  final String userId;
  final String gymId;
  final String? gymPlanId;
  final DateTime startDateUtc;
  final DateTime endDateUtc;
  final String status;

  Membership({
    required this.id,
    required this.userId,
    required this.gymId,
    this.gymPlanId,
    required this.startDateUtc,
    required this.endDateUtc,
    required this.status,
  });

  factory Membership.fromJson(Map<String, dynamic> json) {
    return Membership(
      id: readJsonValue<String>(json, 'id') ?? '',
      userId: readJsonValue<String>(json, 'userId') ?? '',
      gymId: readJsonValue<String>(json, 'gymId') ?? '',
      gymPlanId: readJsonValue<String>(json, 'gymPlanId'),
      startDateUtc: readJsonDate(json, 'startDateUtc') ?? DateTime.now().toUtc(),
      endDateUtc: readJsonDate(json, 'endDateUtc') ?? DateTime.now().toUtc(),
      status: readJsonValue<String>(json, 'status') ?? '',
    );
  }
}

class MembershipRequest {
  final String id;
  final String userId;
  final String gymId;
  final String? gymPlanId;
  final String status;
  final String paymentStatus;
  final DateTime? approvedAtUtc;
  final String? approvedByUserId;
  final DateTime? paidAtUtc;
  final String? paymentId;
  final DateTime? requestedAtUtc;

  MembershipRequest({
    required this.id,
    required this.userId,
    required this.gymId,
    this.gymPlanId,
    required this.status,
    required this.paymentStatus,
    this.approvedAtUtc,
    this.approvedByUserId,
    this.paidAtUtc,
    this.paymentId,
    this.requestedAtUtc,
  });

  factory MembershipRequest.fromJson(Map<String, dynamic> json) {
    return MembershipRequest(
      id: readJsonValue<String>(json, 'id') ?? '',
      userId: readJsonValue<String>(json, 'userId') ?? '',
      gymId: readJsonValue<String>(json, 'gymId') ?? '',
      gymPlanId: readJsonValue<String>(json, 'gymPlanId'),
      status: readJsonValue<String>(json, 'status') ?? '',
      paymentStatus: readJsonValue<String>(json, 'paymentStatus') ?? '',
      approvedAtUtc: readJsonDate(json, 'approvedAtUtc'),
      approvedByUserId: readJsonValue<String>(json, 'approvedByUserId'),
      paidAtUtc: readJsonDate(json, 'paidAtUtc'),
      paymentId: readJsonValue<String>(json, 'paymentId'),
      requestedAtUtc: readJsonDate(json, 'requestedAtUtc'),
    );
  }
}

class Booking {
  final String id;
  final String userId;
  final String trainerId;
  final String trainerUserId;
  final String trainerName;
  final String? gymId;
  final String? gymName;
  final DateTime startUtc;
  final DateTime endUtc;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final double price;
  final DateTime? paidAtUtc;

  Booking({
    required this.id,
    required this.userId,
    required this.trainerId,
    required this.trainerUserId,
    required this.trainerName,
    this.gymId,
    this.gymName,
    required this.startUtc,
    required this.endUtc,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.price,
    this.paidAtUtc,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: readJsonValue<String>(json, 'id') ?? '',
      userId: readJsonValue<String>(json, 'userId') ?? '',
      trainerId: readJsonValue<String>(json, 'trainerId') ?? '',
      trainerUserId: readJsonValue<String>(json, 'trainerUserId') ?? '',
      trainerName: readJsonValue<String>(json, 'trainerName') ?? '',
      gymId: readJsonValue<String>(json, 'gymId'),
      gymName: readJsonValue<String>(json, 'gymName'),
      startUtc: readJsonDate(json, 'startUtc') ?? DateTime.now().toUtc(),
      endUtc: readJsonDate(json, 'endUtc') ?? DateTime.now().toUtc(),
      status: readJsonValue<String>(json, 'status') ?? '',
      paymentMethod: readJsonValue<String>(json, 'paymentMethod') ?? '',
      paymentStatus: readJsonValue<String>(json, 'paymentStatus') ?? '',
      price: (readJsonValue<num>(json, 'price') ?? 0).toDouble(),
      paidAtUtc: readJsonDate(json, 'paidAtUtc'),
    );
  }
}

class Conversation {
  final String id;
  final String? title;
  final DateTime? createdAtUtc;
  final DateTime? updatedAtUtc;
  final DateTime? lastMessageAtUtc;
  final String? memberId;
  final String? trainerId;
  final String? otherUserId;
  final String? otherUserName;
  final String? otherUserRole;
  final String? lastMessage;
  final int unreadCount;

  Conversation({
    required this.id,
    this.title,
    this.createdAtUtc,
    this.updatedAtUtc,
    this.lastMessageAtUtc,
    this.memberId,
    this.trainerId,
    this.otherUserId,
    this.otherUserName,
    this.otherUserRole,
    this.lastMessage,
    this.unreadCount = 0,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: readJsonValue<String>(json, 'id') ?? '',
      title: readJsonValue<String>(json, 'title'),
      createdAtUtc: readJsonDate(json, 'createdAtUtc'),
      updatedAtUtc: readJsonDate(json, 'updatedAtUtc'),
      lastMessageAtUtc: readJsonDate(json, 'lastMessageAtUtc'),
      memberId: readJsonValue<String>(json, 'memberId'),
      trainerId: readJsonValue<String>(json, 'trainerId'),
      otherUserId: readJsonValue<String>(json, 'otherUserId'),
      otherUserName: readJsonValue<String>(json, 'otherUserName'),
      otherUserRole: readJsonValue<String>(json, 'otherUserRole'),
      lastMessage: readJsonValue<String>(json, 'lastMessage'),
      unreadCount: readJsonValue<int>(json, 'unreadCount') ?? 0,
    );
  }
}

class Message {
  final String id;
  final String conversationId;
  final String senderUserId;
  final String? senderRole;
  final String content;
  final DateTime? sentAtUtc;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderUserId,
    this.senderRole,
    required this.content,
    this.sentAtUtc,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: readJsonValue<String>(json, 'id') ?? '',
      conversationId: readJsonValue<String>(json, 'conversationId') ?? '',
      senderUserId: readJsonValue<String>(json, 'senderUserId') ?? '',
      senderRole: readJsonValue<String>(json, 'senderRole'),
      content: readJsonValue<String>(json, 'content') ?? '',
      sentAtUtc: readJsonDate(json, 'sentAtUtc'),
    );
  }
}

class QrIssue {
  final String token;
  final DateTime? expiresAtUtc;

  QrIssue({required this.token, this.expiresAtUtc});

  factory QrIssue.fromJson(Map<String, dynamic> json) {
    return QrIssue(
      token: readJsonValue<String>(json, 'token') ?? '',
      expiresAtUtc: readJsonDate(json, 'expiresAtUtc'),
    );
  }
}

class QrScanResult {
  final String status;
  final String reason;
  final String? membershipId;
  final String? memberId;
  final String? memberName;
  final String? gymId;
  final String? gymName;
  final DateTime? scannedAtUtc;

  QrScanResult({
    required this.status,
    required this.reason,
    this.membershipId,
    this.memberId,
    this.memberName,
    this.gymId,
    this.gymName,
    this.scannedAtUtc,
  });

  factory QrScanResult.fromJson(Map<String, dynamic> json) {
    return QrScanResult(
      status: readJsonValue<String>(json, 'status') ?? 'Denied',
      reason: readJsonValue<String>(json, 'reason') ?? '',
      membershipId: readJsonValue<String>(json, 'membershipId'),
      memberId: readJsonValue<String>(json, 'memberId'),
      memberName: readJsonValue<String>(json, 'memberName'),
      gymId: readJsonValue<String>(json, 'gymId'),
      gymName: readJsonValue<String>(json, 'gymName'),
      scannedAtUtc: readJsonDate(json, 'scannedAtUtc'),
    );
  }
}

class ActiveMembership {
  final String state;
  final String? membershipStatus;
  final String? membershipId;
  final String? gymId;
  final String? gymName;
  final String? gymPlanId;
  final String? planName;
  final DateTime? startDateUtc;
  final DateTime? endDateUtc;
  final int? remainingDays;
  final String? requestId;
  final String? requestStatus;
  final String? paymentStatus;
  final bool canPay;
  final DateTime? requestedAtUtc;

  ActiveMembership({
    required this.state,
    this.membershipStatus,
    this.membershipId,
    this.gymId,
    this.gymName,
    this.gymPlanId,
    this.planName,
    this.startDateUtc,
    this.endDateUtc,
    this.remainingDays,
    this.requestId,
    this.requestStatus,
    this.paymentStatus,
    this.canPay = false,
    this.requestedAtUtc,
  });

  factory ActiveMembership.fromJson(Map<String, dynamic> json) {
    return ActiveMembership(
      state: readJsonValue<String>(json, 'state') ?? 'None',
      membershipStatus: readJsonValue<String>(json, 'membershipStatus'),
      membershipId: readJsonValue<String>(json, 'membershipId'),
      gymId: readJsonValue<String>(json, 'gymId'),
      gymName: readJsonValue<String>(json, 'gymName'),
      gymPlanId: readJsonValue<String>(json, 'gymPlanId'),
      planName: readJsonValue<String>(json, 'planName'),
      startDateUtc: readJsonDate(json, 'startDateUtc'),
      endDateUtc: readJsonDate(json, 'endDateUtc'),
      remainingDays: readJsonValue<int>(json, 'remainingDays'),
      requestId: readJsonValue<String>(json, 'requestId'),
      requestStatus: readJsonValue<String>(json, 'requestStatus'),
      paymentStatus: readJsonValue<String>(json, 'paymentStatus'),
      canPay: readJsonValue<bool>(json, 'canPay') ?? false,
      requestedAtUtc: readJsonDate(json, 'requestedAtUtc'),
    );
  }
}

class MembershipPaymentResponse {
  final Membership membership;
  final QrIssue? qr;

  MembershipPaymentResponse({required this.membership, this.qr});

  factory MembershipPaymentResponse.fromJson(Map<String, dynamic> json) {
    final membershipJson = readJsonValue<Map<String, dynamic>>(json, 'membership') ?? {};
    final qrJson = readJsonValue<Map<String, dynamic>>(json, 'qr');
    return MembershipPaymentResponse(
      membership: Membership.fromJson(membershipJson),
      qr: qrJson == null ? null : QrIssue.fromJson(qrJson),
    );
  }
}

class MonthlyCount {
  final int year;
  final int month;
  final int count;

  MonthlyCount({required this.year, required this.month, required this.count});

  factory MonthlyCount.fromJson(Map<String, dynamic> json) {
    return MonthlyCount(
      year: readJsonValue<int>(json, 'year') ?? 0,
      month: readJsonValue<int>(json, 'month') ?? 0,
      count: readJsonValue<int>(json, 'count') ?? 0,
    );
  }
}

class MonthlyRevenue {
  final int year;
  final int month;
  final double revenue;

  MonthlyRevenue({required this.year, required this.month, required this.revenue});

  factory MonthlyRevenue.fromJson(Map<String, dynamic> json) {
    final raw = readJsonValue<num>(json, 'revenue') ?? 0;
    return MonthlyRevenue(
      year: readJsonValue<int>(json, 'year') ?? 0,
      month: readJsonValue<int>(json, 'month') ?? 0,
      revenue: raw.toDouble(),
    );
  }
}

class TopTrainer {
  final String trainerId;
  final String trainerName;
  final int bookingCount;

  TopTrainer({required this.trainerId, required this.trainerName, required this.bookingCount});

  factory TopTrainer.fromJson(Map<String, dynamic> json) {
    return TopTrainer(
      trainerId: readJsonValue<String>(json, 'trainerId') ?? '',
      trainerName: readJsonValue<String>(json, 'trainerName') ?? '',
      bookingCount: readJsonValue<int>(json, 'bookingCount') ?? 0,
    );
  }
}

class Member {
  final String id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final DateTime? createdAtUtc;

  Member({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.createdAtUtc,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: readJsonValue<String>(json, 'id') ?? '',
      email: readJsonValue<String>(json, 'email') ?? '',
      fullName: readJsonValue<String>(json, 'fullName') ?? '',
      phoneNumber: readJsonValue<String>(json, 'phoneNumber'),
      createdAtUtc: readJsonDate(json, 'createdAtUtc'),
    );
  }
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String? category;
  final bool isRead;
  final DateTime? createdAtUtc;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    this.category,
    required this.isRead,
    this.createdAtUtc,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: readJsonValue<String>(json, 'id') ?? '',
      title: readJsonValue<String>(json, 'title') ?? '',
      message: readJsonValue<String>(json, 'message') ?? '',
      category: readJsonValue<String>(json, 'category'),
      isRead: readJsonValue<bool>(json, 'isRead') ?? false,
      createdAtUtc: readJsonDate(json, 'createdAtUtc'),
    );
  }
}

class AccessLog {
  final String id;
  final String gymId;
  final String gymName;
  final String memberId;
  final String memberName;
  final String status;
  final String reason;
  final DateTime? checkedAtUtc;

  AccessLog({
    required this.id,
    required this.gymId,
    required this.gymName,
    required this.memberId,
    required this.memberName,
    required this.status,
    required this.reason,
    this.checkedAtUtc,
  });

  factory AccessLog.fromJson(Map<String, dynamic> json) {
    return AccessLog(
      id: readJsonValue<String>(json, 'id') ?? '',
      gymId: readJsonValue<String>(json, 'gymId') ?? '',
      gymName: readJsonValue<String>(json, 'gymName') ?? '',
      memberId: readJsonValue<String>(json, 'memberId') ?? '',
      memberName: readJsonValue<String>(json, 'memberName') ?? '',
      status: readJsonValue<String>(json, 'status') ?? '',
      reason: readJsonValue<String>(json, 'reason') ?? '',
      checkedAtUtc: readJsonDate(json, 'checkedAtUtc'),
    );
  }
}

class AdminGymSearch {
  final String id;
  final String name;
  final String city;
  final String address;
  final String? workHours;
  final bool isActive;
  final int memberCount;
  final int trainerCount;

  AdminGymSearch({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    this.workHours,
    required this.isActive,
    required this.memberCount,
    required this.trainerCount,
  });

  factory AdminGymSearch.fromJson(Map<String, dynamic> json) {
    return AdminGymSearch(
      id: readJsonValue<String>(json, 'id') ?? '',
      name: readJsonValue<String>(json, 'name') ?? '',
      city: readJsonValue<String>(json, 'city') ?? '',
      address: readJsonValue<String>(json, 'address') ?? '',
      workHours: readJsonValue<String>(json, 'workHours'),
      isActive: readJsonValue<bool>(json, 'isActive') ?? true,
      memberCount: readJsonValue<int>(json, 'memberCount') ?? 0,
      trainerCount: readJsonValue<int>(json, 'trainerCount') ?? 0,
    );
  }
}

class AdminMemberGym {
  final String gymId;
  final String gymName;
  final String status;
  final DateTime? endDateUtc;

  AdminMemberGym({
    required this.gymId,
    required this.gymName,
    required this.status,
    this.endDateUtc,
  });

  factory AdminMemberGym.fromJson(Map<String, dynamic> json) {
    return AdminMemberGym(
      gymId: readJsonValue<String>(json, 'gymId') ?? '',
      gymName: readJsonValue<String>(json, 'gymName') ?? '',
      status: readJsonValue<String>(json, 'status') ?? '',
      endDateUtc: readJsonDate(json, 'endDateUtc'),
    );
  }
}

class AdminMemberSearch {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final DateTime? createdAtUtc;
  final List<AdminMemberGym> memberships;

  AdminMemberSearch({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.createdAtUtc,
    required this.memberships,
  });

  factory AdminMemberSearch.fromJson(Map<String, dynamic> json) {
    final membershipsJson = readJsonValue<List<dynamic>>(json, 'memberships') ?? [];
    return AdminMemberSearch(
      id: readJsonValue<String>(json, 'id') ?? '',
      fullName: readJsonValue<String>(json, 'fullName') ?? '',
      email: readJsonValue<String>(json, 'email') ?? '',
      phoneNumber: readJsonValue<String>(json, 'phoneNumber'),
      createdAtUtc: readJsonDate(json, 'createdAtUtc'),
      memberships: membershipsJson.map((item) => AdminMemberGym.fromJson(Map<String, dynamic>.from(item))).toList(),
    );
  }
}

class AdminTrainerSearch {
  final String id;
  final String name;
  final double? hourlyRate;
  final bool isActive;
  final int upcomingSessions;
  final List<String> gyms;

  AdminTrainerSearch({
    required this.id,
    required this.name,
    this.hourlyRate,
    required this.isActive,
    required this.upcomingSessions,
    required this.gyms,
  });

  factory AdminTrainerSearch.fromJson(Map<String, dynamic> json) {
    final gymsJson = readJsonValue<List<dynamic>>(json, 'gyms') ?? [];
    return AdminTrainerSearch(
      id: readJsonValue<String>(json, 'id') ?? '',
      name: readJsonValue<String>(json, 'name') ?? '',
      hourlyRate: readJsonValue<num>(json, 'hourlyRate')?.toDouble(),
      isActive: readJsonValue<bool>(json, 'isActive') ?? true,
      upcomingSessions: readJsonValue<int>(json, 'upcomingSessions') ?? 0,
      gyms: gymsJson.map((item) => item.toString()).toList(),
    );
  }
}

class AdminSearchResponse {
  final List<AdminGymSearch> gyms;
  final List<AdminMemberSearch> members;
  final List<AdminTrainerSearch> trainers;

  AdminSearchResponse({
    required this.gyms,
    required this.members,
    required this.trainers,
  });

  factory AdminSearchResponse.fromJson(Map<String, dynamic> json) {
    final gymsJson = readJsonValue<List<dynamic>>(json, 'gyms') ?? [];
    final membersJson = readJsonValue<List<dynamic>>(json, 'members') ?? [];
    final trainersJson = readJsonValue<List<dynamic>>(json, 'trainers') ?? [];
    return AdminSearchResponse(
      gyms: gymsJson.map((item) => AdminGymSearch.fromJson(Map<String, dynamic>.from(item))).toList(),
      members: membersJson.map((item) => AdminMemberSearch.fromJson(Map<String, dynamic>.from(item))).toList(),
      trainers: trainersJson.map((item) => AdminTrainerSearch.fromJson(Map<String, dynamic>.from(item))).toList(),
    );
  }
}

class GymPlan {
  final String id;
  final String gymId;
  final String gymName;
  final String name;
  final double price;
  final int durationMonths;
  final String? description;
  final bool isActive;

  GymPlan({
    required this.id,
    required this.gymId,
    required this.gymName,
    required this.name,
    required this.price,
    required this.durationMonths,
    this.description,
    required this.isActive,
  });

  factory GymPlan.fromJson(Map<String, dynamic> json) {
    return GymPlan(
      id: readJsonValue<String>(json, 'id') ?? '',
      gymId: readJsonValue<String>(json, 'gymId') ?? '',
      gymName: readJsonValue<String>(json, 'gymName') ?? '',
      name: readJsonValue<String>(json, 'name') ?? '',
      price: (readJsonValue<num>(json, 'price') ?? 0).toDouble(),
      durationMonths: readJsonValue<int>(json, 'durationMonths') ?? 0,
      description: readJsonValue<String>(json, 'description'),
      isActive: readJsonValue<bool>(json, 'isActive') ?? true,
    );
  }
}

class MemberDetail {
  final Member member;
  final List<Membership> memberships;
  final List<Booking> bookings;
  final String qrStatus;
  final DateTime? qrExpiresAtUtc;
  final DateTime? lastAccessAtUtc;
  final String? lastAccessGymName;

  MemberDetail({
    required this.member,
    required this.memberships,
    required this.bookings,
    required this.qrStatus,
    this.qrExpiresAtUtc,
    this.lastAccessAtUtc,
    this.lastAccessGymName,
  });

  factory MemberDetail.fromJson(Map<String, dynamic> json) {
    final memberJson = readJsonValue<Map<String, dynamic>>(json, 'member') ?? {};
    final membershipsJson = readJsonValue<List<dynamic>>(json, 'memberships') ?? [];
    final bookingsJson = readJsonValue<List<dynamic>>(json, 'bookings') ?? [];
    return MemberDetail(
      member: Member.fromJson(memberJson),
      memberships: membershipsJson.map((item) => Membership.fromJson(Map<String, dynamic>.from(item))).toList(),
      bookings: bookingsJson.map((item) => Booking.fromJson(Map<String, dynamic>.from(item))).toList(),
      qrStatus: readJsonValue<String>(json, 'qrStatus') ?? 'None',
      qrExpiresAtUtc: readJsonDate(json, 'qrExpiresAtUtc'),
      lastAccessAtUtc: readJsonDate(json, 'lastAccessAtUtc'),
      lastAccessGymName: readJsonValue<String>(json, 'lastAccessGymName'),
    );
  }
}

class TrainerSchedule {
  final String id;
  final String trainerId;
  final String? gymId;
  final DateTime startUtc;
  final DateTime endUtc;
  final bool isAvailable;

  TrainerSchedule({
    required this.id,
    required this.trainerId,
    this.gymId,
    required this.startUtc,
    required this.endUtc,
    required this.isAvailable,
  });

  factory TrainerSchedule.fromJson(Map<String, dynamic> json) {
    return TrainerSchedule(
      id: readJsonValue<String>(json, 'id') ?? '',
      trainerId: readJsonValue<String>(json, 'trainerId') ?? '',
      gymId: readJsonValue<String>(json, 'gymId'),
      startUtc: readJsonDate(json, 'startUtc') ?? DateTime.now().toUtc(),
      endUtc: readJsonDate(json, 'endUtc') ?? DateTime.now().toUtc(),
      isAvailable: readJsonValue<bool>(json, 'isAvailable') ?? false,
    );
  }
}

class TrainerDetail {
  final Trainer trainer;
  final List<Gym> gyms;
  final List<TrainerSchedule> schedules;
  final List<Booking> sessions;

  TrainerDetail({
    required this.trainer,
    required this.gyms,
    required this.schedules,
    required this.sessions,
  });

  factory TrainerDetail.fromJson(Map<String, dynamic> json) {
    final trainerJson = readJsonValue<Map<String, dynamic>>(json, 'trainer') ?? {};
    final gymsJson = readJsonValue<List<dynamic>>(json, 'gyms') ?? [];
    final schedulesJson = readJsonValue<List<dynamic>>(json, 'schedules') ?? [];
    final sessionsJson = readJsonValue<List<dynamic>>(json, 'sessions') ?? [];
    return TrainerDetail(
      trainer: Trainer.fromJson(trainerJson),
      gyms: gymsJson.map((item) => Gym.fromJson(Map<String, dynamic>.from(item))).toList(),
      schedules: schedulesJson.map((item) => TrainerSchedule.fromJson(Map<String, dynamic>.from(item))).toList(),
      sessions: sessionsJson.map((item) => Booking.fromJson(Map<String, dynamic>.from(item))).toList(),
    );
  }
}

class RecommendedTrainer {
  final String trainerId;
  final String trainerName;
  final String? photoUrl;
  final double? hourlyRate;
  final double? ratingAverage;
  final int ratingCount;
  final List<String> reasons;

  RecommendedTrainer({
    required this.trainerId,
    required this.trainerName,
    this.photoUrl,
    this.hourlyRate,
    this.ratingAverage,
    required this.ratingCount,
    required this.reasons,
  });

  factory RecommendedTrainer.fromJson(Map<String, dynamic> json) {
    return RecommendedTrainer(
      trainerId: readJsonValue<String>(json, 'trainerId') ?? '',
      trainerName: readJsonValue<String>(json, 'trainerName') ?? '',
      photoUrl: readJsonValue<String>(json, 'photoUrl'),
      hourlyRate: readJsonValue<num>(json, 'hourlyRate')?.toDouble(),
      ratingAverage: readJsonValue<num>(json, 'ratingAverage')?.toDouble(),
      ratingCount: readJsonValue<int>(json, 'ratingCount') ?? 0,
      reasons: (readJsonValue<List<dynamic>>(json, 'reasons') ?? [])
          .map((item) => item.toString())
          .toList(),
    );
  }
}

class RecommendedGym {
  final String gymId;
  final String gymName;
  final String city;
  final String? photoUrl;
  final String? workHours;
  final double? ratingAverage;
  final int ratingCount;
  final List<String> reasons;

  RecommendedGym({
    required this.gymId,
    required this.gymName,
    required this.city,
    this.photoUrl,
    this.workHours,
    this.ratingAverage,
    required this.ratingCount,
    required this.reasons,
  });

  factory RecommendedGym.fromJson(Map<String, dynamic> json) {
    return RecommendedGym(
      gymId: readJsonValue<String>(json, 'gymId') ?? '',
      gymName: readJsonValue<String>(json, 'gymName') ?? '',
      city: readJsonValue<String>(json, 'city') ?? '',
      photoUrl: readJsonValue<String>(json, 'photoUrl'),
      workHours: readJsonValue<String>(json, 'workHours'),
      ratingAverage: readJsonValue<num>(json, 'ratingAverage')?.toDouble(),
      ratingCount: readJsonValue<int>(json, 'ratingCount') ?? 0,
      reasons: (readJsonValue<List<dynamic>>(json, 'reasons') ?? [])
          .map((item) => item.toString())
          .toList(),
    );
  }
}

String prettyJson(dynamic value) => const JsonEncoder.withIndent('  ').convert(value);
