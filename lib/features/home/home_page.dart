import 'package:flutter/material.dart';
import '../../core/theme/typography.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/utils/responsive.dart';
import 'widgets/app_drawer.dart';
import 'widgets/home_section_about.dart';
import 'widgets/home_section_team.dart';
import 'widgets/home_section_reviews.dart';
import 'widgets/home_section_footer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Hauteur hero responsive fluide
    final heroHeight = context.fluidValue(minValue: 300, maxValue: 500);

    // Taille du logo responsive fluide
    final logoSize = context.fluidValue(minValue: 140, maxValue: 280);

    // Afficher sidebar seulement sur grands écrans (>= 1024px)
    final showSidebar = context.isLargeDesktop;

    return Scaffold(
      backgroundColor: const Color(0xEEEDE4E4), // Fond #EDE4E4 93%
      drawer: !showSidebar ? const AppDrawer() : null,
      body: Row(
        children: [
          // Sidebar pour desktop uniquement
          if (showSidebar)
            SizedBox(
              width: context.fluidValue(
                minValue: 240,
                maxValue: 300,
                minWidth: 1024,
                maxWidth: 1600,
              ),
              child: const AppDrawer(),
            ),

          // Contenu principal
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Section Hero
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      // Background image
                      Container(
                        height: heroHeight,
                        width: double.infinity,
                        child: Image.asset(
                          'assets/images/splash_bg.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),

                      // Overlay noir 25%
                      Container(
                        height: heroHeight,
                        width: double.infinity,
                        color: const Color.fromARGB(
                          255,
                          189,
                          189,
                          189,
                        ).withValues(alpha: 0.25),
                      ),

                      // Header avec menu (seulement si pas de sidebar)
                      if (!showSidebar) SafeArea(child: _Header()),

                      // Logo centré
                      Positioned.fill(
                        child: Center(
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: logoSize,
                            height: logoSize,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Contenu principal avec fond #EDE4E4
                SliverToBoxAdapter(
                  child: Container(
                    color: const Color(0xEEEDE4E4),
                    child: ResponsiveContainer(
                      maxWidth: 1400,
                      padding: EdgeInsets.symmetric(
                        horizontal: context.horizontalPadding,
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: context.fluidValue(
                              minValue: 20,
                              maxValue: 40,
                            ),
                          ),
                          const HomeSectionAbout(),
                          SizedBox(
                            height: context.fluidValue(
                              minValue: 16,
                              maxValue: 32,
                            ),
                          ),
                          const HomeSectionTeam(),
                          SizedBox(
                            height: context.fluidValue(
                              minValue: 16,
                              maxValue: 32,
                            ),
                          ),
                          const HomeSectionReviews(),
                          SizedBox(
                            height: context.fluidValue(
                              minValue: 16,
                              maxValue: 32,
                            ),
                          ),
                          const HomeSectionFooter(),
                          SizedBox(
                            height: context.fluidValue(
                              minValue: 20,
                              maxValue: 40,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final titleSize = context.fluidValue(minValue: 18, maxValue: 26);
    final iconSize = context.fluidValue(minValue: 22, maxValue: 28);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.horizontalPadding,
        8,
        context.horizontalPadding,
        0,
      ),
      child: Row(
        children: [
          // Burger
          IconButton(
            icon: Icon(Icons.menu, size: iconSize),
            color: Colors.white,
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
          SizedBox(width: context.fluidValue(minValue: 4, maxValue: 12)),
          Expanded(
            child: Text(
              'Accueil',
              style: AppTextStyles.sectionTitle.copyWith(
                color: Colors.white,
                fontSize: titleSize,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(width: context.fluidValue(minValue: 4, maxValue: 12)),
          // Petit badge "Avis validés"
          GlassCard(
            padding: EdgeInsets.symmetric(
              horizontal: context.fluidValue(minValue: 8, maxValue: 14),
              vertical: context.fluidValue(minValue: 6, maxValue: 10),
            ),
            radius: 999,
            child: Text(
              'Avis validés',
              style: AppTextStyles.caption.copyWith(
                fontSize: context.fluidValue(minValue: 10, maxValue: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
