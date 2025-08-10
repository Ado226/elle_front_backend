import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../core/models/caring_experience.dart';
import '../services/caring_service.dart';
import '../widgets/caring/surprise_idea_card.dart';
import '../widgets/caring/caring_stats_widget.dart';
import '../widgets/caring/level_progress_widget.dart';
import '../widgets/caring/daily_surprise_widget.dart';

class CaringExperienceScreen extends StatefulWidget {
  const CaringExperienceScreen({Key? key}) : super(key: key);

  @override
  State<CaringExperienceScreen> createState() => _CaringExperienceScreenState();
}

class _CaringExperienceScreenState extends State<CaringExperienceScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _staggerController;
  late TabController _tabController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _headerAnimation;

  CaringStats _stats = const CaringStats();
  List<SurpriseIdea> _surpriseIdeas = [];
  List<SurpriseIdea> _recommendedIdeas = [];
  SurpriseIdea? _dailySurprise;
  List<CompletedAction> _recentActions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadCaringData();
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

  Future<void> _loadCaringData() async {
    setState(() => _isLoading = true);
    
    try {
      final [stats, ideas, recommended, daily, actions] = await Future.wait([
        CaringService.getCaringStats(),
        CaringService.getSurpriseIdeas(unlockedOnly: true),
        CaringService.getRecommendedIdeas(),
        CaringService.getDailySurprise(),
        CaringService.getCompletedActions(),
      ]);

      setState(() {
        _stats = stats as CaringStats;
        _surpriseIdeas = ideas as List<SurpriseIdea>;
        _recommendedIdeas = recommended as List<SurpriseIdea>;
        _dailySurprise = daily as SurpriseIdea?;
        _recentActions = (actions as List<CompletedAction>).take(10).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onActionCompleted() {
    _loadCaringData();
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
                      Icons.favorite,
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
                          'Expérience Caring',
                          style: AppTheme.headerStyle.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Niveau ${_stats.currentLevel} • ${_stats.totalPoints} points',
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
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: AppTheme.primaryPink,
        labelColor: AppTheme.primaryPink,
        unselectedLabelColor: AppTheme.lightGray,
        labelStyle: AppTheme.bodyTextStyle.copyWith(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Découvrir'),
          Tab(text: 'Mes actions'),
          Tab(text: 'Progression'),
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

    return TabBarView(
      controller: _tabController,
      children: [
        _buildDiscoverTab(),
        _buildActionsTab(),
        _buildProgressTab(),
      ],
    );
  }

  Widget _buildDiscoverTab() {
    return RefreshIndicator(
      onRefresh: _loadCaringData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily surprise
            if (_dailySurprise != null) ...[
              DailySurpriseWidget(
                surprise: _dailySurprise!,
                onCompleted: _onActionCompleted,
              ),
              const SizedBox(height: 24),
            ],

            // Level progress
            LevelProgressWidget(
              stats: _stats,
              onLevelUp: () {
                _loadCaringData();
              },
              showDetails: false,
            ),

            const SizedBox(height: 24),

            // Recommended ideas
            Text(
              'Idées recommandées',
              style: AppTheme.subHeaderStyle.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),

            if (_recommendedIdeas.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.lightGray.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 48,
                      color: AppTheme.lightGray,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Aucune idée disponible',
                      style: AppTheme.bodyTextStyle.copyWith(
                        color: AppTheme.lightGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Accomplissez plus d\'actions pour débloquer de nouvelles idées',
                      style: AppTheme.captionStyle.copyWith(
                        color: AppTheme.lightGray,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recommendedIdeas.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return SurpriseIdeaCard(
                    idea: _recommendedIdeas[index],
                    onTap: () => _showIdeaDetail(_recommendedIdeas[index]),
                    onCompleted: () => _completeIdea(_recommendedIdeas[index]),
                  );
                },
              ),

            const SizedBox(height: 24),

            // All ideas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Toutes les idées',
                  style: AppTheme.subHeaderStyle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: () => _showFilterOptions(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.filter_list,
                        size: 16,
                        color: AppTheme.primaryPink,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Filtrer',
                        style: AppTheme.captionStyle.copyWith(
                          color: AppTheme.primaryPink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _surpriseIdeas.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return SurpriseIdeaCard(
                  idea: _surpriseIdeas[index],
                  onTap: () => _showIdeaDetail(_surpriseIdeas[index]),
                  onCompleted: () => _completeIdea(_surpriseIdeas[index]),
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsTab() {
    return RefreshIndicator(
      onRefresh: _loadCaringData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats summary
            CaringStatsWidget(
              stats: _stats,
              onViewDetails: () => _showDetailedStats(),
            ),

            const SizedBox(height: 24),

            // Recent actions
            Text(
              'Actions récentes',
              style: AppTheme.subHeaderStyle.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),

            if (_recentActions.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.lightGray.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.history,
                      size: 48,
                      color: AppTheme.lightGray,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Aucune action accomplie',
                      style: AppTheme.bodyTextStyle.copyWith(
                        color: AppTheme.lightGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Commencez par accomplir votre première action caring',
                      style: AppTheme.captionStyle.copyWith(
                        color: AppTheme.lightGray,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentActions.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final action = _recentActions[index];
                  return _buildActionItem(action);
                },
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTab() {
    return RefreshIndicator(
      onRefresh: _loadCaringData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current level
            LevelProgressWidget(
              stats: _stats,
              onLevelUp: () {
                _loadCaringData();
              },
              showDetails: true,
            ),

            const SizedBox(height: 24),

            // All levels
            Text(
              'Tous les niveaux',
              style: AppTheme.subHeaderStyle.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),

            ...CaringService.getAllLevels().map((level) {
              final isUnlocked = _stats.currentLevel >= level.level;
              final isCurrent = _stats.currentLevel == level.level;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isCurrent 
                      ? AppTheme.primaryPink.withOpacity(0.1)
                      : AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCurrent 
                        ? AppTheme.primaryPink.withOpacity(0.3)
                        : AppTheme.lightGray.withOpacity(0.2),
                    width: isCurrent ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isUnlocked 
                            ? Color(int.parse('0xFF${level.color}'))
                            : AppTheme.lightGray.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          level.badge,
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
                                'Niveau ${level.level}',
                                style: AppTheme.captionStyle.copyWith(
                                  color: AppTheme.lightGray,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (isCurrent) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryPink,
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
                            level.title,
                            style: AppTheme.bodyTextStyle.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isUnlocked 
                                  ? AppTheme.darkText 
                                  : AppTheme.lightGray,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            level.description,
                            style: AppTheme.captionStyle.copyWith(
                              color: AppTheme.lightGray,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${level.pointsRequired} points requis',
                            style: AppTheme.captionStyle.copyWith(
                              color: AppTheme.primaryPink,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isUnlocked)
                      Icon(
                        Icons.check_circle,
                        color: Color(int.parse('0xFF${level.color}')),
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
              );
            }).toList(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(CompletedAction action) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightGray.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryPink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.favorite,
              color: AppTheme.primaryPink,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action.title,
                  style: AppTheme.bodyTextStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  action.categoryDisplayName,
                  style: AppTheme.captionStyle.copyWith(
                    color: AppTheme.lightGray,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  CaringService.formatTimeAgo(action.completedAt),
                  style: AppTheme.captionStyle.copyWith(
                    color: AppTheme.lightGray,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+${action.pointsEarned}',
                  style: AppTheme.captionStyle.copyWith(
                    color: AppTheme.primaryPink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (action.rating > 0) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    return Icon(
                      index < action.rating ? Icons.star : Icons.star_outline,
                      size: 12,
                      color: Colors.amber,
                    );
                  }),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filtrer les idées',
                  style: AppTheme.subHeaderStyle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Cette fonctionnalité sera bientôt disponible',
                  style: AppTheme.bodyTextStyle.copyWith(
                    color: AppTheme.lightGray,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: AppTheme.primaryButtonStyle,
                    child: Text(
                      'Fermer',
                      style: AppTheme.bodyTextStyle.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetailedStats() async {
    final detailedStats = await CaringService.getDetailedStats();
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Statistiques détaillées',
          style: AppTheme.subHeaderStyle.copyWith(fontWeight: FontWeight.w600),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatItem('Actions totales', '${detailedStats['totalActions']}'),
              _buildStatItem('Points totaux', '${detailedStats['totalPoints']}'),
              _buildStatItem('Niveau actuel', '${detailedStats['currentLevel']}'),
              _buildStatItem('Série actuelle', '${detailedStats['currentStreak']} jour(s)'),
              _buildStatItem('Meilleure série', '${detailedStats['longestStreak']} jour(s)'),
              _buildStatItem('Note moyenne', '${detailedStats['averageRating'].toStringAsFixed(1)}/5'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Fermer',
              style: AppTheme.bodyTextStyle.copyWith(color: AppTheme.primaryPink),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodyTextStyle.copyWith(
              color: AppTheme.lightGray,
            ),
          ),
          Text(
            value,
            style: AppTheme.bodyTextStyle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showIdeaDetail(SurpriseIdea idea) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(idea.title, style: AppTheme.subHeaderStyle),
                    const SizedBox(height: 8),
                    Text(idea.description, style: AppTheme.bodyTextStyle),
                    const SizedBox(height: 16),
                    Text(
                      'Temps requis: ${idea.formattedTime}',
                      style: AppTheme.captionStyle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Points: ${idea.carePointsValue}',
                      style: AppTheme.captionStyle.copyWith(
                        color: AppTheme.primaryPink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _completeIdea(SurpriseIdea idea) async {
    final success = await CaringService.completeAction(idea);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bravo! Vous avez gagné ${idea.carePointsValue} points!'),
          backgroundColor: Colors.green,
        ),
      );
      _onActionCompleted();
    }
  }
}