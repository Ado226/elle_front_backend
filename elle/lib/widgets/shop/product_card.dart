import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../core/models/product.dart';
import '../../services/shop_service.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onAddToCart;
  final Duration animationDelay;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onAddToCart,
    this.animationDelay = Duration.zero,
  }) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _favoriteController;
  late AnimationController _tapController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _favoriteAnimation;
  late Animation<double> _tapAnimation;

  bool _isFavorite = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkFavoriteStatus();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _favoriteController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _tapController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    _favoriteAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _favoriteController,
      curve: Curves.elasticOut,
    ));

    _tapAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _tapController,
      curve: Curves.easeInOut,
    ));

    // Start animation with delay
    Future.delayed(widget.animationDelay, () {
      if (mounted) _controller.forward();
    });
  }

  Future<void> _checkFavoriteStatus() async {
    final isFavorite = await ShopService.isFavorite(widget.product.id);
    if (mounted) {
      setState(() => _isFavorite = isFavorite);
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() => _isLoading = true);
    
    final success = await ShopService.toggleFavorite(widget.product.id);
    
    if (success) {
      setState(() => _isFavorite = !_isFavorite);
      _favoriteController.forward().then((_) {
        _favoriteController.reverse();
      });
    }
    
    setState(() => _isLoading = false);
  }

  void _onTapDown() {
    _tapController.forward();
  }

  void _onTapUp() {
    _tapController.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    _favoriteController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _favoriteController, _tapController]),
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value * _tapAnimation.value,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: GestureDetector(
                onTapDown: (_) => _onTapDown(),
                onTapUp: (_) => _onTapUp(),
                onTapCancel: () => _onTapUp(),
                onTap: () => _showProductDetails(),
                child: Container(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImageSection(),
                      _buildInfoSection(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSection() {
    return Expanded(
      flex: 3,
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.primaryPink.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // Product image placeholder
            Center(
              child: Icon(
                _getProductIcon(),
                size: 48,
                color: AppTheme.primaryPink.withOpacity(0.7),
              ),
            ),

            // Category badge
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.product.category.index.isEven 
                      ? AppTheme.primaryPink 
                      : AppTheme.consultationOrange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.product.categoryEmoji,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),

            // Favorite button
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: _toggleFavorite,
                child: Transform.scale(
                  scale: _favoriteAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(AppTheme.primaryPink),
                            ),
                          )
                        : Icon(
                            _isFavorite ? Icons.favorite : Icons.favorite_outline,
                            size: 16,
                            color: _isFavorite ? Colors.red : AppTheme.lightGray,
                          ),
                  ),
                ),
              ),
            ),

            // Stock status
            if (!widget.product.isAvailable)
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Rupture',
                    style: AppTheme.captionStyle.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product name
            Text(
              widget.product.name,
              style: AppTheme.bodyTextStyle.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 4),
            
            // Brand
            Text(
              widget.product.brand,
              style: AppTheme.captionStyle.copyWith(
                color: AppTheme.lightGray,
                fontSize: 12,
              ),
            ),
            
            const Spacer(),
            
            // Rating and price row
            Row(
              children: [
                // Rating
                if (widget.product.reviewCount > 0) ...[
                  Icon(
                    Icons.star,
                    size: 14,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    widget.product.rating.toStringAsFixed(1),
                    style: AppTheme.captionStyle.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${widget.product.reviewCount})',
                    style: AppTheme.captionStyle.copyWith(
                      color: AppTheme.lightGray,
                      fontSize: 10,
                    ),
                  ),
                ],
                
                const Spacer(),
                
                // Price
                Text(
                  widget.product.formattedPrice,
                  style: AppTheme.bodyTextStyle.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryPink,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Add to cart button
            SizedBox(
              width: double.infinity,
              height: 32,
              child: ElevatedButton(
                onPressed: widget.product.isAvailable ? widget.onAddToCart : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPink,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  widget.product.isAvailable ? 'Ajouter' : 'Indisponible',
                  style: AppTheme.captionStyle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getProductIcon() {
    switch (widget.product.category) {
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

  void _showProductDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductDetailsModal(
        product: widget.product,
        onAddToCart: widget.onAddToCart,
      ),
    );
  }
}

class ProductDetailsModal extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;

  const ProductDetailsModal({
    Key? key,
    required this.product,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
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

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image section
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPink.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Icon(
                        _getProductIcon(),
                        size: 80,
                        color: AppTheme.primaryPink.withOpacity(0.7),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Product info
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: AppTheme.headerStyle.copyWith(fontSize: 20),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product.brand,
                              style: AppTheme.captionStyle.copyWith(
                                color: AppTheme.lightGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        product.formattedPrice,
                        style: AppTheme.headerStyle.copyWith(
                          color: AppTheme.primaryPink,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Rating
                  if (product.reviewCount > 0)
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < product.rating.floor()
                                ? Icons.star
                                : Icons.star_outline,
                            size: 20,
                            color: Colors.amber,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          '${product.rating} (${product.reviewCount} avis)',
                          style: AppTheme.captionStyle,
                        ),
                      ],
                    ),

                  const SizedBox(height: 20),

                  // Description
                  Text(
                    'Description',
                    style: AppTheme.subHeaderStyle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: AppTheme.bodyTextStyle,
                  ),

                  const SizedBox(height: 20),

                  // Tags
                  if (product.tags.isNotEmpty) ...[
                    Text(
                      'Caractéristiques',
                      style: AppTheme.subHeaderStyle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: product.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryPink.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            tag,
                            style: AppTheme.captionStyle.copyWith(
                              color: AppTheme.primaryPink,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),

          // Bottom action area
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: product.isAvailable ? () {
                        Navigator.of(context).pop();
                        onAddToCart();
                      } : null,
                      style: AppTheme.primaryButtonStyle,
                      child: Text(
                        product.isAvailable ? 'Ajouter au panier' : 'Indisponible',
                        style: AppTheme.bodyStyle.copyWith(
                          color: AppTheme.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getProductIcon() {
    switch (product.category) {
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