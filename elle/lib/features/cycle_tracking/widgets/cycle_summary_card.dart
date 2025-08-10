import 'package:flutter/material.dart';
import '../../../core/models/menstrual_cycle.dart';
import '../../../core/theme/african_theme.dart';

class CycleSummaryCard extends StatefulWidget {
  final MenstrualCycle cycle;

  const CycleSummaryCard({
    Key? key,
    required this.cycle,
  }) : super(key: key);

  @override
  State<CycleSummaryCard> createState() => _CycleSummaryCardState();
}

class _CycleSummaryCardState extends State<CycleSummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AfricanColors.ivoryWhite,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Header
                    _buildHeader(),
                    
                    const SizedBox(height: 20),
                    
                    // Stats grid
                    _buildStatsGrid(),
                    
                    const SizedBox(height: 16),
                    
                    // Progress indicators
                    _buildProgressIndicators(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final currentType = widget.cycle.getCycleDayType(DateTime.now());
    final currentDay = widget.cycle.getCurrentCycleDay();

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getPhaseColor(currentType),
                _getPhaseColor(currentType).withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: _getPhaseColor(currentType).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            _getPhaseIcon(currentType),
            color: AfricanColors.textLight,
            size: 24,
          ),
        ),
        
        const SizedBox(width: 16),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Jour $currentDay de votre cycle',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AfricanColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.cycle.getCurrentPhaseDescription(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AfricanColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        
        Text(
          _getPhaseEmoji(currentType),
          style: const TextStyle(fontSize: 28),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    final daysUntilPeriod = widget.cycle.getDaysUntilNextPeriod();
    final cycleProgress = (widget.cycle.getCurrentCycleDay() / widget.cycle.cycleLength);

    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            'Cycle actuel',
            '${widget.cycle.getCurrentCycleDay()}/${widget.cycle.cycleLength} jours',
            Icons.refresh,
            AfricanColors.primaryColor,
            cycleProgress,
          ),
        ),
        
        const SizedBox(width: 16),
        
        Expanded(
          child: _buildStatItem(
            'Prochaines règles',
            '$daysUntilPeriod jour${daysUntilPeriod == 1 ? '' : 's'}',
            Icons.schedule,
            AfricanColors.warningOrange,
            daysUntilPeriod <= 7 ? (7 - daysUntilPeriod) / 7 : 0,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
    double progress,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AfricanColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Progress bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicators() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aperçu du cycle',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AfricanColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: 12),
        
        _buildCycleProgressBar(),
      ],
    );
  }

  Widget _buildCycleProgressBar() {
    final currentDay = widget.cycle.getCurrentCycleDay();
    final cycleLength = widget.cycle.cycleLength;
    final menstruationEnd = widget.cycle.menstruationDuration;
    final ovulationDay = cycleLength - 14;
    final fertileStart = ovulationDay - 4;
    final fertileEnd = ovulationDay + 1;

    return Container(
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: AfricanColors.backgroundColor,
      ),
      child: Stack(
        children: [
          // Menstruation phase
          if (menstruationEnd > 0)
            _buildPhaseSegment(
              start: 0,
              end: menstruationEnd / cycleLength,
              color: AfricanColors.menstruationColor,
            ),
          
          // Fertile phase
          if (fertileStart > 0 && fertileEnd <= cycleLength)
            _buildPhaseSegment(
              start: (fertileStart - 1) / cycleLength,
              end: fertileEnd / cycleLength,
              color: AfricanColors.fertileColor,
            ),
          
          // Ovulation day
          if (ovulationDay > 0 && ovulationDay <= cycleLength)
            _buildPhaseSegment(
              start: (ovulationDay - 1) / cycleLength,
              end: ovulationDay / cycleLength,
              color: AfricanColors.ovulationColor,
            ),
          
          // Current day indicator
          Positioned(
            left: (currentDay - 1) / cycleLength * MediaQuery.of(context).size.width * 0.7,
            child: Container(
              width: 12,
              height: 12,
              transform: Matrix4.translationValues(-6, -2, 0),
              decoration: BoxDecoration(
                color: AfricanColors.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AfricanColors.ivoryWhite,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AfricanColors.primaryColor.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseSegment({
    required double start,
    required double end,
    required Color color,
  }) {
    return Positioned.fill(
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: end - start,
        child: Container(
          margin: EdgeInsets.only(
            left: start * MediaQuery.of(context).size.width * 0.7,
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  IconData _getPhaseIcon(CycleDayType type) {
    switch (type) {
      case CycleDayType.menstruation:
        return Icons.water_drop;
      case CycleDayType.fertile:
        return Icons.eco;
      case CycleDayType.ovulation:
        return Icons.star;
      case CycleDayType.safe:
        return Icons.shield;
    }
  }

  Color _getPhaseColor(CycleDayType type) {
    switch (type) {
      case CycleDayType.menstruation:
        return AfricanColors.menstruationColor;
      case CycleDayType.fertile:
        return AfricanColors.fertileColor;
      case CycleDayType.ovulation:
        return AfricanColors.ovulationColor;
      case CycleDayType.safe:
        return AfricanColors.safeColor;
    }
  }

  String _getPhaseEmoji(CycleDayType type) {
    switch (type) {
      case CycleDayType.menstruation:
        return '🩸';
      case CycleDayType.fertile:
        return '🌿';
      case CycleDayType.ovulation:
        return '🌟';
      case CycleDayType.safe:
        return '💙';
    }
  }
}