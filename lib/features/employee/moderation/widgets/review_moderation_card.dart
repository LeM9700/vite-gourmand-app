import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../reviews/models/review_model.dart';

class ReviewModerationCard extends StatelessWidget {
  final ReviewModel review;
  final Future<void> Function(String status) onModerate;

  const ReviewModerationCard({
    super.key,
    required this.review,
    required this.onModerate,
  });

  Color _getRatingColor(int rating) {
    if (rating >= 4) return Colors.green;
    if (rating >= 3) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy à HH:mm');
    final ratingColor = _getRatingColor(review.rating);

    return GlassCard(
      borderColor: review.status == 'PENDING'
          ? Colors.orange.withOpacity(0.5)
          : review.status == 'APPROVED'
              ? Colors.green.withOpacity(0.5)
              : Colors.red.withOpacity(0.5),
      borderWidth: 2,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // En-tête avec statut
            Row(
              children: [
                // Badge statut
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: review.status == 'PENDING'
                        ? Colors.orange.withOpacity(0.15)
                        : review.status == 'APPROVED'
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: review.status == 'PENDING'
                          ? Colors.orange
                          : review.status == 'APPROVED'
                              ? Colors.green
                              : Colors.red,
                    ),
                  ),
                  child: Text(
                    review.status,
                    style: AppTextStyles.caption.copyWith(
                      color: review.status == 'PENDING'
                          ? Colors.orange
                          : review.status == 'APPROVED'
                              ? Colors.green
                              : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  dateFormat.format(review.createdAt),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Note
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    color: ratingColor,
                    size: 24,
                  );
                }),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: ratingColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${review.rating}/5',
                    style: AppTextStyles.subtitle.copyWith(
                      color: ratingColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Commentaire
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                review.comment,
                style: AppTextStyles.body,
              ),
            ),

            const SizedBox(height: 12),

            // Informations supplémentaires
            Row(
              children: [
                const Icon(Icons.shopping_bag, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Commande #${review.orderId}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Informations client
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  '${review.customerFirstname ?? "Client"} ${review.customerLastname ?? "Inconnu"}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            // Boutons d'action (seulement si PENDING)
            if (review.status == 'PENDING') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onModerate('REJECTED'),
                      icon: const Icon(Icons.close, color: Colors.red),
                      label: Text(
                        'Rejeter',
                        style: AppTextStyles.body.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Colors.red, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () => onModerate('APPROVED'),
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: Text(
                        'Approuver',
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
    );
  }
}
