import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/models/loyalty.dart';

class LoyaltyService {
  static const String _loyaltyPointsKey = 'loyalty_points';
  static const String _rewardsKey = 'available_rewards';
  static const String _claimedRewardsKey = 'claimed_rewards';
  static const String _transactionsKey = 'point_transactions';
  static const String _tiersKey = 'loyalty_tiers';

  // Loyalty tiers configuration
  static final List<LoyaltyTier> _loyaltyTiers = [
    LoyaltyTier(
      id: 'bronze',
      name: 'Bronze',
      description: 'Bienvenue dans le programme Elle',
      pointsRequired: 0,
      multiplier: 1.0,
      benefits: [
        'Points de base sur tous les achats',
        'Accès aux récompenses standards',
        'Notifications sur les nouvelles récompenses',
      ],
      color: 'CD7F32',
      icon: '🥉',
    ),
    LoyaltyTier(
      id: 'silver',
      name: 'Argent',
      description: 'Membre appréciée de la communauté Elle',
      pointsRequired: 500,
      multiplier: 1.2,
      benefits: [
        'Bonus de 20% sur tous les points',
        'Accès aux récompenses exclusives Argent',
        'Livraison gratuite prioritaire',
        'Support client prioritaire',
      ],
      color: 'C0C0C0',
      icon: '🥈',
    ),
    LoyaltyTier(
      id: 'gold',
      name: 'Or',
      description: 'Ambassadrice privilégiée Elle',
      pointsRequired: 1500,
      multiplier: 1.5,
      benefits: [
        'Bonus de 50% sur tous les points',
        'Accès aux récompenses exclusives Or',
        'Livraison gratuite express',
        'Consultation gratuite avec nos experts',
        'Cadeaux d\'anniversaire personnalisés',
      ],
      color: 'FFD700',
      icon: '🥇',
    ),
    LoyaltyTier(
      id: 'diamond',
      name: 'Diamant',
      description: 'VIP exclusive de la famille Elle',
      pointsRequired: 3000,
      multiplier: 2.0,
      benefits: [
        'Double points sur tous les achats',
        'Accès aux récompenses ultra-exclusives',
        'Livraison gratuite en 24h',
        'Consultations illimitées avec nos experts',
        'Invitations aux événements VIP',
        'Box surprise trimestrielle',
        'Programme de parrainage premium',
      ],
      color: 'B9F2FF',
      icon: '💎',
    ),
  ];

  // Sample rewards catalog
  static final List<Reward> _sampleRewards = [
    // Health category
    Reward(
      id: 'reward_1',
      title: 'Consultation gratuite sage-femme',
      description: 'Consultation de 30 minutes avec une sage-femme certifiée',
      detailedDescription: 'Profitez d\'une consultation complète avec l\'une de nos sages-femmes partenaires. Idéal pour toutes vos questions sur la santé reproductive et le bien-être féminin.',
      category: RewardCategory.health,
      type: RewardType.experience,
      pointsCost: 250,
      imageUrl: 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56',
      images: [
        'https://images.unsplash.com/photo-1559757148-5c350d0d3c56',
        'https://images.unsplash.com/photo-1576091160399-112ba8d25d1f',
      ],
      expiryDate: DateTime.now().add(const Duration(days: 90)),
      quantityAvailable: 10,
      partnerName: 'Clinique Santé Femme',
      partnerLogo: 'https://via.placeholder.com/100x100',
      terms: [
        'Valable dans nos cliniques partenaires à Abidjan',
        'Réservation obligatoire 48h à l\'avance',
        'Non échangeable contre espèces',
        'Valable 3 mois après réclamation',
      ],
      createdAt: DateTime.now(),
      isFeatured: true,
    ),
    
    Reward(
      id: 'reward_2',
      title: '20% de réduction sur produits bio',
      description: 'Réduction sur tous les produits d\'hygiène bio',
      detailedDescription: 'Bénéficiez de 20% de réduction sur notre gamme complète de produits d\'hygiène féminine biologiques et naturels.',
      category: RewardCategory.health,
      type: RewardType.discount,
      pointsCost: 150,
      imageUrl: 'https://images.unsplash.com/photo-1556228720-195a672e8a03',
      discountPercentage: 20.0,
      promoCode: 'BIO20',
      expiryDate: DateTime.now().add(const Duration(days: 30)),
      terms: [
        'Valable sur tous les produits bio de la boutique',
        'Non cumulable avec d\'autres offres',
        'Code à utiliser lors du checkout',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      popularityScore: 85,
    ),

    // Beauty category
    Reward(
      id: 'reward_3',
      title: 'Kit beauté Elle exclusive',
      description: 'Kit de soins visage et corps spécialement conçu',
      detailedDescription: 'Un kit beauté complet incluant : nettoyant visage, crème hydratante, masque purifiant, et huile corporelle. Tous les produits sont adaptés aux peaux africaines.',
      category: RewardCategory.beauty,
      type: RewardType.freeProduct,
      pointsCost: 400,
      imageUrl: 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9',
      quantityAvailable: 25,
      quantityLimit: 1,
      partnerName: 'Elle Beauty',
      terms: [
        'Un kit par personne',
        'Livraison incluse',
        'Produits adaptés aux peaux africaines',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      isFeatured: true,
      isExclusive: true,
    ),

    Reward(
      id: 'reward_4',
      title: 'Séance maquillage professionnelle',
      description: 'Séance de maquillage avec une maquilleuse professionnelle',
      detailedDescription: 'Apprenez les techniques de maquillage adaptées à votre teint et morphologie avec nos maquilleuses expertes.',
      category: RewardCategory.beauty,
      type: RewardType.experience,
      pointsCost: 300,
      imageUrl: 'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2',
      quantityAvailable: 15,
      partnerName: 'Studio Beauty Pro',
      expiryDate: DateTime.now().add(const Duration(days: 60)),
      terms: [
        'Durée : 1h30',
        'Produits inclus',
        'Photos avant/après offertes',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),

    // Wellness category
    Reward(
      id: 'reward_5',
      title: 'Séance de yoga spécial cycle',
      description: 'Cours de yoga adapté aux différentes phases du cycle',
      detailedDescription: 'Découvrez des postures et techniques de respiration spécialement conçues pour accompagner votre cycle menstruel et soulager les inconforts.',
      category: RewardCategory.wellness,
      type: RewardType.experience,
      pointsCost: 180,
      imageUrl: 'https://images.unsplash.com/photo-1506629905607-d86b83b5187f',
      quantityAvailable: 20,
      partnerName: 'Yoga & Bien-être',
      expiryDate: DateTime.now().add(const Duration(days: 45)),
      terms: [
        'Cours collectif ou individuel',
        'Tapis fourni',
        'Réservation en ligne',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      popularityScore: 92,
    ),

    Reward(
      id: 'reward_6',
      title: 'Massage relaxant aux huiles',
      description: 'Massage de 60 minutes aux huiles essentielles',
      detailedDescription: 'Massage complet du corps aux huiles essentielles naturelles pour détendre et apaiser les tensions liées aux fluctuations hormonales.',
      category: RewardCategory.wellness,
      type: RewardType.experience,
      pointsCost: 350,
      imageUrl: 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874',
      quantityAvailable: 12,
      partnerName: 'Spa Relaxation',
      expiryDate: DateTime.now().add(const Duration(days: 120)),
      terms: [
        'Durée : 60 minutes',
        'Huiles bio incluses',
        'Environnement zen garanti',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      isExclusive: true,
    ),

    // Shopping category
    Reward(
      id: 'reward_7',
      title: '500 XOF de cashback',
      description: 'Cashback sur votre prochain achat',
      detailedDescription: 'Recevez 500 XOF de cashback utilisable sur tous vos achats dans la boutique Elle.',
      category: RewardCategory.shopping,
      type: RewardType.cashback,
      pointsCost: 100,
      imageUrl: 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d',
      discountAmount: 500,
      expiryDate: DateTime.now().add(const Duration(days: 60)),
      terms: [
        'Utilisable sur tous les produits',
        'Minimum d\'achat : 2000 XOF',
        'Non échangeable contre espèces',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      popularityScore: 78,
    ),

    Reward(
      id: 'reward_8',
      title: 'Livraison gratuite à vie',
      description: 'Plus jamais de frais de livraison !',
      detailedDescription: 'Bénéficiez de la livraison gratuite sur tous vos achats futurs, sans minimum de commande.',
      category: RewardCategory.shopping,
      type: RewardType.exclusive,
      pointsCost: 800,
      imageUrl: 'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13',
      quantityAvailable: 50,
      quantityLimit: 1,
      terms: [
        'Valable à vie sur votre compte',
        'Toutes zones de livraison',
        'Non transférable',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      isFeatured: true,
      isExclusive: true,
      popularityScore: 95,
    ),

    // Digital category
    Reward(
      id: 'reward_9',
      title: 'E-book "Cycle & Nutrition"',
      description: 'Guide complet nutrition selon votre cycle',
      detailedDescription: 'E-book de 50 pages avec conseils nutritionnels, recettes et plans de repas adaptés à chaque phase du cycle menstruel.',
      category: RewardCategory.digital,
      type: RewardType.digitalContent,
      pointsCost: 80,
      imageUrl: 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570',
      terms: [
        'Format PDF téléchargeable',
        'Accès immédiat après réclamation',
        'Compatible tous appareils',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      popularityScore: 88,
    ),

    // Charity category
    Reward(
      id: 'reward_10',
      title: 'Don pour l\'éducation des filles',
      description: 'Financez la scolarité d\'une jeune fille',
      detailedDescription: 'Votre don permettra de financer un mois de scolarité pour une jeune fille dans le besoin, incluant fournitures et uniforme.',
      category: RewardCategory.charity,
      type: RewardType.donation,
      pointsCost: 200,
      imageUrl: 'https://images.unsplash.com/photo-1497486751825-1233686d5d80',
      partnerName: 'Fondation Éducation Filles',
      terms: [
        'Don versé directement à la fondation',
        'Certificat de don délivré',
        'Suivi de l\'impact inclus',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
      isExclusive: true,
      popularityScore: 70,
    ),
  ];

  // Get current loyalty points
  static Future<LoyaltyPoints> getLoyaltyPoints() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pointsJson = prefs.getString(_loyaltyPointsKey);
      
      if (pointsJson == null) {
        return LoyaltyPoints(lastUpdated: DateTime.now());
      }
      
      return LoyaltyPoints.fromJson(jsonDecode(pointsJson));
    } catch (e) {
      return LoyaltyPoints(lastUpdated: DateTime.now());
    }
  }

  static Future<bool> updateLoyaltyPoints(LoyaltyPoints points) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pointsJson = jsonEncode(points.toJson());
      return await prefs.setString(_loyaltyPointsKey, pointsJson);
    } catch (e) {
      return false;
    }
  }

  // Award points for various actions
  static Future<bool> awardPoints(
    PointSource source,
    int basePoints,
    String description, {
    Map<String, dynamic>? metadata,
    String? referenceId,
  }) async {
    try {
      final currentPoints = await getLoyaltyPoints();
      final currentTier = getCurrentTier(currentPoints.lifetimePoints);
      final multipliedPoints = (basePoints * currentTier.multiplier).round();
      
      // Create transaction
      final transaction = PointTransaction(
        id: generateId(),
        source: source,
        points: multipliedPoints,
        description: description,
        timestamp: DateTime.now(),
        metadata: metadata ?? {},
        referenceId: referenceId,
      );
      
      // Record transaction
      await _recordTransaction(transaction);
      
      // Update points
      final newPointsBySource = Map<PointSource, int>.from(currentPoints.pointsBySource);
      newPointsBySource[source] = (newPointsBySource[source] ?? 0) + multipliedPoints;
      
      final updatedPoints = currentPoints.copyWith(
        totalPoints: currentPoints.totalPoints + multipliedPoints,
        availablePoints: currentPoints.availablePoints + multipliedPoints,
        lifetimePoints: currentPoints.lifetimePoints + multipliedPoints,
        lastUpdated: DateTime.now(),
        pointsBySource: newPointsBySource,
      );
      
      await updateLoyaltyPoints(updatedPoints);
      
      // Check for tier upgrade
      await _checkTierUpgrade(currentPoints.lifetimePoints, updatedPoints.lifetimePoints);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Spend points for rewards
  static Future<bool> spendPoints(int points, String description, {String? referenceId}) async {
    try {
      final currentPoints = await getLoyaltyPoints();
      
      if (currentPoints.availablePoints < points) {
        return false; // Insufficient points
      }
      
      // Create transaction
      final transaction = PointTransaction(
        id: generateId(),
        source: PointSource.purchase, // Generic for spending
        points: -points,
        description: description,
        timestamp: DateTime.now(),
        referenceId: referenceId,
      );
      
      // Record transaction
      await _recordTransaction(transaction);
      
      // Update points
      final updatedPoints = currentPoints.copyWith(
        totalPoints: currentPoints.totalPoints - points,
        availablePoints: currentPoints.availablePoints - points,
        lastUpdated: DateTime.now(),
      );
      
      await updateLoyaltyPoints(updatedPoints);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get available rewards
  static Future<List<Reward>> getRewards({
    RewardCategory? category,
    RewardType? type,
    bool? isFeatured,
    bool? isExclusive,
    int? maxPoints,
  }) async {
    var rewards = List<Reward>.from(_sampleRewards);
    
    // Apply filters
    if (category != null) {
      rewards = rewards.where((r) => r.category == category).toList();
    }
    
    if (type != null) {
      rewards = rewards.where((r) => r.type == type).toList();
    }
    
    if (isFeatured == true) {
      rewards = rewards.where((r) => r.isFeatured).toList();
    }
    
    if (isExclusive == true) {
      rewards = rewards.where((r) => r.isExclusive).toList();
    }
    
    if (maxPoints != null) {
      rewards = rewards.where((r) => r.pointsCost <= maxPoints).toList();
    }
    
    // Filter out expired or out of stock
    rewards = rewards.where((r) => 
      r.isAvailable && !r.isExpired && !r.isOutOfStock
    ).toList();
    
    // Sort by popularity and featured status
    rewards.sort((a, b) {
      if (a.isFeatured && !b.isFeatured) return -1;
      if (!a.isFeatured && b.isFeatured) return 1;
      return b.popularityScore.compareTo(a.popularityScore);
    });
    
    return rewards;
  }

  static Future<List<Reward>> getFeaturedRewards() async {
    return await getRewards(isFeatured: true);
  }

  static Future<List<Reward>> getRewardsByCategory(RewardCategory category) async {
    return await getRewards(category: category);
  }

  static Future<List<Reward>> getAffordableRewards() async {
    final points = await getLoyaltyPoints();
    return await getRewards(maxPoints: points.availablePoints);
  }

  // Claim reward
  static Future<ClaimedReward?> claimReward(Reward reward) async {
    try {
      final currentPoints = await getLoyaltyPoints();
      
      if (currentPoints.availablePoints < reward.pointsCost) {
        return null; // Insufficient points
      }
      
      if (!reward.isAvailable || reward.isExpired || reward.isOutOfStock) {
        return null; // Reward not available
      }
      
      // Spend points
      final spendSuccess = await spendPoints(
        reward.pointsCost,
        'Réclamation: ${reward.title}',
        referenceId: reward.id,
      );
      
      if (!spendSuccess) return null;
      
      // Create claimed reward
      final claimedReward = ClaimedReward(
        id: generateId(),
        rewardId: reward.id,
        rewardTitle: reward.title,
        rewardType: reward.type,
        pointsUsed: reward.pointsCost,
        claimedAt: DateTime.now(),
        expiryDate: reward.expiryDate,
        promoCode: reward.promoCode ?? _generatePromoCode(),
        qrCode: _generateQRCode(),
        metadata: {
          'partnerName': reward.partnerName,
          'originalPointsCost': reward.pointsCost,
        },
      );
      
      // Save claimed reward
      await _saveClaimedReward(claimedReward);
      
      // Update reward quantity if applicable
      await _updateRewardQuantity(reward.id);
      
      return claimedReward;
    } catch (e) {
      return null;
    }
  }

  // Get claimed rewards
  static Future<List<ClaimedReward>> getClaimedRewards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final claimedJson = prefs.getString(_claimedRewardsKey);
      
      if (claimedJson == null) return [];
      
      final claimedData = jsonDecode(claimedJson) as List;
      return claimedData
          .map((data) => ClaimedReward.fromJson(data))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<ClaimedReward>> getActiveClaimedRewards() async {
    final claimed = await getClaimedRewards();
    return claimed.where((r) => r.isActive).toList();
  }

  // Get point transactions
  static Future<List<PointTransaction>> getPointTransactions({int? limit}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transactionsJson = prefs.getString(_transactionsKey);
      
      if (transactionsJson == null) return [];
      
      final transactionsData = jsonDecode(transactionsJson) as List;
      var transactions = transactionsData
          .map((data) => PointTransaction.fromJson(data))
          .toList();
      
      // Sort by timestamp (newest first)
      transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      if (limit != null && transactions.length > limit) {
        transactions = transactions.take(limit).toList();
      }
      
      return transactions;
    } catch (e) {
      return [];
    }
  }

  // Loyalty tiers
  static List<LoyaltyTier> getLoyaltyTiers() {
    return _loyaltyTiers;
  }

  static LoyaltyTier getCurrentTier(int lifetimePoints) {
    for (int i = _loyaltyTiers.length - 1; i >= 0; i--) {
      if (lifetimePoints >= _loyaltyTiers[i].pointsRequired) {
        return _loyaltyTiers[i];
      }
    }
    return _loyaltyTiers.first;
  }

  static LoyaltyTier? getNextTier(int lifetimePoints) {
    final currentTier = getCurrentTier(lifetimePoints);
    final currentIndex = _loyaltyTiers.indexOf(currentTier);
    
    if (currentIndex < _loyaltyTiers.length - 1) {
      return _loyaltyTiers[currentIndex + 1];
    }
    
    return null; // Already at highest tier
  }

  static double getTierProgress(int lifetimePoints) {
    final currentTier = getCurrentTier(lifetimePoints);
    final nextTier = getNextTier(lifetimePoints);
    
    if (nextTier == null) return 1.0; // Max tier reached
    
    final pointsInCurrentTier = lifetimePoints - currentTier.pointsRequired;
    final pointsNeededForNextTier = nextTier.pointsRequired - currentTier.pointsRequired;
    
    return pointsInCurrentTier / pointsNeededForNextTier;
  }

  // Statistics
  static Future<Map<String, dynamic>> getLoyaltyStats() async {
    final points = await getLoyaltyPoints();
    final transactions = await getPointTransactions();
    final claimedRewards = await getClaimedRewards();
    final currentTier = getCurrentTier(points.lifetimePoints);
    
    // Calculate earned vs spent
    int totalEarned = 0;
    int totalSpent = 0;
    
    for (final transaction in transactions) {
      if (transaction.isEarned) {
        totalEarned += transaction.points;
      } else {
        totalSpent += transaction.points.abs();
      }
    }
    
    // Most active point source
    PointSource? topSource;
    int maxSourcePoints = 0;
    
    for (final entry in points.pointsBySource.entries) {
      if (entry.value > maxSourcePoints) {
        maxSourcePoints = entry.value;
        topSource = entry.key;
      }
    }
    
    return {
      'currentPoints': points.availablePoints,
      'lifetimePoints': points.lifetimePoints,
      'totalEarned': totalEarned,
      'totalSpent': totalSpent,
      'rewardsClaimed': claimedRewards.length,
      'currentTier': currentTier.name,
      'tierProgress': getTierProgress(points.lifetimePoints),
      'topPointSource': topSource?.sourceDisplayName,
      'topSourcePoints': maxSourcePoints,
      'transactionCount': transactions.length,
    };
  }

  // Integration with other modules
  static Future<void> integratePurchase(String orderId, double amount) async {
    final points = (amount / 100).floor(); // 1 point per 100 XOF
    await awardPoints(
      PointSource.purchase,
      points,
      'Achat commande #${orderId.substring(0, 8)}',
      metadata: {'orderId': orderId, 'amount': amount},
      referenceId: orderId,
    );
  }

  static Future<void> integrateCaringAction(String actionId, String actionTitle, int carePoints) async {
    final loyaltyPoints = (carePoints * 0.5).floor(); // Convert caring points to loyalty points
    await awardPoints(
      PointSource.caringAction,
      loyaltyPoints,
      'Action caring: $actionTitle',
      metadata: {'actionId': actionId, 'carePoints': carePoints},
      referenceId: actionId,
    );
  }

  static Future<void> integratePartnerInteraction(String interactionType) async {
    int points = 0;
    String description = '';
    
    switch (interactionType) {
      case 'connection':
        points = 50;
        description = 'Connexion partenaire réussie';
        break;
      case 'gesture_completed':
        points = 10;
        description = 'Geste d\'attention accompli';
        break;
      case 'notification_sent':
        points = 5;
        description = 'Notification envoyée au partenaire';
        break;
    }
    
    if (points > 0) {
      await awardPoints(
        PointSource.partnerInteraction,
        points,
        description,
        metadata: {'interactionType': interactionType},
      );
    }
  }

  static Future<void> integrateDailyLogin() async {
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    // Check if already awarded today
    final prefs = await SharedPreferences.getInstance();
    final lastLoginDate = prefs.getString('last_login_points_date');
    
    if (lastLoginDate != dateKey) {
      await awardPoints(
        PointSource.dailyLogin,
        10,
        'Connexion quotidienne',
        metadata: {'date': dateKey},
      );
      
      await prefs.setString('last_login_points_date', dateKey);
    }
  }

  // Private helper methods
  static Future<bool> _recordTransaction(PointTransaction transaction) async {
    try {
      final transactions = await getPointTransactions();
      transactions.insert(0, transaction);
      
      // Keep only last 200 transactions
      if (transactions.length > 200) {
        transactions.removeRange(200, transactions.length);
      }
      
      final prefs = await SharedPreferences.getInstance();
      final transactionsJson = jsonEncode(
        transactions.map((t) => t.toJson()).toList()
      );
      
      return await prefs.setString(_transactionsKey, transactionsJson);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _saveClaimedReward(ClaimedReward reward) async {
    try {
      final claimed = await getClaimedRewards();
      claimed.insert(0, reward);
      
      final prefs = await SharedPreferences.getInstance();
      final claimedJson = jsonEncode(
        claimed.map((r) => r.toJson()).toList()
      );
      
      return await prefs.setString(_claimedRewardsKey, claimedJson);
    } catch (e) {
      return false;
    }
  }

  static Future<void> _updateRewardQuantity(String rewardId) async {
    // In a real app, this would update the backend
    // For now, we'll just simulate updating local quantity
  }

  static Future<void> _checkTierUpgrade(int oldPoints, int newPoints) async {
    final oldTier = getCurrentTier(oldPoints);
    final newTier = getCurrentTier(newPoints);
    
    if (oldTier.id != newTier.id) {
      // Tier upgraded! You could trigger a notification or celebration here
      await awardPoints(
        PointSource.profileCompletion,
        50,
        'Bonus de passage niveau ${newTier.name}',
        metadata: {'oldTier': oldTier.id, 'newTier': newTier.id},
      );
    }
  }

  static String _generatePromoCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(8, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
    );
  }

  static String _generateQRCode() {
    // In a real app, this would generate a proper QR code
    return 'ELLE_${DateTime.now().millisecondsSinceEpoch}';
  }

  static String generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'loyalty_${timestamp}_${(timestamp % 10000).toString().padLeft(4, '0')}';
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

  // Sample data creation for demo
  static Future<void> createSampleData() async {
    // Award some initial points for demonstration
    await awardPoints(
      PointSource.profileCompletion,
      100,
      'Profil complété à 100%',
    );
    
    await awardPoints(
      PointSource.dailyLogin,
      10,
      'Première connexion',
    );
    
    await awardPoints(
      PointSource.cycleTracking,
      50,
      'Premier cycle enregistré',
    );
  }
}