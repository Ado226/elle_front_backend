import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../theme/app_theme.dart';
import '../../core/models/partner.dart';

class CareGesturesWidget extends StatefulWidget {
  final List<CareGesture> gestures;
  final Function(CareGesture)? onGestureComplete;
  final Function(CareGesture)? onGestureDetails;

  const CareGesturesWidget({
    Key? key,
    required this.gestures,
    this.onGestureComplete,
    this.onGestureDetails,
  }) : super(key: key);

  @override
  State<CareGesturesWidget> createState() => _CareGesturesWidgetState();
}

class _CareGesturesWidgetState extends State<CareGesturesWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  String _selectedCategory = 'all';
  
  final List<String> _categories = [
    'all',
    'romantic',
    'supportive',
    'caring',
    'thoughtful',
    'surprise',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredGestures = _getFilteredGestures();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gestes d\'Attention',
                style: AppTheme.bodyTextStyle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () => _showAllGestures(),
                child: Text(
                  'Voir tout',
                  style: AppTheme.captionStyle.copyWith(
                    color: AppTheme.primaryPink,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Category filter
          _buildCategoryFilter(),

          const SizedBox(height: 16),

          // Gestures grid
          _buildGesturesGrid(filteredGestures),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppTheme.primaryPink
                    : AppTheme.primaryPink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected 
                      ? AppTheme.primaryPink
                      : AppTheme.primaryPink.withOpacity(0.3),
                ),
              ),
              child: Text(
                _getCategoryDisplayName(category),
                style: AppTheme.captionStyle.copyWith(
                  color: isSelected ? Colors.white : AppTheme.primaryPink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGesturesGrid(List<CareGesture> gestures) {
    if (gestures.isEmpty) {
      return _buildEmptyState();
    }

    return AnimationLimiter(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: gestures.length > 4 ? 4 : gestures.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 375),
            columnCount: 2,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: CareGestureCard(
                  gesture: gestures[index],
                  onTap: () => widget.onGestureDetails?.call(gestures[index]),
                  onComplete: () => _completeGesture(gestures[index]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 120,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 32,
            color: AppTheme.lightGray,
          ),
          const SizedBox(height: 8),
          Text(
            'Aucun geste pour cette catégorie',
            style: AppTheme.captionStyle.copyWith(
              color: AppTheme.lightGray,
            ),
          ),
        ],
      ),
    );
  }

  List<CareGesture> _getFilteredGestures() {
    if (_selectedCategory == 'all') return widget.gestures;
    return widget.gestures.where((gesture) => gesture.category.name == _selectedCategory).toList();
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'all':
        return 'Tout';
      case 'romantic':
        return 'Romantique';
      case 'supportive':
        return 'Soutien';
      case 'caring':
        return 'Attention';
      case 'thoughtful':
        return 'Prévenance';
      case 'surprise':
        return 'Surprise';
      default:
        return category;
    }
  }

  void _completeGesture(CareGesture gesture) {
    widget.onGestureComplete?.call(gesture);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Geste "${gesture.title}" marqué comme accompli!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showAllGestures() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CareGesturesListSheet(
        gestures: widget.gestures,
        onGestureComplete: widget.onGestureComplete,
        onGestureDetails: widget.onGestureDetails,
      ),
    );
  }
}

class CareGestureCard extends StatefulWidget {
  final CareGesture gesture;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;

  const CareGestureCard({
    Key? key,
    required this.gesture,
    this.onTap,
    this.onComplete,
  }) : super(key: key);

  @override
  State<CareGestureCard> createState() => _CareGestureCardState();
}

class _CareGestureCardState extends State<CareGestureCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _hoverController.forward(),
            onTapUp: (_) {
              _hoverController.reverse();
              widget.onTap?.call();
            },
            onTapCancel: () => _hoverController.reverse(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.gesture.isCompleted 
                    ? Colors.green.withOpacity(0.1)
                    : AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.gesture.isCompleted 
                      ? Colors.green.withOpacity(0.3)
                      : AppTheme.lightGray.withOpacity(0.2),
                ),
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
                  // Icon and category
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _getCategoryColor(widget.gesture.category).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          _getCategoryIcon(widget.gesture.category),
                          color: _getCategoryColor(widget.gesture.category),
                          size: 18,
                        ),
                      ),
                      if (widget.gesture.isCompleted)
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 18,
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Title
                  Text(
                    widget.gesture.title,
                    style: AppTheme.bodyTextStyle.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Description
                  Text(
                    widget.gesture.description,
                    style: AppTheme.captionStyle.copyWith(
                      color: AppTheme.lightGray,
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const Spacer(),

                  // Bottom row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 12,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${widget.gesture.points}',
                            style: AppTheme.captionStyle.copyWith(
                              color: Colors.amber,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      if (!widget.gesture.isCompleted)
                        GestureDetector(
                          onTap: widget.onComplete,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryPink.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Fait',
                              style: AppTheme.captionStyle.copyWith(
                                color: AppTheme.primaryPink,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(GestureCategory category) {
    switch (category) {
      case GestureCategory.romantic:
        return Icons.favorite;
      case GestureCategory.supportive:
        return Icons.support;
      case GestureCategory.caring:
        return Icons.healing;
      case GestureCategory.thoughtful:
        return Icons.lightbulb;
      case GestureCategory.surprise:
        return Icons.card_giftcard;
      default:
        return Icons.gesture;
    }
  }

  Color _getCategoryColor(GestureCategory category) {
    switch (category) {
      case GestureCategory.romantic:
        return Colors.red;
      case GestureCategory.supportive:
        return Colors.blue;
      case GestureCategory.caring:
        return Colors.green;
      case GestureCategory.thoughtful:
        return Colors.purple;
      case GestureCategory.surprise:
        return Colors.orange;
      default:
        return AppTheme.primaryPink;
    }
  }
}

class CareGesturesListSheet extends StatelessWidget {
  final List<CareGesture> gestures;
  final Function(CareGesture)? onGestureComplete;
  final Function(CareGesture)? onGestureDetails;

  const CareGesturesListSheet({
    Key? key,
    required this.gestures,
    this.onGestureComplete,
    this.onGestureDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tous les gestes d\'attention',
                  style: AppTheme.headerStyle.copyWith(fontSize: 18),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Gestures list
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: gestures.length,
              itemBuilder: (context, index) {
                return CareGestureCard(
                  gesture: gestures[index],
                  onTap: () => onGestureDetails?.call(gestures[index]),
                  onComplete: () => onGestureComplete?.call(gestures[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

