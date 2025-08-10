import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/week_calendar_widget.dart';
import '../widgets/ce_mois_ci_widget.dart';
import '../widgets/symptoms_section.dart';
import '../widgets/discovery_grid.dart';
import '../widgets/consultation_cards.dart';
import '../widgets/notification_icon.dart';
import 'shop_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Start animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.screenBackground,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: AnimationLimiter(
              child: Column(
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 300),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    verticalOffset: 30.0,
                    child: FadeInAnimation(
                      child: widget,
                    ),
                  ),
                  children: [
                    // Header Section (full width)
                    _buildHeader(),
                    
                    // Main content with padding
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          
                          // Week Calendar Section
                          const WeekCalendarWidget(),

                          const SizedBox(height: 16),
                          
                          // Ce mois-ci Section
                          const CeMoisCiWidget(),

                          // Symptoms Section
                          const SymptomsSection(),
                          
                          // const SizedBox(height: 24),
                          
                          // Discovery Grid Section
                          const DiscoveryGrid(),
                          
                          const SizedBox(height: 24),
                          
                          // Consultation Cards Section
                          const ConsultationCards(),
                          
                          // Bottom spacing
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final currentDate = DateTime.now();
    final monthYear = DateFormat('MMMM yyyy', 'fr_FR').format(currentDate);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppTheme.headerBackground,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side - Greeting
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bonjour Anita',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.greetingText,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Text(
                monthYear.replaceFirst(monthYear[0], monthYear[0].toUpperCase()),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.dateText,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          
          // Right side - Icons
          Row(
            children: [
              // Shopping bag icon with badge
              NotificationIcon(
                icon: Icons.shopping_bag_outlined,
                badgeCount: 6,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ShopScreen()),
                ),
              ),
              const SizedBox(width: 16),
              
              // Notification bell icon with badge
              NotificationIcon(
                icon: Icons.notifications_outlined,
                badgeCount: 2,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}