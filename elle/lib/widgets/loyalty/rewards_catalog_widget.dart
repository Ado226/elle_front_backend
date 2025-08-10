import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../core/models/loyalty.dart';
import '../../services/loyalty_service.dart';
import 'reward_card_widget.dart';
import 'reward_detail_widget.dart';

class RewardsCatalogWidget extends StatefulWidget {
  final List<Reward> featuredRewards;
  final List<Reward> allRewards;
  final int availablePoints;
  final VoidCallback onRewardClaimed;
  final VoidCallback onRefresh;

  const RewardsCatalogWidget({
    Key? key,
    required this.featuredRewards,
    required this.allRewards,
    required this.availablePoints,
    required this.onRewardClaimed,
    required this.onRefresh,
  }) : super(key: key);

  @override
  State<RewardsCatalogWidget> createState() => _RewardsCatalogWidgetState();
}

class _RewardsCatalogWidgetState extends State<RewardsCatalogWidget>
    with TickerProviderStateMixin {
  late AnimationController _staggerController;
  RewardCategory? _selectedCategory;
  RewardType? _selectedType;
  bool _showAffordableOnly = false;
  List<Reward> _filteredRewards = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _applyFilters();
  }

  void _initializeAnimations() {
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _staggerController.forward();
    });
  }

  @override
  void didUpdateWidget(RewardsCatalogWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.allRewards != widget.allRewards) {
      _applyFilters();
    }
  }

  void _applyFilters() {
    var filtered = List<Reward>.from(widget.allRewards);

    if (_selectedCategory != null) {
      filtered = filtered.where((r) => r.category == _selectedCategory).toList();
    }

    if (_selectedType != null) {
      filtered = filtered.where((r) => r.type == _selectedType).toList();
    }

    if (_showAffordableOnly) {
      filtered = filtered.where((r) => r.pointsCost <= widget.availablePoints).toList();
    }

    setState(() {
      _filteredRewards = filtered;
    });
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => widget.onRefresh(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter bar
            _buildFilterBar(),

            const SizedBox(height: 20),

            // Featured rewards section
            if (widget.featuredRewards.isNotEmpty && _selectedCategory == null && _selectedType == null) ...[
              _buildSectionHeader(
                title: 'Récompenses vedettes',
                subtitle: 'Nos meilleures offres du moment',
                icon: Icons.stars,
              ),
              const SizedBox(height: 12),
              _buildFeaturedRewards(),
              const SizedBox(height: 24),
            ],

            // Quick actions
            _buildQuickActions(),

            const SizedBox(height: 24),

            // All rewards section
            _buildSectionHeader(
              title: _getFilteredSectionTitle(),
              subtitle: '${_filteredRewards.length} récompense${_filteredRewards.length > 1 ? 's' : ''} disponible${_filteredRewards.length > 1 ? 's' : ''}',
              icon: Icons.card_giftcard,
            ),
            const SizedBox(height: 12),

            if (_filteredRewards.isEmpty) ...[
              _buildEmptyState(),
            ] else ...[
              _buildRewardsList(),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightGray.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_list,
                color: AppTheme.primaryPink,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Filtres',
                style: AppTheme.bodyTextStyle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (_hasActiveFilters())
                TextButton(
                  onPressed: _clearFilters,
                  child: Text(
                    'Effacer',
                    style: AppTheme.captionStyle.copyWith(
                      color: AppTheme.primaryPink,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Category chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip(
                label: 'Budget',
                isSelected: _showAffordableOnly,
                onTap: () {
                  setState(() {
                    _showAffordableOnly = !_showAffordableOnly;
                  });
                  _applyFilters();
                },
                icon: Icons.account_balance_wallet,
              ),
              ...RewardCategory.values.map((category) {
                return _buildFilterChip(
                  label: _getCategoryDisplayName(category),
                  isSelected: _selectedCategory == category,
                  onTap: () {
                    setState(() {
                      _selectedCategory = _selectedCategory == category ? null : category;
                    });
                    _applyFilters();
                  },
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.primaryPink.withOpacity(0.1)
              : AppTheme.lightGray.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? AppTheme.primaryPink
                : AppTheme.lightGray.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected 
                    ? AppTheme.primaryPink
                    : AppTheme.lightGray,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTheme.captionStyle.copyWith(
                color: isSelected 
                    ? AppTheme.primaryPink
                    : AppTheme.lightGray,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions rapides',
          style: AppTheme.subHeaderStyle.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                title: 'À ma portée',
                subtitle: '${widget.allRewards.where((r) => r.pointsCost <= widget.availablePoints).length} récompenses',
                icon: Icons.monetization_on,
                color: Colors.green,
                onTap: () {
                  setState(() {
                    _selectedCategory = null;
                    _selectedType = null;
                    _showAffordableOnly = true;
                  });
                  _applyFilters();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                title: 'Exclusives',
                subtitle: '${widget.allRewards.where((r) => r.isExclusive).length} récompenses',
                icon: Icons.diamond,
                color: Colors.purple,
                onTap: () {
                  final exclusiveRewards = widget.allRewards.where((r) => r.isExclusive).toList();
                  setState(() {
                    _selectedCategory = null;
                    _selectedType = null;
                    _showAffordableOnly = false;
                    _filteredRewards = exclusiveRewards;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTheme.bodyTextStyle.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTheme.captionStyle.copyWith(
                color: AppTheme.lightGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryPink,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.subHeaderStyle.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                subtitle,
                style: AppTheme.captionStyle.copyWith(
                  color: AppTheme.lightGray,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedRewards() {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.featuredRewards.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final reward = widget.featuredRewards[index];
          return SizedBox(
            width: 280,
            child: RewardCardWidget(
              reward: reward,
              availablePoints: widget.availablePoints,
              onTap: () => _showRewardDetail(reward),
              isFeatured: true,
            ),
          );
        },
      ),
    );
  }

  Widget _buildRewardsList() {
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredRewards.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final reward = _filteredRewards[index];
            final delay = index * 0.1;
            final animation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: _staggerController,
              curve: Interval(delay, delay + 0.3, curve: Curves.easeOutCubic),
            ));

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(animation),
                child: RewardCardWidget(
                  reward: reward,
                  availablePoints: widget.availablePoints,
                  onTap: () => _showRewardDetail(reward),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
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
            Icons.search_off,
            size: 48,
            color: AppTheme.lightGray,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune récompense trouvée',
            style: AppTheme.bodyTextStyle.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez de modifier vos filtres ou gagnez plus de points',
            style: AppTheme.captionStyle.copyWith(
              color: AppTheme.lightGray,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _clearFilters,
            child: Text(
              'Effacer les filtres',
              style: AppTheme.bodyTextStyle.copyWith(
                color: AppTheme.primaryPink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRewardDetail(Reward reward) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => RewardDetailWidget(
          reward: reward,
          availablePoints: widget.availablePoints,
          scrollController: scrollController,
          onClaimed: () {
            Navigator.of(context).pop();
            widget.onRewardClaimed();
          },
        ),
      ),
    );
  }

  String _getFilteredSectionTitle() {
    if (_selectedCategory != null) {
      return 'Récompenses ${_getCategoryDisplayName(_selectedCategory!)}';
    }
    if (_showAffordableOnly) {
      return 'Récompenses à votre portée';
    }
    return 'Toutes les récompenses';
  }

  String _getCategoryDisplayName(RewardCategory category) {
    switch (category) {
      case RewardCategory.health:
        return 'Santé';
      case RewardCategory.beauty:
        return 'Beauté';
      case RewardCategory.wellness:
        return 'Bien-être';
      case RewardCategory.shopping:
        return 'Shopping';
      case RewardCategory.experiences:
        return 'Expériences';
      case RewardCategory.digital:
        return 'Numérique';
      case RewardCategory.charity:
        return 'Charité';
    }
  }

  bool _hasActiveFilters() {
    return _selectedCategory != null || _selectedType != null || _showAffordableOnly;
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedType = null;
      _showAffordableOnly = false;
    });
    _applyFilters();
  }
}