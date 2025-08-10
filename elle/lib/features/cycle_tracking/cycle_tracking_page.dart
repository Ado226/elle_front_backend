import 'package:flutter/material.dart';
import '../../core/models/menstrual_cycle.dart';
import '../../core/theme/african_theme.dart';
import 'widgets/cycle_calendar.dart';
import 'widgets/cycle_notifications.dart';
import 'widgets/intercourse_dialog.dart';
import 'cycle_setup_page.dart';

class CycleTrackingPage extends StatefulWidget {
  const CycleTrackingPage({Key? key}) : super(key: key);

  @override
  State<CycleTrackingPage> createState() => _CycleTrackingPageState();
}

class _CycleTrackingPageState extends State<CycleTrackingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  MenstrualCycle? _currentCycle;
  bool _isSetupComplete = false;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Load mock data for demonstration
    _loadMockData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _loadMockData() {
    // Create mock cycle with realistic data
    setState(() {
      _currentCycle = MenstrualCycle(
        lastPeriodStart: DateTime.now().subtract(const Duration(days: 10)),
        cycleLength: 28,
        menstruationDuration: 5,
        cycleDays: _generateMockCycleDays(),
      );
      _isSetupComplete = true;
    });
    
    _fadeController.forward();
  }

  Map<DateTime, CycleDay> _generateMockCycleDays() {
    final Map<DateTime, CycleDay> cycleDays = {};
    final now = DateTime.now();
    
    // Add some intercourse data for demonstration
    final intercourseDay1 = now.subtract(const Duration(days: 15));
    final intercourseDay2 = now.subtract(const Duration(days: 8));
    final intercourseDay3 = now.subtract(const Duration(days: 3));
    
    cycleDays[DateTime(intercourseDay1.year, intercourseDay1.month, intercourseDay1.day)] = 
        CycleDay(
          date: intercourseDay1,
          type: CycleDayType.fertile,
          intercourse: IntercourseType.protected,
          notes: 'Bon moment ensemble 💕',
          symptoms: ['mood_happy', 'cervical_mucus'],
        );
    
    cycleDays[DateTime(intercourseDay2.year, intercourseDay2.month, intercourseDay2.day)] = 
        CycleDay(
          date: intercourseDay2,
          type: CycleDayType.menstruation,
          intercourse: IntercourseType.unprotected,
          symptoms: ['cramps'],
        );
    
    cycleDays[DateTime(intercourseDay3.year, intercourseDay3.month, intercourseDay3.day)] = 
        CycleDay(
          date: intercourseDay3,
          type: CycleDayType.safe,
          intercourse: IntercourseType.protected,
          notes: 'Soirée romantique 🌙',
          symptoms: ['mood_happy'],
        );
    
    return cycleDays;
  }

  void _onCycleCreated(MenstrualCycle cycle) {
    setState(() {
      _currentCycle = cycle;
      _isSetupComplete = true;
    });
    _fadeController.forward();
  }

  void _onDayTapped(CycleDay cycleDay) {
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
    if (_currentCycle != null) {
      setState(() {
        _currentCycle = _currentCycle!.updateCycleDay(updatedDay);
      });
    }
  }

  void _resetSetup() {
    setState(() {
      _isSetupComplete = false;
      _currentCycle = null;
    });
    _fadeController.reset();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isSetupComplete || _currentCycle == null) {
      return CycleSetupPage(onCycleCreated: _onCycleCreated);
    }

    return Scaffold(
      backgroundColor: AfricanColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Mon Cycle'),
        actions: [
          IconButton(
            onPressed: _resetSetup,
            icon: const Icon(Icons.settings),
            tooltip: 'Reconfigurer',
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _fadeController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Column(
              children: [
                // Notifications section
                Container(
                  padding: const EdgeInsets.all(16),
                  child: CycleNotifications(cycle: _currentCycle!),
                ),
                
                // Calendar section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CycleCalendar(
                      cycle: _currentCycle!,
                      onDayTapped: _onDayTapped,
                    ),
                  ),
                ),
                
                // Bottom info section
                _buildBottomInfo(),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _onDayTapped(_currentCycle!.getCycleDay(DateTime.now())),
        icon: const Icon(Icons.favorite),
        label: const Text('Ajouter'),
        backgroundColor: AfricanColors.goldAccent,
        foregroundColor: AfricanColors.textPrimary,
      ),
    );
  }

  Widget _buildBottomInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: AfricanTheme.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Current phase info
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _currentCycle!.getCycleDayType(DateTime.now()).name == 'menstruation'
                        ? AfricanColors.menstruationColor.withOpacity(0.1)
                        : _currentCycle!.getCycleDayType(DateTime.now()).name == 'fertile'
                            ? AfricanColors.fertileColor.withOpacity(0.1)
                            : _currentCycle!.getCycleDayType(DateTime.now()).name == 'ovulation'
                                ? AfricanColors.ovulationColor.withOpacity(0.1)
                                : AfricanColors.safeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getPhaseIcon(_currentCycle!.getCycleDayType(DateTime.now())),
                    color: _getPhaseColor(_currentCycle!.getCycleDayType(DateTime.now())),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentCycle!.getCurrentPhaseDescription(),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _currentCycle!.getFertilityMessage(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AfricanColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Cycle stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Jour du cycle',
                    '${_currentCycle!.getCurrentCycleDay()}',
                    Icons.calendar_today,
                    AfricanColors.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Prochaines règles',
                    '${_currentCycle!.getDaysUntilNextPeriod()} jours',
                    Icons.schedule,
                    AfricanColors.warningOrange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AfricanColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getPhaseIcon(CycleDayType type) {
    switch (type) {
      case CycleDayType.menstruation:
        return Icons.water_drop;
      case CycleDayType.fertile:
        return Icons.eco;
      case CycleDayType.ovulation:
        return Icons.star;
      case CycleDayType.safe:
        return Icons.shield;
    }
  }

  Color _getPhaseColor(CycleDayType type) {
    switch (type) {
      case CycleDayType.menstruation:
        return AfricanColors.menstruationColor;
      case CycleDayType.fertile:
        return AfricanColors.fertileColor;
      case CycleDayType.ovulation:
        return AfricanColors.ovulationColor;
      case CycleDayType.safe:
        return AfricanColors.safeColor;
    }
  }
}