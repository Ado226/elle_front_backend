import 'package:flutter/material.dart';
import '../../../core/models/menstrual_cycle.dart';
import '../../../core/theme/african_theme.dart';

class DayCell extends StatefulWidget {
  final CycleDay? cycleDay;
  final int dayNumber;
  final bool isCurrentMonth;
  final bool isSelected;
  final VoidCallback? onTap;

  const DayCell({
    Key? key,
    this.cycleDay,
    required this.dayNumber,
    this.isCurrentMonth = true,
    this.isSelected = false,
    this.onTap,
  }) : super(key: key);

  @override
  State<DayCell> createState() => _DayCellState();
}

class _DayCellState extends State<DayCell>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _heartAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.92,
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

    _heartAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.isCurrentMonth && widget.onTap != null) {
      setState(() {
        _isPressed = true;
      });
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
      widget.onTap?.call();
    }
  }

  void _handleTapCancel() {
    if (_isPressed) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isToday = widget.cycleDay?.isToday ?? false;
    final hasIntercourse = widget.cycleDay?.hasIntercourse ?? false;
    final cycleType = widget.cycleDay?.type ?? CycleDayType.safe;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: _buildCellDecoration(cycleType, isToday),
              child: Stack(
                children: [
                  // Main content
                  _buildMainContent(cycleType, isToday),
                  
                  // Intercourse indicator
                  if (hasIntercourse && widget.isCurrentMonth)
                    _buildIntercourseIndicator(),
                  
                  // Today indicator
                  if (isToday && widget.isCurrentMonth)
                    _buildTodayIndicator(),
                  
                  // Selection glow
                  if (widget.isSelected)
                    _buildSelectionGlow(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  BoxDecoration _buildCellDecoration(CycleDayType cycleType, bool isToday) {
    Color backgroundColor;
    
    if (!widget.isCurrentMonth) {
      backgroundColor = AfricanColors.backgroundColor.withOpacity(0.3);
    } else {
      switch (cycleType) {
        case CycleDayType.menstruation:
          backgroundColor = AfricanColors.menstruationColor;
          break;
        case CycleDayType.fertile:
          backgroundColor = AfricanColors.fertileColor;
          break;
        case CycleDayType.ovulation:
          backgroundColor = AfricanColors.ovulationColor;
          break;
        case CycleDayType.safe:
          backgroundColor = AfricanColors.safeColor;
          break;
      }
    }

    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(14),
      border: isToday
          ? Border.all(
              color: AfricanColors.primaryColor,
              width: 2.5,
            )
          : widget.isSelected
              ? Border.all(
                  color: AfricanColors.goldAccent,
                  width: 2,
                )
              : null,
      boxShadow: [
        // Base shadow
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
        // Glow effect when pressed or selected
        if (_isPressed || widget.isSelected || isToday)
          BoxShadow(
            color: _getGlowColor(cycleType, isToday).withOpacity(
              0.4 * _glowAnimation.value,
            ),
            blurRadius: 12 + (8 * _glowAnimation.value),
            offset: const Offset(0, 4),
          ),
      ],
    );
  }

  Widget _buildMainContent(CycleDayType cycleType, bool isToday) {
    return Positioned.fill(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Day number
            Text(
              widget.dayNumber.toString(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: _getTextColor(cycleType),
                fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                fontSize: isToday ? 18 : 16,
                letterSpacing: 0.5,
              ),
            ),
            
            // Phase indicator dot
            if (widget.isCurrentMonth && cycleType != CycleDayType.safe)
              Container(
                margin: const EdgeInsets.only(top: 3),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: _getIndicatorColor(cycleType),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _getIndicatorColor(cycleType).withOpacity(0.5),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntercourseIndicator() {
    return Positioned(
      top: 4,
      right: 4,
      child: Transform.scale(
        scale: _heartAnimation.value,
        child: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFF6B6B),
                Color(0xFFE53E3E),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
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
    );
  }

  Widget _buildTodayIndicator() {
    return Positioned(
      bottom: 4,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AfricanColors.primaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AfricanColors.primaryColor.withOpacity(0.5),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionGlow() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AfricanColors.goldAccent.withOpacity(
              0.6 * _glowAnimation.value,
            ),
            width: 2 + (2 * _glowAnimation.value),
          ),
        ),
      ),
    );
  }

  Color _getTextColor(CycleDayType cycleType) {
    if (!widget.isCurrentMonth) {
      return AfricanColors.textSecondary.withOpacity(0.4);
    }

    switch (cycleType) {
      case CycleDayType.menstruation:
      case CycleDayType.fertile:
        return AfricanColors.textLight;
      case CycleDayType.ovulation:
      case CycleDayType.safe:
        return AfricanColors.textPrimary;
    }
  }

  Color _getIndicatorColor(CycleDayType cycleType) {
    switch (cycleType) {
      case CycleDayType.menstruation:
      case CycleDayType.fertile:
        return AfricanColors.textLight;
      case CycleDayType.ovulation:
      case CycleDayType.safe:
        return AfricanColors.textPrimary;
    }
  }

  Color _getGlowColor(CycleDayType cycleType, bool isToday) {
    if (isToday) {
      return AfricanColors.primaryColor;
    }

    switch (cycleType) {
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
}