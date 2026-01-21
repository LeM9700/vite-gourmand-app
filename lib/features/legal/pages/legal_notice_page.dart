import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/glass_card.dart';

class LegalNoticePage extends StatelessWidget {
  const LegalNoticePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Mentions légales',
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primary),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            
            // Header
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.2),
                              AppColors.primary.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mentions légales',
                              style: AppTextStyles.cardTitle,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Informations légales et éditoriales',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            _buildSection(
              title: '1. Identification de l\'entreprise',
              content: '''
Raison sociale : Vite & Gourmand SARL
Siège social : 123 Avenue Gastronomique, 75001 Paris, France
Téléphone : +33 1 23 45 67 89
Email : contact@vite-gourmand.fr
SIRET : 123 456 789 00012
TVA intracommunautaire : FR 12 123456789

Capital social : 50 000 €
Forme juridique : Société à Responsabilité Limitée (SARL)
Directeur de la publication : M. Jean Dupont
''',
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              title: '2. Hébergement',
              content: '''
Le site est hébergé par :
Nom : OVH
Adresse : 2 rue Kellermann, 59100 Roubaix, France
Téléphone : 1007
''',
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              title: '3. Propriété intellectuelle',
              content: '''
L'ensemble de ce site relève de la législation française et internationale sur le droit d'auteur et la propriété intellectuelle. Tous les droits de reproduction sont réservés, y compris pour les documents téléchargeables et les représentations iconographiques et photographiques.

La reproduction de tout ou partie de ce site sur un support électronique quel qu'il soit est formellement interdite sauf autorisation expresse du directeur de la publication.
''',
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              title: '4. Données personnelles',
              content: '''
Conformément au Règlement Général sur la Protection des Données (RGPD), vous disposez d'un droit d'accès, de rectification, de suppression et d'opposition aux données personnelles vous concernant.

Pour exercer ces droits, vous pouvez nous contacter :
- Par email : rgpd@vite-gourmand.fr
- Par courrier : Vite & Gourmand, Service RGPD, 123 Avenue Gastronomique, 75001 Paris

Les données collectées sont uniquement destinées à la gestion de votre commande et ne seront en aucun cas cédées à des tiers.
''',
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              title: '5. Cookies',
              content: '''
Ce site utilise des cookies nécessaires au bon fonctionnement du site et à l'amélioration de votre expérience utilisateur.

Vous pouvez à tout moment vous opposer à l'utilisation de ces cookies en configurant votre navigateur. Toutefois, certaines fonctionnalités du site pourraient ne plus être accessibles.
''',
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              title: '6. Liens hypertextes',
              content: '''
Les liens hypertextes mis en place dans le cadre du présent site en direction d'autres ressources présentes sur le réseau Internet ne sauraient engager la responsabilité de Vite & Gourmand.
''',
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              title: '7. Limitation de responsabilité',
              content: '''
Vite & Gourmand ne pourra être tenu responsable des dommages directs et indirects causés au matériel de l'utilisateur lors de l'accès au site, et résultant soit de l'utilisation d'un matériel ne répondant pas aux spécifications techniques requises, soit de l'apparition d'un bug ou d'une incompatibilité.

Vite & Gourmand ne pourra également être tenu responsable des dommages indirects (tels par exemple qu'une perte de marché ou perte d'une chance) consécutifs à l'utilisation du site.
''',
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              title: '8. Droit applicable',
              content: '''
Les présentes mentions légales sont régies par le droit français. En cas de litige, les tribunaux français seront seuls compétents.
''',
            ),
            
            const SizedBox(height: 32),
            
            // Footer info
            GlassCard(
              borderColor: AppColors.info.withValues(alpha: 0.3),
              child: Row(
                children: [
                  Icon(
                    Icons.update_rounded,
                    color: AppColors.info,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Dernière mise à jour : 14 janvier 2026',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.subtitle.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            content.trim(),
            style: AppTextStyles.body.copyWith(
              height: 1.6,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
