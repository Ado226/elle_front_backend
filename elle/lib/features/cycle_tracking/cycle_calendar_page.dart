import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/models/menstrual_cycle.dart';
import 'create_cycle_page.dart';

/// PAGE 2 - "My Calendar View"
/// Displays the full calendar view with cycle phases and animations
class CycleCalendarPage extends StatefulWidget {
  final MenstrualCycle cycle;

  const CycleCalendarPage({
    Key? key,
    required this.cycle,
  }) : super(key: key);

  @override
  State<CycleCalendarPage> createState() => _CycleCalendarPageState();
}

class _CycleCalendarPageState extends State<CycleCalendarPage>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _pageController;
  late AnimationController _headerController;
  late AnimationController _calendarController;
  late AnimationController _messageController;

  // Animations
  late Animation<double> _pageOpacity;
  late Animation<Offset> _headerSlide;
  late Animation<double> _headerOpacity;
  late Animation<Offset> _calendarSlide;
  late Animation<double> _calendarOpacity;
  late Animation<double> _messagePulse;

  // State
  DateTime _currentMonth = DateTime.now();
  DateTime? _selectedDate;
  MenstrualCycle? _cycleWithData;

  // Colors following the specified design
  static const Color _backgroundColor = Color(0xFFFFF8E7); // Light Cream
  static const Color _buttonColor = Color(0xFF8B4513); // Earth Brown
  static const Color _cardColor = Colors.white;
  static const Color _textPrimary = Color(0xFF2C1810);
  static const Color _textSecondary = Color(0xFF6B4226);
  
  // Cycle phase colors
  static const Color _menstruationColor = Color(0xFFA0522D); // Sienna
  static const Color _fertileColor = Color(0xFF228B22); // Forest Green
  static const Color _ovulationColor = Color(0xFFDAA520); // Golden
  static const Color _safeColor = Color(0xFF87CEEB); // Sky Blue

  static const List<String> _weekDays = [
    'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateCycleData();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Page controller
    _pageController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Header controller
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Calendar controller
    _calendarController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Message controller (for pulsing effect)
    _messageController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Page animations
    _pageOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOut,
    ));

    // Header animations
    _headerSlide = Tween<Offset>(
      begin: const Offset(0.0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.elasticOut,
    ));

    _headerOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    // Calendar animations
    _calendarSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _calendarController,
      curve: Curves.easeOutBack,
    ));

    _calendarOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _calendarController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    // Message pulse animation
    _messagePulse = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _messageController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    _pageController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _headerController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _calendarController.forward();
    });
    _messageController.repeat(reverse: true);
  }

  void _generateCycleData() {
    final cycleDays = <DateTime, CycleDay>{};
    final now = DateTime.now();
    
    // Add some sample intercourse data for demonstration
    final sampleDates = [
      widget.cycle.lastPeriodStart.add(const Duration(days: 10)),
      widget.cycle.lastPeriodStart.add(const Duration(days: 15)),
      widget.cycle.lastPeriodStart.add(const Duration(days: 20)),
    ];
    
    for (int i = 0; i < sampleDates.length; i++) {
      final date = sampleDates[i];
      final key = DateTime(date.year, date.month, date.day);
      if (date.isBefore(now.add(const Duration(days: 1)))) {
        cycleDays[key] = CycleDay(
          date: date,
          type: widget.cycle.getCycleDayType(date),
          intercourse: i % 2 == 0 ? IntercourseType.protected : IntercourseType.unprotected,
          notes: i == 0 ? 'Exemple de rapport' : null,
          symptoms: i == 1 ? ['mood_happy'] : [],
        );
      }
    }
    
    setState(() {
      _cycleWithData = widget.cycle.copyWith(cycleDays: cycleDays);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _headerController.dispose();
    _calendarController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _changeMonth(int delta) async {
    await _calendarController.reverse();
    
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + delta);
      _selectedDate = null;
    });

    await _calendarController.forward();
  }

  void _onDayTapped(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    
    // Add ripple animation and feedback
    HapticFeedback.lightImpact();
  }

  void _goBackToSetup() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const CreateCyclePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: AnimatedBuilder(
        animation: _pageOpacity,
        builder: (context, child) {
          return Opacity(
            opacity: _pageOpacity.value,
            child: SafeArea(
              child: Column(
                children: [
                  // Animated header
                  AnimatedBuilder(
                    animation: _headerController,
                    builder: (context, child) {
                      return SlideTransition(
                        position: _headerSlide,
                        child: FadeTransition(
                          opacity: _headerOpacity,
                          child: _buildHeader(),
                        ),
                      );
                    },
                  ),
                  
                  // Status message bar
                  _buildStatusMessage(),
                  
                  // Calendar section
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _calendarController,
                      builder: (context, child) {
                        return SlideTransition(
                          position: _calendarSlide,
                          child: FadeTransition(
                            opacity: _calendarOpacity,
                            child: _buildCalendarSection(),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Legend
                  _buildLegend(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    final monthName = DateFormat('MMMM yyyy', 'fr_FR').format(_currentMonth);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _buttonColor,
            _buttonColor.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _buttonColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: _goBackToSetup,
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 20,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          
          // Previous month
          IconButton(
            onPressed: () => _changeMonth(-1),
            icon: const Icon(
              Icons.chevron_left,
              color: Colors.white,
              size: 28,
            ),
          ),
          
          // Month name
          Expanded(
            child: Text(
              monthName.substring(0, 1).toUpperCase() + monthName.substring(1),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Next month
          IconButton(
            onPressed: () => _changeMonth(1),
            icon: const Icon(
              Icons.chevron_right,
              color: Colors.white,
              size: 28,
            ),
          ),
          
          // Settings button
          IconButton(
            onPressed: _goBackToSetup,
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
              size: 20,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMessage() {
    if (_cycleWithData == null) return const SizedBox.shrink();

    final currentType = _cycleWithData!.getCycleDayType(DateTime.now());
    final daysUntilPeriod = _cycleWithData!.getDaysUntilNextPeriod();
    
    String message;
    String emoji;
    Color color;

    switch (currentType) {
      case CycleDayType.menstruation:
        message = 'Vous êtes actuellement en période de règles';
        emoji = '🩸';
        color = _menstruationColor;
        break;
      case CycleDayType.fertile:
        message = 'Aujourd\'hui est un jour fertile';
        emoji = '🌿';
        color = _fertileColor;
        break;
      case CycleDayType.ovulation:
        message = 'Aujourd\'hui est votre jour d\'ovulation';
        emoji = '🌟';
        color = _ovulationColor;
        break;
      case CycleDayType.safe:
        if (daysUntilPeriod <= 3) {
          message = 'Prochaines règles dans $daysUntilPeriod jour${daysUntilPeriod == 1 ? '' : 's'}';
          emoji = '⏰';
          color = _ovulationColor;
        } else {
          message = 'Aujourd\'hui est un jour à faible fertilité';
          emoji = '💙';
          color = _safeColor;
        }
        break;
    }

    return AnimatedBuilder(
      animation: _messagePulse,
      builder: (context, child) {
        return Transform.scale(
          scale: _messagePulse.value,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.1),
                  color.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    message,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Week days header
          _buildWeekDaysHeader(),
          
          // Calendar grid
          Expanded(
            child: _buildCalendarGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDaysHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: _buttonColor.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: _weekDays.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    if (_cycleWithData == null) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF8B4513)),
      );
    }

    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    final prevMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    final daysInPrevMonth = DateTime(_currentMonth.year, _currentMonth.month, 0).day;
    final prevMonthDaysToShow = firstDayWeekday - 1;

    final totalCells = 42;
    final currentMonthCells = daysInMonth;
    final prevMonthCells = prevMonthDaysToShow;
    final nextMonthCells = totalCells - prevMonthCells - currentMonthCells;

    List<Widget> calendarCells = [];

    // Previous month days
    for (int i = prevMonthDaysToShow; i > 0; i--) {
      final day = daysInPrevMonth - i + 1;
      final date = DateTime(prevMonth.year, prevMonth.month, day);
      calendarCells.add(_buildDayCell(date, day, false));
    }

    // Current month days
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      calendarCells.add(_buildDayCell(date, day, true));
    }

    // Next month days
    final nextMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    for (int day = 1; day <= nextMonthCells; day++) {
      final date = DateTime(nextMonth.year, nextMonth.month, day);
      calendarCells.add(_buildDayCell(date, day, false));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
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

  Widget _buildDayCell(DateTime date, int dayNumber, bool isCurrentMonth) {
    if (_cycleWithData == null) return const SizedBox.shrink();

    final cycleDay = _cycleWithData!.getCycleDay(date);
    final isSelected = _selectedDate != null &&
                      _selectedDate!.year == date.year &&
                      _selectedDate!.month == date.month &&
                      _selectedDate!.day == date.day;
    final isToday = DateTime.now().year == date.year &&
                   DateTime.now().month == date.month &&
                   DateTime.now().day == date.day;

    Color backgroundColor = Colors.transparent;
    Color borderColor = Colors.transparent;
    
    if (isCurrentMonth) {
      switch (cycleDay.type) {
        case CycleDayType.menstruation:
          backgroundColor = _menstruationColor.withOpacity(0.2);
          borderColor = _menstruationColor;
          break;
        case CycleDayType.fertile:
          backgroundColor = _fertileColor.withOpacity(0.2);
          borderColor = _fertileColor;
          break;
        case CycleDayType.ovulation:
          backgroundColor = _ovulationColor.withOpacity(0.2);
          borderColor = _ovulationColor;
          break;
        case CycleDayType.safe:
          backgroundColor = _safeColor.withOpacity(0.2);
          borderColor = _safeColor;
          break;
      }
    }

    return GestureDetector(
      onTap: isCurrentMonth ? () => _onDayTapped(date) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? borderColor.withOpacity(0.5) : backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isToday ? _buttonColor : (isSelected ? borderColor : Colors.transparent),
            width: isToday ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: borderColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Stack(
          children: [
            // Day number
            Center(
              child: Text(
                dayNumber.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                  color: isCurrentMonth ? 
                    (isToday ? _buttonColor : _textPrimary) : 
                    _textSecondary.withOpacity(0.5),
                ),
              ),
            ),
            
            // Intercourse indicator
            if (isCurrentMonth && cycleDay.intercourse != null)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: cycleDay.intercourse == IntercourseType.protected
                        ? Colors.green
                        : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Légende des couleurs',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildLegendItem('Règles', _menstruationColor, Icons.water_drop)),
              Expanded(child: _buildLegendItem('Fertile', _fertileColor, Icons.eco)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildLegendItem('Ovulation', _ovulationColor, Icons.star)),
              Expanded(child: _buildLegendItem('Sûr', _safeColor, Icons.shield)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

