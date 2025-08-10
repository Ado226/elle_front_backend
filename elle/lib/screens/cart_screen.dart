import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../core/models/product.dart';
import '../services/shop_service.dart';
import '../widgets/shop/cart_item_widget.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _summaryController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _summaryAnimation;

  List<CartItem> _cartItems = [];
  bool _isLoading = true;
  double _subtotal = 0.0;
  double _shippingCost = 0.0;
  double _total = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadCartItems();
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

    _summaryController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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

    _summaryAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _summaryController,
      curve: const Interval(0.5, 1.0, curve: Curves.elasticOut),
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slideController.forward();
      _fadeController.forward();
      _summaryController.forward();
    });
  }

  Future<void> _loadCartItems() async {
    setState(() => _isLoading = true);
    
    try {
      final cartItems = await ShopService.getCartItems();
      _calculateTotals(cartItems);
      
      setState(() {
        _cartItems = cartItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _calculateTotals(List<CartItem> items) {
    _subtotal = items.fold(0.0, (sum, item) => sum + item.totalPrice);
    _shippingCost = _subtotal >= 20000 ? 0.0 : 2500.0; // Free shipping over 20,000 XOF
    _total = _subtotal + _shippingCost;
  }

  Future<void> _updateQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      await _removeItem(productId);
      return;
    }

    final success = await ShopService.updateCartItemQuantity(productId, quantity);
    if (success) {
      await _loadCartItems();
    }
  }

  Future<void> _removeItem(String productId) async {
    final success = await ShopService.removeFromCart(productId);
    if (success) {
      await _loadCartItems();
      
      if (mounted && _cartItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Panier vidé'),
            backgroundColor: AppTheme.primaryPink,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _clearCart() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Vider le panier',
          style: AppTheme.subHeaderStyle.copyWith(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer tous les articles de votre panier ?',
          style: AppTheme.bodyTextStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Annuler',
              style: AppTheme.bodyTextStyle.copyWith(color: AppTheme.lightGray),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Vider', style: AppTheme.bodyTextStyle.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ShopService.clearCart();
      if (success) {
        await _loadCartItems();
      }
    }
  }

  void _proceedToCheckout() {
    if (_cartItems.isEmpty) return;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          cartItems: _cartItems,
          subtotal: _subtotal,
          shippingCost: _shippingCost,
          total: _total,
        ),
      ),
    ).then((_) => _loadCartItems());
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: AnimatedBuilder(
        animation: Listenable.merge([_slideController, _fadeController, _summaryController]),
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
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(
          Icons.arrow_back_ios,
          color: AppTheme.primaryPink,
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mon Panier',
            style: AppTheme.headerStyle.copyWith(fontSize: 20),
          ),
          if (!_isLoading)
            Text(
              '${_cartItems.length} article${_cartItems.length > 1 ? 's' : ''}',
              style: AppTheme.captionStyle.copyWith(color: AppTheme.lightGray),
            ),
        ],
      ),
      actions: [
        if (!_isLoading && _cartItems.isNotEmpty)
          IconButton(
            onPressed: _clearCart,
            icon: Icon(
              Icons.delete_outline,
              color: Colors.red,
            ),
          ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_cartItems.isEmpty) {
      return _buildEmptyCart();
    }

    return Column(
      children: [
        // Cart items list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _cartItems.length,
            itemBuilder: (context, index) {
              final cartItem = _cartItems[index];
              return CartItemWidget(
                cartItem: cartItem,
                onQuantityChanged: (quantity) => _updateQuantity(cartItem.product.id, quantity),
                onRemove: () => _removeItem(cartItem.product.id),
                animationDelay: Duration(milliseconds: index * 100),
              );
            },
          ),
        ),

        // Order summary
        Transform.scale(
          scale: _summaryAnimation.value,
          child: _buildOrderSummary(),
        ),
      ],
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryPink.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: AppTheme.primaryPink,
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Votre panier est vide',
            style: AppTheme.subHeaderStyle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Découvrez nos produits de santé\net bien-être féminin',
            style: AppTheme.captionStyle,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: AppTheme.primaryButtonStyle,
            child: Text(
              'Continuer les achats',
              style: AppTheme.bodyStyle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Résumé de commande',
              style: AppTheme.subHeaderStyle.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Summary rows
            _buildSummaryRow('Sous-total', '${_subtotal.toStringAsFixed(0)} XOF'),
            _buildSummaryRow(
              'Livraison', 
              _shippingCost == 0 ? 'Gratuite' : '${_shippingCost.toStringAsFixed(0)} XOF',
              isShippingFree: _shippingCost == 0,
            ),
            
            const Divider(height: 20),
            
            _buildSummaryRow(
              'Total', 
              '${_total.toStringAsFixed(0)} XOF',
              isTotal: true,
            ),
            
            const SizedBox(height: 20),
            
            // Checkout button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _proceedToCheckout,
                style: AppTheme.primaryButtonStyle.copyWith(
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                child: Text(
                  'Procéder au paiement',
                  style: AppTheme.bodyStyle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false, bool isShippingFree = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodyTextStyle.copyWith(
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Row(
            children: [
              if (isShippingFree)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'GRATUITE',
                    style: AppTheme.captionStyle.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Text(
                value,
                style: AppTheme.bodyTextStyle.copyWith(
                  fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
                  fontSize: isTotal ? 18 : 14,
                  color: isTotal ? AppTheme.primaryPink : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}