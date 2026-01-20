import 'package:flutter/material.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/colors.dart';
import '../../../core/utils/responsive.dart';

class HomeSectionTeam extends StatelessWidget {
  const HomeSectionTeam({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = context.fluidValue(minValue: 16, maxValue: 24);
    final spacing = context.fluidValue(minValue: 12, maxValue: 16);
    final titleSize = context.fluidValue(minValue: 18, maxValue: 24);
    final bodySize = context.fluidValue(minValue: 13, maxValue: 15);
    
    return Column(
      children: [
        // Titre principal simple et lisible
        GlassCard(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              Text(
                'Notre Professionnalisme',
                style: AppTextStyles.sectionTitle.copyWith(
                  fontSize: titleSize,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: spacing * 0.75),
              
              Text(
                'Une équipe passionnée, des standards d\'exception et un savoir-faire reconnu depuis plus de 25 ans.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: bodySize,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        SizedBox(height: spacing),

        // Points forts en vertical - plus lisible
        GlassCard(
          padding: EdgeInsets.all(padding * 0.85),
          child: Column(
            children: [
              _buildSimpleProfessionalismPoint(
                context,
                Icons.verified,
                'Qualité & Fraîcheur',
                'Produits sélectionnés avec exigence',
                AppColors.success,
              ),
              
              SizedBox(height: spacing),
              
              _buildSimpleProfessionalismPoint(
                context,
                Icons.handshake,
                'Respect des délais',
                'Une organisation maîtrisée',
                AppColors.info,
              ),
              
              SizedBox(height: spacing),
              
              _buildSimpleProfessionalismPoint(
                context,
                Icons.star_rounded,
                'Expérience reconnue',
                'Plus de 25 ans de savoir-faire',
                AppColors.primary,
              ),
            ],
          ),
        ),

        SizedBox(height: spacing),

        // Section équipe avec statistiques
        GlassCard(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              Text(
                'Notre Équipe en Chiffres',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: context.fluidValue(minValue: 14, maxValue: 16),
                  color: AppColors.textPrimary,
                ),
              ),
              
              SizedBox(height: spacing),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(context, '👥', '12', 'Collaborateurs'),
                  Container(
                    width: 1, 
                    height: context.fluidValue(minValue: 30, maxValue: 40), 
                    color: AppColors.glassBorder,
                  ),
                  _buildStatItem(context, '🎯', '500+', 'Événements'),
                  Container(
                    width: 1, 
                    height: context.fluidValue(minValue: 30, maxValue: 40), 
                    color: AppColors.glassBorder,
                  ),
                  _buildStatItem(context, '😊', '98%', 'Satisfaction'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget simple et lisible pour les points de professionnalisme
  Widget _buildSimpleProfessionalismPoint(BuildContext context, IconData icon, String title, String description, Color color) {
    final iconContainerSize = context.fluidValue(minValue: 36, maxValue: 50);
    final iconSize = context.fluidValue(minValue: 18, maxValue: 24);
    final titleSize = context.fluidValue(minValue: 13, maxValue: 16);
    final descSize = context.fluidValue(minValue: 12, maxValue: 14);
    final spacing = context.fluidValue(minValue: 10, maxValue: 16);
    
    return Row(
      children: [
        // Icône colorée
        Container(
          width: iconContainerSize,
          height: iconContainerSize,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(iconContainerSize / 2),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: iconSize,
          ),
        ),
        
        SizedBox(width: spacing),
        
        // Texte en full width
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTextStyles.body.copyWith(
                  fontSize: descSize,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String emoji, String number, String label) {
    final emojiSize = context.fluidValue(minValue: 18, maxValue: 24);
    final numberSize = context.fluidValue(minValue: 14, maxValue: 18);
    final labelSize = context.fluidValue(minValue: 9, maxValue: 11);
    
    return Column(
      children: [
        Text(
          emoji,
          style: TextStyle(fontSize: emojiSize),
        ),
        const SizedBox(height: 4),
        Text(
          number,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: numberSize,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontSize: labelSize,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
