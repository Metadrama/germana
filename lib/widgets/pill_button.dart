import 'package:flutter/material.dart';
import 'package:germana/core/theme.dart';

/// Clean pill-shaped button with subtle press feedback.
class PillButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? textColor;
  final IconData? icon;
  final bool isSmall;
  final bool isOutlined;
  final bool expand;

  const PillButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color,
    this.textColor,
    this.icon,
    this.isSmall = false,
    this.isOutlined = false,
    this.expand = false,
  });

  @override
  State<PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<PillButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) => _controller.forward();
  void _handleTapUp(TapUpDetails _) => _controller.reverse();
  void _handleTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final bg = widget.color ?? AppColors.accentBlue;
    final fg = widget.textColor ?? AppColors.textOnAccent;
    final vertPad = widget.isSmall ? 10.0 : 16.0;
    final horizPad = widget.isSmall ? 20.0 : 28.0;
    final fontSize = widget.isSmall ? 14.0 : 17.0;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Container(
          width: widget.expand ? double.infinity : null,
          padding: EdgeInsets.symmetric(
            vertical: vertPad,
            horizontal: horizPad,
          ),
          decoration: BoxDecoration(
            color: widget.isOutlined ? Colors.transparent : bg,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: widget.isOutlined
                ? Border.all(color: bg, width: 1.2)
                : null,
          ),
          child: Row(
            mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: widget.isOutlined ? bg : fg, size: fontSize + 2),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: widget.isOutlined ? bg : fg,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
