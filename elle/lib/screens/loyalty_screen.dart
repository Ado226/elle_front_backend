import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../core/models/loyalty.dart';
import '../services/loyalty_service.dart';
import '../widgets/loyalty/loyalty_header_widget.dart';
import '../widgets/loyalty/rewards_catalog_widget.dart';
import '../widgets/loyalty/claimed_rewards_widget.dart';
import '../widgets/loyalty/points_history_widget.dart';

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({Key? key}) : super(key: key);

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _staggerController;
  late TabController _tabController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _headerAnimation;

  LoyaltyPoints _loyaltyPoints = LoyaltyPoints(lastUpdated: DateTime.now());
  List<Reward> _featuredRewards = [];
  List<Reward> _allRewards = [];
  List<ClaimedReward> _claimedRewards = [];
  List<PointTransaction> _recentTransactions = [];
  LoyaltyTier _currentTier = LoyaltyService.getLoyaltyTiers().first;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadLoyaltyData();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _tabController = TabController(length: 3, vsync: this);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slideController.forward();
      _fadeController.forward();
      _staggerController.forward();
    });
  }

  Future<void> _loadLoyaltyData() async {
    setState(() => _isLoading = true);
    
    try {
      final [points, featured, all, claimed, transactions] = await Future.wait([
        LoyaltyService.getLoyaltyPoints(),
        LoyaltyService.getFeaturedRewards(),
        LoyaltyService.getRewards(),
        LoyaltyService.getClaimedRewards(),
        LoyaltyService.getPointTransactions(limit: 20),
      ]);

      setState(() {
        _loyaltyPoints = points as LoyaltyPoints;
        _featuredRewards = featured as List<Reward>;
        _allRewards = all as List<Reward>;
        _claimedRewards = claimed as List<ClaimedReward>;
        _recentTransactions = transactions as List<PointTransaction>;
        _currentTier = LoyaltyService.getCurrentTier(_loyaltyPoints.lifetimePoints);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onRewardClaimed() {
    _loadLoyaltyData();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _staggerController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: AnimatedBuilder(
        animation: Listenable.merge([_slideController, _fadeController, _staggerController]),
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildBody(),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.backgroundColor,
      elevation: 0,
      title: AnimatedBuilder(
        animation: _headerAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _headerAnimation.value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - _headerAnimation.value)),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryPink,
                          AppTheme.primaryPink.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.stars,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Programme Fidélité',
                          style: AppTheme.headerStyle.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${_loyaltyPoints.availablePoints} points • ${_currentTier.name}',
                          style: AppTheme.captionStyle.copyWith(
                            fontSize: 12,
                            color: AppTheme.lightGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      actions: [
        IconButton(
          onPressed: () => _showLoyaltyInfo(),
          icon: Icon(
            Icons.info_outline,
            color: AppTheme.primaryPink,
          ),
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: AppTheme.primaryPink,
        labelColor: AppTheme.primaryPink,
        unselectedLabelColor: AppTheme.lightGray,
        labelStyle: AppTheme.bodyTextStyle.copyWith(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Récompenses'),
          Tab(text: 'Mes gains'),
          Tab(text: 'Historique'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      children: [
        // Loyalty header with points and tier info
        LoyaltyHeaderWidget(
          loyaltyPoints: _loyaltyPoints,
          currentTier: _currentTier,
          onTierTapped: () => _showTierDetails(),
        ),

        const SizedBox(height: 8),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              RewardsCatalogWidget(
                featuredRewards: _featuredRewards,
                allRewards: _allRewards,
                availablePoints: _loyaltyPoints.availablePoints,
                onRewardClaimed: _onRewardClaimed,
                onRefresh: _loadLoyaltyData,
              ),
              ClaimedRewardsWidget(
                claimedRewards: _claimedRewards,
                onRefresh: _loadLoyaltyData,
              ),
              PointsHistoryWidget(
                transactions: _recentTransactions,
                loyaltyPoints: _loyaltyPoints,
                onRefresh: _loadLoyaltyData,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLoyaltyInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.stars,
              color: AppTheme.primaryPink,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Programme Fidélité Elle',
              style: AppTheme.subHeaderStyle.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Comment gagner des points ?',
                style: AppTheme.bodyTextStyle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildInfoItem('🛒', 'Achats dans la boutique', '1 pt / 100 XOF'),
              _buildInfoItem('💕', 'Actions caring accomplies', '5-15 pts'),
              _buildInfoItem('👫', 'Interactions partenaire', '5-50 pts'),
              _buildInfoItem('📱', 'Connexion quotidienne', '10 pts'),
              _buildInfoItem('📝', 'Activité communauté', '5-20 pts'),
              _buildInfoItem('📅', 'Suivi de cycle', '10 pts'),
              
              const SizedBox(height: 16),
              
              Text(
                'Avantages par niveau',
                style: AppTheme.bodyTextStyle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...LoyaltyService.getLoyaltyTiers().map((tier) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Text(
                        tier.icon,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${tier.name}: +${((tier.multiplier - 1) * 100).toInt()}% de bonus',
                          style: AppTheme.captionStyle,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Compris',
              style: AppTheme.bodyTextStyle.copyWith(color: AppTheme.primaryPink),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String emoji, String title, String points) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: AppTheme.captionStyle,
            ),
          ),
          Text(
            points,
            style: AppTheme.captionStyle.copyWith(
              color: AppTheme.primaryPink,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showTierDetails() {
    final allTiers = LoyaltyService.getLoyaltyTiers();
    final nextTier = LoyaltyService.getNextTier(_loyaltyPoints.lifetimePoints);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.lightGray.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.workspace_premium,
                      color: AppTheme.primaryPink,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Niveaux de fidélité',
                            style: AppTheme.headerStyle.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Montez de niveau pour plus d\'avantages',
                            style: AppTheme.captionStyle.copyWith(
                              color: AppTheme.lightGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Tiers list
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: allTiers.map((tier) {
                      final isCurrentTier = tier.id == _currentTier.id;
                      final isUnlocked = _loyaltyPoints.lifetimePoints >= tier.pointsRequired;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isCurrentTier 
                              ? Color(int.parse('0xFF${tier.color}')).withOpacity(0.1)
                              : AppTheme.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isCurrentTier 
                                ? Color(int.parse('0xFF${tier.color}')).withOpacity(0.3)
                                : AppTheme.lightGray.withOpacity(0.2),
                            width: isCurrentTier ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isUnlocked 
                                        ? Color(int.parse('0xFF${tier.color}'))
                                        : AppTheme.lightGray.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      tier.icon,
                                      style: TextStyle(fontSize: 24),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            tier.name,
                                            style: AppTheme.subHeaderStyle.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: isUnlocked 
                                                  ? AppTheme.darkText 
                                                  : AppTheme.lightGray,
                                            ),
                                          ),
                                          if (isCurrentTier) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Color(int.parse('0xFF${tier.color}')),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                'Actuel',
                                                style: AppTheme.captionStyle.copyWith(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        tier.description,
                                        style: AppTheme.captionStyle.copyWith(
                                          color: AppTheme.lightGray,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isUnlocked)
                                  Icon(
                                    Icons.check_circle,
                                    color: Color(int.parse('0xFF${tier.color}')),
                                    size: 24,
                                  )
                                else
                                  Icon(
                                    Icons.lock_outline,
                                    color: AppTheme.lightGray,
                                    size: 24,
                                  ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            Text(
                              '${tier.pointsRequired} points requis • Bonus x${tier.multiplier}',
                              style: AppTheme.captionStyle.copyWith(
                                color: Color(int.parse('0xFF${tier.color}')),
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            if (tier.benefits.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              ...tier.benefits.map((benefit) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check,
                                        size: 16,
                                        color: isUnlocked 
                                            ? Color(int.parse('0xFF${tier.color}'))
                                            : AppTheme.lightGray,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          benefit,
                                          style: AppTheme.captionStyle.copyWith(
                                            color: isUnlocked 
                                                ? AppTheme.darkText 
                                                : AppTheme.lightGray,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}