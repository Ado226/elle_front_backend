import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../core/models/loyalty.dart';

class RewardCardWidget extends StatefulWidget {
  final Reward reward;
  final int availablePoints;
  final VoidCallback onTap;
  final bool isFeatured;

  const RewardCardWidget({
    Key? key,
    required this.reward,
    required this.availablePoints,
    required this.onTap,
    this.isFeatured = false,
  }) : super(key: key);

  @override
  State<RewardCardWidget> createState() => _RewardCardWidgetState();
}

class _RewardCardWidgetState extends State<RewardCardWidget>
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
      duration: const Duration(milliseconds: 200),
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
    final canAfford = widget.availablePoints >= widget.reward.pointsCost;
    final isExpired = widget.reward.isExpired;
    final isOutOfStock = widget.reward.isOutOfStock;
    final isAvailable = widget.reward.isAvailable && !isExpired && !isOutOfStock;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: GestureDetector(
              onTapDown: (_) => _animationController.forward(),
              onTapUp: (_) {
                _animationController.reverse();
                widget.onTap();
              },
              onTapCancel: () => _animationController.reverse(),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.isFeatured
                        ? AppTheme.primaryPink.withOpacity(0.3)
                        : AppTheme.lightGray.withOpacity(0.2),
                    width: widget.isFeatured ? 2 : 1,
                  ),
                  boxShadow: widget.isFeatured ? [
                    BoxShadow(
                      color: AppTheme.primaryPink.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ] : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image section
                    _buildImageSection(),

                    // Content section
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with badges
                            _buildHeader(),

                            const SizedBox(height: 8),

                            // Title
                            Text(
                              widget.reward.title,
                              style: AppTheme.bodyTextStyle.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isAvailable 
                                    ? AppTheme.darkText 
                                    : AppTheme.lightGray,
                              ),
                              maxLines: widget.isFeatured ? 2 : 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 4),

                            // Description
                            Expanded(
                              child: Text(
                                widget.reward.description,
                                style: AppTheme.captionStyle.copyWith(
                                  color: isAvailable 
                                      ? AppTheme.lightGray 
                                      : AppTheme.lightGray.withOpacity(0.7),
                                  height: 1.3,
                                ),
                                maxLines: widget.isFeatured ? 3 : 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Footer
                            _buildFooter(canAfford, isAvailable),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        // Image
        Container(
          height: widget.isFeatured ? 120 : 100,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            gradient: LinearGradient(
              colors: [
                _getCategoryColor().withOpacity(0.2),
                _getCategoryColor().withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Icon(
              _getCategoryIcon(),
              size: widget.isFeatured ? 48 : 40,
              color: _getCategoryColor(),
            ),
          ),
        ),

        // Badges overlay
        Positioned(
          top: 8,
          left: 8,
          child: Row(
            children: [
              if (widget.reward.isFeatured)
                _buildBadge(
                  label: 'Vedette',
                  color: AppTheme.primaryPink,
                  icon: Icons.star,
                ),
              if (widget.reward.isExclusive) ...[
                if (widget.reward.isFeatured) const SizedBox(width: 4),
                _buildBadge(
                  label: 'Exclusif',
                  color: Colors.purple,
                  icon: Icons.diamond,
                ),
              ],
            ],
          ),
        ),

        // Status overlay
        if (!widget.reward.isAvailable || widget.reward.isExpired || widget.reward.isOutOfStock)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                color: Colors.black.withOpacity(0.6),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.reward.isExpired 
                        ? 'Expiré' 
                        : widget.reward.isOutOfStock 
                            ? 'Épuisé'
                            : 'Indisponible',
                    style: AppTheme.captionStyle.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBadge({
    required String label,
    required Color color,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 10,
              color: Colors.white,
            ),
            const SizedBox(width: 2),
          ],
          Text(
            label,
            style: AppTheme.captionStyle.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _getCategoryColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.reward.categoryDisplayName,
            style: AppTheme.captionStyle.copyWith(
              color: _getCategoryColor(),
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _getTypeColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.reward.typeDisplayName,
            style: AppTheme.captionStyle.copyWith(
              color: _getTypeColor(),
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
          ),
        ),
        const Spacer(),
        if (widget.reward.hasExpiry)
          Icon(
            Icons.schedule,
            size: 14,
            color: AppTheme.lightGray,
          ),
      ],
    );
  }

  Widget _buildFooter(bool canAfford, bool isAvailable) {
    return Row(
      children: [
        // Points cost
        Expanded(
          child: Row(
            children: [
              Icon(
                Icons.stars,
                size: 16,
                color: canAfford && isAvailable 
                    ? AppTheme.primaryPink 
                    : AppTheme.lightGray,
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.reward.pointsCost}',
                style: AppTheme.bodyTextStyle.copyWith(
                  fontWeight: FontWeight.w700,
                  color: canAfford && isAvailable 
                      ? AppTheme.primaryPink 
                      : AppTheme.lightGray,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                'pts',
                style: AppTheme.captionStyle.copyWith(
                  color: canAfford && isAvailable 
                      ? AppTheme.primaryPink 
                      : AppTheme.lightGray,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),

        // Status indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(canAfford, isAvailable).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getStatusIcon(canAfford, isAvailable),
                size: 12,
                color: _getStatusColor(canAfford, isAvailable),
              ),
              const SizedBox(width: 4),
              Text(
                _getStatusText(canAfford, isAvailable),
                style: AppTheme.captionStyle.copyWith(
                  color: _getStatusColor(canAfford, isAvailable),
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor() {
    switch (widget.reward.category) {
      case RewardCategory.health:
        return Colors.green;
      case RewardCategory.beauty:
        return Colors.pink;
      case RewardCategory.wellness:
        return Colors.purple;
      case RewardCategory.shopping:
        return Colors.blue;
      case RewardCategory.experiences:
        return Colors.orange;
      case RewardCategory.digital:
        return Colors.teal;
      case RewardCategory.charity:
        return Colors.amber;
    }
  }

  IconData _getCategoryIcon() {
    switch (widget.reward.category) {
      case RewardCategory.health:
        return Icons.health_and_safety;
      case RewardCategory.beauty:
        return Icons.face_retouching_natural;
      case RewardCategory.wellness:
        return Icons.spa;
      case RewardCategory.shopping:
        return Icons.shopping_bag;
      case RewardCategory.experiences:
        return Icons.explore;
      case RewardCategory.digital:
        return Icons.computer;
      case RewardCategory.charity:
        return Icons.favorite;
    }
  }

  Color _getTypeColor() {
    switch (widget.reward.type) {
      case RewardType.discount:
        return Colors.green;
      case RewardType.freeProduct:
        return Colors.blue;
      case RewardType.cashback:
        return Colors.purple;
      case RewardType.experience:
        return Colors.orange;
      case RewardType.digitalContent:
        return Colors.teal;
      case RewardType.donation:
        return Colors.amber;
      case RewardType.exclusive:
        return Colors.red;
    }
  }

  Color _getStatusColor(bool canAfford, bool isAvailable) {
    if (!isAvailable) return Colors.red;
    if (!canAfford) return Colors.orange;
    return Colors.green;
  }

  IconData _getStatusIcon(bool canAfford, bool isAvailable) {
    if (!isAvailable) return Icons.error;
    if (!canAfford) return Icons.lock;
    return Icons.check_circle;
  }

  String _getStatusText(bool canAfford, bool isAvailable) {
    if (!isAvailable) return 'Indisponible';
    if (!canAfford) return 'Insuffisant';
    return 'Disponible';
  }
}