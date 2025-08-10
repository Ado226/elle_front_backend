import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../theme/app_theme.dart';
import '../core/models/caring_experience.dart';
import '../services/caring_service.dart';
import '../widgets/caring/daily_surprise_widget.dart';
import '../widgets/caring/level_progress_widget.dart';
import '../widgets/caring/caring_stats_widget.dart';
import '../widgets/caring/surprise_idea_card.dart';

class CaringScreen extends StatefulWidget {
  const CaringScreen({Key? key}) : super(key: key);

  @override
  State<CaringScreen> createState() => _CaringScreenState();
}

class _CaringScreenState extends State<CaringScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late TabController _tabController;
  
  final List<String> _tabs = ['Aujourd\'hui', 'Idées', 'Statistiques'];
  final List<SurpriseIdea> _todaySuggestions = [];
  final List<SurpriseIdea> _allIdeas = [];
  CaringStats _stats = const CaringStats();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadMockData();
    _animationController.forward();
  }

  void _loadMockData() async {
    // Load real data from the service
    final ideas = await CaringService.getSurpriseIdeas(unlockedOnly: true);
    final stats = await CaringService.getCaringStats();
    
    setState(() {
      _stats = stats;
      _todaySuggestions.clear();
      _todaySuggestions.addAll(ideas.take(3));
      _allIdeas.clear();
      _allIdeas.addAll(ideas);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Caring Boyfriend',
          style: AppTheme.headerStyle.copyWith(fontSize: 20),
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
          labelColor: AppTheme.primaryPink,
          unselectedLabelColor: AppTheme.lightGray,
          indicatorColor: AppTheme.primaryPink,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayTab(),
          _buildIdeasTab(),
          _buildStatsTab(),
        ],
      ),
    );
  }

  Widget _buildTodayTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: AnimationLimiter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 375),
            childAnimationBuilder: (widget) => SlideAnimation(
              horizontalOffset: 50.0,
              child: FadeInAnimation(child: widget),
            ),
            children: [
              // Daily surprise widget
              DailySurpriseWidget(
                surprise: _todaySuggestions.isNotEmpty ? _todaySuggestions.first : SurpriseIdea(
                  id: 'default',
                  title: 'Petit message doux',
                  description: 'Envoyez un message d\'encouragement',
                  category: SurpriseCategory.supportive,
                  difficulty: ActionDifficulty.easy,
                  timeRequired: 2,
                  emoji: '💕',
                  carePointsValue: 10,
                ),
                onCompleted: () => _completeIdea(_todaySuggestions.isNotEmpty ? _todaySuggestions.first : null),
              ),
              
              const SizedBox(height: 20),
              
              // Level progress
              LevelProgressWidget(
                stats: _stats,
                onLevelUp: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Félicitations! Nouveau niveau atteint!')),
                  );
                },
                showDetails: true,
              ),
              
              const SizedBox(height: 20),
              
              // Today's suggestions header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Suggestions du jour',
                    style: AppTheme.sectionTitleStyle.copyWith(fontSize: 18),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPink.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Phase menstruelle',
                      style: AppTheme.captionStyle.copyWith(
                        color: AppTheme.primaryPink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Today's suggestions list
              ..._todaySuggestions.map((idea) => SurpriseIdeaCard(
                idea: idea,
                onTap: () => _showIdeaDetail(idea),
                onCompleted: () => _completeIdea(idea),
              )).toList(),
              
              const SizedBox(height: 20),
              
              // Quick actions
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdeasTab() {
    final categories = _allIdeas.map((e) => e.categoryDisplayName).toSet().toList();
    
    return DefaultTabController(
      length: categories.length,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabs: categories.map((category) => Tab(text: category)).toList(),
            labelColor: AppTheme.primaryPink,
            unselectedLabelColor: AppTheme.lightGray,
            indicatorColor: AppTheme.primaryPink,
          ),
          Expanded(
            child: TabBarView(
              children: categories.map((category) {
                final categoryIdeas = _allIdeas.where((idea) => idea.categoryDisplayName == category).toList();
                return AnimationLimiter(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: categoryIdeas.length,
                    itemBuilder: (context, index) {
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: SurpriseIdeaCard(
                              idea: categoryIdeas[index],
                              onTap: () => _showIdeaDetail(categoryIdeas[index]),
                              onCompleted: () => _completeIdea(categoryIdeas[index]),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: AnimationLimiter(
        child: Column(
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 375),
            childAnimationBuilder: (widget) => SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(child: widget),
            ),
            children: [
              CaringStatsWidget(
                stats: _stats,
                onViewDetails: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Affichage des détails des statistiques')),
                  );
                },
              ),
              
              const SizedBox(height: 20),
              
              _buildAchievements(),
              
              const SizedBox(height: 20),
              
              _buildWeeklyProgress(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions rapides',
            style: AppTheme.bodyTextStyle.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickActionButton(
                icon: Icons.favorite,
                label: 'Câlin',
                color: Colors.red,
                onTap: () => _quickAction('Câlin réconfortant'),
              ),
              _buildQuickActionButton(
                icon: Icons.local_florist,
                label: 'Fleurs',
                color: Colors.pink,
                onTap: () => _quickAction('Bouquet de fleurs'),
              ),
              _buildQuickActionButton(
                icon: Icons.coffee,
                label: 'Boisson',
                color: Colors.brown,
                onTap: () => _quickAction('Boisson chaude'),
              ),
              _buildQuickActionButton(
                icon: Icons.message,
                label: 'Message',
                color: Colors.blue,
                onTap: () => _quickAction('Message doux'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTheme.captionStyle.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    final achievements = [
      {'title': 'Première semaine', 'description': 'Complétez 7 jours consécutifs', 'isUnlocked': true},
      {'title': 'Expert en bien-être', 'description': 'Réalisez 20 actions bien-être', 'isUnlocked': true},
      {'title': 'Chef cuisinier', 'description': 'Préparez 10 repas surprises', 'isUnlocked': false},
      {'title': 'Maître du massage', 'description': 'Offrez 15 massages', 'isUnlocked': false},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Succès débloqués',
            style: AppTheme.bodyTextStyle.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...achievements.map((achievement) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  achievement['isUnlocked'] as bool ? Icons.check_circle : Icons.lock,
                  color: achievement['isUnlocked'] as bool ? Colors.green : AppTheme.lightGray,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement['title'] as String,
                        style: AppTheme.captionStyle.copyWith(
                          fontWeight: FontWeight.w600,
                          color: achievement['isUnlocked'] as bool ? AppTheme.darkText : AppTheme.lightGray,
                        ),
                      ),
                      Text(
                        achievement['description'] as String,
                        style: AppTheme.captionStyle.copyWith(
                          color: AppTheme.lightGray,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgress() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progrès cette semaine',
            style: AppTheme.bodyTextStyle.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProgressItem('Lun', true),
              _buildProgressItem('Mar', true),
              _buildProgressItem('Mer', true),
              _buildProgressItem('Jeu', false),
              _buildProgressItem('Ven', false),
              _buildProgressItem('Sam', false),
              _buildProgressItem('Dim', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String day, bool isCompleted) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isCompleted ? AppTheme.primaryPink : AppTheme.lightGray.withOpacity(0.3),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            isCompleted ? Icons.check : Icons.close,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          day,
          style: AppTheme.captionStyle.copyWith(fontSize: 10),
        ),
      ],
    );
  }

  void _showIdeaDetail(SurpriseIdea idea) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SurpriseIdeaDetailSheet(idea: idea),
    );
  }

  void _completeIdea(SurpriseIdea? idea) async {
    if (idea == null) return;
    
    final success = await CaringService.completeAction(idea);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bravo! Vous avez gagné ${idea.carePointsValue} points!'),
          backgroundColor: Colors.green,
        ),
      );
      _loadMockData(); // Reload data
    }
  }

  void _quickAction(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action réalisé! +10 points'),
        backgroundColor: AppTheme.primaryPink,
      ),
    );
  }
}

class SurpriseIdeaDetailSheet extends StatelessWidget {
  final SurpriseIdea idea;

  const SurpriseIdeaDetailSheet({Key? key, required this.idea}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  Row(
                    children: [
                      _buildTag(idea.categoryDisplayName, AppTheme.primaryPink),
                      const SizedBox(width: 8),
                      _buildTag(idea.difficultyDisplayName, Colors.orange),
                      const SizedBox(width: 8),
                      _buildTag(idea.formattedTime, Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(idea.description, style: AppTheme.bodyTextStyle),
                  const SizedBox(height: 20),
                  Text(
                    'Instructions détaillées:',
                    style: AppTheme.bodyTextStyle.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. Préparez l\'espace nécessaire\n'
                    '2. Rassemblez les éléments requis\n'
                    '3. Créez une ambiance appropriée\n'
                    '4. Réalisez l\'action avec attention\n'
                    '5. Observez la réaction et ajustez',
                    style: AppTheme.bodyTextStyle,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPink.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.stars, color: AppTheme.primaryPink),
                        const SizedBox(width: 8),
                        Text(
                          'Vous gagnerez ${idea.carePointsValue} points!',
                          style: AppTheme.bodyTextStyle.copyWith(
                            color: AppTheme.primaryPink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: AppTheme.captionStyle.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}