import 'package:equatable/equatable.dart';
import '../../../../shared/utils/search_utils.dart';

class CategoryModel extends Equatable {
  final String id;
  final String name;
  final String iconName;
  final String? imageUrl;
  final List<String> searchKeywords;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.iconName,
    this.imageUrl,
    this.searchKeywords = const [],
  });

  factory CategoryModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CategoryModel(
      id: id,
      name: data['name'] ?? '',
      iconName: data['iconName'] ?? '',
      imageUrl: data['imageUrl'],
      searchKeywords: List<String>.from(data['searchKeywords'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'iconName': iconName,
      'imageUrl': imageUrl,
      'searchKeywords': generateSearchKeywords(name, ''),
    };
  }

  @override
  List<Object?> get props => [id, name, iconName, imageUrl, searchKeywords];
}
