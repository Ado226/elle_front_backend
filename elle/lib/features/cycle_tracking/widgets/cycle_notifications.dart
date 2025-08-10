import 'package:flutter/material.dart';
import '../../../core/models/menstrual_cycle.dart';
import '../../../core/theme/african_theme.dart';

class CycleNotifications extends StatefulWidget {
  final MenstrualCycle cycle;

  const CycleNotifications({
    Key? key,
    required this.cycle,
  }) : super(key: key);

  @override
  State<CycleNotifications> createState() => _CycleNotificationsState();
}

class _CycleNotificationsState extends State<CycleNotifications>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _getNotifications();

    if (notifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Column(
              children: notifications
                  .map((notification) => _buildNotificationCard(notification))
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  List<NotificationData> _getNotifications() {
    final notifications = <NotificationData>[];
    final now = DateTime.now();
    final currentType = widget.cycle.getCycleDayType(now);
    final daysUntilPeriod = widget.cycle.getDaysUntilNextPeriod();

    // Current phase notification
    switch (currentType) {
      case CycleDayType.menstruation:
        notifications.add(NotificationData(
          icon: Icons.water_drop,
          iconColor: AfricanColors.menstruationColor,
          backgroundColor: AfricanColors.menstruationColor.withOpacity(0.1),
          borderColor: AfricanColors.menstruationColor,
          title: 'Période menstruelle',
          message: widget.cycle.getCurrentPhaseDescription(),
          emoji: '🩸',
          priority: NotificationPriority.high,
        ));
        break;
        
      case CycleDayType.fertile:
        notifications.add(NotificationData(
          icon: Icons.eco,
          iconColor: AfricanColors.fertileColor,
          backgroundColor: AfricanColors.fertileColor.withOpacity(0.1),
          borderColor: AfricanColors.fertileColor,
          title: 'Fenêtre fertile',
          message: 'Vous êtes dans votre période fertile 🌿',
          emoji: '🌿',
          priority: NotificationPriority.high,
        ));
        break;
        
      case CycleDayType.ovulation:
        notifications.add(NotificationData(
          icon: Icons.star,
          iconColor: AfricanColors.ovulationColor,
          backgroundColor: AfricanColors.ovulationColor.withOpacity(0.1),
          borderColor: AfricanColors.ovulationColor,
          title: 'Jour d\'ovulation',
          message: 'Aujourd\'hui est votre jour d\'ovulation 🌟',
          emoji: '🌟',
          priority: NotificationPriority.critical,
        ));
        break;
        
      case CycleDayType.safe:
        if (daysUntilPeriod <= 3) {
          notifications.add(NotificationData(
            icon: Icons.schedule,
            iconColor: AfricanColors.warningOrange,
            backgroundColor: AfricanColors.warningOrange.withOpacity(0.1),
            borderColor: AfricanColors.warningOrange,
            title: 'Règles approchent',
            message: 'Vos règles peuvent commencer dans $daysUntilPeriod jour${daysUntilPeriod == 1 ? '' : 's'} 🩸',
            emoji: '⏰',
            priority: NotificationPriority.medium,
          ));
        } else {
          notifications.add(NotificationData(
            icon: Icons.shield,
            iconColor: AfricanColors.safeColor,
            backgroundColor: AfricanColors.safeColor.withOpacity(0.1),
            borderColor: AfricanColors.safeColor,
            title: 'Jour sûr',
            message: 'Aujourd\'hui est un jour à faible fertilité 💙',
            emoji: '💙',
            priority: NotificationPriority.low,
          ));
        }
        break;
    }

    // Additional reminders
    _addAdditionalReminders(notifications, now, daysUntilPeriod);

    return notifications;
  }

  void _addAdditionalReminders(
    List<NotificationData> notifications,
    DateTime now,
    int daysUntilPeriod,
  ) {
    // Hydration reminder during period
    if (widget.cycle.getCycleDayType(now) == CycleDayType.menstruation) {
      notifications.add(NotificationData(
        icon: Icons.local_drink,
        iconColor: AfricanColors.infoBlue,
        backgroundColor: AfricanColors.infoBlue.withOpacity(0.1),
        borderColor: AfricanColors.infoBlue,
        title: 'Hydratation',
        message: 'N\'oubliez pas de boire beaucoup d\'eau 💧',
        emoji: '💧',
        priority: NotificationPriority.low,
      ));
    }

    // Exercise reminder during fertile window
    if (widget.cycle.getCycleDayType(now) == CycleDayType.fertile) {
      notifications.add(NotificationData(
        icon: Icons.fitness_center,
        iconColor: AfricanColors.successGreen,
        backgroundColor: AfricanColors.successGreen.withOpacity(0.1),
        borderColor: AfricanColors.successGreen,
        title: 'Activité physique',
        message: 'Période idéale pour l\'exercice léger 🏃‍♀️',
        emoji: '🏃‍♀️',
        priority: NotificationPriority.low,
      ));
    }

    // Preparation reminder
    if (daysUntilPeriod == 1) {
      notifications.add(NotificationData(
        icon: Icons.backpack,
        iconColor: AfricanColors.warningOrange,
        backgroundColor: AfricanColors.warningOrange.withOpacity(0.1),
        borderColor: AfricanColors.warningOrange,
        title: 'Préparation',
        message: 'Préparez vos produits hygiéniques 🎒',
        emoji: '🎒',
        priority: NotificationPriority.medium,
      ));
    }
  }

  Widget _buildNotificationCard(NotificationData notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: notification.borderColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: notification.iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                notification.icon,
                color: notification.iconColor,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        notification.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: notification.iconColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        notification.emoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      if (notification.priority == NotificationPriority.critical)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AfricanColors.errorRed,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'IMPORTANT',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AfricanColors.textLight,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AfricanColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum NotificationPriority {
  low,
  medium,
  high,
  critical,
}

class NotificationData {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final String title;
  final String message;
  final String emoji;
  final NotificationPriority priority;

  const NotificationData({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.title,
    required this.message,
    required this.emoji,
    this.priority = NotificationPriority.low,
  });
}