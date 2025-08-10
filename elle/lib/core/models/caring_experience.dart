enum SurpriseCategory {
  romantic,
  supportive,
  health,
  comfort,
  adventure,
  creative,
}

enum ActionDifficulty {
  easy,
  medium,
  advanced,
}

enum MoodContext {
  menstruation,
  pms,
  ovulation,
  happy,
  stressed,
  tired,
  emotional,
}

class SurpriseIdea {
  final String id;
  final String title;
  final String description;
  final SurpriseCategory category;
  final ActionDifficulty difficulty;
  final int timeRequired; // minutes
  final int cost; // estimated cost in XOF
  final List<String> materials;
  final List<String> steps;
  final List<MoodContext> bestForMoods;
  final String emoji;
  final int carePointsValue;
  final List<String> tips;
  final bool isUnlocked;
  final int requiredLevel;

  const SurpriseIdea({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.timeRequired,
    this.cost = 0,
    this.materials = const [],
    this.steps = const [],
    this.bestForMoods = const [],
    required this.emoji,
    required this.carePointsValue,
    this.tips = const [],
    this.isUnlocked = true,
    this.requiredLevel = 0,
  });

  SurpriseIdea copyWith({
    String? id,
    String? title,
    String? description,
    SurpriseCategory? category,
    ActionDifficulty? difficulty,
    int? timeRequired,
    int? cost,
    List<String>? materials,
    List<String>? steps,
    List<MoodContext>? bestForMoods,
    String? emoji,
    int? carePointsValue,
    List<String>? tips,
    bool? isUnlocked,
    int? requiredLevel,
  }) {
    return SurpriseIdea(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      timeRequired: timeRequired ?? this.timeRequired,
      cost: cost ?? this.cost,
      materials: materials ?? this.materials,
      steps: steps ?? this.steps,
      bestForMoods: bestForMoods ?? this.bestForMoods,
      emoji: emoji ?? this.emoji,
      carePointsValue: carePointsValue ?? this.carePointsValue,
      tips: tips ?? this.tips,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      requiredLevel: requiredLevel ?? this.requiredLevel,
    );
  }

  String get categoryDisplayName {
    switch (category) {
      case SurpriseCategory.romantic:
        return 'Romantique';
      case SurpriseCategory.supportive:
        return 'Soutien';
      case SurpriseCategory.health:
        return 'Santé';
      case SurpriseCategory.comfort:
        return 'Confort';
      case SurpriseCategory.adventure:
        return 'Aventure';
      case SurpriseCategory.creative:
        return 'Créatif';
    }
  }

  String get difficultyDisplayName {
    switch (difficulty) {
      case ActionDifficulty.easy:
        return 'Facile';
      case ActionDifficulty.medium:
        return 'Moyen';
      case ActionDifficulty.advanced:
        return 'Avancé';
    }
  }

  String get formattedTime {
    if (timeRequired < 60) {
      return '$timeRequired min';
    }
    final hours = timeRequired ~/ 60;
    final minutes = timeRequired % 60;
    if (minutes == 0) {
      return '${hours}h';
    }
    return '${hours}h${minutes}min';
  }

  String get formattedCost {
    if (cost == 0) return 'Gratuit';
    return '${cost.toStringAsFixed(0)} XOF';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'difficulty': difficulty.name,
      'timeRequired': timeRequired,
      'cost': cost,
      'materials': materials,
      'steps': steps,
      'bestForMoods': bestForMoods.map((m) => m.name).toList(),
      'emoji': emoji,
      'carePointsValue': carePointsValue,
      'tips': tips,
      'isUnlocked': isUnlocked,
      'requiredLevel': requiredLevel,
    };
  }

  factory SurpriseIdea.fromJson(Map<String, dynamic> json) {
    return SurpriseIdea(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: SurpriseCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => SurpriseCategory.romantic,
      ),
      difficulty: ActionDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => ActionDifficulty.easy,
      ),
      timeRequired: json['timeRequired'] as int,
      cost: json['cost'] as int? ?? 0,
      materials: List<String>.from(json['materials'] as List? ?? []),
      steps: List<String>.from(json['steps'] as List? ?? []),
      bestForMoods: (json['bestForMoods'] as List? ?? [])
          .map((m) => MoodContext.values.firstWhere(
                (e) => e.name == m,
                orElse: () => MoodContext.happy,
              ))
          .toList(),
      emoji: json['emoji'] as String,
      carePointsValue: json['carePointsValue'] as int,
      tips: List<String>.from(json['tips'] as List? ?? []),
      isUnlocked: json['isUnlocked'] as bool? ?? true,
      requiredLevel: json['requiredLevel'] as int? ?? 0,
    );
  }
}

class CaringLevel {
  final int level;
  final String title;
  final String description;
  final int pointsRequired;
  final List<String> unlockedFeatures;
  final String badge;
  final String color;

  const CaringLevel({
    required this.level,
    required this.title,
    required this.description,
    required this.pointsRequired,
    this.unlockedFeatures = const [],
    required this.badge,
    required this.color,
  });

  CaringLevel copyWith({
    int? level,
    String? title,
    String? description,
    int? pointsRequired,
    List<String>? unlockedFeatures,
    String? badge,
    String? color,
  }) {
    return CaringLevel(
      level: level ?? this.level,
      title: title ?? this.title,
      description: description ?? this.description,
      pointsRequired: pointsRequired ?? this.pointsRequired,
      unlockedFeatures: unlockedFeatures ?? this.unlockedFeatures,
      badge: badge ?? this.badge,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'title': title,
      'description': description,
      'pointsRequired': pointsRequired,
      'unlockedFeatures': unlockedFeatures,
      'badge': badge,
      'color': color,
    };
  }

  factory CaringLevel.fromJson(Map<String, dynamic> json) {
    return CaringLevel(
      level: json['level'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      pointsRequired: json['pointsRequired'] as int,
      unlockedFeatures: List<String>.from(json['unlockedFeatures'] as List? ?? []),
      badge: json['badge'] as String,
      color: json['color'] as String,
    );
  }
}

class CareStreak {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActionDate;
  final List<DateTime> actionDates;

  const CareStreak({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActionDate,
    this.actionDates = const [],
  });

  CareStreak copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActionDate,
    List<DateTime>? actionDates,
  }) {
    return CareStreak(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActionDate: lastActionDate ?? this.lastActionDate,
      actionDates: actionDates ?? this.actionDates,
    );
  }

  bool get isActiveToday {
    if (lastActionDate == null) return false;
    final today = DateTime.now();
    final lastAction = lastActionDate!;
    return lastAction.year == today.year &&
           lastAction.month == today.month &&
           lastAction.day == today.day;
  }

  bool get isStreakBroken {
    if (lastActionDate == null) return currentStreak > 0;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return lastActionDate!.isBefore(DateTime(yesterday.year, yesterday.month, yesterday.day));
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActionDate': lastActionDate?.toIso8601String(),
      'actionDates': actionDates.map((d) => d.toIso8601String()).toList(),
    };
  }

  factory CareStreak.fromJson(Map<String, dynamic> json) {
    return CareStreak(
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastActionDate: json['lastActionDate'] != null 
          ? DateTime.parse(json['lastActionDate'] as String)
          : null,
      actionDates: (json['actionDates'] as List? ?? [])
          .map((d) => DateTime.parse(d as String))
          .toList(),
    );
  }
}

class CaringStats {
  final int totalActions;
  final int totalPoints;
  final int currentLevel;
  final Map<SurpriseCategory, int> categoryStats;
  final CareStreak streak;
  final List<String> achievements;
  final DateTime? lastActiveDate;

  const CaringStats({
    this.totalActions = 0,
    this.totalPoints = 0,
    this.currentLevel = 1,
    this.categoryStats = const {},
    this.streak = const CareStreak(),
    this.achievements = const [],
    this.lastActiveDate,
  });

  CaringStats copyWith({
    int? totalActions,
    int? totalPoints,
    int? currentLevel,
    Map<SurpriseCategory, int>? categoryStats,
    CareStreak? streak,
    List<String>? achievements,
    DateTime? lastActiveDate,
  }) {
    return CaringStats(
      totalActions: totalActions ?? this.totalActions,
      totalPoints: totalPoints ?? this.totalPoints,
      currentLevel: currentLevel ?? this.currentLevel,
      categoryStats: categoryStats ?? this.categoryStats,
      streak: streak ?? this.streak,
      achievements: achievements ?? this.achievements,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }

  double get averagePointsPerAction {
    if (totalActions == 0) return 0.0;
    return totalPoints / totalActions;
  }

  SurpriseCategory? get favoriteCategory {
    if (categoryStats.isEmpty) return null;
    return categoryStats.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  Map<String, dynamic> toJson() {
    return {
      'totalActions': totalActions,
      'totalPoints': totalPoints,
      'currentLevel': currentLevel,
      'categoryStats': categoryStats.map((k, v) => MapEntry(k.name, v)),
      'streak': streak.toJson(),
      'achievements': achievements,
      'lastActiveDate': lastActiveDate?.toIso8601String(),
    };
  }

  factory CaringStats.fromJson(Map<String, dynamic> json) {
    return CaringStats(
      totalActions: json['totalActions'] as int? ?? 0,
      totalPoints: json['totalPoints'] as int? ?? 0,
      currentLevel: json['currentLevel'] as int? ?? 1,
      categoryStats: (json['categoryStats'] as Map? ?? {}).map(
        (k, v) => MapEntry(
          SurpriseCategory.values.firstWhere(
            (e) => e.name == k,
            orElse: () => SurpriseCategory.romantic,
          ),
          v as int,
        ),
      ),
      streak: CareStreak.fromJson(json['streak'] as Map<String, dynamic>? ?? {}),
      achievements: List<String>.from(json['achievements'] as List? ?? []),
      lastActiveDate: json['lastActiveDate'] != null 
          ? DateTime.parse(json['lastActiveDate'] as String)
          : null,
    );
  }
}

class CompletedAction {
  final String id;
  final String surpriseId;
  final String title;
  final SurpriseCategory category;
  final int pointsEarned;
  final DateTime completedAt;
  final String? notes;
  final List<String> photos;
  final int rating;

  const CompletedAction({
    required this.id,
    required this.surpriseId,
    required this.title,
    required this.category,
    required this.pointsEarned,
    required this.completedAt,
    this.notes,
    this.photos = const [],
    this.rating = 0,
  });

  String get categoryDisplayName {
    switch (category) {
      case SurpriseCategory.romantic:
        return 'Romantique';
      case SurpriseCategory.supportive:
        return 'Soutien';
      case SurpriseCategory.health:
        return 'Santé';
      case SurpriseCategory.comfort:
        return 'Confort';
      case SurpriseCategory.adventure:
        return 'Aventure';
      case SurpriseCategory.creative:
        return 'Créatif';
    }
  }

  CompletedAction copyWith({
    String? id,
    String? surpriseId,
    String? title,
    SurpriseCategory? category,
    int? pointsEarned,
    DateTime? completedAt,
    String? notes,
    List<String>? photos,
    int? rating,
  }) {
    return CompletedAction(
      id: id ?? this.id,
      surpriseId: surpriseId ?? this.surpriseId,
      title: title ?? this.title,
      category: category ?? this.category,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      photos: photos ?? this.photos,
      rating: rating ?? this.rating,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'surpriseId': surpriseId,
      'title': title,
      'category': category.name,
      'pointsEarned': pointsEarned,
      'completedAt': completedAt.toIso8601String(),
      'notes': notes,
      'photos': photos,
      'rating': rating,
    };
  }

  factory CompletedAction.fromJson(Map<String, dynamic> json) {
    return CompletedAction(
      id: json['id'] as String,
      surpriseId: json['surpriseId'] as String,
      title: json['title'] as String,
      category: SurpriseCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => SurpriseCategory.romantic,
      ),
      pointsEarned: json['pointsEarned'] as int,
      completedAt: DateTime.parse(json['completedAt'] as String),
      notes: json['notes'] as String?,
      photos: List<String>.from(json['photos'] as List? ?? []),
      rating: json['rating'] as int? ?? 0,
    );
  }
}