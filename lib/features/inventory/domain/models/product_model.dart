import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../../../shared/utils/search_utils.dart';

class ProductModel extends Equatable {
  final String id;
  final String name;
  final String? imageUrl;
  final String brandId;
  final String brandName;
  final String categoryId;
  final String categoryName;
  final double price;
  final double discount;
  final int stockQuantity;
  final DateTime lastUpdated;
  final List<String> searchKeywords;

  const ProductModel({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.brandId,
    required this.brandName,
    required this.categoryId,
    required this.categoryName,
    required this.price,
    required this.discount,
    required this.stockQuantity,
    required this.lastUpdated,
    this.searchKeywords = const [],
  });

  factory ProductModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ProductModel(
      id: id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'],
      brandId: data['brandId'] ?? '',
      brandName: data['brandName'] ?? '',
      categoryId: data['categoryId'] ?? '',
      categoryName: data['categoryName'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      discount: (data['discount'] ?? 0).toDouble(),
      stockQuantity: (data['stockQuantity'] ?? 0).toInt(),
      lastUpdated:
          (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      searchKeywords: List<String>.from(data['searchKeywords'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'brandId': brandId,
      'brandName': brandName,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'price': price,
      'discount': discount,
      'stockQuantity': stockQuantity,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      // Always regenerate so renames/brand changes keep keywords fresh
      'searchKeywords': generateSearchKeywords(name, brandName),
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    imageUrl,
    brandId,
    brandName,
    categoryId,
    categoryName,
    price,
    discount,
    stockQuantity,
    lastUpdated,
    searchKeywords,
  ];
}
