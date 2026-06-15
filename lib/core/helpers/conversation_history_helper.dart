import 'dart:convert';

import 'package:taal/core/helpers/shared_pref_local_storage.dart';

class ConversationLine {
  const ConversationLine({
    required this.text,
    this.time,
  });

  final String text;
  final DateTime? time;

  Map<String, dynamic> toJson() => {
        'text': text,
        'time': time?.toIso8601String(),
      };

  factory ConversationLine.fromJson(Map<String, dynamic> json) {
    return ConversationLine(
      text: json['text']?.toString() ?? '',
      time: json['time'] != null
          ? DateTime.tryParse(json['time'].toString())
          : null,
    );
  }
}

class ConversationHistoryEntry {
  const ConversationHistoryEntry({
    required this.id,
    required this.type,
    required this.title,
    required this.myLines,
    required this.theirLines,
    required this.updatedAt,
  });

  final String id;
  final String type;
  final String title;
  final List<ConversationLine> myLines;
  final List<ConversationLine> theirLines;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'myLines': myLines.map((line) => line.toJson()).toList(),
        'theirLines': theirLines.map((line) => line.toJson()).toList(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ConversationHistoryEntry.fromJson(Map<String, dynamic> json) {
    final myRaw = json['myLines'] as List<dynamic>? ?? [];
    final theirRaw = json['theirLines'] as List<dynamic>? ?? [];
    return ConversationHistoryEntry(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      myLines: myRaw
          .map((item) => ConversationLine.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(),
      theirLines: theirRaw
          .map((item) => ConversationLine.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class ConversationHistoryHelper {
  static const _storageKey = 'conversation_history_entries';

  static List<ConversationHistoryEntry> getAll() {
    final raw = SharedPref.sharedPreferences.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map(
            (item) => ConversationHistoryEntry.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(ConversationHistoryEntry entry) async {
    final items = getAll().where((item) => item.id != entry.id).toList();
    items.insert(0, entry);
    await SharedPref.sharedPreferences.setString(
      _storageKey,
      jsonEncode(items.map((item) => item.toJson()).toList()),
    );
  }

  static Future<void> delete(String id) async {
    final items = getAll().where((item) => item.id != id).toList();
    await SharedPref.sharedPreferences.setString(
      _storageKey,
      jsonEncode(items.map((item) => item.toJson()).toList()),
    );
  }
}
