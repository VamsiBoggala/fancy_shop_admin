import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/image_picker_service.dart';

class FancyImagePicker extends StatelessWidget {
  final Uint8List? imageBytes;
  final String? imageUrl;
  final Function(Uint8List bytes) onImagePicked;
  final String label;
  final double size;
  final IconData placeholderIcon;

  const FancyImagePicker({
    super.key,
    required this.imageBytes,
    required this.onImagePicked,
    this.imageUrl,
    this.label = 'UPLOAD IMAGE',
    this.size = 120,
    this.placeholderIcon = Icons.add_photo_alternate_outlined,
  });

  Future<void> _pickImage() async {
    final bytes = await ImagePickerService().pickAndCompressImage();
    if (bytes != null) {
      onImagePicked(bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 16),
        ],
        Center(
          child: Stack(
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.lightSurfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        (isDark ? AppColors.darkBorder : AppColors.lightBorder)
                            .withOpacity(0.5),
                    width: 1.5,
                  ),
                  image: imageBytes != null
                      ? DecorationImage(
                          image: MemoryImage(imageBytes!),
                          fit: BoxFit.cover,
                        )
                      : (imageUrl != null && imageUrl!.isNotEmpty)
                      ? DecorationImage(
                          image: NetworkImage(imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child:
                    (imageBytes == null &&
                        (imageUrl == null || imageUrl!.isEmpty))
                    ? Icon(
                        placeholderIcon,
                        size: size * 0.28,
                        color: isDark
                            ? AppColors.darkTextHint
                            : AppColors.lightTextHint,
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Material(
                  color: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                  child: InkWell(
                    onTap: _pickImage,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Icon(
                        (imageBytes == null &&
                                (imageUrl == null || imageUrl!.isEmpty))
                            ? Icons.camera_alt
                            : Icons.edit,
                        size: size * 0.15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
