import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../core/models/partner.dart';
import '../services/partner_service.dart';
import '../widgets/partner/partner_connection_widget.dart';
import '../widgets/partner/partner_dashboard_widget.dart';
import '../widgets/partner/partner_notifications_widget.dart';
import '../widgets/partner/care_gestures_widget.dart';

class PartnerScreen extends StatefulWidget {
  const PartnerScreen({Key? key}) : super(key: key);

  @override
  State<PartnerScreen> createState() => _PartnerScreenState();
}

class _PartnerScreenState extends State<PartnerScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _staggerController;
  late TabController _tabController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _headerAnimation;

  Partner? _connectedPartner;
  List<PartnerNotificationItem> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadPartnerData();
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

    _tabController = TabController(length: 3, vsync: this);

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

  Future<void> _loadPartnerData() async {
    setState(() => _isLoading = true);
    
    try {
      final [partner, notifications] = await Future.wait([
        PartnerService.getConnectedPartner(),
        PartnerService.getPartnerNotifications(),
      ]);

      setState(() {
        _connectedPartner = partner as Partner?;
        _notifications = []; // Mock notifications for now
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onPartnerConnected() {
    _loadPartnerData();
  }

  void _onPartnerDisconnected() {
    setState(() {
      _connectedPartner = null;
      _notifications = [];
    });
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
                      color: AppTheme.primaryPink.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.favorite_outline,
                      color: AppTheme.primaryPink,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _connectedPartner != null ? 'Mon Partenaire' : 'Connexion Partenaire',
                          style: AppTheme.headerStyle.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          _connectedPartner != null 
                              ? _connectedPartner!.name 
                              : 'Connectez votre partenaire',
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
        if (_connectedPartner != null) ...[
          IconButton(
            onPressed: () => _showPartnerMenu(),
            icon: Icon(
              Icons.more_vert,
              color: AppTheme.primaryPink,
            ),
          ),
        ],
      ],
      bottom: _connectedPartner != null ? TabBar(
        controller: _tabController,
        indicatorColor: AppTheme.primaryPink,
        labelColor: AppTheme.primaryPink,
        unselectedLabelColor: AppTheme.lightGray,
        labelStyle: AppTheme.bodyTextStyle.copyWith(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Tableau de bord'),
          Tab(text: 'Notifications'),
          Tab(text: 'Gestes d\'attention'),
        ],
      ) : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_connectedPartner == null) {
      return PartnerConnectionWidget(
        onPartnerConnected: _onPartnerConnected,
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        PartnerDashboardWidget(
          isConnected: _connectedPartner != null,
          partnerName: _connectedPartner?.name,
          syncData: _connectedPartner != null ? {
            'currentPhase': 'Menstruelle',
            'nextPeriod': '5 jours',
            'symptoms': 'Légers',
            'mood': 'Positive',
          } : null,
        ),
        PartnerNotificationsWidget(
          notifications: _notifications,
          onNotificationTap: (notification) {
            // Handle notification tap
          },
          onNotificationDismiss: (notification) {
            // Handle notification dismiss
            _loadPartnerData();
          },
        ),
        CareGesturesWidget(
          gestures: [
            CareGesture(
              id: '1',
              title: 'Massage relaxant',
              description: 'Offrez un massage des épaules',
              category: GestureCategory.caring,
              pointsValue: 20,
              emoji: '💆‍♀️',
            ),
            CareGesture(
              id: '2',
              title: 'Tisane apaisante',
              description: 'Préparez une tisane de camomille',
              category: GestureCategory.supportive,
              pointsValue: 15,
              emoji: '🍵',
            ),
          ],
          onGestureComplete: (gesture) {
            _loadPartnerData();
          },
          onGestureDetails: (gesture) {
            // Show gesture details
          },
        ),
      ],
    );
  }

  void _showPartnerMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.lightGray.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 20),

              // Menu items
              _buildMenuItem(
                icon: Icons.settings,
                title: 'Paramètres de notification',
                onTap: () {
                  Navigator.of(context).pop();
                  _showNotificationSettings();
                },
              ),
              _buildMenuItem(
                icon: Icons.pause,
                title: 'Mettre en pause',
                onTap: () {
                  Navigator.of(context).pop();
                  _pausePartnership();
                },
              ),
              _buildMenuItem(
                icon: Icons.link_off,
                title: 'Déconnecter',
                color: Colors.red,
                onTap: () {
                  Navigator.of(context).pop();
                  _showDisconnectDialog();
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? AppTheme.primaryPink,
      ),
      title: Text(
        title,
        style: AppTheme.bodyTextStyle.copyWith(
          color: color ?? AppTheme.darkText,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showNotificationSettings() {
    // Implementation for notification settings dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Paramètres de notification',
          style: AppTheme.subHeaderStyle.copyWith(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Configurez les types de notifications que votre partenaire recevra.',
          style: AppTheme.bodyTextStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Fermer',
              style: AppTheme.bodyTextStyle.copyWith(color: AppTheme.primaryPink),
            ),
          ),
        ],
      ),
    );
  }

  void _pausePartnership() async {
    final success = await PartnerService.pausePartnership();
    if (success) {
      _loadPartnerData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Partenariat mis en pause'),
            backgroundColor: AppTheme.primaryPink,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _showDisconnectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Déconnecter le partenaire',
          style: AppTheme.subHeaderStyle.copyWith(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir déconnecter votre partenaire ? Cette action supprimera toutes les données partagées.',
          style: AppTheme.bodyTextStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Annuler',
              style: AppTheme.bodyTextStyle.copyWith(color: AppTheme.lightGray),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await PartnerService.disconnectPartner();
              if (success) {
                _onPartnerDisconnected();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Partenaire déconnecté'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Déconnecter',
              style: AppTheme.bodyTextStyle.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}