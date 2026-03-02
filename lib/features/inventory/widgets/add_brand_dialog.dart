import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/fancy_text_field.dart';
import '../../../shared/widgets/fancy_button.dart';
import '../../../shared/widgets/fancy_image_picker.dart';
import '../../../shared/utils/fancy_snackbar.dart';
import '../bloc/inventory_bloc.dart';
import '../bloc/inventory_event.dart';
import '../domain/models/brand_model.dart';

class AddBrandDialog extends StatefulWidget {
  final BrandModel? brand;
  const AddBrandDialog({super.key, this.brand});

  @override
  State<AddBrandDialog> createState() => _AddBrandDialogState();
}

class _AddBrandDialogState extends State<AddBrandDialog> {
  late final TextEditingController _nameController;
  Uint8List? _imageBytes;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.brand?.name);
  }

  void _submitForm() {
    if (_nameController.text.isNotEmpty) {
      setState(() => _loading = true);
      if (widget.brand != null) {
        context.read<InventoryBloc>().add(
          UpdateBrand(
            BrandModel(
              id: widget.brand!.id,
              name: _nameController.text,
              logoUrl: widget.brand!.logoUrl,
            ),
            imageBytes: _imageBytes,
          ),
        );
      } else {
        context.read<InventoryBloc>().add(
          AddBrand(
            BrandModel(id: '', name: _nameController.text, logoUrl: ''),
            imageBytes: _imageBytes,
          ),
        );
      }
      Navigator.pop(context);
    } else {
      FancySnackBar.show(
        context,
        message: 'Please enter a brand name',
        type: SnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 440,
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.brand != null ? 'Edit Brand' : 'Add Brand',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      size: 20,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FancyImagePicker(
                      imageBytes: _imageBytes,
                      imageUrl: widget.brand?.logoUrl,
                      onImagePicked: (bytes) =>
                          setState(() => _imageBytes = bytes),
                      label: 'BRAND LOGO',
                      placeholderIcon: Icons.business_center_outlined,
                    ),
                    const SizedBox(height: 32),

                    FancyTextField(
                      label: 'Brand Name',
                      hintText: 'Enter brand name',
                      controller: _nameController,
                      prefixIcon: const Icon(Icons.business_outlined, size: 20),
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Row(
                children: [
                  Expanded(
                    child: FancyButton(
                      label: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                      isSecondary: true,
                      height: 52,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FancyButton(
                      label: widget.brand != null ? 'Update' : 'Create',
                      onPressed: _loading ? null : _submitForm,
                      isLoading: _loading,
                      height: 52,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
