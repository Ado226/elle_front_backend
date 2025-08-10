import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/shop_screen.dart';

class DiscoveryGrid extends StatelessWidget {
  const DiscoveryGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Text(
          'Découvrez',
          style: AppTheme.sectionTitleStyle,
        ),
        const SizedBox(height: 14),

        // Horizontal scrollable list
        SizedBox(
          height: 120, // Hauteur fixe pour les cartes
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: 16),
            itemCount: 5, // 4 cartes + 1 bouton plus
            itemBuilder: (context, index) {
              if (index == 4) {
                // Bouton plus à la fin
                return _buildPlusButton(context);
              }

              // Cartes de produits
              final products = [
                {'title': 'Préservatifs', 'icon': Icons.favorite_border},
                {'title': 'Pilules', 'icon': Icons.medical_services_outlined},
                {'title': 'Lubrifiant', 'icon': Icons.water_drop_outlined},
                {'title': 'Sex toys', 'icon': Icons.favorite_outlined},
              ];

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _buildDiscoveryCard(
                  products[index]['title'] as String,
                  products[index]['icon'] as IconData,
                      () => _navigateToProduct(context, products[index]['title'] as String),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDiscoveryCard(
      String title,
      IconData icon,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100, // Largeur fixe pour chaque carte
        decoration: AppTheme.cardDecoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Icon(
              icon,
              color: AppTheme.mediumGray,
              size: 24,
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              title,
              style: AppTheme.bodyTextStyle.copyWith(
                color: AppTheme.darkText,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlusButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToProduct(context, 'More'),
      child: Container(
        width: 100, // Même largeur que les cartes
        height: 120, // Même hauteur que les cartes
        decoration: AppTheme.cardDecoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppTheme.primaryPink,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: AppTheme.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Plus',
              style: AppTheme.bodyTextStyle.copyWith(
                color: AppTheme.darkText,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToProduct(BuildContext context, String productType) {
    if (productType == 'More') {
      // Navigate to shop with all products
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const ShopScreen()),
      );
    } else {
      // Navigate to shop with specific category filter
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const ShopScreen(),
          settings: RouteSettings(arguments: {'category': productType}),
        ),
      );
    }
  }
}