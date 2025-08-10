import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../model/cycle_day_model.dart';

class ReportModalWidget extends StatefulWidget {
  final CycleDay cycleDay;
  final Function(CycleDay) onReportAdded;

  const ReportModalWidget({
    Key? key,
    required this.cycleDay,
    required this.onReportAdded,
  }) : super(key: key);

  @override
  State<ReportModalWidget> createState() => _ReportModalWidgetState();
}

class _ReportModalWidgetState extends State<ReportModalWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final TextEditingController _noteController = TextEditingController();
  final List<String> _selectedSymptoms = [];

  final List<Map<String, dynamic>> _availableSymptoms = [
    {'id': 'cramps', 'label': 'Crampes', 'icon': Icons.healing},
    {'id': 'fatigue', 'label': 'Fatigue', 'icon': Icons.battery_0_bar},
    {'id': 'mood_change', 'label': 'Changement d\'humeur', 'icon': Icons.mood},
    {'id': 'headache', 'label': 'Mal de tête', 'icon': Icons.psychology},
    {'id': 'bloating', 'label': 'Ballonnements', 'icon': Icons.fitness_center},
    {'id': 'cervical_mucus', 'label': 'Glaire cervicale', 'icon': Icons.water_drop},
    {'id': 'ovulation_pain', 'label': 'Douleur ovulation', 'icon': Icons.favorite},
    {'id': 'breast_tenderness', 'label': 'Sensibilité seins', 'icon': Icons.child_care},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Initialize with existing data
    _selectedSymptoms.addAll(widget.cycleDay.symptoms);
    _noteController.text = widget.cycleDay.note ?? '';

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _closeModal() async {
    await _animationController.reverse();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _saveReport() async {
    final updatedCycleDay = widget.cycleDay.copyWith(
      hasReport: true,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
      symptoms: List.from(_selectedSymptoms),
    );

    widget.onReportAdded(updatedCycleDay);
    await _animationController.reverse();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          color: Colors.black.withOpacity(0.5 * _fadeAnimation.value),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Transform.translate(
              offset: Offset(0, MediaQuery.of(context).size.height * _slideAnimation.value),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.75,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: _closeModal,
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.textLight,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'Rapport du ${widget.cycleDay.date.day}/${widget.cycleDay.date.month}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textLight,
                                  ),
                                ),
                                Text(
                                  widget.cycleDay.typeDisplayName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _saveReport,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondaryColor,
                              foregroundColor: AppColors.textPrimary,
                            ),
                            child: const Text('Sauver'),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Symptoms section
                            const Text(
                              'Symptômes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _availableSymptoms.map((symptom) {
                                final isSelected = _selectedSymptoms.contains(symptom['id']);
                                return FilterChip(
                                  selected: isSelected,
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        symptom['icon'],
                                        size: 16,
                                        color: isSelected 
                                            ? AppColors.textLight
                                            : AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(symptom['label']),
                                    ],
                                  ),
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedSymptoms.add(symptom['id']);
                                      } else {
                                        _selectedSymptoms.remove(symptom['id']);
                                      }
                                    });
                                  },
                                  selectedColor: AppColors.primaryColor,
                                  backgroundColor: AppColors.backgroundColor,
                                  labelStyle: TextStyle(
                                    color: isSelected 
                                        ? AppColors.textLight
                                        : AppColors.textPrimary,
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 24),

                            // Notes section
                            const Text(
                              'Notes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.backgroundColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.borderColor,
                                ),
                              ),
                              child: TextField(
                                controller: _noteController,
                                maxLines: 4,
                                decoration: const InputDecoration(
                                  hintText: 'Ajoutez vos notes ici...',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(12),
                                  hintStyle: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Quick actions
                            const Text(
                              'Actions rapides',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: _buildQuickActionCard(
                                    icon: Icons.favorite,
                                    label: 'Rapport intime',
                                    color: AppColors.accentOrange,
                                    onTap: () {
                                      // Mock action
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Rapport intime ajouté'),
                                          backgroundColor: AppColors.successColor,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildQuickActionCard(
                                    icon: Icons.water_drop,
                                    label: 'Flux menstruel',
                                    color: AppColors.periodColor,
                                    onTap: () {
                                      // Mock action
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Flux menstruel ajouté'),
                                          backgroundColor: AppColors.successColor,
                                        ),
                                      );
                                    },
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
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}