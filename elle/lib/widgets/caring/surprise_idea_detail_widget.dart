import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../core/models/caring_experience.dart';
import '../../services/caring_service.dart';

class SurpriseIdeaDetailWidget extends StatefulWidget {
  final SurpriseIdea idea;
  final ScrollController scrollController;
  final VoidCallback onCompleted;

  const SurpriseIdeaDetailWidget({
    Key? key,
    required this.idea,
    required this.scrollController,
    required this.onCompleted,
  }) : super(key: key);

  @override
  State<SurpriseIdeaDetailWidget> createState() => _SurpriseIdeaDetailWidgetState();
}

class _SurpriseIdeaDetailWidgetState extends State<SurpriseIdeaDetailWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _staggerController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final TextEditingController _notesController = TextEditingController();
  int _selectedRating = 5;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slideController.forward();
      _fadeController.forward();
      _staggerController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _staggerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_slideController, _fadeController]),
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
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.lightGray.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getCategoryColor(),
                        _getCategoryColor().withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      widget.idea.emoji,
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.idea.title,
                        style: AppTheme.headerStyle.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getCategoryColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.idea.categoryDisplayName,
                              style: AppTheme.captionStyle.copyWith(
                                color: _getCategoryColor(),
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryPink.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.favorite,
                                  size: 10,
                                  color: AppTheme.primaryPink,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${widget.idea.carePointsValue} pts',
                                  style: AppTheme.captionStyle.copyWith(
                                    color: AppTheme.primaryPink,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    widget.idea.description,
                    style: AppTheme.bodyTextStyle.copyWith(
                      height: 1.5,
                      color: AppTheme.lightGray.withOpacity(0.9),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Info cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.schedule,
                          label: 'Durée',
                          value: widget.idea.formattedTime,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.attach_money,
                          label: 'Coût',
                          value: widget.idea.formattedCost,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.trending_up,
                          label: 'Difficulté',
                          value: widget.idea.difficultyDisplayName,
                          color: _getDifficultyColor(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Materials needed
                  if (widget.idea.materials.isNotEmpty) ...[
                    _buildSection(
                      title: 'Matériel nécessaire',
                      icon: Icons.list_alt,
                      children: widget.idea.materials.map((material) {
                        return _buildListItem(material, Icons.check_circle_outline);
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Steps
                  if (widget.idea.steps.isNotEmpty) ...[
                    _buildSection(
                      title: 'Étapes à suivre',
                      icon: Icons.format_list_numbered,
                      children: widget.idea.steps.asMap().entries.map((entry) {
                        final index = entry.key;
                        final step = entry.value;
                        return _buildStepItem(index + 1, step);
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Tips
                  if (widget.idea.tips.isNotEmpty) ...[
                    _buildSection(
                      title: 'Conseils',
                      icon: Icons.lightbulb_outline,
                      children: widget.idea.tips.map((tip) {
                        return _buildListItem(tip, Icons.lightbulb);
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Best for moods
                  if (widget.idea.bestForMoods.isNotEmpty) ...[
                    Text(
                      'Idéal pour',
                      style: AppTheme.subHeaderStyle.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.idea.bestForMoods.map((mood) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryPink.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.primaryPink.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            _getMoodDisplayName(mood),
                            style: AppTheme.captionStyle.copyWith(
                              color: AppTheme.primaryPink,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Completion section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPink.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.primaryPink.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Marquer comme accompli',
                          style: AppTheme.subHeaderStyle.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Rating
                        Text(
                          'Comment s\'est passée cette action ?',
                          style: AppTheme.bodyTextStyle.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(5, (index) {
                            return GestureDetector(
                              onTap: () => setState(() => _selectedRating = index + 1),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                child: Icon(
                                  index < _selectedRating ? Icons.star : Icons.star_outline,
                                  color: Colors.amber,
                                  size: 32,
                                ),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 16),

                        // Notes
                        Text(
                          'Notes (optionnel)',
                          style: AppTheme.bodyTextStyle.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _notesController,
                          decoration: InputDecoration(
                            hintText: 'Ajoutez vos impressions...',
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
                          maxLines: 3,
                          textCapitalization: TextCapitalization.sentences,
                        ),

                        const SizedBox(height: 20),

                        // Complete button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isCompleting ? null : _completeAction,
                            style: AppTheme.primaryButtonStyle.copyWith(
                              padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                            child: _isCompleting
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Marquer comme accompli (+${widget.idea.carePointsValue} pts)',
                                        style: AppTheme.bodyTextStyle.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTheme.captionStyle.copyWith(
              color: AppTheme.lightGray,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTheme.captionStyle.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryPink,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTheme.subHeaderStyle.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildListItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppTheme.primaryPink,
            size: 16,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTheme.bodyTextStyle.copyWith(
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.primaryPink,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: AppTheme.captionStyle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTheme.bodyTextStyle.copyWith(
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor() {
    switch (widget.idea.category) {
      case SurpriseCategory.romantic:
        return Colors.pink;
      case SurpriseCategory.supportive:
        return Colors.blue;
      case SurpriseCategory.health:
        return Colors.green;
      case SurpriseCategory.comfort:
        return Colors.purple;
      case SurpriseCategory.adventure:
        return Colors.orange;
      case SurpriseCategory.creative:
        return Colors.amber;
    }
  }

  Color _getDifficultyColor() {
    switch (widget.idea.difficulty) {
      case ActionDifficulty.easy:
        return Colors.green;
      case ActionDifficulty.medium:
        return Colors.orange;
      case ActionDifficulty.advanced:
        return Colors.red;
    }
  }

  String _getMoodDisplayName(MoodContext mood) {
    switch (mood) {
      case MoodContext.menstruation:
        return 'Menstruation';
      case MoodContext.pms:
        return 'SPM';
      case MoodContext.ovulation:
        return 'Ovulation';
      case MoodContext.happy:
        return 'Bonne humeur';
      case MoodContext.stressed:
        return 'Stress';
      case MoodContext.tired:
        return 'Fatigue';
      case MoodContext.emotional:
        return 'Émotionnel';
    }
  }

  Future<void> _completeAction() async {
    setState(() => _isCompleting = true);

    try {
      final success = await CaringService.completeAction(
        widget.idea,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        rating: _selectedRating,
      );

      if (success) {
        widget.onCompleted();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Action accomplie ! +${widget.idea.carePointsValue} points'),
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
              content: const Text('Erreur lors de la validation'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erreur inattendue'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      setState(() => _isCompleting = false);
    }
  }
}