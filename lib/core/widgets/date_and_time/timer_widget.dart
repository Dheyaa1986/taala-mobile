import 'dart:async';

import 'package:flutter/material.dart';

import '../../app_config/app_colors.dart';

class TimerWidget extends StatefulWidget {
  final DateTime until;
  final bool showDays, showHours, showMinutes;
  final TextStyle? style;
  final VoidCallback? onEnd;
  const TimerWidget({
    super.key,
    required this.until,
    this.onEnd,
    this.showDays = true,
    this.showHours = true,
    this.showMinutes = true,
    this.style,
  });

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  Timer? _timer;

  @override
  void initState() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (DateTime.now().isAfter(widget.until)) {
        _timer?.cancel();
        widget.onEnd?.call();
      }
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Text(
        _formattedTime,
        style: widget.style ??
            Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primaryColor,
                ),
      ),
    );
  }

  String get _formattedTime {
    final time = widget.until.isAfter(DateTime.now())
        ? widget.until.difference(DateTime.now())
        : Duration.zero;
    final days = widget.showDays ? "${"${time.inDays}".padLeft(2, "0")}:" : "";
    final hours =
        widget.showHours ? "${"${time.inHours % 60}".padLeft(2, "0")}:" : "";
    final minutes = widget.showMinutes
        ? "${"${time.inMinutes % 60}".padLeft(2, "0")}:"
        : "";
    final seconds = "${time.inSeconds % 60}".padLeft(2, "0");
    return "$days$hours$minutes$seconds";
  }
}
