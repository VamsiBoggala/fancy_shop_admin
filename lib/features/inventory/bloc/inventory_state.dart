import 'package:equatable/equatable.dart';
import '../domain/models/brand_model.dart';
import '../domain/models/category_model.dart';
import '../domain/models/product_model.dart';

abstract class InventoryState extends Equatable {
  const InventoryState();

  @override
  List<Object?> get props => [];
}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryLoaded extends InventoryState {
  final List<ProductModel> products;
  final List<CategoryModel> categories;
  final List<BrandModel> brands;

  const InventoryLoaded({
    required this.products,
    required this.categories,
    required this.brands,
  });

  @override
  List<Object?> get props => [products, categories, brands];
}

class InventoryError extends InventoryState {
  final String message;
  const InventoryError(this.message);

  @override
  List<Object?> get props => [message];
}
