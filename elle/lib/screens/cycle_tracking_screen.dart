import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CycleTrackingScreen extends StatefulWidget {
  final Function(DateTime)? onDateSelected;
  final VoidCallback? onNext;
  final VoidCallback? onBack;

  const CycleTrackingScreen({
    Key? key,
    this.onDateSelected,
    this.onNext,
    this.onBack,
  }) : super(key: key);

  @override
  State<CycleTrackingScreen> createState() => _CycleTrackingScreenState();
}

class _CycleTrackingScreenState extends State<CycleTrackingScreen>
    with TickerProviderStateMixin {
  DateTime? selectedDate;
  List<DateTime> periodDates = [];

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late AnimationController _buttonController;
  late AnimationController _headerController;
  late AnimationController _calendarController;
  late AnimationController _shimmerController;
  late AnimationController _bounceController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _buttonAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _calendarSlideAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _bounceAnimation;

  // Modern gradient colors
  static const Color primaryPink = Color(0xFFE91E63);
  static const Color deepPink = Color(0xFFAD1457);
  static const Color lightPink = Color(0xFFFFE0E6);
  static const Color purple = Color(0xFF9C27B0);
  static const Color deepPurple = Color(0xFF7B1FA2);
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color blue = Color(0xFF1976D2);
  static const Color backgroundGray = Color(0xFFF8F9FA);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textLight = Color(0xFF666666);
  static const Color cardBackground = Color(0xFFFFFFFF);

  late final DateTime currentMonth;
  late final DateTime today;

  @override
  void initState() {
    super.initState();
    today = DateTime.now();
    currentMonth = DateTime(today.year, today.month, 1);

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _calendarController = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    );
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _buttonAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutBack,
    ));

    _calendarSlideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _calendarController,
      curve: Curves.easeOutCubic,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    // Start animations with delays
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _headerController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _calendarController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _scaleController.forward();
      _slideController.forward();
    });

    _pulseController.repeat(reverse: true);
    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    _buttonController.dispose();
    _headerController.dispose();
    _calendarController.dispose();
    _shimmerController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF0F5),
              Color(0xFFFFF8FC),
              Color(0xFFF8F9FA),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 30),
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildCalendar(),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _buildBottomButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SlideTransition(
      position: _headerSlideAnimation,
      child: Container(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        child: Column(
          children: [
            Row(
              children: [
                _buildBackButton(),
                const Spacer(),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 40),
            _buildHeaderTitle(),
            const SizedBox(height: 12),
            /*
            _buildSubtitle(),
             */
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTapDown: (_) => _buttonController.forward(),
      onTapUp: (_) => _buttonController.reverse(),
      onTapCancel: () => _buttonController.reverse(),
      onTap: () {
        HapticFeedback.lightImpact();
        if (widget.onBack != null) {
          widget.onBack!();
        } else {
          Navigator.of(context).pop();
        }
      },
      child: AnimatedBuilder(
        animation: _buttonAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _buttonAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.9),
                    Colors.white.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primaryPink.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios,
                color: textDark,
                size: 20,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderTitle() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                primaryPink.withOpacity(0.8),
                primaryPink,
                deepPink,
                purple,
                deepPink,
                primaryPink,
                primaryPink.withOpacity(0.8),
              ],
              stops: const [0.0, 0.1, 0.3, 0.5, 0.7, 0.9, 1.0],
              begin: Alignment(_shimmerAnimation.value - 1, 0),
              end: Alignment(_shimmerAnimation.value, 0),
            ).createShader(bounds);
          },
          child: const Text(
            'Quand avez-vous eu vos\ndernières règles ?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.3,
              letterSpacing: -0.5,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubtitle() {
    return AnimatedOpacity(
      opacity: _fadeAnimation.value,
      duration: const Duration(milliseconds: 800),
      child: Text(
        'Nous pourrons alors prévoir vos prochaines règles',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          color: textLight.withOpacity(0.8),
          height: 1.4,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return AnimatedBuilder(
      animation: _calendarSlideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _calendarSlideAnimation.value) * 50),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16), // ← Réduisez de 20 à 10
            decoration: BoxDecoration(
              color: cardBackground,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: primaryPink.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                children: [
                  _buildCalendarHeader(),
                  _buildWeekDayHeaders(),
                  const SizedBox(height: 8), // ← Réduisez de 16 à 8
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12), // ← Réduisez de 20 à 12
                      child: _buildCalendarGrid(),
                    ),
                  ),
                  const SizedBox(height: 10), // ← Réduisez de 20 à 10
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryPink.withOpacity(0.1),
            purple.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
            child: Text(_getMonthYearDisplay()),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDayHeaders() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ['L', 'M', 'M', 'J', 'V', 'S', 'D']
            .asMap()
            .entries
            .map((entry) => AnimatedContainer(
          duration: Duration(milliseconds: 300 + (entry.key * 50)),
          width: 40,
          child: Text(
            entry.value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: textLight.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ))
            .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    int firstDayWeekday = firstDayOfMonth.weekday;
    int daysFromMonday = firstDayWeekday - 1;
    final startDate = firstDayOfMonth.subtract(Duration(days: daysFromMonday));

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 42,
      itemBuilder: (context, index) {
        final date = startDate.add(Duration(days: index));
        return AnimatedContainer(
          duration: Duration(milliseconds: 100 + (index * 20)),
          curve: Curves.easeOutCubic,
          child: _buildCalendarDay(date),
        );
      },
    );
  }

  Widget _buildCalendarDay(DateTime date) {
    final isCurrentMonth = date.month == currentMonth.month;
    final isSelected = selectedDate != null && _isSameDay(date, selectedDate!);
    final isToday = _isSameDay(date, today);
    final dateStyle = _getDateStyle(date);

    return GestureDetector(
      onTapDown: (_) {
        // Micro bounce animation on tap
        _bounceController.reset();
        _bounceController.forward();
      },
      onTap: () => _onDateSelected(date),
      child: AnimatedBuilder(
        animation: _bounceAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isSelected ? 1.0 : (1.0 - (_bounceAnimation.value * 0.1)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                gradient: dateStyle.gradient,
                shape: BoxShape.circle,
                boxShadow: isSelected || isToday ? [
                  BoxShadow(
                    color: (isSelected ? primaryPink : purple).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ] : [],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (isSelected)
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: primaryPink.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
                      color: dateStyle.textColor,
                    ),
                    child: Text('${date.day}'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  DateStyle _getDateStyle(DateTime date) {
    final isCurrentMonth = date.month == currentMonth.month;
    final isSelected = selectedDate != null && _isSameDay(date, selectedDate!);
    final isToday = _isSameDay(date, today);

    if (isSelected) {
      return DateStyle(
        gradient: const LinearGradient(
          colors: [primaryPink, deepPink],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        textColor: Colors.white,
      );
    }

    if (isToday) {
      return DateStyle(
        gradient: const LinearGradient(
          colors: [purple, deepPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        textColor: Colors.white,
      );
    }

    return DateStyle(
      gradient: null,
      textColor: isCurrentMonth ? textDark : Colors.grey.shade400,
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        children: [
          _buildAnimatedButton(
            text: 'SUIVANT',
            onPressed: _onSuivantPressed,
            isPrimary: true,
          ),
          const SizedBox(height: 16),
          _buildAnimatedButton(
            text: 'JE NE SAIS PAS',
            onPressed: _onJeNeSaisPasPressed,
            isPrimary: false,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedButton({
    required String text,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (isPrimary ? primaryPink : Colors.grey).withOpacity(0.3 * value),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onPressed();
                },
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    gradient: isPrimary
                        ? const LinearGradient(
                      colors: [primaryPink, deepPink],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                        : null,
                    color: isPrimary ? null : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: isPrimary
                        ? null
                        : Border.all(color: primaryPink, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 150),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: isPrimary ? Colors.white : primaryPink,
                    ),
                    child: Text(text),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onDateSelected(DateTime date) {
    HapticFeedback.lightImpact();
    setState(() {
      selectedDate = date;
      if (!periodDates.contains(date)) {
        periodDates.add(date);
      }
    });

    if (widget.onDateSelected != null) {
      widget.onDateSelected!(date);
    }
  }

  void _onSuivantPressed() {
    if (selectedDate != null) {
      if (widget.onNext != null) {
        widget.onNext!();
      } else {
        _showSnackBar(
          'Date sélectionnée: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
          primaryPink,
        );
      }
    } else {
      _showSnackBar('Veuillez sélectionner une date', Colors.orange);
    }
  }

  void _onJeNeSaisPasPressed() {
    if (widget.onNext != null) {
      widget.onNext!();
    } else {
      _showSnackBar('Aucune date sélectionnée', Colors.grey);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getMonthYearDisplay() {
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];

    final monthName = months[currentMonth.month - 1];
    return '$monthName ${currentMonth.year}';
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

class DateStyle {
  final LinearGradient? gradient;
  final Color textColor;

  DateStyle({
    this.gradient,
    required this.textColor,
  });
}