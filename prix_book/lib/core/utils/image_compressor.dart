import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Compress product images to 150x150 JPEG thumbnail < 20KB
/// as per BR-P08 in Section 6.1
class ImageCompressor {
  static const int maxDimension = 150;
  static const int jpegQuality = 70;

  /// Compress image file and save to app documents directory
  /// Returns the relative path or null on failure
  static Future<String?> compressAndSave(String sourcePath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(path.join(appDir.path, 'product_images'));
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final fileName =
          'img_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final targetPath = path.join(imagesDir.path, fileName);

      final result = await FlutterImageCompress.compressAndGetFile(
        sourcePath,
        targetPath,
        minWidth: maxDimension,
        minHeight: maxDimension,
        quality: jpegQuality,
        format: CompressFormat.jpeg,
      );

      if (result == null) return null;

      // Return relative path for storage
      return 'product_images/$fileName';
    } catch (e) {
      return null;
    }
  }

  /// Resolve relative path to full path
  static Future<String?> resolvePath(String relativePath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      return path.join(appDir.path, relativePath);
    } catch (e) {
      return null;
    }
  }

  /// Delete image file
  static Future<void> deleteImage(String relativePath) async {
    try {
      final fullPath = await resolvePath(relativePath);
      if (fullPath != null) {
        final file = File(fullPath);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (_) {}
  }
}
