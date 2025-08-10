import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../core/models/payment.dart';
import '../services/payment_service.dart';
import '../widgets/payment/payment_methods_widget.dart';
import '../widgets/payment/payment_history_widget.dart';
import '../widgets/payment/add_payment_method_widget.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  List<PaymentMethod> _paymentMethods = [];
  List<PaymentTransaction> _transactions = [];
  PaymentSettings _settings = const PaymentSettings();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadPaymentData();
  }

  void _initializeAnimations() {
    _tabController = TabController(length: 2, vsync: this);
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slideController.forward();
      _fadeController.forward();
    });
  }

  Future<void> _loadPaymentData() async {
    setState(() => _isLoading = true);
    
    try {
      final [methods, transactions, settings] = await Future.wait([
        PaymentService.getPaymentMethods(),
        PaymentService.getTransactions(limit: 50),
        PaymentService.getSettings(),
      ]);

      setState(() {
        _paymentMethods = methods as List<PaymentMethod>;
        _transactions = transactions as List<PaymentTransaction>;
        _settings = settings as PaymentSettings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showAddPaymentMethod() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => AddPaymentMethodWidget(
          scrollController: scrollController,
          onMethodAdded: (method) {
            _loadPaymentData();
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: AnimatedBuilder(
        animation: Listenable.merge([_slideController, _fadeController]),
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
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.backgroundColor,
      elevation: 0,
      title: Row(
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
                  'Paiements',
                  style: AppTheme.headerStyle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${_paymentMethods.length} méthode(s) • ${_transactions.length} transaction(s)',
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
      actions: [
        IconButton(
          onPressed: () => _showPaymentSettings(),
          icon: Icon(
            Icons.settings,
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
        tabs: const [
          Tab(text: 'Mes moyens de paiement'),
          Tab(text: 'Historique'),
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
        PaymentMethodsWidget(
          paymentMethods: _paymentMethods,
          settings: _settings,
          onMethodUpdated: (method) => _loadPaymentData(),
          onMethodDeleted: (methodId) => _loadPaymentData(),
          onAddMethod: _showAddPaymentMethod,
        ),
        PaymentHistoryWidget(
          transactions: _transactions,
          onRefresh: _loadPaymentData,
          onTransactionTap: _showTransactionDetail,
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return Transform.scale(
          scale: _fadeAnimation.value,
          child: FloatingActionButton.extended(
            onPressed: _showAddPaymentMethod,
            backgroundColor: AppTheme.primaryPink,
            elevation: 4,
            label: Text(
              'Ajouter un moyen',
              style: AppTheme.bodyTextStyle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  void _showPaymentSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.settings,
              color: AppTheme.primaryPink,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Paramètres de paiement',
              style: AppTheme.subHeaderStyle.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSettingsTile(
              icon: Icons.security,
              title: 'Sécurité renforcée',
              subtitle: 'Authentification biométrique',
              value: true,
              onChanged: (value) {},
            ),
            const SizedBox(height: 12),
            _buildSettingsTile(
              icon: Icons.notifications,
              title: 'Notifications de paiement',
              subtitle: 'Alertes pour chaque transaction',
              value: true,
              onChanged: (value) {},
            ),
            const SizedBox(height: 12),
            _buildSettingsTile(
              icon: Icons.save,
              title: 'Sauvegarder les cartes',
              subtitle: 'Mémoriser pour les futurs achats',
              value: false,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Fermer',
              style: AppTheme.bodyTextStyle.copyWith(color: AppTheme.lightGray),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPink,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Sauvegarder',
              style: AppTheme.bodyTextStyle.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.primaryPink.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryPink,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.bodyTextStyle.copyWith(
                  fontWeight: FontWeight.w600,
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
        ),
      ],
    );
  }

  void _showTransactionDetail(PaymentTransaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getStatusColor(transaction.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getProviderIcon(transaction.provider),
                color: _getStatusColor(transaction.status),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transaction ${transaction.id}',
                    style: AppTheme.bodyTextStyle.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(transaction.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      transaction.statusDisplayName,
                      style: AppTheme.captionStyle.copyWith(
                        color: _getStatusColor(transaction.status),
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Montant', PaymentService.formatAmount(transaction.amount)),
            if (transaction.fees != null)
              _buildDetailRow('Frais', PaymentService.formatAmount(transaction.fees!)),
            _buildDetailRow('Total', PaymentService.formatAmount(transaction.totalAmount)),
            _buildDetailRow('Fournisseur', transaction.provider.name),
            _buildDetailRow('Date', PaymentService.formatTimeAgo(transaction.createdAt)),
            if (transaction.description != null)
              _buildDetailRow('Description', transaction.description!),
            if (transaction.externalTransactionId != null)
              _buildDetailRow('Référence', transaction.externalTransactionId!),
            if (transaction.failureReason != null)
              _buildDetailRow('Raison de l\'échec', transaction.failureReason!, isError: true),
          ],
        ),
        actions: [
          if (transaction.canBeRefunded)
            TextButton(
              onPressed: () => _initiateRefund(transaction),
              child: Text(
                'Rembourser',
                style: AppTheme.bodyTextStyle.copyWith(color: Colors.orange),
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

  Widget _buildDetailRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: AppTheme.captionStyle.copyWith(
                color: AppTheme.lightGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyTextStyle.copyWith(
                fontWeight: FontWeight.w600,
                color: isError ? Colors.red : AppTheme.darkText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _initiateRefund(PaymentTransaction transaction) async {
    Navigator.of(context).pop(); // Close detail dialog
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer le remboursement'),
        content: Text(
          'Êtes-vous sûr de vouloir rembourser cette transaction de ${PaymentService.formatAmount(transaction.amount)} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Rembourser'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await PaymentService.refundPayment(transaction.id);
        _loadPaymentData();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Remboursement initié avec succès'),
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
              content: const Text('Erreur lors du remboursement'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    }
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.processing:
        return Colors.blue;
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.cancelled:
        return Colors.grey;
      case PaymentStatus.refunded:
        return Colors.purple;
      case PaymentStatus.expired:
        return Colors.red.shade300;
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
}