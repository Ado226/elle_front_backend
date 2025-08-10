import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../core/models/order.dart';

class PaymentMethodSelector extends StatefulWidget {
  final OrderPaymentMethod? selectedMethod;
  final Function(OrderPaymentMethod) onMethodSelected;

  const PaymentMethodSelector({
    Key? key,
    required this.selectedMethod,
    required this.onMethodSelected,
  }) : super(key: key);

  @override
  State<PaymentMethodSelector> createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<AnimationController> _cardControllers;
  late List<Animation<double>> _cardAnimations;

  final List<PaymentMethodData> _paymentMethods = [
    PaymentMethodData(
      method: OrderPaymentMethod.orangeMoney,
      name: 'Orange Money',
      description: 'Paiement mobile sécurisé',
      icon: Icons.phone_android,
      color: const Color(0xFFFF6900),
      isRecommended: true,
    ),
    PaymentMethodData(
      method: OrderPaymentMethod.moovMoney,
      name: 'Moov Money',
      description: 'Paiement mobile rapide',
      icon: Icons.smartphone,
      color: const Color(0xFF0066CC),
      isRecommended: false,
    ),
    PaymentMethodData(
      method: OrderPaymentMethod.mtnMoney,
      name: 'MTN Money',
      description: 'Mobile Money MTN',
      icon: Icons.phone_in_talk,
      color: const Color(0xFFFFCC00),
      isRecommended: false,
    ),
    PaymentMethodData(
      method: OrderPaymentMethod.visa,
      name: 'Visa',
      description: 'Carte bancaire Visa',
      icon: Icons.credit_card,
      color: const Color(0xFF1A1F71),
      isRecommended: false,
    ),
    PaymentMethodData(
      method: OrderPaymentMethod.mastercard,
      name: 'Mastercard',
      description: 'Carte bancaire Mastercard',
      icon: Icons.credit_card,
      color: const Color(0xFFEB001B),
      isRecommended: false,
    ),
    PaymentMethodData(
      method: OrderPaymentMethod.cashOnDelivery,
      name: 'Paiement à la livraison',
      description: 'Payez en espèces à la réception',
      icon: Icons.local_shipping,
      color: const Color(0xFF4CAF50),
      isRecommended: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _cardControllers = List.generate(
      _paymentMethods.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _cardAnimations = _cardControllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      ));
    }).toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
      _startStaggeredAnimations();
    });
  }

  void _startStaggeredAnimations() {
    for (int i = 0; i < _cardControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) _cardControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choisissez votre mode de paiement',
            style: AppTheme.subHeaderStyle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Tous les paiements sont sécurisés et cryptés',
            style: AppTheme.captionStyle.copyWith(
              color: AppTheme.lightGray,
            ),
          ),
          
          const SizedBox(height: 24),
          
          Expanded(
            child: ListView.builder(
              itemCount: _paymentMethods.length,
              itemBuilder: (context, index) {
                final paymentData = _paymentMethods[index];
                final isSelected = widget.selectedMethod == paymentData.method;

                return AnimatedBuilder(
                  animation: _cardAnimations[index],
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _cardAnimations[index].value,
                      child: PaymentMethodCard(
                        paymentData: paymentData,
                        isSelected: isSelected,
                        onTap: () => widget.onMethodSelected(paymentData.method),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentMethodData {
  final OrderPaymentMethod method;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final bool isRecommended;

  PaymentMethodData({
    required this.method,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.isRecommended = false,
  });
}

class PaymentMethodCard extends StatefulWidget {
  final PaymentMethodData paymentData;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodCard({
    Key? key,
    required this.paymentData,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  State<PaymentMethodCard> createState() => _PaymentMethodCardState();
}

class _PaymentMethodCardState extends State<PaymentMethodCard>
    with TickerProviderStateMixin {
  late AnimationController _tapController;
  late AnimationController _selectionController;
  late AnimationController _pulseController;

  late Animation<double> _tapAnimation;
  late Animation<double> _selectionAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _tapAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _tapController,
      curve: Curves.easeInOut,
    ));

    _selectionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _selectionController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.isSelected) {
      _selectionController.forward();
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PaymentMethodCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _selectionController.forward();
        _pulseController.repeat(reverse: true);
      } else {
        _selectionController.reverse();
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  void _onTapDown() {
    _tapController.forward();
  }

  void _onTapUp() {
    _tapController.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _tapController.reverse();
  }

  @override
  void dispose() {
    _tapController.dispose();
    _selectionController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _tapController,
        _selectionController,
        _pulseController,
      ]),
      builder: (context, child) {
        final scale = _tapAnimation.value * 
            (widget.isSelected ? _pulseAnimation.value : 1.0);

        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTapDown: (_) => _onTapDown(),
            onTapUp: (_) => _onTapUp(),
            onTapCancel: _onTapCancel,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isSelected 
                      ? widget.paymentData.color
                      : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isSelected
                        ? widget.paymentData.color.withOpacity(0.2)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: widget.isSelected ? 12 : 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Payment method icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: widget.paymentData.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.paymentData.icon,
                      color: widget.paymentData.color,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Payment method info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.paymentData.name,
                              style: AppTheme.bodyTextStyle.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            if (widget.paymentData.isRecommended) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'RECOMMANDÉ',
                                  style: AppTheme.captionStyle.copyWith(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.paymentData.description,
                          style: AppTheme.captionStyle.copyWith(
                            color: AppTheme.lightGray,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Selection indicator
                  Transform.scale(
                    scale: 0.8 + (_selectionAnimation.value * 0.2),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.isSelected 
                              ? widget.paymentData.color
                              : AppTheme.lightGray,
                          width: 2,
                        ),
                        color: widget.isSelected 
                            ? widget.paymentData.color
                            : Colors.transparent,
                      ),
                      child: widget.isSelected
                          ? Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}