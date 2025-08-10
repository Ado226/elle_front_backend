import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../core/models/caring_experience.dart';
import '../../services/caring_service.dart';
import 'surprise_idea_detail_widget.dart';

class SurpriseIdeaCard extends StatefulWidget {
  final SurpriseIdea idea;
  final VoidCallback? onTap;
  final VoidCallback onCompleted;

  const SurpriseIdeaCard({
    Key? key,
    required this.idea,
    this.onTap,
    required this.onCompleted,
  }) : super(key: key);

  @override
  State<SurpriseIdeaCard> createState() => _SurpriseIdeaCardState();
}

class _SurpriseIdeaCardState extends State<SurpriseIdeaCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: _buildCard(),
          ),
        );
      },
    );
  }

  Widget _buildCard() {
    final isLocked = !widget.idea.isUnlocked;
    
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) {
        _animationController.reverse();
        if (widget.onTap != null) {
          widget.onTap!();
        } else {
          _showIdeaDetail();
        }
      },
      onTapCancel: () => _animationController.reverse(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isLocked 
              ? AppTheme.lightGray.withOpacity(0.1)
              : AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLocked 
                ? AppTheme.lightGray.withOpacity(0.3)
                : AppTheme.primaryPink.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: isLocked ? null : [
            BoxShadow(
              color: AppTheme.primaryPink.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isLocked 
                        ? AppTheme.lightGray.withOpacity(0.2)
                        : AppTheme.primaryPink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      isLocked ? '🔒' : widget.idea.emoji,
                      style: TextStyle(
                        fontSize: 24,
                        color: isLocked ? AppTheme.lightGray : null,
                      ),
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isLocked 
                                  ? AppTheme.lightGray.withOpacity(0.2)
                                  : _getCategoryColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.idea.categoryDisplayName,
                              style: AppTheme.captionStyle.copyWith(
                                color: isLocked 
                                    ? AppTheme.lightGray
                                    : _getCategoryColor(),
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isLocked 
                                  ? AppTheme.lightGray.withOpacity(0.2)
                                  : _getDifficultyColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.idea.difficultyDisplayName,
                              style: AppTheme.captionStyle.copyWith(
                                color: isLocked 
                                    ? AppTheme.lightGray
                                    : _getDifficultyColor(),
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.idea.title,
                        style: AppTheme.bodyTextStyle.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isLocked 
                              ? AppTheme.lightGray
                              : AppTheme.darkText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Points value
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isLocked 
                        ? AppTheme.lightGray.withOpacity(0.2)
                        : AppTheme.primaryPink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite,
                        size: 12,
                        color: isLocked 
                            ? AppTheme.lightGray
                            : AppTheme.primaryPink,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.idea.carePointsValue}',
                        style: AppTheme.captionStyle.copyWith(
                          color: isLocked 
                              ? AppTheme.lightGray
                              : AppTheme.primaryPink,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              widget.idea.description,
              style: AppTheme.captionStyle.copyWith(
                color: isLocked 
                    ? AppTheme.lightGray
                    : AppTheme.lightGray.withOpacity(0.8),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Info row
            Row(
              children: [
                _buildInfoChip(
                  icon: Icons.schedule,
                  label: widget.idea.formattedTime,
                  isLocked: isLocked,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  icon: Icons.attach_money,
                  label: widget.idea.formattedCost,
                  isLocked: isLocked,
                ),
                const Spacer(),
                if (isLocked) ...[
                  Icon(
                    Icons.lock_outline,
                    size: 16,
                    color: AppTheme.lightGray,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Niveau ${widget.idea.requiredLevel}',
                    style: AppTheme.captionStyle.copyWith(
                      color: AppTheme.lightGray,
                      fontSize: 11,
                    ),
                  ),
                ] else ...[
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppTheme.primaryPink,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required bool isLocked,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isLocked 
            ? AppTheme.lightGray.withOpacity(0.1)
            : AppTheme.lightGray.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isLocked 
                ? AppTheme.lightGray
                : AppTheme.lightGray.withOpacity(0.8),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTheme.captionStyle.copyWith(
              color: isLocked 
                  ? AppTheme.lightGray
                  : AppTheme.lightGray.withOpacity(0.8),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor() {
    switch (widget.idea.category) {
      case SurpriseCategory.romantic:
        return Colors.pink;
      case SurpriseCategory.supportive:
        return Colors.blue;
      case SurpriseCategory.health:
        return Colors.green;
      case SurpriseCategory.comfort:
        return Colors.purple;
      case SurpriseCategory.adventure:
        return Colors.orange;
      case SurpriseCategory.creative:
        return Colors.amber;
    }
  }

  Color _getDifficultyColor() {
    switch (widget.idea.difficulty) {
      case ActionDifficulty.easy:
        return Colors.green;
      case ActionDifficulty.medium:
        return Colors.orange;
      case ActionDifficulty.advanced:
        return Colors.red;
    }
  }

  void _showIdeaDetail() {
    if (!widget.idea.isUnlocked) {
      _showLockedDialog();
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => SurpriseIdeaDetailWidget(
          idea: widget.idea,
          scrollController: scrollController,
          onCompleted: () {
            Navigator.of(context).pop();
            widget.onCompleted();
          },
        ),
      ),
    );
  }

  void _showLockedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.lock_outline,
              color: AppTheme.primaryPink,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Idée verrouillée',
              style: AppTheme.subHeaderStyle.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          'Cette idée est déverrouillée au niveau ${widget.idea.requiredLevel}. Continuez à accomplir des actions caring pour progresser !',
          style: AppTheme.bodyTextStyle,
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
}