import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../core/models/loyalty.dart';
import '../../services/loyalty_service.dart';

class PointsHistoryWidget extends StatefulWidget {
  final List<PointTransaction> transactions;
  final LoyaltyPoints loyaltyPoints;
  final VoidCallback onRefresh;

  const PointsHistoryWidget({
    Key? key,
    required this.transactions,
    required this.loyaltyPoints,
    required this.onRefresh,
  }) : super(key: key);

  @override
  State<PointsHistoryWidget> createState() => _PointsHistoryWidgetState();
}

class _PointsHistoryWidgetState extends State<PointsHistoryWidget>
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
            // Statistics overview
            _buildStatisticsOverview(),

            const SizedBox(height: 24),

            // Points breakdown
            _buildPointsBreakdown(),

            const SizedBox(height: 24),

            // Transaction history
            _buildSectionHeader(
              title: 'Historique des transactions',
              subtitle: '${widget.transactions.length} transaction(s) récente(s)',
              icon: Icons.receipt_long,
            ),
            const SizedBox(height: 12),

            if (widget.transactions.isEmpty) ...[
              _buildEmptyState(),
            ] else ...[
              _buildTransactionsList(),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsOverview() {
    final earnedTransactions = widget.transactions.where((t) => t.isEarned);
    final spentTransactions = widget.transactions.where((t) => t.isSpent);
    
    final totalEarned = earnedTransactions.fold<int>(0, (sum, t) => sum + t.points);
    final totalSpent = spentTransactions.fold<int>(0, (sum, t) => sum + t.points.abs());
    final avgEarned = earnedTransactions.isEmpty ? 0 : (totalEarned / earnedTransactions.length).round();

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
                  Icons.analytics,
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
                      'Statistiques',
                      style: AppTheme.subHeaderStyle.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Résumé de votre activité',
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
                child: _buildStatItem(
                  icon: Icons.add_circle,
                  label: 'Gagnés',
                  value: '+$totalEarned',
                  subtitle: '${earnedTransactions.length} transaction(s)',
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.remove_circle,
                  label: 'Dépensés',
                  value: '-$totalSpent',
                  subtitle: '${spentTransactions.length} transaction(s)',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Moyenne par gain:',
                  style: AppTheme.captionStyle.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                Text(
                  '$avgEarned pts',
                  style: AppTheme.bodyTextStyle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required String subtitle,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTheme.bodyTextStyle.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.captionStyle.copyWith(
            color: Colors.white.withOpacity(0.9),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: AppTheme.captionStyle.copyWith(
            color: Colors.white.withOpacity(0.7),
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPointsBreakdown() {
    final pointsBySource = widget.loyaltyPoints.pointsBySource;
    final sortedEntries = pointsBySource.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'Répartition par source',
          subtitle: 'D\'où viennent vos points',
          icon: Icons.pie_chart,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.lightGray.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: sortedEntries.map((entry) {
              final source = entry.key;
              final points = entry.value;
              final percentage = widget.loyaltyPoints.lifetimePoints > 0 
                  ? (points / widget.loyaltyPoints.lifetimePoints * 100).round()
                  : 0;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildSourceBreakdownItem(source, points, percentage),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSourceBreakdownItem(PointSource source, int points, int percentage) {
    final color = _getSourceColor(source);
    
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              _getSourceIcon(source),
              color: color,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                source.sourceDisplayName,
                style: AppTheme.bodyTextStyle.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '$points pts',
              style: AppTheme.bodyTextStyle.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$percentage%',
              style: AppTheme.captionStyle.copyWith(
                color: AppTheme.lightGray,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: AppTheme.lightGray.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 4,
          ),
        ),
      ],
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

  Widget _buildTransactionsList() {
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.transactions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final transaction = widget.transactions[index];
            final delay = index * 0.05;
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
                child: _buildTransactionItem(transaction),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTransactionItem(PointTransaction transaction) {
    final isEarned = transaction.isEarned;
    final color = isEarned ? Colors.green : Colors.red;
    final icon = _getSourceIcon(transaction.source);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightGray.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getSourceColor(transaction.source).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: _getSourceColor(transaction.source),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: AppTheme.bodyTextStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      transaction.sourceDisplayName,
                      style: AppTheme.captionStyle.copyWith(
                        color: AppTheme.lightGray,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: AppTheme.captionStyle.copyWith(
                        color: AppTheme.lightGray,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      LoyaltyService.formatTimeAgo(transaction.timestamp),
                      style: AppTheme.captionStyle.copyWith(
                        color: AppTheme.lightGray,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${isEarned ? '+' : ''}${transaction.points}',
              style: AppTheme.bodyTextStyle.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
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
            Icons.receipt_long_outlined,
            size: 48,
            color: AppTheme.lightGray,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune transaction',
            style: AppTheme.bodyTextStyle.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vos transactions de points apparaîtront ici',
            style: AppTheme.captionStyle.copyWith(
              color: AppTheme.lightGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getSourceColor(PointSource source) {
    switch (source) {
      case PointSource.purchase:
        return Colors.blue;
      case PointSource.caringAction:
        return Colors.pink;
      case PointSource.partnerInteraction:
        return Colors.purple;
      case PointSource.dailyLogin:
        return Colors.green;
      case PointSource.profileCompletion:
        return Colors.orange;
      case PointSource.referral:
        return Colors.amber;
      case PointSource.cycleTracking:
        return Colors.teal;
      case PointSource.forumActivity:
        return Colors.indigo;
      case PointSource.articleReading:
        return Colors.cyan;
      case PointSource.appointmentBooking:
        return Colors.red;
      case PointSource.reviewWriting:
        return Colors.lime;
      case PointSource.sharingContent:
        return Colors.brown;
    }
  }

  IconData _getSourceIcon(PointSource source) {
    switch (source) {
      case PointSource.purchase:
        return Icons.shopping_cart;
      case PointSource.caringAction:
        return Icons.favorite;
      case PointSource.partnerInteraction:
        return Icons.people;
      case PointSource.dailyLogin:
        return Icons.login;
      case PointSource.profileCompletion:
        return Icons.person;
      case PointSource.referral:
        return Icons.share;
      case PointSource.cycleTracking:
        return Icons.calendar_month;
      case PointSource.forumActivity:
        return Icons.forum;
      case PointSource.articleReading:
        return Icons.article;
      case PointSource.appointmentBooking:
        return Icons.event;
      case PointSource.reviewWriting:
        return Icons.rate_review;
      case PointSource.sharingContent:
        return Icons.send;
    }
  }
}