import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/cycle_data_manager.dart';

class CycleProgressWidget extends StatefulWidget {
  final bool showFertileWindow;
  final bool showPhaseDetails;
  final double height;

  const CycleProgressWidget({
    Key? key,
    this.showFertileWindow = true,
    this.showPhaseDetails = true,
    this.height = 200,
  }) : super(key: key);

  @override
  State<CycleProgressWidget> createState() => _CycleProgressWidgetState();
}

class _CycleProgressWidgetState extends State<CycleProgressWidget>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  CycleData? cycleData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _loadCycleData();
  }

  Future<void> _loadCycleData() async {
    final result = await CycleDataManager.instance.loadCycleData();
    
    if (result.isSuccess && result.data != null) {
      setState(() {
        cycleData = result.data;
        isLoading = false;
      });
      
      _progressController.forward();
      
      // Start pulse animation if in fertile window
      if (result.data!.isInFertileWindow) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isLoading 
          ? _buildLoadingState()
          : cycleData != null 
              ? _buildCycleProgress()
              : _buildNoCycleData(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFFE91E63),
      ),
    );
  }

  Widget _buildNoCycleData() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune donnée de cycle',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Configurez votre cycle pour voir le suivi',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 20),
        Expanded(
          child: _buildCircularProgress(),
        ),
        if (widget.showPhaseDetails) ...[
          const SizedBox(height: 20),
          _buildPhaseIndicators(),
        ],
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Suivi du cycle',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            Text(
              'Jour ${_getCurrentCycleDay()} de ${cycleData!.cycleDuration}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        if (cycleData!.isInFertileWindow)
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '💮',
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Fertile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildCircularProgress() {
    return Center(
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          return CustomPaint(
            size: const Size(140, 140),
            painter: CycleProgressPainter(
              progress: cycleData!.cycleProgress * _progressAnimation.value,
              fertileWindow: widget.showFertileWindow ? _getFertileWindowProgress() : null,
              currentPhase: cycleData!.currentPhase,
              isInFertileWindow: cycleData!.isInFertileWindow,
            ),
            child: SizedBox(
              width: 140,
              height: 140,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(cycleData!.cycleProgress * _progressAnimation.value * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE91E63),
                      ),
                    ),
                    Text(
                      _getPhaseDisplayName(cycleData!.currentPhase),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhaseIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildPhaseIndicator('🩸', 'Règles', 'Menstrual'),
        _buildPhaseIndicator('🌱', 'Folliculaire', 'Follicular'),
        _buildPhaseIndicator('💮', 'Fertile', 'Fertile'),
        _buildPhaseIndicator('🥚', 'Ovulation', 'Ovulation'),
        _buildPhaseIndicator('🌙', 'Lutéale', 'Luteal'),
      ],
    );
  }

  Widget _buildPhaseIndicator(String emoji, String label, String phase) {
    final isCurrentPhase = cycleData!.currentPhase == phase;
    
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCurrentPhase 
                ? const Color(0xFFE91E63).withOpacity(0.1)
                : Colors.transparent,
            shape: BoxShape.circle,
            border: isCurrentPhase 
                ? Border.all(color: const Color(0xFFE91E63), width: 2)
                : null,
          ),
          child: Center(
            child: Text(
              emoji,
              style: TextStyle(
                fontSize: isCurrentPhase ? 20 : 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isCurrentPhase 
                ? const Color(0xFFE91E63) 
                : Colors.grey[600],
            fontWeight: isCurrentPhase 
                ? FontWeight.w600 
                : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  int _getCurrentCycleDay() {
    final daysSinceLastPeriod = DateTime.now()
        .difference(cycleData!.lastPeriodDate)
        .inDays + 1;
    return daysSinceLastPeriod > 0 ? daysSinceLastPeriod : 1;
  }

  List<double>? _getFertileWindowProgress() {
    if (cycleData == null) return null;
    
    final cycleDays = cycleData!.cycleDuration;
    final fertileStart = (cycleDays / 2 - 6) / cycleDays; // ~6 days before ovulation
    final fertileEnd = (cycleDays / 2 + 1) / cycleDays;   // ~1 day after ovulation
    
    return [fertileStart, fertileEnd];
  }

  String _getPhaseDisplayName(String phase) {
    switch (phase) {
      case 'Menstrual':
        return 'Règles';
      case 'Follicular':
        return 'Folliculaire';
      case 'Fertile':
        return 'Fertile';
      case 'Ovulation':
        return 'Ovulation';
      case 'Luteal':
        return 'Lutéale';
      default:
        return 'Phase';
    }
  }
}

class CycleProgressPainter extends CustomPainter {
  final double progress;
  final List<double>? fertileWindow;
  final String currentPhase;
  final bool isInFertileWindow;

  CycleProgressPainter({
    required this.progress,
    this.fertileWindow,
    required this.currentPhase,
    required this.isInFertileWindow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw fertile window if enabled
    if (fertileWindow != null && fertileWindow!.length == 2) {
      final fertileStartAngle = fertileWindow![0] * 2 * math.pi - math.pi / 2;
      final fertileEndAngle = fertileWindow![1] * 2 * math.pi - math.pi / 2;
      final fertileSweepAngle = fertileEndAngle - fertileStartAngle;

      final fertilePaint = Paint()
        ..color = const Color(0xFF4CAF50).withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        fertileStartAngle,
        fertileSweepAngle,
        false,
        fertilePaint,
      );
    }

    // Draw progress arc
    final progressPaint = Paint()
      ..color = _getPhaseColor(currentPhase)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final sweepAngle = progress * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // Draw current position indicator
    if (progress > 0) {
      final angle = progress * 2 * math.pi - math.pi / 2;
      final indicatorX = center.dx + radius * math.cos(angle);
      final indicatorY = center.dy + radius * math.sin(angle);

      final indicatorPaint = Paint()
        ..color = _getPhaseColor(currentPhase)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(indicatorX, indicatorY),
        6,
        indicatorPaint,
      );

      // Draw white inner circle for indicator
      final innerIndicatorPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(indicatorX, indicatorY),
        3,
        innerIndicatorPaint,
      );
    }
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
        return const Color(0xFFE91E63);
    }
  }

  @override
  bool shouldRepaint(covariant CycleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.currentPhase != currentPhase ||
        oldDelegate.isInFertileWindow != isInFertileWindow;
  }
}