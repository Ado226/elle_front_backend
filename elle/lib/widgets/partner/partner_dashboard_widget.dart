import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class PartnerDashboardWidget extends StatefulWidget {
  final bool isConnected;
  final String? partnerName;
  final Map<String, dynamic>? syncData;

  const PartnerDashboardWidget({
    Key? key,
    required this.isConnected,
    this.partnerName,
    this.syncData,
  }) : super(key: key);

  @override
  State<PartnerDashboardWidget> createState() => _PartnerDashboardWidgetState();
}

class _PartnerDashboardWidgetState extends State<PartnerDashboardWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
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
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.cardDecoration,
              child: widget.isConnected ? _buildConnectedView() : _buildDisconnectedView(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildConnectedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with partner info
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.favorite,
                color: Colors.green,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connecté avec ${widget.partnerName ?? 'Votre partenaire'}',
                    style: AppTheme.bodyTextStyle.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    'Synchronisation active',
                    style: AppTheme.captionStyle.copyWith(
                      color: AppTheme.lightGray,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Sync status
        _buildSyncStatusSection(),

        const SizedBox(height: 20),

        // Quick actions
        _buildQuickActionsSection(),

        const SizedBox(height: 20),

        // Recent activity
        _buildRecentActivitySection(),
      ],
    );
  }

  Widget _buildDisconnectedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.lightGray.withOpacity(0.1),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Icon(
            Icons.people_outline,
            color: AppTheme.lightGray,
            size: 40,
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'Aucune connexion partenaire',
          style: AppTheme.subHeaderStyle.copyWith(
            color: AppTheme.lightGray,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Invitez votre partenaire à rejoindre votre suivi de cycle',
          style: AppTheme.captionStyle.copyWith(
            color: AppTheme.lightGray,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showConnectionDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Connecter un partenaire'),
            style: AppTheme.primaryButtonStyle,
          ),
        ),
      ],
    );
  }

  Widget _buildSyncStatusSection() {
    final syncData = widget.syncData ?? {};
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryPink.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryPink.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'État de synchronisation',
            style: AppTheme.bodyTextStyle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildSyncItem(
                  'Phase actuelle',
                  syncData['currentPhase'] ?? 'Menstruelle',
                  Icons.calendar_month,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.lightGray.withOpacity(0.3),
              ),
              Expanded(
                child: _buildSyncItem(
                  'Prochaine période',
                  syncData['nextPeriod'] ?? '5 jours',
                  Icons.schedule,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildSyncItem(
                  'Symptômes',
                  syncData['symptoms'] ?? 'Légers',
                  Icons.favorite,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.lightGray.withOpacity(0.3),
              ),
              Expanded(
                child: _buildSyncItem(
                  'Humeur',
                  syncData['mood'] ?? 'Positive',
                  Icons.mood,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSyncItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryPink,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.captionStyle.copyWith(
            color: AppTheme.lightGray,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTheme.captionStyle.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.darkText,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions rapides',
          style: AppTheme.bodyTextStyle.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildQuickActionButton(
              icon: Icons.message,
              label: 'Message',
              color: Colors.blue,
              onTap: () => _sendQuickMessage(),
            ),
            _buildQuickActionButton(
              icon: Icons.notification_important,
              label: 'Rappel',
              color: Colors.orange,
              onTap: () => _setReminder(),
            ),
            _buildQuickActionButton(
              icon: Icons.favorite,
              label: 'Soutien',
              color: Colors.red,
              onTap: () => _sendSupport(),
            ),
            _buildQuickActionButton(
              icon: Icons.settings,
              label: 'Paramètres',
              color: AppTheme.lightGray,
              onTap: () => _openSettings(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(22.5),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTheme.captionStyle.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    final activities = [
      'Partenaire a envoyé un message de soutien',
      'Synchronisation des données effectuée',
      'Rappel de prise de médicament programmé',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activité récente',
          style: AppTheme.bodyTextStyle.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 12),
        
        ...activities.take(3).map((activity) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.lightGray.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  activity,
                  style: AppTheme.captionStyle.copyWith(
                    color: AppTheme.mediumGray,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  void _showConnectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Connecter un partenaire', style: AppTheme.subHeaderStyle),
        content: const Text('Fonctionnalité de connexion partenaire en cours de développement'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: AppTheme.bodyTextStyle),
          ),
        ],
      ),
    );
  }

  void _sendQuickMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message envoyé à votre partenaire')),
    );
  }

  void _setReminder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rappel programmé')),
    );
  }

  void _sendSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message de soutien envoyé')),
    );
  }

  void _openSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ouverture des paramètres partenaire')),
    );
  }
}