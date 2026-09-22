import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/taala_tokens.dart';

enum TaalaButtonVariant { primary, secondary, text }

class TaalaButton extends StatefulWidget {
  const TaalaButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = TaalaButtonVariant.primary,
    this.enabled = true,
    this.expanded = true,
    this.icon,
    this.height = 52,
  });

  final String label;
  final VoidCallback? onPressed;
  final TaalaButtonVariant variant;
  final bool enabled;
  final bool expanded;
  final Widget? icon;
  final double height;

  @override
  State<TaalaButton> createState() => _TaalaButtonState();
}

class _TaalaButtonState extends State<TaalaButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = TaalaTokens.of(context);
    final enabled = widget.enabled && widget.onPressed != null;

    final background = switch (widget.variant) {
      TaalaButtonVariant.primary => tokens.primary,
      TaalaButtonVariant.secondary => tokens.primarySoft,
      TaalaButtonVariant.text => Colors.transparent,
    };

    final foreground = switch (widget.variant) {
      TaalaButtonVariant.primary => tokens.onPrimary,
      TaalaButtonVariant.secondary => tokens.textPrimary,
      TaalaButtonVariant.text => tokens.primary,
    };

    final child = Row(
      mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          widget.icon!,
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );

    final button = AnimatedScale(
      scale: _pressed && enabled ? 0.98 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.5,
        duration: const Duration(milliseconds: 120),
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(tokens.buttonRadius),
          child: InkWell(
            onTap: enabled
                ? () {
                    HapticFeedback.lightImpact();
                    widget.onPressed?.call();
                  }
                : null,
            onHighlightChanged: enabled ? _setPressed : null,
            borderRadius: BorderRadius.circular(tokens.buttonRadius),
            child: Container(
              height: widget.height,
              width: widget.expanded ? double.infinity : null,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              child: child,
            ),
          ),
        ),
      ),
    );

    return enabled
        ? button
        : IgnorePointer(
            child: button,
          );
  }
}
