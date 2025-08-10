import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../core/models/product.dart';

class CartItemWidget extends StatefulWidget {
  final CartItem cartItem;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;
  final Duration animationDelay;

  const CartItemWidget({
    Key? key,
    required this.cartItem,
    required this.onQuantityChanged,
    required this.onRemove,
    this.animationDelay = Duration.zero,
  }) : super(key: key);

  @override
  State<CartItemWidget> createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _removeController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _removeAnimation;

  bool _isRemoving = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _removeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _removeController,
      curve: Curves.easeOut,
    ));

    _removeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _removeController,
      curve: Curves.easeInOut,
    ));

    // Start animation with delay
    Future.delayed(widget.animationDelay, () {
      if (mounted) _slideController.forward();
    });
  }

  Future<void> _handleRemove() async {
    setState(() => _isRemoving = true);
    
    await _removeController.forward();
    
    if (mounted) {
      widget.onRemove();
    }
  }

  void _updateQuantity(int delta) {
    final newQuantity = widget.cartItem.quantity + delta;
    if (newQuantity >= 0) {
      widget.onQuantityChanged(newQuantity);
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    _removeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_slideController, _removeController]),
      builder: (context, child) {
        return Opacity(
          opacity: _isRemoving ? _fadeAnimation.value : 1.0,
          child: Transform.scale(
            scale: _scaleAnimation.value * (_isRemoving ? _removeAnimation.value : 1.0),
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _buildProductImage(),
                    const SizedBox(width: 16),
                    Expanded(child: _buildProductInfo()),
                    const SizedBox(width: 16),
                    _buildQuantityControls(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.primaryPink.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              _getProductIcon(),
              size: 36,
              color: AppTheme.primaryPink.withOpacity(0.7),
            ),
          ),
          
          // Category badge
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: widget.cartItem.product.category.index.isEven 
                    ? AppTheme.primaryPink 
                    : AppTheme.consultationOrange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.cartItem.product.categoryEmoji,
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product name
        Text(
          widget.cartItem.product.name,
          style: AppTheme.bodyTextStyle.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 4),
        
        // Brand
        Text(
          widget.cartItem.product.brand,
          style: AppTheme.captionStyle.copyWith(
            color: AppTheme.lightGray,
            fontSize: 12,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Price per unit
        Text(
          '${widget.cartItem.product.formattedPrice} / unité',
          style: AppTheme.captionStyle.copyWith(
            color: AppTheme.lightGray,
            fontSize: 12,
          ),
        ),
        
        const SizedBox(height: 4),
        
        // Total price for this item
        Text(
          widget.cartItem.formattedTotalPrice,
          style: AppTheme.bodyTextStyle.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryPink,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityControls() {
    return Column(
      children: [
        // Remove button
        GestureDetector(
          onTap: _handleRemove,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.delete_outline,
              size: 20,
              color: Colors.red,
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Quantity controls
        Container(
          decoration: BoxDecoration(
            color: AppTheme.primaryPink.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              // Increase button
              GestureDetector(
                onTap: () => _updateQuantity(1),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.add,
                    size: 16,
                    color: AppTheme.primaryPink,
                  ),
                ),
              ),
              
              // Quantity display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Text(
                  widget.cartItem.quantity.toString(),
                  style: AppTheme.bodyTextStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              
              // Decrease button
              GestureDetector(
                onTap: () => _updateQuantity(-1),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.remove,
                    size: 16,
                    color: widget.cartItem.quantity > 1 
                        ? AppTheme.primaryPink 
                        : AppTheme.lightGray,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getProductIcon() {
    switch (widget.cartItem.product.category) {
      case ProductCategory.contraception:
        return Icons.shield_outlined;
      case ProductCategory.hygiene:
        return Icons.clean_hands_outlined;
      case ProductCategory.supplements:
        return Icons.medication_outlined;
      case ProductCategory.intimacy:
        return Icons.favorite_outline;
      case ProductCategory.education:
        return Icons.school_outlined;
      case ProductCategory.comfort:
        return Icons.spa_outlined;
    }
  }
}