import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../core/models/payment.dart';
import '../../services/payment_service.dart';

class PaymentHistoryWidget extends StatefulWidget {
  final List<PaymentTransaction> transactions;
  final VoidCallback onRefresh;
  final Function(PaymentTransaction) onTransactionTap;

  const PaymentHistoryWidget({
    Key? key,
    required this.transactions,
    required this.onRefresh,
    required this.onTransactionTap,
  }) : super(key: key);

  @override
  State<PaymentHistoryWidget> createState() => _PaymentHistoryWidgetState();
}

class _PaymentHistoryWidgetState extends State<PaymentHistoryWidget>
    with TickerProviderStateMixin {
  late AnimationController _staggerController;
  PaymentStatus? _selectedStatus;
  PaymentProvider? _selectedProvider;

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

  List<PaymentTransaction> get _filteredTransactions {
    var filtered = widget.transactions;
    
    if (_selectedStatus != null) {
      filtered = filtered.where((t) => t.status == _selectedStatus).toList();
    }
    
    if (_selectedProvider != null) {
      filtered = filtered.where((t) => t.provider == _selectedProvider).toList();
    }
    
    return filtered;
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
            // Summary statistics
            _buildStatisticsCard(),

            const SizedBox(height: 24),

            // Filters
            _buildFiltersSection(),

            const SizedBox(height: 24),

            // Transactions list
            _buildSectionHeader(),
            const SizedBox(height: 12),

            if (_filteredTransactions.isEmpty) ...[ 
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

  Widget _buildStatisticsCard() {
    final completedTransactions = widget.transactions.where((t) => t.isCompleted);
    final totalAmount = completedTransactions.fold<double>(0, (sum, t) => sum + t.amount);
    final totalFees = completedTransactions.fold<double>(0, (sum, t) => sum + (t.fees ?? 0));
    final successRate = widget.transactions.isNotEmpty 
        ? (completedTransactions.length / widget.transactions.length * 100).round()
        : 0;

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
                      'Historique des paiements',
                      style: AppTheme.subHeaderStyle.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${widget.transactions.length} transaction(s) au total',
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
                  icon: Icons.monetization_on,
                  label: 'Total payé',
                  value: PaymentService.formatAmount(totalAmount),
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.receipt,
                  label: 'Frais totaux',
                  value: PaymentService.formatAmount(totalFees),
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.trending_up,
                  label: 'Taux succès',
                  value: '$successRate%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
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
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.captionStyle.copyWith(
            color: Colors.white.withOpacity(0.9),
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFiltersSection() {
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
                'Filtrer les transactions',
                style: AppTheme.subHeaderStyle.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (_selectedStatus != null || _selectedProvider != null)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedStatus = null;
                      _selectedProvider = null;
                    });
                  },
                  child: Text(
                    'Réinitialiser',
                    style: AppTheme.captionStyle.copyWith(
                      color: AppTheme.primaryPink,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Status filter
          Text(
            'Par statut',
            style: AppTheme.bodyTextStyle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: PaymentStatus.values.map((status) {
              final isSelected = _selectedStatus == status;
              final count = widget.transactions.where((t) => t.status == status).length;
              
              if (count == 0) return const SizedBox.shrink();
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedStatus = isSelected ? null : status;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? _getStatusColor(status) 
                        : _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getStatusColor(status).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(status),
                        size: 12,
                        color: isSelected ? Colors.white : _getStatusColor(status),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        status.name,
                        style: AppTheme.captionStyle.copyWith(
                          color: isSelected ? Colors.white : _getStatusColor(status),
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '($count)',
                        style: AppTheme.captionStyle.copyWith(
                          color: isSelected ? Colors.white : _getStatusColor(status),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Provider filter
          Text(
            'Par fournisseur',
            style: AppTheme.bodyTextStyle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: PaymentProvider.values.map((provider) {
              final isSelected = _selectedProvider == provider;
              final count = widget.transactions.where((t) => t.provider == provider).length;
              
              if (count == 0) return const SizedBox.shrink();
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedProvider = isSelected ? null : provider;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? _getProviderColor(provider) 
                        : _getProviderColor(provider).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getProviderColor(provider).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getProviderIcon(provider),
                        size: 12,
                        color: isSelected ? Colors.white : _getProviderColor(provider),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getProviderShortName(provider),
                        style: AppTheme.captionStyle.copyWith(
                          color: isSelected ? Colors.white : _getProviderColor(provider),
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '($count)',
                        style: AppTheme.captionStyle.copyWith(
                          color: isSelected ? Colors.white : _getProviderColor(provider),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Icon(
          Icons.history,
          color: AppTheme.primaryPink,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transactions récentes',
                style: AppTheme.subHeaderStyle.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${_filteredTransactions.length} transaction(s) ${_selectedStatus != null || _selectedProvider != null ? 'filtrée(s)' : 'au total'}',
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
          itemCount: _filteredTransactions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final transaction = _filteredTransactions[index];
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
                child: _buildTransactionCard(transaction),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTransactionCard(PaymentTransaction transaction) {
    final statusColor = _getStatusColor(transaction.status);
    final providerColor = _getProviderColor(transaction.provider);

    return GestureDetector(
      onTap: () => widget.onTransactionTap(transaction),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.lightGray.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Provider icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: providerColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getProviderIcon(transaction.provider),
                    color: providerColor,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 12),

                // Transaction details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              transaction.description ?? 'Transaction ${transaction.id}',
                              style: AppTheme.bodyTextStyle.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getStatusIcon(transaction.status),
                                  color: statusColor,
                                  size: 10,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  transaction.statusDisplayName,
                                  style: AppTheme.captionStyle.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          Text(
                            transaction.provider.name,
                            style: AppTheme.captionStyle.copyWith(
                              color: providerColor,
                              fontWeight: FontWeight.w500,
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
                            PaymentService.formatTimeAgo(transaction.createdAt),
                            style: AppTheme.captionStyle.copyWith(
                              color: AppTheme.lightGray,
                            ),
                          ),
                          if (transaction.orderId != null) ...[ 
                            const SizedBox(width: 8),
                            Text(
                              '•',
                              style: AppTheme.captionStyle.copyWith(
                                color: AppTheme.lightGray,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '#${transaction.orderId}',
                              style: AppTheme.captionStyle.copyWith(
                                color: AppTheme.lightGray,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      PaymentService.formatAmount(transaction.amount),
                      style: AppTheme.bodyTextStyle.copyWith(
                        fontWeight: FontWeight.w700,
                        color: transaction.isCompleted ? Colors.green : AppTheme.darkText,
                      ),
                    ),
                    if (transaction.fees != null && transaction.fees! > 0) ...[ 
                      const SizedBox(height: 2),
                      Text(
                        '+${PaymentService.formatAmount(transaction.fees!)} frais',
                        style: AppTheme.captionStyle.copyWith(
                          color: AppTheme.lightGray,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),

            // Additional info for specific statuses
            if (transaction.failureReason != null) ...[ 
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        transaction.failureReason!,
                        style: AppTheme.captionStyle.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (transaction.externalTransactionId != null) ...[ 
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.receipt_long,
                    color: AppTheme.lightGray,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Réf: ${transaction.externalTransactionId}',
                    style: AppTheme.captionStyle.copyWith(
                      color: AppTheme.lightGray,
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String message = 'Aucune transaction trouvée';
    String subtitle = 'Vos transactions apparaîtront ici';
    
    if (_selectedStatus != null || _selectedProvider != null) {
      message = 'Aucune transaction correspondante';
      subtitle = 'Essayez d\'ajuster vos filtres';
    }

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
            Icons.history,
            size: 48,
            color: AppTheme.lightGray,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTheme.bodyTextStyle.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTheme.captionStyle.copyWith(
              color: AppTheme.lightGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.processing:
        return Colors.blue;
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.cancelled:
        return Colors.grey;
      case PaymentStatus.refunded:
        return Colors.purple;
      case PaymentStatus.expired:
        return Colors.red.shade300;
    }
  }

  IconData _getStatusIcon(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Icons.schedule;
      case PaymentStatus.processing:
        return Icons.sync;
      case PaymentStatus.completed:
        return Icons.check_circle;
      case PaymentStatus.failed:
        return Icons.error;
      case PaymentStatus.cancelled:
        return Icons.cancel;
      case PaymentStatus.refunded:
        return Icons.undo;
      case PaymentStatus.expired:
        return Icons.access_time;
    }
  }

  Color _getProviderColor(PaymentProvider provider) {
    switch (provider) {
      case PaymentProvider.orangeMoney:
        return Colors.orange;
      case PaymentProvider.mtnMomo:
        return Colors.yellow.shade700;
      case PaymentProvider.moovMoney:
        return Colors.blue;
      case PaymentProvider.visa:
        return Colors.blue.shade800;
      case PaymentProvider.mastercard:
        return Colors.red;
      case PaymentProvider.wave:
        return Colors.purple;
      case PaymentProvider.freeMoneyWallet:
        return Colors.green;
    }
  }

  IconData _getProviderIcon(PaymentProvider provider) {
    switch (provider) {
      case PaymentProvider.orangeMoney:
        return Icons.phone_android;
      case PaymentProvider.mtnMomo:
        return Icons.phone_android;
      case PaymentProvider.moovMoney:
        return Icons.phone_android;
      case PaymentProvider.visa:
        return Icons.credit_card;
      case PaymentProvider.mastercard:
        return Icons.credit_card;
      case PaymentProvider.wave:
        return Icons.waves;
      case PaymentProvider.freeMoneyWallet:
        return Icons.account_balance_wallet;
    }
  }

  String _getProviderShortName(PaymentProvider provider) {
    switch (provider) {
      case PaymentProvider.orangeMoney:
        return 'Orange';
      case PaymentProvider.mtnMomo:
        return 'MTN';
      case PaymentProvider.moovMoney:
        return 'Moov';
      case PaymentProvider.visa:
        return 'Visa';
      case PaymentProvider.mastercard:
        return 'Mastercard';
      case PaymentProvider.wave:
        return 'Wave';
      case PaymentProvider.freeMoneyWallet:
        return 'Free Money';
    }
  }
}