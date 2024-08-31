class HourData {
  final Map<String, int> minutes;

  HourData({required this.minutes});

  factory HourData.fromJson(Map<String, dynamic> json) {
    return HourData(
      minutes: Map<String, int>.from(json),
    );
  }
}

class DayData {
  final String date;
  final int weekNumber;
  final Map<String, HourData> hours;

  DayData({required this.date, required this.weekNumber, required this.hours});

  factory DayData.fromJson(Map<String, dynamic> json) {
    Map<String, HourData> hours = {};
    json['hours'].forEach((hour, data) {
      hours[hour] = HourData.fromJson(data);
    });

    return DayData(
      date: json['date'],
      weekNumber: json['weekNumber'],
      hours: hours,
    );
  }
}

class LocationData {
  final int id;
  final String name;
  final Map<String, DayData> days;

  LocationData({required this.id, required this.name, required this.days});

  factory LocationData.fromJson(Map<String, dynamic> json) {
    Map<String, DayData> days = {};
    json['days'].forEach((day, data) {
      days[day] = DayData.fromJson(data);
    });

    return LocationData(
      id: json['id'],
      name: json['name'],
      days: days,
    );
  }
}
