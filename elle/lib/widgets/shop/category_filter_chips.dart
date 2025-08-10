import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../core/models/product.dart';

class CategoryFilterChips extends StatefulWidget {
  final ProductCategory? selectedCategory;
  final Function(ProductCategory?) onCategorySelected;

  const CategoryFilterChips({
    Key? key,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  State<CategoryFilterChips> createState() => _CategoryFilterChipsState();
}

class _CategoryFilterChipsState extends State<CategoryFilterChips>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<AnimationController> _chipControllers;
  late List<Animation<double>> _chipAnimations;

  final List<CategoryChipData> _categories = [
    CategoryChipData(
      category: null,
      label: 'Tout',
      emoji: '🛍️',
      color: AppTheme.primaryPink,
    ),
    CategoryChipData(
      category: ProductCategory.contraception,
      label: 'Contraception',
      emoji: '🛡️',
      color: const Color(0xFF6366F1),
    ),
    CategoryChipData(
      category: ProductCategory.hygiene,
      label: 'Hygiène',
      emoji: '🧼',
      color: const Color(0xFF10B981),
    ),
    CategoryChipData(
      category: ProductCategory.supplements,
      label: 'Compléments',
      emoji: '💊',
      color: const Color(0xFFF59E0B),
    ),
    CategoryChipData(
      category: ProductCategory.intimacy,
      label: 'Intimité',
      emoji: '💕',
      color: const Color(0xFFEC4899),
    ),
    CategoryChipData(
      category: ProductCategory.education,
      label: 'Éducation',
      emoji: '📚',
      color: const Color(0xFF8B5CF6),
    ),
    CategoryChipData(
      category: ProductCategory.comfort,
      label: 'Confort',
      emoji: '🌸',
      color: const Color(0xFF06B6D4),
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

    _chipControllers = List.generate(
      _categories.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _chipAnimations = _chipControllers.map((controller) {
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
    for (int i = 0; i < _chipControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) _chipControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    for (var controller in _chipControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final categoryData = _categories[index];
          final isSelected = widget.selectedCategory == categoryData.category;

          return AnimatedBuilder(
            animation: _chipAnimations[index],
            builder: (context, child) {
              return Transform.scale(
                scale: _chipAnimations[index].value,
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: CategoryChip(
                    categoryData: categoryData,
                    isSelected: isSelected,
                    onTap: () => widget.onCategorySelected(categoryData.category),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class CategoryChipData {
  final ProductCategory? category;
  final String label;
  final String emoji;
  final Color color;

  CategoryChipData({
    required this.category,
    required this.label,
    required this.emoji,
    required this.color,
  });
}

class CategoryChip extends StatefulWidget {
  final CategoryChipData categoryData;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    Key? key,
    required this.categoryData,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  State<CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<CategoryChip>
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
      end: 0.95,
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
      end: 1.05,
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
  void didUpdateWidget(CategoryChip oldWidget) {
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
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: widget.isSelected 
                    ? widget.categoryData.color
                    : widget.categoryData.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: widget.isSelected
                      ? widget.categoryData.color
                      : widget.categoryData.color.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: widget.categoryData.color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Emoji with animation
                  Transform.scale(
                    scale: 1.0 + (_selectionAnimation.value * 0.2),
                    child: Text(
                      widget.categoryData.emoji,
                      style: TextStyle(
                        fontSize: 16 + (_selectionAnimation.value * 2),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Label
                  Text(
                    widget.categoryData.label,
                    style: AppTheme.bodyTextStyle.copyWith(
                      fontSize: 14,
                      fontWeight: widget.isSelected 
                          ? FontWeight.w600 
                          : FontWeight.w500,
                      color: widget.isSelected
                          ? Colors.white
                          : widget.categoryData.color,
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