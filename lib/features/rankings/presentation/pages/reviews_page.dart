import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/matchday_shimmer.dart';
import '../../domain/entities/review_entity.dart';
import '../bloc/evaluations_bloc.dart';

class ReviewsPage extends StatelessWidget {
  final int targetId;
  final bool isTeam;
  final String title;

  const ReviewsPage({
    super.key,
    required this.targetId,
    required this.isTeam,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => sl<EvaluationsBloc>()
        ..add(LoadEvaluationsEvent(targetId: targetId, isTeam: isTeam)),
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'COMENTARIOS',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 1.2,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : Colors.black,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<EvaluationsBloc, EvaluationsState>(
          builder: (context, state) {
            if (state is EvaluationsLoading) {
              return _buildSkeleton();
            }
            if (state is EvaluationsError) {
              return _buildErrorState(state.message);
            }
            if (state is EvaluationsLoaded) {
              if (state.evaluations.isEmpty) {
                return _buildEmptyState();
              }
              return _buildReviewsList(state.evaluations, isDark);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: MatchDayShimmer.rounded(height: 160, borderRadius: 24),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rate_review_outlined, size: 80, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text(
            'Sin comentarios aún',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Las evaluaciones aparecerán aquí después de los partidos.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ).animate().fadeIn(),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Text('Error: $message', textAlign: TextAlign.center),
      ),
    );
  }

  Widget _buildReviewsList(List<ReviewEntity> reviews, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return _buildReviewCard(review, isDark)
            .animate()
            .fadeIn(delay: (index * 50).ms)
            .slideX(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildReviewCard(ReviewEntity review, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(review.evaluator.foto, isDark),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.evaluator.nombre,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                    ),
                    Text(
                      'Capitán de ${review.evaluatorTeam.nombre}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildStars(review.puntuacion),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd/MM/yyyy').format(review.fecha),
                    style: TextStyle(color: Colors.grey[500], fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          if (review.comentario != null && review.comentario!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03),
                ),
              ),
              child: Text(
                review.comentario!,
                style: TextStyle(
                  color: isDark ? Colors.grey[300] : Colors.grey[800],
                  fontSize: 14,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(String? url, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
      ),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: isDark ? Colors.black26 : Colors.grey[200],
        backgroundImage: (url != null && url.startsWith('http')) ? NetworkImage(url) : null,
        child: (url == null || !url.startsWith('http'))
            ? const Icon(Icons.person, color: Colors.grey, size: 20)
            : null,
      ),
    );
  }

  Widget _buildStars(int count) {
    return Row(
      children: List.generate(
        5,
        (index) => Icon(
          index < count ? Icons.star_rounded : Icons.star_outline_rounded,
          color: index < count ? Colors.amber : Colors.grey[300],
          size: 16,
        ),
      ),
    );
  }
}
