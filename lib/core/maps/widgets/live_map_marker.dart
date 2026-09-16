import 'package:flutter/material.dart';

/// Pulsing marker to indicate a live / updating map position.
class LiveMapMarker extends StatefulWidget {
  const LiveMapMarker({
    super.key,
    required this.icon,
    required this.color,
    this.size = 34,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  State<LiveMapMarker> createState() => _LiveMapMarkerState();
}

class _LiveMapMarkerState extends State<LiveMapMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size + 16,
      height: widget.size + 16,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final scale = 0.6 + (_controller.value * 0.7);
              final opacity = (1 - _controller.value) * 0.45;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withValues(alpha: opacity),
                  ),
                ),
              );
            },
          ),
          Icon(
            widget.icon,
            color: widget.color,
            size: widget.size,
          ),
        ],
      ),
    );
  }
}
