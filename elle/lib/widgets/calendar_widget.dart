import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({Key? key}) : super(key: key);

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime _currentMonth;
  late DateTime _today;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _currentMonth = DateTime(_today.year, _today.month);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightPinkBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Days of week header (M T W T F S S)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
                return Container(
                  width: 32,
                  height: 24,
                  alignment: Alignment.center,
                  child: Text(
                    day,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.mediumGray,
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 8),
            
            // Calendar grid
            _buildCalendarGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstWeekdayOfMonth = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    List<Widget> dayWidgets = [];

    // Add empty containers for days before the first day of the month
    for (int i = 1; i < firstWeekdayOfMonth; i++) {
      dayWidgets.add(Container(
        width: 40,
        height: 40,
      ));
    }

    // Add day containers for each day of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final dayDate = DateTime(_currentMonth.year, _currentMonth.month, day);
      final isSelected = day == 15; // Mockup shows date 15 selected
      
      dayWidgets.add(_buildDayCell(day, isSelected));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: dayWidgets,
    );
  }

  Widget _buildDayCell(int day, bool isSelected) {
    return GestureDetector(
      onTap: () {
        // Handle day tap with animation
        setState(() {
          // Update selected date logic here
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.selectedDate : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            day.toString(),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppTheme.white : const Color(0xFF333333),
            ),
          ),
        ),
      ),
    );
  }
}