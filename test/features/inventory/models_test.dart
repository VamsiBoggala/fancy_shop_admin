import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fancy_shop_admin/features/inventory/domain/models/brand_model.dart';
import 'package:fancy_shop_admin/features/inventory/domain/models/category_model.dart';
import 'package:fancy_shop_admin/features/inventory/domain/models/product_model.dart';

void main() {
  group('Inventory Models Test', () {
    test('BrandModel to/from Firestore', () {
      final data = {'name': 'Nike', 'logoUrl': 'https://nike.com/logo.png'};
      final brand = BrandModel.fromFirestore(data, 'brand_1');

      expect(brand.id, 'brand_1');
      expect(brand.name, 'Nike');
      expect(brand.toFirestore(), data);
    });

    test('CategoryModel to/from Firestore', () {
      final data = {'name': 'Shoes', 'iconName': 'shoe_icon'};
      final category = CategoryModel.fromFirestore(data, 'cat_1');

      expect(category.id, 'cat_1');
      expect(category.name, 'Shoes');
      expect(category.toFirestore(), data);
    });

    test('ProductModel to/from Firestore', () {
      final now = DateTime.now();
      final data = {
        'name': 'Air Max',
        'brandId': 'brand_1',
        'brandName': 'Nike',
        'categoryId': 'cat_1',
        'categoryName': 'Shoes',
        'price': 150.0,
        'discount': 10.0,
        'stockQuantity': 50,
        'lastUpdated': Timestamp.fromDate(now),
      };

      final product = ProductModel.fromFirestore(data, 'prod_1');

      expect(product.id, 'prod_1');
      expect(product.name, 'Air Max');
      expect(product.price, 150.0);
      expect(product.lastUpdated.year, now.year);

      final toFirestore = product.toFirestore();
      expect(toFirestore['name'], 'Air Max');
      expect(toFirestore['lastUpdated'], isA<Timestamp>());
    });
  });
}
