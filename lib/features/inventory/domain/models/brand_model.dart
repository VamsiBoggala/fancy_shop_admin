import 'package:equatable/equatable.dart';
import '../../../../shared/utils/search_utils.dart';

class BrandModel extends Equatable {
  final String id;
  final String name;
  final String logoUrl;
  final List<String> searchKeywords;

  const BrandModel({
    required this.id,
    required this.name,
    required this.logoUrl,
    this.searchKeywords = const [],
  });

  factory BrandModel.fromFirestore(Map<String, dynamic> data, String id) {
    return BrandModel(
      id: id,
      name: data['name'] ?? '',
      logoUrl: data['logoUrl'] ?? '',
      searchKeywords: List<String>.from(data['searchKeywords'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'logoUrl': logoUrl,
      'searchKeywords': generateSearchKeywords(name, ''),
    };
  }

  @override
  List<Object?> get props => [id, name, logoUrl, searchKeywords];
}
