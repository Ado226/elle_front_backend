import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'model/cycle_day_model.dart';
import 'widgets/day_cell_widget.dart';
import 'widgets/cycle_legend_widget.dart';
import 'widgets/report_modal_widget.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _legendController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _legendAnimation;

  DateTime _currentMonth = DateTime.now();
  List<CycleDay> _cycleDays = [];
  CycleDay? _selectedDay;
  bool _showLegend = false;

  final List<String> _monthNames = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
  ];

  final List<String> _weekDays = [
    'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'
  ];

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _legendController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    _legendAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _legendController,
      curve: Curves.easeInOut,
    ));

    _loadCycleData();
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _legendController.dispose();
    super.dispose();
  }

  void _loadCycleData() {
    setState(() {
      _cycleDays = MockCycleData.getMockDataForMonth(
        _currentMonth.year,
        _currentMonth.month,
      );
    });
  }

  void _changeMonth(int delta) async {
    await _slideController.reverse();
    
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + delta);
      _selectedDay = null;
    });

    _loadCycleData();
    await _slideController.forward();
  }

  void _toggleLegend() {
    setState(() {
      _showLegend = !_showLegend;
    });

    if (_showLegend) {
      _legendController.forward();
    } else {
      _legendController.reverse();
    }
  }

  void _onDayTapped(CycleDay cycleDay) {
    setState(() {
      _selectedDay = cycleDay;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReportModalWidget(
        cycleDay: cycleDay,
        onReportAdded: _onReportAdded,
      ),
    );
  }

  void _onReportAdded(CycleDay updatedDay) {
    setState(() {
      final index = _cycleDays.indexWhere(
        (day) => day.date.day == updatedDay.date.day,
      );
      if (index != -1) {
        _cycleDays[index] = updatedDay;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'Mon Calendrier',
          style: TextStyle(
            color: AppColors.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _toggleLegend,
            icon: Icon(
              _showLegend ? Icons.close : Icons.info_outline,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Month navigation
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceColor,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => _changeMonth(-1),
                      icon: const Icon(
                        Icons.chevron_left,
                        color: AppColors.primaryColor,
                        size: 28,
                      ),
                    ),
                    Text(
                      '${_monthNames[_currentMonth.month - 1]} ${_currentMonth.year}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _changeMonth(1),
                      icon: const Icon(
                        Icons.chevron_right,
                        color: AppColors.primaryColor,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),

              // Calendar
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildCalendar(),
                ),
              ),
            ],
          ),

          // Legend overlay
          if (_showLegend)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleLegend,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),

          if (_showLegend)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).animate(_legendAnimation),
                child: const CycleLegendWidget(),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to today
          setState(() {
            _currentMonth = DateTime.now();
            _selectedDay = null;
          });
          _loadCycleData();
        },
        backgroundColor: AppColors.secondaryColor,
        foregroundColor: AppColors.textPrimary,
        child: const Icon(Icons.today),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // Week days header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: _weekDays.map((day) {
                return Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Calendar grid
          Expanded(
            child: _buildCalendarGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    // Calculate days from previous month to show
    final prevMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    final daysInPrevMonth = DateTime(_currentMonth.year, _currentMonth.month, 0).day;
    final prevMonthDaysToShow = firstDayWeekday - 1;

    // Calculate days from next month to show
    final totalCells = 42; // 6 weeks * 7 days
    final currentMonthCells = daysInMonth;
    final prevMonthCells = prevMonthDaysToShow;
    final nextMonthCells = totalCells - prevMonthCells - currentMonthCells;

    List<Widget> calendarCells = [];

    // Previous month days
    for (int i = prevMonthDaysToShow; i > 0; i--) {
      final day = daysInPrevMonth - i + 1;
      calendarCells.add(
        DayCellWidget(
          dayNumber: day,
          isCurrentMonth: false,
          onTap: () {},
        ),
      );
    }

    // Current month days
    for (int day = 1; day <= daysInMonth; day++) {
      final cycleDay = _cycleDays.firstWhere(
        (cd) => cd.date.day == day,
        orElse: () => CycleDay(
          date: DateTime(_currentMonth.year, _currentMonth.month, day),
          type: 'normal',
        ),
      );

      calendarCells.add(
        DayCellWidget(
          cycleDay: cycleDay,
          dayNumber: day,
          isCurrentMonth: true,
          isSelected: _selectedDay?.date.day == day,
          onTap: () => _onDayTapped(cycleDay),
        ),
      );
    }

    // Next month days
    for (int day = 1; day <= nextMonthCells; day++) {
      calendarCells.add(
        DayCellWidget(
          dayNumber: day,
          isCurrentMonth: false,
          onTap: () {},
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
      ),
      itemCount: calendarCells.length,
      itemBuilder: (context, index) => calendarCells[index],
    );
  }
}