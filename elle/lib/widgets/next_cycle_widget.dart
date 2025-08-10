import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/cycle_prediction_service.dart';
import '../screens/onboarding_flow.dart';

class NextCycleWidget extends StatefulWidget {
  const NextCycleWidget({Key? key}) : super(key: key);

  @override
  State<NextCycleWidget> createState() => _NextCycleWidgetState();
}

class _NextCycleWidgetState extends State<NextCycleWidget> {
  DateTime? nextPeriodDate;
  DateTime? lastPeriodDate;
  int? daysUntil;
  int? cycleDuration;
  bool isLoading = true;
  bool hasCycleData = false;
  String currentPhase = '';
  double cycleProgress = 0.0;
  List<DateTime> fertileWindow = [];

  @override
  void initState() {
    super.initState();
    _loadCycleData();
  }

  /// Public method to refresh cycle data
  void refreshData() {
    _loadCycleData();
  }

  Future<void> _loadCycleData() async {
    try {
      final cycleData = await CyclePredictionService.loadCycleData();
      
      if (cycleData != null) {
        final lastPeriod = cycleData['lastPeriodDate'] as DateTime;
        final cycleDur = cycleData['cycleDuration'] as int;
        
        // Calculate next period and related data
        final nextPeriod = CyclePredictionService.calculateNextPeriod(
          lastPeriodDate: lastPeriod,
          cycleDuration: cycleDur,
        );
        
        final daysUntilPeriod = CyclePredictionService.daysUntilNextPeriod(nextPeriod);
        final phase = CyclePredictionService.getCurrentCyclePhase(
          lastPeriodDate: lastPeriod,
          cycleDuration: cycleDur,
        );
        final progress = CyclePredictionService.getCycleProgress(
          lastPeriodDate: lastPeriod,
          cycleDuration: cycleDur,
        );
        final fertile = CyclePredictionService.calculateFertileWindow(nextPeriod);
        
        if (mounted) {
          setState(() {
            nextPeriodDate = nextPeriod;
            lastPeriodDate = lastPeriod;
            daysUntil = daysUntilPeriod;
            cycleDuration = cycleDur;
            currentPhase = phase;
            cycleProgress = progress;
            fertileWindow = fertile;
            hasCycleData = true;
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            hasCycleData = false;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          hasCycleData = false;
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE91E63), Color(0xFFFC407F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E63).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          
          if (isLoading)
            _buildLoadingState()
          else if (hasCycleData)
            _buildCycleInfo()
          else
            _buildNoCycleData(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '🩸',
            style: TextStyle(fontSize: 20),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Prochain cycle',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildCycleInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Next period date and days until
        _buildPeriodInfo(),
        const SizedBox(height: 16),
        
        // Cycle progress bar
        _buildProgressBar(),
        const SizedBox(height: 16),
        
        // Current cycle phase
        _buildPhaseInfo(),
        const SizedBox(height: 16),
        
        // Fertile window info
        if (_isInFertileWindow())
          _buildFertileWindowInfo(),
      ],
    );
  }

  Widget _buildPeriodInfo() {
    String dateText = CyclePredictionService.formatDateInFrench(nextPeriodDate!);
    String daysText = CyclePredictionService.formatDaysUntilInFrench(daysUntil!);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.calendar_today,
              color: Colors.white70,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              dateText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          daysText,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progression du cycle',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(cycleProgress * 100).round()}%',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: cycleProgress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhaseInfo() {
    Color phaseColor = _getPhaseColor(currentPhase);
    String phaseIcon = _getPhaseIcon(currentPhase);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            phaseIcon,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phase actuelle',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                Text(
                  _getPhaseName(currentPhase),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFertileWindowInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Text(
            '💮',
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fenêtre fertile',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                const Text(
                  'Période de fertilité élevée',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoCycleData() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configurez votre cycle',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Commencez à suivre vos règles pour des prédictions personnalisées',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const OnboardingFlow(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFE91E63),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Commencer',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _isInFertileWindow() {
    if (lastPeriodDate == null || cycleDuration == null) return false;
    
    return CyclePredictionService.isInFertileWindow(
      lastPeriodDate: lastPeriodDate!,
      cycleDuration: cycleDuration!,
    );
  }

  Color _getPhaseColor(String phase) {
    switch (phase) {
      case 'Menstrual':
        return const Color(0xFFE91E63);
      case 'Follicular':
        return const Color(0xFF2196F3);
      case 'Fertile':
      case 'Ovulation':
        return const Color(0xFF4CAF50);
      case 'Luteal':
        return const Color(0xFFFF9800);
      default:
        return Colors.grey;
    }
  }

  String _getPhaseIcon(String phase) {
    switch (phase) {
      case 'Menstrual':
        return '🩸';
      case 'Follicular':
        return '🌱';
      case 'Fertile':
        return '💮';
      case 'Ovulation':
        return '🥚';
      case 'Luteal':
        return '🌙';
      default:
        return '📅';
    }
  }

  String _getPhaseName(String phase) {
    switch (phase) {
      case 'Menstrual':
        return 'Menstruation';
      case 'Follicular':
        return 'Phase folliculaire';
      case 'Fertile':
        return 'Fenêtre fertile';
      case 'Ovulation':
        return 'Ovulation';
      case 'Luteal':
        return 'Phase lutéale';
      default:
        return 'Phase inconnue';
    }
  }
}