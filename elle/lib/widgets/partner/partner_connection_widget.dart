import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../services/partner_service.dart';

class PartnerConnectionWidget extends StatefulWidget {
  final VoidCallback onPartnerConnected;

  const PartnerConnectionWidget({
    Key? key,
    required this.onPartnerConnected,
  }) : super(key: key);

  @override
  State<PartnerConnectionWidget> createState() => _PartnerConnectionWidgetState();
}

class _PartnerConnectionWidgetState extends State<PartnerConnectionWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _floatingController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatingAnimation;

  final PageController _pageController = PageController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  int _currentPage = 0;
  String _generatedCode = '';
  bool _isGeneratingCode = false;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _floatingAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slideController.forward();
      _fadeController.forward();
      _pulseController.repeat(reverse: true);
      _floatingController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    _floatingController.dispose();
    _pageController.dispose();
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_slideController, _fadeController, _pulseController, _floatingController]),
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildContent(),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Floating hearts animation
        Container(
          height: 120,
          child: Stack(
            children: [
              ...List.generate(5, (index) {
                return Positioned(
                  left: 50.0 + (index * 60),
                  top: 20 + (index % 2) * 30,
                  child: Transform.translate(
                    offset: Offset(
                      (index % 2 == 0 ? 1 : -1) * _floatingAnimation.value,
                      _floatingAnimation.value * 0.5,
                    ),
                    child: Transform.scale(
                      scale: _pulseAnimation.value * (0.8 + index * 0.1),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPink.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.favorite,
                          color: AppTheme.primaryPink.withOpacity(0.7),
                          size: 20 + (index % 3) * 8,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        // Main content
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (page) => setState(() => _currentPage = page),
            children: [
              _buildWelcomePage(),
              _buildGenerateCodePage(),
              _buildConnectWithCodePage(),
            ],
          ),
        ),

        // Page indicator
        _buildPageIndicator(),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryPink,
                    AppTheme.primaryPink.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPink.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 32),

          Text(
            'Connectez votre partenaire',
            style: AppTheme.headerStyle.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          Text(
            'Partagez vos informations de cycle avec votre partenaire pour qu\'il puisse mieux vous comprendre et vous soutenir.',
            style: AppTheme.bodyTextStyle.copyWith(
              color: AppTheme.lightGray,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // Benefits list
          Column(
            children: [
              _buildBenefitItem(
                icon: Icons.notifications_active,
                title: 'Notifications contextuelles',
                description: 'Votre partenaire recevra des notifications adaptées à votre cycle',
              ),
              const SizedBox(height: 16),
              _buildBenefitItem(
                icon: Icons.favorite_outline,
                title: 'Suggestions d\'attention',
                description: 'Des idées de gestes attentionnés selon votre phase de cycle',
              ),
              const SizedBox(height: 16),
              _buildBenefitItem(
                icon: Icons.security,
                title: 'Connexion sécurisée',
                description: 'Vos données restent privées et sécurisées',
              ),
            ],
          ),

          const SizedBox(height: 40),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _nextPage(),
                  style: AppTheme.primaryButtonStyle.copyWith(
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  child: Text(
                    'Commencer',
                    style: AppTheme.bodyStyle.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryPink.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryPink,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.bodyTextStyle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTheme.captionStyle.copyWith(
                  color: AppTheme.lightGray,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGenerateCodePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_2,
            size: 80,
            color: AppTheme.primaryPink,
          ),

          const SizedBox(height: 32),

          Text(
            'Générer un code de connexion',
            style: AppTheme.headerStyle.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          Text(
            'Créez un code unique que votre partenaire pourra utiliser pour se connecter à votre compte.',
            style: AppTheme.bodyTextStyle.copyWith(
              color: AppTheme.lightGray,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          if (_generatedCode.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryPink.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Votre code de connexion',
                    style: AppTheme.captionStyle.copyWith(
                      color: AppTheme.lightGray,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _generatedCode.split('').map((char) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPink.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            char,
                            style: AppTheme.headerStyle.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryPink,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _generatedCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Code copié !'),
                              backgroundColor: AppTheme.primaryPink,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                        icon: Icon(Icons.copy, size: 16),
                        label: Text('Copier'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryPink,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ce code expire dans 24 heures',
                      style: AppTheme.captionStyle.copyWith(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: _isGeneratingCode ? null : _generateCode,
              icon: _isGeneratingCode 
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Icon(Icons.qr_code),
              label: Text(_isGeneratingCode ? 'Génération...' : 'Générer le code'),
              style: AppTheme.primaryButtonStyle,
            ),
          ],

          const SizedBox(height: 40),

          TextButton(
            onPressed: () => _nextPage(),
            child: Text(
              'J\'ai déjà un code de connexion',
              style: AppTheme.bodyTextStyle.copyWith(
                color: AppTheme.primaryPink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectWithCodePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.link,
            size: 80,
            color: AppTheme.primaryPink,
          ),

          const SizedBox(height: 32),

          Text(
            'Se connecter avec un code',
            style: AppTheme.headerStyle.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          Text(
            'Saisissez le code de connexion que votre partenaire vous a partagé.',
            style: AppTheme.bodyTextStyle.copyWith(
              color: AppTheme.lightGray,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // Partner name input
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nom de votre partenaire',
              hintText: 'Entrez le nom de votre partenaire',
              prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryPink),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.lightGray.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.lightGray.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryPink),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Code input
          TextField(
            controller: _codeController,
            decoration: InputDecoration(
              labelText: 'Code de connexion',
              hintText: 'Entrez le code (6 lettres)',
              prefixIcon: Icon(Icons.qr_code_scanner, color: AppTheme.primaryPink),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.lightGray.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.lightGray.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryPink),
              ),
            ),
            textCapitalization: TextCapitalization.characters,
            maxLength: 6,
          ),

          const SizedBox(height: 30),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isConnecting || 
                             _codeController.text.length != 6 || 
                             _nameController.text.trim().isEmpty
                      ? null 
                      : _connectWithCode,
                  style: AppTheme.primaryButtonStyle.copyWith(
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  child: _isConnecting
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          'Se connecter',
                          style: AppTheme.bodyStyle.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          TextButton(
            onPressed: () => _previousPage(),
            child: Text(
              'Générer un nouveau code',
              style: AppTheme.bodyTextStyle.copyWith(
                color: AppTheme.primaryPink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index 
                ? AppTheme.primaryPink 
                : AppTheme.lightGray.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _generateCode() async {
    setState(() => _isGeneratingCode = true);
    
    try {
      final code = await PartnerService.generateConnectionCode();
      setState(() {
        _generatedCode = code;
        _isGeneratingCode = false;
      });
    } catch (e) {
      setState(() => _isGeneratingCode = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erreur lors de la génération du code'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _connectWithCode() async {
    setState(() => _isConnecting = true);
    
    try {
      final success = await PartnerService.connectWithCode(
        _codeController.text.toUpperCase(),
        _nameController.text.trim(),
      );
      
      setState(() => _isConnecting = false);
      
      if (success) {
        widget.onPartnerConnected();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Connecté avec ${_nameController.text} !'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Code invalide ou expiré'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isConnecting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erreur de connexion'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }
}