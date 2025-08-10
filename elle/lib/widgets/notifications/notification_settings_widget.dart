import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../core/models/notification.dart';
import '../../services/notification_service.dart';

class NotificationSettingsWidget extends StatefulWidget {
  final NotificationSettings settings;
  final ScrollController scrollController;
  final VoidCallback? onSettingsUpdated;

  const NotificationSettingsWidget({
    Key? key,
    required this.settings,
    required this.scrollController,
    this.onSettingsUpdated,
  }) : super(key: key);

  @override
  State<NotificationSettingsWidget> createState() => _NotificationSettingsWidgetState();
}

class _NotificationSettingsWidgetState extends State<NotificationSettingsWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  late NotificationSettings _currentSettings;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentSettings = widget.settings;
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slideController.forward();
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);

    try {
      await NotificationService.updateSettings(_currentSettings);
      widget.onSettingsUpdated?.call();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Paramètres sauvegardés avec succès'),
            backgroundColor: AppTheme.primaryPink,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erreur lors de la sauvegarde'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: AnimatedBuilder(
        animation: Listenable.merge([_slideController, _fadeController]),
        builder: (context, child) {
          return SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Handle bar
                  _buildHandleBar(),

                  // Header
                  _buildHeader(),

                  // Settings content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: widget.scrollController,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // General settings
                          _buildGeneralSettings(),

                          const SizedBox(height: 24),

                          // Category settings
                          _buildCategorySettings(),

                          const SizedBox(height: 24),

                          // Schedule settings
                          _buildScheduleSettings(),

                          const SizedBox(height: 24),

                          // Advanced settings
                          _buildAdvancedSettings(),

                          const SizedBox(height: 32),

                          // Save button
                          _buildSaveButton(),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHandleBar() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.lightGray.withOpacity(0.5),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.lightGray.withOpacity(0.2),
          ),
        ),
      ),
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
              Icons.settings,
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
                  'Paramètres de notification',
                  style: AppTheme.headerStyle.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Personnalisez vos préférences',
                  style: AppTheme.captionStyle.copyWith(
                    color: AppTheme.lightGray,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: AppTheme.lightGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralSettings() {
    return _buildSettingsSection(
      title: 'Paramètres généraux',
      subtitle: 'Contrôle global des notifications',
      icon: Icons.tune,
      children: [
        _buildSwitchTile(
          title: 'Activer les notifications',
          subtitle: 'Recevoir toutes les notifications de l\'app',
          value: _currentSettings.enabled,
          onChanged: (value) {
            setState(() {
              _currentSettings = _currentSettings.copyWith(enabled: value);
            });
          },
        ),
        
        if (_currentSettings.enabled) ...[ 
          const SizedBox(height: 12),
          _buildSwitchTile(
            title: 'Notifications le week-end',
            subtitle: 'Recevoir des notifications samedi et dimanche',
            value: _currentSettings.weekendsEnabled,
            onChanged: (value) {
              setState(() {
                _currentSettings = _currentSettings.copyWith(weekendsEnabled: value);
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _buildCategorySettings() {
    return _buildSettingsSection(
      title: 'Par catégorie',
      subtitle: 'Choisissez les types de notifications',
      icon: Icons.category,
      children: NotificationCategory.values.map((category) {
        final isEnabled = _currentSettings.isCategoryEnabled(category);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildSwitchTile(
            title: _getCategoryDisplayName(category),
            subtitle: _getCategoryDescription(category),
            value: isEnabled,
            onChanged: _currentSettings.enabled 
                ? (value) {
                    setState(() {
                      final newCategorySettings = Map<NotificationCategory, bool>.from(_currentSettings.categorySettings);
                      newCategorySettings[category] = value;
                      _currentSettings = _currentSettings.copyWith(categorySettings: newCategorySettings);
                    });
                  }
                : null,
            leadingIcon: _getCategoryIcon(category),
            leadingColor: _getCategoryColor(category),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildScheduleSettings() {
    return _buildSettingsSection(
      title: 'Horaires',
      subtitle: 'Définissez vos créneaux préférés',
      icon: Icons.schedule,
      children: [
        // Quiet hours
        _buildQuietHoursSelector(),
        
        const SizedBox(height: 16),
        
        // Active days
        _buildActiveDaysSelector(),
      ],
    );
  }

  Widget _buildAdvancedSettings() {
    return _buildSettingsSection(
      title: 'Paramètres avancés',
      subtitle: 'Options de personnalisation',
      icon: Icons.tune,
      children: [
        _buildLanguageSelector(),
        
        const SizedBox(height: 16),
        
        _buildTestNotificationButton(),
      ],
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
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
                icon,
                color: AppTheme.primaryPink,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.subHeaderStyle.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTheme.captionStyle.copyWith(
                        color: AppTheme.lightGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
    IconData? leadingIcon,
    Color? leadingColor,
  }) {
    return Row(
      children: [
        if (leadingIcon != null) ...[ 
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: (leadingColor ?? AppTheme.primaryPink).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              leadingIcon,
              color: leadingColor ?? AppTheme.primaryPink,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
        ],
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.bodyTextStyle.copyWith(
                  fontWeight: FontWeight.w600,
                  color: onChanged != null ? AppTheme.darkText : AppTheme.lightGray,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTheme.captionStyle.copyWith(
                  color: AppTheme.lightGray,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryPink,
          inactiveThumbColor: AppTheme.lightGray,
        ),
      ],
    );
  }

  Widget _buildQuietHoursSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.bedtime,
              color: AppTheme.primaryPink,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Heures de silence',
              style: AppTheme.bodyTextStyle.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTimeSelector(
                label: 'Début',
                time: _currentSettings.quietHoursStart,
                onTimeSelected: (time) {
                  setState(() {
                    _currentSettings = _currentSettings.copyWith(quietHoursStart: time);
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTimeSelector(
                label: 'Fin',
                time: _currentSettings.quietHoursEnd,
                onTimeSelected: (time) {
                  setState(() {
                    _currentSettings = _currentSettings.copyWith(quietHoursEnd: time);
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeSelector({
    required String label,
    required TimeOfDay? time,
    required ValueChanged<TimeOfDay?> onTimeSelected,
  }) {
    return GestureDetector(
      onTap: () async {
        final selectedTime = await showTimePicker(
          context: context,
          initialTime: time ?? const TimeOfDay(hour: 22, minute: 0),
        );
        if (selectedTime != null) {
          onTimeSelected(selectedTime);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.lightGray.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.lightGray.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTheme.captionStyle.copyWith(
                color: AppTheme.lightGray,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time != null 
                  ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
                  : 'Non défini',
              style: AppTheme.bodyTextStyle.copyWith(
                fontWeight: FontWeight.w600,
                color: time != null ? AppTheme.darkText : AppTheme.lightGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveDaysSelector() {
    final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: AppTheme.primaryPink,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Jours actifs',
              style: AppTheme.bodyTextStyle.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(7, (index) {
            final dayNumber = index + 1;
            final isEnabled = _currentSettings.enabledDays.contains(dayNumber);
            
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index < 6 ? 4 : 0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      final newEnabledDays = List<int>.from(_currentSettings.enabledDays);
                      if (isEnabled) {
                        newEnabledDays.remove(dayNumber);
                      } else {
                        newEnabledDays.add(dayNumber);
                      }
                      _currentSettings = _currentSettings.copyWith(enabledDays: newEnabledDays);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isEnabled 
                          ? AppTheme.primaryPink 
                          : AppTheme.lightGray.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isEnabled 
                            ? AppTheme.primaryPink 
                            : AppTheme.lightGray.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      days[index],
                      style: AppTheme.captionStyle.copyWith(
                        color: isEnabled ? Colors.white : AppTheme.lightGray,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildLanguageSelector() {
    return Row(
      children: [
        Icon(
          Icons.language,
          color: AppTheme.primaryPink,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Langue',
                style: AppTheme.bodyTextStyle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Français (par défaut)',
                style: AppTheme.captionStyle.copyWith(
                  color: AppTheme.lightGray,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.primaryPink.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'FR',
            style: AppTheme.captionStyle.copyWith(
              color: AppTheme.primaryPink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTestNotificationButton() {
    return GestureDetector(
      onTap: _sendTestNotification,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.primaryPink.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.primaryPink.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.notification_add,
              color: AppTheme.primaryPink,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Envoyer une notification test',
                style: AppTheme.bodyTextStyle.copyWith(
                  color: AppTheme.primaryPink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.primaryPink,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveSettings,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryPink,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Sauvegarder les paramètres',
                style: AppTheme.bodyTextStyle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  void _sendTestNotification() async {
    try {
      // Create a test notification
      final testNotification = AppNotification(
        id: 'test_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Notification test',
        body: 'Ceci est une notification de test pour vérifier vos paramètres.',
        category: NotificationCategory.general,
        createdAt: DateTime.now(),
        status: NotificationStatus.sent,
        sentAt: DateTime.now(),
      );

      await NotificationService.saveNotification(testNotification);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification test envoyée !'),
            backgroundColor: AppTheme.primaryPink,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erreur lors de l\'envoi du test'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  String _getCategoryDisplayName(NotificationCategory category) {
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

  String _getCategoryDescription(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.cycle:
        return 'Rappels de phases, symptômes';
      case NotificationCategory.health:
        return 'Conseils santé, hydratation';
      case NotificationCategory.caring:
        return 'Suggestions d\'attention';
      case NotificationCategory.partner:
        return 'Informations partenaire';
      case NotificationCategory.appointment:
        return 'Rappels de rendez-vous';
      case NotificationCategory.loyalty:
        return 'Points, récompenses';
      case NotificationCategory.shop:
        return 'Commandes, promotions';
      case NotificationCategory.general:
        return 'Informations générales';
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
}