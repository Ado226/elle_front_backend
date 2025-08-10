import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/cycle_model.dart';
import '../utils/theme.dart';

class CycleCalendar extends StatefulWidget {
  final CycleCalculations? calculations;
  final Function(DateTime) onDaySelected;
  final DateTime? selectedDay;

  const CycleCalendar({
    Key? key,
    this.calculations,
    required this.onDaySelected,
    this.selectedDay,
  }) : super(key: key);

  @override
  State<CycleCalendar> createState() => _CycleCalendarState();
}

class _CycleCalendarState extends State<CycleCalendar>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getDayType(DateTime day) {
    if (widget.calculations == null) return 'normal';

    final calculations = widget.calculations!;
    
    // Check if day is in menstruation period
    if (calculations.menstruationPeriod.any((date) => isSameDay(date, day))) {
      return 'menstruation';
    }
    
    // Check if day is ovulation day
    if (isSameDay(calculations.ovulationDate, day)) {
      return 'ovulation';
    }
    
    // Check if day is in fertile window
    if (calculations.fertileWindow.any((date) => isSameDay(date, day))) {
      return 'fertile';
    }
    
    // Check if day is safe
    if (calculations.safeDays.any((date) => isSameDay(date, day))) {
      return 'safe';
    }
    
    return 'normal';
  }

  bool _hasIntercourse(DateTime day) {
    if (widget.calculations == null) return false;
    return widget.calculations!.cycleData.intercourseData
        .any((date) => isSameDay(date, day));
  }

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBrown.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: AnimationConfiguration.staggeredList(
          position: 0,
          duration: const Duration(milliseconds: 600),
          child: SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Calendar header
                    _buildCalendarHeader(),
                    const SizedBox(height: 16),
                    
                    // Calendar widget
                    _buildCalendar(),
                    
                    const SizedBox(height: 16),
                    
                    // Legend
                    _buildLegend(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Calendrier Menstruel',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_view_month, color: Colors.white),
            onPressed: () {
              setState(() {
                _calendarFormat = _calendarFormat == CalendarFormat.month
                    ? CalendarFormat.twoWeeks
                    : CalendarFormat.month;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar<String>(
      locale: 'fr_FR',
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) {
        return widget.selectedDay != null && isSameDay(widget.selectedDay!, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
        widget.onDaySelected(selectedDay);
      },
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        selectedDecoration: BoxDecoration(
          color: AppTheme.primaryBrown,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBrown.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        todayDecoration: BoxDecoration(
          color: AppTheme.accentTerracotta,
          shape: BoxShape.circle,
        ),
        defaultDecoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        weekendDecoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          return _buildDayCell(day, false);
        },
        selectedBuilder: (context, day, focusedDay) {
          return _buildDayCell(day, true);
        },
        todayBuilder: (context, day, focusedDay) {
          return _buildDayCell(day, false, isToday: true);
        },
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: const TextStyle(
          color: AppTheme.primaryBrown,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        leftChevronIcon: const Icon(
          Icons.chevron_left,
          color: AppTheme.primaryBrown,
        ),
        rightChevronIcon: const Icon(
          Icons.chevron_right,
          color: AppTheme.primaryBrown,
        ),
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: AppTheme.primaryBrown,
          fontWeight: FontWeight.w600,
        ),
        weekendStyle: TextStyle(
          color: AppTheme.primaryBrown,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDayCell(DateTime day, bool isSelected, {bool isToday = false}) {
    final dayType = _getDayType(day);
    final hasIntercourse = _hasIntercourse(day);
    final dayColor = AppTheme.getDayColor(dayType);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isSelected 
            ? AppTheme.primaryBrown 
            : isToday 
                ? AppTheme.accentTerracotta 
                : dayColor.withOpacity(0.3),
        shape: BoxShape.circle,
        border: dayType != 'normal' && !isSelected
            ? Border.all(color: dayColor, width: 2)
            : null,
        boxShadow: isSelected || isToday
            ? [
                BoxShadow(
                  color: (isSelected ? AppTheme.primaryBrown : AppTheme.accentTerracotta)
                      .withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '${day.day}',
            style: TextStyle(
              color: isSelected || isToday ? Colors.white : AppTheme.primaryBrown,
              fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (hasIntercourse)
            const Positioned(
              top: 2,
              right: 2,
              child: Text(
                '❤️',
                style: TextStyle(fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warmBeige,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Légende',
            style: TextStyle(
              color: AppTheme.primaryBrown,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildLegendItem('Règles', AppTheme.menstruationBrown),
              _buildLegendItem('Fertilité', AppTheme.fertileGreen),
              _buildLegendItem('Ovulation', AppTheme.ovulationGold),
              _buildLegendItem('Jours sûrs', AppTheme.safeDaysBlue),
              _buildLegendItem('Rapport ❤️', Colors.transparent, showHeart: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, {bool showHeart = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showHeart)
          const Text('❤️', style: TextStyle(fontSize: 12))
        else
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primaryBrown, width: 1),
            ),
          ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.primaryBrown,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}