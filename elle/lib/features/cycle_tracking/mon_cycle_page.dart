import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/menstrual_cycle.dart';
import '../../core/theme/african_theme.dart';
import 'widgets/header_bar.dart';
import 'widgets/day_cell.dart';
import 'widgets/cycle_summary_card.dart';
import 'widgets/cycle_legend.dart';
import 'widgets/intercourse_dialog.dart';

class MonCyclePage extends StatefulWidget {
  const MonCyclePage({Key? key}) : super(key: key);

  @override
  State<MonCyclePage> createState() => _MonCyclePageState();
}

class _MonCyclePageState extends State<MonCyclePage>
    with TickerProviderStateMixin {
  late AnimationController _pageController;
  late AnimationController _calendarController;
  late Animation<double> _pageAnimation;
  late Animation<Offset> _calendarSlideAnimation;

  DateTime _currentMonth = DateTime.now();
  DateTime? _selectedDate;
  bool _showLegend = false;
  bool _showSetup = true;
  MenstrualCycle? _cycle;
  
  // Setup form controllers
  DateTime _setupStartDate = DateTime.now().subtract(const Duration(days: 14));
  int _setupCycleLength = 28;
  int _setupMenstruationDuration = 5;

  static const List<String> _weekDays = [
    'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'
  ];

  @override
  void initState() {
    super.initState();
    
    _pageController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _calendarController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _pageAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOutCubic,
    ));

    _calendarSlideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _calendarController,
      curve: Curves.easeOutCubic,
    ));

    // Don't initialize mock data automatically - wait for user input
    _pageController.forward();
    _calendarController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  void _generateCalendar() {
    // Create cycle data from user input
    final baseCycle = MenstrualCycle(
      lastPeriodStart: _setupStartDate,
      cycleLength: _setupCycleLength,
      menstruationDuration: _setupMenstruationDuration,
    );
    
    // Generate cycle days using the user's cycle data
    final cycleDays = _generateCycleDays(baseCycle);
    
    // Create the complete cycle with user data
    setState(() {
      _cycle = baseCycle.copyWith(cycleDays: cycleDays);
      _showSetup = false;
    });
  }

  void _resetSetup() {
    setState(() {
      _showSetup = true;
      _cycle = null;
    });
  }

  Map<DateTime, CycleDay> _generateCycleDays(MenstrualCycle baseCycle) {
    final Map<DateTime, CycleDay> cycleDays = {};
    final now = DateTime.now();
    
    // Add some sample intercourse tracking for demonstration
    final sampleDates = [
      _setupStartDate.add(const Duration(days: 10)),
      _setupStartDate.add(const Duration(days: 15)),
      _setupStartDate.add(const Duration(days: 20)),
    ];
    
    for (int i = 0; i < sampleDates.length; i++) {
      final date = sampleDates[i];
      final key = DateTime(date.year, date.month, date.day);
      if (date.isBefore(now.add(const Duration(days: 1)))) {
        cycleDays[key] = CycleDay(
          date: date,
          type: baseCycle.getCycleDayType(date),
          intercourse: i % 2 == 0 ? IntercourseType.protected : IntercourseType.unprotected,
          notes: i == 0 ? 'Exemple de rapport' : null,
          symptoms: i == 1 ? ['mood_happy'] : [],
        );
      }
    }
    
    return cycleDays;
  }

  void _changeMonth(int delta) async {
    await _calendarController.reverse();
    
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + delta);
      _selectedDate = null;
    });

    await _calendarController.forward();
  }

  void _goToToday() {
    _changeMonth(DateTime.now().difference(_currentMonth).inDays ~/ 30);
  }

  void _toggleLegend() {
    setState(() {
      _showLegend = !_showLegend;
    });
  }

  void _selectStartDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _setupStartDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AfricanColors.primaryColor,
              secondary: AfricanColors.goldAccent,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        _setupStartDate = selectedDate;
      });
    }
  }

  void _onDayTapped(CycleDay cycleDay) {
    setState(() {
      _selectedDate = cycleDay.date;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => IntercourseDialog(
        cycleDay: cycleDay,
        onSave: _updateCycleDay,
      ),
    );
  }

  void _updateCycleDay(CycleDay updatedDay) {
    if (_cycle != null) {
      setState(() {
        _cycle = _cycle!.updateCycleDay(updatedDay);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AfricanColors.backgroundColor,
      body: Stack(
        children: [
          // Main content
          AnimatedBuilder(
            animation: _pageAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _pageAnimation.value,
                child: _showSetup ? _buildSetupSection() : _buildCalendarSection(),
              );
            },
          ),
          
          // Legend overlay (only show when not in setup)
          if (!_showSetup)
            CycleLegend(
              isVisible: _showLegend,
              onClose: () => setState(() => _showLegend = false),
            ),
          
          // Floating action buttons (only show when not in setup)
          if (!_showSetup)
            _buildFloatingActions(),
        ],
      ),
    );
  }

  Widget _buildSetupSection() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            
            // Header
            _buildSetupHeader(),
            
            const SizedBox(height: 40),
            
            // Setup form
            _buildSetupForm(),
            
            const SizedBox(height: 40),
            
            // Generate button
            _buildGenerateButton(),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarSection() {
    // Show loading if cycle is not yet initialized
    if (_cycle == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: AfricanColors.primaryColor,
        ),
      );
    }

    return Column(
      children: [
        // Header with navigation and status
        HeaderBar(
          currentMonth: _currentMonth,
          cycle: _cycle!,
          onPreviousMonth: () => _changeMonth(-1),
          onNextMonth: () => _changeMonth(1),
          onTodayTap: _goToToday,
        ),
        
        // Summary card
        CycleSummaryCard(cycle: _cycle!),
        
        // Calendar container
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: AfricanColors.ivoryWhite,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Week days header
                _buildWeekDaysHeader(),
                
                // Calendar grid
                Expanded(
                  child: SlideTransition(
                    position: _calendarSlideAnimation,
                    child: _buildCalendarGrid(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekDaysHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: const BoxDecoration(
        color: AfricanColors.safariSand,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: _weekDays.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AfricanColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    if (_cycle == null) {
      return const Center(child: CircularProgressIndicator());
    }

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
      final cycleDay = _cycle!.getCycleDay(date);
      
      calendarCells.add(
        DayCell(
          cycleDay: cycleDay,
          dayNumber: day,
          isCurrentMonth: false,
          onTap: () => _onDayTapped(cycleDay),
        ),
      );
    }

    // Current month days
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final cycleDay = _cycle!.getCycleDay(date);
      final isSelected = _selectedDate != null &&
                        _selectedDate!.year == date.year &&
                        _selectedDate!.month == date.month &&
                        _selectedDate!.day == date.day;
      
      calendarCells.add(
        DayCell(
          cycleDay: cycleDay,
          dayNumber: day,
          isCurrentMonth: true,
          isSelected: isSelected,
          onTap: () => _onDayTapped(cycleDay),
        ),
      );
    }

    // Next month days
    final nextMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    for (int day = 1; day <= nextMonthCells; day++) {
      final date = DateTime(nextMonth.year, nextMonth.month, day);
      final cycleDay = _cycle!.getCycleDay(date);
      
      calendarCells.add(
        DayCell(
          cycleDay: cycleDay,
          dayNumber: day,
          isCurrentMonth: false,
          onTap: () => _onDayTapped(cycleDay),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12),
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

  Widget _buildFloatingActions() {
    return Positioned(
      bottom: 24 + MediaQuery.of(context).padding.bottom,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Settings button (to go back to setup)
          FloatingActionButton(
            heroTag: "settings",
            onPressed: _resetSetup,
            backgroundColor: AfricanColors.goldAccent,
            foregroundColor: AfricanColors.textPrimary,
            elevation: 8,
            child: const Icon(
              Icons.settings,
              size: 24,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Legend button
          FloatingActionButton(
            heroTag: "legend",
            onPressed: _toggleLegend,
            backgroundColor: AfricanColors.goldAccent,
            foregroundColor: AfricanColors.textPrimary,
            elevation: 8,
            child: Icon(
              _showLegend ? Icons.close : Icons.info_outline,
              size: 24,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Add button
          FloatingActionButton.extended(
            heroTag: "add",
            onPressed: _cycle != null ? () {
              final today = DateTime.now();
              final todayCycleDay = _cycle!.getCycleDay(today);
              _onDayTapped(todayCycleDay);
            } : null,
            backgroundColor: AfricanColors.primaryColor,
            foregroundColor: AfricanColors.textLight,
            elevation: 8,
            icon: const Icon(Icons.favorite, size: 20),
            label: Text(
              'Ajouter',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AfricanColors.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AfricanColors.primaryColor,
                AfricanColors.copperAccent,
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AfricanColors.primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.calendar_month_rounded,
            color: AfricanColors.textLight,
            size: 40,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Créer Mon Calendrier',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AfricanColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Configurez votre cycle menstruel pour obtenir un calendrier personnalisé avec vos phases de fertilité.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AfricanColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSetupForm() {
    return Column(
      children: [
        // Start date input
        _buildDateInputCard(),
        
        const SizedBox(height: 20),
        
        // Cycle length input
        _buildCycleLengthCard(),
        
        const SizedBox(height: 20),
        
        // Menstruation duration input
        _buildMenstruationDurationCard(),
      ],
    );
  }

  Widget _buildDateInputCard() {
    return Container(
      decoration: BoxDecoration(
        color: AfricanColors.ivoryWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AfricanColors.menstruationColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.water_drop,
                  color: AfricanColors.menstruationColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Date de début des dernières règles',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AfricanColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          GestureDetector(
            onTap: _selectStartDate,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AfricanColors.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AfricanColors.dividerColor),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: AfricanColors.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      DateFormat('d MMMM yyyy', 'fr_FR').format(_setupStartDate),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AfricanColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AfricanColors.textSecondary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleLengthCard() {
    return Container(
      decoration: BoxDecoration(
        color: AfricanColors.ivoryWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AfricanColors.fertileColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.refresh,
                  color: AfricanColors.fertileColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Durée moyenne du cycle',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AfricanColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _setupCycleLength.toDouble(),
                  min: 21,
                  max: 35,
                  divisions: 14,
                  activeColor: AfricanColors.fertileColor,
                  inactiveColor: AfricanColors.backgroundColor,
                  onChanged: (value) {
                    setState(() {
                      _setupCycleLength = value.round();
                    });
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AfricanColors.fertileColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_setupCycleLength jours',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AfricanColors.fertileColor,
                  ),
                ),
              ),
            ],
          ),
          
          Text(
            'La plupart des femmes ont un cycle de 28 jours, mais entre 21 et 35 jours est normal.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AfricanColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenstruationDurationCard() {
    return Container(
      decoration: BoxDecoration(
        color: AfricanColors.ivoryWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AfricanColors.ovulationColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.timer,
                  color: AfricanColors.ovulationColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Durée des règles',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AfricanColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _setupMenstruationDuration.toDouble(),
                  min: 3,
                  max: 8,
                  divisions: 5,
                  activeColor: AfricanColors.ovulationColor,
                  inactiveColor: AfricanColors.backgroundColor,
                  onChanged: (value) {
                    setState(() {
                      _setupMenstruationDuration = value.round();
                    });
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AfricanColors.ovulationColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_setupMenstruationDuration jours',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AfricanColors.ovulationColor,
                  ),
                ),
              ),
            ],
          ),
          
          Text(
            'La durée normale des règles varie de 3 à 8 jours.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AfricanColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return Column(
      children: [
        // Preview info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AfricanColors.goldAccent,
                AfricanColors.ovulationColor,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AfricanColors.goldAccent.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AfricanColors.textPrimary,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                'Aperçu de votre cycle',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AfricanColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Cycle de $_setupCycleLength jours • Règles de $_setupMenstruationDuration jours',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AfricanColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Generate button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _generateCalendar,
            style: ElevatedButton.styleFrom(
              backgroundColor: AfricanColors.primaryColor,
              foregroundColor: AfricanColors.textLight,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Générer Mon Calendrier',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AfricanColors.textLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}