import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../core/models/notification.dart';
import '../services/notification_service.dart';
import '../widgets/notifications/notification_card_widget.dart';
import '../widgets/notifications/notification_settings_widget.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _staggerController;
  late TabController _tabController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _headerAnimation;

  List<AppNotification> _allNotifications = [];
  List<AppNotification> _unreadNotifications = [];
  NotificationSettings _settings = const NotificationSettings();
  Map<NotificationCategory, int> _unreadCounts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadNotificationData();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _tabController = TabController(length: 2, vsync: this);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slideController.forward();
      _fadeController.forward();
      _staggerController.forward();
    });
  }

  Future<void> _loadNotificationData() async {
    setState(() => _isLoading = true);
    
    try {
      final [all, unread, settings] = await Future.wait([
        NotificationService.getNotifications(),
        NotificationService.getNotifications(unreadOnly: true),
        NotificationService.getSettings(),
      ]);

      // Calculate unread counts by category
      final unreadCounts = <NotificationCategory, int>{};
      for (final category in NotificationCategory.values) {
        final count = await NotificationService.getUnreadCount(category: category);
        unreadCounts[category] = count;
      }

      setState(() {
        _allNotifications = all as List<AppNotification>;
        _unreadNotifications = unread as List<AppNotification>;
        _settings = settings as NotificationSettings;
        _unreadCounts = unreadCounts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onNotificationRead(String notificationId) async {
    await NotificationService.markAsRead(notificationId);
    _loadNotificationData();
  }

  void _onNotificationDeleted(String notificationId) async {
    await NotificationService.deleteNotification(notificationId);
    _loadNotificationData();
  }

  void _onSettingsUpdated() {
    _loadNotificationData();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _staggerController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: AnimatedBuilder(
        animation: Listenable.merge([_slideController, _fadeController, _staggerController]),
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildBody(),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.backgroundColor,
      elevation: 0,
      title: AnimatedBuilder(
        animation: _headerAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _headerAnimation.value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - _headerAnimation.value)),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryPink,
                          AppTheme.primaryPink.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.notifications,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notifications',
                          style: AppTheme.headerStyle.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${_unreadNotifications.length} non lue${_unreadNotifications.length > 1 ? 's' : ''}',
                          style: AppTheme.captionStyle.copyWith(
                            fontSize: 12,
                            color: AppTheme.lightGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      actions: [
        IconButton(
          onPressed: () => _showNotificationSettings(),
          icon: Icon(
            Icons.settings,
            color: AppTheme.primaryPink,
          ),
        ),
        if (_unreadNotifications.isNotEmpty)
          IconButton(
            onPressed: () => _markAllAsRead(),
            icon: Icon(
              Icons.done_all,
              color: AppTheme.primaryPink,
            ),
          ),
      ],
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: AppTheme.primaryPink,
        labelColor: AppTheme.primaryPink,
        unselectedLabelColor: AppTheme.lightGray,
        labelStyle: AppTheme.bodyTextStyle.copyWith(fontWeight: FontWeight.w600),
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Non lues'),
                if (_unreadNotifications.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPink,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      '${_unreadNotifications.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Tab(text: 'Toutes'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildUnreadNotifications(),
        _buildAllNotifications(),
      ],
    );
  }

  Widget _buildUnreadNotifications() {
    return RefreshIndicator(
      onRefresh: _loadNotificationData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick stats
            if (_unreadCounts.isNotEmpty) ...[
              _buildUnreadStats(),
              const SizedBox(height: 24),
            ],

            // Unread notifications
            if (_unreadNotifications.isEmpty) ...[
              _buildEmptyUnreadState(),
            ] else ...[
              _buildNotificationsList(_unreadNotifications),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAllNotifications() {
    return RefreshIndicator(
      onRefresh: _loadNotificationData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter by category
            _buildCategoryFilter(),

            const SizedBox(height: 20),

            // All notifications
            if (_allNotifications.isEmpty) ...[
              _buildEmptyAllState(),
            ] else ...[
              _buildNotificationsList(_allNotifications),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildUnreadStats() {
    final activeCategories = _unreadCounts.entries
        .where((entry) => entry.value > 0)
        .toList();

    if (activeCategories.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryPink.withOpacity(0.1),
            AppTheme.primaryPink.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryPink.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: AppTheme.primaryPink,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Notifications par catégorie',
                style: AppTheme.bodyTextStyle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: activeCategories.map((entry) {
              return _buildCategoryChip(entry.key, entry.value);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(NotificationCategory category, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getCategoryColor(category).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getCategoryColor(category).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCategoryIcon(category),
            size: 14,
            color: _getCategoryColor(category),
          ),
          const SizedBox(width: 4),
          Text(
            category.name.substring(0, 1).toUpperCase() + category.name.substring(1),
            style: AppTheme.captionStyle.copyWith(
              color: _getCategoryColor(category),
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: _getCategoryColor(category),
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(
              minWidth: 16,
              minHeight: 16,
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightGray.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_list,
                color: AppTheme.primaryPink,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Filtrer par catégorie',
                style: AppTheme.bodyTextStyle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // Implement category filtering
                },
                child: Text(
                  'Tout voir',
                  style: AppTheme.captionStyle.copyWith(
                    color: AppTheme.primaryPink,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: NotificationCategory.values.map((category) {
              final count = _allNotifications.where((n) => n.category == category).length;
              if (count == 0) return const SizedBox.shrink();
              
              return GestureDetector(
                onTap: () {
                  // Implement category filtering
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getCategoryColor(category).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getCategoryIcon(category),
                        size: 12,
                        color: _getCategoryColor(category),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        category.name,
                        style: AppTheme.captionStyle.copyWith(
                          color: _getCategoryColor(category),
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '($count)',
                        style: AppTheme.captionStyle.copyWith(
                          color: _getCategoryColor(category),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<AppNotification> notifications) {
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: notifications.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final notification = notifications[index];
            final delay = index * 0.1;
            final animation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: _staggerController,
              curve: Interval(delay, delay + 0.3, curve: Curves.easeOutCubic),
            ));

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(animation),
                child: NotificationCardWidget(
                  notification: notification,
                  onRead: () => _onNotificationRead(notification.id),
                  onDelete: () => _onNotificationDeleted(notification.id),
                  onTap: () => _showNotificationDetail(notification),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyUnreadState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightGray.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 48,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Toutes vos notifications sont lues !',
            style: AppTheme.bodyTextStyle.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vous êtes à jour avec toutes vos notifications',
            style: AppTheme.captionStyle.copyWith(
              color: AppTheme.lightGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyAllState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightGray.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.notifications_none,
            size: 48,
            color: AppTheme.lightGray,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune notification',
            style: AppTheme.bodyTextStyle.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vos notifications apparaîtront ici quand vous en recevrez',
            style: AppTheme.captionStyle.copyWith(
              color: AppTheme.lightGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => NotificationSettingsWidget(
          settings: _settings,
          scrollController: scrollController,
          onSettingsUpdated: _onSettingsUpdated,
        ),
      ),
    );
  }

  void _showNotificationDetail(AppNotification notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              _getCategoryIcon(notification.category),
              color: _getCategoryColor(notification.category),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                notification.title,
                style: AppTheme.subHeaderStyle.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              notification.body,
              style: AppTheme.bodyTextStyle,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(notification.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    notification.categoryDisplayName,
                    style: AppTheme.captionStyle.copyWith(
                      color: _getCategoryColor(notification.category),
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  NotificationService.formatTimeAgo(notification.createdAt),
                  style: AppTheme.captionStyle.copyWith(
                    color: AppTheme.lightGray,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (!notification.isRead)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _onNotificationRead(notification.id);
              },
              child: Text(
                'Marquer comme lue',
                style: AppTheme.bodyTextStyle.copyWith(color: AppTheme.primaryPink),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Fermer',
              style: AppTheme.bodyTextStyle.copyWith(color: AppTheme.lightGray),
            ),
          ),
        ],
      ),
    );
  }

  void _markAllAsRead() async {
    for (final notification in _unreadNotifications) {
      await NotificationService.markAsRead(notification.id);
    }
    _loadNotificationData();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_unreadNotifications.length} notification(s) marquée(s) comme lue(s)'),
          backgroundColor: AppTheme.primaryPink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
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
}