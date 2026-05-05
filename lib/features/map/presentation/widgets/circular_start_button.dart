import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Circular START CTA button with micro-interactions (press scale, spring animation)
class CircularStartButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isVisible;
  final String label;
  final IconData icon;

  const CircularStartButton({
    super.key,
    required this.onPressed,
    this.isVisible = true,
    this.label = 'START',
    this.icon = Icons.play_arrow,
  });

  @override
  State<CircularStartButton> createState() => _CircularStartButtonState();
}

class _CircularStartButtonState extends State<CircularStartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _pressController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onPress() {
    _pressController.forward();
  }

  void _onRelease() {
    _pressController.reverse();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _onPress(),
        onTapUp: (_) => _onRelease(),
        onTapCancel: () => _pressController.reverse(),
        child: Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.neonCyan,
            boxShadow: [
              // Primary glow
              BoxShadow(
                color: AppTheme.neonCyan.withOpacity(0.5),
                blurRadius: 24,
                spreadRadius: 2,
              ),
              // Secondary glow (inner)
              BoxShadow(
                color: AppTheme.neonCyan.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: AppTheme.deepDark, size: 36),
              const SizedBox(height: 2),
              Text(
                widget.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.deepDark,
                  fontSize: widget.label.length > 5 ? 11 : 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
