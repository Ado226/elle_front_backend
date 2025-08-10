import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/menstrual_cycle.dart';
import '../../core/theme/african_theme.dart';

class CycleSetupPage extends StatefulWidget {
  final Function(MenstrualCycle) onCycleCreated;

  const CycleSetupPage({
    Key? key,
    required this.onCycleCreated,
  }) : super(key: key);

  @override
  State<CycleSetupPage> createState() => _CycleSetupPageState();
}

class _CycleSetupPageState extends State<CycleSetupPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  DateTime _lastPeriodStart = DateTime.now().subtract(const Duration(days: 14));
  int _cycleLength = 28;
  int _menstruationDuration = 5;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _lastPeriodStart,
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
        _lastPeriodStart = selectedDate;
      });
    }
  }

  void _createCycle() {
    if (_formKey.currentState!.validate()) {
      final cycle = MenstrualCycle(
        lastPeriodStart: _lastPeriodStart,
        cycleLength: _cycleLength,
        menstruationDuration: _menstruationDuration,
      );

      widget.onCycleCreated(cycle);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AfricanColors.backgroundColor,
      body: AnimatedBuilder(
        animation: _fadeController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),
                        
                        // Header
                        _buildHeader(),
                        
                        const SizedBox(height: 40),
                        
                        // Last period date
                        _buildDateSection(),
                        
                        const SizedBox(height: 32),
                        
                        // Cycle length
                        _buildCycleLengthSection(),
                        
                        const SizedBox(height: 32),
                        
                        // Menstruation duration
                        _buildMenstruationDurationSection(),
                        
                        const SizedBox(height: 40),
                        
                        // Information card
                        _buildInfoCard(),
                        
                        const SizedBox(height: 40),
                        
                        // Create button
                        _buildCreateButton(),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
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
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AfricanTheme.primaryGradientDecoration.gradient,
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
          'Configuration de votre cycle',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AfricanColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Aidez-nous à personnaliser votre expérience en configurant les détails de votre cycle menstruel.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AfricanColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDateSection() {
    return Container(
      decoration: AfricanTheme.cardDecoration,
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
                'Début des dernières règles',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AfricanColors.safariSand,
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
                      DateFormat('d MMMM yyyy', 'fr_FR').format(_lastPeriodStart),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
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

  Widget _buildCycleLengthSection() {
    return Container(
      decoration: AfricanTheme.cardDecoration,
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
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _cycleLength.toDouble(),
                  min: 21,
                  max: 35,
                  divisions: 14,
                  activeColor: AfricanColors.fertileColor,
                  inactiveColor: AfricanColors.safariSand,
                  onChanged: (value) {
                    setState(() {
                      _cycleLength = value.round();
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
                  '$_cycleLength jours',
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

  Widget _buildMenstruationDurationSection() {
    return Container(
      decoration: AfricanTheme.cardDecoration,
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
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _menstruationDuration.toDouble(),
                  min: 3,
                  max: 8,
                  divisions: 5,
                  activeColor: AfricanColors.ovulationColor,
                  inactiveColor: AfricanColors.safariSand,
                  onChanged: (value) {
                    setState(() {
                      _menstruationDuration = value.round();
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
                  '$_menstruationDuration jours',
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

  Widget _buildInfoCard() {
    final cycle = MenstrualCycle(
      lastPeriodStart: _lastPeriodStart,
      cycleLength: _cycleLength,
      menstruationDuration: _menstruationDuration,
    );

    return Container(
      decoration: BoxDecoration(
        gradient: AfricanTheme.sunsetGradientDecoration.gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AfricanColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: AfricanColors.textLight,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'Aperçu de votre cycle',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AfricanColors.textLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Prochaine ovulation prévue: ${DateFormat('d MMMM', 'fr_FR').format(cycle.ovulationDay)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AfricanColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Prochaines règles prévues: ${DateFormat('d MMMM', 'fr_FR').format(cycle.nextPeriodStart)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AfricanColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return ElevatedButton(
      onPressed: _createCycle,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Créer mon calendrier',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AfricanColors.textLight,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}