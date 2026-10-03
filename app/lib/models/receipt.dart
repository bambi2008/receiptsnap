import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

const receiptReviewNeedsReview = 'needs_review';
const receiptReviewConfirmedBusiness = 'confirmed_business';
const receiptReviewPersonal = 'personal_do_not_include';

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

  @HiveField(7)
  String? businessPurpose;

  @HiveField(8)
  String? location;

  @HiveField(9)
  String? paymentMethod;

  @HiveField(10)
  double businessUsePercent;

  @HiveField(11)
  String reviewStatus;

  @HiveField(12)
  DateTime capturedAt;

  Receipt({
    String? id,
    required this.vendorName,
    required this.amount,
    required this.date,
    required this.category,
    this.imagePath,
    this.note,
    this.businessPurpose,
    this.location,
    this.paymentMethod,
    this.businessUsePercent = 100,
    this.reviewStatus = receiptReviewNeedsReview,
    DateTime? capturedAt,
  }) : id = id ?? const Uuid().v4(),
       capturedAt = capturedAt ?? DateTime.now();

  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';
  String get formattedDate {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  double get businessAmount => reviewStatus == receiptReviewPersonal
      ? 0
      : amount * businessUsePercent / 100;

  String get reviewStatusLabel => switch (reviewStatus) {
    receiptReviewConfirmedBusiness => 'Confirmed business record',
    receiptReviewPersonal => 'Personal — exclude from tax totals',
    _ => 'Needs review',
  };

  String get monthYearKey {
    final months = [
      'JANUARY',
      'FEBRUARY',
      'MARCH',
      'APRIL',
      'MAY',
      'JUNE',
      'JULY',
      'AUGUST',
      'SEPTEMBER',
      'OCTOBER',
      'NOVEMBER',
      'DECEMBER',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  Map<String, dynamic> toCsvRow() => {
    'Tax Year': date.year.toString(),
    'Receipt ID': id,
    'Transaction Date':
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
    'Vendor': vendorName,
    'Gross Amount': amount.toStringAsFixed(2),
    'Currency': 'USD',
    'Business Use Percent': businessUsePercent.toStringAsFixed(1),
    'Business Amount (Not a Tax Determination)': businessAmount.toStringAsFixed(
      2,
    ),
    'Expense Category': category,
    'Description / Items': note ?? '',
    'Business Purpose': businessPurpose ?? '',
    'Location / Destination': location ?? '',
    'Payment Method': paymentMethod ?? 'Not recorded',
    'Review Status': reviewStatusLabel,
    'Captured At': capturedAt.toUtc().toIso8601String(),
  };

  static List<String> get csvHeaders => [
    'Tax Year',
    'Receipt ID',
    'Transaction Date',
    'Vendor',
    'Gross Amount',
    'Currency',
    'Business Use Percent',
    'Business Amount (Not a Tax Determination)',
    'Expense Category',
    'Suggested Schedule C Reference',
    'Description / Items',
    'Business Purpose',
    'Location / Destination',
    'Payment Method',
    'Review Status',
    'Receipt Image Reference',
    'Captured At',
  ];
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
      imagePath: (fields[5] as String?)?.trim().isEmpty == true
          ? null
          : fields[5] as String?,
      note: (fields[6] as String?)?.isEmpty == true
          ? null
          : fields[6] as String?,
      businessPurpose: (fields[7] as String?)?.isEmpty == true
          ? null
          : fields[7] as String?,
      location: (fields[8] as String?)?.isEmpty == true
          ? null
          : fields[8] as String?,
      paymentMethod: (fields[9] as String?)?.isEmpty == true
          ? null
          : fields[9] as String?,
      businessUsePercent: (fields[10] as num?)?.toDouble() ?? 100,
      reviewStatus: fields[11] as String? ?? receiptReviewNeedsReview,
      capturedAt: fields[12] as DateTime? ?? fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Receipt obj) {
    writer.writeByte(13);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.vendorName);
    writer.writeByte(2);
    writer.write(obj.amount);
    writer.writeByte(3);
    writer.write(obj.date);
    writer.writeByte(4);
    writer.write(obj.category);
    writer.writeByte(5);
    writer.write(obj.imagePath ?? '');
    writer.writeByte(6);
    writer.write(obj.note ?? '');
    writer.writeByte(7);
    writer.write(obj.businessPurpose ?? '');
    writer.writeByte(8);
    writer.write(obj.location ?? '');
    writer.writeByte(9);
    writer.write(obj.paymentMethod ?? '');
    writer.writeByte(10);
    writer.write(obj.businessUsePercent);
    writer.writeByte(11);
    writer.write(obj.reviewStatus);
    writer.writeByte(12);
    writer.write(obj.capturedAt);
  }
}
