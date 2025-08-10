import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'shop_screen.dart';
import 'forum_screen.dart';
import 'appointments_screen.dart';
import 'partner_screen.dart';
import 'caring_screen.dart';
import 'loyalty_screen.dart';
import 'payment_screen.dart';
import 'notifications_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const ShopScreen(),
    const ForumScreen(),
    const AppointmentsScreen(),
    const ModulesScreen(), // Menu pour les modules spéciaux
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primaryPink,
          unselectedItemColor: AppTheme.lightGray,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          iconSize: 24,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag),
              label: 'Boutique',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.forum),
              label: 'Forum',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: 'RDV',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.apps),
              label: 'Plus',
            ),
          ],
        ),
      ),
    );
  }
}

class ModulesScreen extends StatelessWidget {
  const ModulesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Modules Elles',
          style: AppTheme.headerStyle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildModuleCard(
              context,
              'Partenaire',
              'Connectez-vous avec votre partenaire',
              Icons.people,
              Colors.blue,
              () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const PartnerScreen()),
              ),
            ),
            _buildModuleCard(
              context,
              'Caring Boyfriend',
              'Suggestions d\'attention',
              Icons.favorite,
              Colors.purple,
              () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CaringScreen()),
              ),
            ),
            _buildModuleCard(
              context,
              'Fidélité',
              'Points et récompenses',
              Icons.stars,
              Colors.amber,
              () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const LoyaltyScreen()),
              ),
            ),
            _buildModuleCard(
              context,
              'Paiements',
              'Gérez vos moyens de paiement',
              Icons.payment,
              Colors.green,
              () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const PaymentScreen()),
              ),
            ),
            _buildModuleCard(
              context,
              'Notifications',
              'Paramètres et historique',
              Icons.notifications,
              Colors.orange,
              () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              ),
            ),
            _buildModuleCard(
              context,
              'Profil',
              'Paramètres du compte',
              Icons.person,
              AppTheme.primaryPink,
              () => _showProfileDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.lightGray.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTheme.bodyTextStyle.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTheme.captionStyle.copyWith(
                color: AppTheme.lightGray,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.person,
              color: AppTheme.primaryPink,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Profil Utilisateur',
              style: AppTheme.subHeaderStyle.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildProfileRow('Nom', 'Anita Kouassi'),
            _buildProfileRow('Email', 'anita@example.com'),
            _buildProfileRow('Téléphone', '+225 07 12 34 56 78'),
            _buildProfileRow('Âge', '28 ans'),
            _buildProfileRow('Localisation', 'Abidjan, Côte d\'Ivoire'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryPink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    color: AppTheme.primaryPink,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Données de test - Toutes les fonctionnalités sont disponibles',
                      style: AppTheme.captionStyle.copyWith(
                        color: AppTheme.primaryPink,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Fermer',
              style: AppTheme.bodyTextStyle.copyWith(color: AppTheme.lightGray),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: AppTheme.captionStyle.copyWith(
                color: AppTheme.lightGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyTextStyle.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}