import 'package:flutter/material.dart';

/// Breakpoints pour le design responsive
class Breakpoints {
  static const double mobile = 480;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double widescreen = 1440;
}

/// Types d'écran
enum ScreenType { mobile, tablet, desktop, widescreen }

/// Extension pour faciliter les calculs responsive
extension ResponsiveContext on BuildContext {
  /// Largeur de l'écran
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Hauteur de l'écran
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Type d'écran actuel
  ScreenType get screenType {
    final width = screenWidth;
    if (width < Breakpoints.mobile) return ScreenType.mobile;
    if (width < Breakpoints.tablet) return ScreenType.tablet;
    if (width < Breakpoints.desktop) return ScreenType.desktop;
    return ScreenType.widescreen;
  }

  /// Vérifie si c'est un mobile (< 480px)
  bool get isMobile => screenWidth < Breakpoints.mobile;

  /// Vérifie si c'est un petit écran mobile/tablette (< 768px)
  bool get isSmallScreen => screenWidth < Breakpoints.tablet;

  /// Vérifie si c'est une tablette (480-768px)
  bool get isTablet =>
      screenWidth >= Breakpoints.mobile && screenWidth < Breakpoints.tablet;

  /// Vérifie si c'est un desktop (>= 768px)
  bool get isDesktop => screenWidth >= Breakpoints.tablet;

  /// Vérifie si c'est un grand desktop (>= 1024px)
  bool get isLargeDesktop => screenWidth >= Breakpoints.desktop;

  /// Vérifie si c'est un écran large (>= 1440px)
  bool get isWidescreen => screenWidth >= Breakpoints.widescreen;

  /// Facteur de scale basé sur la largeur (fluide)
  double get scaleFactor {
    final width = screenWidth;
    if (width <= 320) return 0.75;
    if (width <= 480) return 0.85;
    if (width <= 600) return 0.95;
    if (width <= 768) return 1.0;
    if (width <= 1024) return 1.1;
    if (width <= 1440) return 1.2;
    return 1.3;
  }

  /// Padding horizontal responsive (fluide)
  double get horizontalPadding {
    final width = screenWidth;
    if (width < 400) return 12;
    if (width < 600) return 16;
    if (width < 900) return 24;
    if (width < 1200) return 32;
    return 48;
  }

  /// Padding vertical responsive
  double get verticalPadding {
    if (screenWidth < 600) return 16;
    if (screenWidth < 900) return 20;
    return 24;
  }

  /// Largeur maximale du contenu
  double get maxContentWidth {
    if (screenWidth < 600) return screenWidth;
    if (screenWidth < 900) return 720;
    if (screenWidth < 1200) return 960;
    return 1200;
  }

  /// Nombre de colonnes pour les grilles (fluide)
  int get gridColumns {
    final width = screenWidth;
    if (width < 500) return 1;
    if (width < 800) return 2;
    if (width < 1100) return 3;
    return 4;
  }

  /// Espacement entre les éléments de grille
  double get gridSpacing {
    if (screenWidth < 600) return 12;
    if (screenWidth < 900) return 16;
    return 24;
  }

  /// Taille de police responsive (fluide)
  double responsiveFontSize(double baseSize) {
    return baseSize * scaleFactor;
  }

  /// Taille d'icône responsive
  double responsiveIconSize(double baseSize) {
    return baseSize * scaleFactor;
  }

  /// Calcul fluide entre deux valeurs selon la largeur
  double fluidValue({
    required double minValue,
    required double maxValue,
    double minWidth = 320,
    double maxWidth = 1200,
  }) {
    final width = screenWidth.clamp(minWidth, maxWidth);
    final ratio = (width - minWidth) / (maxWidth - minWidth);
    return minValue + (maxValue - minValue) * ratio;
  }
}

/// Widget responsive qui affiche différents layouts selon la taille d'écran
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? widescreen;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.widescreen,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Breakpoints.desktop && widescreen != null) {
          return widescreen!;
        }
        if (constraints.maxWidth >= Breakpoints.tablet && desktop != null) {
          return desktop!;
        }
        if (constraints.maxWidth >= Breakpoints.mobile && tablet != null) {
          return tablet!;
        }
        return mobile;
      },
    );
  }
}

/// Widget qui centre le contenu avec une largeur maximale
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool center;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.center = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMaxWidth = maxWidth ?? context.maxContentWidth;
    final effectivePadding =
        padding ?? EdgeInsets.symmetric(horizontal: context.horizontalPadding);

    Widget content = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
      child: Padding(padding: effectivePadding, child: child),
    );

    if (center) {
      content = Center(child: content);
    }

    return content;
  }
}

/// Grille responsive qui adapte le nombre de colonnes
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? columns;
  final double? spacing;
  final double? runSpacing;
  final double childAspectRatio;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.columns,
    this.spacing,
    this.runSpacing,
    this.childAspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColumns = columns ?? context.gridColumns;
    final effectiveSpacing = spacing ?? context.gridSpacing;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: effectiveColumns,
        crossAxisSpacing: effectiveSpacing,
        mainAxisSpacing: runSpacing ?? effectiveSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// Row ou Column selon l'orientation
class ResponsiveRowColumn extends StatelessWidget {
  final List<Widget> children;
  final bool? forceRow;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;

  const ResponsiveRowColumn({
    super.key,
    required this.children,
    this.forceRow,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    final isRow = forceRow ?? !context.isMobile;

    final spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(isRow ? Flexible(child: children[i]) : children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(
          SizedBox(width: isRow ? spacing : 0, height: isRow ? 0 : spacing),
        );
      }
    }

    if (isRow) {
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: spacedChildren,
      );
    }

    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: spacedChildren,
    );
  }
}

/// Widget pour afficher/masquer selon la taille d'écran
class ResponsiveVisibility extends StatelessWidget {
  final Widget child;
  final bool visibleOnMobile;
  final bool visibleOnTablet;
  final bool visibleOnDesktop;
  final Widget? replacement;

  const ResponsiveVisibility({
    super.key,
    required this.child,
    this.visibleOnMobile = true,
    this.visibleOnTablet = true,
    this.visibleOnDesktop = true,
    this.replacement,
  });

  @override
  Widget build(BuildContext context) {
    bool isVisible;
    if (context.isMobile) {
      isVisible = visibleOnMobile;
    } else if (context.isTablet) {
      isVisible = visibleOnTablet;
    } else {
      isVisible = visibleOnDesktop;
    }

    if (isVisible) {
      return child;
    }
    return replacement ?? const SizedBox.shrink();
  }
}

/// Calcul de valeur responsive
T responsiveValue<T>(
  BuildContext context, {
  required T mobile,
  T? tablet,
  T? desktop,
  T? widescreen,
}) {
  if (context.screenWidth >= Breakpoints.desktop && widescreen != null) {
    return widescreen;
  }
  if (context.screenWidth >= Breakpoints.tablet && desktop != null) {
    return desktop;
  }
  if (context.screenWidth >= Breakpoints.mobile && tablet != null) {
    return tablet;
  }
  return mobile;
}
