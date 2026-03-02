import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/inventory_repository.dart';
import '../domain/models/product_model.dart';
import '../domain/models/category_model.dart';
import '../domain/models/brand_model.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryRepository _repository;

  InventoryBloc(this._repository) : super(InventoryInitial()) {
    on<LoadInventory>(_onLoadInventory);
    on<AddBrand>(_onAddBrand);
    on<AddCategory>(_onAddCategory);
    on<AddProduct>(_onAddProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<UpdateBrand>(_onUpdateBrand);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteProduct>(_onDeleteProduct);
    on<DeleteCategory>(_onDeleteCategory);
    on<DeleteBrand>(_onDeleteBrand);
  }

  Future<void> _onLoadInventory(
    LoadInventory event,
    Emitter<InventoryState> emit,
  ) async {
    emit(InventoryLoading());
    try {
      final products = await _repository.getProducts();
      final categories = await _repository.getCategories();
      final brands = await _repository.getBrands();
      debugPrint('📦 Inventory Data Loaded:');
      debugPrint('   - ${products.length} products');
      debugPrint('   - ${categories.length} categories');
      debugPrint('   - ${brands.length} brands');
      emit(
        InventoryLoaded(
          products: products,
          categories: categories,
          brands: brands,
        ),
      );
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> _onAddBrand(AddBrand event, Emitter<InventoryState> emit) async {
    final previousState = state;
    emit(InventoryLoading());
    try {
      String? logoUrl;
      if (event.imageBytes != null) {
        final fileName = 'brand_${DateTime.now().millisecondsSinceEpoch}.jpg';
        logoUrl = await _repository.uploadImage(
          event.imageBytes!,
          fileName,
          'brands',
        );
      }

      final brandToAdd = BrandModel(
        id: event.brand.id,
        name: event.brand.name,
        logoUrl: logoUrl ?? event.brand.logoUrl,
      );

      await _repository.addBrand(brandToAdd);
      add(LoadInventory());
    } catch (e) {
      if (previousState is InventoryLoaded) {
        emit(previousState);
      }
      emit(InventoryError('Failed to add brand: ${e.toString()}'));
    }
  }

  Future<void> _onAddCategory(
    AddCategory event,
    Emitter<InventoryState> emit,
  ) async {
    final previousState = state;
    emit(InventoryLoading());
    try {
      String? imageUrl;
      if (event.imageBytes != null) {
        final fileName =
            'category_${DateTime.now().millisecondsSinceEpoch}.jpg';
        imageUrl = await _repository.uploadImage(
          event.imageBytes!,
          fileName,
          'categories',
        );
      }

      final categoryToAdd = CategoryModel(
        id: event.category.id,
        name: event.category.name,
        iconName: event.category.iconName,
        imageUrl: imageUrl ?? event.category.imageUrl,
      );

      await _repository.addCategory(categoryToAdd);
      add(LoadInventory());
    } catch (e) {
      if (previousState is InventoryLoaded) {
        emit(previousState);
      }
      emit(InventoryError('Failed to add category: ${e.toString()}'));
    }
  }

  Future<void> _onAddProduct(
    AddProduct event,
    Emitter<InventoryState> emit,
  ) async {
    final previousState = state;
    emit(InventoryLoading());
    try {
      String? imageUrl;
      if (event.imageBytes != null) {
        final fileName = 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
        imageUrl = await _repository.uploadImage(
          event.imageBytes!,
          fileName,
          'products',
        );
      }

      final productToAdd = event.product;
      final updatedProduct = ProductModel(
        id: productToAdd.id,
        name: productToAdd.name,
        imageUrl: imageUrl,
        brandId: productToAdd.brandId,
        brandName: productToAdd.brandName,
        categoryId: productToAdd.categoryId,
        categoryName: productToAdd.categoryName,
        price: productToAdd.price,
        discount: productToAdd.discount,
        stockQuantity: productToAdd.stockQuantity,
        lastUpdated: productToAdd.lastUpdated,
      );

      await _repository.addProduct(updatedProduct);
      add(LoadInventory());
    } catch (e) {
      if (previousState is InventoryLoaded) {
        emit(previousState);
      }
      emit(InventoryError('Failed to add product: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateProduct(
    UpdateProduct event,
    Emitter<InventoryState> emit,
  ) async {
    final previousState = state;
    emit(InventoryLoading());
    try {
      String? imageUrl;
      if (event.imageBytes != null) {
        // Delete old image if it exists
        if (event.product.imageUrl != null &&
            event.product.imageUrl!.isNotEmpty) {
          await _repository.deleteImage(event.product.imageUrl!);
        }

        final fileName = 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
        imageUrl = await _repository.uploadImage(
          event.imageBytes!,
          fileName,
          'products',
        );
      }

      final productToUpdate = ProductModel(
        id: event.product.id,
        name: event.product.name,
        imageUrl: imageUrl ?? event.product.imageUrl,
        brandId: event.product.brandId,
        brandName: event.product.brandName,
        categoryId: event.product.categoryId,
        categoryName: event.product.categoryName,
        price: event.product.price,
        discount: event.product.discount,
        stockQuantity: event.product.stockQuantity,
        lastUpdated: DateTime.now(),
      );

      await _repository.updateProduct(productToUpdate);
      add(LoadInventory());
    } catch (e) {
      if (previousState is InventoryLoaded) {
        emit(previousState);
      }
      emit(InventoryError('Failed to update product: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateBrand(
    UpdateBrand event,
    Emitter<InventoryState> emit,
  ) async {
    final previousState = state;
    emit(InventoryLoading());
    try {
      String? logoUrl;
      if (event.imageBytes != null) {
        // Delete old logo if it exists
        if (event.brand.logoUrl.isNotEmpty) {
          await _repository.deleteImage(event.brand.logoUrl);
        }

        final fileName = 'brand_${DateTime.now().millisecondsSinceEpoch}.jpg';
        logoUrl = await _repository.uploadImage(
          event.imageBytes!,
          fileName,
          'brands',
        );
      }

      final brandToUpdate = BrandModel(
        id: event.brand.id,
        name: event.brand.name,
        logoUrl: logoUrl ?? event.brand.logoUrl,
      );

      await _repository.updateBrand(brandToUpdate);
      add(LoadInventory());
    } catch (e) {
      if (previousState is InventoryLoaded) {
        emit(previousState);
      }
      emit(InventoryError('Failed to update brand: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategory event,
    Emitter<InventoryState> emit,
  ) async {
    final previousState = state;
    emit(InventoryLoading());
    try {
      String? imageUrl;
      if (event.imageBytes != null) {
        // Delete old image if it exists
        if (event.category.imageUrl != null &&
            event.category.imageUrl!.isNotEmpty) {
          await _repository.deleteImage(event.category.imageUrl!);
        }

        final fileName =
            'category_${DateTime.now().millisecondsSinceEpoch}.jpg';
        imageUrl = await _repository.uploadImage(
          event.imageBytes!,
          fileName,
          'categories',
        );
      }

      final categoryToUpdate = CategoryModel(
        id: event.category.id,
        name: event.category.name,
        iconName: event.category.iconName,
        imageUrl: imageUrl ?? event.category.imageUrl,
      );

      await _repository.updateCategory(categoryToUpdate);
      add(LoadInventory());
    } catch (e) {
      if (previousState is InventoryLoaded) {
        emit(previousState);
      }
      emit(InventoryError('Failed to update category: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteProduct(
    DeleteProduct event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      // Delete image from storage if it exists
      if (event.product.imageUrl != null &&
          event.product.imageUrl!.isNotEmpty) {
        await _repository.deleteImage(event.product.imageUrl!);
      }

      await _repository.deleteProduct(event.product.id);
      add(LoadInventory());
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategory event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      // Delete image from storage if it exists
      if (event.category.imageUrl != null &&
          event.category.imageUrl!.isNotEmpty) {
        await _repository.deleteImage(event.category.imageUrl!);
      }

      await _repository.deleteCategory(event.category.id);
      add(LoadInventory());
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }

  Future<void> _onDeleteBrand(
    DeleteBrand event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      // Delete image from storage if it exists
      if (event.brand.logoUrl.isNotEmpty) {
        await _repository.deleteImage(event.brand.logoUrl);
      }

      await _repository.deleteBrand(event.brand.id);
      add(LoadInventory());
    } catch (e) {
      emit(InventoryError(e.toString()));
    }
  }
}
