import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../core/models/payment.dart';
import '../../services/payment_service.dart';

class PaymentCheckoutWidget extends StatefulWidget {
  final double amount;
  final String description;
  final String? orderId;
  final PaymentType paymentType;
  final Map<String, dynamic>? metadata;
  final Function(PaymentTransaction) onPaymentCompleted;
  final Function(String)? onPaymentFailed;
  final VoidCallback? onCancel;

  const PaymentCheckoutWidget({
    Key? key,
    required this.amount,
    required this.description,
    this.orderId,
    this.paymentType = PaymentType.orderPayment,
    this.metadata,
    required this.onPaymentCompleted,
    this.onPaymentFailed,
    this.onCancel,
  }) : super(key: key);

  @override
  State<PaymentCheckoutWidget> createState() => _PaymentCheckoutWidgetState();
}

class _PaymentCheckoutWidgetState extends State<PaymentCheckoutWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _processingController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _processingAnimation;

  List<PaymentMethod> _paymentMethods = [];
  PaymentMethod? _selectedMethod;
  PaymentTransaction? _currentTransaction;
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _processingMessage;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadPaymentMethods();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _processingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _processingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _processingController,
      curve: Curves.easeInOut,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slideController.forward();
    });
  }

  Future<void> _loadPaymentMethods() async {
    setState(() => _isLoading = true);

    try {
      final methods = await PaymentService.getPaymentMethods();
      setState(() {
        _paymentMethods = methods;
        _selectedMethod = methods.where((m) => m.isDefault).firstOrNull ?? 
                          (methods.isNotEmpty ? methods.first : null);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _processingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: AnimatedBuilder(
        animation: _slideController,
        builder: (context, child) {
          return SlideTransition(
            position: _slideAnimation,
            child: _isProcessing ? _buildProcessingView() : _buildCheckoutView(),
          );
        },
      ),
    );
  }

  Widget _buildCheckoutView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Handle bar
        _buildHandleBar(),

        // Header
        _buildHeader(),

        // Content
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Payment summary
                _buildPaymentSummary(),

                const SizedBox(height: 24),

                // Payment methods
                if (_paymentMethods.isNotEmpty) ...[ 
                  _buildPaymentMethodsSection(),
                  const SizedBox(height: 24),
                ],

                // Security info
                _buildSecurityInfo(),

                const SizedBox(height: 32),

                // Action buttons
                _buildActionButtons(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingView() {
    return AnimatedBuilder(
      animation: _processingController,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandleBar(),
            
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  // Processing animation
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryPink,
                          AppTheme.primaryPink.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer ring
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(
                            value: _processingAnimation.value,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation(Colors.white),
                            strokeWidth: 4,
                          ),
                        ),
                        // Inner icon
                        Icon(
                          _selectedMethod != null 
                              ? _getProviderIcon(_selectedMethod!.provider)
                              : Icons.payment,
                          color: Colors.white,
                          size: 40,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Traitement du paiement',
                    style: AppTheme.headerStyle.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _processingMessage ?? 'Veuillez patienter...',
                    style: AppTheme.bodyTextStyle.copyWith(
                      color: AppTheme.lightGray,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  if (_selectedMethod != null) ...[ 
                    const SizedBox(height: 16),
                    
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.lightGray.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getProviderIcon(_selectedMethod!.provider),
                            color: _getProviderColor(_selectedMethod!.provider),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedMethod!.displayName,
                            style: AppTheme.captionStyle.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            PaymentService.formatAmount(widget.amount),
                            style: AppTheme.captionStyle.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryPink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  TextButton(
                    onPressed: _cancelPayment,
                    child: Text(
                      'Annuler',
                      style: AppTheme.bodyTextStyle.copyWith(
                        color: AppTheme.lightGray,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
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
                  'Finaliser le paiement',
                  style: AppTheme.headerStyle.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Choisissez votre moyen de paiement',
                  style: AppTheme.captionStyle.copyWith(
                    color: AppTheme.lightGray,
                  ),
                ),
              ],
            ),
          ),
          if (widget.onCancel != null)
            IconButton(
              onPressed: widget.onCancel,
              icon: Icon(
                Icons.close,
                color: AppTheme.lightGray,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    final fees = _selectedMethod != null 
        ? PaymentService.calculateTotalWithFees(widget.amount, _selectedMethod!.provider)
        : Future.value(widget.amount);

    return Container(
      padding: const EdgeInsets.all(20),
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
                Icons.receipt,
                color: AppTheme.primaryPink,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Résumé du paiement',
                style: AppTheme.bodyTextStyle.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildSummaryRow('Description', widget.description),
          
          if (widget.orderId != null)
            _buildSummaryRow('Commande', '#${widget.orderId}'),
          
          _buildSummaryRow('Montant', PaymentService.formatAmount(widget.amount)),

          if (_selectedMethod != null) ...[ 
            const Divider(height: 24),
            
            FutureBuilder<double>(
              future: PaymentService.calculateTotalWithFees(widget.amount, _selectedMethod!.provider),
              builder: (context, snapshot) {
                final total = snapshot.data ?? widget.amount;
                final fees = total - widget.amount;
                
                return Column(
                  children: [
                    if (fees > 0)
                      _buildSummaryRow(
                        'Frais ${_selectedMethod!.providerDisplayName}',
                        PaymentService.formatAmount(fees),
                        isSecondary: true,
                      ),
                    
                    const SizedBox(height: 8),
                    
                    _buildSummaryRow(
                      'Total à payer',
                      PaymentService.formatAmount(total),
                      isTotal: true,
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isSecondary = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodyTextStyle.copyWith(
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isSecondary ? AppTheme.lightGray : AppTheme.darkText,
            ),
          ),
          Text(
            value,
            style: AppTheme.bodyTextStyle.copyWith(
              fontWeight: FontWeight.w700,
              color: isTotal ? AppTheme.primaryPink : AppTheme.darkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choisir un moyen de paiement',
          style: AppTheme.subHeaderStyle.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 12),

        if (_isLoading) ...[ 
          const Center(child: CircularProgressIndicator()),
        ] else if (_paymentMethods.isEmpty) ...[ 
          _buildNoPaymentMethodsCard(),
        ] else ...[ 
          ..._paymentMethods.map((method) => _buildPaymentMethodCard(method)),
        ],
      ],
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod method) {
    final isSelected = _selectedMethod?.id == method.id;
    final providerColor = _getProviderColor(method.provider);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = method;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? providerColor.withOpacity(0.4)
                : AppTheme.lightGray.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: providerColor.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
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
                ],
              ),
            ),

            // Selection indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? providerColor : AppTheme.lightGray,
                  width: 2,
                ),
                color: isSelected ? providerColor : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoPaymentMethodsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
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
            Icons.credit_card_off,
            size: 48,
            color: AppTheme.lightGray,
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
            'Vous devez ajouter une méthode de paiement pour continuer',
            style: AppTheme.captionStyle.copyWith(
              color: AppTheme.lightGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.security,
            color: Colors.green,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paiement sécurisé',
                  style: AppTheme.bodyTextStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Vos informations sont protégées par un cryptage de niveau bancaire',
                  style: AppTheme.captionStyle.copyWith(
                    color: Colors.green.shade700,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final canPay = _selectedMethod != null && !_isLoading;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canPay ? _processPayment : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPink,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Text(
              canPay 
                  ? 'Payer ${PaymentService.formatAmount(widget.amount)}'
                  : 'Sélectionnez une méthode de paiement',
              style: AppTheme.bodyTextStyle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        if (widget.onCancel != null) ...[ 
          const SizedBox(height: 12),
          
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: widget.onCancel,
              child: Text(
                'Annuler',
                style: AppTheme.bodyTextStyle.copyWith(
                  color: AppTheme.lightGray,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _processPayment() async {
    if (_selectedMethod == null) return;

    setState(() {
      _isProcessing = true;
      _processingMessage = 'Initialisation du paiement...';
    });

    _processingController.repeat();

    try {
      // Create payment request
      final request = PaymentRequest(
        id: 'req_${DateTime.now().millisecondsSinceEpoch}',
        amount: widget.amount,
        provider: _selectedMethod!.provider,
        type: widget.paymentType,
        description: widget.description,
        orderId: widget.orderId,
        metadata: widget.metadata ?? {},
        expiresAt: DateTime.now().add(const Duration(minutes: 15)),
      );

      setState(() {
        _processingMessage = 'Connexion au fournisseur de paiement...';
      });

      // Initiate payment
      final transaction = await PaymentService.initiatePayment(request);
      _currentTransaction = transaction;

      setState(() {
        _processingMessage = _selectedMethod!.isMobileMoney
            ? 'Vérifiez votre téléphone pour confirmer le paiement'
            : 'Traitement de votre carte bancaire...';
      });

      // Poll for transaction status
      await _pollTransactionStatus(transaction.id);

    } catch (e) {
      _processingController.stop();
      setState(() {
        _isProcessing = false;
      });

      widget.onPaymentFailed?.call('Erreur lors du traitement du paiement');
    }
  }

  Future<void> _pollTransactionStatus(String transactionId) async {
    for (int i = 0; i < 30; i++) { // Poll for up to 30 seconds
      await Future.delayed(const Duration(seconds: 1));

      final transaction = await PaymentService.getTransaction(transactionId);
      if (transaction == null) continue;

      if (transaction.isCompleted) {
        _processingController.stop();
        setState(() {
          _isProcessing = false;
        });
        widget.onPaymentCompleted(transaction);
        return;
      } else if (transaction.isFailed) {
        _processingController.stop();
        setState(() {
          _isProcessing = false;
        });
        widget.onPaymentFailed?.call(transaction.failureReason ?? 'Paiement échoué');
        return;
      }
    }

    // Timeout
    _processingController.stop();
    setState(() {
      _isProcessing = false;
    });
    widget.onPaymentFailed?.call('Délai d\'attente dépassé');
  }

  void _cancelPayment() async {
    if (_currentTransaction != null) {
      await PaymentService.cancelPayment(_currentTransaction!.id);
    }

    _processingController.stop();
    setState(() {
      _isProcessing = false;
    });

    widget.onCancel?.call();
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
}