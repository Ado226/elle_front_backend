import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/models/notification.dart';

class NotificationService {
  static const String _settingsKey = 'notification_settings';
  static const String _notificationsKey = 'app_notifications';
  static const String _templatesKey = 'notification_templates';
  static const String _rulesKey = 'notification_rules';
  static const String _scheduledKey = 'scheduled_notifications';

  // Default notification templates
  static final List<NotificationTemplate> _defaultTemplates = [
    // Cycle notifications
    NotificationTemplate(
      id: 'cycle_phase_start',
      name: 'Début de phase de cycle',
      category: NotificationCategory.cycle,
      titleTemplate: '{{phase}} commence',
      bodyTemplate: 'Votre phase {{phase}} commence aujourd\'hui. {{message}}',
      priority: NotificationPriority.normal,
      sound: 'gentle_chime',
      actions: [
        NotificationAction(
          id: 'track_symptoms',
          title: 'Noter symptômes',
          data: {'action': 'track_symptoms'},
        ),
        NotificationAction(
          id: 'view_calendar',
          title: 'Voir calendrier',
          data: {'action': 'view_calendar'},
        ),
      ],
    ),

    NotificationTemplate(
      id: 'period_reminder',
      name: 'Rappel de règles',
      category: NotificationCategory.cycle,
      titleTemplate: 'Vos règles arrivent bientôt',
      bodyTemplate: 'Vos règles sont prévues dans {{days}} jour(s). Préparez-vous en avance !',
      priority: NotificationPriority.high,
      sound: 'gentle_bell',
      actions: [
        NotificationAction(
          id: 'prepare_supplies',
          title: 'Préparer',
          data: {'action': 'shop_hygiene'},
        ),
      ],
    ),

    NotificationTemplate(
      id: 'ovulation_reminder',
      name: 'Rappel d\'ovulation',
      category: NotificationCategory.cycle,
      titleTemplate: 'Période d\'ovulation',
      bodyTemplate: 'Vous êtes actuellement en période d\'ovulation. {{message}}',
      priority: NotificationPriority.normal,
      sound: 'soft_tone',
    ),

    // Health notifications
    NotificationTemplate(
      id: 'hydration_reminder',
      name: 'Rappel d\'hydratation',
      category: NotificationCategory.health,
      titleTemplate: 'Pensez à vous hydrater',
      bodyTemplate: 'Il est important de boire suffisamment d\'eau, surtout pendant {{phase}}.',
      priority: NotificationPriority.low,
    ),

    NotificationTemplate(
      id: 'symptom_tracking',
      name: 'Suivi des symptômes',
      category: NotificationCategory.health,
      titleTemplate: 'Comment vous sentez-vous ?',
      bodyTemplate: 'Prenez un moment pour noter vos symptômes et votre humeur.',
      priority: NotificationPriority.normal,
      actions: [
        NotificationAction(
          id: 'track_mood',
          title: 'Noter humeur',
          data: {'action': 'track_mood'},
        ),
        NotificationAction(
          id: 'track_symptoms',
          title: 'Symptômes',
          data: {'action': 'track_symptoms'},
        ),
      ],
    ),

    // Appointment notifications
    NotificationTemplate(
      id: 'appointment_reminder',
      name: 'Rappel de rendez-vous',
      category: NotificationCategory.appointment,
      titleTemplate: 'Rendez-vous {{when}}',
      bodyTemplate: 'Votre rendez-vous avec {{doctor}} est prévu {{when}}.',
      priority: NotificationPriority.high,
      sound: 'appointment_bell',
      persistent: true,
      actions: [
        NotificationAction(
          id: 'view_details',
          title: 'Voir détails',
          data: {'action': 'view_appointment'},
        ),
        NotificationAction(
          id: 'reschedule',
          title: 'Reporter',
          data: {'action': 'reschedule'},
        ),
      ],
    ),

    // Caring notifications
    NotificationTemplate(
      id: 'caring_suggestion',
      name: 'Suggestion caring',
      category: NotificationCategory.caring,
      titleTemplate: 'Idée d\'attention pour {{partner}}',
      bodyTemplate: '{{suggestion}}. C\'est le moment parfait pour montrer votre attention !',
      priority: NotificationPriority.normal,
      actions: [
        NotificationAction(
          id: 'view_suggestion',
          title: 'Voir l\'idée',
          data: {'action': 'view_caring'},
        ),
        NotificationAction(
          id: 'mark_done',
          title: 'C\'est fait !',
          data: {'action': 'complete_caring'},
        ),
      ],
    ),

    NotificationTemplate(
      id: 'partner_notification',
      name: 'Notification partenaire',
      category: NotificationCategory.partner,
      titleTemplate: 'Information sur {{partner}}',
      bodyTemplate: '{{message}}',
      priority: NotificationPriority.normal,
      sound: 'partner_tone',
    ),

    // Loyalty notifications
    NotificationTemplate(
      id: 'points_earned',
      name: 'Points gagnés',
      category: NotificationCategory.loyalty,
      titleTemplate: 'Vous avez gagné {{points}} points !',
      bodyTemplate: '{{reason}}. Votre solde actuel : {{total}} points.',
      priority: NotificationPriority.low,
      actions: [
        NotificationAction(
          id: 'view_rewards',
          title: 'Voir récompenses',
          data: {'action': 'view_rewards'},
        ),
      ],
    ),

    NotificationTemplate(
      id: 'tier_upgrade',
      name: 'Niveau fidélité',
      category: NotificationCategory.loyalty,
      titleTemplate: 'Félicitations ! Niveau {{tier}} atteint',
      bodyTemplate: 'Vous venez d\'atteindre le niveau {{tier}} ! Découvrez vos nouveaux avantages.',
      priority: NotificationPriority.high,
      sound: 'achievement',
      actions: [
        NotificationAction(
          id: 'view_benefits',
          title: 'Voir avantages',
          data: {'action': 'view_tier_benefits'},
        ),
      ],
    ),

    // Shop notifications
    NotificationTemplate(
      id: 'order_update',
      name: 'Mise à jour commande',
      category: NotificationCategory.shop,
      titleTemplate: 'Commande {{status}}',
      bodyTemplate: 'Votre commande #{{orderNumber}} est {{status}}.',
      priority: NotificationPriority.normal,
      actions: [
        NotificationAction(
          id: 'track_order',
          title: 'Suivre',
          data: {'action': 'track_order'},
        ),
      ],
    ),
  ];

  // Default notification rules
  static final List<NotificationRule> _defaultRules = [
    // Daily cycle check
    NotificationRule(
      id: 'daily_cycle_check',
      name: 'Vérification quotidienne du cycle',
      template: _defaultTemplates.firstWhere((t) => t.id == 'symptom_tracking'),
      triggerCondition: 'daily_9am',
      recurring: true,
      cronExpression: '0 9 * * *', // Every day at 9 AM
    ),

    // Pre-period reminder
    NotificationRule(
      id: 'pre_period_reminder',
      name: 'Rappel pré-règles',
      template: _defaultTemplates.firstWhere((t) => t.id == 'period_reminder'),
      triggerCondition: 'period_in_2_days',
      conditions: {'days_until_period': 2},
    ),

    // Ovulation notification
    NotificationRule(
      id: 'ovulation_notification',
      name: 'Notification ovulation',
      template: _defaultTemplates.firstWhere((t) => t.id == 'ovulation_reminder'),
      triggerCondition: 'ovulation_day',
    ),

    // Hydration reminders during period
    NotificationRule(
      id: 'period_hydration',
      name: 'Hydratation pendant les règles',
      template: _defaultTemplates.firstWhere((t) => t.id == 'hydration_reminder'),
      triggerCondition: 'during_period_hours',
      recurring: true,
      conditions: {'phase': 'menstruation'},
    ),
  ];

  // Get notification settings
  static Future<NotificationSettings> getSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      
      if (settingsJson == null) {
        return const NotificationSettings();
      }
      
      return NotificationSettings.fromJson(jsonDecode(settingsJson));
    } catch (e) {
      return const NotificationSettings();
    }
  }

  static Future<bool> updateSettings(NotificationSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = jsonEncode(settings.toJson());
      return await prefs.setString(_settingsKey, settingsJson);
    } catch (e) {
      return false;
    }
  }

  // Notification management
  static Future<List<AppNotification>> getNotifications({
    NotificationCategory? category,
    bool? unreadOnly,
    int? limit,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey);
      
      if (notificationsJson == null) return [];
      
      final notificationsData = jsonDecode(notificationsJson) as List;
      var notifications = notificationsData
          .map((data) => AppNotification.fromJson(data))
          .toList();
      
      // Apply filters
      if (category != null) {
        notifications = notifications.where((n) => n.category == category).toList();
      }
      
      if (unreadOnly == true) {
        notifications = notifications.where((n) => !n.isRead).toList();
      }
      
      // Sort by creation date (newest first)
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      if (limit != null && notifications.length > limit) {
        notifications = notifications.take(limit).toList();
      }
      
      return notifications;
    } catch (e) {
      return [];
    }
  }

  static Future<bool> saveNotification(AppNotification notification) async {
    try {
      final notifications = await getNotifications();
      
      // Check if notification already exists
      final existingIndex = notifications.indexWhere((n) => n.id == notification.id);
      if (existingIndex != -1) {
        notifications[existingIndex] = notification;
      } else {
        notifications.insert(0, notification);
      }
      
      // Keep only last 100 notifications
      if (notifications.length > 100) {
        notifications.removeRange(100, notifications.length);
      }
      
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = jsonEncode(
        notifications.map((n) => n.toJson()).toList()
      );
      
      return await prefs.setString(_notificationsKey, notificationsJson);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> markAsRead(String notificationId) async {
    try {
      final notifications = await getNotifications();
      final index = notifications.indexWhere((n) => n.id == notificationId);
      
      if (index == -1) return false;
      
      final updatedNotification = notifications[index].copyWith(
        status: NotificationStatus.read,
        readAt: DateTime.now(),
      );
      
      notifications[index] = updatedNotification;
      
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = jsonEncode(
        notifications.map((n) => n.toJson()).toList()
      );
      
      return await prefs.setString(_notificationsKey, notificationsJson);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteNotification(String notificationId) async {
    try {
      final notifications = await getNotifications();
      notifications.removeWhere((n) => n.id == notificationId);
      
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = jsonEncode(
        notifications.map((n) => n.toJson()).toList()
      );
      
      return await prefs.setString(_notificationsKey, notificationsJson);
    } catch (e) {
      return false;
    }
  }

  static Future<int> getUnreadCount({NotificationCategory? category}) async {
    final notifications = await getNotifications(
      category: category,
      unreadOnly: true,
    );
    return notifications.length;
  }

  // Schedule notifications
  static Future<bool> scheduleNotification(AppNotification notification) async {
    try {
      if (notification.scheduledAt == null) return false;
      
      final settings = await getSettings();
      if (!settings.isTimeAllowed(notification.scheduledAt!)) {
        // Reschedule to next allowed time
        final newScheduledAt = _findNextAllowedTime(notification.scheduledAt!, settings);
        final rescheduledNotification = notification.copyWith(
          scheduledAt: newScheduledAt,
          status: NotificationStatus.scheduled,
        );
        
        return await _saveScheduledNotification(rescheduledNotification);
      }
      
      final scheduledNotification = notification.copyWith(
        status: NotificationStatus.scheduled,
      );
      
      return await _saveScheduledNotification(scheduledNotification);
    } catch (e) {
      return false;
    }
  }

  static Future<List<AppNotification>> getScheduledNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scheduledJson = prefs.getString(_scheduledKey);
      
      if (scheduledJson == null) return [];
      
      final scheduledData = jsonDecode(scheduledJson) as List;
      return scheduledData
          .map((data) => AppNotification.fromJson(data))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> _saveScheduledNotification(AppNotification notification) async {
    try {
      final scheduled = await getScheduledNotifications();
      
      // Remove existing notification with same ID
      scheduled.removeWhere((n) => n.id == notification.id);
      
      // Add new scheduled notification
      scheduled.add(notification);
      
      // Sort by scheduled time
      scheduled.sort((a, b) => (a.scheduledAt ?? DateTime.now())
          .compareTo(b.scheduledAt ?? DateTime.now()));
      
      final prefs = await SharedPreferences.getInstance();
      final scheduledJson = jsonEncode(
        scheduled.map((n) => n.toJson()).toList()
      );
      
      return await prefs.setString(_scheduledKey, scheduledJson);
    } catch (e) {
      return false;
    }
  }

  // Process pending notifications
  static Future<void> processPendingNotifications() async {
    try {
      final scheduled = await getScheduledNotifications();
      final now = DateTime.now();
      
      for (final notification in scheduled) {
        if (notification.scheduledAt != null && 
            notification.scheduledAt!.isBefore(now) &&
            notification.status == NotificationStatus.scheduled) {
          
          // Send notification
          await _sendNotification(notification);
          
          // Remove from scheduled
          await _removeScheduledNotification(notification.id);
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }

  static Future<bool> _sendNotification(AppNotification notification) async {
    try {
      // In a real app, this would trigger the actual notification
      // For now, we'll just mark it as sent and save it
      final sentNotification = notification.copyWith(
        status: NotificationStatus.sent,
        sentAt: DateTime.now(),
      );
      
      await saveNotification(sentNotification);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _removeScheduledNotification(String notificationId) async {
    try {
      final scheduled = await getScheduledNotifications();
      scheduled.removeWhere((n) => n.id == notificationId);
      
      final prefs = await SharedPreferences.getInstance();
      final scheduledJson = jsonEncode(
        scheduled.map((n) => n.toJson()).toList()
      );
      
      return await prefs.setString(_scheduledKey, scheduledJson);
    } catch (e) {
      return false;
    }
  }

  // Context-aware notifications
  static Future<void> triggerCycleNotification(CyclePhase phase, {Map<String, dynamic>? context}) async {
    final settings = await getSettings();
    if (!settings.isCategoryEnabled(NotificationCategory.cycle)) return;
    
    String templateId;
    String message;
    
    switch (phase) {
      case CyclePhase.menstruation:
        templateId = 'cycle_phase_start';
        message = 'Prenez soin de vous et écoutez votre corps.';
        break;
      case CyclePhase.follicular:
        templateId = 'cycle_phase_start';
        message = 'Votre énergie augmente progressivement.';
        break;
      case CyclePhase.ovulation:
        templateId = 'ovulation_reminder';
        message = 'Vous êtes au pic de votre fertilité.';
        break;
      case CyclePhase.luteal:
        templateId = 'cycle_phase_start';
        message = 'Votre corps se prépare pour le prochain cycle.';
        break;
    }
    
    final template = _defaultTemplates.firstWhere((t) => t.id == templateId);
    final notification = template.createNotification({
      'phase': _getPhaseDisplayName(phase),
      'message': message,
      ...?context,
    });
    
    await saveNotification(notification);
  }

  static Future<void> triggerAppointmentReminder(Map<String, dynamic> appointmentData) async {
    final settings = await getSettings();
    if (!settings.isCategoryEnabled(NotificationCategory.appointment)) return;
    
    final template = _defaultTemplates.firstWhere((t) => t.id == 'appointment_reminder');
    final notification = template.createNotification(appointmentData);
    
    // Schedule for 24 hours before appointment
    final scheduledAt = DateTime.parse(appointmentData['appointmentTime'] as String)
        .subtract(const Duration(hours: 24));
    
    final scheduledNotification = notification.copyWith(scheduledAt: scheduledAt);
    await scheduleNotification(scheduledNotification);
  }

  static Future<void> triggerCaringSuggestion(String partnerName, String suggestion) async {
    final settings = await getSettings();
    if (!settings.isCategoryEnabled(NotificationCategory.caring)) return;
    
    final template = _defaultTemplates.firstWhere((t) => t.id == 'caring_suggestion');
    final notification = template.createNotification({
      'partner': partnerName,
      'suggestion': suggestion,
    });
    
    await saveNotification(notification);
  }

  static Future<void> triggerLoyaltyNotification(String type, Map<String, dynamic> data) async {
    final settings = await getSettings();
    if (!settings.isCategoryEnabled(NotificationCategory.loyalty)) return;
    
    String templateId;
    switch (type) {
      case 'points_earned':
        templateId = 'points_earned';
        break;
      case 'tier_upgrade':
        templateId = 'tier_upgrade';
        break;
      default:
        return;
    }
    
    final template = _defaultTemplates.firstWhere((t) => t.id == templateId);
    final notification = template.createNotification(data);
    
    await saveNotification(notification);
  }

  // Utility methods
  static DateTime _findNextAllowedTime(DateTime original, NotificationSettings settings) {
    var candidate = original;
    
    // Find next allowed time within 7 days
    for (int i = 0; i < 7 * 24; i++) {
      if (settings.isTimeAllowed(candidate)) {
        return candidate;
      }
      candidate = candidate.add(const Duration(hours: 1));
    }
    
    // If no allowed time found, return original
    return original;
  }

  static String _getPhaseDisplayName(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstruation:
        return 'menstruelle';
      case CyclePhase.follicular:
        return 'folliculaire';
      case CyclePhase.ovulation:
        return 'd\'ovulation';
      case CyclePhase.luteal:
        return 'lutéale';
    }
  }

  static String generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'notif_${timestamp}_${(timestamp % 10000).toString().padLeft(4, '0')}';
  }

  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'à l\'instant';
    }
  }

  // Integration methods
  static Future<void> onCyclePhaseChange(CyclePhase newPhase) async {
    await triggerCycleNotification(newPhase);
  }

  static Future<void> onCaringActionSuggested(String partnerName, String suggestion) async {
    await triggerCaringSuggestion(partnerName, suggestion);
  }

  static Future<void> onPointsEarned(int points, String reason, int total) async {
    await triggerLoyaltyNotification('points_earned', {
      'points': points,
      'reason': reason,
      'total': total,
    });
  }

  static Future<void> onTierUpgrade(String tierName) async {
    await triggerLoyaltyNotification('tier_upgrade', {
      'tier': tierName,
    });
  }

  static Future<void> onOrderStatusUpdate(String orderNumber, String status) async {
    final settings = await getSettings();
    if (!settings.isCategoryEnabled(NotificationCategory.shop)) return;
    
    final template = _defaultTemplates.firstWhere((t) => t.id == 'order_update');
    final notification = template.createNotification({
      'orderNumber': orderNumber,
      'status': _getOrderStatusDisplayName(status),
    });
    
    await saveNotification(notification);
  }

  static String _getOrderStatusDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'confirmée';
      case 'preparing':
        return 'en préparation';
      case 'shipped':
        return 'expédiée';
      case 'delivered':
        return 'livrée';
      case 'cancelled':
        return 'annulée';
      default:
        return status;
    }
  }

  // Daily notification processing
  static Future<void> processDailyNotifications() async {
    await processPendingNotifications();
    
    // Process recurring rules
    final now = DateTime.now();
    final hour = now.hour;
    
    // Morning cycle check (9 AM)
    if (hour == 9) {
      await triggerCycleNotification(CyclePhase.menstruation, context: {
        'daily_check': true,
      });
    }
    
    // Hydration reminders during day (every 3 hours)
    if (hour % 3 == 0 && hour >= 9 && hour <= 21) {
      final settings = await getSettings();
      if (settings.isCategoryEnabled(NotificationCategory.health)) {
        final template = _defaultTemplates.firstWhere((t) => t.id == 'hydration_reminder');
        final notification = template.createNotification({
          'phase': 'votre cycle actuel',
        });
        
        await saveNotification(notification);
      }
    }
  }

  // Sample data creation
  static Future<void> createSampleNotifications() async {
    final now = DateTime.now();
    
    final sampleNotifications = [
      _defaultTemplates.firstWhere((t) => t.id == 'cycle_phase_start').createNotification({
        'phase': 'menstruelle',
        'message': 'Prenez soin de vous et écoutez votre corps.',
      }).copyWith(
        createdAt: now.subtract(const Duration(hours: 2)),
        status: NotificationStatus.sent,
        sentAt: now.subtract(const Duration(hours: 2)),
      ),
      
      _defaultTemplates.firstWhere((t) => t.id == 'caring_suggestion').createNotification({
        'partner': 'votre partenaire',
        'suggestion': 'Préparez-lui une tisane apaisante',
      }).copyWith(
        createdAt: now.subtract(const Duration(hours: 6)),
        status: NotificationStatus.sent,
        sentAt: now.subtract(const Duration(hours: 6)),
      ),
      
      _defaultTemplates.firstWhere((t) => t.id == 'points_earned').createNotification({
        'points': 25,
        'reason': 'Action caring accomplie',
        'total': 156,
      }).copyWith(
        createdAt: now.subtract(const Duration(days: 1)),
        status: NotificationStatus.read,
        sentAt: now.subtract(const Duration(days: 1)),
        readAt: now.subtract(const Duration(hours: 20)),
      ),
    ];
    
    for (final notification in sampleNotifications) {
      await saveNotification(notification);
    }
  }
}