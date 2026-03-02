import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:typed_data';
import '../bloc/inventory_bloc.dart';
import '../bloc/inventory_event.dart';
import '../domain/models/category_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/fancy_text_field.dart';
import '../../../shared/widgets/fancy_button.dart';
import '../../../shared/widgets/fancy_image_picker.dart';
import '../../../shared/utils/fancy_snackbar.dart';

class AddCategoryDialog extends StatefulWidget {
  final CategoryModel? category;
  const AddCategoryDialog({super.key, this.category});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _iconNameController;
  Uint8List? _imageBytes;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);
    _iconNameController = TextEditingController(
      text: widget.category?.iconName,
    );
  }

  void _submitForm() {
    if (_nameController.text.isNotEmpty) {
      setState(() => _loading = true);
      if (widget.category != null) {
        context.read<InventoryBloc>().add(
          UpdateCategory(
            CategoryModel(
              id: widget.category!.id,
              name: _nameController.text,
              iconName: _iconNameController.text,
              imageUrl: widget.category!.imageUrl,
            ),
            imageBytes: _imageBytes,
          ),
        );
      } else {
        context.read<InventoryBloc>().add(
          AddCategory(
            CategoryModel(
              id: '',
              name: _nameController.text,
              iconName: _iconNameController.text,
            ),
            imageBytes: _imageBytes,
          ),
        );
      }
      Navigator.pop(context);
    } else {
      FancySnackBar.show(
        context,
        message: 'Please enter a category name',
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
                    widget.category != null ? 'Edit Category' : 'Add Category',
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
                  children: [
                    FancyImagePicker(
                      imageBytes: _imageBytes,
                      imageUrl: widget.category?.imageUrl,
                      onImagePicked: (bytes) =>
                          setState(() => _imageBytes = bytes),
                      label: 'CATEGORY IMAGE',
                      placeholderIcon: Icons.category_outlined,
                    ),
                    const SizedBox(height: 24),
                    FancyTextField(
                      label: 'Category Name',
                      hintText: 'Enter category name',
                      controller: _nameController,
                      prefixIcon: const Icon(Icons.category_outlined, size: 20),
                    ),
                    const SizedBox(height: 20),
                    FancyTextField(
                      label: 'Icon Name',
                      hintText: 'e.g., shoe_icon',
                      controller: _iconNameController,
                      prefixIcon: const Icon(
                        Icons.insert_emoticon_outlined,
                        size: 20,
                      ),
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
                      label: widget.category != null ? 'Update' : 'Create',
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
