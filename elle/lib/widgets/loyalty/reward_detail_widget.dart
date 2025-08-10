import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../core/models/loyalty.dart';
import '../../services/loyalty_service.dart';

class RewardDetailWidget extends StatefulWidget {
  final Reward reward;
  final int availablePoints;
  final ScrollController scrollController;
  final VoidCallback onClaimed;

  const RewardDetailWidget({
    Key? key,
    required this.reward,
    required this.availablePoints,
    required this.scrollController,
    required this.onClaimed,
  }) : super(key: key);

  @override
  State<RewardDetailWidget> createState() => _RewardDetailWidgetState();
}

class _RewardDetailWidgetState extends State<RewardDetailWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _shimmerController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shimmerAnimation;

  bool _isClaiming = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
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

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slideController.forward();
      _fadeController.forward();
      _shimmerController.repeat();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canAfford = widget.availablePoints >= widget.reward.pointsCost;
    final isAvailable = widget.reward.isAvailable && !widget.reward.isExpired && !widget.reward.isOutOfStock;

    return AnimatedBuilder(
      animation: Listenable.merge([_slideController, _fadeController]),
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildContent(canAfford, isAvailable),
          ),
        );
      },
    );
  }

  Widget _buildContent(bool canAfford, bool isAvailable) {
    return Container(
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

          // Header
          _buildHeader(),

          // Content
          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    widget.reward.description,
                    style: AppTheme.bodyTextStyle.copyWith(
                      height: 1.5,
                      color: AppTheme.lightGray.withOpacity(0.9),
                    ),
                  ),

                  if (widget.reward.detailedDescription != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      widget.reward.detailedDescription!,
                      style: AppTheme.bodyTextStyle.copyWith(
                        height: 1.5,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Info cards
                  _buildInfoSection(),

                  const SizedBox(height: 24),

                  // Partner info
                  if (widget.reward.partnerName != null) ...[
                    _buildPartnerSection(),
                    const SizedBox(height: 24),
                  ],

                  // Terms and conditions
                  if (widget.reward.terms.isNotEmpty) ...[
                    _buildTermsSection(),
                    const SizedBox(height: 24),
                  ],

                  // Claim section
                  _buildClaimSection(canAfford, isAvailable),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getCategoryColor(),
                  _getCategoryColor().withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    _getCategoryIcon(),
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                if (widget.reward.isFeatured || widget.reward.isExclusive)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.reward.isFeatured ? Icons.star : Icons.diamond,
                        color: widget.reward.isFeatured ? Colors.amber : Colors.purple,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.reward.categoryDisplayName,
                        style: AppTheme.captionStyle.copyWith(
                          color: _getCategoryColor(),
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPink.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.stars,
                            size: 10,
                            color: AppTheme.primaryPink,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${widget.reward.pointsCost}',
                            style: AppTheme.captionStyle.copyWith(
                              color: AppTheme.primaryPink,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.reward.title,
                  style: AppTheme.headerStyle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.reward.typeDisplayName,
                  style: AppTheme.captionStyle.copyWith(
                    color: AppTheme.lightGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations',
          style: AppTheme.subHeaderStyle.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                icon: Icons.stars,
                label: 'Points requis',
                value: '${widget.reward.pointsCost}',
                color: AppTheme.primaryPink,
              ),
            ),
            const SizedBox(width: 12),
            if (widget.reward.discountPercentage != null)
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.percent,
                  label: 'Réduction',
                  value: '${widget.reward.discountPercentage!.toInt()}%',
                  color: Colors.green,
                ),
              )
            else if (widget.reward.discountAmount != null)
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.monetization_on,
                  label: 'Valeur',
                  value: '${widget.reward.discountAmount} XOF',
                  color: Colors.green,
                ),
              )
            else
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.category,
                  label: 'Type',
                  value: widget.reward.typeDisplayName,
                  color: _getTypeColor(),
                ),
              ),
          ],
        ),
        if (widget.reward.hasExpiry || widget.reward.hasQuantityLimit) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              if (widget.reward.hasExpiry)
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.schedule,
                    label: 'Expire le',
                    value: _formatDate(widget.reward.expiryDate!),
                    color: Colors.orange,
                  ),
                ),
              if (widget.reward.hasExpiry && widget.reward.hasQuantityLimit)
                const SizedBox(width: 12),
              if (widget.reward.hasQuantityLimit)
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.inventory,
                    label: 'Disponible',
                    value: '${widget.reward.quantityAvailable}',
                    color: Colors.blue,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTheme.captionStyle.copyWith(
              color: AppTheme.lightGray,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTheme.bodyTextStyle.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Partenaire',
          style: AppTheme.subHeaderStyle.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.business,
                  color: AppTheme.primaryPink,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.reward.partnerName!,
                      style: AppTheme.bodyTextStyle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Partenaire officiel Elle',
                      style: AppTheme.captionStyle.copyWith(
                        color: AppTheme.lightGray,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.verified,
                color: Colors.green,
                size: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTermsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conditions d\'utilisation',
          style: AppTheme.subHeaderStyle.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightGray.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.reward.terms.map((term) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: AppTheme.primaryPink,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        term,
                        style: AppTheme.captionStyle.copyWith(
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildClaimSection(bool canAfford, bool isAvailable) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryPink.withOpacity(0.1),
            AppTheme.primaryPink.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryPink.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.card_giftcard,
                color: AppTheme.primaryPink,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Réclamation de récompense',
                  style: AppTheme.subHeaderStyle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Points info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Points disponibles:',
                style: AppTheme.bodyTextStyle.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${widget.availablePoints}',
                style: AppTheme.bodyTextStyle.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryPink,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Coût de cette récompense:',
                style: AppTheme.bodyTextStyle.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${widget.reward.pointsCost}',
                style: AppTheme.bodyTextStyle.copyWith(
                  fontWeight: FontWeight.w700,
                  color: canAfford ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            height: 1,
            color: AppTheme.lightGray.withOpacity(0.3),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Solde après réclamation:',
                style: AppTheme.bodyTextStyle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${widget.availablePoints - widget.reward.pointsCost}',
                style: AppTheme.bodyTextStyle.copyWith(
                  fontWeight: FontWeight.w700,
                  color: canAfford ? AppTheme.primaryPink : Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Claim button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (canAfford && isAvailable && !_isClaiming) 
                  ? _claimReward 
                  : null,
              style: AppTheme.primaryButtonStyle.copyWith(
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(vertical: 16),
                ),
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.disabled)) {
                    return AppTheme.lightGray.withOpacity(0.3);
                  }
                  return AppTheme.primaryPink;
                }),
              ),
              child: _isClaiming
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getClaimIcon(canAfford, isAvailable),
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getClaimButtonText(canAfford, isAvailable),
                          style: AppTheme.bodyTextStyle.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          if (!canAfford && isAvailable) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Il vous manque ${widget.reward.pointsCost - widget.availablePoints} points pour cette récompense',
                      style: AppTheme.captionStyle.copyWith(
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getClaimIcon(bool canAfford, bool isAvailable) {
    if (!isAvailable) return Icons.error;
    if (!canAfford) return Icons.lock;
    return Icons.card_giftcard;
  }

  String _getClaimButtonText(bool canAfford, bool isAvailable) {
    if (!isAvailable) return 'Indisponible';
    if (!canAfford) return 'Points insuffisants';
    return 'Réclamer cette récompense';
  }

  Future<void> _claimReward() async {
    setState(() => _isClaiming = true);

    try {
      final claimedReward = await LoyaltyService.claimReward(widget.reward);

      if (claimedReward != null) {
        widget.onClaimed();
        
        if (mounted) {
          // Show success with promo code if applicable
          _showClaimSuccess(claimedReward);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Impossible de réclamer cette récompense'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erreur lors de la réclamation'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      setState(() => _isClaiming = false);
    }
  }

  void _showClaimSuccess(ClaimedReward claimedReward) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Récompense réclamée !',
              style: AppTheme.headerStyle.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Votre récompense "${claimedReward.rewardTitle}" a été ajoutée à vos gains.',
              style: AppTheme.bodyTextStyle,
              textAlign: TextAlign.center,
            ),
            if (claimedReward.promoCode != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Code promo:',
                      style: AppTheme.captionStyle.copyWith(
                        color: AppTheme.lightGray,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          claimedReward.promoCode!,
                          style: AppTheme.headerStyle.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryPink,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: claimedReward.promoCode!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Code copié !'),
                                backgroundColor: AppTheme.primaryPink,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.copy,
                            color: AppTheme.primaryPink,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Fermer',
              style: AppTheme.bodyTextStyle.copyWith(color: AppTheme.primaryPink),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor() {
    switch (widget.reward.category) {
      case RewardCategory.health:
        return Colors.green;
      case RewardCategory.beauty:
        return Colors.pink;
      case RewardCategory.wellness:
        return Colors.purple;
      case RewardCategory.shopping:
        return Colors.blue;
      case RewardCategory.experiences:
        return Colors.orange;
      case RewardCategory.digital:
        return Colors.teal;
      case RewardCategory.charity:
        return Colors.amber;
    }
  }

  IconData _getCategoryIcon() {
    switch (widget.reward.category) {
      case RewardCategory.health:
        return Icons.health_and_safety;
      case RewardCategory.beauty:
        return Icons.face_retouching_natural;
      case RewardCategory.wellness:
        return Icons.spa;
      case RewardCategory.shopping:
        return Icons.shopping_bag;
      case RewardCategory.experiences:
        return Icons.explore;
      case RewardCategory.digital:
        return Icons.computer;
      case RewardCategory.charity:
        return Icons.favorite;
    }
  }

  Color _getTypeColor() {
    switch (widget.reward.type) {
      case RewardType.discount:
        return Colors.green;
      case RewardType.freeProduct:
        return Colors.blue;
      case RewardType.cashback:
        return Colors.purple;
      case RewardType.experience:
        return Colors.orange;
      case RewardType.digitalContent:
        return Colors.teal;
      case RewardType.donation:
        return Colors.amber;
      case RewardType.exclusive:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}