import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ConsultationCards extends StatelessWidget {
  const ConsultationCards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Text(
          'Vous aimerez',
          style: AppTheme.sectionTitleStyle,
        ),
        const SizedBox(height: 16),
        
        // Consultation cards
        Column(
          children: [
            _buildConsultationCard(
              'La consultation chez la gynécologue',
              'Prenez rendez-vous avec un spécialiste',
              Icons.local_hospital_outlined,
              () => _openConsultation(context, 'gynécologue'),
            ),
            const SizedBox(height: 8),
            _buildConsultationCard(
              'La consultation chez la gynécologue',
              'Parlez à un professionnel de santé',
              Icons.chat_bubble_outline,
              () => _openConsultation(context, 'en ligne'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConsultationCard(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 60,
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.cardDecoration,
        child: Row(
          children: [
            // Icon container (Orange/peach colored)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.consultationOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppTheme.consultationOrange,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.bodyTextStyle.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTheme.bodyTextStyle.copyWith(
                      fontSize: 12,
                      color: AppTheme.lightGray,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openConsultation(BuildContext context, String consultationType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.lightGray.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Header
                Text(
                  'Consultation $consultationType',
                  style: AppTheme.subHeaderStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Content
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppTheme.primaryPink,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Informations',
                            style: AppTheme.bodyStyle.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        consultationType == 'gynécologue'
                            ? 'Prenez rendez-vous avec un gynécologue qualifié pour un suivi médical personnalisé.'
                            : 'Consultez un professionnel de santé en ligne pour obtenir des conseils et un suivi médical.',
                        style: AppTheme.captionStyle,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: AppTheme.secondaryButtonStyle,
                        child: Text(
                          'Fermer',
                          style: AppTheme.bodyStyle.copyWith(
                            color: AppTheme.primaryPink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Handle booking
                        },
                        style: AppTheme.primaryButtonStyle,
                        child: Text(
                          'Réserver',
                          style: AppTheme.bodyStyle.copyWith(
                            color: AppTheme.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}