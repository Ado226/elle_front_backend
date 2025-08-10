import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../core/models/loyalty.dart';
import '../../services/loyalty_service.dart';

class ClaimedRewardsWidget extends StatefulWidget {
  final List<ClaimedReward> claimedRewards;
  final VoidCallback onRefresh;

  const ClaimedRewardsWidget({
    Key? key,
    required this.claimedRewards,
    required this.onRefresh,
  }) : super(key: key);

  @override
  State<ClaimedRewardsWidget> createState() => _ClaimedRewardsWidgetState();
}

class _ClaimedRewardsWidgetState extends State<ClaimedRewardsWidget>
    with TickerProviderStateMixin {
  late AnimationController _staggerController;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
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
            // Summary card
            _buildSummaryCard(),

            const SizedBox(height: 24),

            // Active rewards
            if (widget.claimedRewards.where((r) => r.isActive).isNotEmpty) ...[
              _buildSectionHeader(
                title: 'Récompenses actives',
                subtitle: '${widget.claimedRewards.where((r) => r.isActive).length} récompense(s) utilisable(s)',
                icon: Icons.check_circle,
                color: Colors.green,
              ),
              const SizedBox(height: 12),
              _buildActiveRewards(),
              const SizedBox(height: 24),
            ],

            // All claimed rewards
            _buildSectionHeader(
              title: 'Historique complet',
              subtitle: '${widget.claimedRewards.length} récompense(s) réclamée(s)',
              icon: Icons.history,
              color: AppTheme.primaryPink,
            ),
            const SizedBox(height: 12),

            if (widget.claimedRewards.isEmpty) ...[
              _buildEmptyState(),
            ] else ...[
              _buildClaimedRewardsList(),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final activeRewards = widget.claimedRewards.where((r) => r.isActive).length;
    final totalPointsUsed = widget.claimedRewards.fold<int>(
      0, 
      (sum, reward) => sum + reward.pointsUsed,
    );
    final usedRewards = widget.claimedRewards.where((r) => r.isUsed).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryPink,
            AppTheme.primaryPink.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.card_giftcard,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mes récompenses',
                      style: AppTheme.subHeaderStyle.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Gérez vos gains fidélité',
                      style: AppTheme.captionStyle.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.stars,
                  label: 'Points utilisés',
                  value: '$totalPointsUsed',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.check_circle,
                  label: 'Actives',
                  value: '$activeRewards',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.done_all,
                  label: 'Utilisées',
                  value: '$usedRewards',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTheme.bodyTextStyle.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.captionStyle.copyWith(
            color: Colors.white.withOpacity(0.9),
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
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

  Widget _buildActiveRewards() {
    final activeRewards = widget.claimedRewards.where((r) => r.isActive).toList();
    
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activeRewards.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final reward = activeRewards[index];
        return _buildActiveRewardCard(reward);
      },
    );
  }

  Widget _buildActiveRewardCard(ClaimedReward reward) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withOpacity(0.1),
            Colors.green.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getRewardTypeIcon(reward.rewardType),
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reward.rewardTitle,
                      style: AppTheme.bodyTextStyle.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Réclamé ${LoyaltyService.formatTimeAgo(reward.claimedAt)}',
                      style: AppTheme.captionStyle.copyWith(
                        color: AppTheme.lightGray,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'ACTIF',
                  style: AppTheme.captionStyle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),

          if (reward.promoCode != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Code promo',
                          style: AppTheme.captionStyle.copyWith(
                            color: AppTheme.lightGray,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reward.promoCode!,
                          style: AppTheme.bodyTextStyle.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            letterSpacing: 2,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _copyPromoCode(reward.promoCode!),
                    icon: Icon(
                      Icons.copy,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (reward.expiryDate != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Expire le ${_formatDate(reward.expiryDate!)}',
                  style: AppTheme.captionStyle.copyWith(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildClaimedRewardsList() {
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.claimedRewards.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final reward = widget.claimedRewards[index];
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
                child: _buildClaimedRewardCard(reward),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildClaimedRewardCard(ClaimedReward reward) {
    final isActive = reward.isActive;
    final isExpired = reward.isExpired;
    final isUsed = reward.isUsed;

    Color statusColor = Colors.green;
    String statusText = 'Actif';
    IconData statusIcon = Icons.check_circle;

    if (isUsed) {
      statusColor = Colors.blue;
      statusText = 'Utilisé';
      statusIcon = Icons.done_all;
    } else if (isExpired) {
      statusColor = Colors.red;
      statusText = 'Expiré';
      statusIcon = Icons.error;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive 
              ? statusColor.withOpacity(0.3)
              : AppTheme.lightGray.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getRewardTypeIcon(reward.rewardType),
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reward.rewardTitle,
                      style: AppTheme.bodyTextStyle.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isActive ? AppTheme.darkText : AppTheme.lightGray,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Réclamé ${LoyaltyService.formatTimeAgo(reward.claimedAt)}',
                      style: AppTheme.captionStyle.copyWith(
                        color: AppTheme.lightGray,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          color: statusColor,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: AppTheme.captionStyle.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '-${reward.pointsUsed} pts',
                    style: AppTheme.captionStyle.copyWith(
                      color: AppTheme.lightGray,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (reward.promoCode != null && isActive) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.lightGray.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Code: ${reward.promoCode}',
                      style: AppTheme.captionStyle.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _copyPromoCode(reward.promoCode!),
                    child: Icon(
                      Icons.copy,
                      color: AppTheme.primaryPink,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (reward.expiryDate != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: isExpired ? Colors.red : Colors.orange,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  isExpired 
                      ? 'Expiré le ${_formatDate(reward.expiryDate!)}'
                      : 'Expire le ${_formatDate(reward.expiryDate!)}',
                  style: AppTheme.captionStyle.copyWith(
                    color: isExpired ? Colors.red : Colors.orange.shade700,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],

          if (reward.usedAt != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.check,
                  color: Colors.blue,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  'Utilisé ${LoyaltyService.formatTimeAgo(reward.usedAt!)}',
                  style: AppTheme.captionStyle.copyWith(
                    color: Colors.blue,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
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
            Icons.card_giftcard_outlined,
            size: 48,
            color: AppTheme.lightGray,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune récompense réclamée',
            style: AppTheme.bodyTextStyle.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Explorez le catalogue pour découvrir nos récompenses et commencez à les réclamer !',
            style: AppTheme.captionStyle.copyWith(
              color: AppTheme.lightGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _copyPromoCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Code "$code" copié !'),
        backgroundColor: AppTheme.primaryPink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  IconData _getRewardTypeIcon(RewardType type) {
    switch (type) {
      case RewardType.discount:
        return Icons.percent;
      case RewardType.freeProduct:
        return Icons.redeem;
      case RewardType.cashback:
        return Icons.monetization_on;
      case RewardType.experience:
        return Icons.explore;
      case RewardType.digitalContent:
        return Icons.download;
      case RewardType.donation:
        return Icons.favorite;
      case RewardType.exclusive:
        return Icons.diamond;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}