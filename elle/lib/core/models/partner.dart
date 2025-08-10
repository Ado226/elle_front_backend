enum PartnershipStatus {
  pending,
  connected,
  paused,
  disconnected,
}

enum NotificationType {
  menstrualPhase,
  mood,
  symptoms,
  appointment,
  reminder,
  achievement,
  gift,
}

enum GestureCategory {
  romantic,
  supportive,
  caring,
  thoughtful,
  surprise,
}

class Partner {
  final String id;
  final String name;
  final String? profileImageUrl;
  final String? phoneNumber;
  final String? email;
  final DateTime connectedAt;
  final PartnershipStatus status;
  final Map<String, bool> notificationPreferences;
  final int carePoints;
  final List<String> achievements;
  final DateTime? lastActiveAt;

  const Partner({
    required this.id,
    required this.name,
    this.profileImageUrl,
    this.phoneNumber,
    this.email,
    required this.connectedAt,
    this.status = PartnershipStatus.pending,
    this.notificationPreferences = const {},
    this.carePoints = 0,
    this.achievements = const [],
    this.lastActiveAt,
  });

  Partner copyWith({
    String? id,
    String? name,
    String? profileImageUrl,
    String? phoneNumber,
    String? email,
    DateTime? connectedAt,
    PartnershipStatus? status,
    Map<String, bool>? notificationPreferences,
    int? carePoints,
    List<String>? achievements,
    DateTime? lastActiveAt,
  }) {
    return Partner(
      id: id ?? this.id,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      connectedAt: connectedAt ?? this.connectedAt,
      status: status ?? this.status,
      notificationPreferences: notificationPreferences ?? this.notificationPreferences,
      carePoints: carePoints ?? this.carePoints,
      achievements: achievements ?? this.achievements,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  String get statusDisplayName {
    switch (status) {
      case PartnershipStatus.pending:
        return 'En attente';
      case PartnershipStatus.connected:
        return 'Connecté';
      case PartnershipStatus.paused:
        return 'En pause';
      case PartnershipStatus.disconnected:
        return 'Déconnecté';
    }
  }

  String get careLevel {
    if (carePoints >= 1000) return 'Expert en attention';
    if (carePoints >= 500) return 'Partenaire attentionné';
    if (carePoints >= 200) return 'Ami bienveillant';
    if (carePoints >= 50) return 'Débutant en soin';
    return 'Nouveau partenaire';
  }

  bool get isConnected => status == PartnershipStatus.connected;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profileImageUrl': profileImageUrl,
      'phoneNumber': phoneNumber,
      'email': email,
      'connectedAt': connectedAt.toIso8601String(),
      'status': status.name,
      'notificationPreferences': notificationPreferences,
      'carePoints': carePoints,
      'achievements': achievements,
      'lastActiveAt': lastActiveAt?.toIso8601String(),
    };
  }

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      id: json['id'] as String,
      name: json['name'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      connectedAt: DateTime.parse(json['connectedAt'] as String),
      status: PartnershipStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PartnershipStatus.pending,
      ),
      notificationPreferences: Map<String, bool>.from(json['notificationPreferences'] as Map? ?? {}),
      carePoints: json['carePoints'] as int? ?? 0,
      achievements: List<String>.from(json['achievements'] as List? ?? []),
      lastActiveAt: json['lastActiveAt'] != null 
          ? DateTime.parse(json['lastActiveAt'] as String)
          : null,
    );
  }
}

class PartnerConnection {
  final String connectionCode;
  final String userId;
  final String? partnerId;
  final DateTime createdAt;
  final DateTime? connectedAt;
  final DateTime expiresAt;
  final bool isActive;

  const PartnerConnection({
    required this.connectionCode,
    required this.userId,
    this.partnerId,
    required this.createdAt,
    this.connectedAt,
    required this.expiresAt,
    this.isActive = true,
  });

  PartnerConnection copyWith({
    String? connectionCode,
    String? userId,
    String? partnerId,
    DateTime? createdAt,
    DateTime? connectedAt,
    DateTime? expiresAt,
    bool? isActive,
  }) {
    return PartnerConnection(
      connectionCode: connectionCode ?? this.connectionCode,
      userId: userId ?? this.userId,
      partnerId: partnerId ?? this.partnerId,
      createdAt: createdAt ?? this.createdAt,
      connectedAt: connectedAt ?? this.connectedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isConnected => partnerId != null && connectedAt != null;

  Map<String, dynamic> toJson() {
    return {
      'connectionCode': connectionCode,
      'userId': userId,
      'partnerId': partnerId,
      'createdAt': createdAt.toIso8601String(),
      'connectedAt': connectedAt?.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory PartnerConnection.fromJson(Map<String, dynamic> json) {
    return PartnerConnection(
      connectionCode: json['connectionCode'] as String,
      userId: json['userId'] as String,
      partnerId: json['partnerId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      connectedAt: json['connectedAt'] != null 
          ? DateTime.parse(json['connectedAt'] as String)
          : null,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

class PartnerNotification {
  final String id;
  final String userId;
  final String? partnerId;
  final NotificationType type;
  final String title;
  final String message;
  final Map<String, dynamic> data;
  final DateTime scheduledAt;
  final DateTime? sentAt;
  final bool isRead;
  final List<String> suggestedActions;

  const PartnerNotification({
    required this.id,
    required this.userId,
    this.partnerId,
    required this.type,
    required this.title,
    required this.message,
    this.data = const {},
    required this.scheduledAt,
    this.sentAt,
    this.isRead = false,
    this.suggestedActions = const [],
  });

  PartnerNotification copyWith({
    String? id,
    String? userId,
    String? partnerId,
    NotificationType? type,
    String? title,
    String? message,
    Map<String, dynamic>? data,
    DateTime? scheduledAt,
    DateTime? sentAt,
    bool? isRead,
    List<String>? suggestedActions,
  }) {
    return PartnerNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      partnerId: partnerId ?? this.partnerId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      data: data ?? this.data,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      sentAt: sentAt ?? this.sentAt,
      isRead: isRead ?? this.isRead,
      suggestedActions: suggestedActions ?? this.suggestedActions,
    );
  }

  String get typeDisplayName {
    switch (type) {
      case NotificationType.menstrualPhase:
        return 'Phase menstruelle';
      case NotificationType.mood:
        return 'Humeur';
      case NotificationType.symptoms:
        return 'Symptômes';
      case NotificationType.appointment:
        return 'Rendez-vous médical';
      case NotificationType.reminder:
        return 'Rappel';
      case NotificationType.achievement:
        return 'Réussite';
      case NotificationType.gift:
        return 'Cadeau';
    }
  }

  String get typeEmoji {
    switch (type) {
      case NotificationType.menstrualPhase:
        return '🩸';
      case NotificationType.mood:
        return '😊';
      case NotificationType.symptoms:
        return '💊';
      case NotificationType.appointment:
        return '🏥';
      case NotificationType.reminder:
        return '⏰';
      case NotificationType.achievement:
        return '🏆';
      case NotificationType.gift:
        return '🎁';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'partnerId': partnerId,
      'type': type.name,
      'title': title,
      'message': message,
      'data': data,
      'scheduledAt': scheduledAt.toIso8601String(),
      'sentAt': sentAt?.toIso8601String(),
      'isRead': isRead,
      'suggestedActions': suggestedActions,
    };
  }

  factory PartnerNotification.fromJson(Map<String, dynamic> json) {
    return PartnerNotification(
      id: json['id'] as String,
      userId: json['userId'] as String,
      partnerId: json['partnerId'] as String?,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.reminder,
      ),
      title: json['title'] as String,
      message: json['message'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map? ?? {}),
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      sentAt: json['sentAt'] != null 
          ? DateTime.parse(json['sentAt'] as String)
          : null,
      isRead: json['isRead'] as bool? ?? false,
      suggestedActions: List<String>.from(json['suggestedActions'] as List? ?? []),
    );
  }
}

class CareGesture {
  final String id;
  final String title;
  final String description;
  final GestureCategory category;
  final int pointsValue;
  final String emoji;
  final List<String> tips;
  final bool isUnlocked;
  final int requiredCarePoints;
  final bool isCompleted;
  final int points;

  const CareGesture({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.pointsValue,
    required this.emoji,
    this.tips = const [],
    this.isUnlocked = true,
    this.requiredCarePoints = 0,
    this.isCompleted = false,
    int? points,
  }) : points = points ?? pointsValue;

  CareGesture copyWith({
    String? id,
    String? title,
    String? description,
    GestureCategory? category,
    int? pointsValue,
    String? emoji,
    List<String>? tips,
    bool? isUnlocked,
    int? requiredCarePoints,
    bool? isCompleted,
    int? points,
  }) {
    return CareGesture(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      pointsValue: pointsValue ?? this.pointsValue,
      emoji: emoji ?? this.emoji,
      tips: tips ?? this.tips,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      requiredCarePoints: requiredCarePoints ?? this.requiredCarePoints,
      isCompleted: isCompleted ?? this.isCompleted,
      points: points ?? this.points,
    );
  }

  String get categoryDisplayName {
    switch (category) {
      case GestureCategory.romantic:
        return 'Romantique';
      case GestureCategory.supportive:
        return 'Soutien';
      case GestureCategory.caring:
        return 'Attention';
      case GestureCategory.thoughtful:
        return 'Prévenance';
      case GestureCategory.surprise:
        return 'Surprise';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'pointsValue': pointsValue,
      'emoji': emoji,
      'tips': tips,
      'isUnlocked': isUnlocked,
      'requiredCarePoints': requiredCarePoints,
    };
  }

  factory CareGesture.fromJson(Map<String, dynamic> json) {
    return CareGesture(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: GestureCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => GestureCategory.caring,
      ),
      pointsValue: json['pointsValue'] as int,
      emoji: json['emoji'] as String,
      tips: List<String>.from(json['tips'] as List? ?? []),
      isUnlocked: json['isUnlocked'] as bool? ?? true,
      requiredCarePoints: json['requiredCarePoints'] as int? ?? 0,
    );
  }
}

class PartnerActivity {
  final String id;
  final String userId;
  final String? partnerId;
  final String action;
  final String description;
  final int pointsEarned;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const PartnerActivity({
    required this.id,
    required this.userId,
    this.partnerId,
    required this.action,
    required this.description,
    this.pointsEarned = 0,
    required this.timestamp,
    this.metadata = const {},
  });

  PartnerActivity copyWith({
    String? id,
    String? userId,
    String? partnerId,
    String? action,
    String? description,
    int? pointsEarned,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return PartnerActivity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      partnerId: partnerId ?? this.partnerId,
      action: action ?? this.action,
      description: description ?? this.description,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'partnerId': partnerId,
      'action': action,
      'description': description,
      'pointsEarned': pointsEarned,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory PartnerActivity.fromJson(Map<String, dynamic> json) {
    return PartnerActivity(
      id: json['id'] as String,
      userId: json['userId'] as String,
      partnerId: json['partnerId'] as String?,
      action: json['action'] as String,
      description: json['description'] as String,
      pointsEarned: json['pointsEarned'] as int? ?? 0,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }
}