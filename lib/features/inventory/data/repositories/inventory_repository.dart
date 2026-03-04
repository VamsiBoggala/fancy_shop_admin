import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fancy_shop_admin/core/constants/app_constants.dart';
import 'package:fancy_shop_admin/features/inventory/domain/models/brand_model.dart';
import 'package:fancy_shop_admin/features/inventory/domain/models/category_model.dart';
import 'package:fancy_shop_admin/features/inventory/domain/models/product_model.dart';
import 'dart:typed_data';

class InventoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ── Image Upload ─────────────────────────────────────────────────────────
  Future<String> uploadImage(
    Uint8List imageBytes,
    String fileName,
    String folder,
  ) async {
    final ref = _storage.ref().child('$folder/$fileName');
    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {'uploaded_at': DateTime.now().toIso8601String()},
    );
    final uploadTask = await ref.putData(imageBytes, metadata);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      if (imageUrl.isEmpty) return;
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Log error but don't rethrow as image deletion failure shouldn't block main workflow
      print('Error deleting image from storage: $e');
    }
  }

  // ── Brands ───────────────────────────────────────────────────────────────
  Future<List<BrandModel>> getBrands() async {
    final snapshot = await _firestore.collection(AppConstants.colBrands).get();
    return snapshot.docs
        .map((doc) => BrandModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<void> addBrand(BrandModel brand) async {
    await _firestore
        .collection(AppConstants.colBrands)
        .add(brand.toFirestore());
  }

  Future<void> updateBrand(BrandModel brand) async {
    await _firestore
        .collection(AppConstants.colBrands)
        .doc(brand.id)
        .update(brand.toFirestore());
  }

  // ── Categories ────────────────────────────────────────────────────────────
  Future<List<CategoryModel>> getCategories() async {
    final snapshot = await _firestore
        .collection(AppConstants.colCategories)
        .get();
    return snapshot.docs
        .map((doc) => CategoryModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<void> addCategory(CategoryModel category) async {
    await _firestore
        .collection(AppConstants.colCategories)
        .add(category.toFirestore());
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _firestore
        .collection(AppConstants.colCategories)
        .doc(category.id)
        .update(category.toFirestore());
  }

  Future<void> deleteCategory(String categoryId) async {
    await _firestore
        .collection(AppConstants.colCategories)
        .doc(categoryId)
        .delete();
  }

  Future<List<CategoryModel>> searchCategories(String query) async {
    final searchInput = query.toLowerCase().trim();
    if (searchInput.isEmpty) return getCategories();

    final snapshot = await _firestore
        .collection(AppConstants.colCategories)
        .where('searchKeywords', arrayContains: searchInput)
        .get();

    return snapshot.docs
        .map((doc) => CategoryModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<void> deleteBrand(String brandId) async {
    await _firestore.collection(AppConstants.colBrands).doc(brandId).delete();
  }

  Future<List<BrandModel>> searchBrands(String query) async {
    final searchInput = query.toLowerCase().trim();
    if (searchInput.isEmpty) return getBrands();

    final snapshot = await _firestore
        .collection(AppConstants.colBrands)
        .where('searchKeywords', arrayContains: searchInput)
        .get();

    return snapshot.docs
        .map((doc) => BrandModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  // ── Products ─────────────────────────────────────────────────────────────
  Future<List<ProductModel>> getProducts() async {
    final snapshot = await _firestore
        .collection(AppConstants.colProducts)
        .get();
    return snapshot.docs
        .map((doc) => ProductModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<void> addProduct(ProductModel product) async {
    await _firestore
        .collection(AppConstants.colProducts)
        .add(product.toFirestore());
  }

  Future<void> updateProduct(ProductModel product) async {
    await _firestore
        .collection(AppConstants.colProducts)
        .doc(product.id)
        .update(product.toFirestore());
  }

  Future<void> deleteProduct(String productId) async {
    await _firestore
        .collection(AppConstants.colProducts)
        .doc(productId)
        .delete();
  }

  /// Atomically increments (or decrements) stock by [delta] without a read.
  Future<void> updateStockDelta(String productId, int delta) async {
    await _firestore.collection(AppConstants.colProducts).doc(productId).update(
      {'stockQuantity': FieldValue.increment(delta)},
    );
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    final searchInput = query.toLowerCase().trim();
    if (searchInput.isEmpty) return getProducts();

    final snapshot = await _firestore
        .collection(AppConstants.colProducts)
        .where('searchKeywords', arrayContains: searchInput)
        .get();

    return snapshot.docs
        .map((doc) => ProductModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }
}
