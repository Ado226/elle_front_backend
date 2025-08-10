import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../model/cycle_day_model.dart';

class DayCellWidget extends StatefulWidget {
  final CycleDay? cycleDay;
  final int dayNumber;
  final bool isCurrentMonth;
  final bool isSelected;
  final VoidCallback? onTap;
  
  const DayCellWidget({
    Key? key,
    this.cycleDay,
    required this.dayNumber,
    this.isCurrentMonth = true,
    this.isSelected = false,
    this.onTap,
  }) : super(key: key);

  @override
  State<DayCellWidget> createState() => _DayCellWidgetState();
}

class _DayCellWidgetState extends State<DayCellWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final cycleType = widget.cycleDay?.type ?? 'normal';
    final isToday = widget.cycleDay?.isToday ?? false;
    final hasReport = widget.cycleDay?.hasReport ?? false;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              onTap: widget.isCurrentMonth ? widget.onTap : null,
              child: Container(
                margin: const EdgeInsets.all(1.0),
                decoration: BoxDecoration(
                  color: widget.isCurrentMonth 
                      ? AppColors.getCycleColor(cycleType)
                      : AppColors.normalColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8.0),
                  border: isToday
                      ? Border.all(
                          color: AppColors.primaryColor,
                          width: 2.0,
                        )
                      : widget.isSelected
                          ? Border.all(
                              color: AppColors.secondaryColor,
                              width: 2.0,
                            )
                          : null,
                  boxShadow: [
                    if (isToday || widget.isSelected)
                      BoxShadow(
                        color: AppColors.shadowColor,
                        blurRadius: 4.0,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Main day content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Day number
                          Text(
                            widget.dayNumber.toString(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                              color: _getTextColor(cycleType),
                            ),
                          ),
                          
                          // Cycle type indicator (small dot)
                          if (widget.isCurrentMonth && cycleType != 'normal')
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: _getIndicatorColor(cycleType),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // Report indicator (heart icon)
                    if (hasReport && widget.isCurrentMonth)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite,
                            size: 8,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      
                    // Today indicator
                    if (isToday)
                      Positioned(
                        bottom: 2,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getTextColor(String cycleType) {
    if (!widget.isCurrentMonth) {
      return AppColors.textSecondary.withOpacity(0.5);
    }
    
    switch (cycleType) {
      case 'period':
        return AppColors.textLight;
      case 'fertile':
        return AppColors.textLight;
      case 'ovulation':
        return AppColors.textPrimary;
      default:
        return AppColors.textPrimary;
    }
  }

  Color _getIndicatorColor(String cycleType) {
    switch (cycleType) {
      case 'period':
        return AppColors.textLight;
      case 'fertile':
        return AppColors.textLight;
      case 'ovulation':
        return AppColors.textPrimary;
      default:
        return AppColors.textSecondary;
    }
  }
}