import 'dart:async';

import 'package:latlong2/latlong.dart';
import 'package:taal/core/maps/navigation/navigation_geometry.dart';
import 'package:taal/core/maps/navigation/navigation_tts_service.dart';
import 'package:taal/core/maps/navigation/taala_navigation_route.dart';

class RouteGuidanceSnapshot {
  const RouteGuidanceSnapshot({
    required this.active,
    required this.stepIndex,
    required this.currentInstruction,
    required this.remainingDistanceMeters,
    required this.remainingDurationSeconds,
    required this.arrived,
    required this.offRoute,
  });

  final bool active;
  final int stepIndex;
  final String currentInstruction;
  final double remainingDistanceMeters;
  final double remainingDurationSeconds;
  final bool arrived;
  final bool offRoute;

  static const idle = RouteGuidanceSnapshot(
    active: false,
    stepIndex: 0,
    currentInstruction: '',
    remainingDistanceMeters: 0,
    remainingDurationSeconds: 0,
    arrived: false,
    offRoute: false,
  );
}

class RouteGuidanceController {
  RouteGuidanceController(this._tts);

  final NavigationTtsService _tts;

  TaalaNavigationRoute? _route;
  LatLng? _lastPosition;
  var _stepIndex = 0;
  var _active = false;
  var _arrived = false;
  var _offRoute = false;
  var _spokenApproachStep = -1;
  RouteGuidanceSnapshot _snapshot = RouteGuidanceSnapshot.idle;

  RouteGuidanceSnapshot get snapshot => _snapshot;

  void setRoute(TaalaNavigationRoute? route) {
    _route = route;
    _stepIndex = 0;
    _arrived = false;
    _offRoute = false;
    _spokenApproachStep = -1;
    _lastPosition = null;
    _tts.resetLastSpoken();
    _refreshSnapshot();
  }

  void start() {
    _active = true;
    _arrived = false;
    _offRoute = false;
    _stepIndex = 0;
    _spokenApproachStep = -1;
    _tts.resetLastSpoken();
    _refreshSnapshot(notifySpeech: true);
  }

  void stop() {
    _active = false;
    _refreshSnapshot();
  }

  bool shouldReroute(LatLng position) {
    final route = _route;
    if (route == null || route.points.length < 2) return false;
    return distanceToPolylineMeters(position, route.points) > 50;
  }

  RouteGuidanceSnapshot updatePosition(LatLng position) {
    _lastPosition = position;
    final route = _route;
    if (!_active || route == null || route.steps.isEmpty) {
      return _snapshot;
    }

    _offRoute = distanceToPolylineMeters(position, route.points) > 50;
    if (_offRoute) {
      _refreshSnapshot();
      return _snapshot;
    }

    while (_stepIndex < route.steps.length - 1) {
      final step = route.steps[_stepIndex];
      final distanceToManeuver =
          navigationDistanceMeters(position, step.maneuverLocation);
      if (distanceToManeuver > 35) break;
      _stepIndex++;
      _spokenApproachStep = -1;
      _tts.resetLastSpoken();
    }

    final currentStep = route.steps[_stepIndex];
    final distanceToCurrent =
        navigationDistanceMeters(position, currentStep.maneuverLocation);

    if (_stepIndex >= route.steps.length - 1 && distanceToCurrent < 35) {
      _arrived = true;
      _active = false;
      unawaited(_tts.speak('وصلت إلى الوجهة'));
      _refreshSnapshot();
      return _snapshot;
    }

    if (_spokenApproachStep != _stepIndex && distanceToCurrent <= 120) {
      _spokenApproachStep = _stepIndex;
      final meters = distanceToCurrent.round();
      final prefix = meters >= 80 ? 'بعد $meters متر' : 'الآن';
      unawaited(_tts.speak('$prefix ${currentStep.instruction}'));
    }

    _refreshSnapshot();
    return _snapshot;
  }

  void _refreshSnapshot({bool notifySpeech = false}) {
    final route = _route;
    if (route == null || route.steps.isEmpty) {
      _snapshot = RouteGuidanceSnapshot.idle;
      return;
    }

    final step = route.steps[_stepIndex.clamp(0, route.steps.length - 1)];
    final position = _lastPosition;
    final remainingDistance = _active &&
            position != null &&
            route.points.length >= 2
        ? remainingPolylineDistanceMeters(position, route.points)
        : route.totalDistanceMeters;
    final ratio = route.totalDistanceMeters <= 0
        ? 1.0
        : (remainingDistance / route.totalDistanceMeters).clamp(0.0, 1.0);
    final remainingDuration = route.totalDurationSeconds * ratio;

    _snapshot = RouteGuidanceSnapshot(
      active: _active,
      stepIndex: _stepIndex,
      currentInstruction: step.instruction,
      remainingDistanceMeters: remainingDistance,
      remainingDurationSeconds: remainingDuration,
      arrived: _arrived,
      offRoute: _offRoute,
    );

    if (notifySpeech && _active) {
      unawaited(_tts.speak(step.instruction));
    }
  }
}
