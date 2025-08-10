import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../core/models/community.dart';
import '../../services/community_service.dart';

class ArticleCard extends StatefulWidget {
  final Article article;
  final VoidCallback onTap;
  final Duration animationDelay;
  final bool isHorizontal;

  const ArticleCard({
    Key? key,
    required this.article,
    required this.onTap,
    this.animationDelay = Duration.zero,
    this.isHorizontal = true,
  }) : super(key: key);

  @override
  State<ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends State<ArticleCard>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _likeController;
  late AnimationController _bookmarkController;
  late AnimationController _tapController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _likeAnimation;
  late Animation<double> _bookmarkAnimation;
  late Animation<double> _tapAnimation;

  bool _isLiked = false;
  bool _isBookmarked = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkInteractionStatus();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _likeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _bookmarkController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _tapController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    _likeAnimation = Tween<double>(
      begin: 0.8,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _likeController,
      curve: Curves.elasticOut,
    ));

    _bookmarkAnimation = Tween<double>(
      begin: 0.8,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _bookmarkController,
      curve: Curves.elasticOut,
    ));

    _tapAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _tapController,
      curve: Curves.easeInOut,
    ));

    // Start animation with delay
    Future.delayed(widget.animationDelay, () {
      if (mounted) _controller.forward();
    });
  }

  Future<void> _checkInteractionStatus() async {
    final [isLiked, isBookmarked] = await Future.wait([
      CommunityService.isArticleLiked(widget.article.id),
      CommunityService.isArticleBookmarked(widget.article.id),
    ]);

    if (mounted) {
      setState(() {
        _isLiked = isLiked;
        _isBookmarked = isBookmarked;
      });
    }
  }

  Future<void> _toggleLike() async {
    setState(() => _isLoading = true);
    
    final success = await CommunityService.toggleArticleLike(widget.article.id);
    
    if (success) {
      setState(() => _isLiked = !_isLiked);
      _likeController.forward().then((_) {
        _likeController.reverse();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isLiked ? 'Article ajouté aux favoris' : 'Article retiré des favoris'),
            backgroundColor: AppTheme.primaryPink,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _toggleBookmark() async {
    setState(() => _isLoading = true);
    
    final success = await CommunityService.toggleArticleBookmark(widget.article.id);
    
    if (success) {
      setState(() => _isBookmarked = !_isBookmarked);
      _bookmarkController.forward().then((_) {
        _bookmarkController.reverse();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isBookmarked ? 'Article sauvegardé' : 'Article retiré des sauvegardes'),
            backgroundColor: AppTheme.primaryPink,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
    
    setState(() => _isLoading = false);
  }

  void _onTapDown() {
    _tapController.forward();
  }

  void _onTapUp() {
    _tapController.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _tapController.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    _likeController.dispose();
    _bookmarkController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _likeController, _bookmarkController, _tapController]),
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value * _tapAnimation.value,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: GestureDetector(
                onTapDown: (_) => _onTapDown(),
                onTapUp: (_) => _onTapUp(),
                onTapCancel: _onTapCancel,
                child: Container(
                  width: widget.isHorizontal ? 280 : double.infinity,
                  margin: EdgeInsets.only(
                    right: widget.isHorizontal ? 16 : 0,
                    bottom: widget.isHorizontal ? 0 : 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImageSection(),
                      _buildContentSection(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSection() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: AppTheme.primaryPink.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Stack(
        children: [
          // Article image placeholder
          Center(
            child: Icon(
              _getArticleIcon(),
              size: 48,
              color: AppTheme.primaryPink.withOpacity(0.7),
            ),
          ),

          // Category badge
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getCategoryColor(),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.article.categoryEmoji,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.article.categoryDisplayName,
                    style: AppTheme.captionStyle.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expert badge
          if (widget.article.isExpertContent)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'EXPERT',
                      style: AppTheme.captionStyle.copyWith(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Featured badge
          if (widget.article.isFeatured)
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '⭐ À LA UNE',
                  style: AppTheme.captionStyle.copyWith(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

          // Action buttons
          Positioned(
            bottom: 12,
            right: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Like button
                GestureDetector(
                  onTap: _toggleLike,
                  child: Transform.scale(
                    scale: _likeAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                valueColor: AlwaysStoppedAnimation(AppTheme.primaryPink),
                              ),
                            )
                          : Icon(
                              _isLiked ? Icons.favorite : Icons.favorite_outline,
                              size: 12,
                              color: _isLiked ? Colors.red : AppTheme.lightGray,
                            ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Bookmark button
                GestureDetector(
                  onTap: _toggleBookmark,
                  child: Transform.scale(
                    scale: _bookmarkAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                        size: 12,
                        color: _isBookmarked ? AppTheme.primaryPink : AppTheme.lightGray,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Article title
          Text(
            widget.article.title,
            style: AppTheme.bodyTextStyle.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 8),
          
          // Article excerpt
          Text(
            widget.article.excerpt,
            style: AppTheme.captionStyle.copyWith(
              color: AppTheme.lightGray,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 12),
          
          // Author and metadata
          Row(
            children: [
              // Author avatar
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: widget.article.author.role == UserRole.expert 
                      ? Colors.green.withOpacity(0.1)
                      : AppTheme.primaryPink.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    widget.article.author.roleEmoji,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Author name
              Expanded(
                child: Text(
                  widget.article.author.displayName,
                  style: AppTheme.captionStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // Reading time
              Text(
                widget.article.readingTime,
                style: AppTheme.captionStyle.copyWith(
                  color: AppTheme.lightGray,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Stats row
          Row(
            children: [
              _buildStatItem(Icons.visibility, widget.article.views.toString()),
              const SizedBox(width: 16),
              _buildStatItem(Icons.favorite, widget.article.likes.toString()),
              const SizedBox(width: 16),
              _buildStatItem(Icons.comment, widget.article.commentsCount.toString()),
              
              const Spacer(),
              
              // Publication date
              Text(
                CommunityService.formatTimeAgo(widget.article.publishedAt),
                style: AppTheme.captionStyle.copyWith(
                  color: AppTheme.lightGray,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: AppTheme.lightGray,
        ),
        const SizedBox(width: 2),
        Text(
          count,
          style: AppTheme.captionStyle.copyWith(
            color: AppTheme.lightGray,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  IconData _getArticleIcon() {
    switch (widget.article.category) {
      case ArticleCategory.health:
        return Icons.local_hospital_outlined;
      case ArticleCategory.contraception:
        return Icons.shield_outlined;
      case ArticleCategory.menstruation:
        return Icons.calendar_today_outlined;
      case ArticleCategory.pregnancy:
        return Icons.child_care_outlined;
      case ArticleCategory.intimacy:
        return Icons.favorite_outline;
      case ArticleCategory.nutrition:
        return Icons.restaurant_outlined;
      case ArticleCategory.psychology:
        return Icons.psychology_outlined;
      case ArticleCategory.relationships:
        return Icons.people_outline;
    }
  }

  Color _getCategoryColor() {
    switch (widget.article.category) {
      case ArticleCategory.health:
        return const Color(0xFF10B981);
      case ArticleCategory.contraception:
        return const Color(0xFF6366F1);
      case ArticleCategory.menstruation:
        return const Color(0xFFEC4899);
      case ArticleCategory.pregnancy:
        return const Color(0xFFF59E0B);
      case ArticleCategory.intimacy:
        return const Color(0xFFEF4444);
      case ArticleCategory.nutrition:
        return const Color(0xFF84CC16);
      case ArticleCategory.psychology:
        return const Color(0xFF8B5CF6);
      case ArticleCategory.relationships:
        return const Color(0xFF06B6D4);
    }
  }
}