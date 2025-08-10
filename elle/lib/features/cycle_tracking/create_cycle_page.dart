import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/menstrual_cycle.dart';
import 'cycle_calendar_page.dart';

/// PAGE 1 - "Create My Calendar"
/// Allows users to enter their menstrual cycle parameters and navigate to calendar view
class CreateCyclePage extends StatefulWidget {
  const CreateCyclePage({Key? key}) : super(key: key);

  @override
  State<CreateCyclePage> createState() => _CreateCyclePageState();
}

class _CreateCyclePageState extends State<CreateCyclePage>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _pageController;
  late AnimationController _formController;
  late AnimationController _buttonController;

  // Animations
  late Animation<double> _pageOpacity;
  late Animation<Offset> _formSlide;
  late Animation<double> _formOpacity;
  late Animation<double> _buttonScale;

  // Form state
  DateTime _selectedDate = DateTime.now().subtract(const Duration(days: 14));
  int _cycleLength = 28;
  int _menstruationDuration = 5;
  bool _isLoading = false;

  // Form validation
  final _formKey = GlobalKey<FormState>();

  // Colors following the specified design
  static const Color _backgroundColor = Color(0xFFFFF8E7); // Light Cream
  static const Color _buttonColor = Color(0xFF8B4513); // Earth Brown
  static const Color _cardColor = Colors.white;
  static const Color _textPrimary = Color(0xFF2C1810);
  static const Color _textSecondary = Color(0xFF6B4226);
  static const Color _accentColor = Color(0xFFDAA520); // Golden

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Page controller
    _pageController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Form controller
    _formController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Button controller
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 200),
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

    // Form animations
    _formSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.elasticOut,
    ));

    _formOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    // Button animations
    _buttonScale = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    _pageController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _formController.forward();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _formController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: _buttonColor,
              secondary: _accentColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDate = selectedDate;
      });
    }
  }

  Future<void> _generateCalendar() async {
    if (!_formKey.currentState!.validate()) return;

    // Button press animation
    await _buttonController.forward();
    _buttonController.reverse();

    setState(() {
      _isLoading = true;
    });

    // Simulate processing time for smooth UX
    await Future.delayed(const Duration(milliseconds: 800));

    // Create cycle data
    final cycle = MenstrualCycle(
      lastPeriodStart: _selectedDate,
      cycleLength: _cycleLength,
      menstruationDuration: _menstruationDuration,
    );

    // Navigate to calendar page
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              CycleCalendarPage(cycle: cycle),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      
                      // Header
                      _buildHeader(),
                      
                      const SizedBox(height: 40),
                      
                      // Form section
                      AnimatedBuilder(
                        animation: _formController,
                        builder: (context, child) {
                          return SlideTransition(
                            position: _formSlide,
                            child: FadeTransition(
                              opacity: _formOpacity,
                              child: _buildForm(),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Generate button
                      _buildGenerateButton(),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // App icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _buttonColor,
                _buttonColor.withOpacity(0.8),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _buttonColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.calendar_month_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Title
        Text(
          'Créer Mon Calendrier',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: _textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 8),
        
        // Subtitle
        Text(
          'Configurez votre cycle menstruel pour obtenir\nun calendrier personnalisé.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: _textSecondary,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        // Date input card
        _buildDateCard(),
        
        const SizedBox(height: 20),
        
        // Cycle length card
        _buildCycleLengthCard(),
        
        const SizedBox(height: 20),
        
        // Menstruation duration card
        _buildMenstruationCard(),
      ],
    );
  }

  Widget _buildDateCard() {
    return Container(
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
                  color: const Color(0xFFA0522D).withOpacity(0.1), // Sienna
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.water_drop,
                  color: Color(0xFFA0522D),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Date des dernières règles',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Date picker button
          GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _buttonColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: _buttonColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(_selectedDate),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: _textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.edit,
                    color: _buttonColor,
                    size: 18,
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
                  color: const Color(0xFF228B22).withOpacity(0.1), // Forest Green
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.refresh,
                  color: Color(0xFF228B22),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Durée du cycle',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF228B22).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_cycleLength jours',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF228B22),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF228B22),
              inactiveTrackColor: const Color(0xFF228B22).withOpacity(0.3),
              thumbColor: const Color(0xFF228B22),
              overlayColor: const Color(0xFF228B22).withOpacity(0.2),
              trackHeight: 6,
            ),
            child: Slider(
              value: _cycleLength.toDouble(),
              min: 21,
              max: 35,
              divisions: 14,
              onChanged: (value) {
                setState(() {
                  _cycleLength = value.round();
                });
              },
            ),
          ),
          
          Text(
            'La plupart des femmes ont un cycle de 28 jours, mais entre 21 et 35 jours est normal.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenstruationCard() {
    return Container(
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
                  color: _accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.timer,
                  color: _accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Durée des règles',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_menstruationDuration jours',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _accentColor,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _accentColor,
              inactiveTrackColor: _accentColor.withOpacity(0.3),
              thumbColor: _accentColor,
              overlayColor: _accentColor.withOpacity(0.2),
              trackHeight: 6,
            ),
            child: Slider(
              value: _menstruationDuration.toDouble(),
              min: 3,
              max: 8,
              divisions: 5,
              onChanged: (value) {
                setState(() {
                  _menstruationDuration = value.round();
                });
              },
            ),
          ),
          
          Text(
            'La durée normale des règles varie de 3 à 8 jours.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return AnimatedBuilder(
      animation: _buttonScale,
      builder: (context, child) {
        return Transform.scale(
          scale: _buttonScale.value,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _generateCalendar,
              style: ElevatedButton.styleFrom(
                backgroundColor: _buttonColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: _buttonColor.withOpacity(0.4),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.auto_awesome, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Générer Mon Calendrier',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}