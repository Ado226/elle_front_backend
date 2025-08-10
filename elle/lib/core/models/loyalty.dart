enum RewardCategory {
  health,
  beauty,
  wellness,
  shopping,
  experiences,
  digital,
  charity,
}

enum RewardType {
  discount,
  freeProduct,
  cashback,
  experience,
  digitalContent,
  donation,
  exclusive,
}

enum PointSource {
  purchase,
  caringAction,
  partnerInteraction,
  dailyLogin,
  profileCompletion,
  referral,
  cycleTracking,
  forumActivity,
  articleReading,
  appointmentBooking,
  reviewWriting,
  sharingContent,
}

enum RewardStatus {
  available,
  claimed,
  expired,
  outOfStock,
  upcoming,
}

class LoyaltyPoints {
  final int totalPoints;
  final int availablePoints;
  final int pendingPoints;
  final int lifetimePoints;
  final DateTime lastUpdated;
  final Map<PointSource, int> pointsBySource;

  const LoyaltyPoints({
    this.totalPoints = 0,
    this.availablePoints = 0,
    this.pendingPoints = 0,
    this.lifetimePoints = 0,
    required this.lastUpdated,
    this.pointsBySource = const {},
  });

  LoyaltyPoints copyWith({
    int? totalPoints,
    int? availablePoints,
    int? pendingPoints,
    int? lifetimePoints,
    DateTime? lastUpdated,
    Map<PointSource, int>? pointsBySource,
  }) {
    return LoyaltyPoints(
      totalPoints: totalPoints ?? this.totalPoints,
      availablePoints: availablePoints ?? this.availablePoints,
      pendingPoints: pendingPoints ?? this.pendingPoints,
      lifetimePoints: lifetimePoints ?? this.lifetimePoints,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      pointsBySource: pointsBySource ?? this.pointsBySource,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPoints': totalPoints,
      'availablePoints': availablePoints,
      'pendingPoints': pendingPoints,
      'lifetimePoints': lifetimePoints,
      'lastUpdated': lastUpdated.toIso8601String(),
      'pointsBySource': pointsBySource.map((k, v) => MapEntry(k.name, v)),
    };
  }

  factory LoyaltyPoints.fromJson(Map<String, dynamic> json) {
    return LoyaltyPoints(
      totalPoints: json['totalPoints'] as int? ?? 0,
      availablePoints: json['availablePoints'] as int? ?? 0,
      pendingPoints: json['pendingPoints'] as int? ?? 0,
      lifetimePoints: json['lifetimePoints'] as int? ?? 0,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      pointsBySource: (json['pointsBySource'] as Map? ?? {}).map(
        (k, v) => MapEntry(
          PointSource.values.firstWhere(
            (e) => e.name == k,
            orElse: () => PointSource.purchase,
          ),
          v as int,
        ),
      ),
    );
  }
}

class Reward {
  final String id;
  final String title;
  final String description;
  final String? detailedDescription;
  final RewardCategory category;
  final RewardType type;
  final int pointsCost;
  final String imageUrl;
  final List<String> images;
  final RewardStatus status;
  final DateTime? expiryDate;
  final int? quantityAvailable;
  final int? quantityLimit;
  final String? promoCode;
  final double? discountPercentage;
  final int? discountAmount;
  final String? partnerName;
  final String? partnerLogo;
  final List<String> terms;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isFeatured;
  final bool isExclusive;
  final int popularityScore;

  const Reward({
    required this.id,
    required this.title,
    required this.description,
    this.detailedDescription,
    required this.category,
    required this.type,
    required this.pointsCost,
    required this.imageUrl,
    this.images = const [],
    this.status = RewardStatus.available,
    this.expiryDate,
    this.quantityAvailable,
    this.quantityLimit,
    this.promoCode,
    this.discountPercentage,
    this.discountAmount,
    this.partnerName,
    this.partnerLogo,
    this.terms = const [],
    this.metadata = const {},
    required this.createdAt,
    this.updatedAt,
    this.isFeatured = false,
    this.isExclusive = false,
    this.popularityScore = 0,
  });

  Reward copyWith({
    String? id,
    String? title,
    String? description,
    String? detailedDescription,
    RewardCategory? category,
    RewardType? type,
    int? pointsCost,
    String? imageUrl,
    List<String>? images,
    RewardStatus? status,
    DateTime? expiryDate,
    int? quantityAvailable,
    int? quantityLimit,
    String? promoCode,
    double? discountPercentage,
    int? discountAmount,
    String? partnerName,
    String? partnerLogo,
    List<String>? terms,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFeatured,
    bool? isExclusive,
    int? popularityScore,
  }) {
    return Reward(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      detailedDescription: detailedDescription ?? this.detailedDescription,
      category: category ?? this.category,
      type: type ?? this.type,
      pointsCost: pointsCost ?? this.pointsCost,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      status: status ?? this.status,
      expiryDate: expiryDate ?? this.expiryDate,
      quantityAvailable: quantityAvailable ?? this.quantityAvailable,
      quantityLimit: quantityLimit ?? this.quantityLimit,
      promoCode: promoCode ?? this.promoCode,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      discountAmount: discountAmount ?? this.discountAmount,
      partnerName: partnerName ?? this.partnerName,
      partnerLogo: partnerLogo ?? this.partnerLogo,
      terms: terms ?? this.terms,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFeatured: isFeatured ?? this.isFeatured,
      isExclusive: isExclusive ?? this.isExclusive,
      popularityScore: popularityScore ?? this.popularityScore,
    );
  }

  String get categoryDisplayName {
    switch (category) {
      case RewardCategory.health:
        return 'Santé';
      case RewardCategory.beauty:
        return 'Beauté';
      case RewardCategory.wellness:
        return 'Bien-être';
      case RewardCategory.shopping:
        return 'Shopping';
      case RewardCategory.experiences:
        return 'Expériences';
      case RewardCategory.digital:
        return 'Numérique';
      case RewardCategory.charity:
        return 'Charité';
    }
  }

  String get typeDisplayName {
    switch (type) {
      case RewardType.discount:
        return 'Réduction';
      case RewardType.freeProduct:
        return 'Produit gratuit';
      case RewardType.cashback:
        return 'Cashback';
      case RewardType.experience:
        return 'Expérience';
      case RewardType.digitalContent:
        return 'Contenu numérique';
      case RewardType.donation:
        return 'Don';
      case RewardType.exclusive:
        return 'Exclusif';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case RewardStatus.available:
        return 'Disponible';
      case RewardStatus.claimed:
        return 'Réclamé';
      case RewardStatus.expired:
        return 'Expiré';
      case RewardStatus.outOfStock:
        return 'Rupture de stock';
      case RewardStatus.upcoming:
        return 'À venir';
    }
  }

  bool get isAvailable => status == RewardStatus.available;
  bool get hasExpiry => expiryDate != null;
  bool get isExpired => expiryDate != null && DateTime.now().isAfter(expiryDate!);
  bool get hasQuantityLimit => quantityAvailable != null;
  bool get isOutOfStock => quantityAvailable != null && quantityAvailable! <= 0;

  String get formattedDiscount {
    if (discountPercentage != null) {
      return '${discountPercentage!.toInt()}% de réduction';
    } else if (discountAmount != null) {
      return '${discountAmount} XOF de réduction';
    }
    return '';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'detailedDescription': detailedDescription,
      'category': category.name,
      'type': type.name,
      'pointsCost': pointsCost,
      'imageUrl': imageUrl,
      'images': images,
      'status': status.name,
      'expiryDate': expiryDate?.toIso8601String(),
      'quantityAvailable': quantityAvailable,
      'quantityLimit': quantityLimit,
      'promoCode': promoCode,
      'discountPercentage': discountPercentage,
      'discountAmount': discountAmount,
      'partnerName': partnerName,
      'partnerLogo': partnerLogo,
      'terms': terms,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isFeatured': isFeatured,
      'isExclusive': isExclusive,
      'popularityScore': popularityScore,
    };
  }

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      detailedDescription: json['detailedDescription'] as String?,
      category: RewardCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => RewardCategory.health,
      ),
      type: RewardType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RewardType.discount,
      ),
      pointsCost: json['pointsCost'] as int,
      imageUrl: json['imageUrl'] as String,
      images: List<String>.from(json['images'] as List? ?? []),
      status: RewardStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RewardStatus.available,
      ),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      quantityAvailable: json['quantityAvailable'] as int?,
      quantityLimit: json['quantityLimit'] as int?,
      promoCode: json['promoCode'] as String?,
      discountPercentage: json['discountPercentage'] as double?,
      discountAmount: json['discountAmount'] as int?,
      partnerName: json['partnerName'] as String?,
      partnerLogo: json['partnerLogo'] as String?,
      terms: List<String>.from(json['terms'] as List? ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isExclusive: json['isExclusive'] as bool? ?? false,
      popularityScore: json['popularityScore'] as int? ?? 0,
    );
  }
}

class ClaimedReward {
  final String id;
  final String rewardId;
  final String rewardTitle;
  final RewardType rewardType;
  final int pointsUsed;
  final DateTime claimedAt;
  final DateTime? usedAt;
  final DateTime? expiryDate;
  final String? promoCode;
  final String? qrCode;
  final RewardStatus status;
  final Map<String, dynamic> metadata;

  const ClaimedReward({
    required this.id,
    required this.rewardId,
    required this.rewardTitle,
    required this.rewardType,
    required this.pointsUsed,
    required this.claimedAt,
    this.usedAt,
    this.expiryDate,
    this.promoCode,
    this.qrCode,
    this.status = RewardStatus.claimed,
    this.metadata = const {},
  });

  ClaimedReward copyWith({
    String? id,
    String? rewardId,
    String? rewardTitle,
    RewardType? rewardType,
    int? pointsUsed,
    DateTime? claimedAt,
    DateTime? usedAt,
    DateTime? expiryDate,
    String? promoCode,
    String? qrCode,
    RewardStatus? status,
    Map<String, dynamic>? metadata,
  }) {
    return ClaimedReward(
      id: id ?? this.id,
      rewardId: rewardId ?? this.rewardId,
      rewardTitle: rewardTitle ?? this.rewardTitle,
      rewardType: rewardType ?? this.rewardType,
      pointsUsed: pointsUsed ?? this.pointsUsed,
      claimedAt: claimedAt ?? this.claimedAt,
      usedAt: usedAt ?? this.usedAt,
      expiryDate: expiryDate ?? this.expiryDate,
      promoCode: promoCode ?? this.promoCode,
      qrCode: qrCode ?? this.qrCode,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isExpired => expiryDate != null && DateTime.now().isAfter(expiryDate!);
  bool get isUsed => usedAt != null;
  bool get isActive => !isExpired && !isUsed;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rewardId': rewardId,
      'rewardTitle': rewardTitle,
      'rewardType': rewardType.name,
      'pointsUsed': pointsUsed,
      'claimedAt': claimedAt.toIso8601String(),
      'usedAt': usedAt?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'promoCode': promoCode,
      'qrCode': qrCode,
      'status': status.name,
      'metadata': metadata,
    };
  }

  factory ClaimedReward.fromJson(Map<String, dynamic> json) {
    return ClaimedReward(
      id: json['id'] as String,
      rewardId: json['rewardId'] as String,
      rewardTitle: json['rewardTitle'] as String,
      rewardType: RewardType.values.firstWhere(
        (e) => e.name == json['rewardType'],
        orElse: () => RewardType.discount,
      ),
      pointsUsed: json['pointsUsed'] as int,
      claimedAt: DateTime.parse(json['claimedAt'] as String),
      usedAt: json['usedAt'] != null
          ? DateTime.parse(json['usedAt'] as String)
          : null,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      promoCode: json['promoCode'] as String?,
      qrCode: json['qrCode'] as String?,
      status: RewardStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RewardStatus.claimed,
      ),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }
}

class PointTransaction {
  final String id;
  final PointSource source;
  final int points;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  final String? referenceId;

  const PointTransaction({
    required this.id,
    required this.source,
    required this.points,
    required this.description,
    required this.timestamp,
    this.metadata = const {},
    this.referenceId,
  });

  PointTransaction copyWith({
    String? id,
    PointSource? source,
    int? points,
    String? description,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
    String? referenceId,
  }) {
    return PointTransaction(
      id: id ?? this.id,
      source: source ?? this.source,
      points: points ?? this.points,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
      referenceId: referenceId ?? this.referenceId,
    );
  }

  String get sourceDisplayName {
    switch (source) {
      case PointSource.purchase:
        return 'Achat';
      case PointSource.caringAction:
        return 'Action caring';
      case PointSource.partnerInteraction:
        return 'Interaction partenaire';
      case PointSource.dailyLogin:
        return 'Connexion quotidienne';
      case PointSource.profileCompletion:
        return 'Profil complété';
      case PointSource.referral:
        return 'Parrainage';
      case PointSource.cycleTracking:
        return 'Suivi de cycle';
      case PointSource.forumActivity:
        return 'Activité forum';
      case PointSource.articleReading:
        return 'Lecture d\'article';
      case PointSource.appointmentBooking:
        return 'Prise de rendez-vous';
      case PointSource.reviewWriting:
        return 'Écriture d\'avis';
      case PointSource.sharingContent:
        return 'Partage de contenu';
    }
  }

  bool get isEarned => points > 0;
  bool get isSpent => points < 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source': source.name,
      'points': points,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
      'referenceId': referenceId,
    };
  }

  factory PointTransaction.fromJson(Map<String, dynamic> json) {
    return PointTransaction(
      id: json['id'] as String,
      source: PointSource.values.firstWhere(
        (e) => e.name == json['source'],
        orElse: () => PointSource.purchase,
      ),
      points: json['points'] as int,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
      referenceId: json['referenceId'] as String?,
    );
  }
}

class LoyaltyTier {
  final String id;
  final String name;
  final String description;
  final int pointsRequired;
  final double multiplier;
  final List<String> benefits;
  final String color;
  final String icon;

  const LoyaltyTier({
    required this.id,
    required this.name,
    required this.description,
    required this.pointsRequired,
    this.multiplier = 1.0,
    this.benefits = const [],
    required this.color,
    required this.icon,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'pointsRequired': pointsRequired,
      'multiplier': multiplier,
      'benefits': benefits,
      'color': color,
      'icon': icon,
    };
  }

  factory LoyaltyTier.fromJson(Map<String, dynamic> json) {
    return LoyaltyTier(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      pointsRequired: json['pointsRequired'] as int,
      multiplier: json['multiplier'] as double? ?? 1.0,
      benefits: List<String>.from(json['benefits'] as List? ?? []),
      color: json['color'] as String,
      icon: json['icon'] as String,
    );
  }
}

// Extensions for enums
extension PointSourceExtension on PointSource {
  String get sourceDisplayName {
    switch (this) {
      case PointSource.purchase:
        return 'Achat';
      case PointSource.caringAction:
        return 'Action caring';
      case PointSource.partnerInteraction:
        return 'Interaction partenaire';
      case PointSource.dailyLogin:
        return 'Connexion quotidienne';
      case PointSource.profileCompletion:
        return 'Profil complété';
      case PointSource.referral:
        return 'Parrainage';
      case PointSource.cycleTracking:
        return 'Suivi de cycle';
      case PointSource.forumActivity:
        return 'Activité forum';
      case PointSource.articleReading:
        return 'Lecture d\'article';
      case PointSource.appointmentBooking:
        return 'Réservation RDV';
      case PointSource.reviewWriting:
        return 'Rédaction d\'avis';
      case PointSource.sharingContent:
        return 'Partage de contenu';
    }
  }
}