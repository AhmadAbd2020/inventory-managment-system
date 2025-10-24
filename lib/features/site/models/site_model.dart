class SiteModel {
  final String id;
  final String name;

  SiteModel({required this.id, required this.name});

  factory SiteModel.fromMap(String id, Map<String, dynamic> data) {
    return SiteModel(
      id: id,
      name: data['name'] ?? '',
    );
  }
}
