/// Represents data for a specific hour, containing minute-level data.
class HourData {
  /// A map where keys are minute strings (e.g., "00", "15") and values are integer data points.
  final Map<String, int> minutes;

  /// Creates an instance of [HourData].
  ///
  /// The [minutes] parameter is required and represents minute-level data for an hour.
  HourData({required this.minutes});

  /// Creates an instance of [HourData] from a JSON object.
  ///
  /// The [json] parameter must be a map where keys are minute strings
  /// and values are integer data points.
  factory HourData.fromJson(Map<String, dynamic> json) {
    return HourData(
      minutes: Map<String, int>.from(json),
    );
  }
}

/// Represents data for a specific day, including hours and other metadata.
class DayData {
  /// The date of the day in string format.
  final String date;

  /// The week number to which this day belongs.
  final int weekNumber;

  /// A map where keys are hour strings (e.g., "05", "14") and values are [HourData] instances.
  final Map<String, HourData> hours;

  /// Creates an instance of [DayData].
  ///
  /// The [date], [weekNumber], and [hours] parameters are required.
  DayData({required this.date, required this.weekNumber, required this.hours});

  /// Creates an instance of [DayData] from a JSON object.
  ///
  /// The [json] parameter must be a map containing:
  /// - 'date': a string representing the date.
  /// - 'weekNumber': an integer representing the week number.
  /// - 'hours': a map where keys are hour strings and values are [HourData] objects.
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

/// Represents data for a specific location, including day-level data.
class LocationData {
  /// The unique identifier for the location.
  final int id;

  /// The name of the location.
  final String name;

  /// A map where keys are day strings (e.g., "2023-09-01") and values are [DayData] instances.
  final Map<String, DayData> days;

  /// Creates an instance of [LocationData].
  ///
  /// The [id], [name], and [days] parameters are required.
  LocationData({required this.id, required this.name, required this.days});

  /// Creates an instance of [LocationData] from a JSON object.
  ///
  /// The [json] parameter must be a map containing:
  /// - 'id': an integer representing the location ID.
  /// - 'name': a string representing the location name.
  /// - 'days': a map where keys are day strings and values are [DayData] objects.
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
