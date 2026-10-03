import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ReceiptImageStore {
  static const int maxImageBytes = 15 * 1024 * 1024;

  static Future<void> validateForOcr(String sourcePath) async {
    final file = File(sourcePath);
    if (!await file.exists()) {
      throw const FileSystemException('Image file is unavailable.');
    }
    if (await file.length() > maxImageBytes) {
      throw const FileSystemException(
        'Image is too large. Choose an image under 15 MB.',
      );
    }
  }

  static Future<String> persist(String sourcePath) async {
    await validateForOcr(sourcePath);
    final documents = await getApplicationDocumentsDirectory();
    final directory = Directory(p.join(documents.path, 'receipt_images'));
    await directory.create(recursive: true);
    final extension = p.extension(sourcePath).toLowerCase();
    final safeExtension = {'.jpg', '.jpeg', '.png', '.heic'}.contains(extension)
        ? extension
        : '.jpg';
    final destination = p.join(
      directory.path,
      '${const Uuid().v4()}$safeExtension',
    );
    return (await File(sourcePath).copy(destination)).path;
  }

  static Future<void> deleteIfManaged(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return;
    final documents = await getApplicationDocumentsDirectory();
    final root = p.canonicalize(p.join(documents.path, 'receipt_images'));
    final candidate = p.canonicalize(imagePath);
    if (!p.isWithin(root, candidate)) return;
    final file = File(candidate);
    if (await file.exists()) await file.delete();
  }
}
