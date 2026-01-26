import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/utils/responsive.dart';
import '../../core/api/dio_client.dart';
import '../orders/models/order_model.dart';
import 'widgets/rating_stars.dart';

class CreateReviewPage extends StatefulWidget {
  final OrderModel order;

  const CreateReviewPage({super.key, required this.order});

  @override
  State<CreateReviewPage> createState() => _CreateReviewPageState();
}

class _CreateReviewPageState extends State<CreateReviewPage>
    with TickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();
  int _rating = 0;
  bool _isSubmitting = false;
  String? _errorMessage;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Animation de glissement
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    // Animation de fade
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    // Démarrer les animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    // Validation
    if (_rating == 0) {
      setState(() => _errorMessage = 'Veuillez donner une note');
      return;
    }

    if (_commentController.text.trim().length < 5) {
      setState(
        () =>
            _errorMessage =
                'Le commentaire doit contenir au moins 5 caractères',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final dioClient = await DioClient.create();

      await dioClient.dio.post(
        '/orders/${widget.order.id}/review',
        data: {'rating': _rating, 'comment': _commentController.text.trim()},
      );

      if (!mounted) return;

      // Succès - retour avec résultat
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Merci pour votre avis ! Il sera publié après modération.',
          ),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = _parseError(e);
      });
    }
  }

  String _parseError(dynamic error) {
    if (error.toString().contains('already reviewed')) {
      return 'Vous avez déjà laissé un avis pour cette commande';
    }
    if (error.toString().contains('not found')) {
      return 'Commande introuvable';
    }
    if (error.toString().contains('DELIVERED') ||
        error.toString().contains('COMPLETED')) {
      return 'Vous ne pouvez laisser un avis que pour les commandes livrées ou terminées';
    }
    return 'Une erreur est survenue. Veuillez réessayer.';
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = context.horizontalPadding;
    final maxWidth = context.maxContentWidth;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Évaluer ma commande',
          style: AppTextStyles.cardTitle.copyWith(color: AppColors.textPrimary),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth.clamp(0, 600)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // En-tête élégant
                    GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.2),
                                  AppColors.primary.withValues(alpha: 0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Icon(
                              Icons.rate_review,
                              size: 40,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Votre avis compte !',
                            style: AppTextStyles.sectionTitle,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Partagez votre expérience avec la communauté',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Informations commande
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.glassFill,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: Text(
                              widget.order.status.emoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Commande #${widget.order.id}',
                                  style: AppTextStyles.cardTitle.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${widget.order.eventCity} • ${widget.order.formattedDate}',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Formulaire d'évaluation
                    GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Note
                          Text(
                            'Votre note *',
                            style: AppTextStyles.subtitle.copyWith(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: RatingStars(
                              rating: _rating,
                              onRatingChanged: (rating) {
                                setState(() {
                                  _rating = rating;
                                  _errorMessage = null;
                                });
                              },
                              size: 48,
                            ),
                          ),
                          if (_rating > 0) ...[
                            const SizedBox(height: 12),
                            Center(
                              child: Text(
                                _getRatingLabel(_rating),
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 32),

                          // Commentaire
                          Text(
                            'Votre commentaire *',
                            style: AppTextStyles.subtitle.copyWith(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _commentController,
                            maxLines: 6,
                            maxLength: 500,
                            decoration: InputDecoration(
                              hintText:
                                  'Partagez votre expérience en détail...',
                              hintStyle: AppTextStyles.body.copyWith(
                                color: AppColors.textMuted,
                              ),
                              filled: true,
                              fillColor: AppColors.glassFill,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: AppColors.glassBorder,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),

                          if (_errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.danger.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.danger.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: AppColors.danger,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.danger,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Bouton de soumission
                          PrimaryButton(
                            label: 'Publier mon avis',
                            onPressed: _isSubmitting ? null : _submitReview,
                            isLoading: _isSubmitting,
                          ),

                          const SizedBox(height: 12),

                          Text(
                            'Votre avis sera publié après modération par notre équipe.',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textMuted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Décevant';
      case 2:
        return 'Moyen';
      case 3:
        return 'Bien';
      case 4:
        return 'Très bien';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }
}
