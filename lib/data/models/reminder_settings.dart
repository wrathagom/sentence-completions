import 'dart:convert';

class ReminderSettings {
  final bool enabled;
  final int hour;
  final int minute;
  final Set<int> daysOfWeek;

  const ReminderSettings({
    this.enabled = false,
    this.hour = 9,
    this.minute = 0,
    this.daysOfWeek = const {1, 2, 3, 4, 5, 6, 7},
  });

  static const ReminderSettings defaultSettings = ReminderSettings();

  String get formattedTime {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  String get daysDescription {
    if (daysOfWeek.length == 7) {
      return 'Every day';
    }
    if (daysOfWeek.containsAll({1, 2, 3, 4, 5}) &&
        !daysOfWeek.contains(6) &&
        !daysOfWeek.contains(7)) {
      return 'Weekdays';
    }
    if (daysOfWeek.containsAll({6, 7}) && daysOfWeek.length == 2) {
      return 'Weekends';
    }
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final sortedDays = daysOfWeek.toList()..sort();
    return sortedDays.map((d) => dayNames[d - 1]).join(', ');
  }

  ReminderSettings copyWith({
    bool? enabled,
    int? hour,
    int? minute,
    Set<int>? daysOfWeek,
  }) {
    return ReminderSettings(
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'hour': hour,
      'minute': minute,
      'daysOfWeek': daysOfWeek.toList(),
    };
  }

  String toJson() => jsonEncode(toMap());

  factory ReminderSettings.fromMap(Map<String, dynamic> map) {
    return ReminderSettings(
      enabled: map['enabled'] as bool? ?? false,
      hour: map['hour'] as int? ?? 9,
      minute: map['minute'] as int? ?? 0,
      daysOfWeek: (map['daysOfWeek'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toSet() ??
          {1, 2, 3, 4, 5, 6, 7},
    );
  }

  factory ReminderSettings.fromJson(String json) {
    return ReminderSettings.fromMap(jsonDecode(json));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderSettings &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled &&
          hour == other.hour &&
          minute == other.minute &&
          daysOfWeek.containsAll(other.daysOfWeek) &&
          other.daysOfWeek.containsAll(daysOfWeek);

  @override
  int get hashCode =>
      enabled.hashCode ^ hour.hashCode ^ minute.hashCode ^ daysOfWeek.hashCode;
}
