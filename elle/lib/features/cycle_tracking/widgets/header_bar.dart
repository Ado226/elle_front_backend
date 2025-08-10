import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/menstrual_cycle.dart';
import '../../../core/theme/african_theme.dart';

class HeaderBar extends StatefulWidget {
  final DateTime currentMonth;
  final MenstrualCycle cycle;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onTodayTap;

  const HeaderBar({
    Key? key,
    required this.currentMonth,
    required this.cycle,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onTodayTap,
  }) : super(key: key);

  @override
  State<HeaderBar> createState() => _HeaderBarState();
}

class _HeaderBarState extends State<HeaderBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onMonthChange() {
    _animationController.reset();
    _animationController.forward();
  }

  @override
  void didUpdateWidget(HeaderBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentMonth != widget.currentMonth) {
      _onMonthChange();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AfricanColors.primaryColor,
            AfricanColors.copperAccent,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AfricanColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            children: [
              // Month navigation
              _buildMonthNavigation(),
              
              const SizedBox(height: 20),
              
              // Cycle status card
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: _buildCycleStatusCard(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthNavigation() {
    final monthName = DateFormat('MMMM yyyy', 'fr_FR').format(widget.currentMonth);
    final isCurrentMonth = widget.currentMonth.year == DateTime.now().year &&
                          widget.currentMonth.month == DateTime.now().month;

    return Row(
      children: [
        // Previous month button
        _buildNavButton(
          icon: Icons.chevron_left,
          onPressed: widget.onPreviousMonth,
        ),
        
        const SizedBox(width: 16),
        
        // Month and year
        Expanded(
          child: GestureDetector(
            onTap: widget.onTodayTap,
            child: Column(
              children: [
                Text(
                  monthName.substring(0, 1).toUpperCase() + monthName.substring(1),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AfricanColors.textLight,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (isCurrentMonth)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AfricanColors.goldAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AfricanColors.goldAccent.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Ce mois',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AfricanColors.goldAccent,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Next month button
        _buildNavButton(
          icon: Icons.chevron_right,
          onPressed: widget.onNextMonth,
        ),
      ],
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AfricanColors.textLight.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AfricanColors.textLight.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: AfricanColors.textLight,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildCycleStatusCard() {
    final currentPhase = widget.cycle.getCurrentPhaseDescription();
    final daysUntilPeriod = widget.cycle.getDaysUntilNextPeriod();
    final currentType = widget.cycle.getCycleDayType(DateTime.now());
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AfricanColors.textLight.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Status icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getPhaseColor(currentType).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getPhaseIcon(currentType),
              color: _getPhaseColor(currentType),
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Status text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentPhase,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AfricanColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getSecondaryMessage(currentType, daysUntilPeriod),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AfricanColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Emoji indicator
          Text(
            _getPhaseEmoji(currentType),
            style: const TextStyle(fontSize: 24),
          ),
        ],
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

  String _getSecondaryMessage(CycleDayType type, int daysUntilPeriod) {
    switch (type) {
      case CycleDayType.menstruation:
        return 'Prenez soin de vous pendant cette période';
      case CycleDayType.fertile:
        return 'Fenêtre de fertilité élevée';
      case CycleDayType.ovulation:
        return 'Pic de fertilité aujourd\'hui';
      case CycleDayType.safe:
        if (daysUntilPeriod <= 3) {
          return 'Prochaines règles dans $daysUntilPeriod jour${daysUntilPeriod == 1 ? '' : 's'}';
        }
        return 'Faible probabilité de fertilité';
    }
  }
}