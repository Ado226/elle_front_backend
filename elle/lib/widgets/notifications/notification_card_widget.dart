import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../core/models/notification.dart';
import '../../services/notification_service.dart';

class NotificationCardWidget extends StatefulWidget {
  final AppNotification notification;
  final VoidCallback? onRead;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const NotificationCardWidget({
    Key? key,
    required this.notification,
    this.onRead,
    this.onDelete,
    this.onTap,
  }) : super(key: key);

  @override
  State<NotificationCardWidget> createState() => _NotificationCardWidgetState();
}

class _NotificationCardWidgetState extends State<NotificationCardWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _swipeController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _swipeAnimation;

  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _swipeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _swipeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.0, 0),
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeInOut,
    ));

    // Pulse for unread notifications
    if (!widget.notification.isRead) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _swipeController.dispose();
    super.dispose();
  }

  void _handleDismiss() {
    setState(() => _isDismissed = true);
    _swipeController.forward().then((_) {
      widget.onDelete?.call();
    });
  }

  void _handleTap() {
    if (!widget.notification.isRead) {
      widget.onRead?.call();
      _pulseController.stop();
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_isDismissed) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _swipeController]),
      builder: (context, child) {
        return SlideTransition(
          position: _swipeAnimation,
          child: Transform.scale(
            scale: _pulseAnimation.value,
            child: Dismissible(
              key: Key(widget.notification.id),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => _handleDismiss(),
              background: _buildDismissBackground(),
              child: GestureDetector(
                onTap: _handleTap,
                child: _buildNotificationCard(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.delete,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildNotificationCard() {
    final isUnread = !widget.notification.isRead;
    final categoryColor = _getCategoryColor(widget.notification.category);
    final priorityColor = _getPriorityColor(widget.notification.priority);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread 
              ? categoryColor.withOpacity(0.4)
              : AppTheme.lightGray.withOpacity(0.2),
          width: isUnread ? 2 : 1,
        ),
        boxShadow: isUnread
            ? [
                BoxShadow(
                  color: categoryColor.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Gradient overlay for unread notifications
            if (isUnread)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        categoryColor.withOpacity(0.05),
                        Colors.transparent,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),

            // Main content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with icon, title, and priority
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _getCategoryIcon(widget.notification.category),
                          color: categoryColor,
                          size: 20,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Title and metadata
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.notification.title,
                                    style: AppTheme.bodyTextStyle.copyWith(
                                      fontWeight: isUnread 
                                          ? FontWeight.w700 
                                          : FontWeight.w600,
                                      color: isUnread 
                                          ? AppTheme.darkText 
                                          : AppTheme.lightGray,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                // Priority indicator
                                if (widget.notification.priority != NotificationPriority.normal)
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: priorityColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      widget.notification.priority.name.toUpperCase(),
                                      style: AppTheme.captionStyle.copyWith(
                                        color: priorityColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 4),

                            // Time and category
                            Row(
                              children: [
                                Text(
                                  NotificationService.formatTimeAgo(widget.notification.createdAt),
                                  style: AppTheme.captionStyle.copyWith(
                                    color: AppTheme.lightGray,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '•',
                                  style: AppTheme.captionStyle.copyWith(
                                    color: AppTheme.lightGray,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: categoryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    widget.notification.categoryDisplayName,
                                    style: AppTheme.captionStyle.copyWith(
                                      color: categoryColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Unread indicator
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: categoryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Message body
                  Text(
                    widget.notification.body,
                    style: AppTheme.bodyTextStyle.copyWith(
                      color: isUnread 
                          ? AppTheme.darkText 
                          : AppTheme.lightGray,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Action buttons
                  if (widget.notification.actions.isNotEmpty) ...[ 
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: widget.notification.actions.take(2).map((action) {
                        return _buildActionButton(action);
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(NotificationAction action) {
    return GestureDetector(
      onTap: () => _handleActionTap(action),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.primaryPink.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryPink.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (action.icon != null) ...[ 
              Icon(
                _getActionIcon(action.icon!),
                color: AppTheme.primaryPink,
                size: 14,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              action.title,
              style: AppTheme.captionStyle.copyWith(
                color: AppTheme.primaryPink,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleActionTap(NotificationAction action) {
    // Mark as read when action is tapped
    if (!widget.notification.isRead) {
      widget.onRead?.call();
    }

    // Handle specific actions based on action data
    final actionType = action.data['action'] as String?;
    
    switch (actionType) {
      case 'track_symptoms':
        Navigator.of(context).pushNamed('/cycle/symptoms');
        break;
      case 'view_calendar':
        Navigator.of(context).pushNamed('/cycle');
        break;
      case 'shop_hygiene':
        Navigator.of(context).pushNamed('/shop', arguments: {'category': 'hygiene'});
        break;
      case 'track_mood':
        Navigator.of(context).pushNamed('/cycle/mood');
        break;
      case 'view_appointment':
        Navigator.of(context).pushNamed('/appointments');
        break;
      case 'reschedule':
        Navigator.of(context).pushNamed('/appointments/reschedule');
        break;
      case 'view_caring':
        Navigator.of(context).pushNamed('/caring');
        break;
      case 'complete_caring':
        // Handle caring action completion
        break;
      case 'view_rewards':
        Navigator.of(context).pushNamed('/loyalty');
        break;
      case 'view_tier_benefits':
        Navigator.of(context).pushNamed('/loyalty', arguments: {'tab': 'benefits'});
        break;
      case 'track_order':
        Navigator.of(context).pushNamed('/orders');
        break;
      default:
        // Default action - just mark as read
        break;
    }
  }

  Color _getCategoryColor(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.cycle:
        return AppTheme.primaryPink;
      case NotificationCategory.health:
        return Colors.green;
      case NotificationCategory.caring:
        return Colors.purple;
      case NotificationCategory.partner:
        return Colors.blue;
      case NotificationCategory.appointment:
        return Colors.orange;
      case NotificationCategory.loyalty:
        return Colors.amber;
      case NotificationCategory.shop:
        return Colors.teal;
      case NotificationCategory.general:
        return AppTheme.lightGray;
    }
  }

  Color _getPriorityColor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Colors.grey;
      case NotificationPriority.normal:
        return AppTheme.primaryPink;
      case NotificationPriority.high:
        return Colors.orange;
      case NotificationPriority.urgent:
        return Colors.red;
    }
  }

  IconData _getCategoryIcon(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.cycle:
        return Icons.calendar_month;
      case NotificationCategory.health:
        return Icons.health_and_safety;
      case NotificationCategory.caring:
        return Icons.favorite;
      case NotificationCategory.partner:
        return Icons.people;
      case NotificationCategory.appointment:
        return Icons.event;
      case NotificationCategory.loyalty:
        return Icons.stars;
      case NotificationCategory.shop:
        return Icons.shopping_bag;
      case NotificationCategory.general:
        return Icons.info;
    }
  }

  IconData _getActionIcon(String iconName) {
    switch (iconName) {
      case 'track':
        return Icons.add_circle_outline;
      case 'view':
        return Icons.visibility;
      case 'shop':
        return Icons.shopping_cart;
      case 'calendar':
        return Icons.calendar_today;
      case 'appointment':
        return Icons.event;
      case 'caring':
        return Icons.favorite;
      case 'reward':
        return Icons.card_giftcard;
      case 'order':
        return Icons.local_shipping;
      default:
        return Icons.arrow_forward;
    }
  }
}