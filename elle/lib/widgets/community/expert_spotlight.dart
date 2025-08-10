import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../theme/app_theme.dart';
import '../../core/models/community.dart';

class ExpertSpotlight extends StatefulWidget {
  final CommunityUser? expert;
  final Duration animationDelay;
  
  const ExpertSpotlight({
    Key? key,
    this.expert,
    this.animationDelay = Duration.zero,
  }) : super(key: key);

  @override
  State<ExpertSpotlight> createState() => _ExpertSpotlightState();
}

class _ExpertSpotlightState extends State<ExpertSpotlight>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _carouselController;
  late PageController _pageController;
  
  int _currentIndex = 0;
  late List<Expert> _experts;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeExperts();
    _startAutoCarousel();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _carouselController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pageController = PageController(
      viewportFraction: 0.85,
      initialPage: 0,
    );

    _animationController.forward();
  }

  void _initializeExperts() {
    _experts = [
      Expert(
        id: '1',
        name: 'Dr. Aminata Traoré',
        specialty: 'Gynécologue',
        location: 'Abidjan, Côte d\'Ivoire',
        experience: '15 ans d\'expérience',
        description: 'Spécialisée en santé reproductive et contraception moderne.',
        avatar: 'assets/images/expert1.jpg',
        rating: 4.9,
        consultations: 1500,
        isVerified: true,
        availableForChat: true,
      ),
      Expert(
        id: '2',
        name: 'Dr. Fatoumata Keita',
        specialty: 'Nutritionniste',
        location: 'Ouagadougou, Burkina Faso',
        experience: '12 ans d\'expérience',
        description: 'Experte en nutrition pendant la grossesse et l\'allaitement.',
        avatar: 'assets/images/expert2.jpg',
        rating: 4.8,
        consultations: 980,
        isVerified: true,
        availableForChat: false,
      ),
      Expert(
        id: '3',
        name: 'Dr. Mariam Coulibaly',
        specialty: 'Psychologue',
        location: 'Bamako, Mali',
        experience: '10 ans d\'expérience',
        description: 'Accompagnement psychologique et sexologie.',
        avatar: 'assets/images/expert3.jpg',
        rating: 4.7,
        consultations: 750,
        isVerified: true,
        availableForChat: true,
      ),
    ];
  }

  void _startAutoCarousel() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _nextPage();
        _startAutoCarousel();
      }
    });
  }

  void _nextPage() {
    if (_currentIndex < _experts.length - 1) {
      _currentIndex++;
    } else {
      _currentIndex = 0;
    }
    
    _pageController.animateToPage(
      _currentIndex,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _carouselController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nos Expertes',
                      style: AppTheme.sectionTitleStyle.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Consultez nos professionnelles de santé',
                      style: AppTheme.captionStyle.copyWith(
                        color: AppTheme.lightGray,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => _showAllExperts(),
                  child: Text(
                    'Voir tout',
                    style: AppTheme.bodyTextStyle.copyWith(
                      color: AppTheme.primaryPink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Expert cards carousel
          SizedBox(
            height: 220,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemCount: _experts.length,
                  itemBuilder: (context, index) {
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        horizontalOffset: 50.0,
                        child: FadeInAnimation(
                          child: ExpertCard(
                            expert: _experts[index],
                            isActive: index == _currentIndex,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _experts.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: index == _currentIndex ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: index == _currentIndex 
                      ? AppTheme.primaryPink
                      : AppTheme.lightGray.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAllExperts() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.lightGray,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Toutes nos expertes',
                        style: AppTheme.headerStyle.copyWith(fontSize: 18),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                
                // Experts list
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _experts.length,
                    itemBuilder: (context, index) {
                      return ExpertListTile(expert: _experts[index]);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ExpertCard extends StatefulWidget {
  final Expert expert;
  final bool isActive;

  const ExpertCard({
    Key? key,
    required this.expert,
    this.isActive = false,
  }) : super(key: key);

  @override
  State<ExpertCard> createState() => _ExpertCardState();
}

class _ExpertCardState extends State<ExpertCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _hoverController.forward(),
            onTapUp: (_) => _hoverController.reverse(),
            onTapCancel: () => _hoverController.reverse(),
            onTap: () => _showExpertDetail(context),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isActive 
                      ? AppTheme.primaryPink
                      : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar and status
                  Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppTheme.primaryPink,
                            child: Text(
                              widget.expert.name.split(' ').map((n) => n[0]).join(),
                              style: AppTheme.bodyTextStyle.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (widget.expert.isVerified)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      
                      const SizedBox(width: 12),
                      
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.expert.name,
                              style: AppTheme.bodyTextStyle.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              widget.expert.specialty,
                              style: AppTheme.captionStyle.copyWith(
                                color: AppTheme.primaryPink,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      if (widget.expert.availableForChat)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Description
                  Text(
                    widget.expert.description,
                    style: AppTheme.captionStyle.copyWith(
                      color: AppTheme.mediumGray,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem(
                        Icons.star,
                        widget.expert.rating.toString(),
                        Colors.amber,
                      ),
                      _buildStatItem(
                        Icons.people,
                        '${widget.expert.consultations}',
                        AppTheme.primaryPink,
                      ),
                      _buildStatItem(
                        Icons.location_on,
                        widget.expert.location.split(',')[0],
                        AppTheme.mediumGray,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Action button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showExpertDetail(context),
                      style: AppTheme.primaryButtonStyle.copyWith(
                        minimumSize: MaterialStateProperty.all(const Size(0, 36)),
                      ),
                      child: Text(
                        'Consulter',
                        style: AppTheme.buttonTextStyle.copyWith(fontSize: 14),
                      ),
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

  Widget _buildStatItem(IconData icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: AppTheme.captionStyle.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _showExpertDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExpertDetailSheet(expert: widget.expert),
    );
  }
}

class ExpertListTile extends StatelessWidget {
  final Expert expert;

  const ExpertListTile({Key? key, required this.expert}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.primaryPink,
            child: Text(
              expert.name.split(' ').map((n) => n[0]).join(),
              style: AppTheme.bodyTextStyle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expert.name, style: AppTheme.bodyTextStyle.copyWith(fontWeight: FontWeight.w600)),
                Text(expert.specialty, style: AppTheme.captionStyle.copyWith(color: AppTheme.primaryPink)),
                Text(expert.experience, style: AppTheme.captionStyle),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.lightGray),
        ],
      ),
    );
  }
}

class ExpertDetailSheet extends StatelessWidget {
  final Expert expert;

  const ExpertDetailSheet({Key? key, required this.expert}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Expert info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppTheme.primaryPink,
                        child: Text(
                          expert.name.split(' ').map((n) => n[0]).join(),
                          style: AppTheme.headerStyle.copyWith(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(expert.name, style: AppTheme.subHeaderStyle),
                            Text(expert.specialty, style: AppTheme.bodyTextStyle.copyWith(color: AppTheme.primaryPink)),
                            Text(expert.experience, style: AppTheme.captionStyle),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Text(expert.description, style: AppTheme.bodyTextStyle),
                  
                  const SizedBox(height: 20),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.video_call),
                          label: const Text('Consultation'),
                          style: AppTheme.primaryButtonStyle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: expert.availableForChat ? () {} : null,
                          icon: const Icon(Icons.chat),
                          label: const Text('Discuter'),
                          style: AppTheme.secondaryButtonStyle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Expert model
class Expert {
  final String id;
  final String name;
  final String specialty;
  final String location;
  final String experience;
  final String description;
  final String avatar;
  final double rating;
  final int consultations;
  final bool isVerified;
  final bool availableForChat;

  Expert({
    required this.id,
    required this.name,
    required this.specialty,
    required this.location,
    required this.experience,
    required this.description,
    required this.avatar,
    required this.rating,
    required this.consultations,
    required this.isVerified,
    required this.availableForChat,
  });
}