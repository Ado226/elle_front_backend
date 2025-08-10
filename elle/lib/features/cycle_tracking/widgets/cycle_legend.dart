import 'package:flutter/material.dart';
import '../../../core/theme/african_theme.dart';

class CycleLegend extends StatefulWidget {
  final bool isVisible;
  final VoidCallback onClose;

  const CycleLegend({
    Key? key,
    required this.isVisible,
    required this.onClose,
  }) : super(key: key);

  @override
  State<CycleLegend> createState() => _CycleLegendState();
}

class _CycleLegendState extends State<CycleLegend>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _backdropAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _backdropAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isVisible) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(CycleLegend oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible && !_animationController.isAnimating) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          children: [
            // Backdrop
            Positioned.fill(
              child: GestureDetector(
                onTap: widget.onClose,
                child: Container(
                  color: Colors.black.withOpacity(0.5 * _backdropAnimation.value),
                ),
              ),
            ),
            
            // Legend content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Transform.translate(
                offset: Offset(0, MediaQuery.of(context).size.height * 0.4 * _slideAnimation.value),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: _buildLegendContent(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLegendContent() {
    return Container(
      decoration: const BoxDecoration(
        color: AfricanColors.ivoryWhite,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: AfricanColors.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          _buildHeader(),
          
          // Legend items
          _buildLegendItems(),
          
          // Additional info
          _buildAdditionalInfo(),
          
          // Close button
          _buildCloseButton(),
          
          // Bottom padding
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AfricanColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.palette,
              color: AfricanColors.primaryColor,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Légende des couleurs',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AfricanColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Comprenez les phases de votre cycle',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AfricanColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItems() {
    final legendItems = [
      LegendItemData(
        color: AfricanColors.menstruationColor,
        title: 'Menstruation',
        subtitle: 'Période des règles',
        icon: Icons.water_drop,
        emoji: '🩸',
        description: 'Durée habituelle : 3-7 jours',
      ),
      LegendItemData(
        color: AfricanColors.fertileColor,
        title: 'Période fertile',
        subtitle: 'Fertilité élevée',
        icon: Icons.eco,
        emoji: '🌿',
        description: 'Fenêtre de conception possible',
      ),
      LegendItemData(
        color: AfricanColors.ovulationColor,
        title: 'Ovulation',
        subtitle: 'Pic de fertilité',
        icon: Icons.star,
        emoji: '🌟',
        description: 'Jour le plus fertile du cycle',
      ),
      LegendItemData(
        color: AfricanColors.safeColor,
        title: 'Jours sûrs',
        subtitle: 'Faible fertilité',
        icon: Icons.shield,
        emoji: '💙',
        description: 'Probabilité réduite de conception',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: legendItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: index < legendItems.length - 1 ? 16 : 0),
            child: _buildLegendItem(item),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLegendItem(LegendItemData item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Color indicator
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: item.color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              item.icon,
              color: _getIconColor(item.color),
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: item.color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.emoji,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AfricanColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AfricanColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AfricanColors.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AfricanColors.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AfricanColors.infoBlue,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Informations supplémentaires',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AfricanColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          _buildInfoRow(Icons.favorite, 'Cœur rouge', 'Rapport intime enregistré'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.radio_button_checked, 'Bordure épaisse', 'Jour actuel (aujourd\'hui)'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.circle, 'Point coloré', 'Phase active du cycle'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String description) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AfricanColors.textSecondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AfricanColors.textSecondary,
              ),
              children: [
                TextSpan(
                  text: label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const TextSpan(text: ' : '),
                TextSpan(text: description),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCloseButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: widget.onClose,
          style: ElevatedButton.styleFrom(
            backgroundColor: AfricanColors.primaryColor,
            foregroundColor: AfricanColors.textLight,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Compris',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AfricanColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getIconColor(Color backgroundColor) {
    if (backgroundColor == AfricanColors.ovulationColor ||
        backgroundColor == AfricanColors.safeColor) {
      return AfricanColors.textPrimary;
    }
    return AfricanColors.textLight;
  }
}

class LegendItemData {
  final Color color;
  final String title;
  final String subtitle;
  final IconData icon;
  final String emoji;
  final String description;

  const LegendItemData({
    required this.color,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.emoji,
    required this.description,
  });
}