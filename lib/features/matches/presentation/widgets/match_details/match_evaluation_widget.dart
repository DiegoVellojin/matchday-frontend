import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/match_entity.dart';
import '../../bloc/matches_bloc.dart';

class MatchEvaluationWidget extends StatefulWidget {
  final MatchEntity match;
  final bool isDark;
  final String? rivalName;
  final String? rivalLogo;

  const MatchEvaluationWidget({
    super.key,
    required this.match,
    required this.isDark,
    this.rivalName,
    this.rivalLogo,
  });

  @override
  State<MatchEvaluationWidget> createState() => _MatchEvaluationWidgetState();
}

class _MatchEvaluationWidgetState extends State<MatchEvaluationWidget> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitEvaluation(BuildContext context) {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una calificación')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    context.read<MatchesBloc>().add(EvaluateMatchEvent(
      matchId: widget.match.id,
      puntuacion: _rating,
      comentario: _commentController.text.isEmpty ? null : _commentController.text,
    ));
  }
  @override
  Widget build(BuildContext context) {
    if (widget.match.yaEvaluado || widget.match.evaluaciones.isNotEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: Colors.greenAccent.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.greenAccent.withValues(alpha: 0.05),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 24),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'EVALUACIÓN COMPLETADA',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: Colors.greenAccent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (widget.rivalLogo != null && widget.rivalLogo!.startsWith('http')) ...[
                            ClipOval(
                              child: Image.network(
                                widget.rivalLogo!,
                                width: 20,
                                height: 20,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.group, size: 14),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.rivalName?.toUpperCase() ?? 'RIVAL',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.match.evaluaciones.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Divider(height: 1),
              const SizedBox(height: 16),
              ...widget.match.evaluaciones.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          e.evaluadorNombre.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: widget.isDark ? Colors.white70 : Colors.black87,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Row(
                          children: List.generate(5, (index) => Icon(
                            index < e.puntuacion ? Icons.star_rounded : Icons.star_outline_rounded,
                            size: 14,
                            color: index < e.puntuacion ? Colors.amber : Colors.grey,
                          )),
                        ),
                      ],
                    ),
                    if (e.comentario != null && e.comentario!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (widget.isDark ? Colors.white : Colors.black).withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          e.comentario!,
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: widget.isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              )),
            ],
          ],
        ),
      );
    }

    return BlocListener<MatchesBloc, MatchesState>(
      listener: (context, state) {
        if (state is MatchEvaluated) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Equipo y capitán evaluados'), 
              backgroundColor: Colors.greenAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.go('/'); 
        } else if (state is MatchesError && _isSubmitting) {
          setState(() => _isSubmitting = false);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: -10,
              child: Icon(
                Icons.stars_rounded,
                size: 100,
                color: AppColors.primary.withValues(alpha: 0.05),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.primary, size: 18),
                      const SizedBox(width: 10),
                      const Text(
                        'EVALUACIÓN DE RIVAL',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                width: 1.5,
                              ),
                            ),
                            child: ClipOval(
                              child: (widget.rivalLogo != null && widget.rivalLogo!.startsWith('http'))
                                  ? Image.network(
                                      widget.rivalLogo!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => 
                                          const Icon(Icons.group, color: AppColors.primary),
                                    )
                                  : Center(
                                      child: Text(
                                        widget.rivalLogo ?? '⚽',
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.rivalName?.toUpperCase() ?? 'TU RIVAL',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: widget.isDark ? Colors.white : Colors.black,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Text(
                                  'Califica el desempeño y deportividad.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: widget.isDark ? Colors.grey[400] : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: (widget.isDark ? Colors.white : Colors.black).withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: (widget.isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(5, (index) {
                                final starValue = index + 1;
                                final isSelected = _rating >= starValue;
                                return GestureDetector(
                                  onTap: () => setState(() => _rating = starValue),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Icon(
                                      isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                                      color: isSelected ? AppColors.primary : Colors.grey[400],
                                      size: 44,
                                    ).animate(target: isSelected ? 1 : 0)
                                     .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 300.ms, curve: Curves.easeOutBack)
                                     .shimmer(duration: 1200.ms, color: Colors.white24),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: _commentController,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: widget.isDark ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Añade un comentario (opcional)...',
                          hintStyle: TextStyle(
                            color: widget.isDark ? Colors.white24 : Colors.black26,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: (widget.isDark ? Colors.black : Colors.grey[100])?.withValues(alpha: 0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: widget.isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: widget.isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.all(20),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : () => _submitEvaluation(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: _isSubmitting
                              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text(
                                  'ENVIAR CALIFICACIÓN',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),
    );
  }
}
