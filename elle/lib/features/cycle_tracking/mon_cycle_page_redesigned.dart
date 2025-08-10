import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/menstrual_cycle.dart';
import '../../core/theme/african_theme.dart';
import 'widgets/day_cell.dart';
import 'widgets/intercourse_dialog.dart';

class MonCyclePageRedesigned extends StatefulWidget {
  const MonCyclePageRedesigned({Key? key}) : super(key: key);

  @override
  State<MonCyclePageRedesigned> createState() => _MonCyclePageRedesignedState();
}

class _MonCyclePageRedesignedState extends State<MonCyclePageRedesigned>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _pageController;
  late AnimationController _formController;
  late AnimationController _calendarController;
  late AnimationController _statusController;
  late AnimationController _buttonController;

  // Animations
  late Animation<double> _pageAnimation;
  late Animation<Offset> _formSlideAnimation;
  late Animation<double> _formFadeAnimation;
  late Animation<Offset> _calendarSlideAnimation;
  late Animation<double> _calendarFadeAnimation;
  late Animation<double> _statusPulseAnimation;
  late Animation<double> _buttonScaleAnimation;

  // State variables
  DateTime _currentMonth = DateTime.now();
  DateTime? _selectedDate;
  bool _showLegend = false;
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
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _pageController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _formController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _calendarController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _statusController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    // Page animations
    _pageAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOutCubic,
    ));

    // Form animations
    _formSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.elasticOut,
    ));

    _formFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    // Calendar animations
    _calendarSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _calendarController,
      curve: Curves.easeOutBack,
    ));

    _calendarFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _calendarController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    // Status pulse animation
    _statusPulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _statusController,
      curve: Curves.easeInOut,
    ));

    // Button scale animation
    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    _pageController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _formController.forward();
    });
    _statusController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _formController.dispose();
    _calendarController.dispose();
    _statusController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  void _generateCalendar() async {
    _buttonController.forward();
    
    // Create cycle data from user input
    final baseCycle = MenstrualCycle(
      lastPeriodStart: _setupStartDate,
      cycleLength: _setupCycleLength,
      menstruationDuration: _setupMenstruationDuration,
    );
    
    // Generate cycle days
    final cycleDays = _generateCycleDays(baseCycle);
    
    setState(() {
      _cycle = baseCycle.copyWith(cycleDays: cycleDays);
    });

    // Start calendar animation
    await _calendarController.forward();
    _buttonController.reverse();
  }

  Map<DateTime, CycleDay> _generateCycleDays(MenstrualCycle baseCycle) {
    final Map<DateTime, CycleDay> cycleDays = {};
    final now = DateTime.now();
    
    // Add some sample data
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
      // Reset calendar if already generated
      if (_cycle != null) {
        _calendarController.reset();
        setState(() {
          _cycle = null;
        });
      }
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
      body: AnimatedBuilder(
        animation: _pageAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _pageAnimation.value,
            child: CustomScrollView(
              slivers: [
                // AppBar
                _buildSliverAppBar(),
                
                // Form section
                SliverToBoxAdapter(
                  child: _buildFormSection(),
                ),
                
                // Status banner
                if (_cycle != null)
                  SliverToBoxAdapter(
                    child: _buildStatusBanner(),
                  ),
                
                // Calendar section
                if (_cycle != null)
                  SliverToBoxAdapter(
                    child: _buildCalendarSection(),
                  ),
                
                // Legend section
                if (_cycle != null)
                  SliverToBoxAdapter(
                    child: _buildLegendSection(),
                  ),
                
                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 12,
      backgroundColor: AfricanColors.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AfricanColors.primaryColor,
                AfricanColors.copperAccent,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AfricanColors.textLight.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.calendar_month_rounded,
                          color: AfricanColors.textLight,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mon Calendrier Menstruel',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AfricanColors.textLight,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Suivi personnalisé de votre cycle',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AfricanColors.textLight.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return AnimatedBuilder(
      animation: _formController,
      builder: (context, child) {
        return SlideTransition(
          position: _formSlideAnimation,
          child: FadeTransition(
            opacity: _formFadeAnimation,
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AfricanColors.ivoryWhite,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AfricanColors.primaryColor, AfricanColors.goldAccent],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.settings_rounded,
                            color: AfricanColors.textLight,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Configuration du Cycle',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AfricanColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Date input
                    _buildDateInput(),
                    
                    const SizedBox(height: 20),
                    
                    // Cycle length
                    _buildCycleLengthInput(),
                    
                    const SizedBox(height: 20),
                    
                    // Menstruation duration
                    _buildMenstruationDurationInput(),
                    
                    const SizedBox(height: 24),
                    
                    // Generate button
                    _buildGenerateButton(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AfricanColors.menstruationColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.water_drop,
                color: AfricanColors.menstruationColor,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Date des dernières règles',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AfricanColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _selectStartDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AfricanColors.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AfricanColors.primaryColor.withOpacity(0.3)),
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
                    DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(_setupStartDate),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AfricanColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.edit,
                  color: AfricanColors.primaryColor,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCycleLengthInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AfricanColors.fertileColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.refresh,
                color: AfricanColors.fertileColor,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Durée du cycle',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AfricanColors.textPrimary,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AfricanColors.fertileColor,
            inactiveTrackColor: AfricanColors.fertileColor.withOpacity(0.3),
            thumbColor: AfricanColors.fertileColor,
            overlayColor: AfricanColors.fertileColor.withOpacity(0.2),
            trackHeight: 6,
          ),
          child: Slider(
            value: _setupCycleLength.toDouble(),
            min: 21,
            max: 35,
            divisions: 14,
            onChanged: (value) {
              setState(() {
                _setupCycleLength = value.round();
              });
              if (_cycle != null) {
                _calendarController.reset();
                setState(() {
                  _cycle = null;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMenstruationDurationInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AfricanColors.ovulationColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.timer,
                color: AfricanColors.ovulationColor,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Durée des règles',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AfricanColors.textPrimary,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AfricanColors.ovulationColor,
            inactiveTrackColor: AfricanColors.ovulationColor.withOpacity(0.3),
            thumbColor: AfricanColors.ovulationColor,
            overlayColor: AfricanColors.ovulationColor.withOpacity(0.2),
            trackHeight: 6,
          ),
          child: Slider(
            value: _setupMenstruationDuration.toDouble(),
            min: 3,
            max: 8,
            divisions: 5,
            onChanged: (value) {
              setState(() {
                _setupMenstruationDuration = value.round();
              });
              if (_cycle != null) {
                _calendarController.reset();
                setState(() {
                  _cycle = null;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return AnimatedBuilder(
      animation: _buttonController,
      builder: (context, child) {
        return Transform.scale(
          scale: _buttonScaleAnimation.value,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _cycle == null ? _generateCalendar : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AfricanColors.primaryColor,
                foregroundColor: AfricanColors.textLight,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_cycle == null) ...[
                    const Icon(Icons.auto_awesome, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Générer Mon Calendrier',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AfricanColors.textLight,
                      ),
                    ),
                  ] else ...[
                    const Icon(Icons.check_circle, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Calendrier Généré',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AfricanColors.textLight,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBanner() {
    if (_cycle == null) return const SizedBox.shrink();

    final currentType = _cycle!.getCycleDayType(DateTime.now());
    final daysUntilPeriod = _cycle!.getDaysUntilNextPeriod();
    
    String message;
    String emoji;
    Color color;

    switch (currentType) {
      case CycleDayType.menstruation:
        message = 'Vous êtes actuellement en période de règles';
        emoji = '🩸';
        color = AfricanColors.menstruationColor;
        break;
      case CycleDayType.fertile:
        message = 'Aujourd\'hui est un jour fertile';
        emoji = '🌿';
        color = AfricanColors.fertileColor;
        break;
      case CycleDayType.ovulation:
        message = 'Aujourd\'hui est votre jour d\'ovulation';
        emoji = '🌟';
        color = AfricanColors.ovulationColor;
        break;
      case CycleDayType.safe:
        if (daysUntilPeriod <= 3) {
          message = 'Vos prochaines règles dans $daysUntilPeriod jour${daysUntilPeriod == 1 ? '' : 's'}';
          emoji = '⏰';
          color = AfricanColors.warningOrange;
        } else {
          message = 'Aujourd\'hui est un jour à faible fertilité';
          emoji = '💙';
          color = AfricanColors.safeColor;
        }
        break;
    }

    return AnimatedBuilder(
      animation: _statusController,
      builder: (context, child) {
        return Transform.scale(
          scale: _statusPulseAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
    if (_cycle == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _calendarController,
      builder: (context, child) {
        return SlideTransition(
          position: _calendarSlideAnimation,
          child: FadeTransition(
            opacity: _calendarFadeAnimation,
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AfricanColors.ivoryWhite,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Month navigation
                  _buildMonthNavigation(),
                  
                  // Week days header
                  _buildWeekDaysHeader(),
                  
                  // Calendar grid
                  _buildCalendarGrid(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMonthNavigation() {
    final monthName = DateFormat('MMMM yyyy', 'fr_FR').format(_currentMonth);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AfricanColors.primaryColor,
            AfricanColors.copperAccent,
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
          Text(
            monthName.substring(0, 1).toUpperCase() + monthName.substring(1),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AfricanColors.textLight,
              fontWeight: FontWeight.bold,
            ),
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: const BoxDecoration(
        color: AfricanColors.safariSand,
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
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    if (_cycle == null) return const SizedBox.shrink();

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
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
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

  Widget _buildLegendSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AfricanColors.ivoryWhite,
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
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AfricanColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildLegendItem('Règles', AfricanColors.menstruationColor, Icons.water_drop)),
              Expanded(child: _buildLegendItem('Fertile', AfricanColors.fertileColor, Icons.eco)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildLegendItem('Ovulation', AfricanColors.ovulationColor, Icons.star)),
              Expanded(child: _buildLegendItem('Sûr', AfricanColors.safeColor, Icons.shield)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
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