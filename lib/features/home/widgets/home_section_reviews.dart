import 'package:flutter/material.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/colors.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/utils/responsive.dart';

class HomeSectionReviews extends StatefulWidget {
  const HomeSectionReviews({super.key});

  @override
  State<HomeSectionReviews> createState() => _HomeSectionReviewsState();
}

class _HomeSectionReviewsState extends State<HomeSectionReviews> {
  List<ReviewModel> reviews = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      setState(() => isLoading = true);
      
      final dioClient = await DioClient.create();
      final response = await dioClient.dio.get(
        '/reviews/approved?limit=7&sort_by=rating&order=desc',
      );
      
      if (response.data != null) {
        final List<dynamic> reviewsData;
        
        // Gérer différents formats de réponse
        if (response.data is List) {
          reviewsData = response.data;
        } else if (response.data is Map && response.data['reviews'] != null) {
          reviewsData = response.data['reviews'];
        } else if (response.data is Map && response.data['data'] != null) {
          reviewsData = response.data['data'];
        } else {
          throw Exception('Format de données inattendu');
        }
        
        setState(() {
          reviews = reviewsData
              .map((item) => ReviewModel.fromJson(item))
              .toList();
          isLoading = false;
          error = null;
        });
      }
    } catch (e) {
      print('Erreur lors du chargement des avis: $e');
      setState(() {
        isLoading = false;
        error = e.toString();
        // Données de fallback
        reviews = [
          ReviewModel(
            name: 'Sophie M.',
            rating: 5,
            comment: 'Service impeccable, livraison parfaite.',
            date: DateTime.now().subtract(const Duration(days: 2)),
          ),
          ReviewModel(
            name: 'Karim B.',
            rating: 5,
            comment: 'Plats délicieux, présentation soignée.',
            date: DateTime.now().subtract(const Duration(days: 5)),
          ),
          ReviewModel(
            name: 'Emma L.',
            rating: 4,
            comment: 'Menu Noël incroyable, je recommande vivement.',
            date: DateTime.now().subtract(const Duration(days: 8)),
          ),
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = context.fluidValue(minValue: 16, maxValue: 24);
    final spacing = context.fluidValue(minValue: 12, maxValue: 16);
    final iconSize = context.fluidValue(minValue: 36, maxValue: 50);
    final iconInnerSize = context.fluidValue(minValue: 18, maxValue: 24);
    final titleSize = context.fluidValue(minValue: 16, maxValue: 20);
    final subtitleSize = context.fluidValue(minValue: 12, maxValue: 14);
    final cardWidth = context.fluidValue(minValue: 220, maxValue: 280);
    final cardHeight = context.fluidValue(minValue: 130, maxValue: 160);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête simple et lisible
        GlassCard(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.saffron],
                      ),
                      borderRadius: BorderRadius.circular(iconSize / 2),
                    ),
                    child: Icon(
                      Icons.reviews,
                      color: Colors.white,
                      size: iconInnerSize,
                    ),
                  ),
                  
                  SizedBox(width: spacing),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Avis Clients',
                          style: AppTextStyles.sectionTitle.copyWith(
                            fontSize: titleSize,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: spacing * 0.25),
                        Text(
                          'La confiance de nos clients fait notre fierté',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: subtitleSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  if (isLoading)
                    SizedBox(
                      width: context.fluidValue(minValue: 18, maxValue: 24),
                      height: context.fluidValue(minValue: 18, maxValue: 24),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        
        SizedBox(height: spacing),
        
        // Liste scrollable horizontale
        SizedBox(
          height: cardHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: padding * 0.85),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return Container(
                width: cardWidth,
                margin: EdgeInsets.only(
                  right: index == reviews.length - 1 ? 0 : spacing * 0.75,
                ),
                child: _ReviewCard(review: review),
              );
            },
          ),
        ),
        
        // Message d'erreur si nécessaire
        if (error != null && !isLoading)
          Padding(
            padding: EdgeInsets.all(padding),
            child: GlassCard(
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.secondary, size: iconInnerSize * 0.85),
                  SizedBox(width: spacing * 0.5),
                  Expanded(
                    child: Text(
                      'Connexion à l\'API en cours...',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: subtitleSize * 0.9,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;

  const _ReviewCard({
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    final padding = context.fluidValue(minValue: 12, maxValue: 16);
    final starSize = context.fluidValue(minValue: 14, maxValue: 18);
    final commentSize = context.fluidValue(minValue: 12, maxValue: 15);
    final nameSize = context.fluidValue(minValue: 13, maxValue: 16);
    final dateSize = context.fluidValue(minValue: 9, maxValue: 11);
    final spacing = context.fluidValue(minValue: 10, maxValue: 16);
    
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Étoiles dorées élégantes
          Row(
            children: List.generate(5, (index) {
              return Padding(
                padding: const EdgeInsets.only(right: 2),
                child: Icon(
                  index < review.rating ? Icons.star_rounded : Icons.star_border_rounded,
                  color: index < review.rating 
                      ? AppColors.primary
                      : AppColors.mediumGrey,
                  size: starSize,
                ),
              );
            }),
          ),
          
          SizedBox(height: spacing),
          
          // Commentaire stylisé
          Expanded(
            child: Text(
              '"${review.comment}"',
              style: AppTextStyles.body.copyWith(
                fontSize: commentSize,
                height: 1.5,
                fontStyle: FontStyle.italic,
                color: AppColors.textPrimary,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          SizedBox(height: spacing * 1.2),
          
          // Signature élégante
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  review.name,
                  style: AppTextStyles.cardTitle.copyWith(
                    fontSize: nameSize,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.fluidValue(minValue: 6, maxValue: 8),
                  vertical: context.fluidValue(minValue: 3, maxValue: 4),
                ),
                decoration: BoxDecoration(
                  color: AppColors.champagne.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _formatDate(review.date),
                  style: AppTextStyles.caption.copyWith(
                    fontSize: dateSize,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year}';
  }
}

class ReviewModel {
  final String name;
  final int rating;
  final String comment;
  final DateTime date;

  ReviewModel({
    required this.name,
    required this.rating,
    required this.comment,
    required this.date,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      name: json['customer_name'] ?? json['name'] ?? 'Client',
      rating: (json['rating'] ?? 5).round(),
      comment: json['comment'] ?? json['review'] ?? '',
      date: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : json['date'] != null
              ? DateTime.parse(json['date'])
              : DateTime.now(),
    );
  }
}
