import 'package:flutter/material.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/colors.dart';
import '../../../core/utils/responsive.dart';

class HomeSectionAbout extends StatelessWidget {
  const HomeSectionAbout({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    // Valeurs fluides pour le responsive
    final padding = context.fluidValue(minValue: 16, maxValue: 32);
    final spacing = context.fluidValue(minValue: 16, maxValue: 32);
    final quoteSize = context.fluidValue(minValue: 16, maxValue: 22);
    final bodySize = context.fluidValue(minValue: 13, maxValue: 15);
    final avatarSize = context.fluidValue(minValue: 60, maxValue: 100);
    final iconSize = context.fluidValue(minValue: 24, maxValue: 40);
    final titleSize = context.fluidValue(minValue: 15, maxValue: 18);
    final subtitleSize = context.fluidValue(minValue: 10, maxValue: 12);
    final descriptionSize = context.fluidValue(minValue: 11, maxValue: 13);
    final badgePaddingH = context.fluidValue(minValue: 10, maxValue: 16);
    final badgePaddingV = context.fluidValue(minValue: 5, maxValue: 8);

    return Column(
      children: [
        // Section principale avec quote élégante
        GlassCard(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              // Quote mark ornementale
              Container(
                width: context.fluidValue(minValue: 40, maxValue: 60),
                height: context.fluidValue(minValue: 3, maxValue: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.saffron],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              SizedBox(height: spacing * 0.75),

              // Citation élégante
              Text(
                "\"L'excellence culinaire rencontre l'art de recevoir\"",
                style: AppTextStyles.elegantQuote.copyWith(
                  fontSize: quoteSize,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: spacing * 0.5),

              Text(
                "Julie et José orchestrent vos événements privés et professionnels avec une exigence sans compromis et une passion gourmande.",
                style: AppTextStyles.body.copyWith(
                  fontSize: bodySize,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        SizedBox(height: spacing),

        // Section José & Julie - Responsive Column/Row
        isSmallScreen
            ? Column(
              children: [
                _buildProfileCard(
                  context: context,
                  name: 'José',
                  title: 'Maître de la Logistique',
                  description:
                      'Orchestrateur méticuleux, José transforme chaque événement en symphonie logistique parfaite.',
                  badge: 'Excellence Logistique',
                  icon: Icons.precision_manufacturing_rounded,
                  gradientColors: [AppColors.truffle, AppColors.caviar],
                  badgeGradient: [
                    AppColors.truffle.withValues(alpha: 0.1),
                    AppColors.caviar.withValues(alpha: 0.05),
                  ],
                  badgeColor: AppColors.truffle,
                  padding: padding,
                  avatarSize: avatarSize,
                  iconSize: iconSize,
                  titleSize: titleSize,
                  subtitleSize: subtitleSize,
                  descriptionSize: descriptionSize,
                  badgePaddingH: badgePaddingH,
                  badgePaddingV: badgePaddingV,
                  spacing: spacing,
                ),
                SizedBox(height: spacing * 0.75),
                _buildProfileCard(
                  context: context,
                  name: 'Julie',
                  title: 'Maître Cuisinier',
                  description:
                      'Artiste culinaire au cœur généreux, Julie sublime chaque recette avec créativité et passion.',
                  badge: 'Art Culinaire',
                  icon: Icons.restaurant_menu_rounded,
                  gradientColors: [AppColors.primary, AppColors.saffron],
                  badgeGradient: [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.saffron.withValues(alpha: 0.1),
                  ],
                  badgeColor: AppColors.primary,
                  padding: padding,
                  avatarSize: avatarSize,
                  iconSize: iconSize,
                  titleSize: titleSize,
                  subtitleSize: subtitleSize,
                  descriptionSize: descriptionSize,
                  badgePaddingH: badgePaddingH,
                  badgePaddingV: badgePaddingV,
                  spacing: spacing,
                ),
              ],
            )
            : Row(
              children: [
                Expanded(
                  child: _buildProfileCard(
                    context: context,
                    name: 'José',
                    title: 'Maître de la Logistique',
                    description:
                        'Orchestrateur méticuleux, José transforme chaque événement en symphonie logistique parfaite.',
                    badge: 'Excellence Logistique',
                    icon: Icons.precision_manufacturing_rounded,
                    gradientColors: [AppColors.truffle, AppColors.caviar],
                    badgeGradient: [
                      AppColors.truffle.withValues(alpha: 0.1),
                      AppColors.caviar.withValues(alpha: 0.05),
                    ],
                    badgeColor: AppColors.truffle,
                    padding: padding,
                    avatarSize: avatarSize,
                    iconSize: iconSize,
                    titleSize: titleSize,
                    subtitleSize: subtitleSize,
                    descriptionSize: descriptionSize,
                    badgePaddingH: badgePaddingH,
                    badgePaddingV: badgePaddingV,
                    spacing: spacing,
                  ),
                ),
                SizedBox(width: spacing * 0.75),
                Expanded(
                  child: _buildProfileCard(
                    context: context,
                    name: 'Julie',
                    title: 'Maître Cuisinier',
                    description:
                        'Artiste culinaire au cœur généreux, Julie sublime chaque recette avec créativité et passion.',
                    badge: 'Art Culinaire',
                    icon: Icons.restaurant_menu_rounded,
                    gradientColors: [AppColors.primary, AppColors.saffron],
                    badgeGradient: [
                      AppColors.primary.withValues(alpha: 0.15),
                      AppColors.saffron.withValues(alpha: 0.1),
                    ],
                    badgeColor: AppColors.primary,
                    padding: padding,
                    avatarSize: avatarSize,
                    iconSize: iconSize,
                    titleSize: titleSize,
                    subtitleSize: subtitleSize,
                    descriptionSize: descriptionSize,
                    badgePaddingH: badgePaddingH,
                    badgePaddingV: badgePaddingV,
                    spacing: spacing,
                  ),
                ),
              ],
            ),

        SizedBox(height: spacing * 1.25),

        // Section engagement - Layout vertical lisible
        GlassCard(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              // Titre simple et lisible
              Text(
                'Notre Engagement',
                style: AppTextStyles.sectionTitle.copyWith(
                  fontSize: context.fluidValue(minValue: 18, maxValue: 24),
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: spacing * 0.75),

              // Points en vertical - plus lisible
              _buildSimpleEngagementPoint(
                context,
                Icons.palette_rounded,
                'Sur Mesure',
                'Chaque création reflète votre identité et vos aspirations culinaires.',
              ),

              SizedBox(height: spacing * 0.5),

              _buildSimpleEngagementPoint(
                context,
                Icons.diamond_rounded,
                'Excellence',
                'Produits d\'exception, techniques maîtrisées, service impeccable.',
              ),

              SizedBox(height: spacing * 0.5),

              _buildSimpleEngagementPoint(
                context,
                Icons.favorite_rounded,
                'Émotion',
                'Nous créons des souvenirs gourmands qui marquent les cœurs.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard({
    required BuildContext context,
    required String name,
    required String title,
    required String description,
    required String badge,
    required IconData icon,
    required List<Color> gradientColors,
    required List<Color> badgeGradient,
    required Color badgeColor,
    required double padding,
    required double avatarSize,
    required double iconSize,
    required double titleSize,
    required double subtitleSize,
    required double descriptionSize,
    required double badgePaddingH,
    required double badgePaddingV,
    required double spacing,
  }) {
    return GlassCard(
      padding: EdgeInsets.all(padding),
      child: Column(
        children: [
          // Avatar - Design premium
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(avatarSize / 2),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[0].withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
              ),
              Container(
                width: avatarSize - 4,
                height: avatarSize - 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular((avatarSize - 4) / 2),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Icon(icon, color: AppColors.champagne, size: iconSize),
              ),
            ],
          ),

          SizedBox(height: spacing * 0.6),

          // Nom
          Text(
            name,
            style: AppTextStyles.cardTitle.copyWith(
              fontSize: titleSize,
              color: AppColors.textPrimary,
              letterSpacing: 1.2,
            ),
          ),

          SizedBox(height: spacing * 0.25),

          Text(
            title,
            style: AppTextStyles.overline.copyWith(
              fontSize: subtitleSize,
              color: AppColors.primary,
              letterSpacing: 1.5,
            ),
          ),

          SizedBox(height: spacing * 0.5),

          // Description
          Text(
            description,
            style: AppTextStyles.caption.copyWith(
              fontSize: descriptionSize,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: spacing * 0.6),

          // Badge spécialité - Design premium
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: badgePaddingH,
              vertical: badgePaddingV,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: badgeGradient),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: badgeColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Text(
              badge,
              style: AppTextStyles.caption.copyWith(
                fontSize: descriptionSize - 1,
                color: badgeColor,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget simple et lisible pour les points d'engagement
  Widget _buildSimpleEngagementPoint(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    final iconContainerSize = context.fluidValue(minValue: 36, maxValue: 50);
    final iconSize = context.fluidValue(minValue: 18, maxValue: 24);
    final titleSize = context.fluidValue(minValue: 13, maxValue: 16);
    final descSize = context.fluidValue(minValue: 12, maxValue: 14);
    final spacing = context.fluidValue(minValue: 10, maxValue: 16);

    return Row(
      children: [
        // Icône dans un container doré
        Container(
          width: iconContainerSize,
          height: iconContainerSize,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.saffron],
            ),
            borderRadius: BorderRadius.circular(iconContainerSize / 2),
          ),
          child: Icon(icon, color: Colors.white, size: iconSize),
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
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
