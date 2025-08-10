import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/models/caring_experience.dart';

class CaringService {
  static const String _surpriseIdeasKey = 'surprise_ideas';
  static const String _caringStatsKey = 'caring_stats';
  static const String _completedActionsKey = 'completed_actions';
  static const String _caringLevelsKey = 'caring_levels';

  // Caring levels configuration
  static final List<CaringLevel> _caringLevels = [
    CaringLevel(
      level: 1,
      title: 'Débutant attentionné',
      description: 'Vous commencez votre voyage vers plus d\'attention',
      pointsRequired: 0,
      badge: '🌱',
      color: '4CAF50',
      unlockedFeatures: ['Idées de base', 'Suivi des actions'],
    ),
    CaringLevel(
      level: 2,
      title: 'Partenaire bienveillant',
      description: 'Vous montrez une attention constante',
      pointsRequired: 100,
      badge: '💚',
      color: '2196F3',
      unlockedFeatures: ['Idées moyennes', 'Statistiques détaillées'],
    ),
    CaringLevel(
      level: 3,
      title: 'Expert en romance',
      description: 'Vos gestes romantiques sont remarquables',
      pointsRequired: 300,
      badge: '💕',
      color: 'E91E63',
      unlockedFeatures: ['Idées avancées', 'Suggestions personnalisées'],
    ),
    CaringLevel(
      level: 4,
      title: 'Maître de l\'attention',
      description: 'Votre dévouement est exemplaire',
      pointsRequired: 600,
      badge: '👑',
      color: 'FF9800',
      unlockedFeatures: ['Idées exclusives', 'Défis spéciaux'],
    ),
    CaringLevel(
      level: 5,
      title: 'Légende de l\'amour',
      description: 'Vous êtes un modèle d\'attention et d\'amour',
      pointsRequired: 1000,
      badge: '⭐',
      color: 'FF5722',
      unlockedFeatures: ['Toutes les fonctionnalités', 'Statut VIP'],
    ),
  ];

  // Sample surprise ideas
  static final List<SurpriseIdea> _sampleSurpriseIdeas = [
    SurpriseIdea(
      id: '1',
      title: 'Message matinal d\'amour',
      description: 'Envoyez un message doux pour commencer sa journée',
      category: SurpriseCategory.romantic,
      difficulty: ActionDifficulty.easy,
      timeRequired: 5,
      cost: 0,
      emoji: '💌',
      carePointsValue: 10,
      bestForMoods: [MoodContext.happy, MoodContext.stressed],
      tips: [
        'Personnalisez le message selon son humeur',
        'Mentionnez quelque chose de spécial à venir',
        'Ajoutez un emoji qui la fait sourire'
      ],
      steps: [
        'Réfléchissez à ce qui la rendrait heureuse',
        'Écrivez un message sincère et personnalisé',
        'Envoyez-le à un moment où elle le verra',
      ],
    ),
    SurpriseIdea(
      id: '2',
      title: 'Petit-déjeuner surprise',
      description: 'Préparez son petit-déjeuner préféré',
      category: SurpriseCategory.supportive,
      difficulty: ActionDifficulty.medium,
      timeRequired: 30,
      cost: 2000,
      emoji: '🥐',
      carePointsValue: 25,
      bestForMoods: [MoodContext.menstruation, MoodContext.tired],
      materials: ['Ingrédients préférés', 'Plateau', 'Serviette'],
      tips: [
        'Préparez tout en silence si elle dort',
        'Ajoutez une petite note',
        'Présentez joliment sur un plateau'
      ],
      steps: [
        'Rassemblez tous les ingrédients',
        'Préparez le petit-déjeuner avec soin',
        'Dressez joliment sur un plateau',
        'Servez avec le sourire',
      ],
    ),
    SurpriseIdea(
      id: '3',
      title: 'Soirée spa maison',
      description: 'Organisez une soirée détente avec bain et massage',
      category: SurpriseCategory.health,
      difficulty: ActionDifficulty.advanced,
      timeRequired: 120,
      cost: 3500,
      emoji: '🛁',
      carePointsValue: 40,
      bestForMoods: [MoodContext.stressed, MoodContext.menstruation, MoodContext.tired],
      materials: [
        'Sels de bain',
        'Huiles essentielles',
        'Bougies',
        'Musique relaxante',
        'Serviettes chaudes'
      ],
      tips: [
        'Créez une ambiance tamisée',
        'Préparez des boissons hydratantes',
        'Respectez son rythme et ses envies'
      ],
      steps: [
        'Préparez la salle de bain avec bougies et musique',
        'Faites couler un bain chaud avec sels',
        'Préparez l\'espace massage',
        'Guidez-la pour une soirée relaxante',
      ],
      requiredLevel: 2,
    ),
    SurpriseIdea(
      id: '4',
      title: 'Playlist personnalisée',
      description: 'Créez une playlist avec ses chansons préférées',
      category: SurpriseCategory.creative,
      difficulty: ActionDifficulty.easy,
      timeRequired: 45,
      cost: 0,
      emoji: '🎵',
      carePointsValue: 15,
      bestForMoods: [MoodContext.happy, MoodContext.emotional],
      tips: [
        'Incluez des chansons qui vous rappellent des moments spéciaux',
        'Mélangez ses styles préférés',
        'Ajoutez une chanson surprise qu\'elle ne connaît pas'
      ],
      steps: [
        'Réfléchissez aux chansons qui lui plaisent',
        'Organisez la playlist de manière fluide',
        'Ajoutez un titre personnel à la playlist',
        'Partagez-la avec un message explicatif',
      ],
    ),
    SurpriseIdea(
      id: '5',
      title: 'Pique-nique romantique',
      description: 'Organisez un pique-nique dans un endroit spécial',
      category: SurpriseCategory.adventure,
      difficulty: ActionDifficulty.medium,
      timeRequired: 180,
      cost: 5000,
      emoji: '🧺',
      carePointsValue: 35,
      bestForMoods: [MoodContext.happy, MoodContext.ovulation],
      materials: [
        'Panier pique-nique',
        'Couverture',
        'Nourriture préférée',
        'Boissons',
        'Enceinte portable'
      ],
      tips: [
        'Choisissez un endroit avec une belle vue',
        'Vérifiez la météo avant',
        'Apportez des jeux ou activités'
      ],
      steps: [
        'Planifiez le menu et préparez la nourriture',
        'Choisissez l\'endroit parfait',
        'Préparez le matériel nécessaire',
        'Créez une atmosphère romantique sur place',
      ],
      requiredLevel: 2,
    ),
    SurpriseIdea(
      id: '6',
      title: 'Lettre d\'amour manuscrite',
      description: 'Écrivez une lettre d\'amour touchante à la main',
      category: SurpriseCategory.romantic,
      difficulty: ActionDifficulty.medium,
      timeRequired: 60,
      cost: 500,
      emoji: '💝',
      carePointsValue: 30,
      bestForMoods: [MoodContext.emotional, MoodContext.happy],
      materials: ['Beau papier', 'Stylo', 'Enveloppe'],
      tips: [
        'Soyez sincère et spécifique',
        'Mentionnez des souvenirs précis',
        'Prenez votre temps pour bien écrire'
      ],
      steps: [
        'Réfléchissez à ce que vous voulez exprimer',
        'Structurez vos idées',
        'Écrivez la lettre à la main',
        'Pliez et présentez joliment',
      ],
    ),
    SurpriseIdea(
      id: '7',
      title: 'Cours de cuisine ensemble',
      description: 'Cuisinez ensemble un plat qu\'elle aime',
      category: SurpriseCategory.adventure,
      difficulty: ActionDifficulty.medium,
      timeRequired: 90,
      cost: 4000,
      emoji: '👨‍🍳',
      carePointsValue: 28,
      bestForMoods: [MoodContext.happy, MoodContext.ovulation],
      materials: ['Ingrédients', 'Recette', 'Tabliers', 'Vin (optionnel)'],
      tips: [
        'Choisissez une recette qu\'elle veut essayer',
        'Préparez tous les ingrédients à l\'avance',
        'Rendez l\'expérience amusante'
      ],
      steps: [
        'Choisissez la recette ensemble',
        'Faites les courses ensemble',
        'Préparez l\'espace de cuisine',
        'Cuisinez en équipe',
      ],
    ),
    SurpriseIdea(
      id: '8',
      title: 'Livre photo personnalisé',
      description: 'Créez un album photo de vos plus beaux moments',
      category: SurpriseCategory.creative,
      difficulty: ActionDifficulty.advanced,
      timeRequired: 240,
      cost: 8000,
      emoji: '📸',
      carePointsValue: 50,
      bestForMoods: [MoodContext.emotional, MoodContext.happy],
      materials: ['Photos', 'Album', 'Décorations', 'Stylos'],
      tips: [
        'Sélectionnez vos plus belles photos ensemble',
        'Ajoutez des petites notes pour chaque photo',
        'Organisez chronologiquement'
      ],
      steps: [
        'Rassemblez toutes vos photos préférées',
        'Choisissez un thème ou une organisation',
        'Imprimez et organisez les photos',
        'Créez l\'album avec amour',
      ],
      requiredLevel: 3,
    ),
    SurpriseIdea(
      id: '9',
      title: 'Moment détente avec tisane',
      description: 'Préparez une tisane apaisante et partagez un moment calme',
      category: SurpriseCategory.health,
      difficulty: ActionDifficulty.easy,
      timeRequired: 20,
      cost: 1000,
      emoji: '🍵',
      carePointsValue: 15,
      bestForMoods: [MoodContext.menstruation, MoodContext.stressed, MoodContext.tired],
      materials: ['Tisane', 'Miel', 'Tasses jolies', 'Petits biscuits'],
      tips: [
        'Choisissez une tisane qu\'elle aime',
        'Créez une atmosphère cosy',
        'Profitez du moment pour discuter'
      ],
      steps: [
        'Sélectionnez la tisane appropriée',
        'Faites chauffer l\'eau',
        'Préparez les tasses et accompagnements',
        'Servez et savourez ensemble',
      ],
    ),
    SurpriseIdea(
      id: '10',
      title: 'Surprise créative personnalisée',
      description: 'Créez quelque chose d\'unique : dessin, origami, bracelet...',
      category: SurpriseCategory.creative,
      difficulty: ActionDifficulty.advanced,
      timeRequired: 150,
      cost: 2500,
      emoji: '🎨',
      carePointsValue: 45,
      bestForMoods: [MoodContext.happy, MoodContext.emotional],
      materials: ['Matériel créatif', 'Outils', 'Inspiration'],
      tips: [
        'Choisissez quelque chose qui correspond à ses goûts',
        'Prenez votre temps pour bien faire',
        'L\'intention compte plus que la perfection'
      ],
      steps: [
        'Décidez du type de création',
        'Rassemblez le matériel nécessaire',
        'Créez avec patience et amour',
        'Présentez votre création',
      ],
      requiredLevel: 3,
    ),
  ];

  // Get caring stats
  static Future<CaringStats> getCaringStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString(_caringStatsKey);
      
      if (statsJson == null) {
        return const CaringStats();
      }
      
      return CaringStats.fromJson(jsonDecode(statsJson));
    } catch (e) {
      return const CaringStats();
    }
  }

  static Future<bool> updateCaringStats(CaringStats stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = jsonEncode(stats.toJson());
      return await prefs.setString(_caringStatsKey, statsJson);
    } catch (e) {
      return false;
    }
  }

  // Get surprise ideas
  static Future<List<SurpriseIdea>> getSurpriseIdeas({
    SurpriseCategory? category,
    ActionDifficulty? difficulty,
    MoodContext? mood,
    int? maxTime,
    int? maxCost,
    bool? unlockedOnly,
  }) async {
    final stats = await getCaringStats();
    final currentLevel = getCurrentLevel(stats.totalPoints);
    
    var ideas = List<SurpriseIdea>.from(_sampleSurpriseIdeas);
    
    // Apply unlock status based on level
    ideas = ideas.map((idea) {
      return idea.copyWith(
        isUnlocked: currentLevel >= idea.requiredLevel,
      );
    }).toList();
    
    // Apply filters
    if (category != null) {
      ideas = ideas.where((idea) => idea.category == category).toList();
    }
    
    if (difficulty != null) {
      ideas = ideas.where((idea) => idea.difficulty == difficulty).toList();
    }
    
    if (mood != null) {
      ideas = ideas.where((idea) => idea.bestForMoods.contains(mood)).toList();
    }
    
    if (maxTime != null) {
      ideas = ideas.where((idea) => idea.timeRequired <= maxTime).toList();
    }
    
    if (maxCost != null) {
      ideas = ideas.where((idea) => idea.cost <= maxCost).toList();
    }
    
    if (unlockedOnly == true) {
      ideas = ideas.where((idea) => idea.isUnlocked).toList();
    }
    
    return ideas;
  }

  static Future<List<SurpriseIdea>> getRecommendedIdeas({MoodContext? mood}) async {
    var ideas = await getSurpriseIdeas(unlockedOnly: true);
    
    if (mood != null) {
      // Prioritize ideas that match the mood
      ideas.sort((a, b) {
        final aMatches = a.bestForMoods.contains(mood);
        final bMatches = b.bestForMoods.contains(mood);
        if (aMatches && !bMatches) return -1;
        if (!aMatches && bMatches) return 1;
        return b.carePointsValue.compareTo(a.carePointsValue);
      });
    } else {
      // Sort by points value
      ideas.sort((a, b) => b.carePointsValue.compareTo(a.carePointsValue));
    }
    
    return ideas.take(5).toList();
  }

  static Future<SurpriseIdea?> getDailySurprise() async {
    final ideas = await getSurpriseIdeas(unlockedOnly: true);
    if (ideas.isEmpty) return null;
    
    // Use current date as seed for consistent daily surprise
    final today = DateTime.now();
    final seed = today.year * 10000 + today.month * 100 + today.day;
    final random = Random(seed);
    
    return ideas[random.nextInt(ideas.length)];
  }

  // Complete actions
  static Future<List<CompletedAction>> getCompletedActions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final actionsJson = prefs.getString(_completedActionsKey);
      
      if (actionsJson == null) return [];
      
      final actionsData = jsonDecode(actionsJson) as List;
      return actionsData
          .map((data) => CompletedAction.fromJson(data))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> completeAction(
    SurpriseIdea idea, {
    String? notes,
    List<String>? photos,
    int rating = 5,
  }) async {
    try {
      final actions = await getCompletedActions();
      final stats = await getCaringStats();
      
      // Create completed action
      final action = CompletedAction(
        id: generateId(),
        surpriseId: idea.id,
        title: idea.title,
        category: idea.category,
        pointsEarned: idea.carePointsValue,
        completedAt: DateTime.now(),
        notes: notes,
        photos: photos ?? [],
        rating: rating,
      );
      
      actions.insert(0, action);
      
      // Update stats
      final today = DateTime.now();
      final dateKey = DateTime(today.year, today.month, today.day);
      
      // Update streak
      var newStreak = stats.streak;
      if (newStreak.lastActionDate == null) {
        // First action ever
        newStreak = newStreak.copyWith(
          currentStreak: 1,
          longestStreak: 1,
          lastActionDate: today,
          actionDates: [dateKey],
        );
      } else if (!newStreak.isActiveToday) {
        final yesterday = today.subtract(const Duration(days: 1));
        final lastActionDay = DateTime(
          newStreak.lastActionDate!.year,
          newStreak.lastActionDate!.month,
          newStreak.lastActionDate!.day,
        );
        final yesterdayDay = DateTime(yesterday.year, yesterday.month, yesterday.day);
        
        if (lastActionDay.isAtSameMomentAs(yesterdayDay)) {
          // Continue streak
          newStreak = newStreak.copyWith(
            currentStreak: newStreak.currentStreak + 1,
            longestStreak: max(newStreak.longestStreak, newStreak.currentStreak + 1),
            lastActionDate: today,
            actionDates: [...newStreak.actionDates, dateKey],
          );
        } else {
          // Reset streak
          newStreak = newStreak.copyWith(
            currentStreak: 1,
            longestStreak: max(newStreak.longestStreak, 1),
            lastActionDate: today,
            actionDates: [...newStreak.actionDates, dateKey],
          );
        }
      }
      
      // Update category stats
      final newCategoryStats = Map<SurpriseCategory, int>.from(stats.categoryStats);
      newCategoryStats[idea.category] = (newCategoryStats[idea.category] ?? 0) + 1;
      
      // Update overall stats
      final newStats = stats.copyWith(
        totalActions: stats.totalActions + 1,
        totalPoints: stats.totalPoints + idea.carePointsValue,
        currentLevel: getCurrentLevel(stats.totalPoints + idea.carePointsValue),
        categoryStats: newCategoryStats,
        streak: newStreak,
        lastActiveDate: today,
      );
      
      // Check for new achievements
      await _checkAndAwardAchievements(newStats, stats);
      
      // Save data
      final prefs = await SharedPreferences.getInstance();
      
      final actionsJson = jsonEncode(actions.map((a) => a.toJson()).toList());
      await prefs.setString(_completedActionsKey, actionsJson);
      
      await updateCaringStats(newStats);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Levels and progression
  static int getCurrentLevel(int totalPoints) {
    for (int i = _caringLevels.length - 1; i >= 0; i--) {
      if (totalPoints >= _caringLevels[i].pointsRequired) {
        return _caringLevels[i].level;
      }
    }
    return 1;
  }

  static CaringLevel getCurrentLevelData(int totalPoints) {
    final level = getCurrentLevel(totalPoints);
    return _caringLevels.firstWhere((l) => l.level == level);
  }

  static CaringLevel? getNextLevelData(int totalPoints) {
    final currentLevel = getCurrentLevel(totalPoints);
    if (currentLevel >= _caringLevels.length) return null;
    
    return _caringLevels.firstWhere(
      (l) => l.level == currentLevel + 1,
      orElse: () => _caringLevels.last,
    );
  }

  static double getLevelProgress(int totalPoints) {
    final currentLevelData = getCurrentLevelData(totalPoints);
    final nextLevelData = getNextLevelData(totalPoints);
    
    if (nextLevelData == null) return 1.0;
    
    final currentLevelPoints = currentLevelData.pointsRequired;
    final nextLevelPoints = nextLevelData.pointsRequired;
    final pointsInLevel = totalPoints - currentLevelPoints;
    final pointsNeeded = nextLevelPoints - currentLevelPoints;
    
    return pointsInLevel / pointsNeeded;
  }

  static List<CaringLevel> getAllLevels() {
    return _caringLevels;
  }

  // Achievements
  static Future<void> _checkAndAwardAchievements(CaringStats newStats, CaringStats oldStats) async {
    final achievements = List<String>.from(newStats.achievements);
    bool hasNewAchievement = false;
    
    // First action
    if (newStats.totalActions == 1 && !achievements.contains('first_action')) {
      achievements.add('first_action');
      hasNewAchievement = true;
    }
    
    // Streak achievements
    if (newStats.streak.currentStreak >= 7 && !achievements.contains('week_streak')) {
      achievements.add('week_streak');
      hasNewAchievement = true;
    }
    
    if (newStats.streak.currentStreak >= 30 && !achievements.contains('month_streak')) {
      achievements.add('month_streak');
      hasNewAchievement = true;
    }
    
    // Points milestones
    if (newStats.totalPoints >= 100 && !achievements.contains('hundred_points')) {
      achievements.add('hundred_points');
      hasNewAchievement = true;
    }
    
    if (newStats.totalPoints >= 500 && !achievements.contains('five_hundred_points')) {
      achievements.add('five_hundred_points');
      hasNewAchievement = true;
    }
    
    // Category specialist
    for (final entry in newStats.categoryStats.entries) {
      final category = entry.key;
      final count = entry.value;
      final achievementKey = '${category.name}_specialist';
      
      if (count >= 10 && !achievements.contains(achievementKey)) {
        achievements.add(achievementKey);
        hasNewAchievement = true;
      }
    }
    
    // Level up achievements
    if (newStats.currentLevel > oldStats.currentLevel) {
      final levelAchievement = 'level_${newStats.currentLevel}';
      if (!achievements.contains(levelAchievement)) {
        achievements.add(levelAchievement);
        hasNewAchievement = true;
      }
    }
    
    if (hasNewAchievement) {
      final updatedStats = newStats.copyWith(achievements: achievements);
      await updateCaringStats(updatedStats);
    }
  }

  // Statistics
  static Future<Map<String, dynamic>> getDetailedStats() async {
    final stats = await getCaringStats();
    final actions = await getCompletedActions();
    
    // Actions by category
    final actionsByCategory = <SurpriseCategory, int>{};
    for (final action in actions) {
      actionsByCategory[action.category] = (actionsByCategory[action.category] ?? 0) + 1;
    }
    
    // Actions by month
    final actionsByMonth = <String, int>{};
    for (final action in actions) {
      final monthKey = '${action.completedAt.year}-${action.completedAt.month.toString().padLeft(2, '0')}';
      actionsByMonth[monthKey] = (actionsByMonth[monthKey] ?? 0) + 1;
    }
    
    // Average rating
    final ratings = actions.where((a) => a.rating > 0).map((a) => a.rating).toList();
    final averageRating = ratings.isEmpty ? 0.0 : ratings.reduce((a, b) => a + b) / ratings.length;
    
    return {
      'totalActions': stats.totalActions,
      'totalPoints': stats.totalPoints,
      'currentLevel': stats.currentLevel,
      'currentStreak': stats.streak.currentStreak,
      'longestStreak': stats.streak.longestStreak,
      'actionsByCategory': actionsByCategory.map((k, v) => MapEntry(k.name, v)),
      'actionsByMonth': actionsByMonth,
      'averageRating': averageRating,
      'achievements': stats.achievements,
      'favoriteCategory': stats.favoriteCategory?.name,
    };
  }

  // Utility methods
  static String generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'caring_${timestamp}_${(timestamp % 10000).toString().padLeft(4, '0')}';
  }

  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'à l\'instant';
    }
  }

  static String getAchievementTitle(String achievementKey) {
    switch (achievementKey) {
      case 'first_action':
        return 'Premier pas';
      case 'week_streak':
        return 'Une semaine d\'attention';
      case 'month_streak':
        return 'Un mois d\'amour';
      case 'hundred_points':
        return 'Centurion de l\'attention';
      case 'five_hundred_points':
        return 'Maître du care';
      case 'romantic_specialist':
        return 'Spécialiste romantique';
      case 'supportive_specialist':
        return 'Expert en soutien';
      case 'health_specialist':
        return 'Gardien de sa santé';
      case 'comfort_specialist':
        return 'Maître du confort';
      case 'adventure_specialist':
        return 'Aventurier du couple';
      case 'creative_specialist':
        return 'Créatif de l\'amour';
      case 'level_2':
        return 'Partenaire bienveillant';
      case 'level_3':
        return 'Expert en romance';
      case 'level_4':
        return 'Maître de l\'attention';
      case 'level_5':
        return 'Légende de l\'amour';
      default:
        return 'Réussite débloquée';
    }
  }

  static String getAchievementDescription(String achievementKey) {
    switch (achievementKey) {
      case 'first_action':
        return 'Vous avez accompli votre première action attentionnée';
      case 'week_streak':
        return 'Vous avez été attentionné 7 jours consécutifs';
      case 'month_streak':
        return 'Vous avez maintenu votre attention pendant 30 jours';
      case 'hundred_points':
        return 'Vous avez gagné 100 points d\'attention';
      case 'five_hundred_points':
        return 'Vous avez atteint 500 points d\'attention';
      case 'romantic_specialist':
        return 'Vous avez accompli 10 actions romantiques';
      case 'supportive_specialist':
        return 'Vous avez accompli 10 actions de soutien';
      case 'health_specialist':
        return 'Vous avez accompli 10 actions pour sa santé';
      case 'comfort_specialist':
        return 'Vous avez accompli 10 actions de confort';
      case 'adventure_specialist':
        return 'Vous avez accompli 10 aventures ensemble';
      case 'creative_specialist':
        return 'Vous avez accompli 10 créations personnalisées';
      case 'level_2':
        return 'Vous avez atteint le niveau 2';
      case 'level_3':
        return 'Vous avez atteint le niveau 3';
      case 'level_4':
        return 'Vous avez atteint le niveau 4';
      case 'level_5':
        return 'Vous avez atteint le niveau maximum';
      default:
        return 'Félicitations pour cette réussite !';
    }
  }
}