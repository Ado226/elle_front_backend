import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class WeekCalendarWidget extends StatefulWidget {
  const WeekCalendarWidget({Key? key}) : super(key: key);

  @override
  State<WeekCalendarWidget> createState() => _WeekCalendarWidgetState();
}

class _WeekCalendarWidgetState extends State<WeekCalendarWidget> {
  int selectedDate = 15; // Current selected date
  late DateTime _currentWeekStart;
  late List<int> _weekDates;

  @override
  void initState() {
    super.initState();
    _initializeWeek();
  }

  void _initializeWeek() {
    final now = DateTime.now();
    // Find the start of the current week (Monday)
    final daysFromMonday = now.weekday - 1;
    _currentWeekStart = now.subtract(Duration(days: daysFromMonday));
    
    // Generate week dates
    _weekDates = List.generate(7, (index) {
      final date = _currentWeekStart.add(Duration(days: index));
      return date.day;
    });
  }

  void _onDateSelected(int date) {
    setState(() {
      selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.weekCalendarBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Days header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              DayHeaderWidget(day: "M"),
              DayHeaderWidget(day: "T"),
              DayHeaderWidget(day: "W"),
              DayHeaderWidget(day: "T"),
              DayHeaderWidget(day: "F"),
              DayHeaderWidget(day: "S"),
              DayHeaderWidget(day: "S"),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Current week dates row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _weekDates.map((date) {
              return DateWidget(
                date: date,
                isSelected: date == selectedDate,
                onTap: () => _onDateSelected(date),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class DayHeaderWidget extends StatelessWidget {
  final String day;
  
  const DayHeaderWidget({Key? key, required this.day}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      child: Text(
        day,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.dayHeaderBlue,
        ),
      ),
    );
  }
}

class DateWidget extends StatefulWidget {
  final int date;
  final bool isSelected;
  final VoidCallback onTap;
  
  const DateWidget({
    Key? key,
    required this.date,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  State<DateWidget> createState() => _DateWidgetState();
}

class _DateWidgetState extends State<DateWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32,
              height: 28,
              decoration: BoxDecoration(
                color: widget.isSelected ? AppTheme.selectedDateBackground : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  widget.date.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: widget.isSelected ? AppTheme.selectedDateText : AppTheme.regularDateText,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}