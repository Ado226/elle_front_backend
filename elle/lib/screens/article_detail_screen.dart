import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../core/models/community.dart';
import '../services/community_service.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Article article;

  const ArticleDetailScreen({Key? key, required this.article}) : super(key: key);

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _floatingController;
  late ScrollController _scrollController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floatingAnimation;
  
  final CommunityService _communityService = CommunityService();
  bool _isBookmarked = false;
  bool _isLiked = false;
  bool _showFloatingButton = false;
  int _currentLikes = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeData();
    _setupScrollListener();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  void _initializeData() {
    _currentLikes = widget.article.likes;
    // In a real app, you'd load the bookmark/like status from a service
  }

  void _setupScrollListener() {
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      final shouldShow = _scrollController.offset > 200;
      if (shouldShow != _showFloatingButton) {
        setState(() {
          _showFloatingButton = shouldShow;
        });
        if (shouldShow) {
          _floatingController.forward();
        } else {
          _floatingController.reverse();
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _floatingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildArticleContent(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _floatingController,
        builder: (context, child) {
          return Transform.scale(
            scale: _floatingAnimation.value,
            child: _showFloatingButton
                ? FloatingActionButton(
                    onPressed: () => _scrollToTop(),
                    backgroundColor: AppTheme.primaryPink,
                    child: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
                  )
                : const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppTheme.primaryPink,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.article.title,
          style: AppTheme.headerStyle.copyWith(
            color: Colors.white,
            fontSize: 16,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryPink,
                AppTheme.primaryPink.withOpacity(0.8),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Background pattern or image placeholder
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink.withOpacity(0.1),
                ),
                child: Icon(
                  _getCategoryIcon(widget.article.categoryDisplayName),
                  size: 120,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: Colors.white,
          ),
          onPressed: _toggleBookmark,
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: _shareArticle,
        ),
      ],
    );
  }

  Widget _buildArticleContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Article metadata
          _buildArticleMetadata(),
          
          const SizedBox(height: 24),
          
          // Article content
          _buildArticleBody(),
          
          const SizedBox(height: 32),
          
          // Interaction buttons
          _buildInteractionSection(),
          
          const SizedBox(height: 32),
          
          // Related articles
          _buildRelatedArticles(),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildArticleMetadata() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  widget.article.categoryDisplayName.toUpperCase(),
                  style: AppTheme.captionStyle.copyWith(
                    color: AppTheme.primaryPink,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: AppTheme.lightGray),
                  const SizedBox(width: 4),
                  Text(
                    widget.article.readingTime,
                    style: AppTheme.captionStyle.copyWith(color: AppTheme.lightGray),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primaryPink,
                child: Text(
                  widget.article.author.displayName[0].toUpperCase(),
                  style: AppTheme.captionStyle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.article.author.displayName,
                    style: AppTheme.bodyTextStyle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Publié le ${_formatDate(widget.article.publishedAt)}',
                    style: AppTheme.captionStyle.copyWith(
                      color: AppTheme.lightGray,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArticleBody() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.article.excerpt,
            style: AppTheme.bodyTextStyle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.article.content,
            style: AppTheme.bodyTextStyle.copyWith(
              height: 1.7,
              fontSize: 15,
            ),
          ),
          
          // Add more content sections as needed
          const SizedBox(height: 24),
          
          _buildContentSection(
            'Points clés à retenir',
            [
              'Toujours consulter un professionnel de santé',
              'Maintenir une hygiène intime appropriée',
              'Écouter votre corps et ses signaux',
              'Ne pas hésiter à poser des questions',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(String title, List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.subHeaderStyle.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 12),
        ...points.map((point) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(top: 8, right: 12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  point,
                  style: AppTheme.bodyTextStyle.copyWith(height: 1.5),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildInteractionSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInteractionButton(
            icon: _isLiked ? Icons.favorite : Icons.favorite_border,
            label: '$_currentLikes',
            color: _isLiked ? Colors.red : AppTheme.lightGray,
            onTap: _toggleLike,
          ),
          _buildInteractionButton(
            icon: Icons.comment_outlined,
            label: 'Commenter',
            color: AppTheme.lightGray,
            onTap: _showCommentDialog,
          ),
          _buildInteractionButton(
            icon: Icons.share_outlined,
            label: 'Partager',
            color: AppTheme.lightGray,
            onTap: _shareArticle,
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.captionStyle.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedArticles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Articles similaires',
          style: AppTheme.subHeaderStyle.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Article connexe ${index + 1}',
                      style: AppTheme.bodyTextStyle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Découvrez plus sur ce sujet...',
                      style: AppTheme.captionStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'santé':
        return Icons.favorite;
      case 'cycle':
        return Icons.calendar_month;
      case 'contraception':
        return Icons.medical_services;
      case 'nutrition':
        return Icons.restaurant;
      default:
        return Icons.article;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isBookmarked ? 'Article ajouté aux favoris' : 'Article retiré des favoris',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _currentLikes += _isLiked ? 1 : -1;
    });
    
    HapticFeedback.lightImpact();
  }

  void _shareArticle() {
    // In a real app, you'd use the share plugin
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité de partage en cours de développement'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajouter un commentaire', style: AppTheme.subHeaderStyle),
        content: TextField(
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Partagez votre avis sur cet article...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: AppTheme.bodyTextStyle),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Commentaire ajouté avec succès!')),
              );
            },
            style: AppTheme.primaryButtonStyle,
            child: Text('Publier', style: AppTheme.buttonTextStyle),
          ),
        ],
      ),
    );
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}