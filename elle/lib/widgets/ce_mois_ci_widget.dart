import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'animated_heptagon_widget.dart';

class CeMoisCiWidget extends StatelessWidget {
  const CeMoisCiWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      color: AppTheme.ceMoisCiBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Ce mois-ci',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppTheme.titleColor,
            ),
          ),
          // Centered animated heptagon
          const Center(
            child: AnimatedHeptagonWidget(),
          ),
        ],
      ),
    );
  }
}

