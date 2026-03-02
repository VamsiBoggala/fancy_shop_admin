import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  final String id;
  final String name;
  final String iconName;
  final String? imageUrl;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.iconName,
    this.imageUrl,
  });

  factory CategoryModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CategoryModel(
      id: id,
      name: data['name'] ?? '',
      iconName: data['iconName'] ?? '',
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'name': name, 'iconName': iconName, 'imageUrl': imageUrl};
  }

  @override
  List<Object?> get props => [id, name, iconName, imageUrl];
}
