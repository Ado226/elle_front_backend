import 'package:flutter/material.dart';
import '../../../core/models/menstrual_cycle.dart';
import '../../../core/theme/african_theme.dart';
import 'cycle_day_cell.dart';

class CycleCalendar extends StatefulWidget {
  final MenstrualCycle cycle;
  final Function(CycleDay) onDayTapped;
  final DateTime? selectedDate;

  const CycleCalendar({
    Key? key,
    required this.cycle,
    required this.onDayTapped,
    this.selectedDate,
  }) : super(key: key);

  @override
  State<CycleCalendar> createState() => _CycleCalendarState();
}

class _CycleCalendarState extends State<CycleCalendar>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  
  DateTime _currentMonth = DateTime.now();
  PageController _pageController = PageController(initialPage: 12);

  static const List<String> _monthNames = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
  ];

  static const List<String> _weekDays = [
    'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _changeMonth(int delta) async {
    await _slideController.reverse();
    
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + delta);
    });

    await _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AfricanTheme.cardDecoration,
      child: Column(
        children: [
          // Month header
          _buildMonthHeader(),
          
          // Week days header
          _buildWeekDaysHeader(),
          
          // Calendar grid
          Expanded(
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildCalendarGrid(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AfricanColors.primaryColor,
            AfricanColors.copperAccent,
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _changeMonth(-1),
            icon: const Icon(
              Icons.chevron_left,
              color: AfricanColors.textLight,
              size: 28,
            ),
          ),
          Column(
            children: [
              Text(
                '${_monthNames[_currentMonth.month - 1]} ${_currentMonth.year}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AfricanColors.textLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.cycle.getCurrentPhaseDescription(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AfricanColors.textLight.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          IconButton(
            onPressed: () => _changeMonth(1),
            icon: const Icon(
              Icons.chevron_right,
              color: AfricanColors.textLight,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDaysHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: const BoxDecoration(
        color: AfricanColors.safariSand,
      ),
      child: Row(
        children: _weekDays.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AfricanColors.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    // Calculate previous month days to show
    final prevMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    final daysInPrevMonth = DateTime(_currentMonth.year, _currentMonth.month, 0).day;
    final prevMonthDaysToShow = firstDayWeekday - 1;

    // Calculate next month days to show
    final totalCells = 42; // 6 weeks * 7 days
    final currentMonthCells = daysInMonth;
    final prevMonthCells = prevMonthDaysToShow;
    final nextMonthCells = totalCells - prevMonthCells - currentMonthCells;

    List<Widget> calendarCells = [];

    // Previous month days
    for (int i = prevMonthDaysToShow; i > 0; i--) {
      final day = daysInPrevMonth - i + 1;
      final date = DateTime(prevMonth.year, prevMonth.month, day);
      final cycleDay = widget.cycle.getCycleDay(date);
      
      calendarCells.add(
        CycleDayCell(
          cycleDay: cycleDay,
          isCurrentMonth: false,
          onTap: () => widget.onDayTapped(cycleDay),
        ),
      );
    }

    // Current month days
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final cycleDay = widget.cycle.getCycleDay(date);
      
      calendarCells.add(
        CycleDayCell(
          cycleDay: cycleDay,
          isCurrentMonth: true,
          onTap: () => widget.onDayTapped(cycleDay),
        ),
      );
    }

    // Next month days
    final nextMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    for (int day = 1; day <= nextMonthCells; day++) {
      final date = DateTime(nextMonth.year, nextMonth.month, day);
      final cycleDay = widget.cycle.getCycleDay(date);
      
      calendarCells.add(
        CycleDayCell(
          cycleDay: cycleDay,
          isCurrentMonth: false,
          onTap: () => widget.onDayTapped(cycleDay),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1.0,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: calendarCells.length,
        itemBuilder: (context, index) => calendarCells[index],
      ),
    );
  }
}