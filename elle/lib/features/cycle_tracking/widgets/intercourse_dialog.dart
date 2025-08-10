import 'package:flutter/material.dart';
import '../../../core/models/menstrual_cycle.dart';
import '../../../core/theme/african_theme.dart';

class IntercourseDialog extends StatefulWidget {
  final CycleDay cycleDay;
  final Function(CycleDay) onSave;

  const IntercourseDialog({
    Key? key,
    required this.cycleDay,
    required this.onSave,
  }) : super(key: key);

  @override
  State<IntercourseDialog> createState() => _IntercourseDialogState();
}

class _IntercourseDialogState extends State<IntercourseDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  IntercourseType _selectedType = IntercourseType.none;
  final TextEditingController _notesController = TextEditingController();
  final List<String> _selectedSymptoms = [];

  final List<Map<String, dynamic>> _availableSymptoms = [
    {'id': 'cramps', 'label': 'Crampes', 'icon': Icons.healing, 'color': AfricanColors.errorRed},
    {'id': 'mood_happy', 'label': 'Bonne humeur', 'icon': Icons.mood, 'color': AfricanColors.successGreen},
    {'id': 'mood_sad', 'label': 'Tristesse', 'icon': Icons.sentiment_dissatisfied, 'color': AfricanColors.warningOrange},
    {'id': 'fatigue', 'label': 'Fatigue', 'icon': Icons.battery_2_bar, 'color': AfricanColors.desertRose},
    {'id': 'headache', 'label': 'Mal de tête', 'icon': Icons.psychology, 'color': AfricanColors.nileBlueDark},
    {'id': 'bloating', 'label': 'Ballonnements', 'icon': Icons.fitness_center, 'color': AfricanColors.terracottaAccent},
    {'id': 'breast_tenderness', 'label': 'Sensibilité seins', 'icon': Icons.child_care, 'color': AfricanColors.desertRose},
    {'id': 'cervical_mucus', 'label': 'Glaire cervicale', 'icon': Icons.water_drop, 'color': AfricanColors.fertileColor},
  ];

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    // Initialize with existing data
    _selectedType = widget.cycleDay.intercourse;
    _notesController.text = widget.cycleDay.notes ?? '';
    _selectedSymptoms.addAll(widget.cycleDay.symptoms);

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveAndClose() {
    final updatedCycleDay = widget.cycleDay.copyWith(
      intercourse: _selectedType,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      symptoms: List.from(_selectedSymptoms),
    );

    widget.onSave(updatedCycleDay);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          color: AfricanColors.overlayColor.withOpacity(0.8 * _fadeAnimation.value),
          child: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Container(
                  margin: const EdgeInsets.all(20),
                  constraints: const BoxConstraints(maxHeight: 600),
                  decoration: AfricanTheme.cardDecoration.copyWith(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      _buildHeader(),
                      
                      // Content
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Intercourse type selection
                              _buildIntercourseTypeSection(),
                              
                              const SizedBox(height: 24),
                              
                              // Symptoms section
                              _buildSymptomsSection(),
                              
                              const SizedBox(height: 24),
                              
                              // Notes section
                              _buildNotesSection(),
                            ],
                          ),
                        ),
                      ),
                      
                      // Action buttons
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AfricanColors.primaryColor,
            AfricanColors.copperAccent,
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AfricanColors.textLight.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.favorite,
              color: AfricanColors.textLight,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.cycleDay.date.day}/${widget.cycleDay.date.month}/${widget.cycleDay.date.year}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AfricanColors.textLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.cycleDay.typeDisplayName} ${widget.cycleDay.typeEmoji}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AfricanColors.textLight.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.close,
              color: AfricanColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntercourseTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type de rapport',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AfricanColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildIntercourseOption(
                type: IntercourseType.none,
                label: 'Aucun',
                icon: Icons.close,
                color: AfricanColors.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildIntercourseOption(
                type: IntercourseType.protected,
                label: 'Protégé',
                icon: Icons.shield,
                color: AfricanColors.successGreen,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildIntercourseOption(
                type: IntercourseType.unprotected,
                label: 'Non protégé',
                icon: Icons.favorite,
                color: AfricanColors.errorRed,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIntercourseOption({
    required IntercourseType type,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AfricanColors.safariSand,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AfricanColors.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : AfricanColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? color : AfricanColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Symptômes',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AfricanColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableSymptoms.map((symptom) {
            final isSelected = _selectedSymptoms.contains(symptom['id']);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedSymptoms.remove(symptom['id']);
                  } else {
                    _selectedSymptoms.add(symptom['id']);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? symptom['color'].withOpacity(0.1) 
                      : AfricanColors.safariSand,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                        ? symptom['color'] 
                        : AfricanColors.dividerColor,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      symptom['icon'],
                      size: 16,
                      color: isSelected 
                          ? symptom['color'] 
                          : AfricanColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      symptom['label'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isSelected 
                            ? symptom['color'] 
                            : AfricanColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes personnelles',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AfricanColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Ajoutez vos notes ici...',
            fillColor: AfricanColors.safariSand,
            hintStyle: TextStyle(
              color: AfricanColors.textSecondary.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AfricanColors.safariSand,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _saveAndClose,
              child: const Text('Sauvegarder'),
            ),
          ),
        ],
      ),
    );
  }
}