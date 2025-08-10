import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/models/partner.dart';

class PartnerService {
  static const String _partnerKey = 'connected_partner';
  static const String _connectionKey = 'partner_connection';
  static const String _notificationsKey = 'partner_notifications';
  static const String _activitiesKey = 'partner_activities';
  static const String _gesturesKey = 'care_gestures';

  // Sample care gestures data
  static final List<CareGesture> _sampleGestures = [
    CareGesture(
      id: '1',
      title: 'Préparer une tisane apaisante',
      description: 'Préparez une tisane de camomille ou de gingembre pour soulager les douleurs menstruelles',
      category: GestureCategory.caring,
      pointsValue: 10,
      emoji: '🍵',
      tips: [
        'Utilisez de la camomille pour ses propriétés anti-inflammatoires',
        'Ajoutez un peu de miel pour adoucir',
        'Servez dans sa tasse préférée'
      ],
    ),
    CareGesture(
      id: '2',
      title: 'Massage relaxant',
      description: 'Offrez un massage doux du dos ou des épaules pour détendre les tensions',
      category: GestureCategory.romantic,
      pointsValue: 15,
      emoji: '💆‍♀️',
      tips: [
        'Utilisez une huile essentielle de lavande',
        'Commencez doucement et demandez ses préférences',
        'Créez une ambiance relaxante avec une musique douce'
      ],
    ),
    CareGesture(
      id: '3',
      title: 'Préparer son plat préféré',
      description: 'Cuisinez son repas favori ou commandez de son restaurant préféré',
      category: GestureCategory.thoughtful,
      pointsValue: 20,
      emoji: '🍽️',
      tips: [
        'Évitez les aliments trop épicés pendant les règles',
        'Privilégiez les aliments riches en fer',
        'Présentez joliment le plat'
      ],
    ),
    CareGesture(
      id: '4',
      title: 'Soirée cocooning',
      description: 'Organisez une soirée détente avec films, couvertures et snacks',
      category: GestureCategory.romantic,
      pointsValue: 25,
      emoji: '🎬',
      tips: [
        'Choisissez des films qu\'elle aime',
        'Préparez des snacks sains',
        'Créez un nid douillet avec des coussins'
      ],
    ),
    CareGesture(
      id: '5',
      title: 'Faire les courses',
      description: 'Prenez en charge les courses et les tâches ménagères',
      category: GestureCategory.supportive,
      pointsValue: 15,
      emoji: '🛒',
      tips: [
        'Pensez aux produits d\'hygiène féminine',
        'Achetez ses chocolats préférés',
        'N\'oubliez pas les fruits et légumes'
      ],
    ),
    CareGesture(
      id: '6',
      title: 'Bouquet de fleurs',
      description: 'Offrez des fleurs fraîches pour égayer sa journée',
      category: GestureCategory.surprise,
      pointsValue: 20,
      emoji: '💐',
      tips: [
        'Choisissez des fleurs aux couleurs vives',
        'Ajoutez un petit mot doux',
        'Privilégiez ses fleurs préférées'
      ],
    ),
    CareGesture(
      id: '7',
      title: 'Bain relaxant',
      description: 'Préparez un bain chaud avec des sels de bain apaisants',
      category: GestureCategory.caring,
      pointsValue: 15,
      emoji: '🛁',
      tips: [
        'Ajoutez des sels d\'Epsom pour détendre les muscles',
        'Allumez quelques bougies',
        'Mettez de la musique relaxante'
      ],
      requiredCarePoints: 50,
    ),
    CareGesture(
      id: '8',
      title: 'Surprise créative',
      description: 'Créez quelque chose d\'unique : lettre, dessin, playlist personnalisée',
      category: GestureCategory.surprise,
      pointsValue: 30,
      emoji: '🎨',
      tips: [
        'Personnalisez selon ses goûts',
        'Prenez le temps de bien faire',
        'Ajoutez une touche personnelle'
      ],
      requiredCarePoints: 100,
    ),
    CareGesture(
      id: '9',
      title: 'Petit-déjeuner au lit',
      description: 'Préparez et servez un petit-déjeuner spécial au lit',
      category: GestureCategory.romantic,
      pointsValue: 25,
      emoji: '🥐',
      tips: [
        'Incluez ses viennoiseries préférées',
        'Servez dans de la belle vaisselle',
        'Ajoutez une fleur sur le plateau'
      ],
      requiredCarePoints: 75,
    ),
    CareGesture(
      id: '10',
      title: 'Cadeau surprise',
      description: 'Offrez un petit cadeau thoughtful qui montre votre attention',
      category: GestureCategory.surprise,
      pointsValue: 35,
      emoji: '🎁',
      tips: [
        'Ce n\'est pas la valeur qui compte, mais l\'attention',
        'Choisissez quelque chose d\'utile ou de symbolique',
        'Emballez joliment'
      ],
      requiredCarePoints: 150,
    ),
  ];

  // Partner Connection Management
  static Future<Partner?> getConnectedPartner() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final partnerJson = prefs.getString(_partnerKey);
      
      if (partnerJson == null) return null;
      
      return Partner.fromJson(jsonDecode(partnerJson));
    } catch (e) {
      return null;
    }
  }

  static Future<bool> savePartner(Partner partner) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final partnerJson = jsonEncode(partner.toJson());
      return await prefs.setString(_partnerKey, partnerJson);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> disconnectPartner() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_partnerKey);
      await prefs.remove(_connectionKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Connection Code Management
  static Future<String> generateConnectionCode() async {
    final random = Random();
    final code = String.fromCharCodes(
      List.generate(6, (_) => random.nextInt(26) + 65)
    );
    
    final connection = PartnerConnection(
      connectionCode: code,
      userId: 'current_user', // Replace with actual user ID
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
    );
    
    await _saveConnection(connection);
    return code;
  }

  static Future<bool> connectWithCode(String code, String partnerName) async {
    try {
      // Simulate checking if code exists and is valid
      await Future.delayed(const Duration(milliseconds: 800));
      
      if (code.length != 6) return false;
      
      // Create partner
      final partner = Partner(
        id: generateId(),
        name: partnerName,
        connectedAt: DateTime.now(),
        status: PartnershipStatus.connected,
        notificationPreferences: {
          'menstrualPhase': true,
          'mood': true,
          'symptoms': false,
          'appointment': true,
          'reminder': true,
        },
      );
      
      await savePartner(partner);
      
      // Create welcome activity
      await _recordActivity(
        'partner_connected',
        'Votre partenaire $partnerName s\'est connecté',
        10,
      );
      
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _saveConnection(PartnerConnection connection) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final connectionJson = jsonEncode(connection.toJson());
      return await prefs.setString(_connectionKey, connectionJson);
    } catch (e) {
      return false;
    }
  }

  // Notifications Management
  static Future<List<PartnerNotification>> getPartnerNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey);
      
      if (notificationsJson == null) return [];
      
      final notificationsData = jsonDecode(notificationsJson) as List;
      return notificationsData
          .map((data) => PartnerNotification.fromJson(data))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> sendPartnerNotification(PartnerNotification notification) async {
    try {
      final notifications = await getPartnerNotifications();
      notifications.insert(0, notification);
      
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = jsonEncode(
        notifications.map((n) => n.toJson()).toList()
      );
      
      return await prefs.setString(_notificationsKey, notificationsJson);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      final notifications = await getPartnerNotifications();
      final index = notifications.indexWhere((n) => n.id == notificationId);
      
      if (index == -1) return false;
      
      notifications[index] = notifications[index].copyWith(isRead: true);
      
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = jsonEncode(
        notifications.map((n) => n.toJson()).toList()
      );
      
      return await prefs.setString(_notificationsKey, notificationsJson);
    } catch (e) {
      return false;
    }
  }

  // Contextual notifications based on cycle
  static Future<void> sendCycleNotification(String phase, String message) async {
    final partner = await getConnectedPartner();
    if (partner == null || !partner.isConnected) return;
    
    final notification = PartnerNotification(
      id: generateId(),
      userId: 'current_user',
      partnerId: partner.id,
      type: NotificationType.menstrualPhase,
      title: 'Phase du cycle de votre partenaire',
      message: message,
      scheduledAt: DateTime.now(),
      sentAt: DateTime.now(),
      suggestedActions: _getSuggestedActionsForPhase(phase),
    );
    
    await sendPartnerNotification(notification);
  }

  static List<String> _getSuggestedActionsForPhase(String phase) {
    switch (phase.toLowerCase()) {
      case 'menstruation':
        return [
          'Préparer une tisane apaisante',
          'Offrir un massage relaxant',
          'Organiser une soirée cocooning',
        ];
      case 'follicular':
        return [
          'Planifier une sortie ensemble',
          'Préparer son plat préféré',
          'Faire une activité sportive',
        ];
      case 'ovulation':
        return [
          'Organiser un rendez-vous romantique',
          'Offrir des fleurs',
          'Planifier un week-end spécial',
        ];
      case 'luteal':
        return [
          'Être plus patient et compréhensif',
          'Préparer ses snacks préférés',
          'Proposer une activité relaxante',
        ];
      default:
        return [
          'Envoyer un message doux',
          'Planifier quelque chose de spécial',
          'Être attentionné',
        ];
    }
  }

  // Care Gestures Management
  static Future<List<CareGesture>> getCareGestures() async {
    final partner = await getConnectedPartner();
    final carePoints = partner?.carePoints ?? 0;
    
    return _sampleGestures.map((gesture) {
      return gesture.copyWith(
        isUnlocked: carePoints >= gesture.requiredCarePoints,
      );
    }).toList();
  }

  static Future<List<CareGesture>> getRecommendedGestures({String? phase}) async {
    final gestures = await getCareGestures();
    final unlocked = gestures.where((g) => g.isUnlocked).toList();
    
    if (phase == 'menstruation') {
      // Prioritize caring and supportive gestures during menstruation
      return unlocked.where((g) => 
        g.category == GestureCategory.caring || 
        g.category == GestureCategory.supportive
      ).toList();
    }
    
    // Return random mix of unlocked gestures
    unlocked.shuffle();
    return unlocked.take(5).toList();
  }

  static Future<bool> completeGesture(CareGesture gesture) async {
    try {
      final partner = await getConnectedPartner();
      if (partner == null) return false;
      
      // Award points
      final updatedPartner = partner.copyWith(
        carePoints: partner.carePoints + gesture.pointsValue,
        lastActiveAt: DateTime.now(),
      );
      
      await savePartner(updatedPartner);
      
      // Record activity
      await _recordActivity(
        'gesture_completed',
        'A accompli: ${gesture.title}',
        gesture.pointsValue,
        metadata: {'gestureId': gesture.id, 'category': gesture.category.name},
      );
      
      // Check for achievements
      await _checkAndAwardAchievements(updatedPartner.carePoints);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Activities and Points Management
  static Future<List<PartnerActivity>> getPartnerActivities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final activitiesJson = prefs.getString(_activitiesKey);
      
      if (activitiesJson == null) return [];
      
      final activitiesData = jsonDecode(activitiesJson) as List;
      return activitiesData
          .map((data) => PartnerActivity.fromJson(data))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> _recordActivity(
    String action,
    String description,
    int pointsEarned, {
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final activities = await getPartnerActivities();
      
      final activity = PartnerActivity(
        id: generateId(),
        userId: 'current_user',
        action: action,
        description: description,
        pointsEarned: pointsEarned,
        timestamp: DateTime.now(),
        metadata: metadata ?? {},
      );
      
      activities.insert(0, activity);
      
      // Keep only last 100 activities
      if (activities.length > 100) {
        activities.removeRange(100, activities.length);
      }
      
      final prefs = await SharedPreferences.getInstance();
      final activitiesJson = jsonEncode(
        activities.map((a) => a.toJson()).toList()
      );
      
      return await prefs.setString(_activitiesKey, activitiesJson);
    } catch (e) {
      return false;
    }
  }

  static Future<void> _checkAndAwardAchievements(int totalPoints) async {
    final partner = await getConnectedPartner();
    if (partner == null) return;
    
    final achievements = List<String>.from(partner.achievements);
    bool hasNewAchievement = false;
    
    // Check for new achievements
    if (totalPoints >= 50 && !achievements.contains('first_steps')) {
      achievements.add('first_steps');
      hasNewAchievement = true;
      await _sendAchievementNotification('Premiers pas', 'Vous avez gagné vos premiers 50 points d\'attention !');
    }
    
    if (totalPoints >= 200 && !achievements.contains('caring_partner')) {
      achievements.add('caring_partner');
      hasNewAchievement = true;
      await _sendAchievementNotification('Partenaire attentionné', 'Vous êtes maintenant un partenaire attentionné !');
    }
    
    if (totalPoints >= 500 && !achievements.contains('devoted_partner')) {
      achievements.add('devoted_partner');
      hasNewAchievement = true;
      await _sendAchievementNotification('Partenaire dévoué', 'Votre dévouement est remarquable !');
    }
    
    if (totalPoints >= 1000 && !achievements.contains('care_expert')) {
      achievements.add('care_expert');
      hasNewAchievement = true;
      await _sendAchievementNotification('Expert en attention', 'Vous êtes maintenant un expert en attention !');
    }
    
    if (hasNewAchievement) {
      final updatedPartner = partner.copyWith(achievements: achievements);
      await savePartner(updatedPartner);
    }
  }

  static Future<void> _sendAchievementNotification(String title, String message) async {
    final notification = PartnerNotification(
      id: generateId(),
      userId: 'current_user',
      type: NotificationType.achievement,
      title: title,
      message: message,
      scheduledAt: DateTime.now(),
      sentAt: DateTime.now(),
    );
    
    await sendPartnerNotification(notification);
  }

  // Partner Preferences
  static Future<bool> updateNotificationPreferences(Map<String, bool> preferences) async {
    final partner = await getConnectedPartner();
    if (partner == null) return false;
    
    final updatedPartner = partner.copyWith(notificationPreferences: preferences);
    return await savePartner(updatedPartner);
  }

  static Future<bool> pausePartnership() async {
    final partner = await getConnectedPartner();
    if (partner == null) return false;
    
    final updatedPartner = partner.copyWith(status: PartnershipStatus.paused);
    return await savePartner(updatedPartner);
  }

  static Future<bool> resumePartnership() async {
    final partner = await getConnectedPartner();
    if (partner == null) return false;
    
    final updatedPartner = partner.copyWith(status: PartnershipStatus.connected);
    return await savePartner(updatedPartner);
  }

  // Utility methods
  static String generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'partner_${timestamp}_${(timestamp % 10000).toString().padLeft(4, '0')}';
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

  // Sample data for demo
  static Future<void> createSampleData() async {
    // Create sample notifications for demo
    final sampleNotifications = [
      PartnerNotification(
        id: generateId(),
        userId: 'current_user',
        type: NotificationType.menstrualPhase,
        title: 'Phase menstruelle',
        message: 'Votre partenaire est dans sa phase menstruelle. C\'est le moment d\'être plus attentionné.',
        scheduledAt: DateTime.now().subtract(const Duration(hours: 2)),
        sentAt: DateTime.now().subtract(const Duration(hours: 2)),
        suggestedActions: [
          'Préparer une tisane apaisante',
          'Offrir un massage relaxant',
          'Organiser une soirée cocooning',
        ],
      ),
      PartnerNotification(
        id: generateId(),
        userId: 'current_user',
        type: NotificationType.mood,
        title: 'Humeur',
        message: 'Votre partenaire se sent un peu fatiguée aujourd\'hui.',
        scheduledAt: DateTime.now().subtract(const Duration(hours: 6)),
        sentAt: DateTime.now().subtract(const Duration(hours: 6)),
        suggestedActions: [
          'Préparer son plat préféré',
          'Proposer une sieste ensemble',
          'Faire les tâches ménagères',
        ],
      ),
    ];
    
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = jsonEncode(
      sampleNotifications.map((n) => n.toJson()).toList()
    );
    await prefs.setString(_notificationsKey, notificationsJson);
  }
}