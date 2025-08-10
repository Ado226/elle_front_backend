import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../core/models/caring_experience.dart';
import '../../services/caring_service.dart';

class LevelProgressWidget extends StatefulWidget {
  final CaringStats stats;
  final VoidCallback onLevelUp;
  final bool showDetails;

  const LevelProgressWidget({
    Key? key,
    required this.stats,
    required this.onLevelUp,
    this.showDetails = false,
  }) : super(key: key);

  @override
  State<LevelProgressWidget> createState() => _LevelProgressWidgetState();
}

class _LevelProgressWidgetState extends State<LevelProgressWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: CaringService.getLevelProgress(widget.stats.totalPoints),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLevel = CaringService.getCurrentLevelData(widget.stats.totalPoints);
    final nextLevel = CaringService.getNextLevelData(widget.stats.totalPoints);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Color(int.parse('0xFF${currentLevel.color}')).withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(int.parse('0xFF${currentLevel.color}')).withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current level
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(int.parse('0xFF${currentLevel.color}')),
                            Color(int.parse('0xFF${currentLevel.color}')).withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(int.parse('0xFF${currentLevel.color}')).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          currentLevel.badge,
                          style: const TextStyle(fontSize: 30),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Niveau ${currentLevel.level}',
                                style: AppTheme.captionStyle.copyWith(
                                  color: AppTheme.lightGray,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(int.parse('0xFF${currentLevel.color}')).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Actuel',
                                  style: AppTheme.captionStyle.copyWith(
                                    color: Color(int.parse('0xFF${currentLevel.color}')),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentLevel.title,
                            style: AppTheme.subHeaderStyle.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentLevel.description,
                            style: AppTheme.captionStyle.copyWith(
                              color: AppTheme.lightGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPink.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${widget.stats.totalPoints} pts',
                        style: AppTheme.bodyTextStyle.copyWith(
                          color: AppTheme.primaryPink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                if (widget.showDetails) ...[
                  const SizedBox(height: 20),
                  _buildFeaturesList(currentLevel),
                ],

                const SizedBox(height: 20),

                // Progress to next level
                if (nextLevel != null) ...[
                  _buildProgressSection(currentLevel, nextLevel),
                ] else ...[
                  _buildMaxLevelSection(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturesList(CaringLevel level) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fonctionnalités débloquées',
          style: AppTheme.bodyTextStyle.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...level.unlockedFeatures.map((feature) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Color(int.parse('0xFF${level.color}')),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    feature,
                    style: AppTheme.captionStyle.copyWith(
                      color: AppTheme.darkText,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildProgressSection(CaringLevel currentLevel, CaringLevel nextLevel) {
    final pointsNeeded = nextLevel.pointsRequired - widget.stats.totalPoints;
    final totalPointsForLevel = nextLevel.pointsRequired - currentLevel.pointsRequired;
    final currentPointsInLevel = widget.stats.totalPoints - currentLevel.pointsRequired;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Prochain niveau',
              style: AppTheme.bodyTextStyle.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${pointsNeeded} points restants',
              style: AppTheme.captionStyle.copyWith(
                color: AppTheme.lightGray,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Next level preview
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(int.parse('0xFF${nextLevel.color}')).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Color(int.parse('0xFF${nextLevel.color}')).withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(int.parse('0xFF${nextLevel.color}')).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    nextLevel.badge,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Niveau ${nextLevel.level}: ${nextLevel.title}',
                      style: AppTheme.bodyTextStyle.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Color(int.parse('0xFF${nextLevel.color}')),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nextLevel.description,
                      style: AppTheme.captionStyle.copyWith(
                        color: AppTheme.lightGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Progress bar
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${currentPointsInLevel}',
                  style: AppTheme.captionStyle.copyWith(
                    color: AppTheme.lightGray,
                    fontSize: 11,
                  ),
                ),
                Text(
                  '${totalPointsForLevel}',
                  style: AppTheme.captionStyle.copyWith(
                    color: AppTheme.lightGray,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _progressAnimation.value,
                backgroundColor: AppTheme.lightGray.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation(
                  Color(int.parse('0xFF${nextLevel.color}')),
                ),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(_progressAnimation.value * 100).toInt()}% jusqu\'au niveau ${nextLevel.level}',
              style: AppTheme.captionStyle.copyWith(
                color: AppTheme.lightGray,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMaxLevelSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withOpacity(0.1),
            Colors.orange.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.amber.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star,
              color: Colors.amber,
              size: 24,
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
                    fontWeight: FontWeight.w700,
                    color: Colors.amber.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Vous êtes un maître de l\'attention. Continuez à accomplir des actions pour maintenir votre statut légendaire !',
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
}