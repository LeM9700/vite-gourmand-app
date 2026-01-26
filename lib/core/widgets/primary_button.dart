import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/shadows.dart';
import '../theme/typography.dart';

/// Bouton primaire sophistiqué avec gradient et effets haut de gamme
class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double height;
  final double borderRadius;
  final Color? backgroundColor;
  final Widget? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.height = 56,
    this.borderRadius = 12,
    this.backgroundColor,
    this.icon,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        if (widget.onPressed != null && !widget.isLoading) {
          widget.onPressed!();
        }
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: widget.height,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                gradient:
                    widget.isLoading
                        ? LinearGradient(
                          colors: [
                            widget.backgroundColor ??
                                AppColors.mediumGrey.withValues(alpha: 0.5),
                            (widget.backgroundColor ?? AppColors.lightGrey)
                                .withValues(alpha: 0.8),
                          ],
                        )
                        : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors:
                              _isPressed
                                  ? [
                                    AppColors.primary.withValues(alpha: 0.8),
                                    AppColors.saffron.withValues(alpha: 0.8),
                                  ]
                                  : [AppColors.primary, AppColors.saffron],
                          stops: const [0.0, 1.0],
                        ),
                boxShadow:
                    widget.isLoading
                        ? AppShadows.subtle
                        : (_isPressed ? AppShadows.subtle : AppShadows.elegant),
                border: Border.all(
                  color: AppColors.champagne.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  onTap: widget.isLoading ? null : widget.onPressed,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          widget.icon!, // ✅ Afficher l'icône
                          const SizedBox(width: 8),
                        ],
                        if (widget.isLoading) ...[
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.champagne.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Text(
                          widget.label,
                          style: AppTextStyles.buttonPrimary.copyWith(
                            color:
                                widget.isLoading
                                    ? AppColors.textMuted
                                    : AppColors.dark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
