import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heartbit/config/theme/app_colors.dart';
import 'package:heartbit/core/widgets/animated_background.dart';
import 'package:heartbit/features/daily_question/domain/entities/daily_question.dart';
import 'package:heartbit/features/daily_question/presentation/providers/daily_question_provider.dart';
import 'package:heartbit/features/daily_question/presentation/widgets/reaction_bar.dart';
import 'package:heartbit/features/pairing/presentation/providers/pairing_provider.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class DailyQuestionArchiveScreen extends ConsumerWidget {
  const DailyQuestionArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pastQuestionsAsync = ref.watch(pastQuestionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),
              
              // Card Stack
              Expanded(
                child: pastQuestionsAsync.when(
                  data: (questions) {
                    if (questions.isEmpty) {
                      return _buildEmptyState();
                    }
                    return _buildCardStack(context, ref, questions);
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  error: (e, _) => Center(
                    child: Text(
                      'Hata: $e',
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          ),
          const Expanded(
            child: Column(
              children: [
                Text(
                  '💕 Memory Lane',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Geçmiş cevaplarınız',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '📭',
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 24),
            const Text(
              'Henüz arşivlenmiş soru yok',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'İkiniz de günlük soruları cevapladıkça\nburada görünecekler.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardStack(
    BuildContext context,
    WidgetRef ref,
    List<DailyQuestion> questions,
  ) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final question = questions[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: _MemoryCard(question: question),
        );
      },
    );
  }
}

/// Individual memory card showing a past Q&A
class _MemoryCard extends ConsumerWidget {
  final DailyQuestion question;

  const _MemoryCard({required this.question});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authUserIdProvider);
    final coupleAsync = ref.watch(coupleStateProvider);
    final couple = coupleAsync.valueOrNull;
    
    final isUser1 = couple?.user1Id == userId;
    final myAnswer = isUser1 ? question.user1Answer : question.user2Answer;
    final partnerAnswer = isUser1 ? question.user2Answer : question.user1Answer;
    final myReaction = isUser1 ? question.user1Reaction : question.user2Reaction;
    final partnerReaction = isUser1 ? question.user2Reaction : question.user1Reaction;

    // Format date nicely
    final dateFormatted = _formatDate(question.date);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.surface.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dateFormatted,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Question Text
            Text(
              question.questionText,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Answers
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // My Answer
                    _AnswerCard(
                      label: 'Senin Cevabın',
                      answer: myAnswer ?? '',
                      isMe: true,
                      reaction: partnerReaction,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Partner Answer
                    _AnswerCard(
                      label: 'Partnerinin Cevabı',
                      answer: partnerAnswer ?? '',
                      isMe: false,
                      reaction: myReaction,
                    ),
                  ],
                ),
              ),
            ),
            
            // Swipe hint
            const SizedBox(height: 16),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.swipe_vertical,
                    size: 16,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Kaydır',
                    style: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.5),
                      fontSize: 12,
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

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date).inDays;
      
      if (difference == 1) return 'Dün';
      if (difference < 7) return '$difference gün önce';
      
      return DateFormat('d MMMM', 'tr').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}

/// Answer card widget
class _AnswerCard extends StatelessWidget {
  final String label;
  final String answer;
  final bool isMe;
  final String? reaction;

  const _AnswerCard({
    required this.label,
    required this.answer,
    required this.isMe,
    this.reaction,
  });

  @override
  Widget build(BuildContext context) {
    final reactionEmoji = reaction != null 
        ? ReactionType.fromValue(reaction)?.emoji 
        : null;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMe 
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMe 
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.textSecondary.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isMe ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
              if (reactionEmoji != null) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    reactionEmoji,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: const TextStyle(
              color: AppColors.textPrimary,
              height: 1.4,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
