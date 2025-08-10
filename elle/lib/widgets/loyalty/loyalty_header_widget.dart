import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../core/models/loyalty.dart';
import '../../services/loyalty_service.dart';

class LoyaltyHeaderWidget extends StatefulWidget {
  final LoyaltyPoints loyaltyPoints;
  final LoyaltyTier currentTier;
  final VoidCallback onTierTapped;

  const LoyaltyHeaderWidget({
    Key? key,
    required this.loyaltyPoints,
    required this.currentTier,
    required this.onTierTapped,
  }) : super(key: key);

  @override
  State<LoyaltyHeaderWidget> createState() => _LoyaltyHeaderWidgetState();
}

class _LoyaltyHeaderWidgetState extends State<LoyaltyHeaderWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late AnimationController _countController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<int> _countAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _countController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    _countAnimation = Tween<int>(
      begin: 0,
      end: widget.loyaltyPoints.availablePoints,
    ).animate(CurvedAnimation(
      parent: _countController,
      curve: Curves.easeOutCubic,
    ));

    _pulseController.repeat(reverse: true);
    _shimmerController.repeat();
    _countController.forward();
  }

  @override
  void didUpdateWidget(LoyaltyHeaderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.loyaltyPoints.availablePoints != widget.loyaltyPoints.availablePoints) {
      _countAnimation = Tween<int>(
        begin: oldWidget.loyaltyPoints.availablePoints,
        end: widget.loyaltyPoints.availablePoints,
      ).animate(CurvedAnimation(
        parent: _countController,
        curve: Curves.easeOutCubic,
      ));
      _countController.reset();
      _countController.forward();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    _countController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nextTier = LoyaltyService.getNextTier(widget.loyaltyPoints.lifetimePoints);
    final tierProgress = LoyaltyService.getTierProgress(widget.loyaltyPoints.lifetimePoints);

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _shimmerController, _countController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(int.parse('0xFF${widget.currentTier.color}')),
                  Color(int.parse('0xFF${widget.currentTier.color}')).withOpacity(0.8),
                  AppTheme.primaryPink.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Color(int.parse('0xFF${widget.currentTier.color}')).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Shimmer effect
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CustomPaint(
                      painter: ShimmerPainter(_shimmerAnimation.value),
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                widget.currentTier.icon,
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mes points fidélité',
                                  style: AppTheme.bodyTextStyle.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_countAnimation.value}',
                                  style: AppTheme.headerStyle.copyWith(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: widget.onTierTapped,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.currentTier.name,
                                    style: AppTheme.bodyTextStyle.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Stats row
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              icon: Icons.trending_up,
                              label: 'Gagnés',
                              value: '${widget.loyaltyPoints.lifetimePoints}',
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          Expanded(
                            child: _buildStatItem(
                              icon: Icons.workspace_premium,
                              label: 'Niveau',
                              value: widget.currentTier.name,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          Expanded(
                            child: _buildStatItem(
                              icon: Icons.local_fire_department,
                              label: 'Bonus',
                              value: 'x${widget.currentTier.multiplier}',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Progress to next tier
                      if (nextTier != null) ...[
                        _buildTierProgress(nextTier, tierProgress),
                      ] else ...[
                        _buildMaxTierReached(),
                      ],
                    ],
                  ),
                ),

                // Floating elements
                Positioned(
                  top: 20,
                  right: 20,
                  child: Transform.rotate(
                    angle: _shimmerAnimation.value * 0.3,
                    child: Icon(
                      Icons.stars,
                      color: Colors.white.withOpacity(0.2),
                      size: 24,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 30,
                  child: Transform.rotate(
                    angle: -_shimmerAnimation.value * 0.2,
                    child: Icon(
                      Icons.diamond,
                      color: Colors.white.withOpacity(0.15),
                      size: 20,
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
        ),
      ],
    );
  }

  Widget _buildTierProgress(LoyaltyTier nextTier, double progress) {
    final pointsNeeded = nextTier.pointsRequired - widget.loyaltyPoints.lifetimePoints;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progression vers ${nextTier.name}',
                style: AppTheme.bodyTextStyle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${pointsNeeded} pts restants',
                style: AppTheme.captionStyle.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation(Colors.white),
              minHeight: 8,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              Text(
                nextTier.icon,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  nextTier.description,
                  style: AppTheme.captionStyle.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMaxTierReached() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Niveau maximum atteint !',
                  style: AppTheme.bodyTextStyle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Vous êtes une membre VIP de la famille Elle',
                  style: AppTheme.captionStyle.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerPainter extends CustomPainter {
  final double progress;

  ShimmerPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          Colors.white.withOpacity(0.15),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(
        -size.width + (progress * size.width * 2),
        0,
        size.width,
        size.height,
      ));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}