import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../core/models/product.dart';
import '../core/models/order.dart' as order;
import '../core/models/payment.dart' as payment;
import '../services/shop_service.dart';
import '../services/payment_service.dart';
import '../widgets/shop/shipping_address_form.dart';
import '../widgets/shop/payment_method_selector.dart';
import '../widgets/payment/payment_checkout_widget.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final double subtotal;
  final double shippingCost;
  final double total;

  const CheckoutScreen({
    Key? key,
    required this.cartItems,
    required this.subtotal,
    required this.shippingCost,
    required this.total,
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _stepController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _stepAnimation;

  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isProcessingOrder = false;

  // Form data
  order.ShippingAddress? _shippingAddress;
  order.OrderPaymentMethod? _selectedPaymentMethod;
  String _specialInstructions = '';
  bool _isDiscretePackaging = true;

  final List<String> _stepTitles = [
    'Adresse de livraison',
    'Mode de paiement',
    'Confirmation',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadDefaultAddress();
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

    _stepController = AnimationController(
      duration: const Duration(milliseconds: 400),
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

    _stepAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _stepController,
      curve: Curves.easeOutCubic,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slideController.forward();
      _fadeController.forward();
      _stepController.forward();
    });
  }

  Future<void> _loadDefaultAddress() async {
    final defaultAddress = await ShopService.getDefaultShippingAddress();
    if (defaultAddress != null) {
      setState(() => _shippingAddress = defaultAddress);
    }
  }

  void _nextStep() {
    if (_currentStep < _stepTitles.length - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _canProceedToNextStep() {
    switch (_currentStep) {
      case 0:
        return _shippingAddress != null;
      case 1:
        return _selectedPaymentMethod != null;
      case 2:
        return true;
      default:
        return false;
    }
  }

  Future<void> _placeOrder() async {
    if (_shippingAddress == null || _selectedPaymentMethod == null) return;

    setState(() => _isProcessingOrder = true);

    try {
      final orderObj = order.Order(
        id: ShopService.generateOrderId(),
        userId: 'current_user', // Replace with actual user ID
        items: widget.cartItems.map((cartItem) => order.OrderItem(
          product: cartItem.product,
          quantity: cartItem.quantity,
          unitPrice: cartItem.product.price,
          selectedOptions: cartItem.selectedOptions,
        )).toList(),
        subtotal: widget.subtotal,
        shippingCost: widget.shippingCost,
        taxAmount: 0.0, // No tax for now
        discountAmount: 0.0,
        totalAmount: widget.total,
        status: order.OrderStatus.pending,
        paymentStatus: order.OrderPaymentStatus.pending,
        paymentMethod: _selectedPaymentMethod!,
        shippingAddress: _shippingAddress!,
        notes: _specialInstructions.isNotEmpty ? _specialInstructions : null,
        isDiscretePackaging: _isDiscretePackaging,
        createdAt: DateTime.now(),
        estimatedDelivery: DateTime.now().add(const Duration(days: 3)),
      );

      final success = await ShopService.createOrder(orderObj);

      if (success && mounted) {
        _showOrderConfirmation(orderObj);
      } else {
        _showErrorDialog('Erreur lors de la création de la commande');
      }
    } catch (e) {
      _showErrorDialog('Une erreur inattendue s\'est produite');
    } finally {
      setState(() => _isProcessingOrder = false);
    }
  }

  void _showOrderConfirmation(order.Order orderObj) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 48,
                color: Colors.green,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Commande confirmée !',
              style: AppTheme.subHeaderStyle.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Numéro de commande : ${orderObj.id}',
              style: AppTheme.captionStyle.copyWith(
                color: AppTheme.lightGray,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Votre commande a été enregistrée avec succès. Vous recevrez une confirmation par email.',
              style: AppTheme.bodyTextStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close checkout
                Navigator.of(context).pop(); // Close cart
              },
              style: AppTheme.primaryButtonStyle,
              child: Text(
                'Continuer les achats',
                style: AppTheme.bodyStyle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Erreur',
          style: AppTheme.subHeaderStyle.copyWith(fontWeight: FontWeight.w600),
        ),
        content: Text(message, style: AppTheme.bodyTextStyle),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: AppTheme.primaryButtonStyle,
            child: Text(
              'OK',
              style: AppTheme.bodyStyle.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _stepController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: AnimatedBuilder(
        animation: Listenable.merge([_slideController, _fadeController, _stepController]),
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  _buildStepIndicator(),
                  Expanded(child: _buildStepContent()),
                  _buildBottomActions(),
                ],
              ),
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
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(
          Icons.arrow_back_ios,
          color: AppTheme.primaryPink,
        ),
      ),
      title: Text(
        'Finaliser la commande',
        style: AppTheme.headerStyle.copyWith(fontSize: 20),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Transform.scale(
      scale: _stepAnimation.value,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: List.generate(_stepTitles.length, (index) {
            final isActive = index <= _currentStep;
            final isCompleted = index < _currentStep;

            return Expanded(
              child: Row(
                children: [
                  // Step circle
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isActive ? AppTheme.primaryPink : AppTheme.lightGray.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(
                              Icons.check,
                              size: 18,
                              color: Colors.white,
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isActive ? Colors.white : AppTheme.lightGray,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ),

                  // Step line (except for last step)
                  if (index < _stepTitles.length - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: isCompleted ? AppTheme.primaryPink : AppTheme.lightGray.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Step 1: Shipping Address
        ShippingAddressForm(
          initialAddress: _shippingAddress,
          onAddressChanged: (address) => setState(() => _shippingAddress = address),
        ),

        // Step 2: Payment Method
        PaymentMethodSelector(
          selectedMethod: _selectedPaymentMethod,
          onMethodSelected: (method) => setState(() => _selectedPaymentMethod = method),
        ),

        // Step 3: Order Confirmation
        _buildOrderConfirmation(),
      ],
    );
  }

  Widget _buildOrderConfirmation() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Confirmez votre commande',
            style: AppTheme.subHeaderStyle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 20),

          // Order items
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Articles commandés',
                  style: AppTheme.bodyTextStyle.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                ...widget.cartItems.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item.product.name} (x${item.quantity})',
                          style: AppTheme.captionStyle,
                        ),
                      ),
                      Text(
                        item.formattedTotalPrice,
                        style: AppTheme.captionStyle.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Shipping address
          if (_shippingAddress != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Adresse de livraison',
                    style: AppTheme.bodyTextStyle.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _shippingAddress!.fullName,
                    style: AppTheme.captionStyle.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    _shippingAddress!.formattedAddress,
                    style: AppTheme.captionStyle,
                  ),
                  Text(
                    _shippingAddress!.phoneNumber,
                    style: AppTheme.captionStyle,
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Payment method
          if (_selectedPaymentMethod != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mode de paiement',
                    style: AppTheme.bodyTextStyle.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedPaymentMethod!.toString().split('.').last,
                    style: AppTheme.captionStyle,
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Special instructions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Instructions spéciales',
                  style: AppTheme.bodyTextStyle.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  onChanged: (value) => setState(() => _specialInstructions = value),
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Instructions pour la livraison (optionnel)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppTheme.lightGray.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppTheme.lightGray.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppTheme.primaryPink),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Discrete packaging option
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emballage discret',
                        style: AppTheme.bodyTextStyle.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Votre commande sera livrée dans un emballage neutre',
                        style: AppTheme.captionStyle,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isDiscretePackaging,
                  onChanged: (value) => setState(() => _isDiscretePackaging = value),
                  activeColor: AppTheme.primaryPink,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Order total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: AppTheme.subHeaderStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${widget.total.toStringAsFixed(0)} XOF',
                  style: AppTheme.subHeaderStyle.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryPink,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.primaryPink),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Précédent',
                        style: AppTheme.bodyStyle.copyWith(
                          color: AppTheme.primaryPink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                if (_currentStep > 0) const SizedBox(width: 16),

                Expanded(
                  child: ElevatedButton(
                    onPressed: _isProcessingOrder || !_canProceedToNextStep()
                        ? null
                        : (_currentStep == _stepTitles.length - 1 ? _placeOrder : _nextStep),
                    style: AppTheme.primaryButtonStyle.copyWith(
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    child: _isProcessingOrder
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Text(
                            _currentStep == _stepTitles.length - 1 ? 'Confirmer la commande' : 'Suivant',
                            style: AppTheme.bodyStyle.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}