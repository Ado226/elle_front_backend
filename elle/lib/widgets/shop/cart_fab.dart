import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CartFAB extends StatefulWidget {
  final int itemCount;
  final VoidCallback onPressed;

  const CartFAB({
    Key? key,
    required this.itemCount,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<CartFAB> createState() => _CartFABState();
}

class _CartFABState extends State<CartFAB>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _bounceController;
  late AnimationController _pulseController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _badgeAnimation;

  int _previousItemCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _previousItemCount = widget.itemCount;
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _badgeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.itemCount > 0) {
        _controller.forward();
        _pulseController.repeat(reverse: true);
      }
    });
  }

  @override
  void didUpdateWidget(CartFAB oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.itemCount != oldWidget.itemCount) {
      if (widget.itemCount > 0) {
        if (oldWidget.itemCount == 0) {
          // First item added - show FAB
          _controller.forward();
          _pulseController.repeat(reverse: true);
        }
        
        if (widget.itemCount > _previousItemCount) {
          // Item count increased - bounce animation
          _bounceController.forward().then((_) {
            _bounceController.reverse();
          });
        }
      } else {
        // No items - hide FAB
        _controller.reverse();
        _pulseController.stop();
        _pulseController.reset();
      }
      
      _previousItemCount = widget.itemCount;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _bounceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount == 0) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _bounceController, _pulseController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value * _pulseAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Main FAB
                FloatingActionButton.extended(
                  onPressed: widget.onPressed,
                  backgroundColor: AppTheme.primaryPink,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shopping_bag,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Panier',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Item count badge
                Positioned(
                  top: -8,
                  right: -8,
                  child: Transform.scale(
                    scale: _bounceAnimation.value * _badgeAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryPink,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryPink.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                      child: Center(
                        child: Text(
                          widget.itemCount > 99 ? '99+' : widget.itemCount.toString(),
                          style: TextStyle(
                            color: AppTheme.primaryPink,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),

                // Ripple effect when items are added
                if (_bounceController.isAnimating)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryPink.withOpacity(
                            0.5 * (1 - _bounceAnimation.value),
                          ),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}