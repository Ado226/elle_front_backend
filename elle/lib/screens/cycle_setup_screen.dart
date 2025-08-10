import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/cycle_model.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';
import 'cycle_tracking_screen.dart';

class CycleSetupScreen extends StatefulWidget {
  const CycleSetupScreen({Key? key}) : super(key: key);

  @override
  State<CycleSetupScreen> createState() => _CycleSetupScreenState();
}

class _CycleSetupScreenState extends State<CycleSetupScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();

  // Enhanced animation controllers
  late AnimationController _animationController;
  late AnimationController _backgroundController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  late AnimationController _stepController;
  late AnimationController _particleController;
  late AnimationController _shimmerController;
  late AnimationController _breathingController;
  late AnimationController _rippleController;
  late AnimationController _glowController;
  late AnimationController _slideController;

  // Enhanced animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _stepAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _breathingAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<Offset> _cardSlideAnimation;
  late Animation<double> _headerFadeAnimation;
  late Animation<double> _progressAnimation;

  DateTime _startDate = DateTime.now();
  int _cycleLength = 28;
  int _menstruationLength = 5;
  bool _isLoading = false;
  int _currentStep = 0;
  final int _totalSteps = 3;

  @override
  void initState() {
    super.initState();
    _setupEnhancedAnimations();
  }

  void _setupEnhancedAnimations() {
    // Primary animation controllers
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _floatingController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    _stepController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Enhanced animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * pi,
    ).animate(_backgroundController);

    _pulseAnimation = Tween<double>(
      begin: 0.85,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _stepAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _stepController,
      curve: Curves.elasticOut,
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_particleController);

    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    _breathingAnimation = Tween<double>(
      begin: 0.98,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _headerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
    ));

    // Start animations with staggered timing
    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _backgroundController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    _stepController.dispose();
    _particleController.dispose();
    _shimmerController.dispose();
    _breathingController.dispose();
    _rippleController.dispose();
    _glowController.dispose();
    _slideController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    HapticFeedback.lightImpact();
    _rippleController.forward().then((_) => _rippleController.reset());
    
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _stepController.forward();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _saveCycle();
    }
  }

  void _previousStep() {
    HapticFeedback.lightImpact();
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _stepController.reverse();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    HapticFeedback.selectionClick();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF6B73FF),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: const Color(0xFF2D3748),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _saveCycle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final cycleCreate = CycleCreate(
        userId: 1,
        startDate: _startDate,
        cycleLength: _cycleLength,
        menstruationLength: _menstruationLength,
      );

      await ApiService.createCycle(cycleCreate);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const CycleTrackingScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCubic,
                )),
                child: FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(
                      begin: 0.9,
                      end: 1.0,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOut,
                    )),
                    child: child,
                  ),
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 1200),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showEnhancedSnackBar(
          'Erreur: ${e.toString()}',
          const Color(0xFFFF6B6B),
          Icons.error_outline,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showEnhancedSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        elevation: 8,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667EEA),
              Color(0xFF764BA2),
              Color(0xFFFF6B6B),
              Color(0xFF4ECDC4),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Enhanced animated background with particles
              _buildAdvancedAnimatedBackground(),

              // Main content with enhanced animations
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Column(
                      children: [
                        // Enhanced header with glassmorphism
                        _buildFuturisticHeader(),

                        // Advanced progress indicator
                        _buildAdvancedProgressIndicator(),

                        // Page view with enhanced transitions
                        Expanded(
                          child: PageView(
                            controller: _pageController,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _buildEnhancedDateStep(),
                              _buildEnhancedCycleLengthStep(),
                              _buildEnhancedMenstruationLengthStep(),
                            ],
                          ),
                        ),

                        // Enhanced navigation buttons
                        _buildEnhancedNavigationButtons(),
                      ],
                    ),
                  );
                },
              ),

              // Floating action elements
              _buildFloatingElements(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Stack(
          children: [
            // Animated gradient overlay with movement
            AnimatedBuilder(
              animation: _backgroundController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF667EEA).withOpacity(0.1),
                        const Color(0xFF764BA2).withOpacity(0.05),
                        const Color(0xFFFF6B6B).withOpacity(0.1),
                        const Color(0xFF4ECDC4).withOpacity(0.05),
                      ],
                      stops: [
                        (sin(_backgroundController.value * 2 * pi) + 1) / 8,
                        (cos(_backgroundController.value * 2 * pi) + 1) / 6,
                        (sin(_backgroundController.value * 2 * pi + pi) + 1) / 4,
                        (cos(_backgroundController.value * 2 * pi + pi) + 1) / 2,
                      ],
                    ),
                  ),
                );
              },
            ),

            // Enhanced floating orbs with particle effects
            ...List.generate(8, (index) => _buildEnhancedFloatingOrb(index)),
            
            // Particle system
            _buildParticleSystem(),
          ],
        );
      },
    );
  }

  Widget _buildEnhancedFloatingOrb(int index) {
    final positions = [
      const Offset(0.85, 0.1),
      const Offset(0.05, 0.25),
      const Offset(0.95, 0.4),
      const Offset(0.1, 0.6),
      const Offset(0.8, 0.75),
      const Offset(0.3, 0.85),
      const Offset(0.7, 0.15),
      const Offset(0.4, 0.45),
    ];

    final sizes = [70.0, 50.0, 90.0, 35.0, 60.0, 40.0, 80.0, 45.0];
    final speeds = [1.0, 1.8, 0.6, 2.2, 1.3, 2.0, 0.8, 1.5];
    final colors = [
      Colors.white.withOpacity(0.15),
      Colors.white.withOpacity(0.12),
      Colors.white.withOpacity(0.18),
      Colors.white.withOpacity(0.10),
      Colors.white.withOpacity(0.16),
      Colors.white.withOpacity(0.14),
      Colors.white.withOpacity(0.11),
      Colors.white.withOpacity(0.13),
    ];

    return Positioned(
      top: MediaQuery.of(context).size.height * positions[index].dy,
      left: MediaQuery.of(context).size.width * positions[index].dx,
      child: AnimatedBuilder(
        animation: Listenable.merge([_floatingController, _pulseController, _breathingController]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              sin(_floatingController.value * 2 * pi * speeds[index]) * 25,
              cos(_floatingController.value * 2 * pi * speeds[index]) * 20,
            ),
            child: Transform.scale(
              scale: _breathingAnimation.value * (0.8 + (_pulseAnimation.value - 0.8) * 0.4),
              child: Container(
                width: sizes[index],
                height: sizes[index],
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colors[index],
                      colors[index].withOpacity(0.5),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors[index],
                      blurRadius: 15,
                      spreadRadius: 2,
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

  Widget _buildParticleSystem() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return Stack(
          children: List.generate(20, (index) {
            final progress = (_particleController.value + index * 0.1) % 1.0;
            final x = (index % 5) / 4.0 * MediaQuery.of(context).size.width;
            final y = progress * MediaQuery.of(context).size.height;
            final opacity = (1.0 - progress) * 0.3;
            
            return Positioned(
              left: x,
              top: y,
              child: Container(
                width: 3,
                height: 3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(opacity),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildFuturisticHeader() {
    return AnimatedBuilder(
      animation: _headerFadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _headerFadeAnimation.value) * -50),
          child: Opacity(
            opacity: _headerFadeAnimation.value,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.4),
                      Colors.white.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Animated icon with glow effect
                        AnimatedBuilder(
                          animation: _glowController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF6B73FF).withOpacity(_glowAnimation.value),
                                      const Color(0xFF9644F4).withOpacity(_glowAnimation.value),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6B73FF).withOpacity(0.6 * _glowAnimation.value),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ShaderMask(
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                      colors: [
                                        Colors.white,
                                        Colors.white.withOpacity(0.8),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds);
                                  },
                                  child: const Icon(
                                    Icons.auto_awesome,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 24),
                        // Animated text with shimmer effect
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedBuilder(
                                animation: _shimmerAnimation,
                                builder: (context, child) {
                                  return ShaderMask(
                                    shaderCallback: (bounds) {
                                      return LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.6),
                                          Colors.white,
                                          Colors.white.withOpacity(0.9),
                                          Colors.white,
                                          Colors.white.withOpacity(0.6),
                                        ],
                                        stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
                                        begin: Alignment(_shimmerAnimation.value - 1, 0),
                                        end: Alignment(_shimmerAnimation.value, 0),
                                      ).createShader(bounds);
                                    },
                                    child: const Text(
                                      'Bienvenue sur Elles',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.8,
                                        height: 1.1,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Configuration personnalisée intelligente',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
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
        );
      },
    );
  }

  Widget _buildAdvancedProgressIndicator() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _progressAnimation.value) * 30),
          child: Opacity(
            opacity: _progressAnimation.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.timeline,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Étape ${_currentStep + 1} sur $_totalSteps',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6B73FF), Color(0xFF9644F4)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${((_currentStep + 1) / _totalSteps * 100).round()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Enhanced progress bar with animation
                    Stack(
                      children: [
                        Container(
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeInOutCubic,
                          height: 10,
                          width: MediaQuery.of(context).size.width * 0.85 * ((_currentStep + 1) / _totalSteps),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6B73FF), Color(0xFF9644F4)],
                            ),
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6B73FF).withOpacity(0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Step indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_totalSteps, (index) {
                        final isActive = index <= _currentStep;
                        final isCurrent = index == _currentStep;
                        
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isCurrent ? 32 : 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: isCurrent ? [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ] : null,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedDateStep() {
    return AnimatedBuilder(
      animation: _cardSlideAnimation,
      builder: (context, child) {
        return SlideTransition(
          position: _cardSlideAnimation,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: AnimationConfiguration.staggeredList(
              position: 0,
              duration: const Duration(milliseconds: 800),
              child: SlideAnimation(
                verticalOffset: 80.0,
                child: FadeInAnimation(
                  child: _buildAdvancedGlassCard(
                    icon: Icons.calendar_today,
                    iconGradient: const LinearGradient(
                      colors: [Color(0xFF6B73FF), Color(0xFF9644F4)],
                    ),
                    title: 'Date de début des dernières règles',
                    subtitle: 'Sélectionnez la date du premier jour de vos dernières règles',
                    child: GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.25),
                              Colors.white.withOpacity(0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.4)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _getDateText(),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.edit_calendar,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedCycleLengthStep() {
    return AnimatedBuilder(
      animation: _cardSlideAnimation,
      builder: (context, child) {
        return SlideTransition(
          position: _cardSlideAnimation,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: AnimationConfiguration.staggeredList(
              position: 1,
              duration: const Duration(milliseconds: 800),
              child: SlideAnimation(
                verticalOffset: 80.0,
                child: FadeInAnimation(
                  child: _buildAdvancedGlassCard(
                    icon: Icons.repeat,
                    iconGradient: const LinearGradient(
                      colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                    ),
                    title: 'Durée moyenne du cycle',
                    subtitle: 'Ajustez selon votre cycle personnel (21-35 jours)',
                    child: Column(
                      children: [
                        // Value display with enhanced styling
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4ECDC4).withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.access_time,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '$_cycleLength',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 32,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'jours',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Enhanced slider
                        _buildEnhancedSlider(
                          value: _cycleLength.toDouble(),
                          min: 21,
                          max: 35,
                          divisions: 14,
                          activeColor: const Color(0xFF4ECDC4),
                          onChanged: (value) {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _cycleLength = value.round();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedMenstruationLengthStep() {
    return AnimatedBuilder(
      animation: _cardSlideAnimation,
      builder: (context, child) {
        return SlideTransition(
          position: _cardSlideAnimation,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: AnimationConfiguration.staggeredList(
              position: 2,
              duration: const Duration(milliseconds: 800),
              child: SlideAnimation(
                verticalOffset: 80.0,
                child: FadeInAnimation(
                  child: _buildAdvancedGlassCard(
                    icon: Icons.water_drop,
                    iconGradient: const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
                    ),
                    title: 'Durée des règles',
                    subtitle: 'Nombre de jours de flux menstruel (3-8 jours)',
                    child: Column(
                      children: [
                        // Value display with enhanced styling
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF6B6B).withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.water_drop,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '$_menstruationLength',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 32,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'jours',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Enhanced slider
                        _buildEnhancedSlider(
                          value: _menstruationLength.toDouble(),
                          min: 3,
                          max: 8,
                          divisions: 5,
                          activeColor: const Color(0xFFFF6B6B),
                          onChanged: (value) {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _menstruationLength = value.round();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedSlider({
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Color activeColor,
    required Function(double) onChanged,
  }) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: Colors.white.withOpacity(0.8),
        inactiveTrackColor: Colors.white.withOpacity(0.3),
        thumbColor: activeColor,
        overlayColor: activeColor.withOpacity(0.2),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 16),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 28),
        trackHeight: 8,
      ),
      child: Column(
        children: [
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSliderLabel('${min.round()} jours'),
              _buildSliderLabel('${max.round()} jours'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSliderLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAdvancedGlassCard({
    required IconData icon,
    required LinearGradient iconGradient,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: iconGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: iconGradient.colors.first.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 28),
                    ),
                  );
                },
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          child,
        ],
      ),
    );
  }

  Widget _buildEnhancedNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: _buildFuturisticButton(
                onPressed: _previousStep,
                text: 'Précédent',
                icon: Icons.arrow_back,
                isPrimary: false,
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: _currentStep > 0 ? 1 : 2,
            child: _buildFuturisticButton(
              onPressed: _isLoading ? null : _nextStep,
              text: _currentStep == _totalSteps - 1 ? 'Terminer' : 'Suivant',
              icon: _currentStep == _totalSteps - 1 ? Icons.check_circle : Icons.arrow_forward,
              isPrimary: true,
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFuturisticButton({
    required VoidCallback? onPressed,
    required String text,
    required IconData icon,
    required bool isPrimary,
    bool isLoading = false,
  }) {
    return AnimatedBuilder(
      animation: _rippleAnimation,
      builder: (context, child) {
        return Container(
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: isPrimary && !isLoading ? [
              BoxShadow(
                color: const Color(0xFF6B73FF).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ] : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  gradient: isPrimary
                      ? (isLoading
                          ? LinearGradient(
                              colors: [
                                Colors.grey.withOpacity(0.4),
                                Colors.grey.withOpacity(0.3),
                              ],
                            )
                          : const LinearGradient(
                              colors: [Color(0xFF6B73FF), Color(0xFF9644F4)],
                            ))
                      : LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.3),
                            Colors.white.withOpacity(0.2),
                          ],
                        ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isPrimary ? Colors.transparent : Colors.white.withOpacity(0.4),
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    // Ripple effect
                    if (isPrimary && _rippleAnimation.value > 0)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3 * (1 - _rippleAnimation.value)),
                              width: 2 * _rippleAnimation.value,
                            ),
                          ),
                        ),
                      ),
                    // Button content
                    Center(
                      child: isLoading
                          ? const SizedBox(
                              height: 28,
                              width: 28,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (!isPrimary) ...[
                                  Icon(icon, color: Colors.white, size: 22),
                                  const SizedBox(width: 12),
                                ],
                                Text(
                                  text,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                if (isPrimary) ...[
                                  const SizedBox(width: 12),
                                  Icon(icon, color: Colors.white, size: 22),
                                ],
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
  }

  Widget _buildFloatingElements() {
    return Positioned(
      top: 100,
      right: 20,
      child: AnimatedBuilder(
        animation: _floatingController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              sin(_floatingController.value * 2 * pi) * 10,
              cos(_floatingController.value * 2 * pi) * 15,
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: const Icon(
                Icons.auto_graph,
                color: Colors.white,
                size: 24,
              ),
            ),
          );
        },
      ),
    );
  }

  String _getDateText() {
    final now = DateTime.now();
    final difference = now.difference(_startDate).inDays;

    if (difference == 0) {
      return "Aujourd'hui";
    } else if (difference == 1) {
      return "Hier";
    } else if (difference < 7) {
      return "Il y a $difference jours";
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return "Il y a ${weeks == 1 ? '1 semaine' : '$weeks semaines'}";
    } else {
      final months = (difference / 30).floor();
      return "Il y a ${months == 1 ? '1 mois' : '$months mois'}";
    }
  }
}