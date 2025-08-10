import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../core/models/community.dart';
import '../services/community_service.dart';
import '../widgets/community/article_card.dart';
import '../widgets/community/forum_post_card.dart';
import '../widgets/community/expert_spotlight.dart';
import '../widgets/community/category_tabs.dart';
import 'article_detail_screen.dart';
import 'forum_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _staggerController;
  late TabController _tabController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _headerAnimation;

  List<Article> _featuredArticles = [];
  List<Article> _recentArticles = [];
  List<ForumPost> _trendingPosts = [];
  List<CommunityUser> _experts = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadCommunityData();
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

  Future<void> _loadCommunityData() async {
    setState(() => _isLoading = true);
    
    try {
      final [featuredArticles, recentArticles, trendingPosts, experts] = await Future.wait([
        CommunityService.getFeaturedArticles(),
        CommunityService.getArticles(),
        CommunityService.getForumPosts(),
        CommunityService.getExperts(),
      ]);

      setState(() {
        _featuredArticles = featuredArticles as List<Article>;
        _recentArticles = (recentArticles as List<Article>).take(5).toList();
        _trendingPosts = (trendingPosts as List<ForumPost>).take(3).toList();
        _experts = experts as List<CommunityUser>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    // In a real app, you would debounce this search
  }

  void _navigateToArticle(Article article) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ArticleDetailScreen(article: article),
      ),
    );
  }

  void _navigateToForum() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ForumScreen(),
      ),
    );
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
                      color: AppTheme.primaryPink.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.people_outline,
                      color: AppTheme.primaryPink,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Communauté',
                          style: AppTheme.headerStyle.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Articles & Forum',
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
          onPressed: () {},
          icon: Icon(
            Icons.search,
            color: AppTheme.primaryPink,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.notifications_none,
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
          Tab(text: 'Accueil'),
          Tab(text: 'Articles'),
          Tab(text: 'Forum'),
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
        _buildHomeTab(),
        _buildArticlesTab(),
        _buildForumTab(),
      ],
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Expert spotlight
          if (_experts.isNotEmpty) ...[
            Text(
              'Nos Experts',
              style: AppTheme.subHeaderStyle.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _experts.length,
                itemBuilder: (context, index) {
                  return ExpertSpotlight(
                    expert: _experts[index],
                    animationDelay: Duration(milliseconds: index * 150),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Featured articles
          if (_featuredArticles.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Articles à la Une',
                  style: AppTheme.subHeaderStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () => _tabController.animateTo(1),
                  child: Text(
                    'Voir tout',
                    style: AppTheme.captionStyle.copyWith(
                      color: AppTheme.primaryPink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _featuredArticles.length,
                itemBuilder: (context, index) {
                  return ArticleCard(
                    article: _featuredArticles[index],
                    onTap: () => _navigateToArticle(_featuredArticles[index]),
                    animationDelay: Duration(milliseconds: index * 100),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Trending forum posts
          if (_trendingPosts.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Discussions Populaires',
                  style: AppTheme.subHeaderStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: _navigateToForum,
                  child: Text(
                    'Voir tout',
                    style: AppTheme.captionStyle.copyWith(
                      color: AppTheme.primaryPink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._trendingPosts.map((post) => ForumPostCard(
              post: post,
              onTap: () => _navigateToForum(),
              animationDelay: Duration(milliseconds: _trendingPosts.indexOf(post) * 100),
            )),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildArticlesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: AppTheme.lightGray,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Rechercher des articles...',
                      border: InputBorder.none,
                      hintStyle: AppTheme.captionStyle.copyWith(
                        color: AppTheme.lightGray,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Category filter
          CategoryTabs(
            categories: ForumCategory.values,
            selectedCategory: _selectedCategory,
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category;
              });
            },
          ),

          const SizedBox(height: 16),

          // Articles list
          Text(
            'Tous les Articles',
            style: AppTheme.subHeaderStyle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentArticles.length,
            itemBuilder: (context, index) {
              return ArticleCard(
                article: _recentArticles[index],
                onTap: () => _navigateToArticle(_recentArticles[index]),
                animationDelay: Duration(milliseconds: index * 100),
                isHorizontal: false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildForumTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.add, size: 20),
                  label: Text(
                    'Nouvelle discussion',
                    style: AppTheme.captionStyle.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: AppTheme.primaryButtonStyle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.help_outline, size: 20),
                  label: Text(
                    'Question Expert',
                    style: AppTheme.captionStyle.copyWith(
                      color: AppTheme.primaryPink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.primaryPink),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Forum categories
          Text(
            'Catégories',
            style: AppTheme.subHeaderStyle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: ForumCategory.values.length,
            itemBuilder: (context, index) {
              final category = ForumCategory.values[index];
              return _buildCategoryCard(category);
            },
          ),

          const SizedBox(height: 24),

          // Recent discussions
          Text(
            'Discussions Récentes',
            style: AppTheme.subHeaderStyle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _trendingPosts.length,
            itemBuilder: (context, index) {
              return ForumPostCard(
                post: _trendingPosts[index],
                onTap: _navigateToForum,
                animationDelay: Duration(milliseconds: index * 100),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(ForumCategory category) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryPink.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Text(
            _getCategoryEmoji(category),
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getCategoryName(category),
              style: AppTheme.captionStyle.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryEmoji(ForumCategory category) {
    switch (category) {
      case ForumCategory.general:
        return '💬';
      case ForumCategory.health:
        return '🏥';
      case ForumCategory.relationships:
        return '👫';
      case ForumCategory.pregnancy:
        return '🤱';
      case ForumCategory.menstruation:
        return '🩸';
      case ForumCategory.support:
        return '🤗';
      case ForumCategory.tips:
        return '💡';
      default:
        return '❓';
    }
  }

  String _getCategoryName(ForumCategory category) {
    switch (category) {
      case ForumCategory.general:
        return 'Général';
      case ForumCategory.health:
        return 'Santé';
      case ForumCategory.relationships:
        return 'Relations';
      case ForumCategory.pregnancy:
        return 'Grossesse';
      case ForumCategory.menstruation:
        return 'Menstruation';
      case ForumCategory.support:
        return 'Soutien';
      case ForumCategory.tips:
        return 'Conseils';
      default:
        return 'Autre';
    }
  }
}