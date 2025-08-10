import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../core/models/community.dart';

class CategoryTabs extends StatefulWidget {
  final List<ForumCategory> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryTabs({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  State<CategoryTabs> createState() => _CategoryTabsState();
}

class _CategoryTabsState extends State<CategoryTabs>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late ScrollController _scrollController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scrollController = ScrollController();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Add "all" category at the beginning
    final allCategories = [
      ForumCategory(
        id: 'all',
        name: 'Tout',
        icon: Icons.dashboard,
        color: AppTheme.primaryPink,
        description: 'Toutes les discussions',
      ),
      ...widget.categories,
    ];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: allCategories.length,
            itemBuilder: (context, index) {
              final category = allCategories[index];
              final isSelected = widget.selectedCategory == category.id;
              
              return AnimatedContainer(
                duration: Duration(milliseconds: 200 + (index * 50)),
                curve: Curves.easeOutBack,
                margin: const EdgeInsets.only(right: 12),
                child: CategoryTab(
                  category: category,
                  isSelected: isSelected,
                  onTap: () => widget.onCategorySelected(category.id),
                  animationDelay: index * 100,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class CategoryTab extends StatefulWidget {
  final ForumCategory category;
  final bool isSelected;
  final VoidCallback onTap;
  final int animationDelay;

  const CategoryTab({
    Key? key,
    required this.category,
    required this.isSelected,
    required this.onTap,
    this.animationDelay = 0,
  }) : super(key: key);

  @override
  State<CategoryTab> createState() => _CategoryTabState();
}

class _CategoryTabState extends State<CategoryTab>
    with TickerProviderStateMixin {
  late AnimationController _tapController;
  late AnimationController _selectionController;
  late AnimationController _bounceController;
  
  late Animation<double> _tapAnimation;
  late Animation<double> _selectionAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startInitialAnimation();
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

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
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

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    if (widget.isSelected) {
      _selectionController.forward();
    }
  }

  void _startInitialAnimation() {
    Future.delayed(Duration(milliseconds: widget.animationDelay), () {
      if (mounted) {
        _bounceController.forward();
      }
    });
  }

  @override
  void didUpdateWidget(CategoryTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _selectionController.forward();
      } else {
        _selectionController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _tapController.dispose();
    _selectionController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _tapController,
        _selectionController,
        _bounceController,
      ]),
      builder: (context, child) {
        final scale = _tapAnimation.value * _bounceAnimation.value;
        
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTapDown: (_) => _tapController.forward(),
            onTapUp: (_) {
              _tapController.reverse();
              widget.onTap();
            },
            onTapCancel: () => _tapController.reverse(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: widget.isSelected 
                    ? widget.category.color
                    : widget.category.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.isSelected 
                      ? widget.category.color
                      : widget.category.color.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: widget.category.color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.scale(
                    scale: 1.0 + (_selectionAnimation.value * 0.1),
                    child: Icon(
                      widget.category.icon,
                      size: 16,
                      color: widget.isSelected 
                          ? Colors.white
                          : widget.category.color,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.category.name,
                    style: AppTheme.captionStyle.copyWith(
                      color: widget.isSelected 
                          ? Colors.white
                          : widget.category.color,
                      fontWeight: widget.isSelected 
                          ? FontWeight.w600
                          : FontWeight.w500,
                      fontSize: 13,
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

// Extension to provide default categories if none are provided
extension CategoryTabsExtension on CategoryTabs {
  static List<ForumCategory> get defaultCategories => [
    ForumCategory(
      id: 'health',
      name: 'Santé',
      icon: Icons.favorite,
      color: Colors.red,
      description: 'Discussions sur la santé féminine',
    ),
    ForumCategory(
      id: 'cycle',
      name: 'Cycle',
      icon: Icons.calendar_month,
      color: Colors.purple,
      description: 'Questions sur le cycle menstruel',
    ),
    ForumCategory(
      id: 'contraception',
      name: 'Contraception',
      icon: Icons.medical_services,
      color: Colors.blue,
      description: 'Méthodes contraceptives',
    ),
    ForumCategory(
      id: 'nutrition',
      name: 'Nutrition',
      icon: Icons.restaurant,
      color: Colors.green,
      description: 'Alimentation et nutrition',
    ),
    ForumCategory(
      id: 'wellness',
      name: 'Bien-être',
      icon: Icons.spa,
      color: Colors.teal,
      description: 'Bien-être et lifestyle',
    ),
    ForumCategory(
      id: 'relationships',
      name: 'Relations',
      icon: Icons.people,
      color: Colors.orange,
      description: 'Relations et intimité',
    ),
  ];
}