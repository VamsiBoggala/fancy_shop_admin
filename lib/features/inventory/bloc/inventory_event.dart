import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import '../domain/models/brand_model.dart';
import '../domain/models/category_model.dart';
import '../domain/models/product_model.dart';

abstract class InventoryEvent extends Equatable {
  const InventoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadInventory extends InventoryEvent {}

class AddBrand extends InventoryEvent {
  final BrandModel brand;
  final Uint8List? imageBytes;
  const AddBrand(this.brand, {this.imageBytes});
  @override
  List<Object?> get props => [brand, imageBytes];
}

class AddCategory extends InventoryEvent {
  final CategoryModel category;
  final Uint8List? imageBytes;
  const AddCategory(this.category, {this.imageBytes});
  @override
  List<Object?> get props => [category, imageBytes];
}

class AddProduct extends InventoryEvent {
  final ProductModel product;
  final Uint8List? imageBytes;
  const AddProduct(this.product, {this.imageBytes});
  @override
  List<Object?> get props => [product, imageBytes];
}

class UpdateProduct extends InventoryEvent {
  final ProductModel product;
  final Uint8List? imageBytes;
  const UpdateProduct(this.product, {this.imageBytes});
  @override
  List<Object?> get props => [product, imageBytes];
}

class UpdateCategory extends InventoryEvent {
  final CategoryModel category;
  final Uint8List? imageBytes;
  const UpdateCategory(this.category, {this.imageBytes});
  @override
  List<Object?> get props => [category, imageBytes];
}

class UpdateBrand extends InventoryEvent {
  final BrandModel brand;
  final Uint8List? imageBytes;
  const UpdateBrand(this.brand, {this.imageBytes});
  @override
  List<Object?> get props => [brand, imageBytes];
}

class DeleteCategory extends InventoryEvent {
  final CategoryModel category;
  const DeleteCategory(this.category);
  @override
  List<Object?> get props => [category];
}

class DeleteBrand extends InventoryEvent {
  final BrandModel brand;
  const DeleteBrand(this.brand);
  @override
  List<Object?> get props => [brand];
}

class DeleteProduct extends InventoryEvent {
  final ProductModel product;
  const DeleteProduct(this.product);
  @override
  List<Object?> get props => [product];
}

/// Quick stock adjustment (+1 / -1) without opening the full edit dialog.
/// [delta] is positive to increase, negative to decrease.
class AdjustProductStock extends InventoryEvent {
  final String productId;
  final int delta;
  const AdjustProductStock(this.productId, this.delta);
  @override
  List<Object?> get props => [productId, delta];
}
