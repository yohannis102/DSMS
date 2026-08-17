class PackageModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? createdAt;
  final String? updatedAt;

  const PackageModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.createdAt,
    this.updatedAt,
  });

  /// Backward-compatible alias
  String get packageName => name;

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['_id'] ?? json['id'] ?? '';
    final rawName = json['name'] ?? json['packageName'] ?? '';
    final rawDescription = json['description'] ?? '';
    final rawPrice = (json['price'] as num?)?.toDouble() ?? 0.0;

    return PackageModel(
      id: rawId.toString(),
      name: rawName.toString().trim(),
      description: rawDescription.toString().trim(),
      price: rawPrice >= 0 ? rawPrice : 0.0,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'description': description.trim(),
      'price': price,
    };
  }

  PackageModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? createdAt,
    String? updatedAt,
  }) {
    return PackageModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
