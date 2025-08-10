import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SymptomsSection extends StatelessWidget {
  const SymptomsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:  EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /*Text(
            'Enregistrez vos symptômes',
            style: AppTheme.sectionTitleStyle,
          ),
          //const SizedBox(height: 8),
          Text(
            'Enregistrez les symptômes pour mieux suivre votre santé',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 8),

           */
          // Bouton aligné à gauche avec une couleur rose plus vive
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              onPressed: () {
                _showSymptomsDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4081), // Rose vif comme dans l'image
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Ajouter des symptômes',
                style: AppTheme.buttonTextStyle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSymptomsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const SymptomsModal();
      },
    );
  }
}

class SymptomsModal extends StatefulWidget {
  const SymptomsModal({Key? key}) : super(key: key);

  @override
  State<SymptomsModal> createState() => _SymptomsModalState();
}

class _SymptomsModalState extends State<SymptomsModal> {
  final Set<String> _selectedSymptoms = <String>{};

  final List<SymptomItem> _symptoms = [
    SymptomItem(
      name: 'Crampes',
      icon: Icons.flash_on,
      color: const Color(0xFFFF6B6B),
    ),
    SymptomItem(
      name: 'Fatigue',
      icon: Icons.battery_2_bar,
      color: const Color(0xFF4ECDC4),
    ),
    SymptomItem(
      name: 'Humeur',
      icon: Icons.mood,
      color: const Color(0xFFFFE66D),
    ),
    SymptomItem(
      name: 'Sommeil',
      icon: Icons.bedtime,
      color: const Color(0xFF95A5A6),
    ),
    SymptomItem(
      name: 'Acné',
      icon: Icons.face,
      color: const Color(0xFFFF9FF3),
    ),
    SymptomItem(
      name: 'Mal de tête',
      icon: Icons.psychology,
      color: const Color(0xFFA8E6CF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sélectionnez vos symptômes',
              style: AppTheme.sectionTitleStyle,
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _symptoms.length,
              itemBuilder: (context, index) {
                final symptom = _symptoms[index];
                final isSelected = _selectedSymptoms.contains(symptom.name);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedSymptoms.remove(symptom.name);
                      } else {
                        _selectedSymptoms.add(symptom.name);
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryPink.withOpacity(0.1) : AppTheme.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryPink : AppTheme.mediumGray.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: symptom.color.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            symptom.icon,
                            color: symptom.color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          symptom.name,
                          style: AppTheme.bodyTextStyle.copyWith(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? AppTheme.primaryPink : AppTheme.darkText,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.mediumGray,
                      side: BorderSide(color: AppTheme.mediumGray.withOpacity(0.3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      minimumSize: const Size(0, 48),
                    ),
                    child: Text(
                      'Annuler',
                      style: AppTheme.buttonTextStyle.copyWith(
                        color: AppTheme.mediumGray,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _selectedSymptoms.isEmpty
                                ? 'Aucun symptôme sélectionné'
                                : 'Symptômes enregistrés: ${_selectedSymptoms.join(', ')}',
                          ),
                          backgroundColor: const Color(0xFFFF4081),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4081),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      minimumSize: const Size(0, 48),
                    ),
                    child: Text(
                      'Enregistrer',
                      style: AppTheme.buttonTextStyle.copyWith(
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
      ),
    );
  }
}

class SymptomItem {
  final String name;
  final IconData icon;
  final Color color;

  SymptomItem({
    required this.name,
    required this.icon,
    required this.color,
  });
}