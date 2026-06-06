import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

@HiveType(typeId: 0)
class Receipt extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String vendorName;

  @HiveField(2)
  double amount;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String category;

  @HiveField(5)
  String? imagePath;

  @HiveField(6)
  String? note;

  Receipt({
    String? id,
    required this.vendorName,
    required this.amount,
    required this.date,
    required this.category,
    this.imagePath,
    this.note,
  }) : id = id ?? const Uuid().v4();

  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';
  String get formattedDate {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String get monthYearKey {
    final months = [
      'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
      'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  Map<String, dynamic> toCsvRow() => {
        'Date': formattedDate,
        'Vendor': vendorName,
        'Category': category,
        'Amount': amount.toStringAsFixed(2),
        'Note': note ?? '',
      };

  static List<String> get csvHeaders => ['Date', 'Vendor', 'Category', 'Amount', 'Note'];
}

class ReceiptAdapter extends TypeAdapter<Receipt> {
  @override
  final int typeId = 0;

  @override
  Receipt read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numFields; i++) {
      final fieldId = reader.readByte();
      fields[fieldId] = reader.read();
    }
    return Receipt(
      id: fields[0] as String,
      vendorName: fields[1] as String,
      amount: (fields[2] as num).toDouble(),
      date: fields[3] as DateTime,
      category: fields[4] as String,
      imagePath: fields[5] as String?,
      note: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Receipt obj) {
    writer.writeByte(7);
    writer.writeByte(0); writer.write(obj.id);
    writer.writeByte(1); writer.write(obj.vendorName);
    writer.writeByte(2); writer.write(obj.amount);
    writer.writeByte(3); writer.write(obj.date);
    writer.writeByte(4); writer.write(obj.category);
    writer.writeByte(5); writer.write(obj.imagePath ?? '');
    writer.writeByte(6); writer.write(obj.note ?? '');
  }
}
