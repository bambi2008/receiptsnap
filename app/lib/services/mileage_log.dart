import 'package:hive_flutter/hive_flutter.dart';

/// IRS Publication 463 Table 5-1 compliant mileage trip record.
class MileageTrip {
  final DateTime date;
  final double miles;
  final String purpose;
  final String destination;
  final int? odometerStart;
  final int? odometerEnd;

  MileageTrip({
    required this.date,
    required this.miles,
    required this.purpose,
    this.destination = '',
    this.odometerStart,
    this.odometerEnd,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'miles': miles,
        'purpose': purpose,
        'destination': destination,
        'odometerStart': odometerStart,
        'odometerEnd': odometerEnd,
      };

  factory MileageTrip.fromJson(Map<String, dynamic> json) => MileageTrip(
        date: DateTime.parse(json['date']),
        miles: (json['miles'] as num).toDouble(),
        purpose: json['purpose'] as String,
        destination: (json['destination'] as String?) ?? '',
        odometerStart: json['odometerStart'] as int?,
        odometerEnd: json['odometerEnd'] as int?,
      );
}

class MileageLog {
  static const _boxName = 'mileage_log';

  static List<MileageTrip> load() {
    final box = Hive.box('settings');
    final raw = box.get(_boxName, defaultValue: <Map>[]) as List;
    return raw.map((e) => MileageTrip.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  static void save(List<MileageTrip> trips) {
    final box = Hive.box('settings');
    box.put(_boxName, trips.map((t) => t.toJson()).toList());
  }

  static void addTrip({
    required double miles,
    required String purpose,
    String destination = '',
    int? odometerStart,
    int? odometerEnd,
  }) {
    final trips = load();
    trips.insert(0, MileageTrip(
      date: DateTime.now(),
      miles: miles,
      purpose: purpose.isEmpty ? 'Business trip' : purpose,
      destination: destination,
      odometerStart: odometerStart,
      odometerEnd: odometerEnd,
    ));
    save(trips);
  }

  static void deleteTrip(int index) {
    final trips = load();
    if (index >= 0 && index < trips.length) {
      trips.removeAt(index);
      save(trips);
    }
  }

  /// IRS 2025 rate: $0.70/mile (Pub 463 Ch.4)
  static const double irsMileageRate = 0.70;

  static double monthlyMiles({int? month, int? year}) {
    final now = DateTime.now();
    return load()
        .where((t) => t.date.month == (month ?? now.month) && t.date.year == (year ?? now.year))
        .fold(0.0, (sum, t) => sum + t.miles);
  }

  static double monthlyValue({int? month, int? year}) {
    return monthlyMiles(month: month, year: year) * irsMileageRate;
  }

  static int monthlyTripCount({int? month, int? year}) {
    final now = DateTime.now();
    return load().where((t) => t.date.month == (month ?? now.month) && t.date.year == (year ?? now.year)).length;
  }

  static double annualMiles({int? year}) {
    final y = year ?? DateTime.now().year;
    return load().where((t) => t.date.year == y).fold(0.0, (sum, t) => sum + t.miles);
  }

  static double annualValue({int? year}) => annualMiles(year: year) * irsMileageRate;

  static int annualTripCount({int? year}) {
    final y = year ?? DateTime.now().year;
    return load().where((t) => t.date.year == y).length;
  }
}
