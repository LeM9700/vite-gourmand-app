import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/glass_card.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Conditions Générales de Vente',
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
                              AppColors.success.withOpacity(0.2),
                              AppColors.success.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.gavel_rounded,
                          color: AppColors.success,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CGV',
                              style: AppTextStyles.cardTitle,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Conditions générales de vente',
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
              title: '1. Objet',
              content: '''
Les présentes Conditions Générales de Vente (CGV) régissent les relations contractuelles entre Vite & Gourmand SARL (ci-après "le Prestataire") et toute personne physique ou morale (ci-après "le Client") souhaitant bénéficier des services de traiteur proposés.

Toute commande implique l'acceptation sans réserve des présentes CGV qui prévalent sur tout autre document.
''',
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              title: '2. Services proposés',
              content: '''
Vite & Gourmand propose des prestations de traiteur événementiel comprenant :
- La préparation de menus personnalisés
- La livraison des plats préparés
- Le service sur place (selon formule choisie)
- La fourniture de matériel (vaisselle, nappage, etc.)

Tous nos menus sont préparés avec des produits frais et de qualité. Les menus peuvent être adaptés selon les régimes alimentaires et allergies, sous réserve de nous en informer lors de la commande.
''',
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              title: '3. Commandes',
              content: '''
Les commandes peuvent être effectuées :
- En ligne via notre site web
- Par téléphone au +33 1 23 45 67 89
- Par email à commandes@vite-gourmand.fr

Toute commande doit être passée au minimum 48 heures avant la date de l'événement. Pour les événements de plus de 50 personnes, un délai de 7 jours est requis.

Une confirmation écrite sera envoyée au Client après validation de la commande.
''',
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              title: '4. Tarifs et paiement',
              content: '''
Tous les tarifs sont indiqués en euros TTC et incluent la TVA applicable.

Les prix comprennent :
- La préparation des plats
- L'emballage adapté au transport
- La livraison dans un rayon de 30 km

Un acompte de 30% du montant total est requis à la commande. Le solde est à régler au plus tard 48 heures avant la livraison.

Moyens de paiement acceptés :
- Carte bancaire
- Virement bancaire
- Chèque (avec présentation de pièce d'identité)
''',
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              title: '5. Livraison',
              content: '''
Les livraisons sont effectuées dans un rayon de 30 km autour de notre établissement. Au-delà, un supplément sera appliqué.

Les horaires de livraison sont à définir lors de la commande. Le Client doit être présent ou désigner une personne pour réceptionner la commande.

Le Prestataire ne saurait être tenu responsable des retards de livraison dus à des cas de force majeure (conditions météorologiques, grèves, accidents, etc.).
''',
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              title: '6. Modifications et annulations',
              content: '''
Modifications :
Toute modification de commande doit être notifiée au moins 72 heures avant la date de livraison. Les modifications tardives peuvent entraîner des frais supplémentaires.

Annulations :
- Plus de 7 jours avant l'événement : remboursement intégral de l'acompte
- Entre 7 et 3 jours : retenue de 50% de l'acompte
- Moins de 3 jours : aucun remboursement

En cas d'annulation pour cause de force majeure justifiée, un avoir sera proposé.
''',
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              title: '7. Réclamations',
              content: '''
Toute réclamation doit être formulée dans les 24 heures suivant la livraison :
- Par email : reclamations@vite-gourmand.fr
- Par téléphone : +33 1 23 45 67 89

Les réclamations doivent être accompagnées de justificatifs (photos, descriptions précises).

Le Prestataire s'engage à traiter toute réclamation dans un délai de 48 heures et à proposer une solution adaptée (avoir, geste commercial, etc.).
''',
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              title: '8. Hygiène et sécurité alimentaire',
              content: '''
Vite & Gourmand respecte strictement les normes HACCP et les réglementations en vigueur concernant l'hygiène alimentaire.

Le Client s'engage à :
- Consommer les plats dans les délais indiqués
- Respecter la chaîne du froid
- Conserver les plats dans des conditions appropriées

Le Prestataire décline toute responsabilité en cas de non-respect de ces consignes.
''',
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              title: '9. Allergènes',
              content: '''
Les informations relatives aux allergènes présents dans nos plats sont disponibles sur demande.

Le Client doit impérativement signaler toute allergie ou intolérance alimentaire lors de la commande. Le Prestataire fera son maximum pour adapter les menus, mais ne peut garantir l'absence totale de traces d'allergènes.
''',
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              title: '10. Données personnelles',
              content: '''
Les données personnelles collectées sont traitées conformément au RGPD. Elles sont utilisées uniquement pour la gestion des commandes et ne sont jamais communiquées à des tiers.

Le Client dispose d'un droit d'accès, de rectification et de suppression de ses données en contactant : rgpd@vite-gourmand.fr
''',
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              title: '11. Responsabilité',
              content: '''
La responsabilité du Prestataire est limitée au montant de la prestation commandée.

Le Prestataire ne saurait être tenu responsable :
- Des dommages indirects
- De l'utilisation inappropriée des produits livrés
- Des allergies non signalées
- Des cas de force majeure
''',
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              title: '12. Droit applicable et litiges',
              content: '''
Les présentes CGV sont soumises au droit français.

En cas de litige, une solution amiable sera recherchée en priorité. À défaut, les tribunaux de Paris seront seuls compétents.

Le Client peut également recourir à la médiation de la consommation en contactant : 
Médiateur de la consommation
www.mediateur-consommation.fr
''',
            ),
            
            const SizedBox(height: 32),
            
            // Footer info
            GlassCard(
              borderColor: AppColors.info.withOpacity(0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.warning.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: AppColors.warning,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'En passant commande, vous acceptez ces conditions générales de vente.',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
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
