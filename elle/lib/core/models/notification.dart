import 'package:flutter/material.dart';

enum NotificationCategory {
  cycle,
  health,
  caring,
  partner,
  appointment,
  loyalty,
  shop,
  general,
}

enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

enum NotificationStatus {
  pending,
  scheduled,
  sent,
  delivered,
  read,
  dismissed,
  failed,
}

enum CyclePhase {
  menstruation,
  follicular,
  ovulation,
  luteal,
}

class NotificationSettings {
  final bool enabled;
  final Map<NotificationCategory, bool> categorySettings;
  final Map<String, bool> specificSettings;
  final TimeOfDay? quietHoursStart;
  final TimeOfDay? quietHoursEnd;
  final bool weekendsEnabled;
  final List<int> enabledDays; // 1=Monday, 7=Sunday
  final String preferredLanguage;

  const NotificationSettings({
    this.enabled = true,
    this.categorySettings = const {},
    this.specificSettings = const {},
    this.quietHoursStart,
    this.quietHoursEnd,
    this.weekendsEnabled = true,
    this.enabledDays = const [1, 2, 3, 4, 5, 6, 7],
    this.preferredLanguage = 'fr',
  });

  NotificationSettings copyWith({
    bool? enabled,
    Map<NotificationCategory, bool>? categorySettings,
    Map<String, bool>? specificSettings,
    TimeOfDay? quietHoursStart,
    TimeOfDay? quietHoursEnd,
    bool? weekendsEnabled,
    List<int>? enabledDays,
    String? preferredLanguage,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      categorySettings: categorySettings ?? this.categorySettings,
      specificSettings: specificSettings ?? this.specificSettings,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      weekendsEnabled: weekendsEnabled ?? this.weekendsEnabled,
      enabledDays: enabledDays ?? this.enabledDays,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
    );
  }

  bool isCategoryEnabled(NotificationCategory category) {
    if (!enabled) return false;
    return categorySettings[category] ?? true;
  }

  bool isTimeAllowed(DateTime time) {
    if (!enabled) return false;
    
    // Check if day is enabled
    final weekday = time.weekday;
    if (!enabledDays.contains(weekday)) return false;
    
    // Check weekend setting
    if (!weekendsEnabled && (weekday == 6 || weekday == 7)) return false;
    
    // Check quiet hours
    if (quietHoursStart != null && quietHoursEnd != null) {
      final currentTime = TimeOfDay.fromDateTime(time);
      final start = quietHoursStart!;
      final end = quietHoursEnd!;
      
      // Handle quiet hours that span midnight
      if (start.hour > end.hour || (start.hour == end.hour && start.minute > end.minute)) {
        // Quiet hours span midnight (e.g., 22:00 to 08:00)
        if (currentTime.hour >= start.hour || 
            currentTime.hour <= end.hour ||
            (currentTime.hour == start.hour && currentTime.minute >= start.minute) ||
            (currentTime.hour == end.hour && currentTime.minute <= end.minute)) {
          return false;
        }
      } else {
        // Normal quiet hours (e.g., 22:00 to 23:00)
        if ((currentTime.hour > start.hour || (currentTime.hour == start.hour && currentTime.minute >= start.minute)) &&
            (currentTime.hour < end.hour || (currentTime.hour == end.hour && currentTime.minute <= end.minute))) {
          return false;
        }
      }
    }
    
    return true;
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'categorySettings': categorySettings.map((k, v) => MapEntry(k.name, v)),
      'specificSettings': specificSettings,
      'quietHoursStart': quietHoursStart != null 
          ? {'hour': quietHoursStart!.hour, 'minute': quietHoursStart!.minute}
          : null,
      'quietHoursEnd': quietHoursEnd != null 
          ? {'hour': quietHoursEnd!.hour, 'minute': quietHoursEnd!.minute}
          : null,
      'weekendsEnabled': weekendsEnabled,
      'enabledDays': enabledDays,
      'preferredLanguage': preferredLanguage,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enabled: json['enabled'] as bool? ?? true,
      categorySettings: (json['categorySettings'] as Map? ?? {}).map(
        (k, v) => MapEntry(
          NotificationCategory.values.firstWhere(
            (e) => e.name == k,
            orElse: () => NotificationCategory.general,
          ),
          v as bool,
        ),
      ),
      specificSettings: Map<String, bool>.from(json['specificSettings'] as Map? ?? {}),
      quietHoursStart: json['quietHoursStart'] != null
          ? TimeOfDay(
              hour: json['quietHoursStart']['hour'] as int,
              minute: json['quietHoursStart']['minute'] as int,
            )
          : null,
      quietHoursEnd: json['quietHoursEnd'] != null
          ? TimeOfDay(
              hour: json['quietHoursEnd']['hour'] as int,
              minute: json['quietHoursEnd']['minute'] as int,
            )
          : null,
      weekendsEnabled: json['weekendsEnabled'] as bool? ?? true,
      enabledDays: List<int>.from(json['enabledDays'] as List? ?? [1, 2, 3, 4, 5, 6, 7]),
      preferredLanguage: json['preferredLanguage'] as String? ?? 'fr',
    );
  }
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationCategory category;
  final NotificationPriority priority;
  final NotificationStatus status;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final DateTime? sentAt;
  final DateTime? readAt;
  final Map<String, dynamic> data;
  final List<NotificationAction> actions;
  final String? imageUrl;
  final String? sound;
  final bool persistent;
  final String? channelId;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    this.priority = NotificationPriority.normal,
    this.status = NotificationStatus.pending,
    required this.createdAt,
    this.scheduledAt,
    this.sentAt,
    this.readAt,
    this.data = const {},
    this.actions = const [],
    this.imageUrl,
    this.sound,
    this.persistent = false,
    this.channelId,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationCategory? category,
    NotificationPriority? priority,
    NotificationStatus? status,
    DateTime? createdAt,
    DateTime? scheduledAt,
    DateTime? sentAt,
    DateTime? readAt,
    Map<String, dynamic>? data,
    List<NotificationAction>? actions,
    String? imageUrl,
    String? sound,
    bool? persistent,
    String? channelId,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      sentAt: sentAt ?? this.sentAt,
      readAt: readAt ?? this.readAt,
      data: data ?? this.data,
      actions: actions ?? this.actions,
      imageUrl: imageUrl ?? this.imageUrl,
      sound: sound ?? this.sound,
      persistent: persistent ?? this.persistent,
      channelId: channelId ?? this.channelId,
    );
  }

  bool get isRead => readAt != null;
  bool get isSent => sentAt != null;
  bool get isScheduled => scheduledAt != null && scheduledAt!.isAfter(DateTime.now());
  bool get isOverdue => scheduledAt != null && scheduledAt!.isBefore(DateTime.now()) && !isSent;

  String get categoryDisplayName {
    switch (category) {
      case NotificationCategory.cycle:
        return 'Cycle menstruel';
      case NotificationCategory.health:
        return 'Santé';
      case NotificationCategory.caring:
        return 'Attention caring';
      case NotificationCategory.partner:
        return 'Partenaire';
      case NotificationCategory.appointment:
        return 'Rendez-vous';
      case NotificationCategory.loyalty:
        return 'Fidélité';
      case NotificationCategory.shop:
        return 'Boutique';
      case NotificationCategory.general:
        return 'Général';
    }
  }

  String get priorityDisplayName {
    switch (priority) {
      case NotificationPriority.low:
        return 'Faible';
      case NotificationPriority.normal:
        return 'Normale';
      case NotificationPriority.high:
        return 'Élevée';
      case NotificationPriority.urgent:
        return 'Urgente';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'category': category.name,
      'priority': priority.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'scheduledAt': scheduledAt?.toIso8601String(),
      'sentAt': sentAt?.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'data': data,
      'actions': actions.map((a) => a.toJson()).toList(),
      'imageUrl': imageUrl,
      'sound': sound,
      'persistent': persistent,
      'channelId': channelId,
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      category: NotificationCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => NotificationCategory.general,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => NotificationPriority.normal,
      ),
      status: NotificationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => NotificationStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.parse(json['scheduledAt'] as String)
          : null,
      sentAt: json['sentAt'] != null
          ? DateTime.parse(json['sentAt'] as String)
          : null,
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
      data: Map<String, dynamic>.from(json['data'] as Map? ?? {}),
      actions: (json['actions'] as List? ?? [])
          .map((a) => NotificationAction.fromJson(a))
          .toList(),
      imageUrl: json['imageUrl'] as String?,
      sound: json['sound'] as String?,
      persistent: json['persistent'] as bool? ?? false,
      channelId: json['channelId'] as String?,
    );
  }
}

class NotificationAction {
  final String id;
  final String title;
  final String? icon;
  final Map<String, dynamic> data;

  const NotificationAction({
    required this.id,
    required this.title,
    this.icon,
    this.data = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
      'data': data,
    };
  }

  factory NotificationAction.fromJson(Map<String, dynamic> json) {
    return NotificationAction(
      id: json['id'] as String,
      title: json['title'] as String,
      icon: json['icon'] as String?,
      data: Map<String, dynamic>.from(json['data'] as Map? ?? {}),
    );
  }
}

class NotificationTemplate {
  final String id;
  final String name;
  final NotificationCategory category;
  final String titleTemplate;
  final String bodyTemplate;
  final NotificationPriority priority;
  final Map<String, dynamic> defaultData;
  final List<NotificationAction> actions;
  final String? sound;
  final bool persistent;

  const NotificationTemplate({
    required this.id,
    required this.name,
    required this.category,
    required this.titleTemplate,
    required this.bodyTemplate,
    this.priority = NotificationPriority.normal,
    this.defaultData = const {},
    this.actions = const [],
    this.sound,
    this.persistent = false,
  });

  AppNotification createNotification(Map<String, dynamic> variables) {
    final title = _replaceVariables(titleTemplate, variables);
    final body = _replaceVariables(bodyTemplate, variables);
    final data = Map<String, dynamic>.from(defaultData)..addAll(variables);

    return AppNotification(
      id: _generateId(),
      title: title,
      body: body,
      category: category,
      priority: priority,
      createdAt: DateTime.now(),
      data: data,
      actions: actions,
      sound: sound,
      persistent: persistent,
    );
  }

  String _replaceVariables(String template, Map<String, dynamic> variables) {
    String result = template;
    for (final entry in variables.entries) {
      result = result.replaceAll('{{${entry.key}}}', entry.value.toString());
    }
    return result;
  }

  String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'notif_${timestamp}_${(timestamp % 10000).toString().padLeft(4, '0')}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.name,
      'titleTemplate': titleTemplate,
      'bodyTemplate': bodyTemplate,
      'priority': priority.name,
      'defaultData': defaultData,
      'actions': actions.map((a) => a.toJson()).toList(),
      'sound': sound,
      'persistent': persistent,
    };
  }

  factory NotificationTemplate.fromJson(Map<String, dynamic> json) {
    return NotificationTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      category: NotificationCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => NotificationCategory.general,
      ),
      titleTemplate: json['titleTemplate'] as String,
      bodyTemplate: json['bodyTemplate'] as String,
      priority: NotificationPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => NotificationPriority.normal,
      ),
      defaultData: Map<String, dynamic>.from(json['defaultData'] as Map? ?? {}),
      actions: (json['actions'] as List? ?? [])
          .map((a) => NotificationAction.fromJson(a))
          .toList(),
      sound: json['sound'] as String?,
      persistent: json['persistent'] as bool? ?? false,
    );
  }
}

class NotificationRule {
  final String id;
  final String name;
  final NotificationTemplate template;
  final String triggerCondition;
  final Duration? delay;
  final bool recurring;
  final String? cronExpression;
  final bool enabled;
  final Map<String, dynamic> conditions;

  const NotificationRule({
    required this.id,
    required this.name,
    required this.template,
    required this.triggerCondition,
    this.delay,
    this.recurring = false,
    this.cronExpression,
    this.enabled = true,
    this.conditions = const {},
  });

  bool shouldTrigger(Map<String, dynamic> context) {
    if (!enabled) return false;
    
    // Evaluate conditions based on context
    for (final entry in conditions.entries) {
      final key = entry.key;
      final expectedValue = entry.value;
      final actualValue = context[key];
      
      if (actualValue != expectedValue) {
        return false;
      }
    }
    
    return true;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'template': template.toJson(),
      'triggerCondition': triggerCondition,
      'delay': delay?.inMilliseconds,
      'recurring': recurring,
      'cronExpression': cronExpression,
      'enabled': enabled,
      'conditions': conditions,
    };
  }

  factory NotificationRule.fromJson(Map<String, dynamic> json) {
    return NotificationRule(
      id: json['id'] as String,
      name: json['name'] as String,
      template: NotificationTemplate.fromJson(json['template']),
      triggerCondition: json['triggerCondition'] as String,
      delay: json['delay'] != null 
          ? Duration(milliseconds: json['delay'] as int)
          : null,
      recurring: json['recurring'] as bool? ?? false,
      cronExpression: json['cronExpression'] as String?,
      enabled: json['enabled'] as bool? ?? true,
      conditions: Map<String, dynamic>.from(json['conditions'] as Map? ?? {}),
    );
  }
}