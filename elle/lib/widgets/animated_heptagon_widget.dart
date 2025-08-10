import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../screens/onboarding_flow.dart';
import '../theme/app_theme.dart';
import '../services/cycle_prediction_service.dart';

class AnimatedHeptagonWidget extends StatefulWidget {
  const AnimatedHeptagonWidget({Key? key}) : super(key: key);

  @override
  State<AnimatedHeptagonWidget> createState() => _AnimatedHeptagonWidgetState();
}

class _AnimatedHeptagonWidgetState extends State<AnimatedHeptagonWidget>
    with TickerProviderStateMixin {
  late AnimationController _primaryController;
  late AnimationController _rotationController;
  late AnimationController _textController;
  late AnimationController _pulseController;
  late AnimationController _breathingController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _textAnimation1;
  late Animation<double> _textAnimation2;
  late Animation<double> _textAnimation3;
  late Animation<double> _pulseAnimation;
  late Animation<double> _breathingAnimation;
  late Animation<double> _borderGlowAnimation;

  // Cycle data state
  DateTime? nextPeriodDate;
  int? daysUntil;
  bool isLoadingCycleData = true;
  bool hasCycleData = false;

  @override
  void initState() {
    super.initState();

    _primaryController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 20000),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _primaryController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.2,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _primaryController,
      curve: const Interval(0.1, 0.8, curve: Curves.elasticOut),
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _textAnimation1 = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
    ));

    _textAnimation2 = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
    ));

    _textAnimation3 = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _breathingAnimation = Tween<double>(
      begin: 0.98,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));

    _borderGlowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _primaryController.forward();
      _rotationController.repeat();
      _pulseController.repeat(reverse: true);
      _breathingController.repeat(reverse: true);

      Future.delayed(const Duration(milliseconds: 1000), () {
        _textController.forward();
      });
    });

    // Load cycle data
    _loadCycleData();
  }

  Future<void> _loadCycleData() async {
    try {
      final cycleData = await CyclePredictionService.loadCycleData();
      
      if (cycleData != null) {
        final lastPeriodDate = cycleData['lastPeriodDate'] as DateTime;
        final cycleDuration = cycleData['cycleDuration'] as int;
        
        // Calculate next period using the service
        final nextPeriod = CyclePredictionService.calculateNextPeriod(
          lastPeriodDate: lastPeriodDate,
          cycleDuration: cycleDuration,
        );
        
        final daysUntilPeriod = CyclePredictionService.daysUntilNextPeriod(nextPeriod);
        
        if (mounted) {
          setState(() {
            nextPeriodDate = nextPeriod;
            daysUntil = daysUntilPeriod;
            hasCycleData = true;
            isLoadingCycleData = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            hasCycleData = false;
            isLoadingCycleData = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          hasCycleData = false;
          isLoadingCycleData = false;
        });
      }
    }
  }

  String _getDisplayDate() {
    if (isLoadingCycleData) {
      return '...';
    }
    
    if (!hasCycleData) {
      return 'À configurer';
    }
    
    if (nextPeriodDate != null) {
      return CyclePredictionService.formatDateInFrench(nextPeriodDate!);
    }
    
    return 'Date inconnue';
  }
  
  String _getDescriptionText() {
    if (isLoadingCycleData) {
      return 'Chargement...';
    }
    
    if (!hasCycleData) {
      return 'Touchez ici pour\nconfigurer votre cycle';
    }
    
    if (daysUntil != null) {
      String daysText = CyclePredictionService.formatDaysUntilInFrench(daysUntil!);
      return 'Règles prévues\n$daysText';
    }
    
    return 'Touchez ici pour\nentrer vos données';
  }

  @override
  void dispose() {
    _primaryController.dispose();
    _rotationController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isSmallScreen = screenWidth < 350;
        final heptagonSize = isSmallScreen ? 280.0 : 320.0;

        return AnimatedBuilder(
          animation: Listenable.merge([
            _primaryController,
            _rotationController,
            _textController,
            _pulseController,
            _breathingController,
          ]),
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value * _breathingAnimation.value,
                child: GestureDetector(
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const OnboardingFlow(),
                      ),
                    );
                    // Refresh cycle data when returning from onboarding
                    _loadCycleData();
                  },
                  child: Container(
                    width: heptagonSize,
                    height: heptagonSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background glow effect
                      Container(
                        width: heptagonSize + 40,
                        height: heptagonSize + 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF69B4).withOpacity(0.1 * _borderGlowAnimation.value),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),

                      // Rotating heptagon
                      Transform.rotate(
                        angle: _rotationAnimation.value * 0.05,
                        child: Transform.scale(
                          scale: _pulseAnimation.value,
                          child: CustomPaint(
                            size: Size(heptagonSize, heptagonSize),
                            painter: EnhancedHeptagonPainter(
                              glowIntensity: _borderGlowAnimation.value,
                              pulseValue: _pulseAnimation.value,
                            ),
                          ),
                        ),
                      ),

                      // Centered text content
                      Container(
                        width: heptagonSize * 0.65,
                        height: heptagonSize * 0.65,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Next period text
                            Transform.translate(
                              offset: Offset(0, _textAnimation1.value * 15 - 15),
                              child: Opacity(
                                opacity: _textAnimation1.value,
                                child: Text(
                                  'Prochain cycle:',
                                  style: AppTheme.circleNextPeriodStyle.copyWith(
                                    fontSize: isSmallScreen ? 13 : 14,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),

                            SizedBox(height: isSmallScreen ? 8 : 10),

                            // Date text
                            Transform.translate(
                              offset: Offset(0, _textAnimation2.value * 15 - 15),
                              child: Opacity(
                                opacity: _textAnimation2.value,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF69B4).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _getDisplayDate(),
                                    style: AppTheme.circleDateStyle.copyWith(
                                      fontSize: isSmallScreen ? 26 : 30,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: isSmallScreen ? 8 : 10),

                            // Description text
                            Transform.translate(
                              offset: Offset(0, _textAnimation3.value * 15 - 15),
                              child: Opacity(
                                opacity: _textAnimation3.value,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    _getDescriptionText(),
                                    textAlign: TextAlign.center,
                                    style: AppTheme.circleDescriptionStyle.copyWith(
                                      fontSize: isSmallScreen ? 11 : 12,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0.3,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class EnhancedHeptagonPainter extends CustomPainter {
  final double glowIntensity;
  final double pulseValue;

  EnhancedHeptagonPainter({
    required this.glowIntensity,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 30;

    // Create gradient for the fill
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 0.8,
      colors: [
        const Color(0xFFFFEEF0),
        const Color(0xFFFFE4E6),
        const Color(0xFFFFD6DC),
      ],
      stops: const [0.0, 0.6, 1.0],
    );

    // Main heptagon path
    final path = Path();
    final vertices = <Offset>[];

    for (int i = 0; i < 7; i++) {
      final angle = (i * 2 * math.pi / 7) - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      vertices.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Draw outer glow
    final outerGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFF69B4).withOpacity(0.3 * glowIntensity),
          const Color(0xFFFF69B4).withOpacity(0.1 * glowIntensity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius + 20))
      ..style = PaintingStyle.fill;

    canvas.drawPath(_createExpandedPath(path, 15), outerGlowPaint);

    // Draw inner shadow
    final innerShadowPath = Path();
    for (int i = 0; i < 7; i++) {
      final angle = (i * 2 * math.pi / 7) - math.pi / 2;
      final x = center.dx + (radius - 8) * math.cos(angle);
      final y = center.dy + (radius - 8) * math.sin(angle);

      if (i == 0) {
        innerShadowPath.moveTo(x, y);
      } else {
        innerShadowPath.lineTo(x, y);
      }
    }
    innerShadowPath.close();

    final innerShadowPaint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, innerShadowPaint);

    // Draw animated border
    final borderPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFFF69B4).withOpacity(0.8),
          const Color(0xFFFF1493).withOpacity(0.9),
          const Color(0xFFFF69B4).withOpacity(0.8),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 + (pulseValue - 1) * 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, borderPaint);

    // Draw corner highlights
    final highlightPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.7)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 7; i++) {
      final vertex = vertices[i];
      canvas.drawCircle(vertex, 3, highlightPaint);
    }

    // Draw subtle inner pattern
    final patternPaint = Paint()
      ..color = const Color(0xFFFF69B4).withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final innerRadius = radius * 0.6;
    final innerPath = Path();

    for (int i = 0; i < 7; i++) {
      final angle = (i * 2 * math.pi / 7) - math.pi / 2;
      final x = center.dx + innerRadius * math.cos(angle);
      final y = center.dy + innerRadius * math.sin(angle);

      if (i == 0) {
        innerPath.moveTo(x, y);
      } else {
        innerPath.lineTo(x, y);
      }
    }
    innerPath.close();

    canvas.drawPath(innerPath, patternPaint);
  }

  Path _createExpandedPath(Path originalPath, double expansion) {
    final bounds = originalPath.getBounds();
    final center = bounds.center;
    final matrix = Matrix4.identity();

    matrix.translate(center.dx, center.dy);
    matrix.scale(1.0 + expansion / bounds.width);
    matrix.translate(-center.dx, -center.dy);

    return originalPath.transform(matrix.storage);
  }

  @override
  bool shouldRepaint(covariant EnhancedHeptagonPainter oldDelegate) {
    return oldDelegate.glowIntensity != glowIntensity ||
        oldDelegate.pulseValue != pulseValue;
  }
}