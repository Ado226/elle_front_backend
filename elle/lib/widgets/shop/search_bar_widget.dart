import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SearchBarWidget extends StatefulWidget {
  final Function(String) onSearchChanged;
  final String hintText;

  const SearchBarWidget({
    Key? key,
    required this.onSearchChanged,
    this.hintText = 'Rechercher...',
  }) : super(key: key);

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late AnimationController _focusController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _focusAnimation;

  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupFocusListener();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _focusController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _focusAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _focusController,
      curve: Curves.easeOutCubic,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
      _pulseController.repeat(reverse: true);
    });
  }

  void _setupFocusListener() {
    _focusNode.addListener(() {
      setState(() => _hasFocus = _focusNode.hasFocus);
      
      if (_focusNode.hasFocus) {
        _focusController.forward();
        _pulseController.stop();
      } else {
        _focusController.reverse();
        _pulseController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    _focusController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _textController.clear();
    widget.onSearchChanged('');
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _pulseController, _focusController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value * (_hasFocus ? 1.0 : _pulseAnimation.value),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _hasFocus 
                    ? AppTheme.primaryPink.withOpacity(0.5)
                    : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _hasFocus
                      ? AppTheme.primaryPink.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: _hasFocus ? 12 : 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              onChanged: widget.onSearchChanged,
              style: AppTheme.bodyTextStyle.copyWith(
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: AppTheme.bodyTextStyle.copyWith(
                  color: AppTheme.lightGray,
                  fontSize: 16,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: _hasFocus
                          ? AppTheme.primaryPink.withOpacity(0.1)
                          : AppTheme.lightGray.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.search,
                      color: _hasFocus ? AppTheme.primaryPink : AppTheme.lightGray,
                      size: 20,
                    ),
                  ),
                ),
                suffixIcon: _textController.text.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(8),
                        child: GestureDetector(
                          onTap: _clearSearch,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: AppTheme.lightGray.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              Icons.close,
                              color: AppTheme.lightGray,
                              size: 16,
                            ),
                          ),
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}