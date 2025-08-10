import 'package:flutter/material.dart';
import '../../../core/models/menstrual_cycle.dart';
import '../../../core/theme/african_theme.dart';

class CycleDayCell extends StatefulWidget {
  final CycleDay cycleDay;
  final VoidCallback? onTap;
  final bool isCurrentMonth;
  final bool showIntercourseIcon;

  const CycleDayCell({
    Key? key,
    required this.cycleDay,
    this.onTap,
    this.isCurrentMonth = true,
    this.showIntercourseIcon = true,
  }) : super(key: key);

  @override
  State<CycleDayCell> createState() => _CycleDayCellState();
}

class _CycleDayCellState extends State<CycleDayCell>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
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

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isToday = widget.cycleDay.isToday;
    final dayNumber = widget.cycleDay.date.day;
    final hasIntercourse = widget.cycleDay.hasIntercourse;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: widget.isCurrentMonth ? _onTapDown : null,
            onTapUp: widget.isCurrentMonth ? _onTapUp : null,
            onTapCancel: widget.isCurrentMonth ? _onTapCancel : null,
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: widget.isCurrentMonth
                    ? widget.cycleDay.backgroundColor
                    : widget.cycleDay.backgroundColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: isToday
                    ? Border.all(
                        color: AfricanColors.primaryColor,
                        width: 3,
                      )
                    : null,
                boxShadow: [
                  if (isToday || _glowAnimation.value > 0)
                    BoxShadow(
                      color: isToday
                          ? AfricanColors.primaryColor.withOpacity(0.4)
                          : widget.cycleDay.backgroundColor.withOpacity(0.6 * _glowAnimation.value),
                      blurRadius: 8 + (4 * _glowAnimation.value),
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Stack(
                children: [
                  // Main content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Day number
                        Text(
                          dayNumber.toString(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: _getTextColor(),
                            fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        
                        // Type indicator dot
                        if (widget.isCurrentMonth)
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            child: Text(
                              widget.cycleDay.typeEmoji,
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Intercourse indicator (heart)
                  if (hasIntercourse && widget.showIntercourseIcon && widget.isCurrentMonth)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.shade400.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                    ),
                  
                  // Today indicator
                  if (isToday)
                    Positioned(
                      bottom: 4,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AfricanColors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  
                  // Pulse animation for today
                  if (isToday)
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AfricanColors.primaryColor.withOpacity(
                                  0.3 * (1 - _glowAnimation.value),
                                ),
                                width: 2 + (2 * _glowAnimation.value),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getTextColor() {
    if (!widget.isCurrentMonth) {
      return AfricanColors.textSecondary.withOpacity(0.5);
    }

    // Return contrasting color based on background
    switch (widget.cycleDay.type) {
      case CycleDayType.menstruation:
      case CycleDayType.fertile:
        return AfricanColors.textLight;
      case CycleDayType.ovulation:
      case CycleDayType.safe:
        return AfricanColors.textPrimary;
    }
  }
}