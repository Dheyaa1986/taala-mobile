import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taal/core/app_config/app_strings.dart';
import 'package:taal/core/extensions/space_extension.dart';
import 'package:taal/core/maps/map_style_config.dart';
import 'package:taal/core/maps/navigation/navigation_geometry.dart';

class WazeNavOverlay extends StatelessWidget {
  const WazeNavOverlay({
    super.key,
    required this.instruction,
    required this.maneuverDistanceMeters,
    required this.remainingDistanceMeters,
    required this.remainingMinutes,
    required this.active,
    this.nextInstruction,
    this.speedKmh = 0,
    this.arrived = false,
    this.offRoute = false,
    this.voiceOn = true,
    this.onClose,
    this.onToggleVoice,
    this.onOpenWaze,
    this.onReport,
  });

  final String instruction;
  final String? nextInstruction;
  final double maneuverDistanceMeters;
  final double remainingDistanceMeters;
  final int remainingMinutes;
  final double speedKmh;
  final bool active;
  final bool arrived;
  final bool offRoute;
  final bool voiceOn;
  final VoidCallback? onClose;
  final VoidCallback? onToggleVoice;
  final VoidCallback? onOpenWaze;
  final VoidCallback? onReport;

  @override
  Widget build(BuildContext context) {
    final eta = DateTime.now().add(Duration(minutes: remainingMinutes));
    final etaLabel =
        '${eta.hour.toString().padLeft(2, '0')}:${eta.minute.toString().padLeft(2, '0')}';

    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RoundIconButton(
                  icon: Icons.close,
                  onPressed: onClose ?? () => Navigator.of(context).maybePop(),
                ),
                8.width,
                Expanded(
                  child: Column(
                    children: [
                      _TurnBanner(
                        instruction: arrived
                            ? 'وصلت'
                            : offRoute
                                ? 'خرجت عن المسار'
                                : instruction,
                        distance: arrived
                            ? '0 م'
                            : offRoute
                                ? '…'
                                : formatNavigationDistance(
                                    maneuverDistanceMeters,
                                  ),
                        icon: _iconFor(
                          instruction,
                          arrived: arrived,
                          offRoute: offRoute,
                        ),
                        alert: offRoute,
                      ),
                      if (!arrived &&
                          !offRoute &&
                          (nextInstruction ?? '').isNotEmpty) ...[
                        6.height,
                        _NextTurnChip(text: nextInstruction!),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        Padding(
          padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 8.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _SpeedBubble(speedKmh: speedKmh),
              const Spacer(),
              Column(
                children: [
                  _RoundIconButton(
                    icon: voiceOn ? Icons.volume_up : Icons.volume_off,
                    onPressed: onToggleVoice ?? () {},
                  ),
                  8.height,
                  _RoundIconButton(
                    icon: Icons.warning_amber_rounded,
                    label: AppStrings.navAddNote.tr(),
                    onPressed: onReport ?? () {},
                  ),
                  if (onOpenWaze != null) ...[
                    8.height,
                    _RoundIconButton(
                      icon: Icons.near_me,
                      onPressed: onOpenWaze!,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (active)
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              20.w,
              14.h,
              20.w,
              14.h + MediaQuery.paddingOf(context).bottom,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _EtaCell(value: etaLabel, label: 'الوصول'),
                _EtaCell(value: '$remainingMinutes د', label: 'المدة'),
                _EtaCell(
                  value: formatNavigationDistance(remainingDistanceMeters),
                  label: 'المتبقي',
                ),
              ],
            ),
          ),
      ],
    );
  }

  static IconData _iconFor(
    String instruction, {
    required bool arrived,
    required bool offRoute,
  }) {
    if (arrived) return Icons.flag_rounded;
    if (offRoute) return Icons.sync;
    if (instruction.contains('الخلف')) return Icons.u_turn_left;
    if (instruction.contains('يمينا')) return Icons.turn_right;
    if (instruction.contains('يسارا')) return Icons.turn_left;
    if (instruction.contains('الدوار')) return Icons.roundabout_right;
    return Icons.arrow_upward_rounded;
  }
}

class _TurnBanner extends StatelessWidget {
  const _TurnBanner({
    required this.instruction,
    required this.distance,
    required this.icon,
    this.alert = false,
  });

  final String instruction;
  final String distance;
  final IconData icon;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: alert ? const Color(0xFFE65100) : MapStyleConfig.routeCasingColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 36.r),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  distance,
                  style: TextStyle(
                    color: alert ? Colors.white : MapStyleConfig.routeColor,
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                4.height,
                Text(
                  instruction.isEmpty ? 'تابع المسار' : instruction,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
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

class _NextTurnChip extends StatelessWidget {
  const _NextTurnChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        'ثم $text',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF333333),
        ),
      ),
    );
  }
}

class _SpeedBubble extends StatelessWidget {
  const _SpeedBubble({required this.speedKmh});

  final double speedKmh;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72.r,
      height: 72.r,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: MapStyleConfig.routeColor, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            speedKmh.round().toString(),
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          Text(
            'كم/س',
            style: TextStyle(fontSize: 10.sp, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _EtaCell extends StatelessWidget {
  const _EtaCell({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        2.height,
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onPressed,
    this.label,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.all(10.r),
          child: Icon(icon, size: 22.r),
        ),
      ),
    );
    if ((label ?? '').isEmpty) return button;
    return Column(
      children: [
        button,
        4.height,
        Text(
          label!,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            shadows: const [Shadow(color: Colors.white, blurRadius: 6)],
          ),
        ),
      ],
    );
  }
}
