import 'package:hive_flutter/hive_flutter.dart';

class MileageTrip {
  final DateTime date;
  final double miles;
  final String purpose;

  MileageTrip({required this.date, required this.miles, required this.purpose});

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'miles': miles,
        'purpose': purpose,
      };

  factory MileageTrip.fromJson(Map<String, dynamic> json) => MileageTrip(
        date: DateTime.parse(json['date']),
        miles: (json['miles'] as num).toDouble(),
        purpose: json['purpose'] as String,
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

  static void addTrip(double miles, String purpose) {
    final trips = load();
    trips.insert(0, MileageTrip(date: DateTime.now(), miles: miles, purpose: purpose.isEmpty ? 'Business trip' : purpose));
    save(trips);
  }

  static void deleteTrip(int index) {
    final trips = load();
    if (index >= 0 && index < trips.length) {
      trips.removeAt(index);
      save(trips);
    }
  }

  static double monthlyMiles({int? month, int? year}) {
    final now = DateTime.now();
    return load()
        .where((t) => t.date.month == (month ?? now.month) && t.date.year == (year ?? now.year))
        .fold(0.0, (sum, t) => sum + t.miles);
  }

  static double monthlyValue({int? month, int? year}) {
    return monthlyMiles(month: month, year: year) * 0.70;
  }

  static int monthlyTripCount({int? month, int? year}) {
    final now = DateTime.now();
    return load().where((t) => t.date.month == (month ?? now.month) && t.date.year == (year ?? now.year)).length;
  }
}
