/// Builds Arabic turn-by-turn instructions from OSRM/Mapbox maneuver metadata.
String buildManeuverInstruction({
  required String? apiInstruction,
  required String? type,
  required String? modifier,
  String? streetName,
}) {
  if (apiInstruction != null && apiInstruction.trim().isNotEmpty) {
    return _normalizeApiInstruction(apiInstruction.trim());
  }

  final maneuverType = (type ?? '').toLowerCase();
  final maneuverModifier = (modifier ?? '').toLowerCase();
  final street = streetName?.trim();

  String base;
  switch (maneuverType) {
    case 'depart':
      base = street != null && street.isNotEmpty
          ? 'انطلق على $street'
          : 'انطلق';
    case 'arrive':
      base = 'وصلت إلى الوجهة';
    case 'roundabout':
    case 'rotary':
      base = 'ادخل الدوار';
    case 'merge':
      base = 'اندمج في الطريق';
    case 'fork':
      base = _modifierPhrase(maneuverModifier, 'عند التقاطع');
    case 'end of road':
      base = _modifierPhrase(maneuverModifier, 'في نهاية الطريق');
    case 'turn':
    case 'new name':
    case 'continue':
      base = _modifierPhrase(maneuverModifier, 'استمر في الطريق');
    default:
      base = _modifierPhrase(maneuverModifier, 'تابع المسار');
  }

  if (street != null &&
      street.isNotEmpty &&
      maneuverType != 'depart' &&
      maneuverType != 'arrive') {
    return '$base نحو $street';
  }
  return base;
}

String _modifierPhrase(String modifier, String fallback) {
  switch (modifier) {
    case 'uturn':
      return 'استدر للخلف';
    case 'sharp right':
      return 'انعطف بحدة يميناً';
    case 'right':
      return 'انعطف يميناً';
    case 'slight right':
      return 'انحرف قليلاً يميناً';
    case 'straight':
      return 'استمر مستقيماً';
    case 'slight left':
      return 'انحرف قليلاً يساراً';
    case 'left':
      return 'انعطف يساراً';
    case 'sharp left':
      return 'انعطف بحدة يساراً';
    default:
      return fallback;
  }
}

String _normalizeApiInstruction(String instruction) {
  final lower = instruction.toLowerCase();
  if (lower.contains('turn right') || lower.contains('right onto')) {
    return instruction.replaceFirst(
      RegExp(r'turn right', caseSensitive: false),
      'انعطف يميناً',
    );
  }
  if (lower.contains('turn left') || lower.contains('left onto')) {
    return instruction.replaceFirst(
      RegExp(r'turn left', caseSensitive: false),
      'انعطف يساراً',
    );
  }
  if (lower.contains('continue') || lower.contains('head')) {
    return instruction
        .replaceFirst(RegExp(r'continue', caseSensitive: false), 'استمر')
        .replaceFirst(RegExp(r'head', caseSensitive: false), 'اتجه');
  }
  if (lower.contains('arrive')) {
    return 'وصلت إلى الوجهة';
  }
  return instruction;
}
