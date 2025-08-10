import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../core/models/community.dart';
import '../../services/community_service.dart';

class ForumPostCard extends StatefulWidget {
  final ForumPost post;
  final VoidCallback onTap;
  final Duration animationDelay;

  const ForumPostCard({
    Key? key,
    required this.post,
    required this.onTap,
    this.animationDelay = Duration.zero,
  }) : super(key: key);

  @override
  State<ForumPostCard> createState() => _ForumPostCardState();
}

class _ForumPostCardState extends State<ForumPostCard>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _likeController;
  late AnimationController _tapController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _likeAnimation;
  late Animation<double> _tapAnimation;

  bool _isLiked = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkLikeStatus();
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

  Future<void> _checkLikeStatus() async {
    final isLiked = await CommunityService.isPostLiked(widget.post.id);
    if (mounted) {
      setState(() => _isLiked = isLiked);
    }
  }

  Future<void> _toggleLike() async {
    setState(() => _isLoading = true);
    
    final success = await CommunityService.togglePostLike(widget.post.id);
    
    if (success) {
      setState(() => _isLiked = !_isLiked);
      _likeController.forward().then((_) {
        _likeController.reverse();
      });
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
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _likeController, _tapController]),
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
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: widget.post.isPinned 
                        ? Border.all(color: AppTheme.primaryPink.withOpacity(0.3), width: 1)
                        : null,
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
                      _buildHeader(),
                      const SizedBox(height: 12),
                      _buildContent(),
                      const SizedBox(height: 12),
                      _buildFooter(),
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

  Widget _buildHeader() {
    return Row(
      children: [
        // Author avatar
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: widget.post.author.role == UserRole.expert 
                ? Colors.green.withOpacity(0.1)
                : AppTheme.primaryPink.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              widget.post.author.roleEmoji,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.post.author.displayName,
                    style: AppTheme.bodyTextStyle.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if (widget.post.author.isVerified) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.verified,
                      size: 14,
                      color: Colors.blue,
                    ),
                  ],
                ],
              ),
              
              const SizedBox(height: 2),
              
              Row(
                children: [
                  Text(
                    widget.post.author.roleDisplayName,
                    style: AppTheme.captionStyle.copyWith(
                      color: AppTheme.lightGray,
                      fontSize: 11,
                    ),
                  ),
                  if (widget.post.author.expertise != null) ...[
                    Text(
                      ' • ${widget.post.author.expertise}',
                      style: AppTheme.captionStyle.copyWith(
                        color: AppTheme.lightGray,
                        fontSize: 11,
                      ),
                    ),
                  ],
                  Text(
                    ' • ${CommunityService.formatTimeAgo(widget.post.createdAt)}',
                    style: AppTheme.captionStyle.copyWith(
                      color: AppTheme.lightGray,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Badges
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (widget.post.isPinned)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '📌 ÉPINGLÉ',
                  style: AppTheme.captionStyle.copyWith(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            
            if (widget.post.isExpertQuestion)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '🩺 EXPERT',
                  style: AppTheme.captionStyle.copyWith(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            
            if (widget.post.isClosed)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '🔒 FERMÉ',
                  style: AppTheme.captionStyle.copyWith(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Post title
        Text(
          widget.post.title,
          style: AppTheme.bodyTextStyle.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 8),
        
        // Post content preview
        Text(
          widget.post.content,
          style: AppTheme.captionStyle.copyWith(
            color: AppTheme.lightGray,
            height: 1.4,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        
        // Tags
        if (widget.post.tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: widget.post.tags.take(3).map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getCategoryColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '#$tag',
                  style: AppTheme.captionStyle.copyWith(
                    color: _getCategoryColor(),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        // Category
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getCategoryColor(),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.post.categoryEmoji,
                style: const TextStyle(fontSize: 10),
              ),
              const SizedBox(width: 4),
              Text(
                widget.post.categoryDisplayName,
                style: AppTheme.captionStyle.copyWith(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        
        const Spacer(),
        
        // Stats
        _buildStatItem(Icons.visibility, widget.post.views.toString()),
        const SizedBox(width: 16),
        _buildStatItem(Icons.chat_bubble_outline, widget.post.repliesCount.toString()),
        const SizedBox(width: 16),
        
        // Like button
        GestureDetector(
          onTap: _toggleLike,
          child: Transform.scale(
            scale: _likeAnimation.value,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _isLoading
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
                        size: 14,
                        color: _isLiked ? Colors.red : AppTheme.lightGray,
                      ),
                const SizedBox(width: 4),
                Text(
                  widget.post.likes.toString(),
                  style: AppTheme.captionStyle.copyWith(
                    color: _isLiked ? Colors.red : AppTheme.lightGray,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
        const SizedBox(width: 4),
        Text(
          count,
          style: AppTheme.captionStyle.copyWith(
            color: AppTheme.lightGray,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor() {
    switch (widget.post.category.id) {
      case 'general':
        return const Color(0xFF6B7280);
      case 'health':
        return const Color(0xFF10B981);
      case 'relationships':
        return const Color(0xFF06B6D4);
      case 'pregnancy':
        return const Color(0xFFF59E0B);
      case 'menstruation':
        return const Color(0xFFEC4899);
      case 'support':
        return const Color(0xFF8B5CF6);
      case 'tips':
        return const Color(0xFF84CC16);
      default:
        return AppTheme.primaryPink;
    }
  }
}