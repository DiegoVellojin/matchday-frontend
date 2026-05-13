import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class MatchDaySearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const MatchDaySearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Buscar...',
    this.onChanged,
    this.onClear,
  });

  @override
  State<MatchDaySearchBar> createState() => _MatchDaySearchBarState();
}

class _MatchDaySearchBarState extends State<MatchDaySearchBar> {
  bool _hasText = false;
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {
        _hasText = widget.controller.text.isNotEmpty;
      });
    }
  }

  void _onFocusChanged() {
    if (mounted) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 54,
      decoration: BoxDecoration(
        color: isDark 
            ? (_isFocused ? const Color(0xFF1F2937) : const Color(0xFF111827))
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isFocused 
              ? AppColors.primary 
              : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _isFocused 
                ? AppColors.primary.withValues(alpha: 0.1) 
                : Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: _isFocused ? 16 : 10,
            offset: Offset(0, _isFocused ? 6 : 4),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          prefixIcon: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.only(left: 12.0),
            child: Icon(
              Icons.search_rounded,
              size: 22,
              color: _isFocused 
                  ? AppColors.primary 
                  : (isDark ? const Color(0xFF6B7280) : Colors.grey.shade400),
            ),
          ),
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: isDark ? const Color(0xFF6B7280) : Colors.grey.shade400,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          suffixIcon: _hasText 
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  color: isDark ? const Color(0xFF6B7280) : Colors.grey.shade600,
                  onPressed: () {
                    widget.controller.clear();
                    if (widget.onClear != null) widget.onClear!();
                    if (widget.onChanged != null) widget.onChanged!('');
                  },
                )
              : null,
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
