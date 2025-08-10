import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../core/models/partner.dart';

class PartnerNotificationsWidget extends StatefulWidget {
  final List<PartnerNotificationItem> notifications;
  final Function(PartnerNotificationItem)? onNotificationTap;
  final Function(PartnerNotificationItem)? onNotificationDismiss;

  const PartnerNotificationsWidget({
    Key? key,
    required this.notifications,
    this.onNotificationTap,
    this.onNotificationDismiss,
  }) : super(key: key);

  @override
  State<PartnerNotificationsWidget> createState() => _PartnerNotificationsWidgetState();
}

class _PartnerNotificationsWidgetState extends State<PartnerNotificationsWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<AnimationController> _itemControllers;
  late List<Animation<double>> _itemAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _itemControllers = List.generate(
      widget.notifications.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      ),
    );

    _itemAnimations = _itemControllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ));
    }).toList();

    _startStaggeredAnimations();
  }

  void _startStaggeredAnimations() {
    _animationController.forward();
    
    for (int i = 0; i < _itemControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          _itemControllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.notifications.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Notifications Partenaire',
                style: AppTheme.bodyTextStyle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (widget.notifications.isNotEmpty)
                TextButton(
                  onPressed: () => _clearAllNotifications(),
                  child: Text(
                    'Tout effacer',
                    style: AppTheme.captionStyle.copyWith(
                      color: AppTheme.primaryPink,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Notifications list
          ...widget.notifications.asMap().entries.map((entry) {
            final index = entry.key;
            final notification = entry.value;
            
            return AnimatedBuilder(
              animation: _itemAnimations[index],
              builder: (context, child) {
                return Transform.scale(
                  scale: _itemAnimations[index].value,
                  child: Opacity(
                    opacity: _itemAnimations[index].value,
                    child: PartnerNotificationCard(
                      notification: notification,
                      onTap: () => widget.onNotificationTap?.call(notification),
                      onDismiss: () => _dismissNotification(notification),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          Icon(
            Icons.notifications_none,
            size: 48,
            color: AppTheme.lightGray,
          ),
          const SizedBox(height: 12),
          Text(
            'Aucune notification',
            style: AppTheme.bodyTextStyle.copyWith(
              color: AppTheme.lightGray,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Les notifications de votre partenaire apparaîtront ici',
            style: AppTheme.captionStyle.copyWith(
              color: AppTheme.lightGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _dismissNotification(PartnerNotificationItem notification) {
    widget.onNotificationDismiss?.call(notification);
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Effacer toutes les notifications', style: AppTheme.subHeaderStyle),
        content: const Text('Êtes-vous sûre de vouloir effacer toutes les notifications partenaire?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: AppTheme.bodyTextStyle),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              for (var notification in widget.notifications) {
                widget.onNotificationDismiss?.call(notification);
              }
            },
            style: AppTheme.primaryButtonStyle,
            child: Text('Effacer', style: AppTheme.buttonTextStyle),
          ),
        ],
      ),
    );
  }
}

class PartnerNotificationCard extends StatefulWidget {
  final PartnerNotificationItem notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const PartnerNotificationCard({
    Key? key,
    required this.notification,
    this.onTap,
    this.onDismiss,
  }) : super(key: key);

  @override
  State<PartnerNotificationCard> createState() => _PartnerNotificationCardState();
}

class _PartnerNotificationCardState extends State<PartnerNotificationCard>
    with TickerProviderStateMixin {
  late AnimationController _tapController;
  late Animation<double> _tapAnimation;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _tapAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _tapController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _tapController,
      builder: (context, child) {
        return Transform.scale(
          scale: _tapAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Dismissible(
              key: Key(widget.notification.id),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => widget.onDismiss?.call(),
              background: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.centerRight,
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
              child: GestureDetector(
                onTapDown: (_) => _tapController.forward(),
                onTapUp: (_) {
                  _tapController.reverse();
                  widget.onTap?.call();
                },
                onTapCancel: () => _tapController.reverse(),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.notification.isRead 
                        ? AppTheme.cardBackground
                        : AppTheme.primaryPink.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.notification.isRead 
                          ? AppTheme.lightGray.withOpacity(0.2)
                          : AppTheme.primaryPink.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getNotificationColor(widget.notification.type).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          _getNotificationIcon(widget.notification.type),
                          color: _getNotificationColor(widget.notification.type),
                          size: 20,
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Content
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
                                      fontWeight: widget.notification.isRead 
                                          ? FontWeight.w500
                                          : FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                if (!widget.notification.isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryPink,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            
                            const SizedBox(height: 4),
                            
                            Text(
                              widget.notification.message,
                              style: AppTheme.captionStyle.copyWith(
                                color: AppTheme.mediumGray,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            
                            const SizedBox(height: 6),
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatTimestamp(widget.notification.timestamp),
                                  style: AppTheme.captionStyle.copyWith(
                                    color: AppTheme.lightGray,
                                    fontSize: 11,
                                  ),
                                ),
                                if (widget.notification.actionRequired)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Action requise',
                                      style: AppTheme.captionStyle.copyWith(
                                        color: Colors.orange,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
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

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.menstrualPhase:
        return Icons.calendar_month;
      case NotificationType.mood:
        return Icons.sentiment_satisfied;
      case NotificationType.symptoms:
        return Icons.health_and_safety;
      case NotificationType.appointment:
        return Icons.event;
      case NotificationType.reminder:
        return Icons.alarm;
      case NotificationType.achievement:
        return Icons.star;
      case NotificationType.gift:
        return Icons.card_giftcard;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.menstrualPhase:
        return Colors.red;
      case NotificationType.mood:
        return Colors.purple;
      case NotificationType.symptoms:
        return Colors.orange;
      case NotificationType.appointment:
        return Colors.blue;
      case NotificationType.reminder:
        return Colors.amber;
      case NotificationType.achievement:
        return Colors.green;
      case NotificationType.gift:
        return AppTheme.primaryPink;
      default:
        return AppTheme.primaryPink;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }
}

// Data models

class PartnerNotificationItem {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final bool actionRequired;
  final Map<String, dynamic>? metadata;

  PartnerNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.actionRequired = false,
    this.metadata,
  });

  PartnerNotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    bool? actionRequired,
    Map<String, dynamic>? metadata,
  }) {
    return PartnerNotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      actionRequired: actionRequired ?? this.actionRequired,
      metadata: metadata ?? this.metadata,
    );
  }
}