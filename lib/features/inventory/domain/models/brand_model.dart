import 'package:equatable/equatable.dart';

class BrandModel extends Equatable {
  final String id;
  final String name;
  final String logoUrl;

  const BrandModel({
    required this.id,
    required this.name,
    required this.logoUrl,
  });

  factory BrandModel.fromFirestore(Map<String, dynamic> data, String id) {
    return BrandModel(
      id: id,
      name: data['name'] ?? '',
      logoUrl: data['logoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'name': name, 'logoUrl': logoUrl};
  }

  @override
  List<Object?> get props => [id, name, logoUrl];
}
