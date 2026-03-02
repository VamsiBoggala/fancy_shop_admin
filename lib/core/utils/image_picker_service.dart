import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<Uint8List?> pickAndCompressImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Reduced from 80
      maxWidth: 1024, // Added resizing
      maxHeight: 1024, // Added resizing
    );

    if (image == null) return null;

    Uint8List imageBytes = await image.readAsBytes();
    const int targetSize = 500 * 1024; // 500 KB

    // If image is already under 500KB, return it
    if (imageBytes.lengthInBytes <= targetSize) {
      return imageBytes;
    }

    if (kIsWeb) {
      // On Web, image_picker's maxWidth/maxHeight/imageQuality is our primary tool.
      // If it's still over 500KB, it's likely a very complex image.
      // We return it and hope the infrastructure handles it, or the initial resize was enough.
      return imageBytes;
    } else {
      // For mobile, we can use flutter_image_compress for more aggressive reduction
      int quality = 70;
      while (imageBytes.lengthInBytes > targetSize && quality > 10) {
        quality -= 10;
        final compressed = await FlutterImageCompress.compressWithList(
          imageBytes,
          quality: quality,
          minWidth: 800,
          minHeight: 800,
        );
        imageBytes = Uint8List.fromList(compressed);
      }
      return imageBytes;
    }
  }
}
