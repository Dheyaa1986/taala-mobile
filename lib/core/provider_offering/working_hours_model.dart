class WorkingHoursDayModel {
  const WorkingHoursDayModel({
    required this.day,
    required this.isOpen,
    this.openTime = '08:00',
    this.closeTime = '18:00',
  });

  final int day;
  final bool isOpen;
  final String openTime;
  final String closeTime;

  Map<String, dynamic> toJson() => {
        'day': day,
        'isOpen': isOpen,
        'openTime': openTime,
        'closeTime': closeTime,
      };

  WorkingHoursDayModel copyWith({
    int? day,
    bool? isOpen,
    String? openTime,
    String? closeTime,
  }) {
    return WorkingHoursDayModel(
      day: day ?? this.day,
      isOpen: isOpen ?? this.isOpen,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
    );
  }

  static List<WorkingHoursDayModel> defaultWeek() {
    return List.generate(
      7,
      (index) => WorkingHoursDayModel(
        day: index,
        isOpen: index != 5,
      ),
    );
  }
}
