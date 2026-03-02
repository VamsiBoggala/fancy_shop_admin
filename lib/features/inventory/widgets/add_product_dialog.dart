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
import '../bloc/inventory_state.dart';
import '../domain/models/product_model.dart';
import '../domain/models/brand_model.dart';
import '../domain/models/category_model.dart';

class AddProductDialog extends StatefulWidget {
  final ProductModel? product;
  const AddProductDialog({super.key, this.product});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _discountController;
  late final TextEditingController _stockController;

  BrandModel? _selectedBrand;
  CategoryModel? _selectedCategory;
  Uint8List? _pickedImageBytes;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name);
    _priceController = TextEditingController(
      text: widget.product?.price.toString(),
    );
    _discountController = TextEditingController(
      text: widget.product?.discount.toString(),
    );
    _stockController = TextEditingController(
      text: widget.product?.stockQuantity.toString(),
    );
  }

  void _submitForm() {
    if (_nameController.text.isNotEmpty &&
        _selectedBrand != null &&
        _selectedCategory != null) {
      setState(() => _loading = true);

      final product = ProductModel(
        id: widget.product?.id ?? '',
        name: _nameController.text,
        brandId: _selectedBrand!.id,
        brandName: _selectedBrand!.name,
        categoryId: _selectedCategory!.id,
        categoryName: _selectedCategory!.name,
        price: double.tryParse(_priceController.text) ?? 0,
        discount: double.tryParse(_discountController.text) ?? 0,
        stockQuantity: int.tryParse(_stockController.text) ?? 0,
        lastUpdated: DateTime.now(),
        imageUrl: widget.product?.imageUrl,
      );

      if (widget.product != null) {
        context.read<InventoryBloc>().add(
          UpdateProduct(product, imageBytes: _pickedImageBytes),
        );
      } else {
        context.read<InventoryBloc>().add(
          AddProduct(product, imageBytes: _pickedImageBytes),
        );
      }

      Navigator.pop(context);
    } else {
      FancySnackBar.show(
        context,
        message: 'Please fill all required fields',
        type: SnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<InventoryBloc, InventoryState>(
      builder: (context, state) {
        if (state is! InventoryLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        // Initialize selections if in edit mode
        if (widget.product != null) {
          _selectedBrand ??= state.brands.firstWhere(
            (b) => b.id == widget.product!.brandId,
            orElse: () => state.brands.first,
          );
          _selectedCategory ??= state.categories.firstWhere(
            (c) => c.id == widget.product!.categoryId,
            orElse: () => state.categories.first,
          );
        }

        return Dialog(
          backgroundColor: isDark
              ? AppColors.darkSurface
              : AppColors.lightSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 24, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.product != null
                            ? 'Edit Product'
                            : 'Add New Product',
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
                          imageBytes: _pickedImageBytes,
                          imageUrl: widget.product?.imageUrl,
                          onImagePicked: (bytes) =>
                              setState(() => _pickedImageBytes = bytes),
                          label: 'PRODUCT IMAGE',
                        ),
                        const SizedBox(height: 32),

                        // Form Fields
                        FancyTextField(
                          label: 'Product Name',
                          hintText: 'Enter product name',
                          controller: _nameController,
                          prefixIcon: const Icon(Icons.abc, size: 20),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Brand',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<BrandModel>(
                                    value: _selectedBrand,
                                    isExpanded: true,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.lightTextPrimary,
                                      fontFamily: 'Inter',
                                    ),
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: isDark
                                              ? AppColors.darkBorder
                                              : AppColors.lightBorder,
                                        ),
                                      ),
                                    ),
                                    items: state.brands
                                        .map(
                                          (brand) => DropdownMenuItem(
                                            value: brand,
                                            child: Text(brand.name),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (val) =>
                                        setState(() => _selectedBrand = val),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Category',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<CategoryModel>(
                                    value: _selectedCategory,
                                    isExpanded: true,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.lightTextPrimary,
                                      fontFamily: 'Inter',
                                    ),
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: isDark
                                              ? AppColors.darkBorder
                                              : AppColors.lightBorder,
                                        ),
                                      ),
                                    ),
                                    items: state.categories
                                        .map(
                                          (cat) => DropdownMenuItem(
                                            value: cat,
                                            child: Text(cat.name),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (val) =>
                                        setState(() => _selectedCategory = val),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: FancyTextField(
                                label: 'Price',
                                hintText: '0.00',
                                controller: _priceController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                prefixIcon: const Icon(
                                  Icons.currency_rupee,
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: FancyTextField(
                                label: 'Discount %',
                                hintText: '0',
                                controller: _discountController,
                                keyboardType: TextInputType.number,
                                prefixIcon: const Icon(Icons.tag, size: 18),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        FancyTextField(
                          label: 'Stock Quantity',
                          hintText: 'Enter stock amount',
                          controller: _stockController,
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(
                            Icons.view_in_ar_outlined,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Actions
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 24,
                  ),
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
                          label: widget.product != null
                              ? 'Update Product'
                              : 'Create Product',
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
      },
    );
  }
}
