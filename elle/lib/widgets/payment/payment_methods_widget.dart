import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../core/models/payment.dart';
import '../../services/payment_service.dart';

class PaymentMethodsWidget extends StatefulWidget {
  final List<PaymentMethod> paymentMethods;
  final PaymentSettings settings;
  final Function(PaymentMethod) onMethodUpdated;
  final Function(String) onMethodDeleted;
  final VoidCallback onAddMethod;

  const PaymentMethodsWidget({
    Key? key,
    required this.paymentMethods,
    required this.settings,
    required this.onMethodUpdated,
    required this.onMethodDeleted,
    required this.onAddMethod,
  }) : super(key: key);

  @override
  State<PaymentMethodsWidget> createState() => _PaymentMethodsWidgetState();
}

class _PaymentMethodsWidgetState extends State<PaymentMethodsWidget>
    with TickerProviderStateMixin {
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _staggerController.forward();
    });
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // Trigger parent refresh
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary card
            _buildSummaryCard(),

            const SizedBox(height: 24),

            // Payment methods list
            if (widget.paymentMethods.isEmpty) ...[ 
              _buildEmptyState(),
            ] else ...[ 
              _buildSectionHeader(),
              const SizedBox(height: 12),
              _buildPaymentMethodsList(),
            ],

            const SizedBox(height: 24),

            // Available providers
            _buildAvailableProviders(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final defaultMethod = widget.paymentMethods.where((m) => m.isDefault).firstOrNull;
    final activeMethods = widget.paymentMethods.where((m) => m.isActive).length;
    final recentlyUsed = widget.paymentMethods.where((m) => 
      m.lastUsed != null && 
      DateTime.now().difference(m.lastUsed!).inDays <= 7
    ).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryPink,
            AppTheme.primaryPink.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.payment,
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
                      'Mes moyens de paiement',
                      style: AppTheme.subHeaderStyle.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      defaultMethod != null 
                          ? 'Défaut: ${defaultMethod.displayName}'
                          : 'Aucune méthode par défaut',
                      style: AppTheme.captionStyle.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.credit_card,
                  label: 'Actives',
                  value: '$activeMethods',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.access_time,
                  label: 'Récentes',
                  value: '$recentlyUsed',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.verified,
                  label: 'Sécurisées',
                  value: '${widget.paymentMethods.length}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTheme.bodyTextStyle.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.captionStyle.copyWith(
            color: Colors.white.withOpacity(0.9),
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Icon(
          Icons.credit_card,
          color: AppTheme.primaryPink,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Méthodes enregistrées',
                style: AppTheme.subHeaderStyle.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${widget.paymentMethods.length} méthode(s) disponible(s)',
                style: AppTheme.captionStyle.copyWith(
                  color: AppTheme.lightGray,
                ),
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: widget.onAddMethod,
          icon: Icon(
            Icons.add,
            color: AppTheme.primaryPink,
            size: 16,
          ),
          label: Text(
            'Ajouter',
            style: AppTheme.captionStyle.copyWith(
              color: AppTheme.primaryPink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodsList() {
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.paymentMethods.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final method = widget.paymentMethods[index];
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
                child: _buildPaymentMethodCard(method),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod method) {
    final isExpired = method.isExpired;
    final providerColor = _getProviderColor(method.provider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: method.isDefault 
              ? providerColor.withOpacity(0.4)
              : AppTheme.lightGray.withOpacity(0.2),
          width: method.isDefault ? 2 : 1,
        ),
        boxShadow: method.isDefault
            ? [
                BoxShadow(
                  color: providerColor.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Provider icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: providerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getProviderIcon(method.provider),
                  color: providerColor,
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              // Method details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            method.displayName,
                            style: AppTheme.bodyTextStyle.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isExpired ? AppTheme.lightGray : AppTheme.darkText,
                            ),
                          ),
                        ),
                        if (method.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: providerColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'DÉFAUT',
                              style: AppTheme.captionStyle.copyWith(
                                color: providerColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 9,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Text(
                          method.providerDisplayName,
                          style: AppTheme.captionStyle.copyWith(
                            color: providerColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (method.maskedNumber != null) ...[ 
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: AppTheme.captionStyle.copyWith(
                              color: AppTheme.lightGray,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            method.maskedNumber!,
                            style: AppTheme.captionStyle.copyWith(
                              color: AppTheme.lightGray,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ],
                    ),

                    if (method.lastUsed != null) ...[ 
                      const SizedBox(height: 4),
                      Text(
                        'Utilisé ${PaymentService.formatTimeAgo(method.lastUsed!)}',
                        style: AppTheme.captionStyle.copyWith(
                          color: AppTheme.lightGray,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Action menu
              PopupMenuButton<String>(
                onSelected: (action) => _handleMethodAction(action, method),
                icon: Icon(
                  Icons.more_vert,
                  color: AppTheme.lightGray,
                  size: 20,
                ),
                itemBuilder: (context) => [
                  if (!method.isDefault)
                    const PopupMenuItem(
                      value: 'set_default',
                      child: Row(
                        children: [
                          Icon(Icons.star, size: 16),
                          SizedBox(width: 8),
                          Text('Définir par défaut'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 16),
                        SizedBox(width: 8),
                        Text('Modifier'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Supprimer', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Expiry warning
          if (isExpired) ...[ 
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cette méthode de paiement a expiré',
                      style: AppTheme.captionStyle.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Holder name for cards
          if (method.holderName != null) ...[ 
            const SizedBox(height: 8),
            Text(
              'Titulaire: ${method.holderName}',
              style: AppTheme.captionStyle.copyWith(
                color: AppTheme.lightGray,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvailableProviders() {
    final availableProviders = PaymentProvider.values
        .where((provider) => widget.settings.isProviderEnabled(provider))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.add_circle_outline,
              color: AppTheme.primaryPink,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ajouter une méthode',
                    style: AppTheme.subHeaderStyle.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Fournisseurs disponibles',
                    style: AppTheme.captionStyle.copyWith(
                      color: AppTheme.lightGray,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.lightGray.withOpacity(0.2),
            ),
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: availableProviders.map((provider) {
              return GestureDetector(
                onTap: () => _addPaymentMethod(provider),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getProviderColor(provider).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getProviderColor(provider).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getProviderIcon(provider),
                        color: _getProviderColor(provider),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getProviderShortName(provider),
                        style: AppTheme.captionStyle.copyWith(
                          color: _getProviderColor(provider),
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
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
              color: AppTheme.primaryPink.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.payment,
              size: 48,
              color: AppTheme.primaryPink,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune méthode de paiement',
            style: AppTheme.bodyTextStyle.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez votre première méthode de paiement pour commencer à effectuer des achats',
            style: AppTheme.captionStyle.copyWith(
              color: AppTheme.lightGray,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: widget.onAddMethod,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPink,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Ajouter une méthode'),
          ),
        ],
      ),
    );
  }

  void _handleMethodAction(String action, PaymentMethod method) async {
    switch (action) {
      case 'set_default':
        final updatedMethod = method.copyWith(isDefault: true);
        widget.onMethodUpdated(updatedMethod);
        break;
      case 'edit':
        _showEditMethod(method);
        break;
      case 'delete':
        _confirmDeleteMethod(method);
        break;
    }
  }

  void _addPaymentMethod(PaymentProvider provider) {
    widget.onAddMethod();
  }

  void _showEditMethod(PaymentMethod method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier la méthode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: method.displayName,
              decoration: const InputDecoration(
                labelText: 'Nom d\'affichage',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // Handle name change
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteMethod(PaymentMethod method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la méthode'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${method.displayName}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onMethodDeleted(method.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Color _getProviderColor(PaymentProvider provider) {
    switch (provider) {
      case PaymentProvider.orangeMoney:
        return Colors.orange;
      case PaymentProvider.mtnMomo:
        return Colors.yellow.shade700;
      case PaymentProvider.moovMoney:
        return Colors.blue;
      case PaymentProvider.visa:
        return Colors.blue.shade800;
      case PaymentProvider.mastercard:
        return Colors.red;
      case PaymentProvider.wave:
        return Colors.purple;
      case PaymentProvider.freeMoneyWallet:
        return Colors.green;
    }
  }

  IconData _getProviderIcon(PaymentProvider provider) {
    switch (provider) {
      case PaymentProvider.orangeMoney:
        return Icons.phone_android;
      case PaymentProvider.mtnMomo:
        return Icons.phone_android;
      case PaymentProvider.moovMoney:
        return Icons.phone_android;
      case PaymentProvider.visa:
        return Icons.credit_card;
      case PaymentProvider.mastercard:
        return Icons.credit_card;
      case PaymentProvider.wave:
        return Icons.waves;
      case PaymentProvider.freeMoneyWallet:
        return Icons.account_balance_wallet;
    }
  }

  String _getProviderShortName(PaymentProvider provider) {
    switch (provider) {
      case PaymentProvider.orangeMoney:
        return 'Orange Money';
      case PaymentProvider.mtnMomo:
        return 'MTN MoMo';
      case PaymentProvider.moovMoney:
        return 'Moov Money';
      case PaymentProvider.visa:
        return 'Visa';
      case PaymentProvider.mastercard:
        return 'Mastercard';
      case PaymentProvider.wave:
        return 'Wave';
      case PaymentProvider.freeMoneyWallet:
        return 'Free Money';
    }
  }
}